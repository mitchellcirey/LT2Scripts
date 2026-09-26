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

local USERS = { "Ivan7274929", "digital_marine" }
local DIR = "LT2Scripts"
local CACHE_FILE = DIR .. "/purchasables.json"
local DB_FILE = DIR .. "/catalog.json"
local PAGE_FILE = DIR .. "/catalog.html"
local HUD_NAME = "JellCatalogHud"

local GREEN = Color3.fromRGB(70, 190, 105)
local TEXT = Color3.fromRGB(230, 230, 230)
local MUTED = Color3.fromRGB(150, 150, 150)
local KIND_ORDER = { Gift = 1, Axe = 2, Vehicle = 3 }

-- Public listing estimates from 2026. Numbers already saved in catalog.json stay as they are.
local OFFER = {
    BasicHatchet = { open = { 10, 10 } },
    Axe1 = { open = { 15, 15 } },
    Axe3 = { open = { 40, 40 } },
    SilverAxe = { open = { 450, 450 } },
    Rukiryaxe = { open = { 2000, 4000 } },
    EndTimesAxe = { open = { 6500, 7000 }, box = { 22000, 22000 } },
    FireAxe = { open = { 5000, 7000 }, box = { 23000, 23000 } },
    AxeBetaTesters = { open = { 7000, 15000 }, box = { 19000, 19000 } },
    AxeAlphaTesters = { open = { 20000, 27000 } },
    CandyCornAxe = { open = { 8000, 8000 } },
    GingerbreadAxe = { open = { 10000, 10000 } },
    AxeAmber = { open = { 18000, 18000 } },
    AxeChicken = { open = { 3000, 3000 }, box = { 10000, 10000 } },
    Beesaxe = { open = { 7500, 7500 }, box = { 22000, 22000 } },
    AxeTwitter = { open = { 7000, 7000 } },
    ManyAxe = { open = { 35000, 35000 }, box = { 100000, 100000 } },
}

local started = false
local mounted = false
local loaded = false
local items = {}
local byId = {}
local statusNote = "Idle"
local query = ""
local alerts = {}
local sightings = {}
local childConn
local scanQueued = false
local pendingMore = false
local saveQueued = false
local root
local listFrame
local statusLabel
local searchBox
local hudGui

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
    return {
        Ivan7274929 = { box = false, open = false },
        digital_marine = { box = false, open = false },
    }
end

local function applyOffer(item)
    local preset = OFFER[item.id]
    if not preset then
        return false
    end
    if type(item.offer) ~= "table" or item.offer[1] ~= nil then
        item.offer = {}
    end
    local changed = false
    for form, range in pairs(preset) do
        if item.offer[form] == nil then
            item.offer[form] = { range[1], range[2] }
            changed = true
        end
    end
    return changed
end

