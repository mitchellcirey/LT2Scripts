local Services = setmetatable({}, {
    __index = function(self, index)
        return game:GetService(index)
    end,
})

local Players           = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local Workspace         = Services.Workspace
local RunService        = Services.RunService
local UserInputService  = Services.UserInputService

local Player            = Players.LocalPlayer
local ClientIsDragging  = ReplicatedStorage:WaitForChild("Interaction"):WaitForChild("ClientIsDragging")

local MAX_STUDS = 10
local APPROACH_STUDS = 4
local APPROACH_WAIT = 0.2
local HOLD_BEFORE_RELEASE = 0.12
local POST_OBJECT_DELAY = 0.04
local FALLBACK_WAIT = 0.35
local PILE_OWNERSHIP_TIMEOUT = 0.55
local PILE_FALLBACK_WAIT = 0.25
local PILE_POST_DELAY = 0.04
local AMOUNT_MAX = 50
local AUTO_PAUSE = 0.4
local GUI_NAME = "LT2DuperUI"
local PLOT_INSET = 3
local PLOT_MIN = 25
local PLOT_MAX = 2000
local LOG_GAP = 2
local MIN_LOG_SPACING = 6

local function item(id, label, keys, rare)
    return {
        id = id,
        label = label,
        keys = keys or { id },
        rare = rare == true,
    }
end

local CATALOG = {
    {
        id = "logs",
        name = "Logs",
        groups = {
            {
                name = "Common",
                items = {
                    item("Generic", "Generic"),
                    item("Oak", "Oak"),
                    item("Cherry", "Cherry"),
                    item("Elm", "Elm"),
                    item("Birch", "Birch"),
                    item("Walnut", "Walnut"),
                    item("Koa", "Koa"),
                    item("Pine", "Pine"),
                    item("Fir", "Fir"),
                    item("Palm", "Palm"),
                },
            },
            {
                name = "Rare woods",
                items = {
                    item("LoneCave", "Lone Cave", nil, true),
                    item("CaveCrawler", "Cave Crawler", nil, true),
                    item("Gold", "Gold", nil, true),
                    item("Phantom", "Phantom", nil, true),
                    item("Frost", "Frost", nil, true),
                    item("Snowglow", "Snowglow", nil, true),
                    item("Volcano", "Volcano / Lava", { "Volcano", "Lava" }, true),
                },
            },
            {
                name = "Event woods",
                items = {
                    item("Spooky", "Spooky"),
                    item("SpookyNeon", "Spooky Neon", nil, true),
                    item("Sinister", "Sinister", nil, true),
                    item("Zombie", "Zombie"),
                    item("BlueSpruce", "Blue Spruce"),
                },
            },
        },
    },
    {
        id = "axes",
        name = "Axes",
        groups = {
            {
                name = "Shop",
                items = {
                    item("BasicHatchet", "Basic Hatchet"),
                    item("PlainAxe", "Plain Axe", { "Axe1", "PlainAxe" }),
                    item("SteelAxe", "Steel Axe", { "Axe2", "SteelAxe" }),
                    item("HardenedAxe", "Hardened Axe", { "Axe3", "HardenedAxe" }),
                    item("SilverAxe", "Silver Axe"),
                    item("Rukiryaxe", "Rukiryaxe"),
                    item("BluesteelAxe", "Bluesteel Axe"),
                },
            },
            {
                name = "Limited",
                items = {
                    item("ManyAxe", "Many Axe", nil, true),
                    item("EndTimesAxe", "End Times Axe", nil, true),
                    item("FireAxe", "Fire Axe", nil, true),
                    item("AxeAlphaTesters", "Alpha Axe", { "AxeAlphaTesters", "AlphaAxe" }, true),
                    item("AxeBetaTesters", "Beta Axe", { "AxeBetaTesters", "BetaAxe" }, true),
                    item("Beesaxe", "Beesaxe", nil, true),
                    item("CandyCaneAxe", "Candy Cane Axe", nil, true),
                    item("AxeChicken", "Chicken Axe", { "AxeChicken", "ChickenAxe" }, true),
                    item("AxeAmber", "Amber Axe", { "AxeAmber", "AmberAxe" }, true),
                    item("GingerbreadAxe", "Gingerbread Axe", nil, true),
                    item("AxeTwitter", "Bird Axe", { "AxeTwitter", "BirdAxe" }, true),
                    item("RustyAxe", "Rusty Axe"),
                    item("CandyCornAxe", "Candy Corn Axe"),
                    item("CaveAxe", "Cave Axe", nil, true),
                    item("OvergrownAxe", "Overgrown Axe", nil, true),
                    item("FrostAxe", "Frost Axe", nil, true),
                    item("PieAxe", "Pie Axe"),
                    item("SpearmintAxe", "Spearmint Axe"),
                    item("RefinedAxe", "Refined Axe", nil, true),
                    item("InverseAxe", "Inverse Axe", nil, true),
                    item("PigAxe", "Pig Axe"),
                    item("GoldAxe", "Gold Axe", nil, true),
                },
            },
        },
    },
    {
        id = "gifts",
        name = "Presents",
        groups = {
            {
                name = "Gifts",
                items = {
                    item("2015CGift_Red", "Happy Red Gift", { "2015CGift_Red" }, true),
                    item("2015CGift_Volcano", "Fiery Gift of Lumber", { "2015CGift_Volcano" }, true),
                    item("2016CGift_Ut", "Wobbly Gift of Uncertainty", { "2016CGift_Ut" }, true),
                    item("2016CGift_Sweet", "Sweet Gift", { "2016CGift_Sweet" }, true),
                    item("2017CGift_Gold", "Golden Gift of Golden Times", { "2017CGift_Gold" }, true),
                    item("2017CGift_Modern", "Modern Gift", { "2017CGift_Modern" }, true),
                    item("2017CGift_GreatTimes", "Gift of Great Times", { "2017CGift_GreatTimes" }, true),
                    item("2017CGift_Green", "Joyful Green Gift", { "2017CGift_Green" }, true),
                    item("2018CGift_Plum", "Plum Gift", { "2018CGift_Plum" }, true),
                    item("2018CGift_GingerAxe", "Gingerbread Axe Gift", { "2018CGift_GingerAxe" }, true),
                    item("2018CGift_Sled", "Sled Gift", { "2018CGift_Sled" }, true),
                    item("2018CGift_Cone", "Cone Gift", { "2018CGift_Cone" }, true),
                    item("2018CGift_Duck", "Duck Gift", { "2018CGift_Duck" }, true),
                    item("2018CGift_Candy", "Candy Gift", { "2018CGift_Candy" }, true),
                    item("2018CGift_CoCoa", "Cocoa Gift", { "2018CGift_CoCoa" }, true),
                    item("2018CGift_Plate", "Plate Gift", { "2018CGift_Plate" }, true),
                    item("2018CGift_Snow", "Snow Gift", { "2018CGift_Snow" }, true),
                    item("2019CGift_Yellow", "Yellow Gift", { "2019CGift_Yellow" }, true),
                },
            },
        },
    },
    {
        id = "paintings",
        name = "Paintings",
        groups = {
            {
                name = "Fine Arts",
                items = {
                    item("TitleUnknown", "Title Unknown", { "TitleUnknown", "Title Unknown" }),
                    item("DisturbedPainting", "Disturbed Painting", { "DisturbedPainting", "Disturbed Painting" }),
                    item("OutdoorWatercolorSketch", "Outdoor Watercolor Sketch", { "OutdoorWatercolorSketch", "Outdoor Watercolor Sketch" }),
                    item("ArcticLight", "Arctic Light", { "ArcticLight", "Arctic Light" }, true),
                    item("GloomySeascape", "Gloomy Seascape", { "GloomySeascape", "Gloomy Seascape at Dusk" }, true),
                    item("LonelyGiraffe", "The Lonely Giraffe", { "LonelyGiraffe", "The Lonely Giraffe" }, true),
                    item("Pineapple", "Pineapple", { "Pineapple" }, true),
                    item("BoldAndBrash", "Bold and Brash", { "BoldAndBrash", "Bold and Brash" }, true),
                    item("BurntPainting", "Burnt Painting", { "BurntPainting", "Burnt Painting" }, true),
                    item("PixelatedPainting", "Pixelated Painting", { "PixelatedPainting", "Pixelated Painting", "Gift of Pixelation" }, true),
                },
            },
        },
    },
}

local selected = {}
local keyIndex = {}
local allItems = {}
local rareItems = {}

local KIND_LABELS = {
    logs = "Log",
    axes = "Axe",
    gifts = "Present",
    paintings = "Painting",
}

local function boxedKind(kind)
    if not kind then
        return "Boxed"
    end
    return "Boxed " .. kind
end

local function displayLabel(entry)
    if entry.kind then
        return entry.label .. " (" .. entry.kind .. ")"
    end
    return entry.label
end

local function indexItem(entry)
    if selected[entry.id] == nil then
        selected[entry.id] = false
    end
    table.insert(allItems, entry)
    if entry.rare then
        table.insert(rareItems, entry)
    end
    for _, key in ipairs(entry.keys) do
        keyIndex[entry.form .. ":" .. key] = entry
        keyIndex[entry.form .. ":" .. string.lower(key)] = entry
    end
end

for _, category in ipairs(CATALOG) do
    local kind = KIND_LABELS[category.id]
    if category.id == "logs" then
        for _, group in ipairs(category.groups) do
            for _, entry in ipairs(group.items) do
                entry.kind = kind
                entry.form = "log"
                indexItem(entry)
            end
        end
    else
        for _, group in ipairs(category.groups) do
            local expanded = {}
            for _, entry in ipairs(group.items) do
                local opened = {
                    id = entry.id .. "_opened",
                    label = entry.label,
                    keys = entry.keys,
                    rare = entry.rare,
                    kind = kind,
                    form = "opened",
                }
                local boxed = {
                    id = entry.id .. "_boxed",
                    label = entry.label,
                    keys = entry.keys,
                    rare = entry.rare,
                    kind = boxedKind(kind),
                    form = "boxed",
                }
                table.insert(expanded, opened)
                table.insert(expanded, boxed)
                indexItem(opened)
                indexItem(boxed)
            end
            group.items = expanded
        end
    end
end

local function lookupEntry(raw)
    raw = tostring(raw)
    return keyIndex["opened:" .. raw]
        or keyIndex["boxed:" .. raw]
        or keyIndex["log:" .. raw]
        or keyIndex["opened:" .. string.lower(raw)]
        or keyIndex["boxed:" .. string.lower(raw)]
        or keyIndex["log:" .. string.lower(raw)]
end

local function prettyName(raw)
    local known = lookupEntry(raw)
    if known then
        return known.label
    end
    return (tostring(raw):gsub("(%l)(%u)", "%1 %2"):gsub("_", " "))
end

local function addDiscovered(categoryId, groupName, rawId, form)
    if categoryId == "logs" then
        form = "log"
    elseif form ~= "boxed" and form ~= "opened" then
        form = "opened"
    end

    if keyIndex[form .. ":" .. rawId] or keyIndex[form .. ":" .. string.lower(rawId)] then
        return
    end

    local category
    for _, cat in ipairs(CATALOG) do
        if cat.id == categoryId then
            category = cat
            break
        end
    end
    if not category then
        return
    end

    local group
    for _, g in ipairs(category.groups) do
        if g.name == groupName then
            group = g
            break
        end
    end
    if not group then
        group = { name = groupName, items = {} }
        table.insert(category.groups, group)
    end

    local kind = KIND_LABELS[categoryId]
    local entryId = rawId
    if form == "boxed" then
        entryId = rawId .. "_boxed"
        kind = boxedKind(kind)
    elseif form == "opened" then
        entryId = rawId .. "_opened"
    end

    local entry = item(rawId, prettyName(rawId), { rawId })
    entry.id = entryId
    entry.kind = kind
    entry.form = form
    table.insert(group.items, entry)
    indexItem(entry)
