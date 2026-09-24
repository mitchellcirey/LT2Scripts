local Services = setmetatable({}, {
    __index = function(self, index)
        return game:GetService(index)
    end,
})

local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local Workspace = Services.Workspace
local UserInputService = Services.UserInputService
local ContextActionService = Services.ContextActionService

local Player = Players.LocalPlayer
local RemoteProxy = ReplicatedStorage:WaitForChild("Interaction"):WaitForChild("RemoteProxy")

local CLICK_ACTION = "LT2ChopperClickSelect"
local FIRE_CAP = 4000
local HITS_PER_SECTION = 30
local CUT_MARGIN = 1
local ADOPT_RANGE = 48

local AXE_STATS = {
    BasicHatchet = { damage = 0.2, cooldown = 0.65 },
    Axe1 = { damage = 0.55, cooldown = 0.73 },
    Axe2 = { damage = 0.93, cooldown = 0.7 },
    Axe3 = { damage = 1.45, cooldown = 0.65 },
    AxeAlphaTesters = { damage = 1.5, cooldown = 0.5 },
    AxeBetaTesters = { damage = 1.45, cooldown = 0.54 },
    AxePig = { damage = 1.5, cooldown = 0.5 },
    AxeChicken = { damage = 0.9, cooldown = 0.3 },
    AxeSwamp = { damage = 0.8, cooldown = 0.55 },
    AxeAmber = { damage = 3.39, cooldown = 1 },
    AxeTwitter = { damage = 1.65, cooldown = 0.4 },
    AxePie = { damage = 0.95, cooldown = 0.3 },
    RustyAxe = { damage = 0.55, cooldown = 0.4 },
    Rukiryaxe = { damage = 1.68, cooldown = 0.4 },
    FireAxe = { damage = 0.6, cooldown = 0.55 },
    IceAxe = { damage = 0.36, cooldown = 0.4 },
    SilverAxe = { damage = 1.6, cooldown = 0.48 },
    CaveAxe = { damage = 0.4, cooldown = 0.4 },
    Beesaxe = { damage = 1.4, cooldown = 0.5 },
    GingerbreadAxe = { damage = 1.2, cooldown = 0.5 },
    ManyAxe = { damage = 10.2, cooldown = 1.9 },
    CandyCornAxe = { damage = 1.75, cooldown = 0.6 },
    EndTimesAxe = { damage = 1.58, cooldown = 0.4 },
    BluesteelAxe = { damage = 2.8, cooldown = 0.8 },
    MintAxe = { damage = 0.8, cooldown = 5 },
    RefinedAxe = { damage = 0, cooldown = 0.6, processed = 12, processedCooldown = 0.6 },
}

local started = false
local mounted = false
local abort = false
local busy = false
local dashWindow
local screenGui
local guiCleanupHooked = false
local selectedTree
local trees = {}
local rows = {}
local setStatus = function() end
local rebuildRows = function() end
local applyHighlight = function() end
local bindClickSelect = function() end
local highlight
local selectConn

local cachedLands = {}

local function prettyName(raw)
    return (tostring(raw):gsub("(%l)(%u)", "%1 %2"):gsub("_", " "))
end

local function isStopped()
    return (not started) or abort or not (screenGui and screenGui.Parent)
end

local function playerRoot()
    local char = Player.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function ownsModel(model)
    if not model or model == Player or model == Player.Character then
        return false
    end
    local owner = model:FindFirstChild("Owner")
    if not (owner and owner:IsA("ValueBase")) then
        return false
    end
    local value = owner.Value
    if value == Player or value == Player.Name or value == Player.UserId or value == tostring(Player.UserId) then
        return true
    end
    if typeof(value) == "Instance" then
        return value:IsA("Player") and value.UserId == Player.UserId
    end
    if type(value) == "string" then
        local lower = string.lower(value)
        return lower == string.lower(Player.Name) or lower == string.lower(Player.DisplayName)
    end
    if type(value) == "number" then
        return value == Player.UserId
    end
    return false
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
    return mn >= 25 and mx <= 2000
end

local function isPlotModel(inst)
    local properties = Workspace:FindFirstChild("Properties")
    return properties ~= nil and inst.Parent == properties
end

