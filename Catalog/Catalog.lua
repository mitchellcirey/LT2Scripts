local Services = setmetatable({}, {
    __index = function(self, index)
        return game:GetService(index)
    end,
})

local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local Workspace = Services.Workspace
local HttpService = Services.HttpService

local Player = Players.LocalPlayer

local USERS = { "Cheeseandrice924", "digital_marine" }
local SHORT = { "Meow", "Jamey" }
local DIR = "LT2Scripts"
local DB_FILE = DIR .. "/catalog.json"
local PAGE_FILE = DIR .. "/catalog.html"

local GREEN = Color3.fromRGB(70, 190, 105)
local CYAN = Color3.fromRGB(70, 200, 210)
local YELLOW = Color3.fromRGB(230, 196, 70)
local RED = Color3.fromRGB(210, 70, 70)
local TEXT = Color3.fromRGB(230, 230, 230)
local MUTED = Color3.fromRGB(150, 150, 150)
local KINDS = {
    "Axes",
    "Balls",
    "Books",
    "Candy",
    "Candy Canes",
    "Food",
    "Fine Art",
    "Games",
    "Home",
    "Pumpkins",
    "Wobble Bobbles",
    "Vehicles",
    "Miscellaneous",
}
local KIND_RANK = {}
for index, kind in ipairs(KINDS) do
    KIND_RANK[kind] = index
end
local ROW_INSET = 16
local PRICE_W = 128
local PRICE_SHEET = "https://docs.google.com/spreadsheets/d/1zWvtEj0_Lp6dpk1yapMZ0pX_u6P58MN3u9znnPqjRxY/export?format=csv&gid=1798480138"

local ALIAS = {
    rukiryaxe = "rukiry axe",
    ["gift of good preparedness"] = "gift of preparedness",
    atv = "pink atv",
    snowmobile = "pink snowmobile",
    ["blue baii"] = "blue ball",
    ["ball of black"] = "black ball",
    ["bubblegum ball"] = "pink ball",
    ["ball of daisy"] = "daisy ball",
    ["ball of orange"] = "orange ball",
    ["ball of teal"] = "teal ball",
    ["ball of red"] = "red ball",
    ["ball of green"] = "green ball",
    ["hatchet by captain hoover"] = "hatchet by captain hoove",
    ["the lumber games by captain hoover"] = "the lumber games by captain hoove",
    ["ferry potter and the deathly shallows by captain hoover"] = "ferry potter and the deathly shallows by captain hoove",
    ["frankensign by captain hoover"] = "franken sign",
    ["the thing in yellow by miguel"] = "the thing in yellow",
    barnabill = "malicious duck",
    ["woabble wobble"] = "woable wobble",
    ["pink neon wire"] = "pink wire",
    ["magenta icicle lights"] = "magenta lights",
}
local ID_ALIAS = {
    ["2023CGift_Pixelatedo"] = { gift = "gift:gift of pixelation rare" },
    VoidEntity = { box = "box:void entity", loose = "loose:void entity" },
}

local started = false
local mounted = false
local loaded = false
local items = {}
local byId = {}
local statusNote = "Idle"
local query = ""
local sightings = {}
local displayNames = {}
local missing = {}
local childConn
local scanQueued = false
local pendingMore = false
local saveQueued = false
local root
local listFrame
local statusLabel
local searchBox

local function make(className, props, parent)
    local inst = Instance.new(className)
    for key, value in pairs(props) do
        inst[key] = value
    end
    inst.Parent = parent
    return inst
end

local function money(amount)
    local digits = tostring(math.floor(amount + 0.5))
    local rev = string.reverse(digits)
    rev = string.gsub(rev, "(%d%d%d)", "%1,")
    rev = string.reverse(rev)
    if string.sub(rev, 1, 1) == "," then
        rev = string.sub(rev, 2)
    end
    return "$" .. rev
end

local function shortRange(range)
    if type(range) ~= "table" or type(range[1]) ~= "number" then
        return nil
    end
    local low = range[1]
    local high = type(range[2]) == "number" and range[2] or low
    local function k(n)
        local v = n / 1000
        if math.abs(v - math.floor(v + 0.05)) < 0.06 then
            return tostring(math.floor(v + 0.5))
        end
        return string.format("%.1f", v)
    end
    if low >= 1000 and high >= 1000 then
        if low == high then
            return "$" .. k(low) .. "k"
        end
        return "$" .. k(low) .. "-" .. k(high) .. "k"
    end
    if low == high then
        return money(low)
    end
    return money(low) .. "-" .. money(high)
end

local function fullRange(range)
    if type(range) ~= "table" or type(range[1]) ~= "number" then
        return nil
    end
    local high = type(range[2]) == "number" and range[2] or range[1]
    if high == range[1] then
        return money(range[1])
    end
    return money(range[1]) .. "-" .. money(high)