end

local function looksLikeGift(name)
    name = string.lower(name)
    return string.find(name, "gift", 1, true) ~= nil
        or string.find(name, "present", 1, true) ~= nil
        or string.find(name, "cgift", 1, true) ~= nil
end

local function looksLikePainting(name)
    name = string.lower(name)
    return string.find(name, "paint", 1, true) ~= nil
        or string.find(name, "portrait", 1, true) ~= nil
end

local function looksLikeAxe(name)
    name = string.lower(name)
    return string.find(name, "axe", 1, true) ~= nil
        or string.find(name, "hatchet", 1, true) ~= nil
end

do
    local purchasables = ReplicatedStorage:FindFirstChild("Purchasables")
    local tools = purchasables and purchasables:FindFirstChild("Tools")
    local allTools = tools and (tools:FindFirstChild("AllTools") or tools)
    if allTools then
        for _, child in ipairs(allTools:GetChildren()) do
            if looksLikeAxe(child.Name) then
                addDiscovered("axes", "Limited", child.Name, "opened")
                addDiscovered("axes", "Limited", child.Name, "boxed")
            end
        end
    end
end

if Workspace:FindFirstChild("PlayerModels") then
    for _, v in ipairs(Workspace.PlayerModels:GetChildren()) do
        local owner = v:FindFirstChild("Owner")
        if owner and owner.Value == Player then
            local tree = v:FindFirstChild("TreeClass")
            local box = v:FindFirstChild("PurchasedBoxItemName")
            local tool = v:FindFirstChild("ToolName")
            if tree then
                addDiscovered("logs", "On your plot", tree.Value, "log")
            elseif box then
                local name = box.Value
                if looksLikeGift(name) then
                    addDiscovered("gifts", "On your plot", name, "boxed")
                elseif looksLikePainting(name) then
                    addDiscovered("paintings", "On your plot", name, "boxed")
                elseif looksLikeAxe(name) then
                    addDiscovered("axes", "On your plot", name, "boxed")
                end
            elseif tool then
                addDiscovered("axes", "On your plot", tool.Value, "opened")
            end
        end
    end
end

local root
local busy = false
local auto = false
local abort = false
local autoToken = 0
local setStatus
local logLimit = nil
local cycleDone = {}
local pilePlanks = false
local plotTarget = { name = nil }
local currentCategoryId = "logs"
local rebuildList
local searchQuery = ""
local screenGui

local function isStopped()
    return abort or not (screenGui and screenGui.Parent)
end

local function flatten(v)
    local flat = Vector3.new(v.X, 0, v.Z)
    if flat.Magnitude < 0.05 then
        return Vector3.new(0, 0, -1)
    end
    return flat.Unit
end

local function isLandPart(part)
    if not (part and part:IsA("BasePart")) then
        return false
    end
    if part.Size.Y > 48 then
        return false
    end
    local mn = math.min(part.Size.X, part.Size.Z)
    local mx = math.max(part.Size.X, part.Size.Z)
    return mn >= PLOT_MIN and mx <= PLOT_MAX
end

local function colorClose(a, b)
    local dr, dg, db = a.R - b.R, a.G - b.G, a.B - b.B
    return (dr * dr + dg * dg + db * db) < 0.04
end

local function looksLikeGrass(part)
    if not part:IsA("BasePart") then
        return false
    end
    if part.Material == Enum.Material.Grass then
        return true
    end
    local c = part.Color
    return c.G > c.R + 0.07 and c.G > c.B + 0.05
end

local function samePlotSurface(seed, part)
    if not (seed and part and part:IsA("BasePart")) then
        return false
    end
    if part == seed then
        return true
    end
    if not isLandPart(part) then
        return false
    end
    if looksLikeGrass(part) and not looksLikeGrass(seed) then
        return false
    end
    if seed.Material ~= part.Material and not colorClose(seed.Color, part.Color) then
        return false
    end
    return colorClose(seed.Color, part.Color)
end

local function partAabbXZ(part)
    local cf = part.CFrame
    local sx, sz = part.Size.X * 0.5, part.Size.Z * 0.5
    local minX, maxX = math.huge, -math.huge
    local minZ, maxZ = math.huge, -math.huge
    for _, ox in ipairs({ -sx, sx }) do
        for _, oz in ipairs({ -sz, sz }) do
            local w = cf:PointToWorldSpace(Vector3.new(ox, 0, oz))
            minX = math.min(minX, w.X)
            maxX = math.max(maxX, w.X)
            minZ = math.min(minZ, w.Z)
            maxZ = math.max(maxZ, w.Z)
        end
    end
    return minX, maxX, minZ, maxZ
end

local function aabbTouches(aMinX, aMaxX, aMinZ, aMaxZ, bMinX, bMaxX, bMinZ, bMaxZ, slop)
    return aMinX <= bMaxX + slop
        and aMaxX >= bMinX - slop
        and aMinZ <= bMaxZ + slop
        and aMaxZ >= bMinZ - slop
end

local function plotFromParts(parts, fromPos)
    if not parts or #parts == 0 then
        return nil
    end
    local minX, maxX = math.huge, -math.huge
    local minZ, maxZ = math.huge, -math.huge
    for _, part in ipairs(parts) do
        local x0, x1, z0, z1 = partAabbXZ(part)
        minX = math.min(minX, x0)
        maxX = math.max(maxX, x1)
        minZ = math.min(minZ, z0)
        maxZ = math.max(maxZ, z1)
    end
    return {
        cf = CFrame.new((minX + maxX) * 0.5, fromPos.Y, (minZ + maxZ) * 0.5),
        size = Vector3.new(math.max(1, maxX - minX), 20, math.max(1, maxZ - minZ)),
        part = parts[1],
        parts = parts,
        seed = parts[1],
    }
end

local function asPlot(part, fromPos)
    return plotFromParts({ part }, fromPos or part.Position)
end

local function partContainsXZ(part, pos, inset)
    inset = inset or 0
    local lp = part.CFrame:PointToObjectSpace(pos)
    local hx = math.max(0, part.Size.X * 0.5 - inset)
    local hz = math.max(0, part.Size.Z * 0.5 - inset)
    return math.abs(lp.X) <= hx and math.abs(lp.Z) <= hz
end

local function collectLandCandidates(seed)
    local seedY = seed.Position.Y
    local candidates = {}
    local seen = {}
    local playerModels = Workspace:FindFirstChild("PlayerModels")

    local function take(part)
        if part and part:IsA("BasePart") and not seen[part] and samePlotSurface(seed, part) then
            if math.abs(part.Position.Y - seedY) <= 24 then
                seen[part] = true
                table.insert(candidates, part)
            end
        end
    end

    local function addContainer(container, descendants)
        if not container then
            return
        end
        if container:IsA("BasePart") then
            take(container)
        end
        if descendants then
            for _, p in ipairs(container:GetDescendants()) do
                if p:IsA("BasePart") then
                    take(p)
                end
            end
        else
            for _, child in ipairs(container:GetChildren()) do
                if child:IsA("BasePart") then
                    take(child)
                end
            end
        end
    end

    take(seed)
    if seed.Parent and seed.Parent ~= Workspace then
        addContainer(seed.Parent, true)
    end
    addContainer(Workspace, false)

    for _, child in ipairs(Workspace:GetChildren()) do
        if child ~= playerModels then
            local owner = child:FindFirstChild("Owner")
            if owner and owner:IsA("ObjectValue") and owner.Value == Player then
                addContainer(child, true)
            end
        end
    end

    return candidates
end

local function connectedLandParts(seed)
    if not (seed and seed:IsA("BasePart")) then
        return {}
    end

    local cluster = { seed }
    local seen = { [seed] = true }
    local minX, maxX, minZ, maxZ = partAabbXZ(seed)
    local y = seed.Position.Y

    local overlapOk, nearby = pcall(function()
        local params = OverlapParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        local ignore = {}
        if Player.Character then
            table.insert(ignore, Player.Character)
        end
        local playerModels = Workspace:FindFirstChild("PlayerModels")
        if playerModels then
            table.insert(ignore, playerModels)
        end
        params.FilterDescendantsInstances = ignore
        local size = Vector3.new(math.max(40, maxX - minX) + 80, 40, math.max(40, maxZ - minZ) + 80)
        return Workspace:GetPartBoundsInBox(CFrame.new((minX + maxX) * 0.5, y, (minZ + maxZ) * 0.5), size, params)
    end)

    if overlapOk and nearby then
        for _, part in ipairs(nearby) do
            if not seen[part] and samePlotSurface(seed, part) and math.abs(part.Position.Y - y) <= 24 then
                local x0, x1, z0, z1 = partAabbXZ(part)
                if aabbTouches(minX, maxX, minZ, maxZ, x0, x1, z0, z1, 20) then
                    seen[part] = true
                    table.insert(cluster, part)
                    minX, maxX = math.min(minX, x0), math.max(maxX, x1)
                    minZ, maxZ = math.min(minZ, z0), math.max(maxZ, z1)
                    if #cluster >= 32 then
                        break
                    end
                end
            end
        end
        if #cluster > 1 then
            return cluster
        end
    end

    local candidates = collectLandCandidates(seed)
    local aabbs = {}
    for _, part in ipairs(candidates) do
        local x0, x1, z0, z1 = partAabbXZ(part)
        aabbs[part] = { x0, x1, z0, z1 }
    end

    local stack = { seed }
    cluster = {}
    seen = { [seed] = true }
    while #stack > 0 and #cluster < 32 do
        local cur = table.remove(stack)
        table.insert(cluster, cur)
        local a = aabbs[cur]
        if a then
            for _, other in ipairs(candidates) do
                if not seen[other] then
                    local b = aabbs[other]
                    if b and aabbTouches(a[1], a[2], a[3], a[4], b[1], b[2], b[3], b[4], 16) then
                        seen[other] = true
                        table.insert(stack, other)
                    end
                end
            end
        end
    end
    return cluster
end

local function considerPlotPart(part, fromPos, best, bestArea)
    if not isLandPart(part) or not partContainsXZ(part, fromPos, -8) then
        return best, bestArea
    end
    local area = part.Size.X * part.Size.Z
    if not best or area > bestArea then
        return part, area
    end
    return best, bestArea
end

local function plotFromModel(model, fromPos)
    if not model then
        return nil
    end
    local parts = {}
    local function take(part)
        if isLandPart(part) then
            table.insert(parts, part)
        end
    end
    if model:IsA("BasePart") then
        take(model)
    end
    for _, p in ipairs(model:GetDescendants()) do
        if p:IsA("BasePart") then
            take(p)
        end
    end
    if #parts > 0 then
        local origin = fromPos
        if not origin then
            origin = parts[1].Position
        end
        return plotFromParts(parts, origin)
    end
    if model:IsA("Model") then
        local cf, size = model:GetBoundingBox()
        if math.min(size.X, size.Z) >= 40 and math.max(size.X, size.Z) <= PLOT_MAX then
            return { cf = cf, size = size, part = model }
        end
    end
    return nil