local function updateLandCache()
    table.clear(cachedLands)
    local properties = Workspace:FindFirstChild("Properties")
    if not properties then
        return
    end
    for _, child in ipairs(properties:GetChildren()) do
        if ownsModel(child) then
            for _, part in ipairs(child:GetChildren()) do
                if part:IsA("BasePart") and isLandPart(part) then
                    table.insert(cachedLands, part)
                end
            end
        end
    end
end

local function positionOnLand(pos)
    for _, part in ipairs(cachedLands) do
        if part.Parent then
            local localPos = part.CFrame:PointToObjectSpace(pos)
            local half = part.Size * 0.5
            if math.abs(localPos.X) <= half.X + 3
                and math.abs(localPos.Z) <= half.Z + 3
                and localPos.Y >= -half.Y - 10
                and localPos.Y <= half.Y + 80
            then
                return true
            end
        end
    end
    return false
end

local function footprintOnLand(cf, size)
    if typeof(cf) ~= "CFrame" or typeof(size) ~= "Vector3" then
        return false
    end
    local half = size * 0.5
    for _, x in ipairs({ -half.X, 0, half.X }) do
        for _, y in ipairs({ -half.Y, 0, half.Y }) do
            for _, z in ipairs({ -half.Z, 0, half.Z }) do
                if positionOnLand(cf:PointToWorldSpace(Vector3.new(x, y, z))) then
                    return true
                end
            end
        end
    end
    return false
end

local function dragTarget(model)
    if model:IsA("BasePart") then
        return model
    end
    return model:FindFirstChild("Main")
        or model:FindFirstChild("WoodSection")
        or model:FindFirstChildWhichIsA("BasePart")
        or model:FindFirstChildWhichIsA("BasePart", true)
end

local function overlapsLand(inst)
    if inst:IsA("BasePart") then
        return footprintOnLand(inst.CFrame, inst.Size)
    end
    local target = dragTarget(inst)
    if target and footprintOnLand(target.CFrame, target.Size) then
        return true
    end
    if inst:IsA("Model") then
        local ok, cf, size = pcall(function()
            return inst:GetBoundingBox()
        end)
        if ok and footprintOnLand(cf, size) then
            return true
        end
    end
    return false
end

local function onPlayerPlot(inst)
    if not inst or inst == Player or inst == Player.Character or isPlotModel(inst) then
        return false
    end
    local properties = Workspace:FindFirstChild("Properties")
    if properties then
        local current = inst
        while current and current ~= properties and current ~= Workspace do
            if current.Parent == properties then
                return ownsModel(current)
            end
            current = current.Parent
        end
    end
    local target = dragTarget(inst)
    if not target then
        return false
    end
    return overlapsLand(inst)
end

local function eachSection(model, callback)
    for _, child in ipairs(model:GetChildren()) do
        if child.Name == "WoodSection" and child:IsA("BasePart") and child:FindFirstChild("ID") then
            callback(child)
        end
    end
end

local function sectionCount(model)
    local count = 0
    if model then
        eachSection(model, function()
            count += 1
        end)
    end
    return count
end

local function isTreeModel(model)
    if not (model and model:IsA("Model")) then
        return false
    end
    if model.Name == "Plank" or model.Name == "PropertySoldSign" then
        return false
    end
    local treeClass = model:FindFirstChild("TreeClass")
    if not (treeClass and treeClass:IsA("StringValue")) then
        return false
    end
    if tostring(treeClass.Value) == "Sign" then
        return false
    end
    if not model:FindFirstChild("CutEvent") then
        return false
    end
    return sectionCount(model) >= 2
end

local function treeLabel(model)
    local treeClass = model and model:FindFirstChild("TreeClass")
    local name = treeClass and prettyName(treeClass.Value) or "Tree"
    return name .. " (" .. sectionCount(model) .. ")"
end

local function modelPoint(model)
    local section = model:FindFirstChild("WoodSection")
    if section and section:IsA("BasePart") then
        return section.Position
    end
    local ok, cf = pcall(function()
        return model:GetPivot()
    end)
    if ok and typeof(cf) == "CFrame" then
        return cf.Position
    end
    return nil
end

