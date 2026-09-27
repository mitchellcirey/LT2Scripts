local Services = setmetatable({}, {
    __index = function(_, index)
        return game:GetService(index)
    end,
})

local Players = Services.Players
local UserInputService = Services.UserInputService
local Workspace = Services.Workspace
local ReplicatedStorage = Services.ReplicatedStorage
local RunService = Services.RunService

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local TEXT = Color3.fromRGB(230, 230, 230)
local MUTED = Color3.fromRGB(160, 160, 160)
local DARK = Color3.fromRGB(18, 18, 18)
local BUTTON = Color3.fromRGB(230, 230, 230)
local FIELD = Color3.fromRGB(58, 58, 58)
local LABEL = Color3.fromRGB(210, 210, 210)
local GREEN = Color3.fromRGB(70, 190, 105)
local STROKE = Color3.fromRGB(70, 70, 70)
local OUTLINE = Color3.fromRGB(74, 120, 255)

local ROW_H = 22
local BTN_W = 88
local OUTLINE_NAME = "JellBPFillaOutlines"

local PROXIMITY = 10
local PRE_FIRE = 0.05
local POST_DELAY = 0.1
local FALLBACK_WAIT = 0.5
local OWNERSHIP_TIMEOUT = 1

local mounted = false
local started = false
local pageOpen = false
local picking = false
local clickFill = false
local filling = false
local busy = false
local runToken = 0
local fillToken = 0
local homeCFrame = nil

local selectedClass = nil
local allPlanks = {}
local filteredPlanks = {}
local filterMin = 1
local filterMax = 1.5
local plankIndex = 1

local connections = {}
local outlineConns = {}
local outlineFolder = nil
local worldConn = nil
local dashWindow = nil
local root = nil
local range = nil
local selectBtn = nil
local fillBtn = nil
local countLabel = nil
local clickTrack = nil
local clickKnob = nil

local function make(className, props, parent)
    local inst = Instance.new(className)
    for key, value in pairs(props) do
        inst[key] = value
    end
    inst.Parent = parent
    return inst
end

local function connect(signal, fn)
    local conn = signal:Connect(fn)
    table.insert(connections, conn)
    return conn
end

local function disconnectAll()
    for _, conn in ipairs(connections) do
        conn:Disconnect()
    end
    table.clear(connections)
end

local function uiParents()
    local list = {}
    local ok, hui = pcall(function()
        return gethui()
    end)
    if ok and hui then
        table.insert(list, hui)
    end
    local coreOk, coreGui = pcall(function()
        return Services.CoreGui
    end)
    if coreOk and coreGui then
        table.insert(list, coreGui)
    end
    local playerGui = Player:FindFirstChild("PlayerGui")
    if playerGui then
        table.insert(list, playerGui)
    end
    return list
end

local function outlineHost()
    local parents = uiParents()
    return parents[1]
end

local function currentRoot()
    local character = Player.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function dragRemote()
    local interaction = ReplicatedStorage:FindFirstChild("Interaction")
    return interaction and interaction:FindFirstChild("ClientIsDragging")
end

local function roundSize(value)
    return math.floor(value * 10 + 0.5) / 10
end

local function formatSize(value)
    local rounded = roundSize(value)
    if math.abs(rounded - math.floor(rounded + 0.001)) < 0.001 then
        return tostring(math.floor(rounded + 0.001))
    end
    return string.format("%.1f", rounded)
end

local function covers(guiObject, x, y)
    if not (guiObject and guiObject.Parent) then
        return false
    end
    if guiObject:IsA("GuiObject") and not guiObject.Visible then
        return false
    end
    local pos = guiObject.AbsolutePosition
    local size = guiObject.AbsoluteSize
    return x >= pos.X and x <= pos.X + size.X and y >= pos.Y and y <= pos.Y + size.Y
end