end

local function raycastFloor(fromPos)
    local ignore = {}
    if Player.Character then
        table.insert(ignore, Player.Character)
    end
    local playerModels = Workspace:FindFirstChild("PlayerModels")
    if playerModels then
        table.insert(ignore, playerModels)
    end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = ignore
    return Workspace:Raycast(fromPos + Vector3.new(0, 8, 0), Vector3.new(0, -200, 0), params)
end

local function plotFromOwnedItems(fromPos)
    local models = Workspace:FindFirstChild("PlayerModels")
    if not models then
        return nil
    end

    local minX, maxX = fromPos.X, fromPos.X
    local minZ, maxZ = fromPos.Z, fromPos.Z
    local found = false

    for _, v in ipairs(models:GetChildren()) do
        local owner = v:FindFirstChild("Owner")
        if owner and owner.Value == Player then
            local part = v:FindFirstChild("Main") or v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
            if part then
                found = true
                minX = math.min(minX, part.Position.X)
                maxX = math.max(maxX, part.Position.X)
                minZ = math.min(minZ, part.Position.Z)
                maxZ = math.max(maxZ, part.Position.Z)
            end
        end
    end

    if not found then
        return nil
    end

    local pad = 20
    local sizeX = math.clamp(maxX - minX + pad * 2, 50, PLOT_MAX)
    local sizeZ = math.clamp(maxZ - minZ + pad * 2, 50, PLOT_MAX)
    return {
        cf = CFrame.new((minX + maxX) * 0.5, fromPos.Y, (minZ + maxZ) * 0.5),
        size = Vector3.new(sizeX, 20, sizeZ),
    }
end

local function getPlotArea(fromPos)
    local playerModels = Workspace:FindFirstChild("PlayerModels")
    local hit = raycastFloor(fromPos)
    local floor = hit and hit.Instance

    local function expand(seed)
        if not (seed and seed:IsA("BasePart")) then
            return nil
        end
        local cluster = connectedLandParts(seed)
        if #cluster == 0 then
            cluster = { seed }
        end
        return plotFromParts(cluster, fromPos)
    end

    if floor and floor:IsA("BasePart") then
        local expanded = expand(floor)
        if expanded and math.min(expanded.size.X, expanded.size.Z) >= 20 then
            return expanded
        end
    end

    local best
    local bestArea = 0
    local inst = floor
    while inst and inst ~= Workspace do
        if inst:IsA("BasePart") then
            best, bestArea = considerPlotPart(inst, fromPos, best, bestArea)
        end
        inst = inst.Parent
    end
    if best then
        return expand(best) or asPlot(best, fromPos)
    end

    for _, child in ipairs(Workspace:GetChildren()) do
        if child ~= playerModels then
            local owner = child:FindFirstChild("Owner")
            if owner and owner:IsA("ObjectValue") and owner.Value == Player then
                local owned = plotFromModel(child, fromPos)
                if owned then
                    return owned
                end
            end
        end
    end

    best, bestArea = nil, 0
    for _, child in ipairs(Workspace:GetChildren()) do
        if child ~= playerModels and child:IsA("BasePart") then
            best, bestArea = considerPlotPart(child, fromPos, best, bestArea)
        end
    end
    if best then
        return expand(best) or asPlot(best, fromPos)
    end

    local fromItems = plotFromOwnedItems(fromPos)
    if fromItems then
        return fromItems
    end

    if floor and floor:IsA("BasePart") then
        return expand(floor) or asPlot(floor, fromPos)
    end

    return nil
end

local function plotInset(spacing)
    return math.max(6, (spacing or MIN_LOG_SPACING) * 0.5 + 2)
end

local function plotHalf(plot, spacing)
    local inset = plotInset(spacing)
    return math.max(0, plot.size.X * 0.5 - inset), math.max(0, plot.size.Z * 0.5 - inset)
end

local function positionOnPlotParts(pos, plot, spacing)
    if not (plot and plot.parts) then
        return false
    end
    local inset = plotInset(spacing)
    for _, part in ipairs(plot.parts) do
        if partContainsXZ(part, pos, inset) then
            return true
        end
    end
    return false
end

local function insidePlot(pos, plot, spacing)
    if not plot then
        return false
    end
    local inset = plotInset(spacing)

    if plot.parts and #plot.parts > 0 then
        if not positionOnPlotParts(pos, plot, spacing) then
            return false
        end
        local probeY = plot.parts[1].Position.Y + 4
        local hit = raycastFloor(Vector3.new(pos.X, probeY, pos.Z))
        local inst = hit and hit.Instance
        if inst then
            for _, part in ipairs(plot.parts) do
                if inst == part then
                    return true
                end
            end
            if plot.seed and samePlotSurface(plot.seed, inst) then
                return partContainsXZ(inst, pos, inset)
            end
            if plot.seed and looksLikeGrass(inst) and not looksLikeGrass(plot.seed) then
                return false
            end
        end
        return true
    end

    local overPart = false
    if plot.part and plot.part:IsA("BasePart") then
        overPart = partContainsXZ(plot.part, pos, inset)
    else
        local hx, hz = plotHalf(plot, spacing)
        local localPos = plot.cf:PointToObjectSpace(pos)
        overPart = math.abs(localPos.X) <= hx and math.abs(localPos.Z) <= hz
    end
    if not overPart then
        return false
    end

    local hit = raycastFloor(pos)
    local inst = hit and hit.Instance
    if not inst then
        return overPart
    end
    if plot.part and inst == plot.part then
        return true
    end
    if plot.seed and samePlotSurface(plot.seed, inst) then
        return partContainsXZ(inst, pos, inset)
    end
    if plot.seed and looksLikeGrass(inst) and not looksLikeGrass(plot.seed) then
        return false
    end
    return overPart
end

local function clampToPlot(pos, plot, spacing)
    if not plot then
        return pos
    end
    if insidePlot(pos, plot, spacing) then
        return pos
    end
    local hx, hz = plotHalf(plot, spacing)
    local localPos = plot.cf:PointToObjectSpace(pos)
    local clamped = Vector3.new(
        math.clamp(localPos.X, -hx, hx),
        localPos.Y,
        math.clamp(localPos.Z, -hz, hz)
    )
    local world = plot.cf:PointToWorldSpace(clamped)
    return Vector3.new(world.X, pos.Y, world.Z)
end

local function snapOntoPlot(pos, plot, spacing)
    if insidePlot(pos, plot, spacing) then
        return pos
    end

    local clamped = clampToPlot(pos, plot, spacing)
    if insidePlot(clamped, plot, spacing) then
        return clamped
    end

    if plot and plot.parts then
        local inset = plotInset(spacing)
        local best, bestDist
        for _, part in ipairs(plot.parts) do
            if part and part.Parent then
                local lp = part.CFrame:PointToObjectSpace(pos)
                local hx = math.max(0, part.Size.X * 0.5 - inset)
                local hz = math.max(0, part.Size.Z * 0.5 - inset)
                local localClamped = Vector3.new(math.clamp(lp.X, -hx, hx), 0, math.clamp(lp.Z, -hz, hz))
                local world = part.CFrame:PointToWorldSpace(localClamped)
                local candidate = Vector3.new(world.X, pos.Y, world.Z)
                local dist = (Vector3.new(candidate.X, 0, candidate.Z) - Vector3.new(pos.X, 0, pos.Z)).Magnitude
                if not best or dist < bestDist then
                    best = candidate
                    bestDist = dist
                end
            end
        end
        if best then
            return best
        end
    end

    return clamped
end

local function standingFootprint(part)
    local dims = { part.Size.X, part.Size.Y, part.Size.Z }
    table.sort(dims)
    return math.max(dims[1], dims[2])
end

local function dragTarget(model)
    return model:FindFirstChild("Main")
        or model:FindFirstChild("WoodSection")
        or model:FindFirstChildWhichIsA("BasePart")
        or model:FindFirstChildWhichIsA("BasePart", true)
end

local function logSpacingFor(models)
    local spacing = MIN_LOG_SPACING
    for _, model in ipairs(models) do
        local target = dragTarget(model)
        if target then
            spacing = math.max(spacing, standingFootprint(target) + LOG_GAP)
        end
    end
    return spacing
end

local function buildLogSlots(pressedCF, count, plot, spacing)
    local slots = {}
    if count <= 0 then
        return slots
    end
    spacing = math.max(spacing or MIN_LOG_SPACING, MIN_LOG_SPACING)
    if not plot then
        return slots
    end

    local hx, hz = plotHalf(plot, spacing)
    local nCol = math.max(1, math.floor((2 * hx) / spacing) + 1)
    local nRow = math.max(1, math.floor((2 * hz) / spacing) + 1)
    nCol = math.min(nCol, 60)
    nRow = math.min(nRow, 60)
    while nCol > 1 and ((nCol - 1) * spacing) * 0.5 > hx + 0.01 do
        nCol -= 1
    end
    while nRow > 1 and ((nRow - 1) * spacing) * 0.5 > hz + 0.01 do
        nRow -= 1
    end

    local x0 = -((nCol - 1) * spacing) * 0.5
    local z0 = -((nRow - 1) * spacing) * 0.5
    local candidates = {}
    for col = 0, nCol - 1 do
        for row = 0, nRow - 1 do
            local localPos = Vector3.new(x0 + col * spacing, 0, z0 + row * spacing)
            local world = plot.cf:PointToWorldSpace(localPos)
            local pos = Vector3.new(world.X, pressedCF.Position.Y, world.Z)
            if insidePlot(pos, plot, spacing) then
                table.insert(candidates, pos)
            end
        end
    end

    local px, pz = pressedCF.Position.X, pressedCF.Position.Z
    table.sort(candidates, function(a, b)
        local da = (a.X - px) * (a.X - px) + (a.Z - pz) * (a.Z - pz)
        local db = (b.X - px) * (b.X - px) + (b.Z - pz) * (b.Z - pz)
        return da < db
    end)

    for _, pos in ipairs(candidates) do
        table.insert(slots, pos)
        if #slots >= count then
            break
        end
    end

    return slots
end

local function fallbackDest(pressedCF, plot)
    if plot and plot.cf then
        return Vector3.new(plot.cf.Position.X, pressedCF.Position.Y, plot.cf.Position.Z)
    end
    return (pressedCF * CFrame.new(0, 0, 4)).Position
end

local activePlot
local activeSpacing = MIN_LOG_SPACING

local function settleModel(model)
    for _, inst in ipairs(model:GetDescendants()) do
        if inst:IsA("BasePart") then
            inst.AssemblyLinearVelocity = Vector3.zero
            inst.AssemblyAngularVelocity = Vector3.zero
            pcall(function()
                inst.Velocity = Vector3.zero
                inst.RotVelocity = Vector3.zero
            end)
        end
    end
end

local function groundYAt(pos, ignore)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = ignore
    local hit = Workspace:Raycast(Vector3.new(pos.X, pos.Y + 50, pos.Z), Vector3.new(0, -120, 0), params)
    if hit then
        return hit.Position.Y
    end
    return pos.Y
end