local function findTrees()
    updateLandCache()
    local found = {}
    local seen = {}
    local root = playerRoot()
    local origin = root and root.Position or Vector3.zero
    for _, inst in ipairs(Workspace:GetDescendants()) do
        if inst.Name == "TreeClass" and inst:IsA("StringValue") then
            local model = inst.Parent
            if model and not seen[model] and isTreeModel(model) and onPlayerPlot(model) then
                seen[model] = true
                local pos = modelPoint(model)
                table.insert(found, {
                    model = model,
                    label = treeLabel(model),
                    distance = pos and (pos - origin).Magnitude or 1e9,
                })
            end
        end
    end
    table.sort(found, function(a, b)
        if a.distance ~= b.distance then
            return a.distance < b.distance
        end
        return a.label < b.label
    end)
    return found
end

local function treeFromPart(part)
    local current = part
    while current and current ~= Workspace do
        if isTreeModel(current) then
            updateLandCache()
            if onPlayerPlot(current) then
                return current
            end
            return nil
        end
        current = current.Parent
    end
    return nil
end

local function childCount(section)
    local ids = section:FindFirstChild("ChildIDs")
    if not ids then
        return 0
    end
    local count = 0
    for _, child in ipairs(ids:GetChildren()) do
        if child.Name == "Child" then
            count += 1
        end
    end
    return count
end

local function axeStats(toolName)
    local known = AXE_STATS[toolName]
    if known then
        return known
    end
    if type(decompile) ~= "function" then
        return nil
    end
    local classes = ReplicatedStorage:FindFirstChild("AxeClasses")
    local class = classes and classes:FindFirstChild("AxeClass_" .. toolName)
    if not class then
        return nil
    end
    local ok, src = pcall(decompile, class)
    if not ok or type(src) ~= "string" then
        return nil
    end
    local damage = tonumber(string.match(src, "Damage%s*=%s*([%d%.%-]+)"))
    local cooldown = tonumber(string.match(src, "SwingCooldown%s*=%s*([%d%.%-]+)"))
    if not damage or not cooldown then
        return nil
    end
    local stats = {
        damage = damage,
        cooldown = cooldown,
    }
    AXE_STATS[toolName] = stats
    return stats
end

local function eachTool(callback)
    local containers = { Player:FindFirstChild("Backpack"), Player.Character }
    for _, container in ipairs(containers) do
        if container then
            for _, child in ipairs(container:GetChildren()) do
                if child:IsA("Tool") then
                    callback(child)
                end
            end
        end
    end
end

local function bestAxe(tree)
    local models = Workspace:FindFirstChild("PlayerModels")
    local processed = models ~= nil and tree:IsDescendantOf(models)
    local bestTool, bestDamage, bestCooldown
    eachTool(function(tool)
        local toolName = tool:FindFirstChild("ToolName")
        local cutting = tool:FindFirstChild("CuttingTool")
        if not (toolName and toolName:IsA("StringValue")) then
            return
        end
        if cutting and cutting:IsA("BoolValue") and not cutting.Value then
            return
        end
        local stats = axeStats(toolName.Value)
        if not stats then
            return
        end
        local damage = stats.damage
        local cooldown = stats.cooldown
        if processed and stats.processed and stats.processed > damage then
            damage = stats.processed
            cooldown = stats.processedCooldown or cooldown
        end
        if damage > 0 and (not bestDamage or damage > bestDamage) then
            bestTool = tool
            bestDamage = damage
            bestCooldown = cooldown
        end
    end)
    return bestTool, bestDamage, bestCooldown
end

local function equip(tool)
    local char = Player.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return false
    end
    if tool.Parent ~= char then
        humanoid:EquipTool(tool)
    end
    local deadline = tick() + 1
    while tool.Parent ~= char and tick() < deadline do
        if isStopped() then
            return false
        end
        task.wait(0.05)
    end
    return tool.Parent == char
end

local function waitFor(seconds)
    local deadline = tick() + seconds
    while tick() < deadline do
        if isStopped() then
            return false
        end
        task.wait(0.05)
    end
    return true
end