end

local function blankSeen()
    local seen = {}
    for _, user in ipairs(USERS) do
        seen[user] = { have = false }
    end
    return seen
end

local function normalize(item)
    local prev = type(item.seen) == "table" and item.seen or {}
    item.seen = {}
    for _, user in ipairs(USERS) do
        local slot = prev[user]
        if type(slot) ~= "table" or slot[1] ~= nil then
            slot = {}
        end
        if slot.have == nil and (slot.box ~= nil or slot.open ~= nil) then
            item.seen[user] = {
                box = slot.box == true,
                open = slot.open == true,
            }
        else
            item.seen[user] = { have = slot.have == true }
        end
    end
    if type(item.offer) ~= "table" or item.offer[1] ~= nil then
        item.offer = nil
    end
end

local function normName(text)
    local value = string.lower(tostring(text or ""))
    value = string.gsub(value, "%b()", " ")
    value = string.gsub(value, "[^%w%s]", " ")
    value = string.gsub(value, "%s+", " ")
    value = string.gsub(value, "^%s+", "")
    value = string.gsub(value, "%s+$", "")
    return value
end

local function slug(text)
    local value = string.lower(tostring(text or ""))
    value = string.gsub(value, "[^%w%s]", " ")
    value = string.gsub(value, "%s+", " ")
    value = string.gsub(value, "^%s+", "")
    value = string.gsub(value, "%s+$", "")
    return value
end

local function baseName(text)
    return slug(normName(text))
end

local function parseRange(text)
    if type(text) ~= "string" then
        return nil
    end
    local value = string.lower(text)
    value = string.gsub(value, "(%d)k(%d)", "%1%2k")
    if string.find(value, "not ", 1, true)
        or string.find(value, "n/a", 1, true)
        or string.find(value, "object does not", 1, true)
        or string.find(value, "depend", 1, true)
        or string.find(value, "obtainable", 1, true)
    then
        return nil
    end
    local nums = {}
    for token in string.gmatch(value, "[%d%.]+%s*[km]?") do
        token = string.gsub(token, "%s", "")
        local amount = tonumber(string.match(token, "^[%d%.]+"))
        if amount then
            local suffix = string.sub(token, -1)
            if suffix == "k" then
                amount *= 1000
            elseif suffix == "m" then
                amount *= 1000000
            end
            if amount >= 1000 then
                table.insert(nums, amount)
            end
        end
    end
    if #nums == 0 then
        return nil
    end
    local low = nums[1]
    local high = nums[2] or low
    if high >= 1000 and low < 1000 then
        low *= 1000
    end
    if low > high then
        low, high = high, low
    end
    return { low, high }
end

local function parseCsv(text)
    local rows = {}
    local row = {}
    local chars = {}
    local i = 1
    local n = #text
    local function pushField()
        table.insert(row, table.concat(chars))
        chars = {}
    end
    local function pushRow()
        pushField()
        table.insert(rows, row)
        row = {}
    end
    while i <= n do
        local c = string.sub(text, i, i)
        if c == '"' then
            i += 1
            while i <= n do
                local d = string.sub(text, i, i)
                if d == '"' then
                    if string.sub(text, i + 1, i + 1) == '"' then
                        table.insert(chars, '"')
                        i += 2
                    else
                        i += 1
                        break
                    end
                else
                    table.insert(chars, d)
                    i += 1
                end
            end
        elseif c == "," then
            pushField()
            i += 1
        elseif c == "\n" then
            pushRow()
            i += 1
        elseif c == "\r" then
            pushRow()
            if string.sub(text, i + 1, i + 1) == "\n" then
                i += 1
            end
            i += 1
        else
            table.insert(chars, c)
            i += 1
        end
    end
    if #chars > 0 or #row > 0 then
        pushRow()
    end
    return rows
end

local function trim(text)
    local value = tostring(text or "")
    value = string.gsub(value, "^%s+", "")
    value = string.gsub(value, "%s+$", "")
    return value
end

local function usableName(name)
    local key = slug(name)
    if key == "" or #key < 3 or string.find(key, "object does not", 1, true) then
        return false
    end
    return true
end

local function sectionTitle(text)
    local value = trim(text)
    if string.sub(value, 1, 1) ~= "<" or string.sub(value, -1) ~= ">" then
        return nil
    end
    value = string.gsub(value, "^<%s*", "")
    value = string.gsub(value, "%s*>$", "")
    if value == "" then
        return nil
    end
    return value
end

local function fetchSheetBody()
    local ok, body = pcall(function()
        return game:HttpGet(PRICE_SHEET)
    end)
    if not ok or type(body) ~= "string" or not string.find(body, "Average", 1, true) then
        return nil
    end
    return body