local function placeLogStanding(model, target, destPos, standUp, pressedCF)
    if not (model and model.Parent and target and target.Parent) then
        return
    end

    settleModel(model)

    if standUp then
        local ignore = { model }
        if Player.Character then
            table.insert(ignore, Player.Character)
        end
        local playerModels = Workspace:FindFirstChild("PlayerModels")
        if playerModels then
            table.insert(ignore, playerModels)
        end
        local gy = groundYAt(destPos, ignore)
        destPos = Vector3.new(destPos.X, gy + target.Size.Y * 0.5 + 0.15, destPos.Z)

        local yaw = 0
        if pressedCF then
            _, yaw = pressedCF:ToEulerAnglesYXZ()
        end
        local desiredMain = CFrame.new(destPos) * CFrame.Angles(0, yaw, 0)
        local pivotOffset = target.CFrame:ToObjectSpace(model:GetPivot())
        model:PivotTo(desiredMain * pivotOffset)
    else
        model:PivotTo(model:GetPivot() + (destPos - target.Position))
    end

    settleModel(model)
end

local function releaseDrag()
    pcall(function()
        ClientIsDragging:FireServer(nil)
    end)
    task.wait()
    pcall(function()
        ClientIsDragging:FireServer(nil)
    end)
end

local function interactionIsOurs(value)
    if value == Player or value == Player.Name then
        return true
    end
    if typeof(value) == "Instance" then
        return value == Player or value.Name == Player.Name
    end
    return false
end

local function findLastInteraction(model)
    local owner = model:FindFirstChild("Owner")
    local onOwner = owner and owner:FindFirstChild("LastInteraction")
    if onOwner then
        return onOwner
    end
    return model:FindFirstChild("LastInteraction", true)
end

local function approachItem(target, pressedCF)
    if not (root and root.Parent and target and target.Parent) then
        return false
    end
    if (root.Position - target.Position).Magnitude <= MAX_STUDS then
        return true
    end

    releaseDrag()
    if isStopped() or not (root and root.Parent and target and target.Parent) then
        return false
    end

    local offset = (root.Position - target.Position) * Vector3.new(1, 0, 1)
    local dir = if offset.Magnitude > 0.05 then offset.Unit else flatten(pressedCF.LookVector)
    local stand = target.Position + dir * APPROACH_STUDS + Vector3.new(0, 1.5, 0)
    local standCF = CFrame.new(stand) * (pressedCF - pressedCF.Position)
    local deadline = tick() + APPROACH_WAIT
    while tick() < deadline do
        if isStopped() or not (root and root.Parent) then
            return false
        end
        root.CFrame = standCF
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        task.wait()
    end
    return root and root.Parent and not isStopped()
end

local function fallbackClaim(model, pile)
    local waitTime = if pile then PILE_FALLBACK_WAIT else FALLBACK_WAIT
    local deadline = tick() + waitTime
    while tick() < deadline do
        if isStopped() or not (model and model.Parent) then
            return false
        end
        local ok, err = pcall(function()
            ClientIsDragging:FireServer(model)
        end)
        if not ok then
            if not pile then
                warn(("[LOT] Fallback FireServer errored on '%s': %s"):format(model.Name, tostring(err)))
            end
            return false
        end
        task.wait()
    end
    return not isStopped()
end

local function claimDrag(model, pile)
    local lastInteraction = findLastInteraction(model)
    if not lastInteraction then
        return fallbackClaim(model, pile)
    end

    local timeout = if pile then PILE_OWNERSHIP_TIMEOUT else 1
    local deadline = tick() + timeout
    while tick() < deadline do
        if isStopped() or not (model and model.Parent) then
            return false
        end
        local ok, err = pcall(function()
            ClientIsDragging:FireServer(model)
        end)
        if not ok then
            if not pile then
                warn(("[LOT] FireServer errored on '%s': %s"):format(model.Name, tostring(err)))
            end
            return false
        end
        if interactionIsOurs(lastInteraction.Value) then
            task.wait(0.08)
            if isStopped() or not (model and model.Parent) then
                return false
            end
            if interactionIsOurs(lastInteraction.Value) then
                return true
            end
        else
            task.wait()
        end
    end
    if not pile then
        warn(("[LOT] LastInteraction on '%s' never became you within %.1fs."):format(model.Name, timeout))
    end
    return false
end

local function MoveObject(v, pressedCF, i, pile, destOverride)
    if isStopped() then
        return nil
    end

    local target = dragTarget(v)
    if not target then
        return false
    end

    if not approachItem(target, pressedCF) then
        if isStopped() then
            return nil
        end
        return false
    end

    if not claimDrag(v, pile) then
        releaseDrag()
        if isStopped() then
            return nil
        end
        return false
    end

    if isStopped() or not (v.Parent and target.Parent) then
        releaseDrag()
        return nil
    end

    local destPos = destOverride
    if not destPos then
        if pile then
            destPos = (pressedCF * CFrame.new(0, 0.08 * (i - 1), 3)).Position
        else
            releaseDrag()
            return false
        end
    end
    destPos = snapOntoPlot(destPos, activePlot, activeSpacing)
    placeLogStanding(v, target, destPos, not pile, pressedCF)
    if v.Parent then
        settleModel(v)
    end

    local holdUntil = tick() + HOLD_BEFORE_RELEASE
    while tick() < holdUntil do
        if isStopped() or not v.Parent then
            break
        end
        pcall(function()
            ClientIsDragging:FireServer(v)
        end)
        task.wait()
    end
    releaseDrag()

    if not isStopped() then
        task.wait(if pile then PILE_POST_DELAY else POST_OBJECT_DELAY)
    end
    return v.Parent ~= nil
end

local function objectMatch(v)
    local tree = v:FindFirstChild("TreeClass")
    if tree then
        return "log", tree.Value
    end

    local box = v:FindFirstChild("PurchasedBoxItemName")
    if box then
        return "boxed", box.Value
    end

    local tool = v:FindFirstChild("ToolName")
    if tool then
        return "opened", tool.Value
    end

    local itemName = v:FindFirstChild("ItemName")
    if itemName then
        return "opened", itemName.Value
    end

    return nil
end

local function guessOwnedKind(form, value)
    if form == "log" then
        return "logs", "Log"
    end
    if looksLikeGift(value) then
        return "gifts", if form == "boxed" then boxedKind("Present") else "Present"
    end
    if looksLikePainting(value) then
        return "paintings", if form == "boxed" then boxedKind("Painting") else "Painting"
    end
    if looksLikeAxe(value) then
        return "axes", if form == "boxed" then boxedKind("Axe") else "Axe"
    end
    return nil, if form == "boxed" then "Boxed" else "Opened"
end

local function resolveEntry(form, value)
    value = tostring(value)
    if value == "" then
        return nil
    end

    local entry = keyIndex[form .. ":" .. value] or keyIndex[form .. ":" .. string.lower(value)]
    if entry then
        return entry
    end

    local categoryId, kind = guessOwnedKind(form, value)
    if categoryId then
        addDiscovered(categoryId, "On your plot", value, form)
        return keyIndex[form .. ":" .. value] or keyIndex[form .. ":" .. string.lower(value)]
    end

    entry = {
        id = form .. ":" .. value,
        label = prettyName(value),
        keys = { value },
        kind = kind,
        form = form,
    }
    indexItem(entry)
    return entry
end

plotTarget.itemOwner = function()
    local name = plotTarget.name
    if type(name) ~= "string" or name == "" or name == Player.Name then
        return Player
    end
    return Players:FindFirstChild(name)
end

plotTarget.ownerIs = function(ownerValue, plr)
    if not (ownerValue and plr) then
        return false
    end
    if ownerValue == plr then
        return true
    end
    if typeof(ownerValue) == "Instance" then
        return ownerValue.Name == plr.Name
    end
    return ownerValue == plr.Name
end

local function groupNameForEntry(entry)
    if entry.form == "log" then
        return "Logs"
    end
    local kind = string.lower(entry.kind or "")
    if string.find(kind, "axe", 1, true) then
        return "Axes"
    end
    if string.find(kind, "present", 1, true) or string.find(kind, "gift", 1, true) then
        return "Presents"
    end
    if string.find(kind, "paint", 1, true) then
        return "Paintings"
    end
    return "Other"
end