local function sawmillLength()
    local info = ReplicatedStorage:FindFirstChild("ClientItemInfo")
    local models = Workspace:FindFirstChild("PlayerModels")
    local best = 0
    if info and models then
        for _, model in ipairs(models:GetChildren()) do
            if string.sub(model.Name, 1, 7) == "Sawmill" and ownsModel(model) then
                local item = info:FindFirstChild(model.Name)
                local other = item and item:FindFirstChild("OtherInfo")
                local length = other and other:FindFirstChild("MaxLogLength")
                if length and length:IsA("NumberValue") and length.Value > best then
                    best = length.Value
                end
            end
        end
    end
    if best <= 0 then
        return 10
    end
    return best
end

local function cutHeight(section, maxLength, used)
    local length = section.Size.Y
    if length <= CUT_MARGIN * 2 then
        return nil
    end
    if length > maxLength then
        return math.clamp(maxLength - 0.15, CUT_MARGIN, length - CUT_MARGIN)
    end
    if childCount(section) > 0 then
        local inset = CUT_MARGIN
        if (used or 0) >= 8 then
            inset = math.max(CUT_MARGIN, math.min(length * 0.2, 3))
        end
        return math.clamp(length - inset, CUT_MARGIN, length - CUT_MARGIN)
    end
    return nil
end

local function pieceFits(model, maxLength)
    local total = 0
    local count = 0
    local tooLong = false
    eachSection(model, function(section)
        count += 1
        if section.Size.Y > maxLength + 0.05 then
            tooLong = true
        end
        total += section.Size.Y
    end)
    if count == 0 then
        return true
    end
    if tooLong then
        return false
    end
    return total <= maxLength + 0.05
end

local function isChopTarget(model)
    if not (model and model:IsA("Model") and model.Parent) then
        return false
    end
    if model.Name == "Plank" or model.Name == "PropertySoldSign" then
        return false
    end
    local treeClass = model:FindFirstChild("TreeClass")
    if not (treeClass and treeClass:IsA("StringValue")) then
        return false
    end
    if tostring(treeClass.Value) == "Sign" then
        return false
    end
    if not model:FindFirstChild("CutEvent") then
        return false
    end
    return sectionCount(model) >= 1
end

local function pieceSignature(model)
    local parts = {}
    eachSection(model, function(section)
        local id = section:FindFirstChild("ID")
        table.insert(parts, string.format("%s:%.2f:%d", id and id.Value or "?", section.Size.Y, childCount(section)))
    end)
    table.sort(parts)
    return table.concat(parts, "|")
end

local function fireChop(model, section, tool, damage, height)
    local cut = model:FindFirstChild("CutEvent")
    local id = section:FindFirstChild("ID")
    if not (cut and id) or not height or height <= 0 then
        return false
    end
    local ok = pcall(function()
        RemoteProxy:FireServer(cut, {
            cuttingClass = "Axe",
            sectionId = id.Value,
            faceVector = Vector3.new(0, 0, -1),
            height = height,
            hitPoints = damage,
            cooldown = 0,
            tool = tool,
        })
    end)
    return ok
end

local function chopWave(model, tool, damage, maxLength, hitsById, hits)
    local sections = {}
    eachSection(model, function(section)
        if cutHeight(section, maxLength) then
            table.insert(sections, section)
        end
    end)
    table.sort(sections, function(a, b)
        return childCount(a) > childCount(b)
    end)
    local fired = 0
    for _, section in ipairs(sections) do
        if isStopped() or hits.count >= FIRE_CAP then
            break
        end
        local idValue = section:FindFirstChild("ID")
        if section.Parent and idValue then
            local id = idValue.Value
            local used = hitsById[id] or 0
            local height = cutHeight(section, maxLength, used)
            if used < HITS_PER_SECTION and height and fireChop(model, section, tool, damage, height) then
                hitsById[id] = used + 1
                hits.count += 1
                fired += 1
            end
        end
    end
    return fired
end

local function chopModel(model, tool, damage, maxLength, hitsById, hits)
    local stall = 0
    while isChopTarget(model) and not pieceFits(model, maxLength) do
        if isStopped() or hits.count >= FIRE_CAP then
            return false
        end
        local before = pieceSignature(model)
        local fired = chopWave(model, tool, damage, maxLength, hitsById, hits)
        if fired == 0 then
            return true
        end
        if not waitFor(0.05) then
            return false
        end
        local after = model.Parent and pieceSignature(model) or ""
        if after ~= before then
            stall = 0
        else
            stall += 1
            if stall >= 40 then
                return pieceFits(model, maxLength)
            end
        end
    end
    return true