local function pointerOverDash()
    if not (dashWindow and dashWindow.Parent and dashWindow.Visible) then
        return false
    end
    local mouse = UserInputService:GetMouseLocation()
    local inset = Services.GuiService:GetGuiInset()
    local points = {
        mouse,
        Vector2.new(mouse.X - inset.X, mouse.Y - inset.Y),
        Vector2.new(mouse.X + inset.X, mouse.Y + inset.Y),
    }
    for _, point in ipairs(points) do
        if covers(dashWindow, point.X, point.Y) then
            return true
        end
    end
    return false
end

local function isOwned(model)
    local owner = model:FindFirstChild("Owner")
    if not owner then
        return false
    end
    local ownerString = owner:FindFirstChild("OwnerString")
    return ownerString and ownerString:IsA("StringValue") and ownerString.Value == Player.Name
end

local function playerModels()
    return Workspace:FindFirstChild("PlayerModels")
end

local function resolveModel(target)
    local folder = playerModels()
    if not folder or not target then
        return nil
    end
    local current = target
    while current and current.Parent ~= folder do
        current = current.Parent
        if not current or current == Workspace then
            return nil
        end
    end
    if current and current:IsA("Model") then
        return current
    end
    return nil
end

local function isBlueprint(model)
    if not model or not model:IsA("Model") or not isOwned(model) then
        return false
    end
    local typeVal = model:FindFirstChild("Type")
    return typeVal and typeVal:IsA("StringValue") and typeVal.Value == "Blueprint"
end

local function blueprintCenter(model)
    if model.PrimaryPart then
        return model.PrimaryPart.Position
    end
    local sum = Vector3.zero
    local count = 0
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            sum += part.Position
            count += 1
        end
    end
    if count > 0 then
        return sum / count
    end
    return Vector3.zero
end

local function scanPlanks(className)
    local result = {}
    local folder = playerModels()
    if not folder or not className then
        return result
    end
    for _, model in ipairs(folder:GetChildren()) do
        if model.Name == "Plank" and model:IsA("Model") and isOwned(model) then
            local treeClass = model:FindFirstChild("TreeClass")
            if treeClass and treeClass:IsA("StringValue") and treeClass.Value == className then
                local part = model:FindFirstChild("Main") or model:FindFirstChildWhichIsA("BasePart")
                if part and part:IsA("BasePart") then
                    table.insert(result, {
                        model = model,
                        part = part,
                        sizeY = roundSize(part.Size.Y),
                    })
                end
            end
        end
    end
    return result
end

local function ownedBlueprints()
    local result = {}
    local folder = playerModels()
    if not folder then
        return result
    end
    for _, model in ipairs(folder:GetChildren()) do
        if isBlueprint(model) then
            table.insert(result, model)
        end
    end
    return result
end