local function normalize(item)
    if type(item.seen) ~= "table" or item.seen[1] ~= nil then
        item.seen = blankSeen()
    end
    for _, user in ipairs(USERS) do
        local slot = item.seen[user]
        if type(slot) ~= "table" or slot[1] ~= nil then
            slot = { box = false, open = false }
            item.seen[user] = slot
        end
        slot.box = slot.box == true
        slot.open = slot.open == true
    end
    if type(item.offer) ~= "table" or item.offer[1] ~= nil then
        item.offer = nil
    end
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
        local shop = type(item.shop) == "number" and money(item.shop) or ""
        local openUsed = item.kind ~= "Gift"
        local ivan = item.seen.Ivan7274929 or {}
        local marine = item.seen.digital_marine or {}
        local blob = string.lower(tostring(item.name) .. " " .. tostring(item.id) .. " " .. tostring(item.kind))
        table.insert(rows, table.concat({
            '<tr data-name="', htmlEscape(blob), '">',
            "<td>", htmlEscape(item.name), "</td>",
            "<td>", htmlEscape(item.kind), "</td>",
            "<td>", htmlEscape(shop), "</td>",
            "<td>", htmlEscape(boxOffer), "</td>",
            "<td>", htmlEscape(openOffer), "</td>",
            "<td>", checkCell(ivan.box, true), "</td>",
            "<td>", checkCell(ivan.open, openUsed), "</td>",
            "<td>", checkCell(marine.box, true), "</td>",
            "<td>", checkCell(marine.open, openUsed), "</td>",
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
        "<p>Offer figures are public listing estimates from 2026. Shop is the in-game price. Edit offer in ",
        htmlEscape(DB_FILE), ".</p>",
        "<label>Search<input id=\"q\"></label>",
        "<table><thead><tr>",
        "<th>Item</th><th>Kind</th><th>Shop</th><th>Box offer</th><th>Open offer</th>",
        "<th>Ivan box</th><th>Ivan open</th><th>Marine box</th><th>Marine open</th>",
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
    applyOffer(item)
    if item.offer and next(item.offer) == nil then
        item.offer = nil
    end
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
            if applyOffer(item) then
                dirty = true
            end
        end
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

local function priceFor(item, form)
    local estimate = fullRange(item.offer and item.offer[form])
    if estimate then
        return estimate
    end
    if type(item.shop) == "number" then
        return "Shop " .. money(item.shop)
    end
    return ""
end

local function formWord(item, form)
    if item.kind == "Gift" then
        return "gift"
    end
    if form == "open" then
        return "open"
    end
    return "box"
end

local function hudParents()
    local list = {}
    local ok, hui = pcall(gethui)
    if ok and hui then
        table.insert(list, hui)
    end
    local coreOk, core = pcall(function()
        return Services.CoreGui
    end)
    if coreOk and core then
        table.insert(list, core)
    end
    local playerGui = Player:FindFirstChild("PlayerGui")
    if playerGui then
        table.insert(list, playerGui)
    end
    return list
end

local function refreshHud()
    if not started then
        if hudGui then
            hudGui.Enabled = false
        end
        return
    end
    if not hudGui or not hudGui.Parent then
        for _, parent in ipairs(hudParents()) do
            local existing = parent:FindFirstChild(HUD_NAME)
            if existing then
                existing:Destroy()
            end
        end
        local parent = hudParents()[1]
        if not parent then
            parent = Player:WaitForChild("PlayerGui")
        end
        hudGui = make("ScreenGui", {
            Name = HUD_NAME,
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            DisplayOrder = 1000,
        }, parent)
        local panel = make("Frame", {
            Name = "Panel",
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -12, 0, 12),
            Size = UDim2.fromOffset(320, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = Color3.fromRGB(18, 18, 18),
            BackgroundTransparency = 0.08,
            BorderSizePixel = 0,
        }, hudGui)
        make("UIPadding", {
            PaddingTop = UDim.new(0, 8),
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
        }, panel)
        make("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            Padding = UDim.new(0, 2),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, panel)
        make("TextLabel", {
            Name = "Title",
            Size = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
            Font = Enum.Font.SourceSans,
            Text = "Missing",
            TextSize = 15,
            TextColor3 = TEXT,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 0,
        }, panel)
    end
    local panel = hudGui:FindFirstChild("Panel")
    if not panel then
        return
    end
    for _, child in ipairs(panel:GetChildren()) do
        if child.Name == "Line" then
            child:Destroy()
        end
    end
    hudGui.Enabled = #alerts > 0
    local shown = math.min(#alerts, 8)
    for index = 1, shown do
        make("TextLabel", {
            Name = "Line",
            Size = UDim2.new(1, 0, 0, 16),
            BackgroundTransparency = 1,
            Font = Enum.Font.SourceSans,
            Text = alerts[index],
            TextSize = 14,
            TextColor3 = TEXT,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            LayoutOrder = index,
        }, panel)
    end
    if #alerts > shown then
        make("TextLabel", {
            Name = "Line",
            Size = UDim2.new(1, 0, 0, 16),
            BackgroundTransparency = 1,
            Font = Enum.Font.SourceSans,
            Text = "+" .. tostring(#alerts - shown),
            TextSize = 14,
            TextColor3 = MUTED,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = shown + 1,
        }, panel)
    end
end

local function remember(owner, item, form)
    local key = string.lower(owner) .. "\0" .. item.id .. "\0" .. form
    sightings[key] = { owner = owner, id = item.id, form = form }
end

local function alertRank(item, form)
    local range = item.offer and item.offer[form]
    if type(range) == "table" and type(range[2]) == "number" then
        return range[2]
    end
    if type(range) == "table" and type(range[1]) == "number" then
        return range[1]
    end
    if type(item.shop) == "number" then
        return item.shop
    end
    return 0
end

local function rebuildAlerts()
    local lines = {}
    for _, hit in pairs(sightings) do
        local item = byId[hit.id]
        if item and not weHave(item, hit.form) then
            local price = priceFor(item, hit.form)
            local line = hit.owner .. " · " .. item.name .. " " .. formWord(item, hit.form)
            if price ~= "" then
                line = line .. " · " .. price
            end
            table.insert(lines, { rank = alertRank(item, hit.form), text = line })
        end
    end
    table.sort(lines, function(a, b)
        if a.rank ~= b.rank then
            return a.rank > b.rank
        end
        return a.text < b.text
    end)
    alerts = {}
    for _, line in ipairs(lines) do
        table.insert(alerts, line.text)
    end
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
    for _, model in ipairs(folder:GetChildren()) do
        local owner, item, form = readModel(model)
        if owner and item and form and not canonicalUser(owner) then
            remember(owner, item, form)
        end
    end
    local previous = table.concat(alerts, "\n")
    rebuildAlerts()
    if save then
        queueSave()
        if refreshUi then
            refreshUi()
        end
    end
    if table.concat(alerts, "\n") ~= previous then
        refreshHud()
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
        return "Shop " .. money(item.shop), false
    end
    return "", false
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

local function addMark(parent, x, on, used)
    local text = ""
    local color = MUTED
    if used then
        text = on and "✓" or "–"
        color = on and GREEN or MUTED
    end
    make("TextLabel", {
        Size = UDim2.fromOffset(16, 22),
        Position = UDim2.fromOffset(x, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = text,
        TextSize = 16,
        TextColor3 = color,
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
    local order = 0
    for _, item in ipairs(items) do
        local blob = string.lower(item.name .. " " .. item.id)
        if needle == "" or string.find(blob, needle, 1, true) then
            order += 1
            local row = make("Frame", {
                Size = UDim2.new(1, 0, 0, 22),
                BackgroundTransparency = 1,
                LayoutOrder = order,
            }, listFrame)
            make("TextLabel", {
                Size = UDim2.new(1, -274, 1, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.SourceSans,
                Text = item.name,
                TextSize = 15,
                TextColor3 = TEXT,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
            }, row)
            local ivan = item.seen.Ivan7274929 or {}
            local marine = item.seen.digital_marine or {}
            local openUsed = item.kind ~= "Gift"
            local ivanFrame = make("Frame", {
                Size = UDim2.fromOffset(78, 22),
                Position = UDim2.new(1, -274, 0, 0),
                BackgroundTransparency = 1,
            }, row)
            addMark(ivanFrame, 8, ivan.box, true)
            addMark(ivanFrame, 28, ivan.open, openUsed)
            local marineFrame = make("Frame", {
                Size = UDim2.fromOffset(78, 22),
                Position = UDim2.new(1, -196, 0, 0),
                BackgroundTransparency = 1,
            }, row)
            addMark(marineFrame, 8, marine.box, true)
            addMark(marineFrame, 28, marine.open, openUsed)
            local price, estimated = cellPrice(item)
            make("TextLabel", {
                Size = UDim2.fromOffset(112, 22),
                Position = UDim2.new(1, -112, 0, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.SourceSans,
                Text = price,
                TextSize = 13,
                TextColor3 = estimated and TEXT or MUTED,
                TextXAlignment = Enum.TextXAlignment.Right,
                TextTruncate = Enum.TextTruncate.AtEnd,
            }, row)
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
        Size = UDim2.new(1, -16, 0, 32),
        Position = UDim2.fromOffset(8, 36),
        BackgroundTransparency = 1,
    }, root)
    make("TextLabel", {
        Size = UDim2.new(1, -274, 0, 16),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = "Item",
        TextSize = 13,
        TextColor3 = MUTED,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, header)

    local function playerHeader(user, x)
        local frame = make("Frame", {
            Size = UDim2.fromOffset(78, 32),
            Position = UDim2.new(1, x, 0, 0),
            BackgroundTransparency = 1,
        }, header)
        make("TextLabel", {
            Size = UDim2.new(1, 0, 0, 14),
            BackgroundTransparency = 1,
            Font = Enum.Font.SourceSans,
            Text = user,
            TextSize = 12,
            TextColor3 = MUTED,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
        }, frame)
        make("TextLabel", {
            Size = UDim2.fromOffset(16, 14),
            Position = UDim2.fromOffset(8, 14),
            BackgroundTransparency = 1,
            Font = Enum.Font.SourceSans,
            Text = "B",
            TextSize = 12,
            TextColor3 = MUTED,
        }, frame)
        make("TextLabel", {
            Size = UDim2.fromOffset(16, 14),
            Position = UDim2.fromOffset(28, 14),
            BackgroundTransparency = 1,
            Font = Enum.Font.SourceSans,
            Text = "O",
            TextSize = 12,
            TextColor3 = MUTED,
        }, frame)
    end

    playerHeader(USERS[1], -274)
    playerHeader(USERS[2], -196)
    make("TextLabel", {
        Size = UDim2.fromOffset(112, 16),
        Position = UDim2.new(1, -112, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = "Price",
        TextSize = 13,
        TextColor3 = MUTED,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, header)

    listFrame = make("ScrollingFrame", {
        Size = UDim2.new(1, -16, 1, -92),
        Position = UDim2.fromOffset(8, 70),
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
        Padding = UDim.new(0, 1),
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
        refreshUi()
        refreshHud()
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
    alerts = {}
    sightings = {}
    if hudGui then
        hudGui:Destroy()
        hudGui = nil
    end
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