end

local function chopTree(tree)
    updateLandCache()
    if not onPlayerPlot(tree) then
        setStatus("Not on your plot")
        return
    end
    local tool, damage = bestAxe(tree)
    if not tool then
        setStatus("Need an axe")
        return
    end
    if not equip(tool) then
        setStatus("Need an axe")
        return
    end
    local maxLength = sawmillLength()
    local origin = modelPoint(tree) or Vector3.zero
    local className = tostring(tree.TreeClass.Value)
    local label = treeLabel(tree)
    setStatus("Chopping " .. label)
    print("[Chopper] " .. label)

    local spawned = {}
    local conn = Workspace.DescendantAdded:Connect(function(inst)
        if inst:IsA("Model") then
            table.insert(spawned, inst)
        end
    end)
    local seen = {}
    for _, entry in ipairs(trees) do
        seen[entry.model] = true
    end
    seen[tree] = true
    local hitsById = {}
    local hits = { count = 0 }
    local finished = true

    local function takePiece(inst)
        if seen[inst] or not isChopTarget(inst) or pieceFits(inst, maxLength) or not onPlayerPlot(inst) then
            return false
        end
        local treeClass = inst:FindFirstChild("TreeClass")
        if not (treeClass and tostring(treeClass.Value) == className) then
            return false
        end
        local name = inst.Name
        if name ~= "Model" and string.sub(name, 1, 6) ~= "Loose_" then
            return false
        end
        local pos = modelPoint(inst)
        if not pos or (pos - origin).Magnitude > ADOPT_RANGE then
            return false
        end
        seen[inst] = true
        return true
    end

    local ok, err = xpcall(function()
        local pending = { tree }
        local index = 1
        while index <= #pending do
            if isStopped() or hits.count >= FIRE_CAP then
                finished = false
                break
            end
            local model = pending[index]
            index += 1
            if isChopTarget(model) and not pieceFits(model, maxLength) and (model == tree or onPlayerPlot(model)) then
                local modelDone = chopModel(model, tool, damage, maxLength, hitsById, hits)
                if isStopped() then
                    finished = false
                    break
                end
                if not modelDone and isChopTarget(model) and not pieceFits(model, maxLength) then
                    finished = false
                end
            end
            for _, inst in ipairs(spawned) do
                if takePiece(inst) then
                    table.insert(pending, inst)
                end
            end
        end
        if finished and not isStopped() and hits.count < FIRE_CAP and waitFor(0.3) then
            for _, inst in ipairs(spawned) do
                if takePiece(inst) then
                    local modelDone = chopModel(inst, tool, damage, maxLength, hitsById, hits)
                    if isStopped() or hits.count >= FIRE_CAP then
                        finished = false
                        break
                    end
                    if not modelDone and isChopTarget(inst) and not pieceFits(inst, maxLength) then
                        finished = false
                    end
                end
            end
        end
    end, debug.traceback)

    conn:Disconnect()

    if isStopped() then
        setStatus("Stopped")
    elseif not ok then
        setStatus("Error")
        warn("[Chopper] " .. tostring(err))
    elseif not finished or hits.count >= FIRE_CAP then
        setStatus("Unfinished")
    else
        setStatus("Done")
    end
end

local function takeCtx(ctx)
    if type(ctx) ~= "table" then
        return
    end
    if ctx.window then
        dashWindow = ctx.window
    end
    if ctx.screenGui then
        screenGui = ctx.screenGui
    end
end

local function watchSelection()
    if selectConn then
        selectConn:Disconnect()
        selectConn = nil
    end
    local model = selectedTree
    if not model then
        return
    end
    selectConn = model.AncestryChanged:Connect(function()
        if selectedTree == model and not model:IsDescendantOf(Workspace) then
            selectedTree = nil
            applyHighlight()
            rebuildRows()
            if not busy then
                setStatus("Select a tree")
            end
        end
    end)
end

