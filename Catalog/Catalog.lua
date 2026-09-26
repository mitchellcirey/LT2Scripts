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
local KIND_TITLE = { Gift = "Gifts", Axe = "Axes", Vehicle = "Vehicles" }
local DIR = "LT2Scripts"
local CACHE_FILE = DIR .. "/purchasables.json"
local DB_FILE = DIR .. "/catalog.json"
local PAGE_FILE = DIR .. "/catalog.html"

local GREEN = Color3.fromRGB(70, 190, 105)
local YELLOW = Color3.fromRGB(230, 196, 70)
local TEXT = Color3.fromRGB(230, 230, 230)
local MUTED = Color3.fromRGB(150, 150, 150)
local KIND_ORDER = { Gift = 1, Axe = 2, Vehicle = 3 }
local ROW_INSET = 16
local PRICE_W = 128
local PRICE_SHEET = "https://docs.google.com/spreadsheets/d/1zWvtEj0_Lp6dpk1yapMZ0pX_u6P58MN3u9znnPqjRxY/export?format=csv&gid=1798480138"

local ALIAS = {
    rukiryaxe = "rukiry axe",
    ["gift of good preparedness"] = "gift of preparedness",
    atv = "pink atv",
    snowmobile = "pink snowmobile",
}

local started = false
local mounted = false
local loaded = false
local items = {}
local byId = {}
local statusNote = "Idle"
local query = ""
local sightings = {}
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
        seen[user] = { box = false, open = false }
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
        item.seen[user] = {
            box = slot.box == true,
            open = slot.open == true,
        }
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

local function rememberPrice(map, name, price)
    local key = normName(name)
    if key == "" or #key < 3 or string.find(key, "object does not", 1, true) then
        return
    end
    local range = parseRange(price)
    if not range then
        return
    end
    local prev = map[key]
    if not prev or range[2] < prev[2] then
        map[key] = range
    end
end

local function fetchStreetLookup()
    local ok, body = pcall(function()
        return game:HttpGet(PRICE_SHEET)
    end)
    if not ok or type(body) ~= "string" or not string.find(body, "Average", 1, true) then
        return nil
    end
    local lookup = { gift = {}, box = {}, open = {} }
    for _, row in ipairs(parseCsv(body)) do
        rememberPrice(lookup.gift, row[2], row[3])
        rememberPrice(lookup.box, row[9], row[10])
        rememberPrice(lookup.open, row[16], row[17])
    end
    local priced = 0
    for _ in pairs(lookup.gift) do
        priced += 1
    end
    for _ in pairs(lookup.box) do
        priced += 1
    end
    for _ in pairs(lookup.open) do
        priced += 1
    end
    if priced < 10 then
        return nil
    end
    return lookup
end

local function priceFrom(map, name)
    local key = normName(name)
    if map[key] then
        return map[key]
    end
    local stripped = string.gsub(key, "^the ", "")
    if map[stripped] then
        return map[stripped]
    end
    local alias = ALIAS[key] or ALIAS[stripped]
    if alias and map[alias] then
        return map[alias]
    end
    return nil
end

local function sameRange(a, b)
    if a == nil or b == nil then
        return a == nil and b == nil
    end
    return a[1] == b[1] and a[2] == b[2]
end

local function streetOffer(item, lookup)
    if item.kind == "Gift" then
        local gift = priceFrom(lookup.gift, item.name)
        if not gift then
            return nil
        end
        return { box = gift }
    end
    local offer = {}
    local boxed = priceFrom(lookup.box, item.name)
    local opened = priceFrom(lookup.open, item.name)
    if boxed then
        offer.box = boxed
    end
    if opened then
        offer.open = opened
    end
    if not boxed and not opened then
        return nil
    end
    return offer
end

local function assignStreet(item, lookup)
    local nextOffer = streetOffer(item, lookup)
    local current = item.offer
    local sameBox = sameRange(current and current.box, nextOffer and nextOffer.box)
    local sameOpen = sameRange(current and current.open, nextOffer and nextOffer.open)
    if sameBox and sameOpen and (current == nil) == (nextOffer == nil) then
        return false
    end
    item.offer = nextOffer
    return true
end