end

local function sheetRows(body)
    local rows = {}
    local seen = {}
    local section = "Miscellaneous"
    local function add(kind, form, name, priceText)
        if not usableName(name) then
            return
        end
        local id = form .. ":" .. slug(name)
        if seen[id] then
            return
        end
        seen[id] = true
        table.insert(rows, {
            id = id,
            name = trim(name),
            kind = kind,
            form = form,
            price = parseRange(priceText),
        })
    end
    for _, row in ipairs(parseCsv(body)) do
        local title = sectionTitle(row[1])
        if title then
            section = title
        else
            add(section, "gift", row[2], row[3])
            add(section, "box", row[9], row[10])
            add(section, "loose", row[16], row[17])
        end
    end
    if #rows < 10 then
        return nil
    end
    return rows
end

local function sortItems()
    table.sort(items, function(a, b)
        local ra = KIND_RANK[a.kind] or 99
        local rb = KIND_RANK[b.kind] or 99
        if ra ~= rb then
            return ra < rb
        end
        return tostring(a.name) < tostring(b.name)
    end)
end

local function rebuildIndex()
    byId = {}
    for _, item in ipairs(items) do
        if type(item.id) == "string" then
            byId[item.id] = item
        end
    end
end

local function ensureFolder()
    if type(makefolder) == "function" and type(isfolder) == "function" and not isfolder(DIR) then
        pcall(makefolder, DIR)
    end
end

local function readJson(path)
    if type(readfile) ~= "function" then
        return nil
    end
    if type(isfile) == "function" and not isfile(path) then
        return nil
    end
    local ok, raw = pcall(readfile, path)
    if not ok or type(raw) ~= "string" or raw == "" then
        return nil
    end
    local decodedOk, data = pcall(function()
        return HttpService:JSONDecode(raw)
    end)
    if decodedOk and type(data) == "table" then
        return data
    end
    return nil
end

local function writeJson(path, data)
    if type(writefile) ~= "function" then
        return false
    end
    ensureFolder()
    local encodedOk, encoded = pcall(function()
        return HttpService:JSONEncode(data)
    end)
    if not encodedOk then
        return false
    end
    local ok = pcall(writefile, path, encoded)
    return ok
end