local function pointerOverWindow()
    if not (dashWindow and dashWindow.Visible and dashWindow.Parent) then
        return false
    end
    local mousePos = UserInputService:GetMouseLocation()
    local gui = dashWindow:FindFirstAncestorWhichIsA("ScreenGui")
    local x, y = mousePos.X, mousePos.Y
    if not (gui and gui.IgnoreGuiInset) then
        local inset = Services.GuiService:GetGuiInset()
        x -= inset.X
        y -= inset.Y
    end
    local pos = dashWindow.AbsolutePosition
    local size = dashWindow.AbsoluteSize
    return x >= pos.X and x <= pos.X + size.X
        and y >= pos.Y and y <= pos.Y + size.Y
end

local function paintRows()
    for _, row in ipairs(rows) do
        local alive, parent = pcall(function()
            return row.model.Parent
        end)
        local on = alive and parent ~= nil and row.model == selectedTree
        row.button.Font = on and Enum.Font.SourceSansBold or Enum.Font.SourceSans
        row.button.TextColor3 = on and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(210, 210, 210)
        row.button.BackgroundTransparency = on and 0 or 1
    end
end

local function buildInterface(parent, ctx)
    local function make(className, props, parentInst)
        local inst = Instance.new(className)
        for key, value in pairs(props) do
            inst[key] = value
        end
        inst.Parent = parentInst
        return inst
    end

    takeCtx(ctx)

    if not guiCleanupHooked and screenGui then
        guiCleanupHooked = true
        screenGui.Destroying:Connect(function()
            started = false
            abort = true
            ContextActionService:UnbindAction(CLICK_ACTION)
            if highlight then
                highlight:Destroy()
                highlight = nil
            end
        end)
    end

    local root = make("Frame", {
        Name = "ChopperRoot",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
    }, parent)

    local page = make("Frame", {
        Size = UDim2.new(1, -16, 1, -16),
        Position = UDim2.fromOffset(8, 8),
        BackgroundTransparency = 1,
    }, root)

    local list = make("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, -52),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Color3.fromRGB(90, 90, 90),
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
    }, page)
    make("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
    }, list)

    local refreshBtn = make("TextButton", {
        Size = UDim2.new(0.5, -2, 0, 22),
        Position = UDim2.new(0, 0, 1, -40),
        BackgroundColor3 = Color3.fromRGB(58, 58, 58),
        BorderSizePixel = 0,
        Font = Enum.Font.SourceSans,
        Text = "Refresh",
        TextSize = 15,
        TextColor3 = Color3.fromRGB(230, 230, 230),
        AutoButtonColor = false,
    }, page)

    local chopBtn = make("TextButton", {
        Size = UDim2.new(0.5, -2, 0, 22),
        Position = UDim2.new(0.5, 2, 1, -40),
        BackgroundColor3 = Color3.fromRGB(230, 230, 230),
        BorderSizePixel = 0,
        Font = Enum.Font.SourceSans,
        Text = "Chop",
        TextSize = 15,
        TextColor3 = Color3.fromRGB(18, 18, 18),
        AutoButtonColor = false,
    }, page)

    local statusLabel = make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 1, -14),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = "Select a tree",
        TextSize = 14,
        TextColor3 = Color3.fromRGB(120, 120, 120),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, page)

    setStatus = function(text)
        if statusLabel and statusLabel.Parent then
            statusLabel.Text = text
        end
    end

    applyHighlight = function()
        local show = mounted and selectedTree and selectedTree.Parent and screenGui and screenGui.Parent
        if not show then
            if highlight then
                highlight.Adornee = nil
                highlight.Enabled = false
            end
            return
        end
        if not highlight then
            highlight = make("Highlight", {
                Name = "ChopperHighlight",
                FillColor = Color3.fromRGB(0, 255, 255),
                OutlineColor = Color3.fromRGB(0, 255, 255),
                FillTransparency = 0.75,
                OutlineTransparency = 0,
                DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
            }, screenGui)
        end
        highlight.Adornee = selectedTree
        highlight.Enabled = true
    end

    rebuildRows = function()
        table.clear(rows)
        for _, child in ipairs(list:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        for index, entry in ipairs(trees) do
            local button = make("TextButton", {
                Size = UDim2.new(1, 0, 0, 22),
                BackgroundColor3 = Color3.fromRGB(48, 48, 48),
                BorderSizePixel = 0,
                Font = Enum.Font.SourceSans,
                Text = entry.label,
                TextSize = 15,
                TextColor3 = Color3.fromRGB(210, 210, 210),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                AutoButtonColor = false,
                LayoutOrder = index,
            }, list)
            make("UIPadding", {
                PaddingLeft = UDim.new(0, 6),
            }, button)
            local model = entry.model
            button.MouseButton1Click:Connect(function()
                if busy then
                    return
                end
                if selectedTree == model then
                    selectedTree = nil
                    setStatus(#trees == 0 and "No trees on your plot" or "Select a tree")
                else
                    selectedTree = model
                    setStatus(entry.label)
                end
                watchSelection()
                paintRows()
                applyHighlight()
            end)
            table.insert(rows, {
                button = button,
                model = model,
            })
        end
        paintRows()
    end

    local function refreshList(keepStatus)
        local previous = selectedTree
        trees = findTrees()
        local still = false
        for _, entry in ipairs(trees) do
            if entry.model == previous then
                still = true
                break
            end
        end
        if not still then
            selectedTree = nil
        end
        rebuildRows()
        watchSelection()
        applyHighlight()
        if keepStatus or busy then
            return
        end
        if selectedTree then
            setStatus(treeLabel(selectedTree))
        elseif #trees == 0 then
            setStatus("No trees on your plot")
        else
            setStatus("Select a tree")
        end
    end

    local function runChop()
        if busy then
            return
        end
        if not started then
            setStatus("Stopped")
            return
        end
        local tree = selectedTree
        if not (tree and tree.Parent and isTreeModel(tree)) then
            setStatus("Select a tree")
            return
        end
        busy = true
        abort = false
        chopBtn.Text = "..."
        local ok, err = xpcall(chopTree, debug.traceback, tree)
        busy = false
        if chopBtn and chopBtn.Parent then
            chopBtn.Text = "Chop"
        end
        if not ok then
            setStatus("Error")
            warn("[Chopper] " .. tostring(err))
        end
        if mounted then
            pcall(refreshList, true)
        end
    end

    refreshBtn.MouseButton1Click:Connect(function()
        if busy then
            return
        end
        refreshList()
    end)

    chopBtn.MouseButton1Click:Connect(function()
        task.spawn(runChop)
    end)

    local function onClickSelect(_, state)
        if state ~= Enum.UserInputState.Begin or not started or busy then
            return Enum.ContextActionResult.Pass
        end
        if not (dashWindow and dashWindow.Visible) then
            return Enum.ContextActionResult.Pass
        end
        if pointerOverWindow() or UserInputService:GetFocusedTextBox() then
            return Enum.ContextActionResult.Pass
        end
        local target = Player:GetMouse().Target
        local model = target and treeFromPart(target)
        if not model then
            return Enum.ContextActionResult.Pass
        end
        selectedTree = model
        local listed = false
        for _, entry in ipairs(trees) do
            if entry.model == model then
                listed = true
                break
            end
        end
        if listed then
            rebuildRows()
            watchSelection()
            applyHighlight()
            setStatus(treeLabel(model))
        else
            refreshList()
        end
        return Enum.ContextActionResult.Sink
    end

    bindClickSelect = function()
        ContextActionService:UnbindAction(CLICK_ACTION)
        if not started then
            return
        end
        ContextActionService:BindActionAtPriority(
            CLICK_ACTION,
            onClickSelect,
            false,
            Enum.ContextActionPriority.High.Value,
            Enum.UserInputType.MouseButton1
        )
    end

    refreshList()
end

local api = {}

function api.start(ctx)
    takeCtx(ctx)
    started = true
    abort = false
    bindClickSelect()
    applyHighlight()
end

function api.stop()
    started = false
    abort = true
    ContextActionService:UnbindAction(CLICK_ACTION)
end

function api.mount(parent, ctx)
    if mounted then
        api.unmount()
    end
    buildInterface(parent, ctx)
    mounted = true
    bindClickSelect()
    applyHighlight()
end

function api.unmount()
    mounted = false
    if selectConn then
        selectConn:Disconnect()
        selectConn = nil
    end
    if highlight then
        highlight:Destroy()
        highlight = nil
    end
    ContextActionService:UnbindAction(CLICK_ACTION)
end

return api