local function collectOwnedOnPlot()
    local counts = {}
    local unique = {}
    local ownerPlayer = plotTarget.itemOwner()
    local models = Workspace:FindFirstChild("PlayerModels")
    if ownerPlayer and models then
        for _, v in ipairs(models:GetChildren()) do
            local owner = v:FindFirstChild("Owner")
            if owner and plotTarget.ownerIs(owner.Value, ownerPlayer) then
                local form, value = objectMatch(v)
                if form and value ~= nil and tostring(value) ~= "" then
                    local entry = resolveEntry(form, value)
                    if entry then
                        counts[entry.id] = (counts[entry.id] or 0) + 1
                        unique[entry.id] = entry
                    end
                end
            end
        end
    end

    local buckets = {
        Logs = {},
        Axes = {},
        Presents = {},
        Paintings = {},
        Other = {},
    }
    for id, entry in pairs(unique) do
        local row = table.clone(entry)
        row.ownedCount = counts[id]
        table.insert(buckets[groupNameForEntry(entry)], row)
    end

    local groups = {}
    for _, name in ipairs({ "Logs", "Axes", "Presents", "Paintings", "Other" }) do
        local items = buckets[name]
        table.sort(items, function(a, b)
            return string.lower(a.label) < string.lower(b.label)
        end)
        if #items > 0 then
            table.insert(groups, { name = name .. "  (" .. #items .. ")", items = items })
        end
    end
    return groups
end

local cachedOwnedGroups
local lastOwnedFingerprint = ""

local function ownedFingerprint(groups)
    local parts = {}
    for _, group in ipairs(groups) do
        for _, entry in ipairs(group.items) do
            table.insert(parts, entry.id .. "=" .. tostring(entry.ownedCount or 0))
        end
    end
    table.sort(parts)
    return table.concat(parts, "|")
end

local function refreshOwnedSnapshot()
    local groups = collectOwnedOnPlot()
    local fp = ownedFingerprint(groups)
    local changed = fp ~= lastOwnedFingerprint
    cachedOwnedGroups = groups
    lastOwnedFingerprint = fp
    return changed
end

local function objectIsSelected(v)
    local form, value = objectMatch(v)
    if not form or value == nil or value == "" then
        return false
    end

    local entry = keyIndex[form .. ":" .. value] or keyIndex[form .. ":" .. string.lower(tostring(value))]
    if entry and selected[entry.id] then
        return true, displayLabel(entry)
    end
    return false
end

local function anySelected()
    for _, entry in ipairs(allItems) do
        if selected[entry.id] then
            return true
        end
    end
    return false
end

local function itemMatchesSearch(entry)
    if searchQuery == "" then
        return true
    end
    local parts = {
        entry.label or "",
        entry.id or "",
        displayLabel(entry),
        entry.kind or "",
        table.concat(entry.keys or {}, " "),
    }
    local hay = string.lower(table.concat(parts, " "))
    for word in string.gmatch(searchQuery, "%S+") do
        if not string.find(hay, word, 1, true) then
            return false
        end
    end
    return true
end

local function itemsForCategory(catId)
    if catId == "owned" then
        if not cachedOwnedGroups then
            refreshOwnedSnapshot()
        end
        return cachedOwnedGroups or {}
    end
    if catId == "rare" then
        return { { name = "High value", items = rareItems } }
    end

    for _, category in ipairs(CATALOG) do
        if category.id == catId then
            return category.groups
        end
    end
    return {}
end

local function isPlank(model)
    return model and model.Name == "Plank"
end

local function shouldGrid(model)
    if model:FindFirstChild("TreeClass") == nil then
        return false
    end
    if pilePlanks and isPlank(model) then
        return false
    end
    return true
end

local function RunPass()
    local char = Player.Character
    root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then
        setStatus("No character")
        return
    end

    if not anySelected() then
        setStatus("Select an item")
        return
    end

    local pressedCF = root.CFrame
    activePlot = getPlotArea(pressedCF.Position)
    if not activePlot then
        setStatus("Stand on your plot")
        return
    end

    local ownerPlayer = plotTarget.itemOwner()
    if not ownerPlayer then
        setStatus("Player left")
        return
    end

    local models = Workspace:FindFirstChild("PlayerModels")
    if not models then
        setStatus("No matching items")
        return
    end

    local matches = {}
    for _, v in ipairs(models:GetChildren()) do
        if v:FindFirstChild("Owner") and plotTarget.ownerIs(v.Owner.Value, ownerPlayer) then
            local ok, label = objectIsSelected(v)
            if ok and dragTarget(v) then
                table.insert(matches, {
                    model = v,
                    label = label,
                    isLog = shouldGrid(v),
                })
            end
        end
    end

    local alive = {}
    for _, job in ipairs(matches) do
        alive[job.model] = true
    end
    for model in pairs(cycleDone) do
        if not alive[model] then
            cycleDone[model] = nil
        end
    end

    local pending = {}
    for _, job in ipairs(matches) do
        if not cycleDone[job.model] then
            table.insert(pending, job)
        end
    end
    if #pending == 0 and #matches > 0 then
        table.clear(cycleDone)
        pending = matches
    end

    local jobs = pending
    if logLimit and #pending > logLimit then
        jobs = {}
        for i = 1, logLimit do
            jobs[i] = pending[i]
        end
    end

    local logModels = {}
    for _, job in ipairs(jobs) do
        if job.isLog then
            table.insert(logModels, job.model)
        end
    end
    local spacing = logSpacingFor(logModels)
    activeSpacing = spacing
    local logSlots = buildLogSlots(pressedCF, #logModels, activePlot, spacing)

    local logI = 1
    local pileI = 1
    local moved = 0

    for index, job in ipairs(jobs) do
        if isStopped() then
            if root and root.Parent then
                releaseDrag()
                root.CFrame = pressedCF
            end
            setStatus("Stopped")
            return
        end
        local dest
        local pile = false
        if job.isLog then
            dest = logSlots[logI] or fallbackDest(pressedCF, activePlot)
            logI += 1
        else
            dest = (pressedCF * CFrame.new(0, 0.08 * (pileI - 1), 3)).Position
            pile = true
            pileI += 1
        end
        dest = snapOntoPlot(dest, activePlot, activeSpacing)
        setStatus(("Moving %s (%d/%d)"):format(job.label, index, #jobs))
        local placed = MoveObject(job.model, pressedCF, index, pile, dest)
        if placed == nil or isStopped() then
            if root and root.Parent then
                releaseDrag()
                root.CFrame = pressedCF
            end
            setStatus("Stopped")
            return
        end
        cycleDone[job.model] = true
        if placed then
            moved += 1
        end
    end

    if root and root.Parent then
        releaseDrag()
        root.CFrame = pressedCF
    end

    if moved == 0 then
        setStatus(if #jobs == 0 then "No matching items" else "Couldn't grab")
    else
        setStatus(("Moved %d item%s"):format(moved, if moved == 1 then "" else "s"))
    end
end

local function getUiParent()
    local ok, hui = pcall(function()
        return gethui()
    end)
    if ok and hui then
        return hui
    end

    local coreOk, coreGui = pcall(function()
        return Services.CoreGui
    end)
    if coreOk and coreGui then
        return coreGui
    end

    return Player:WaitForChild("PlayerGui")
end

local function make(className, props, parent)
    local inst = Instance.new(className)
    for key, value in pairs(props) do
        inst[key] = value
    end
    inst.Parent = parent
    return inst
end

local uiParent = getUiParent()
local existing = uiParent:FindFirstChild(GUI_NAME)
if existing then
    existing:Destroy()
end

screenGui = make("ScreenGui", {
    Name = GUI_NAME,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 999,
}, uiParent)

local SIDE_W = 84
local toggleKey = Enum.KeyCode.T
local listeningForKey = false
local strengthEnabled = false
local strengthState
local CONFIG_DIR = "LT2Scripts"
local CONFIG_FILE = CONFIG_DIR .. "/settings.json"

local function readSavedConfig()
    if type(readfile) ~= "function" then
        return nil
    end
    if type(isfile) == "function" and not isfile(CONFIG_FILE) then
        return nil
    end
    local ok, raw = pcall(readfile, CONFIG_FILE)
    if not ok or type(raw) ~= "string" or raw == "" then
        return nil
    end
    local decodedOk, data = pcall(function()
        return Services.HttpService:JSONDecode(raw)
    end)
    if decodedOk and type(data) == "table" then
        return data
    end
    return nil
end

local function applySavedConfig(data)
    if type(data.toggleKey) == "string" then
        local keyOk, key = pcall(function()
            return Enum.KeyCode[data.toggleKey]
        end)
        if keyOk and key and key ~= Enum.KeyCode.Unknown then
            toggleKey = key
        end
    end
    if data.amount == "unlimited" then
        logLimit = nil
    elseif type(data.amount) == "number" then
        logLimit = math.clamp(math.floor(data.amount), 1, AMOUNT_MAX)
    end
    if type(data.pilePlanks) == "boolean" then
        pilePlanks = data.pilePlanks
    end
    if type(data.strength) == "boolean" then
        strengthEnabled = data.strength
    end
    if type(data.player) == "string" and data.player ~= "" and data.player ~= Player.Name then
        if Players:FindFirstChild(data.player) then
            plotTarget.name = data.player
        end
    end
    local categories = {
        owned = true,
        logs = true,
        axes = true,
        gifts = true,
        paintings = true,
        rare = true,
    }
    if categories[data.category] then
        currentCategoryId = data.category
    end
    if type(data.selected) == "table" then
        local on = {}
        for _, id in ipairs(data.selected) do
            if type(id) == "string" then
                on[id] = true
            end
        end
        for id in pairs(selected) do
            selected[id] = on[id] == true
        end
    end
end

local savedConfig = readSavedConfig()
local windowPos = UDim2.new(0, 16, 0.5, -210)
if savedConfig then
    applySavedConfig(savedConfig)
    local pos = savedConfig.position
    if type(pos) == "table"
        and type(pos.xScale) == "number"
        and type(pos.xOffset) == "number"
        and type(pos.yScale) == "number"
        and type(pos.yOffset) == "number"
    then
        windowPos = UDim2.new(pos.xScale, pos.xOffset, pos.yScale, pos.yOffset)
    end
end

local window = make("Frame", {
    Name = "Window",
    Size = UDim2.fromOffset(280 + SIDE_W, 420),
    Position = windowPos,
    BackgroundColor3 = Color3.fromRGB(18, 18, 18),
    BorderSizePixel = 0,
}, screenGui)

local sidePanel = make("Frame", {
    Name = "SidePanel",
    Size = UDim2.new(0, SIDE_W, 1, 0),
    BackgroundColor3 = Color3.fromRGB(14, 14, 14),
    BorderSizePixel = 0,
}, window)

make("Frame", {
    Size = UDim2.new(0, 1, 1, -16),
    Position = UDim2.new(1, -1, 0, 8),
    BackgroundColor3 = Color3.fromRGB(48, 48, 48),
    BorderSizePixel = 0,
}, sidePanel)

local scriptList = make("ScrollingFrame", {
    Name = "Scripts",
    Size = UDim2.new(1, -12, 1, -52),
    Position = UDim2.fromOffset(6, 8),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = Color3.fromRGB(70, 70, 70),
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollingDirection = Enum.ScrollingDirection.Y,
}, sidePanel)

make("UIListLayout", {
    Padding = UDim.new(0, 4),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, scriptList)

local function makeRailButton(text, parent, order)
    return make("TextButton", {
        Size = UDim2.new(1, 0, 0, 22),
        BackgroundColor3 = Color3.fromRGB(58, 58, 58),
        BorderSizePixel = 0,
        Font = Enum.Font.SourceSans,
        Text = text,
        TextSize = 14,
        TextColor3 = Color3.fromRGB(230, 230, 230),
        TextTruncate = Enum.TextTruncate.AtEnd,
        AutoButtonColor = false,
        LayoutOrder = order or 0,
    }, parent)
end

local duperBtn = makeRailButton("Duper", scriptList, 1)
duperBtn.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
duperBtn.TextColor3 = Color3.fromRGB(18, 18, 18)

local strengthRailBtn = makeRailButton("Strength", scriptList, 2)

local settingsBtn = makeRailButton("Settings", sidePanel)
settingsBtn.Size = UDim2.new(1, -12, 0, 22)
settingsBtn.Position = UDim2.new(0, 6, 1, -30)

local titleBar = make("Frame", {
    Name = "TitleBar",
    Size = UDim2.new(1, -SIDE_W, 0, 28),
    Position = UDim2.fromOffset(SIDE_W, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
}, window)

make("Frame", {
    Size = UDim2.new(1, -16, 0, 1),
    Position = UDim2.new(0, 8, 1, -1),
    BackgroundColor3 = Color3.fromRGB(48, 48, 48),
    BorderSizePixel = 0,
}, titleBar)

local titleLabel = make("TextLabel", {
    Size = UDim2.fromOffset(110, 28),
    Position = UDim2.fromOffset(10, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.SourceSans,
    Text = "Duper",
    TextSize = 16,
    TextColor3 = Color3.fromRGB(230, 230, 230),
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
}, titleBar)

local timerLabel = make("TextLabel", {
    Size = UDim2.fromOffset(48, 28),
    Position = UDim2.fromOffset(112, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.SourceSans,
    Text = "0:00",
    TextSize = 15,
    TextColor3 = Color3.fromRGB(140, 140, 140),
    TextXAlignment = Enum.TextXAlignment.Left,
}, titleBar)

local timerToken = 0
local timerStart = 0
local timerRunning = false

local function formatRunTime(sec)
    sec = math.max(0, math.floor(sec + 0.0001))
    return string.format("%d:%02d", math.floor(sec / 60), sec % 60)
end

local function setTimerDisplay(elapsed)
    if not (timerLabel and timerLabel.Parent) then
        return
    end
    timerLabel.Text = formatRunTime(elapsed)
    if elapsed >= 60 then
        timerLabel.TextColor3 = Color3.fromRGB(200, 80, 80)
    else
        timerLabel.TextColor3 = Color3.fromRGB(140, 140, 140)
    end
end

local function stopRunTimer()
    timerRunning = false
    timerToken += 1
    timerStart = 0
    setTimerDisplay(0)
end

local function startRunTimer()
    if timerRunning then
        return
    end
    timerToken += 1
    local token = timerToken
    timerStart = tick()
    timerRunning = true
    setTimerDisplay(0)
    task.spawn(function()
        while token == timerToken and timerRunning and screenGui and screenGui.Parent do
            setTimerDisplay(tick() - timerStart)
            task.wait(0.15)
        end
        if token == timerToken then
            setTimerDisplay(0)
        end
    end)
end

local closeBtn = make("TextButton", {
    Size = UDim2.fromOffset(28, 28),
    Position = UDim2.new(1, -32, 0, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Font = Enum.Font.SourceSans,
    Text = "x",
    TextSize = 16,
    TextColor3 = Color3.fromRGB(140, 140, 140),
    AutoButtonColor = false,
}, titleBar)

local body = make("Frame", {
    Size = UDim2.new(1, -(16 + SIDE_W), 1, -36),
    Position = UDim2.fromOffset(8 + SIDE_W, 32),
    BackgroundTransparency = 1,
}, window)

local duperPage = make("Frame", {
    Name = "DuperPage",
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
}, body)

local settingsPage = make("Frame", {
    Name = "SettingsPage",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(18, 18, 18),
    BorderSizePixel = 0,
    Visible = false,
    Active = true,
    ZIndex = 3,
}, body)

make("TextLabel", {
    Size = UDim2.new(1, 0, 0, 16),
    BackgroundTransparency = 1,
    Font = Enum.Font.SourceSans,
    Text = "Toggle UI",
    TextSize = 14,
    TextColor3 = Color3.fromRGB(160, 160, 160),
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 3,
}, settingsPage)

local keyBtn = make("TextButton", {
    Size = UDim2.fromOffset(120, 22),
    Position = UDim2.fromOffset(0, 22),
    BackgroundColor3 = Color3.fromRGB(58, 58, 58),
    BorderSizePixel = 0,
    Font = Enum.Font.SourceSans,
    Text = toggleKey.Name,
    TextSize = 15,
    TextColor3 = Color3.fromRGB(230, 230, 230),
    TextTruncate = Enum.TextTruncate.AtEnd,
    AutoButtonColor = false,
    ZIndex = 3,
}, settingsPage)

make("TextLabel", {
    Size = UDim2.new(1, 0, 0, 16),
    Position = UDim2.fromOffset(0, 56),
    BackgroundTransparency = 1,
    Font = Enum.Font.SourceSans,
    Text = "Strength",
    TextSize = 14,
    TextColor3 = Color3.fromRGB(160, 160, 160),
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 3,
}, settingsPage)

local strengthSettingsBtn = make("TextButton", {
    Size = UDim2.fromOffset(120, 22),
    Position = UDim2.fromOffset(0, 78),
    BackgroundColor3 = Color3.fromRGB(58, 58, 58),
    BorderSizePixel = 0,
    Font = Enum.Font.SourceSans,
    Text = "Off",
    TextSize = 15,
    TextColor3 = Color3.fromRGB(230, 230, 230),
    AutoButtonColor = false,
    ZIndex = 3,
}, settingsPage)

plotTarget.bind = function()
    make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.fromOffset(0, 112),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = "Player",
        TextSize = 14,
        TextColor3 = Color3.fromRGB(160, 160, 160),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
    }, settingsPage)

    local playerBtn = make("TextButton", {
        Size = UDim2.new(1, 0, 0, 22),
        Position = UDim2.fromOffset(0, 130),
        BackgroundColor3 = Color3.fromRGB(58, 58, 58),
        BorderSizePixel = 0,
        Font = Enum.Font.SourceSans,
        Text = plotTarget.name or "",
        TextSize = 15,
        TextColor3 = Color3.fromRGB(230, 230, 230),
        TextTruncate = Enum.TextTruncate.AtEnd,
        AutoButtonColor = false,
        ZIndex = 4,
    }, settingsPage)

    local playerList = make("ScrollingFrame", {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.fromOffset(0, 152),
        BackgroundColor3 = Color3.fromRGB(28, 28, 28),
        BorderSizePixel = 0,
        Visible = false,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Color3.fromRGB(70, 70, 70),
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ZIndex = 6,
    }, settingsPage)

    make("UIListLayout", {
        Padding = UDim.new(0, 1),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, playerList)

    local function closePlayerList()
        playerList.Visible = false
    end

    local function refreshPlayerButton()
        if type(plotTarget.name) == "string" and plotTarget.name ~= "" and plotTarget.name ~= Player.Name then
            playerBtn.Text = plotTarget.name
        else
            playerBtn.Text = ""
            plotTarget.name = nil
        end
    end

    local function applyTargetPlayer(name)
        if type(name) ~= "string" or name == "" or name == Player.Name then
            plotTarget.name = nil
        else
            plotTarget.name = name
        end
        refreshPlayerButton()
        cachedOwnedGroups = nil
        lastOwnedFingerprint = ""
        if currentCategoryId == "owned" and rebuildList then
            refreshOwnedSnapshot()
            rebuildList()
        end
    end

    local function lobbyNames()
        local names = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= Player then
                table.insert(names, plr.Name)
            end
        end
        table.sort(names, function(a, b)
            return string.lower(a) < string.lower(b)
        end)
        return names
    end

    local function fillPlayerList()
        for _, child in ipairs(playerList:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        local names = lobbyNames()
        if type(plotTarget.name) == "string" and plotTarget.name ~= "" and not Players:FindFirstChild(plotTarget.name) then
            applyTargetPlayer(nil)
        end

        for index, name in ipairs(names) do
            local on = name == plotTarget.name
            local row = make("TextButton", {
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundColor3 = on and Color3.fromRGB(230, 230, 230) or Color3.fromRGB(42, 42, 42),
                BorderSizePixel = 0,
                Font = Enum.Font.SourceSans,
                Text = name,
                TextSize = 14,
                TextColor3 = on and Color3.fromRGB(18, 18, 18) or Color3.fromRGB(230, 230, 230),
                TextTruncate = Enum.TextTruncate.AtEnd,
                AutoButtonColor = false,
                LayoutOrder = index,
                ZIndex = 6,
            }, playerList)
            row.MouseButton1Click:Connect(function()
                if plotTarget.name == name then
                    applyTargetPlayer(nil)
                else
                    applyTargetPlayer(name)
                end
                closePlayerList()
            end)
        end

        playerList.Size = UDim2.new(1, 0, 0, math.min(#names * 21, 126))
        playerList.Visible = #names > 0
    end

    refreshPlayerButton()

    Players.PlayerAdded:Connect(function()
        if playerList.Visible then
            fillPlayerList()
        elseif type(plotTarget.name) == "string" then
            refreshPlayerButton()
        end
    end)

    Players.PlayerRemoving:Connect(function(plr)
        if plr.Name == plotTarget.name then
            applyTargetPlayer(nil)
        end
        if playerList.Visible then
            fillPlayerList()
        end
    end)

    playerBtn.MouseButton1Click:Connect(function()
        if playerList.Visible then
            closePlayerList()
            return
        end
        fillPlayerList()
    end)

    plotTarget.closeList = closePlayerList
    plotTarget.refresh = refreshPlayerButton
end
plotTarget.bind()

local saveBtn = make("TextButton", {
    Size = UDim2.fromOffset(120, 22),
    Position = UDim2.new(1, -120, 1, -22),
    BackgroundColor3 = Color3.fromRGB(230, 230, 230),
    BorderSizePixel = 0,
    Font = Enum.Font.SourceSans,
    Text = "Save Config",
    TextSize = 15,
    TextColor3 = Color3.fromRGB(18, 18, 18),
    AutoButtonColor = false,
    ZIndex = 3,
}, settingsPage)

local tabBar = make("Frame", {
    Size = UDim2.new(1, 0, 0, 36),
    BackgroundTransparency = 1,
}, body)

make("UIGridLayout", {
    CellSize = UDim2.new(0.333, -2, 0, 16),
    CellPadding = UDim2.fromOffset(2, 2),
    FillDirection = Enum.FillDirection.Horizontal,
    SortOrder = Enum.SortOrder.LayoutOrder,
}, tabBar)

local TAB_DEFS = {
    { id = "owned", name = "On Plot" },
    { id = "logs", name = "Logs" },
    { id = "axes", name = "Axes" },
    { id = "gifts", name = "Presents" },
    { id = "paintings", name = "Paintings" },
    { id = "rare", name = "Rare" },
}

local tabButtons = {}

local selectRow = make("Frame", {
    Size = UDim2.new(1, 0, 0, 16),
    Position = UDim2.fromOffset(0, 40),
    BackgroundTransparency = 1,
}, body)

local selectAllBtn = make("TextButton", {
    Size = UDim2.new(0.33, 0, 1, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.SourceSans,
    Text = "All",
    TextSize = 14,
    TextColor3 = Color3.fromRGB(210, 210, 210),
    TextXAlignment = Enum.TextXAlignment.Left,
    AutoButtonColor = false,
}, selectRow)

local searchToggleBtn = make("TextButton", {
    Size = UDim2.new(0.34, 0, 1, 0),
    Position = UDim2.new(0.33, 0, 0, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.SourceSans,
    Text = "Search",
    TextSize = 14,
    TextColor3 = Color3.fromRGB(210, 210, 210),
    AutoButtonColor = false,
}, selectRow)

local selectNoneBtn = make("TextButton", {
    Size = UDim2.new(0.33, 0, 1, 0),
    Position = UDim2.new(0.67, 0, 0, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.SourceSans,
    Text = "Clear",
    TextSize = 14,
    TextColor3 = Color3.fromRGB(210, 210, 210),
    TextXAlignment = Enum.TextXAlignment.Right,
    AutoButtonColor = false,
}, selectRow)

local searchBox = make("TextBox", {
    Size = UDim2.new(1, 0, 0, 20),
    Position = UDim2.fromOffset(0, 58),
    BackgroundColor3 = Color3.fromRGB(28, 28, 28),
    BorderSizePixel = 0,
    Font = Enum.Font.SourceSans,
    Text = "",
    PlaceholderText = "Search",
    PlaceholderColor3 = Color3.fromRGB(110, 110, 110),
    TextSize = 14,
    TextColor3 = Color3.fromRGB(230, 230, 230),
    TextXAlignment = Enum.TextXAlignment.Left,
    ClearTextOnFocus = false,
    ClipsDescendants = true,
}, body)
make("UIPadding", {
    PaddingLeft = UDim.new(0, 6),
    PaddingRight = UDim.new(0, 6),
}, searchBox)

local list = make("ScrollingFrame", {
    Size = UDim2.new(1, 0, 1, -168),
    Position = UDim2.fromOffset(0, 82),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = Color3.fromRGB(70, 70, 70),
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollingDirection = Enum.ScrollingDirection.Y,
}, body)
make("UIPadding", {
    PaddingTop = UDim.new(0, 2),
    PaddingBottom = UDim.new(0, 2),
}, list)

local listInner = make("Frame", {
    Size = UDim2.new(1, -6, 0, 0),
    AutomaticSize = Enum.AutomaticSize.Y,
    BackgroundTransparency = 1,
}, list)

make("UIListLayout", {
    FillDirection = Enum.FillDirection.Vertical,
    Padding = UDim.new(0, 1),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, listInner)

local function rowText(entry, on)
    local count = entry.ownedCount and ("  x" .. entry.ownedCount) or ""
    return (on and "[x]  " or "[ ]  ") .. displayLabel(entry) .. count
end

local function styleToggle(button, on)
    button.BackgroundTransparency = 1
    button.TextColor3 = on and Color3.fromRGB(230, 230, 230) or Color3.fromRGB(140, 140, 140)
end

local function styleTab(button, on)
    button.BackgroundTransparency = 1
    button.Font = on and Enum.Font.SourceSansBold or Enum.Font.SourceSans
    button.TextColor3 = on and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(175, 175, 175)
end

rebuildList = function()
    local scroll = list.CanvasPosition
    for _, child in ipairs(listInner:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end

    local order = 0
    local shown = 0
    for _, group in ipairs(itemsForCategory(currentCategoryId)) do
        local visible = {}
        for _, entry in ipairs(group.items) do
            if itemMatchesSearch(entry) then
                table.insert(visible, entry)
            end
        end
        if #visible > 0 then
            order += 1
            local header = make("TextButton", {
                Size = UDim2.new(1, 0, 0, 16),
                BackgroundTransparency = 1,
                Font = Enum.Font.SourceSans,
                Text = group.name,
                TextSize = 14,
                TextColor3 = Color3.fromRGB(100, 100, 100),
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = false,
                LayoutOrder = order,
            }, listInner)

            local groupItems = visible
            header.MouseButton1Click:Connect(function()
                local allOn = true
                for _, entry in ipairs(groupItems) do
                    if not selected[entry.id] then
                        allOn = false
                        break
                    end
                end
                for _, entry in ipairs(groupItems) do
                    selected[entry.id] = not allOn
                end
                rebuildList()
            end)

            for _, entry in ipairs(groupItems) do
                order += 1
                shown += 1
                local on = selected[entry.id] == true
                local btn = make("TextButton", {
                    Name = entry.id,
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Font = Enum.Font.SourceSans,
                    Text = rowText(entry, on),
                    TextSize = 15,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    AutoButtonColor = false,
                    LayoutOrder = order,
                }, listInner)

                styleToggle(btn, on)

                local itemId = entry.id
                btn.MouseButton1Click:Connect(function()
                    selected[itemId] = not selected[itemId]
                    btn.Text = rowText(entry, selected[itemId] == true)
                    styleToggle(btn, selected[itemId] == true)
                end)
            end
        end
    end

    if shown == 0 then
        make("TextLabel", {
            Size = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
            Font = Enum.Font.SourceSans,
            Text = if searchQuery ~= "" then "No matches" else "Nothing here",
            TextSize = 15,
            TextColor3 = Color3.fromRGB(110, 110, 110),
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 1,
        }, listInner)
    end

    list.CanvasPosition = scroll
end

local function setCategory(catId)
    currentCategoryId = catId
    if catId == "owned" then
        refreshOwnedSnapshot()
    else
        cachedOwnedGroups = nil
    end
    for id, button in pairs(tabButtons) do
        styleTab(button, id == catId)
    end
    rebuildList()
end

for index, def in ipairs(TAB_DEFS) do
    local btn = make("TextButton", {
        LayoutOrder = index,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Font = Enum.Font.SourceSans,
        Text = def.name,
        TextSize = 14,
        TextColor3 = Color3.fromRGB(175, 175, 175),
        AutoButtonColor = false,
    }, tabBar)
    tabButtons[def.id] = btn
    btn.MouseButton1Click:Connect(function()
        setCategory(def.id)
    end)
end

selectAllBtn.MouseButton1Click:Connect(function()
    for _, group in ipairs(itemsForCategory(currentCategoryId)) do
        for _, entry in ipairs(group.items) do
            if itemMatchesSearch(entry) then
                selected[entry.id] = true
            end
        end
    end
    rebuildList()
end)

selectNoneBtn.MouseButton1Click:Connect(function()
    for _, group in ipairs(itemsForCategory(currentCategoryId)) do
        for _, entry in ipairs(group.items) do
            if itemMatchesSearch(entry) then
                selected[entry.id] = false
            end
        end
    end
    rebuildList()
end)

local function applySearch(text)
    searchQuery = string.lower(text or "")
    rebuildList()
end

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    applySearch(searchBox.Text)
end)

searchToggleBtn.MouseButton1Click:Connect(function()
    searchBox:CaptureFocus()
end)

local amountLabel = make("TextLabel", {
    Size = UDim2.new(1, -78, 0, 18),
    Position = UDim2.new(0, 0, 1, -82),
    BackgroundTransparency = 1,
    Font = Enum.Font.SourceSans,
    Text = "Amount  Unlimited",
    TextSize = 14,
    TextColor3 = Color3.fromRGB(200, 200, 200),
    TextXAlignment = Enum.TextXAlignment.Left,
}, body)

local pilePlanksBtn = make("TextButton", {
    Size = UDim2.fromOffset(70, 18),
    Position = UDim2.new(1, -70, 1, -82),
    BackgroundColor3 = Color3.fromRGB(58, 58, 58),
    BorderSizePixel = 0,
    Font = Enum.Font.SourceSans,
    Text = "Pile off",
    TextSize = 14,
    TextColor3 = Color3.fromRGB(230, 230, 230),
    AutoButtonColor = false,
}, body)

local function stylePilePlanks()
    if pilePlanks then
        pilePlanksBtn.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
        pilePlanksBtn.TextColor3 = Color3.fromRGB(18, 18, 18)
        pilePlanksBtn.Text = "Pile on"
    else
        pilePlanksBtn.BackgroundColor3 = Color3.fromRGB(58, 58, 58)
        pilePlanksBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
        pilePlanksBtn.Text = "Pile off"
    end
end

pilePlanksBtn.MouseButton1Click:Connect(function()
    pilePlanks = not pilePlanks
    stylePilePlanks()
end)
stylePilePlanks()

local sliderTrack = make("Frame", {
    Size = UDim2.new(1, 0, 0, 12),
    Position = UDim2.new(0, 0, 1, -58),
    BackgroundColor3 = Color3.fromRGB(42, 42, 42),
    BorderSizePixel = 0,
    Active = true,
}, body)

local sliderFill = make("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(200, 200, 200),
    BorderSizePixel = 0,
}, sliderTrack)

local sliderKnob = make("Frame", {
    Size = UDim2.fromOffset(10, 10),
    Position = UDim2.new(1, -10, 0.5, -5),
    BackgroundColor3 = Color3.fromRGB(230, 230, 230),
    BorderSizePixel = 0,
    ZIndex = 2,
}, sliderTrack)

local function sliderAlpha()
    if logLimit == nil then
        return 1
    end
    return logLimit / (AMOUNT_MAX + 1)
end

local function refreshAmountUI()
    local alpha = sliderAlpha()
    sliderFill.Size = UDim2.fromScale(alpha, 1)
    sliderKnob.Position = UDim2.new(alpha, -10 * alpha, 0.5, -5)
    if logLimit == nil then
        amountLabel.Text = "Amount  Unlimited"
    else
        amountLabel.Text = "Amount  " .. logLimit
    end
end

local function setAmountFromAlpha(alpha)
    alpha = math.clamp(alpha, 0, 1)
    local step = math.clamp(math.round(alpha * (AMOUNT_MAX + 1)), 0, AMOUNT_MAX + 1)
    if step >= AMOUNT_MAX + 1 then
        logLimit = nil
    else
        logLimit = math.max(step, 1)
    end
    refreshAmountUI()
end

local sliding = false

local function setAmountFromX(x)
    local width = sliderTrack.AbsoluteSize.X
    if width <= 0 then
        return
    end
    setAmountFromAlpha((x - sliderTrack.AbsolutePosition.X) / width)
end

sliderTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliding = true
        setAmountFromX(input.Position.X)
    end
end)

sliderTrack.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliding = false
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliding = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
        setAmountFromX(input.Position.X)
    end
end)

refreshAmountUI()
setCategory(currentCategoryId)

do
    local ownedRefreshToken = 0
    local modelConns = {}

    local function refreshOwnedIfOpen()
        if currentCategoryId ~= "owned" then
            return
        end
        if not (screenGui and screenGui.Parent and rebuildList) then
            return
        end
        if refreshOwnedSnapshot() then
            rebuildList()
        end
    end

    local function scheduleOwnedRefresh()
        if currentCategoryId ~= "owned" then
            cachedOwnedGroups = nil
            lastOwnedFingerprint = ""
            return
        end
        ownedRefreshToken += 1
        local token = ownedRefreshToken
        task.delay(0.1, function()
            if token == ownedRefreshToken then
                refreshOwnedIfOpen()
            end
        end)
    end

    local function hookPlayerModels(models)
        for _, conn in ipairs(modelConns) do
            conn:Disconnect()
        end
        table.clear(modelConns)
        if not models then
            return
        end
        table.insert(modelConns, models.ChildAdded:Connect(scheduleOwnedRefresh))
        table.insert(modelConns, models.ChildRemoved:Connect(scheduleOwnedRefresh))
    end

    hookPlayerModels(Workspace:FindFirstChild("PlayerModels"))
    Workspace.ChildAdded:Connect(function(child)
        if child.Name == "PlayerModels" then
            hookPlayerModels(child)
            scheduleOwnedRefresh()
        end
    end)

    task.spawn(function()
        while screenGui and screenGui.Parent do
            if currentCategoryId == "owned" then
                refreshOwnedIfOpen()
            end
            task.wait(0.35)
        end
        for _, conn in ipairs(modelConns) do
            conn:Disconnect()
        end
    end)
end

local runBtn = make("TextButton", {
    Size = UDim2.new(0.5, -2, 0, 22),
    Position = UDim2.new(0, 0, 1, -40),
    BackgroundColor3 = Color3.fromRGB(230, 230, 230),
    BorderSizePixel = 0,
    Font = Enum.Font.SourceSans,
    Text = "Run",
    TextSize = 15,
    TextColor3 = Color3.fromRGB(18, 18, 18),
    AutoButtonColor = false,
}, body)

local autoBtn = make("TextButton", {
    Size = UDim2.new(0.33, -4, 0, 22),
    Position = UDim2.new(0.34, 2, 1, -40),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Font = Enum.Font.SourceSans,
    Text = "Auto",
    TextSize = 15,
    TextColor3 = Color3.fromRGB(140, 140, 140),
    AutoButtonColor = false,
    Visible = false,
}, body)

local stopBtn = make("TextButton", {
    Size = UDim2.new(0.5, -2, 0, 22),
    Position = UDim2.new(0.5, 2, 1, -40),
    BackgroundColor3 = Color3.fromRGB(58, 58, 58),
    BorderSizePixel = 0,
    Font = Enum.Font.SourceSans,
    Text = "Stop",
    TextSize = 15,
    TextColor3 = Color3.fromRGB(235, 235, 235),
    AutoButtonColor = false,
}, body)

local statusLabel = make("TextLabel", {
    Size = UDim2.new(1, 0, 0, 14),
    Position = UDim2.new(0, 0, 1, -14),
    BackgroundTransparency = 1,
    Font = Enum.Font.SourceSans,
    Text = "Idle",
    TextSize = 14,
    TextColor3 = Color3.fromRGB(120, 120, 120),
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
}, body)

for _, child in ipairs(body:GetChildren()) do
    if child ~= duperPage and child ~= settingsPage then
        child.Parent = duperPage
    end
end

setStatus = function(text)
    if statusLabel and statusLabel.Parent then
        statusLabel.Text = text
    end
end

local function setAutoVisual(on)
    autoBtn.BackgroundTransparency = 1
    if on then
        autoBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
        autoBtn.Text = "Auto on"
    else
        autoBtn.TextColor3 = Color3.fromRGB(140, 140, 140)
        autoBtn.Text = "Auto"
    end
end

local function stopScript(closeUi)
    abort = true
    auto = false
    autoToken += 1
    setAutoVisual(false)
    stopRunTimer()
    if closeUi then
        strengthEnabled = false
        if strengthState then
            strengthState.enabled = false
        end
        if screenGui then
            screenGui:Destroy()
        end
        return
    end
    setStatus("Stopped")
    if runBtn and runBtn.Parent then
        runBtn.Text = "Run"
    end
end

local function runOnce()
    if busy or isStopped() then
        return
    end

    busy = true
    abort = false
    startRunTimer()
    if runBtn and runBtn.Parent then
        runBtn.Text = "..."
    end
    local ok, err = pcall(RunPass)
    if isStopped() then
        setStatus("Stopped")
    elseif not ok then
        setStatus("Error")
        warn("[LOT] " .. tostring(err))
    end
    busy = false
    if runBtn and runBtn.Parent then
        runBtn.Text = "Run"
    end
    if not auto then
        stopRunTimer()
    end
end

runBtn.MouseButton1Click:Connect(function()
    if busy then
        return
    end
    if isStopped() then
        abort = false
    end
    task.spawn(runOnce)
end)

autoBtn.MouseButton1Click:Connect(function()
    auto = not auto
    if auto then
        abort = false
    end
    setAutoVisual(auto)

    if not auto then
        autoToken += 1
        if not busy then
            setStatus("Idle")
            stopRunTimer()
        end
        return
    end

    autoToken += 1
    local token = autoToken
    setStatus("Auto running")

    task.spawn(function()
        while auto and token == autoToken and not isStopped() do
            runOnce()
            local untilTime = tick() + AUTO_PAUSE
            while auto and token == autoToken and not isStopped() and tick() < untilTime do
                task.wait()
            end
        end
    end)
end)

stopBtn.MouseButton1Click:Connect(function()
    stopScript(false)
end)

closeBtn.MouseButton1Click:Connect(function()
    stopScript(true)
end)

local currentDash = "duper"

local strengthPage = make("Frame", {
    Name = "StrengthPage",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(18, 18, 18),
    BorderSizePixel = 0,
    Visible = false,
    Active = true,
    ZIndex = 3,
}, body)

make("TextLabel", {
    Size = UDim2.new(1, 0, 0, 16),
    BackgroundTransparency = 1,
    Font = Enum.Font.SourceSans,
    Text = "Strength",
    TextSize = 14,
    TextColor3 = Color3.fromRGB(160, 160, 160),
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 3,
}, strengthPage)

local strengthToggle = make("TextButton", {
    Size = UDim2.fromOffset(120, 22),
    Position = UDim2.fromOffset(0, 22),
    BackgroundColor3 = Color3.fromRGB(58, 58, 58),
    BorderSizePixel = 0,
    Font = Enum.Font.SourceSans,
    Text = "Off",
    TextSize = 15,
    TextColor3 = Color3.fromRGB(230, 230, 230),
    AutoButtonColor = false,
    ZIndex = 3,
}, strengthPage)

local function strengthSlot()
    local env
    if type(getgenv) == "function" then
        local ok, g = pcall(getgenv)
        if ok and type(g) == "table" then
            env = g
        end
    end
    if not env and type(shared) == "table" then
        env = shared
    end
    if not env then
        return { enabled = false, hooked = false }
    end
    if type(env.LT2DuperStrength) ~= "table" then
        env.LT2DuperStrength = { enabled = false, hooked = false }
    end
    return env.LT2DuperStrength
end

strengthState = strengthSlot()

if type(strengthState.characters) ~= "table" then
    strengthState.characters = setmetatable({}, { __mode = "k" })
end
local characterModels = strengthState.characters

local function watchCharacters()
    if strengthState.watching then
        return
    end
    strengthState.watching = true
    local function mark(character)
        if typeof(character) == "Instance" then
            characterModels[character] = true
        end
    end
    local function watch(plr)
        mark(plr.Character)
        plr.CharacterAdded:Connect(mark)
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        watch(plr)
    end
    Players.PlayerAdded:Connect(watch)
end

local function inCharacter(rawIndex, inst)
    local current = inst
    for _ = 1, 8 do
        if typeof(current) ~= "Instance" then
            return false
        end
        if characterModels[current] then
            return true
        end
        if type(rawIndex) ~= "function" then
            return false
        end
        local ok, parent = pcall(rawIndex, current, "Parent")
        if not ok then
            return false
        end
        current = parent
    end
    return false
end

local function installStrengthHook()
    if strengthState.hooked then
        return true
    end

    watchCharacters()

    local function spoofMass(rawIndex, self)
        return strengthState.enabled
            and typeof(self) == "Instance"
            and not inCharacter(rawIndex, self)
    end

    if type(hookmetamethod) == "function" and type(newcclosure) == "function" and type(getnamecallmethod) == "function" then
        local oldIndex
        local indexOk
        indexOk, oldIndex = pcall(function()
            local old
            old = hookmetamethod(game, "__index", newcclosure(function(self, key)
                if (key == "Mass" or key == "AssemblyMass") and spoofMass(old, self) then
                    return 1e-4
                end
                return old(self, key)
            end))
            return old
        end)
        if not indexOk then
            oldIndex = nil
        end

        local nameOk = pcall(function()
            local oldNamecall
            oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
                if getnamecallmethod() == "GetMass" and spoofMass(oldIndex, self) then
                    return 1e-4
                end
                return oldNamecall(self, ...)
            end))
        end)

        if indexOk or nameOk then
            strengthState.hooked = true
            return true
        end
    end

    if type(getrawmetatable) ~= "function" or type(setreadonly) ~= "function" or type(newcclosure) ~= "function" or type(getnamecallmethod) ~= "function" then
        return false
    end

    local ok, mt = pcall(getrawmetatable, game)
    if not ok or type(mt) ~= "table" or type(mt.__namecall) ~= "function" then
        return false
    end

    local oldNamecall = mt.__namecall
    local oldIndex = mt.__index
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        if getnamecallmethod() == "GetMass" and spoofMass(oldIndex, self) then
            return 1e-4
        end
        return oldNamecall(self, ...)
    end)
    if type(oldIndex) == "function" then
        mt.__index = newcclosure(function(self, key)
            if (key == "Mass" or key == "AssemblyMass") and spoofMass(oldIndex, self) then
                return 1e-4
            end
            return oldIndex(self, key)
        end)
    end
    setreadonly(mt, true)
    strengthState.hooked = true
    return true
end

local function styleStrengthButton(button, on)
    if on then
        button.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
        button.TextColor3 = Color3.fromRGB(18, 18, 18)
        button.Text = "On"
    else
        button.BackgroundColor3 = Color3.fromRGB(58, 58, 58)
        button.TextColor3 = Color3.fromRGB(230, 230, 230)
        button.Text = "Off"
    end
end

local function refreshStrengthToggle()
    styleStrengthButton(strengthToggle, strengthEnabled)
    styleStrengthButton(strengthSettingsBtn, strengthEnabled)
end

local function setStrength(on)
    if on then
        strengthState.enabled = true
        if not installStrengthHook() then
            strengthState.enabled = false
            strengthEnabled = false
            for _, button in ipairs({ strengthToggle, strengthSettingsBtn }) do
                button.Text = "Unavailable"
                button.BackgroundColor3 = Color3.fromRGB(58, 58, 58)
                button.TextColor3 = Color3.fromRGB(200, 80, 80)
            end
            return
        end
    else
        strengthState.enabled = false
    end
    strengthEnabled = on
    refreshStrengthToggle()
end

strengthToggle.MouseButton1Click:Connect(function()
    setStrength(not strengthEnabled)
end)

strengthSettingsBtn.MouseButton1Click:Connect(function()
    setStrength(not strengthEnabled)
end)

setStrength(strengthEnabled)

local function refreshKeyButton()
    if listeningForKey then
        keyBtn.Text = "Press a key"
        keyBtn.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
        keyBtn.TextColor3 = Color3.fromRGB(18, 18, 18)
    else
        keyBtn.Text = toggleKey.Name
        keyBtn.BackgroundColor3 = Color3.fromRGB(58, 58, 58)
        keyBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
    end
end

local function styleDashButton(button, on)
    if on then
        button.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
        button.TextColor3 = Color3.fromRGB(18, 18, 18)
    else
        button.BackgroundColor3 = Color3.fromRGB(58, 58, 58)
        button.TextColor3 = Color3.fromRGB(230, 230, 230)
    end
end

local function showDash(id)
    if currentDash == "settings" and id ~= "settings" then
        listeningForKey = false
        refreshKeyButton()
        if plotTarget.closeList then
            plotTarget.closeList()
        end
    end
    currentDash = id
    duperPage.Visible = id == "duper"
    strengthPage.Visible = id == "strength"
    settingsPage.Visible = id == "settings"
    styleDashButton(duperBtn, id == "duper")
    styleDashButton(strengthRailBtn, id == "strength")
    styleDashButton(settingsBtn, id == "settings")
    if id == "settings" then
        titleLabel.Text = "Settings"
    elseif id == "strength" then
        titleLabel.Text = "Strength"
    else
        titleLabel.Text = "Duper"
    end
end

duperBtn.MouseButton1Click:Connect(function()
    showDash("duper")
end)

strengthRailBtn.MouseButton1Click:Connect(function()
    showDash("strength")
end)

settingsBtn.MouseButton1Click:Connect(function()
    showDash("settings")
end)

keyBtn.MouseButton1Click:Connect(function()
    listeningForKey = not listeningForKey
    refreshKeyButton()
end)

local function saveConfig()
    if type(writefile) ~= "function" then
        return false, "Saving is unavailable"
    end
    if type(makefolder) == "function" and type(isfolder) == "function" and not isfolder(CONFIG_DIR) then
        local made, err = pcall(makefolder, CONFIG_DIR)
        if not made then
            return false, tostring(err)
        end
    end

    local picked = {}
    for id, on in pairs(selected) do
        if on then
            table.insert(picked, id)
        end
    end
    table.sort(picked)

    local pos = window.Position
    local payload = {
        toggleKey = toggleKey.Name,
        amount = logLimit or "unlimited",
        pilePlanks = pilePlanks,
        strength = strengthEnabled,
        player = plotTarget.name or "",
        category = currentCategoryId,
        selected = picked,
        position = {
            xScale = pos.X.Scale,
            xOffset = pos.X.Offset,
            yScale = pos.Y.Scale,
            yOffset = pos.Y.Offset,
        },
    }

    local encodedOk, encoded = pcall(function()
        return Services.HttpService:JSONEncode(payload)
    end)
    if not encodedOk then
        return false, "Could not encode settings"
    end

    local wrote, err = pcall(writefile, CONFIG_FILE, encoded)
    if not wrote then
        return false, tostring(err)
    end
    return true
end

saveBtn.MouseButton1Click:Connect(function()
    local ok = saveConfig()
    saveBtn.Text = ok and "Saved" or "Failed"
    task.delay(0.8, function()
        if saveBtn and saveBtn.Parent then
            saveBtn.Text = "Save"
        end
    end)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then
        return
    end
    if listeningForKey then
        if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Unknown then
            listeningForKey = false
            refreshKeyButton()
            return
        end
        toggleKey = input.KeyCode
        listeningForKey = false
        refreshKeyButton()
        return
    end
    if gameProcessed or UserInputService:GetFocusedTextBox() then
        return
    end
    if input.KeyCode == toggleKey and window and window.Parent then
        window.Visible = not window.Visible
    end
end)

do
    local dragging = false
    local dragStart
    local startPos

    local function beginDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = window.Position
        end
    end

    titleBar.InputBegan:Connect(beginDrag)
    sidePanel.InputBegan:Connect(beginDrag)

    local function endDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end

    titleBar.InputEnded:Connect(endDrag)
    sidePanel.InputEnded:Connect(endDrag)
    UserInputService.InputEnded:Connect(endDrag)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            window.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end