local function sortItems()
    table.sort(items, function(a, b)
        local ra = KIND_ORDER[a.kind] or 9
        local rb = KIND_ORDER[b.kind] or 9
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

local function formCount(user, kind, form)
    local have = 0
    local total = 0
    for _, item in ipairs(items) do
        if item.kind == kind then
            total += 1
            local slot = item.seen[user]
            if slot and slot[form] then
                have += 1
            end
        end
    end
    return have, total
end

local function progressLine(user)
    local function bit(label, kind, form)
        local have, total = formCount(user, kind, form)
        return label .. " " .. have .. "/" .. total
    end
    return table.concat({
        user,
        bit("gifts", "Gift", "box"),
        bit("axe boxes", "Axe", "box"),
        bit("open axes", "Axe", "open"),
        bit("vehicle boxes", "Vehicle", "box"),
        bit("open vehicles", "Vehicle", "open"),
    }, " · ")
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
        local boxOffer = fullRange(item.offer and item.offer.box) or ""
        local openOffer = fullRange(item.offer and item.offer.open) or ""
        local openUsed = item.kind ~= "Gift"
        local first = item.seen[USERS[1]] or {}
        local second = item.seen[USERS[2]] or {}
        local blob = string.lower(tostring(item.name) .. " " .. tostring(item.id) .. " " .. tostring(item.kind))
        table.insert(rows, table.concat({
            '<tr data-name="', htmlEscape(blob), '">',
            "<td>", htmlEscape(item.name), "</td>",
            "<td>", htmlEscape(item.kind), "</td>",
            "<td>", htmlEscape(boxOffer), "</td>",
            "<td>", htmlEscape(openOffer), "</td>",
            "<td>", checkCell(first.box, true), "</td>",
            "<td>", checkCell(first.open, openUsed), "</td>",
            "<td>", checkCell(second.box, true), "</td>",
            "<td>", checkCell(second.open, openUsed), "</td>",
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
        "td:nth-child(n+6){text-align:center;color:#46be69}",
        "</style></head><body>",
        "<h1>Catalog</h1>",
        "<p>", summary, "</p>",
        "<p>Street prices refresh from the Aptyn sheet when Catalog starts.</p>",
        "<label>Search<input id=\"q\"></label>",
        "<table><thead><tr>",
        "<th>Item</th><th>Kind</th><th>Box</th><th>Open</th>",
        "<th>", htmlEscape(USERS[1]), " box</th><th>", htmlEscape(USERS[1]), " open</th>",
        "<th>", htmlEscape(USERS[2]), " box</th><th>", htmlEscape(USERS[2]), " open</th>",
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

local function createItem(row)
    if byId[row.id] then
        return byId[row.id], false
    end
    local item = {
        id = row.id,
        name = row.name,
        kind = row.kind,
        shop = row.shop,
        seen = blankSeen(),
    }
    byId[row.id] = item
    table.insert(items, item)
    return item, true
end

local function readFolder(folder)
    local rows = {}
    if not folder then
        return rows
    end
    for _, child in ipairs(folder:GetChildren()) do
        local typeValue = child:FindFirstChild("Type")
        local typeName = typeValue and tostring(typeValue.Value) or ""
        local kind = nil
        if typeName == "Gift" then
            kind = "Gift"
        elseif typeName == "Tool" then
            kind = "Axe"
        elseif typeName == "Vehicle" then
            kind = "Vehicle"
        end
        if kind then
            local nameValue = child:FindFirstChild("ItemName")
            local name = nameValue and tostring(nameValue.Value) or child.Name
            if name == "" then
                name = child.Name
            end
            local priceValue = child:FindFirstChild("Price")
            local shop = priceValue and tonumber(priceValue.Value) or 0
            table.insert(rows, {
                id = child.Name,
                name = name,
                kind = kind,
                shop = shop,
            })
        end
    end
    table.sort(rows, function(a, b)
        return a.id < b.id
    end)
    return rows
end

local function readLive()
    local purch = ReplicatedStorage:FindFirstChild("Purchasables")
    local rows = readFolder(purch)
    if #rows > 0 then
        return rows
    end
    local info = ReplicatedStorage:FindFirstChild("ClientItemInfo")
    if not info then
        local ok, found = pcall(function()
            return ReplicatedStorage:WaitForChild("ClientItemInfo", 15)
        end)
        if ok then
            info = found
        end
    end
    return readFolder(info)
end

local function syncPurchasables()
    local live = readLive()
    if #live == 0 then
        statusNote = "No item list"
        return 0
    end
    writeJson(CACHE_FILE, { items = live })
    local created = 0
    local dirty = false
    for _, row in ipairs(live) do
        local item, made = createItem(row)
        if made then
            created += 1
            dirty = true
        else
            if item.name ~= row.name or item.shop ~= row.shop or item.kind ~= row.kind then
                item.name = row.name
                item.shop = row.shop
                item.kind = row.kind
                dirty = true
            end
        end
    end
    local lookup = fetchStreetLookup()
    if lookup then
        for _, item in ipairs(items) do
            if assignStreet(item, lookup) then
                dirty = true
            end
        end
    elseif statusNote ~= "No file access" then
        statusNote = "Price list offline"
    end
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

local function ownerName(model)
    local owner = model:FindFirstChild("Owner")
    if not (owner and owner:IsA("ValueBase")) then
        return nil
    end
    local value = owner.Value
    if typeof(value) == "Instance" then
        return value.Name
    end
    if type(value) == "string" and value ~= "" then
        return value
    end
    return nil
end

local function heldItem(model)
    local typeValue = model:FindFirstChild("Type")
    local typeName = typeValue and tostring(typeValue.Value) or ""
    if typeName == "Blueprint" or typeName == "Structure" or typeName == "Wire"
        or typeName == "Furniture" or typeName == "Loose Item" then
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
    if boxId ~= "" and openId == "" then
        return boxId, "box"
    end
    if openId ~= "" then
        if typeName == "Gift" then
            return openId, "box"
        end
        return openId, "open"
    end
    if boxId ~= "" then
        return boxId, "box"
    end
    return nil
end

local function weHave(item, form)
    for _, user in ipairs(USERS) do
        local slot = item.seen[user]
        if slot and slot[form] then
            return true
        end
    end
    return false
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

local function remember(owner, item, form)
    local key = string.lower(owner) .. "\0" .. item.id .. "\0" .. form
    sightings[key] = { owner = owner, id = item.id, form = form }
end

local function rebuildMissing()
    missing = {}
    for _, hit in pairs(sightings) do
        local item = byId[hit.id]
        if item and not weHave(item, hit.form) then
            missing[hit.id] = true
        end
    end
end

local function missingKey()
    local ids = {}
    for id in pairs(missing) do
        table.insert(ids, id)
    end
    table.sort(ids)
    return table.concat(ids, "\n")
end

local function readModel(model)
    if not model:IsA("Model") then
        return nil
    end
    local owner = ownerName(model)
    local id, form = heldItem(model)
    if not owner or not id or not form then
        return nil
    end
    local item = byId[id]
    if not item then
        return nil
    end
    return owner, item, form
end

local queueSave
local refreshUi

local function scanAll(folder)
    local save = false
    for _, model in ipairs(folder:GetChildren()) do
        local owner, item, form = readModel(model)
        if owner and item and form then
            local user = canonicalUser(owner)
            if user then
                local slot = item.seen[user]
                if not slot then
                    slot = { box = false, open = false }
                    item.seen[user] = slot
                end
                if not slot[form] then
                    slot[form] = true
                    save = true
                end
            end
        end
    end
    sightings = {}
    for _, model in ipairs(folder:GetChildren()) do
        local owner, item, form = readModel(model)
        if owner and item and form and not canonicalUser(owner) then
            remember(owner, item, form)
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
        if slot and (slot.box or slot.open) then
            count += 1
        end
    end
    return count
end

local function cellPrice(item)
    local parts = {}
    local boxText = shortRange(item.offer and item.offer.box)
    local openText = shortRange(item.offer and item.offer.open)
    if item.kind == "Gift" then
        if boxText then
            return boxText, true
        end
    else
        if boxText then
            table.insert(parts, "B " .. boxText)
        end
        if openText then
            table.insert(parts, "O " .. openText)
        end
        if #parts > 0 then
            return table.concat(parts, "  "), true
        end
    end
    if type(item.shop) == "number" then
        return "—", false
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
            .. USERS[1]
            .. " "
            .. ownedCount(USERS[1])
            .. "/"
            .. #items
            .. "  "
            .. USERS[2]
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

    local function playerMarks(row, x, label, slot, openUsed)
        letter(row, x, 18, label, MUTED, 52)
        letter(row, x + 54, 18, "B", MUTED, 12)
        addMark(row, x + 66, 18, slot.box == true, true)
        if openUsed then
            letter(row, x + 84, 18, "O", MUTED, 12)
            addMark(row, x + 96, 18, slot.open == true, true)
        end
    end

    local function addItem(item)
        order += 1
        local gone = missing[item.id] == true
        local row = make("Frame", {
            Size = UDim2.new(1, -ROW_INSET, 0, 36),
            BackgroundTransparency = 1,
            LayoutOrder = order,
        }, listFrame)
        make("TextLabel", {
            Size = UDim2.new(1, -(PRICE_W + 8), 0, 18),
            BackgroundTransparency = 1,
            Font = Enum.Font.SourceSans,
            Text = item.name,
            TextSize = 15,
            TextColor3 = gone and YELLOW or TEXT,
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
        local openUsed = item.kind ~= "Gift"
        playerMarks(row, 0, SHORT[1], item.seen[USERS[1]] or {}, openUsed)
        playerMarks(row, 124, SHORT[2], item.seen[USERS[2]] or {}, openUsed)
        letter(row, 248, 18, "M", gone and YELLOW or MUTED, 14)
    end

    local missingRows = {}
    local groups = { Gift = {}, Axe = {}, Vehicle = {} }
    for _, item in ipairs(shown) do
        if missing[item.id] then
            table.insert(missingRows, item)
        elseif groups[item.kind] then
            table.insert(groups[item.kind], item)
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
    for _, kind in ipairs({ "Gift", "Axe", "Vehicle" }) do
        local bucket = groups[kind]
        if #bucket > 0 then
            section(KIND_TITLE[kind], MUTED)
            for _, item in ipairs(bucket) do
                addItem(item)
            end
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