local function htmlEscape(text)
    return (tostring(text):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"))
end

local function progressLine(user)
    local have = 0
    for _, item in ipairs(items) do
        local slot = item.seen[user]
        if slot and slot.have then
            have += 1
        end
    end
    return user .. " " .. have .. "/" .. #items
end

local function checkCell(on, used)
    if not used then
        return ""
    end
    if on then
        return "&#10003;"
    end
    return "–"
end

local function buildPage()
    local rows = {}
    for _, item in ipairs(items) do
        local price = fullRange(item.offer and item.offer.box) or ""
        local first = item.seen[USERS[1]] or {}
        local second = item.seen[USERS[2]] or {}
        local blob = string.lower(tostring(item.name) .. " " .. tostring(item.id) .. " " .. tostring(item.kind))
        table.insert(rows, table.concat({
            '<tr data-name="', htmlEscape(blob), '">',
            "<td>", htmlEscape(item.name), "</td>",
            "<td>", htmlEscape(item.kind), "</td>",
            "<td>", htmlEscape(price), "</td>",
            "<td>", checkCell(first.have, true), "</td>",
            "<td>", checkCell(second.have, true), "</td>",
            "</tr>",
        }))
    end
    local summary = progressLine(USERS[1]) .. "<br>" .. progressLine(USERS[2])
    return table.concat({
        "<!DOCTYPE html><html><head><meta charset=\"utf-8\"><title>LT2 Catalog</title>",
        "<style>",
        "body{margin:24px;background:#121212;color:#e6e6e6;font:15px/1.4 sans-serif}",
        "h1{font-size:22px;font-weight:600;margin:0 0 8px}",
        "p{color:#a0a0a0;margin:0 0 16px}",
        "label{display:block;margin:0 0 12px}",
        "input{margin-left:8px;background:#3a3a3a;color:#e6e6e6;border:0;padding:4px 8px;font:15px sans-serif;width:240px}",
        "table{border-collapse:collapse;width:100%}",
        "th,td{text-align:left;padding:4px 8px;border-bottom:1px solid #2a2a2a;white-space:nowrap}",
        "th{color:#a0a0a0;font-weight:600}",
        "td:nth-child(n+4){text-align:center;color:#46be69}",
        "</style></head><body>",
        "<h1>Catalog</h1>",
        "<p>", summary, "</p>",
        "<p>Street prices refresh from the Aptyn sheet when Catalog starts.</p>",
        "<label>Search<input id=\"q\"></label>",
        "<table><thead><tr>",
        "<th>Item</th><th>Section</th><th>Price</th>",
        "<th>", htmlEscape(USERS[1]), "</th><th>", htmlEscape(USERS[2]), "</th>",
        "</tr></thead><tbody id=\"rows\">",
        table.concat(rows),
        "</tbody></table>",
        "<script>",
        "var q=document.getElementById('q');",
        "q.addEventListener('input',function(){",
        "var needle=q.value.toLowerCase();",
        "var list=document.querySelectorAll('#rows tr');",
        "for(var i=0;i<list.length;i++){",
        "var row=list[i];",
        "row.style.display=row.getAttribute('data-name').indexOf(needle)===-1?'none':'';",
        "}",
        "});",
        "</script></body></html>",
    })
end

local function saveDb()
    if type(writefile) ~= "function" then
        statusNote = "No file access"
        return
    end
    sortItems()
    local payload = { items = items }
    local ok = writeJson(DB_FILE, payload)
    if not ok then
        statusNote = "No file access"
        return
    end
    ensureFolder()
    pcall(writefile, PAGE_FILE, buildPage())
end

local function loadDb()
    items = {}
    byId = {}
    local data = readJson(DB_FILE)
    local source = data and data.items
    if type(source) ~= "table" then
        return
    end
    for _, item in ipairs(source) do
        if type(item) == "table" and type(item.id) == "string" and not byId[item.id] then
            item.kind = item.kind or "Axe"
            item.name = item.name or item.id
            normalize(item)
            byId[item.id] = item
            table.insert(items, item)
        end
    end
    sortItems()
end

local function ensureDb()
    if loaded then
        return
    end
    loaded = true
    loadDb()
end

local links = {}
local byBase = {}

local SHOP_FORMS = {
    Gift = { "gift" },
    Tool = { "box", "loose" },
    Vehicle = { "box", "loose" },
    ["Loose Item"] = { "box", "loose" },
    Furniture = { "box", "loose" },
    Wire = { "box", "loose" },
}

local function indexBases()
    byBase = {}
    local claimed = {}
    for _, item in ipairs(items) do
        local key = tostring(item.form or "") .. ":" .. baseName(item.name)
        if claimed[key] == nil then
            claimed[key] = item
        else
            claimed[key] = false
        end
    end
    for key, item in pairs(claimed) do
        if item then
            byBase[key] = item
        end
    end
end

local function matchItem(form, display)
    local key = slug(display)
    if key == "" then
        return nil
    end
    local keys = { key }
    local alias = ALIAS[key]
    if alias and alias ~= key then
        table.insert(keys, alias)
    end
    for _, try in ipairs(keys) do
        local exact = byId[form .. ":" .. try]
        if exact then
            return exact
        end
        if form == "box" then
            exact = byId["box:" .. try .. " boxed"]
            if exact then
                return exact
            end
        end
        local base = byBase[form .. ":" .. try]
        if base then
            return base
        end
    end
    return nil
end

local function shopInfo()
    local info = ReplicatedStorage:FindFirstChild("ClientItemInfo")
    if info then
        return info
    end
    local ok, found = pcall(function()
        return ReplicatedStorage:WaitForChild("ClientItemInfo", 15)
    end)
    if ok then
        return found
    end
    return nil
end

local function bindLink(gameId, form, item)
    if type(gameId) ~= "string" or gameId == "" or not item then
        return
    end
    links[string.lower(gameId) .. "\0" .. form] = item
    links[string.lower(gameId) .. "_vehicle\0" .. form] = item
    local stripped = string.gsub(gameId, "_Vehicle$", "")
    if stripped ~= gameId then
        links[string.lower(stripped) .. "\0" .. form] = item
    end
end

local function linkShop()
    links = {}
    indexBases()
    local info = shopInfo()
    if info then
        for _, child in ipairs(info:GetChildren()) do
            local typeValue = child:FindFirstChild("Type")
            local typeName = typeValue and tostring(typeValue.Value) or ""
            local forms = SHOP_FORMS[typeName]
            if forms then
                local nameValue = child:FindFirstChild("ItemName")
                local display = nameValue and tostring(nameValue.Value) or ""
                if display == "" then
                    display = child.Name
                end
                for _, form in ipairs(forms) do
                    bindLink(child.Name, form, matchItem(form, display) or matchItem(form, child.Name))
                end
            end
        end
    end
    for gameId, formMap in pairs(ID_ALIAS) do
        for form, itemId in pairs(formMap) do
            bindLink(gameId, form, byId[itemId])
        end
    end
end

local function samePrice(a, b)
    if a == nil or b == nil then
        return a == nil and b == nil
    end
    return a[1] == b[1] and a[2] == b[2]
end

local function syncPurchasables()
    local body = fetchSheetBody()
    if not body then
        if statusNote ~= "No file access" then
            statusNote = "Price list offline"
        end
        linkShop()
        return 0
    end
    local rows = sheetRows(body)
    if not rows then
        statusNote = "Price list offline"
        linkShop()
        return 0
    end
    local prev = {}
    local legacy = {}
    for _, item in ipairs(items) do
        if string.find(item.id, ":", 1, true) then
            prev[item.id] = item
        else
            legacy[baseName(item.name)] = item
        end
    end
    local fresh = {}
    local created = 0
    local dirty = false
    for _, row in ipairs(rows) do
        local item = prev[row.id]
        if not item then
            item = {
                id = row.id,
                name = row.name,
                kind = row.kind,
                form = row.form,
                seen = blankSeen(),
                offer = nil,
            }
            local old = legacy[baseName(row.name)]
            if old and type(old.seen) == "table" then
                for _, user in ipairs(USERS) do
                    local slot = old.seen[user]
                    if type(slot) == "table" then
                        if row.form == "gift" and (old.kind == "Gift" or old.form == "gift") then
                            item.seen[user].have = slot.have == true or slot.box == true
                        elseif row.form == "box" then
                            item.seen[user].have = slot.have == true or slot.box == true
                        elseif row.form == "loose" then
                            item.seen[user].have = slot.have == true or slot.open == true
                        end
                    end
                end
            end
            created += 1
            dirty = true
        elseif item.name ~= row.name or item.kind ~= row.kind or item.form ~= row.form then
            item.name = row.name
            item.kind = row.kind
            item.form = row.form
            dirty = true
        end
        local nextOffer = row.price and { box = row.price } or nil
        local current = item.offer
        if not samePrice(current and current.box, nextOffer and nextOffer.box) or (current == nil) ~= (nextOffer == nil) then
            item.offer = nextOffer
            dirty = true
        end
        normalize(item)
        table.insert(fresh, item)
    end
    if #items ~= #fresh then
        dirty = true
    end
    items = fresh
    rebuildIndex()
    sortItems()
    linkShop()
    if dirty then
        saveDb()
    end
    return created
end

local function canonicalUser(name)
    local lower = string.lower(name)
    for _, user in ipairs(USERS) do
        if string.lower(user) == lower then
            return user
        end
    end
    return nil
end

local function lookupDisplay(username)
    if type(username) ~= "string" or username == "" then
        return username
    end
    local cached = displayNames[username]
    if cached then
        return cached
    end
    local player = Players:FindFirstChild(username)
    if player and player:IsA("Player") and player.DisplayName ~= "" then
        displayNames[username] = player.DisplayName
        return player.DisplayName
    end
    return username
end

local function ownerName(model)
    local owner = model:FindFirstChild("Owner")
    if not (owner and owner:IsA("ValueBase")) then
        return nil
    end
    local value = owner.Value
    if typeof(value) == "Instance" then
        if value:IsA("Player") and value.DisplayName ~= "" then
            displayNames[value.Name] = value.DisplayName
        end
        return value.Name
    end
    if type(value) == "string" and value ~= "" then
        lookupDisplay(value)
        return value
    end
    return nil
end

local function heldItem(model)
    local typeValue = model:FindFirstChild("Type")
    local typeName = typeValue and tostring(typeValue.Value) or ""
    if typeName == "Blueprint" or typeName == "Structure" or typeName == "Vehicle Spot" then
        return nil
    end
    local box = model:FindFirstChild("PurchasedBoxItemName")
    local itemName = model:FindFirstChild("ItemName")
    local toolName = model:FindFirstChild("ToolName")
    local boxId = box and tostring(box.Value) or ""
    local openId = itemName and tostring(itemName.Value) or ""
    if openId == "" and toolName then
        openId = tostring(toolName.Value)
    end
    local form, gameId
    if typeName == "Gift" and openId ~= "" then
        form = "gift"
        gameId = openId
    elseif boxId ~= "" and openId == "" then
        form = "box"
        gameId = boxId
    elseif openId ~= "" then
        form = "loose"
        gameId = openId
    else
        return nil
    end
    return links[string.lower(gameId) .. "\0" .. form]
end

local function weHave(item)
    for _, user in ipairs(USERS) do
        local slot = item.seen[user]
        if slot and slot.have then
            return true
        end
    end
    return false
end

local function userHas(item, username)
    local slot = item.seen[username]
    return slot ~= nil and slot.have == true
end

local function localTrackedUser()
    local name = Player and Player.Name
    if type(name) ~= "string" then
        return nil
    end
    local lower = string.lower(name)
    for _, user in ipairs(USERS) do
        if string.lower(user) == lower then
            return user
        end
    end
    return nil
end

local function itemColor(item)
    local mine = localTrackedUser()
    local iHave = mine ~= nil and userHas(item, mine)
    local both = iHave
    if both then
        for _, user in ipairs(USERS) do
            if not userHas(item, user) then
                both = false
                break
            end
        end
    end
    if both then
        return CYAN
    end
    if iHave then
        return GREEN
    end
    if missing[item.id] then
        return YELLOW
    end
    return RED
end

local function clearHud()
    local parents = {}
    local ok, hui = pcall(gethui)
    if ok and hui then
        table.insert(parents, hui)
    end
    local coreOk, core = pcall(function()
        return Services.CoreGui
    end)
    if coreOk and core then
        table.insert(parents, core)
    end
    local playerGui = Player:FindFirstChild("PlayerGui")
    if playerGui then
        table.insert(parents, playerGui)
    end
    for _, parent in ipairs(parents) do
        local existing = parent:FindFirstChild("JellCatalogHud")
        if existing then
            existing:Destroy()
        end
    end
end

local function remember(owner, item)
    local key = string.lower(owner) .. "\0" .. item.id
    local hit = sightings[key]
    if not hit then
        hit = {
            owner = owner,
            display = lookupDisplay(owner),
            id = item.id,
            count = 0,
        }
        sightings[key] = hit
    end
    hit.display = lookupDisplay(owner)
    hit.count += 1
end

local function rebuildMissing()
    missing = {}
    for _, hit in pairs(sightings) do
        local item = byId[hit.id]
        if item and not weHave(item) then
            local holders = missing[hit.id]
            if not holders then
                holders = {}
                missing[hit.id] = holders
            end
            holders[hit.owner] = {
                display = hit.display or lookupDisplay(hit.owner),
                count = hit.count or 1,
            }
        end
    end
end

local function holderText(item)
    local holders = missing[item.id]
    if type(holders) ~= "table" then
        return ""
    end
    local names = {}
    for _, slot in pairs(holders) do
        local display = slot
        local count = 1
        if type(slot) == "table" then
            display = slot.display
            count = slot.count or 1
        end
        table.insert(names, tostring(display) .. " x" .. tostring(count))
    end
    table.sort(names)
    return table.concat(names, ", ")
end

local function missingKey()
    local ids = {}
    for id, holders in pairs(missing) do
        local names = {}
        if type(holders) == "table" then
            for owner, slot in pairs(holders) do
                local display = slot
                local count = 1
                if type(slot) == "table" then
                    display = slot.display
                    count = slot.count or 1
                end
                table.insert(names, owner .. "=" .. tostring(display) .. ":" .. tostring(count))
            end
        end
        table.sort(names)
        table.insert(ids, id .. "=" .. table.concat(names, ","))
    end
    table.sort(ids)
    return table.concat(ids, "\n")
end

local function readModel(model)
    if not model:IsA("Model") then
        return nil
    end
    local owner = ownerName(model)
    local item = heldItem(model)
    if not owner or not item then
        return nil
    end
    return owner, item
end

local queueSave
local refreshUi

local function scanAll(folder)
    local save = false
    for _, model in ipairs(folder:GetChildren()) do
        local owner, item = readModel(model)
        if owner and item then
            local user = canonicalUser(owner)
            if user then
                local slot = item.seen[user]
                if not slot then
                    slot = { have = false }
                    item.seen[user] = slot
                end
                if not slot.have then
                    slot.have = true
                    save = true
                end
            end
        end
    end
    sightings = {}
    for _, model in ipairs(folder:GetChildren()) do
        local owner, item = readModel(model)
        if owner and item and not canonicalUser(owner) then
            remember(owner, item)
        end
    end
    local previous = missingKey()
    rebuildMissing()
    if save then
        queueSave()
    end
    if (save or missingKey() ~= previous) and refreshUi then
        refreshUi()
    end
end

local function scheduleScan()
    if scanQueued or not started then
        return
    end
    scanQueued = true
    task.delay(0.75, function()
        if not started then
            scanQueued = false
            return
        end
        local folder = Workspace:FindFirstChild("PlayerModels")
        if folder then
            scanAll(folder)
        end
        scanQueued = false
        if pendingMore then
            pendingMore = false
            scheduleScan()
        end
    end)
end

local function watchBases()
    local folder = Workspace:FindFirstChild("PlayerModels")
    if not folder then
        folder = Workspace:WaitForChild("PlayerModels", 20)
    end
    if not started or not folder then
        if started then
            statusNote = "No bases"
            if refreshUi then
                refreshUi()
            end
        end
        return
    end
    scanAll(folder)
    if childConn then
        childConn:Disconnect()
    end
    childConn = folder.ChildAdded:Connect(function()
        if not started then
            return
        end
        if scanQueued then
            pendingMore = true
        else
            scheduleScan()
        end
    end)
    task.delay(3, function()
        if started and folder.Parent then
            scanAll(folder)
        end
    end)
end

local function ownedCount(user)
    local count = 0
    for _, item in ipairs(items) do
        local slot = item.seen[user]
        if slot and slot.have then
            count += 1
        end
    end
    return count
end

local function cellPrice(item)
    local text = shortRange(item.offer and item.offer.box)
    if text then
        return text, true
    end
    return "—", false
end

local function clearRows()
    if not listFrame then
        return
    end
    for _, child in ipairs(listFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
end

local function addMark(parent, x, y, on, used)
    if not used then
        return
    end
    make("TextLabel", {
        Size = UDim2.fromOffset(16, 16),
        Position = UDim2.fromOffset(x, y),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = on and "✓" or "–",
        TextSize = 15,
        TextColor3 = on and GREEN or MUTED,
    }, parent)
end

local function letter(parent, x, y, text, color, width)
    make("TextLabel", {
        Size = UDim2.fromOffset(width or 14, 16),
        Position = UDim2.fromOffset(x, y),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = text,
        TextSize = 13,
        TextColor3 = color,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, parent)
end

refreshUi = function()
    if not (root and root.Parent and listFrame) then
        return
    end
    if statusLabel then
        statusLabel.Text = statusNote
            .. "  "
            .. lookupDisplay(USERS[1])
            .. " "
            .. ownedCount(USERS[1])
            .. "/"
            .. #items
            .. "  "
            .. lookupDisplay(USERS[2])
            .. " "
            .. ownedCount(USERS[2])
            .. "/"
            .. #items
    end
    clearRows()
    local needle = query
    local shown = {}
    for _, item in ipairs(items) do
        local blob = string.lower(item.name .. " " .. item.id)
        if needle == "" or string.find(blob, needle, 1, true) then
            table.insert(shown, item)
        end
    end

    local order = 0
    local function section(title, color)
        order += 1
        local row = make("Frame", {
            Size = UDim2.new(1, -ROW_INSET, 0, 20),
            BackgroundTransparency = 1,
            LayoutOrder = order,
        }, listFrame)
        make("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.SourceSansBold,
            Text = title,
            TextSize = 14,
            TextColor3 = color,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, row)
    end

    local function playerMarks(row, x, label, on)
        letter(row, x, 18, label, MUTED, 52)
        addMark(row, x + 54, 18, on, true)
    end

    local band = 0
    local function addItem(item)
        order += 1
        band += 1
        local holders = holderText(item)
        local gone = holders ~= ""
        local row = make("Frame", {
            Size = UDim2.new(1, -ROW_INSET, 0, gone and 52 or 36),
            BackgroundColor3 = Color3.fromRGB(32, 32, 32),
            BackgroundTransparency = band % 2 == 0 and 0 or 1,
            BorderSizePixel = 0,
            LayoutOrder = order,
        }, listFrame)
        make("TextLabel", {
            Size = UDim2.new(1, -(PRICE_W + 14), 0, 18),
            Position = UDim2.fromOffset(6, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.SourceSans,
            Text = item.name,
            TextSize = 15,
            TextColor3 = itemColor(item),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
        }, row)
        local price, estimated = cellPrice(item)
        make("TextLabel", {
            Size = UDim2.fromOffset(PRICE_W, 18),
            Position = UDim2.new(1, -PRICE_W, 0, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.SourceSans,
            Text = price,
            TextSize = 14,
            TextColor3 = estimated and TEXT or MUTED,
            TextXAlignment = Enum.TextXAlignment.Right,
            TextTruncate = Enum.TextTruncate.AtEnd,
        }, row)
        playerMarks(row, 6, SHORT[1], (item.seen[USERS[1]] or {}).have == true)
        playerMarks(row, 130, SHORT[2], (item.seen[USERS[2]] or {}).have == true)
        letter(row, 254, 18, "M", gone and YELLOW or MUTED, 14)
        if gone then
            make("TextLabel", {
                Size = UDim2.new(1, -12, 0, 16),
                Position = UDim2.fromOffset(6, 34),
                BackgroundTransparency = 1,
                Font = Enum.Font.SourceSans,
                Text = holders,
                TextSize = 14,
                TextColor3 = YELLOW,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
            }, row)
        end
    end

    local missingRows = {}
    local groups = {}
    local extras = {}
    for _, kind in ipairs(KINDS) do
        groups[kind] = {}
    end
    for _, item in ipairs(shown) do
        if missing[item.id] then
            table.insert(missingRows, item)
        elseif groups[item.kind] then
            table.insert(groups[item.kind], item)
        else
            local bucket = extras[item.kind]
            if not bucket then
                bucket = {}
                extras[item.kind] = bucket
            end
            table.insert(bucket, item)
        end
    end
    table.sort(missingRows, function(a, b)
        return tostring(a.name) < tostring(b.name)
    end)
    if #missingRows > 0 then
        section("Missing", YELLOW)
        for _, item in ipairs(missingRows) do
            addItem(item)
        end
    end
    for _, kind in ipairs(KINDS) do
        local bucket = groups[kind]
        if #bucket > 0 then
            section(kind, MUTED)
            for _, item in ipairs(bucket) do
                addItem(item)
            end
        end
    end
    local extraNames = {}
    for kind in pairs(extras) do
        table.insert(extraNames, kind)
    end
    table.sort(extraNames)
    for _, kind in ipairs(extraNames) do
        section(kind, MUTED)
        for _, item in ipairs(extras[kind]) do
            addItem(item)
        end
    end
end

queueSave = function()
    if saveQueued then
        return
    end
    saveQueued = true
    task.delay(0.4, function()
        saveQueued = false
        saveDb()
    end)
end

local function build(parent)
    root = make("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
    }, parent)

    make("TextLabel", {
        Size = UDim2.fromOffset(52, 22),
        Position = UDim2.fromOffset(8, 8),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = "Search",
        TextSize = 15,
        TextColor3 = Color3.fromRGB(210, 210, 210),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, root)

    searchBox = make("TextBox", {
        Size = UDim2.new(1, -76, 0, 22),
        Position = UDim2.fromOffset(64, 8),
        BackgroundColor3 = Color3.fromRGB(58, 58, 58),
        BorderSizePixel = 0,
        ClearTextOnFocus = false,
        Font = Enum.Font.SourceSans,
        Text = "",
        TextSize = 15,
        TextColor3 = TEXT,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, root)
    make("UIPadding", {
        PaddingLeft = UDim.new(0, 6),
    }, searchBox)

    local header = make("Frame", {
        Size = UDim2.new(1, -(16 + ROW_INSET), 0, 18),
        Position = UDim2.fromOffset(8, 36),
        BackgroundTransparency = 1,
    }, root)
    make("TextLabel", {
        Size = UDim2.new(1, -PRICE_W, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = "Item",
        TextSize = 13,
        TextColor3 = MUTED,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, header)
    make("TextLabel", {
        Size = UDim2.fromOffset(PRICE_W, 18),
        Position = UDim2.new(1, -PRICE_W, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = "Price",
        TextSize = 13,
        TextColor3 = MUTED,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, header)

    listFrame = make("ScrollingFrame", {
        Size = UDim2.new(1, -16, 1, -78),
        Position = UDim2.fromOffset(8, 56),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Color3.fromRGB(70, 70, 70),
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
    }, root)
    make("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, listFrame)

    statusLabel = make("TextLabel", {
        Size = UDim2.new(1, -16, 0, 16),
        Position = UDim2.new(0, 8, 1, -18),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = statusNote,
        TextSize = 14,
        TextColor3 = MUTED,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, root)

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        query = string.lower(searchBox.Text)
        refreshUi()
    end)
end

local api = {}

function api.start()
    if started then
        return
    end
    started = true
    clearHud()
    ensureDb()
    statusNote = "Scanning"
    refreshUi()
    task.spawn(function()
        local ok, err = xpcall(function()
            local created = syncPurchasables()
            if statusNote ~= "No file access" and statusNote ~= "No item list" then
                if created > 0 then
                    statusNote = tostring(created) .. " added"
                elseif statusNote == "Scanning" then
                    statusNote = "Idle"
                end
            end
            watchBases()
            if statusNote == "Scanning" then
                statusNote = "Idle"
            end
        end, debug.traceback)
        if not ok then
            statusNote = "Error"
            warn("[Jell] Catalog " .. tostring(err))
        end
        clearHud()
        refreshUi()
    end)
end

function api.stop()
    started = false
    if childConn then
        childConn:Disconnect()
        childConn = nil
    end
    scanQueued = false
    pendingMore = false
    sightings = {}
    displayNames = {}
    missing = {}
    clearHud()
    if statusNote == "Scanning" then
        statusNote = "Idle"
    end
    refreshUi()
end

function api.mount(parent)
    if mounted then
        api.unmount()
    end
    ensureDb()
    build(parent)
    mounted = true
    refreshUi()
end

function api.unmount()
    if root then
        root:Destroy()
        root = nil
    end
    listFrame = nil
    statusLabel = nil
    searchBox = nil
    mounted = false
end

return api