local function paintCount()
    if countLabel and countLabel.Parent then
        countLabel.Text = tostring(#filteredPlanks)
    end
end

local function paintSelect()
    if selectBtn and selectBtn.Parent then
        selectBtn.Text = picking and "Picking" or "Start"
    end
end

local function paintFill()
    if fillBtn and fillBtn.Parent then
        fillBtn.Text = filling and "Stop" or "Start"
    end
end

local function paintClick()
    if not (clickTrack and clickTrack.Parent and clickKnob) then
        return
    end
    clickKnob.Position = UDim2.fromOffset(clickFill and 16 or 2, 2)
    clickTrack.BackgroundColor3 = clickFill and GREEN or FIELD
end

local function applyOutlineVisibility()
    if not outlineFolder then
        return
    end
    outlineFolder.Parent = pageOpen and outlineHost() or nil
end

local function clearOutlines()
    for _, conn in ipairs(outlineConns) do
        conn:Disconnect()
    end
    table.clear(outlineConns)
    if outlineFolder then
        outlineFolder:Destroy()
        outlineFolder = nil
    end
end

local function dropPlank(part)
    for index, entry in ipairs(filteredPlanks) do
        if entry.part == part then
            table.remove(filteredPlanks, index)
            break
        end
    end
    for index, entry in ipairs(allPlanks) do
        if entry.part == part then
            table.remove(allPlanks, index)
            break
        end
    end
    if #filteredPlanks == 0 then
        plankIndex = 1
    else
        plankIndex = math.clamp(plankIndex, 1, #filteredPlanks)
    end
    paintCount()
end

local function drawOutlines()
    clearOutlines()
    local host = outlineHost()
    if not host then
        return
    end
    outlineFolder = make("Folder", {
        Name = OUTLINE_NAME,
    })
    for _, entry in ipairs(filteredPlanks) do
        if entry.part and entry.part.Parent then
            local box = make("SelectionBox", {
                Adornee = entry.part,
                Color3 = OUTLINE,
                LineThickness = 0.03,
                SurfaceColor3 = OUTLINE,
                SurfaceTransparency = 0.75,
            }, outlineFolder)
            local part = entry.part
            table.insert(outlineConns, part.Destroying:Connect(function()
                if box.Parent then
                    box:Destroy()
                end
                dropPlank(part)
            end))
        end
    end
    applyOutlineVisibility()
    paintCount()
end

local function applyFilter()
    filteredPlanks = {}
    for _, entry in ipairs(allPlanks) do
        if entry.sizeY >= filterMin and entry.sizeY <= filterMax then
            table.insert(filteredPlanks, entry)
        end
    end
    plankIndex = 1
    drawOutlines()
end

local function dynamicDelay()
    local samples = {}
    local last = Workspace.DistributedGameTime
    for _ = 1, 5 do
        RunService.Heartbeat:Wait()
        local now = Workspace.DistributedGameTime
        if now ~= last then
            table.insert(samples, now - last)
            last = now
        end
    end
    if #samples == 0 then
        return 0.5
    end
    local sum = 0
    for _, value in ipairs(samples) do
        sum += value
    end
    return math.clamp((sum / #samples) * 20, 0.5, 1)
end

local function findLastInteraction(model)
    local ownerFolder = model:FindFirstChild("Owner")
    if ownerFolder then
        local nested = ownerFolder:FindFirstChild("LastInteraction")
        if nested then
            return nested
        end
    end
    return model:FindFirstChild("LastInteraction")
end

local function aborted(token)
    return token ~= runToken or not started
end

local function teleportSingle(target, goalCF, rootPart, token)
    if aborted(token) or not target or not target.Parent or not rootPart then
        return
    end
    local remote = dragRemote()
    if not remote then
        warn("[Jell] BP Filla: Drag remote missing")
        return
    end
    local model = target:FindFirstAncestorOfClass("Model") or target.Parent
    local lastInteracted = findLastInteraction(model)
    local flat = (rootPart.Position - target.Position) * Vector3.new(1, 0, 1)
    if flat.Magnitude > PROXIMITY then
        rootPart.CFrame = CFrame.new(target.Position + Vector3.new(0, 3, 0))
    end
    if aborted(token) then
        return
    end

    local ownerFolder = model:FindFirstChild("Owner")
    local ownerString = ownerFolder and ownerFolder:FindFirstChild("OwnerString")
    if ownerString and ownerString.Value ~= Player.Name then
        local baseDelay = dynamicDelay()
        for attempt = 1, 5 do
            if aborted(token) then
                return
            end
            local deadline = tick() + (baseDelay * attempt)
            while tick() < deadline do
                if aborted(token) then
                    return
                end
                pcall(function()
                    remote:FireServer(model)
                end)
                task.wait()
            end
            if not aborted(token) and target.Parent then
                target.CFrame = goalCF
            end
            task.wait(0.2)
            if target.Parent and (target.Position - goalCF.Position).Magnitude < 2 then
                break
            end
        end
        task.wait(POST_DELAY)
        return
    end

    task.wait(PRE_FIRE)
    if aborted(token) then
        return
    end

    if lastInteracted then
        local thread = coroutine.running()
        local fired = false
        local conn = lastInteracted:GetPropertyChangedSignal("Value"):Connect(function()
            if not fired then
                fired = true
                task.spawn(thread)
            end
        end)
        local fireLoop = task.spawn(function()
            local deadline = tick() + OWNERSHIP_TIMEOUT
            while not fired and tick() < deadline do
                if aborted(token) then
                    break
                end
                pcall(function()
                    remote:FireServer(model)
                end)
                task.wait()
            end
            if not fired then
                fired = true
                task.spawn(thread)
            end
        end)
        coroutine.yield()
        conn:Disconnect()
        pcall(task.cancel, fireLoop)
    else
        local deadline = tick() + FALLBACK_WAIT
        while tick() < deadline do
            if aborted(token) then
                return
            end
            local ok = pcall(function()
                remote:FireServer(model)
            end)
            if not ok then
                break
            end
            task.wait()
        end
    end

    if not aborted(token) and target.Parent then
        target.CFrame = goalCF
    end
    task.wait(POST_DELAY)
end

local function teleportObject(part, goalCF, returnHome)
    local token = runToken
    if busy or not started or not part or not part.Parent then
        return false
    end
    local rootPart = currentRoot()
    if not rootPart then
        warn("[Jell] BP Filla: No character")
        return false
    end
    busy = true
    local saved = rootPart.CFrame
    homeCFrame = saved
    pcall(teleportSingle, part, goalCF, rootPart, token)
    if token ~= runToken then
        busy = false
        return false
    end
    if returnHome and rootPart.Parent then
        rootPart.CFrame = saved
    end
    homeCFrame = nil
    busy = false
    return true
end

local function stopPicking()
    picking = false
    paintSelect()
end

local function onPlankPicked(target)
    local model = resolveModel(target)
    if not model or model.Name ~= "Plank" or not isOwned(model) then
        stopPicking()
        return
    end
    local treeClass = model:FindFirstChild("TreeClass")
    if not treeClass or not treeClass:IsA("StringValue") or treeClass.Value == "" then
        stopPicking()
        return
    end
    selectedClass = treeClass.Value
    allPlanks = scanPlanks(selectedClass)
    local yMin, yMax = 0, 0
    if #allPlanks > 0 then
        yMin, yMax = math.huge, -math.huge
        for _, entry in ipairs(allPlanks) do
            yMin = math.min(yMin, entry.sizeY)
            yMax = math.max(yMax, entry.sizeY)
        end
        filterMin = yMin
        filterMax = yMax
    else
        filterMin = 0
        filterMax = 0
    end
    if range then
        range.setBounds(0, math.max(10, yMax))
        range.set(filterMin, filterMax)
    end
    applyFilter()
    stopPicking()
end

local function nextPlank()
    if #filteredPlanks == 0 then
        return nil
    end
    local entry = filteredPlanks[plankIndex]
    plankIndex = (plankIndex % #filteredPlanks) + 1
    if not entry or not entry.part or not entry.part.Parent then
        return nil
    end
    return entry
end

local function onBlueprintClicked(target)
    local model = resolveModel(target)
    if not isBlueprint(model) then
        return
    end
    if #filteredPlanks == 0 then
        warn("[Jell] BP Filla: No filtered planks to place")
        return
    end
    if busy or filling then
        warn("[Jell] BP Filla: Busy")
        return
    end
    local entry = nextPlank()
    if not entry then
        return
    end
    local goal = CFrame.new(blueprintCenter(model))
    task.spawn(teleportObject, entry.part, goal, true)
end

local function stopFill()
    fillToken += 1
    filling = false
    runToken += 1
    local rootPart = currentRoot()
    if homeCFrame and rootPart then
        rootPart.CFrame = homeCFrame
    end
    homeCFrame = nil
    busy = false
    paintFill()
end

local function startFill()
    if filling then
        stopFill()
        return
    end
    if busy then
        warn("[Jell] BP Filla: Busy")
        return
    end
    if #filteredPlanks == 0 then
        warn("[Jell] BP Filla: No filtered planks selected")
        return
    end
    local blueprints = ownedBlueprints()
    if #blueprints == 0 then
        warn("[Jell] BP Filla: No owned blueprints found")
        return
    end
    fillToken += 1
    local token = fillToken
    filling = true
    paintFill()
    task.spawn(function()
        for index, blueprint in ipairs(blueprints) do
            if token ~= fillToken or not started then
                break
            end
            local entry = filteredPlanks[((index - 1) % #filteredPlanks) + 1]
            if entry and entry.part and entry.part.Parent and blueprint.Parent then
                teleportObject(entry.part, CFrame.new(blueprintCenter(blueprint)), true)
            end
            if token ~= fillToken or not started then
                break
            end
            task.wait(0.05)
        end
        if token == fillToken then
            filling = false
            paintFill()
        end
    end)
end

local function clicksAccepted()
    return started and mounted and pageOpen
end

local function bindWorld()
    if worldConn then
        worldConn:Disconnect()
    end
    worldConn = UserInputService.InputBegan:Connect(function(input, processed)
        if not clicksAccepted() then
            return
        end
        if processed or input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return
        end
        if pointerOverDash() or UserInputService:GetFocusedTextBox() then
            return
        end
        if picking then
            onPlankPicked(Mouse.Target)
            return
        end
        if clickFill then
            onBlueprintClicked(Mouse.Target)
        end
    end)
end

local function unbindWorld()
    if worldConn then
        worldConn:Disconnect()
        worldConn = nil
    end
end

local function sweepOutlines()
    for _, parent in ipairs(uiParents()) do
        local existing = parent:FindFirstChild(OUTLINE_NAME)
        if existing and existing ~= outlineFolder then
            existing:Destroy()
        end
    end
end

local function heading(parent, text, order)
    local row = make("Frame", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        LayoutOrder = order,
    }, parent)
    local label = make("TextLabel", {
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = string.upper(text),
        TextSize = 15,
        TextColor3 = TEXT,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)
    local line = make("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = STROKE,
        BorderSizePixel = 0,
    }, row)
    local function place()
        local gap = label.AbsoluteSize.X + 8
        line.Position = UDim2.new(0, gap, 0.5, 0)
        line.Size = UDim2.new(1, -gap, 0, 1)
    end
    label:GetPropertyChangedSignal("AbsoluteSize"):Connect(place)
    task.defer(place)
end

local function actionRow(parent, labelText, buttonText, order)
    local row = make("Frame", {
        Size = UDim2.new(1, 0, 0, ROW_H),
        BackgroundTransparency = 1,
        LayoutOrder = order,
    }, parent)
    make("TextLabel", {
        Size = UDim2.new(1, -(BTN_W + 8), 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = labelText,
        TextSize = 15,
        TextColor3 = LABEL,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, row)
    return make("TextButton", {
        Size = UDim2.fromOffset(BTN_W, ROW_H),
        Position = UDim2.new(1, -BTN_W, 0, 0),
        BackgroundColor3 = BUTTON,
        BorderSizePixel = 0,
        Font = Enum.Font.SourceSans,
        Text = buttonText,
        TextSize = 15,
        TextColor3 = DARK,
        AutoButtonColor = false,
    }, row)
end

local function rangeRow(parent, labelText, order, boundsMin, boundsMax, startLow, startHigh, onChange)
    local minValue = boundsMin
    local maxValue = math.max(boundsMax, boundsMin + 0.1)
    local low = startLow
    local high = startHigh
    local dragging = nil

    local row = make("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        LayoutOrder = order,
    }, parent)
    make("TextLabel", {
        Size = UDim2.new(1, -88, 0, 16),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = labelText,
        TextSize = 15,
        TextColor3 = LABEL,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)
    local valueLabel = make("TextLabel", {
        Size = UDim2.fromOffset(80, 16),
        Position = UDim2.new(1, -80, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = "",
        TextSize = 15,
        TextColor3 = TEXT,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, row)
    local hit = make("TextButton", {
        Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.fromOffset(0, 18),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
    }, row)
    local track = make("Frame", {
        Size = UDim2.new(1, 0, 0, 4),
        Position = UDim2.new(0, 0, 0.5, -2),
        BackgroundColor3 = FIELD,
        BorderSizePixel = 0,
    }, hit)
    local fill = make("Frame", {
        BackgroundColor3 = BUTTON,
        BorderSizePixel = 0,
    }, track)
    local function knob()
        local handle = make("Frame", {
            Size = UDim2.fromOffset(10, 10),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = BUTTON,
            BorderSizePixel = 0,
            ZIndex = 2,
        }, track)
        make("UICorner", { CornerRadius = UDim.new(1, 0) }, handle)
        return handle
    end
    local knobLow = knob()
    local knobHigh = knob()

    local function paint()
        local span = maxValue - minValue
        local lowPct = math.clamp((low - minValue) / span, 0, 1)
        local highPct = math.clamp((high - minValue) / span, 0, 1)
        fill.Position = UDim2.new(lowPct, 0, 0, 0)
        fill.Size = UDim2.new(math.max(highPct - lowPct, 0), 0, 1, 0)
        knobLow.Position = UDim2.new(lowPct, 0, 0.5, 0)
        knobHigh.Position = UDim2.new(highPct, 0, 0.5, 0)
        valueLabel.Text = formatSize(low) .. " — " .. formatSize(high)
    end

    local function pointerAlpha()
        local width = track.AbsoluteSize.X
        if width <= 0 then
            return 0
        end
        local x = UserInputService:GetMouseLocation().X
        local gui = track:FindFirstAncestorWhichIsA("ScreenGui")
        if not (gui and gui.IgnoreGuiInset) then
            x -= Services.GuiService:GetGuiInset().X
        end
        return math.clamp((x - track.AbsolutePosition.X) / width, 0, 1)
    end

    local function applyPointer()
        local value = roundSize(minValue + (maxValue - minValue) * pointerAlpha())
        if dragging == "low" then
            low = math.clamp(value, minValue, high)
        else
            high = math.clamp(value, low, maxValue)
        end
        paint()
        onChange(low, high)
    end

    hit.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return
        end
        local alpha = pointerAlpha()
        local span = maxValue - minValue
        local lowPct = (low - minValue) / span
        local highPct = (high - minValue) / span
        if math.abs(alpha - lowPct) <= math.abs(alpha - highPct) then
            dragging = "low"
        else
            dragging = "high"
        end
        applyPointer()
    end)
    connect(UserInputService.InputChanged, function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            applyPointer()
        end
    end)
    connect(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = nil
        end
    end)
    paint()

    return {
        setBounds = function(nextMin, nextMax)
            minValue = nextMin
            maxValue = math.max(nextMax, nextMin + 0.1)
            low = math.clamp(low, minValue, maxValue)
            high = math.clamp(high, low, maxValue)
            paint()
        end,
        set = function(nextLow, nextHigh)
            low = math.clamp(roundSize(nextLow), minValue, maxValue)
            high = math.clamp(roundSize(nextHigh), minValue, maxValue)
            if low > high then
                low, high = high, low
            end
            paint()
        end,
    }
end

local function build(parent)
    root = make("ScrollingFrame", {
        Name = "BPFillaRoot",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = STROKE,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
    }, parent)
    local list = make("Frame", {
        Size = UDim2.new(1, -16, 0, 0),
        Position = UDim2.fromOffset(8, 8),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
    }, root)
    make("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
    }, list)
    make("UIPadding", {
        PaddingBottom = UDim.new(0, 12),
    }, list)

    heading(list, "Selection", 1)
    selectBtn = actionRow(list, "Select plank type", "Start", 2)
    selectBtn.MouseButton1Click:Connect(function()
        if not started then
            return
        end
        picking = not picking
        paintSelect()
    end)

    local countRow = make("Frame", {
        Size = UDim2.new(1, 0, 0, ROW_H),
        BackgroundTransparency = 1,
        LayoutOrder = 3,
    }, list)
    make("TextLabel", {
        Size = UDim2.new(1, -40, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = "Planks",
        TextSize = 15,
        TextColor3 = LABEL,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, countRow)
    countLabel = make("TextLabel", {
        Size = UDim2.fromOffset(36, ROW_H),
        Position = UDim2.new(1, -36, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = "0",
        TextSize = 15,
        TextColor3 = TEXT,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, countRow)

    range = rangeRow(list, "Y size", 4, 0, 10, filterMin, filterMax, function(low, high)
        filterMin = low
        filterMax = high
        if #allPlanks == 0 then
            return
        end
        applyFilter()
    end)

    heading(list, "Plank fill", 5)
    local clickRow = make("Frame", {
        Size = UDim2.new(1, 0, 0, ROW_H),
        BackgroundTransparency = 1,
        LayoutOrder = 6,
    }, list)
    make("TextLabel", {
        Size = UDim2.new(1, -40, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = "Click to fill",
        TextSize = 15,
        TextColor3 = LABEL,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, clickRow)
    clickTrack = make("TextButton", {
        Size = UDim2.fromOffset(28, 14),
        Position = UDim2.new(1, -28, 0.5, -7),
        BackgroundColor3 = FIELD,
        Text = "",
        AutoButtonColor = false,
    }, clickRow)
    make("UICorner", { CornerRadius = UDim.new(1, 0) }, clickTrack)
    clickKnob = make("Frame", {
        Size = UDim2.fromOffset(10, 10),
        Position = UDim2.fromOffset(2, 2),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
    }, clickTrack)
    make("UICorner", { CornerRadius = UDim.new(1, 0) }, clickKnob)
    clickTrack.MouseButton1Click:Connect(function()
        if not started then
            return
        end
        if not clickFill and #filteredPlanks == 0 then
            warn("[Jell] BP Filla: Select and filter planks first")
            clickFill = false
            paintClick()
            return
        end
        clickFill = not clickFill
        paintClick()
    end)

    fillBtn = actionRow(list, "Fill all blueprints", "Start", 7)
    fillBtn.MouseButton1Click:Connect(function()
        if not started then
            return
        end
        startFill()
    end)

    paintSelect()
    paintFill()
    paintClick()
    paintCount()
end

local api = {}

function api.start(ctx)
    if type(ctx) == "table" and ctx.window then
        dashWindow = ctx.window
    end
    if started then
        return
    end
    started = true
    sweepOutlines()
    bindWorld()
end

function api.stop()
    started = false
    picking = false
    clickFill = false
    stopFill()
    unbindWorld()
    selectedClass = nil
    allPlanks = {}
    filteredPlanks = {}
    filterMin = 1
    filterMax = 1.5
    plankIndex = 1
    clearOutlines()
    if range then
        range.setBounds(0, 10)
        range.set(filterMin, filterMax)
    end
    paintSelect()
    paintClick()
    paintCount()
end

function api.setPageOpen(open)
    pageOpen = open == true
    applyOutlineVisibility()
end

function api.mount(parent, ctx)
    if type(ctx) == "table" and ctx.window then
        dashWindow = ctx.window
    end
    if mounted then
        api.unmount()
    end
    build(parent)
    mounted = true
end

function api.unmount()
    mounted = false
    disconnectAll()
    if root then
        root:Destroy()
        root = nil
    end
    range = nil
    selectBtn = nil
    fillBtn = nil
    countLabel = nil
    clickTrack = nil
    clickKnob = nil
end

return api
