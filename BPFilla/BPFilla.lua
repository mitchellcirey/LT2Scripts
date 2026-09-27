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
local MENU = Color3.fromRGB(32, 32, 32)
local HOVER = Color3.fromRGB(120, 120, 120)
local OUTLINE = Color3.fromRGB(74, 120, 255)

local ROW_H = 22
local BTN_W = 88
local MENU_MAX = 176
local OUTLINE_NAME = "JellBPFillaOutlines"
local LASSO_NAME = "JellBPFillaLasso"

local PROXIMITY = 10
local PRE_FIRE = 0.05
local POST_DELAY = 0.1
local FALLBACK_WAIT = 0.5
local OWNERSHIP_TIMEOUT = 1

local mounted = false
local started = false
local pageOpen = false
local clickSelect = false
local groupSelect = false
local lasso = false
local lassoDragging = false
local lassoStart = nil
local clickFill = false
local filling = false
local deleting = false
local busy = false
local runToken = 0
local fillToken = 0
local deleteToken = 0
local homeCFrame = nil

local selectedClass = nil
local allPlanks = {}
local filteredPlanks = {}
local chosen = {}
local filterMin = 1
local filterMax = 1.5
local plankIndex = 1

local connections = {}
local outlineConns = {}
local outlineFolder = nil
local worldConns = {}
local lassoGui = nil
local lassoFrame = nil
local dashWindow = nil
local root = nil
local range = nil
local fillBtn = nil
local deleteBtn = nil
local countLabel = nil
local typeButton = nil
local typeLabel = nil
local menu = nil
local menuAnchor = nil
local clickTrack = nil
local clickKnob = nil
local modeTracks = {}

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

local function typeValue(model)
    local typeVal = model and model:FindFirstChild("Type")
    if typeVal and typeVal:IsA("StringValue") then
        return typeVal.Value
    end
    return nil
end

local function isBlueprint(model)
    return model and model:IsA("Model") and isOwned(model) and typeValue(model) == "Blueprint"
        and model:FindFirstChild("PurchasedBoxItemName") == nil
end

local function isStructure(model)
    if not model or not model:IsA("Model") or not isOwned(model) then
        return false
    end
    local kind = typeValue(model)
    return kind == "Structure" or kind == "Vehicle Spot"
end

local function isSelectable(model)
    return isBlueprint(model) or isStructure(model)
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

local function paintCount()
    if countLabel and countLabel.Parent then
        countLabel.Text = tostring(#chosen)
    end
end

local function paintType()
    if not (typeLabel and typeLabel.Parent) then
        return
    end
    if selectedClass and selectedClass ~= "" then
        typeLabel.Text = selectedClass
        typeLabel.TextColor3 = TEXT
    else
        typeLabel.Text = "Select"
        typeLabel.TextColor3 = MUTED
    end
end

local function paintModes()
    local flags = {
        click = clickSelect,
        group = groupSelect,
        lasso = lasso,
    }
    for mode, widgets in pairs(modeTracks) do
        local on = flags[mode] == true
        if widgets.knob and widgets.knob.Parent then
            widgets.knob.Position = UDim2.fromOffset(on and 16 or 2, 2)
        end
        if widgets.track and widgets.track.Parent then
            widgets.track.BackgroundColor3 = on and GREEN or FIELD
        end
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

local function dropBlueprint(model)
    local index = table.find(chosen, model)
    if index then
        table.remove(chosen, index)
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
    for _, model in ipairs(chosen) do
        if model and model.Parent then
            local box = make("SelectionBox", {
                Adornee = model,
                Color3 = OUTLINE,
                LineThickness = 0.03,
                SurfaceColor3 = OUTLINE,
                SurfaceTransparency = 0.75,
            }, outlineFolder)
            table.insert(outlineConns, model.Destroying:Connect(function()
                if box.Parent then
                    box:Destroy()
                end
                dropBlueprint(model)
            end))
        end
    end
    applyOutlineVisibility()
    paintCount()
end

local function refilter()
    filteredPlanks = {}
    for _, entry in ipairs(allPlanks) do
        if entry.sizeY >= filterMin and entry.sizeY <= filterMax then
            table.insert(filteredPlanks, entry)
        end
    end
    if #filteredPlanks == 0 then
        plankIndex = 1
    else
        plankIndex = math.clamp(plankIndex, 1, #filteredPlanks)
    end
end

local function plankClasses()
    local seen = {}
    local names = {}
    local folder = playerModels()
    if not folder then
        return names
    end
    for _, model in ipairs(folder:GetChildren()) do
        if model.Name == "Plank" and model:IsA("Model") and isOwned(model) then
            local treeClass = model:FindFirstChild("TreeClass")
            if treeClass and treeClass:IsA("StringValue") and treeClass.Value ~= "" and not seen[treeClass.Value] then
                seen[treeClass.Value] = true
                table.insert(names, treeClass.Value)
            end
        end
    end
    table.sort(names)
    return names
end

local function chooseClass(className)
    selectedClass = className
    allPlanks = scanPlanks(className)
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
    refilter()
    paintType()
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

local function itemName(model)
    local named = model:FindFirstChild("ItemName")
    if named and tostring(named.Value) ~= "" then
        return tostring(named.Value)
    end
    return model.Name
end

local function toggleBlueprint(model)
    local index = table.find(chosen, model)
    if index then
        table.remove(chosen, index)
        return
    end
    table.insert(chosen, model)
end

local function selectableFromTarget(target)
    local model = resolveModel(target)
    if isSelectable(model) then
        return model
    end
    return nil
end

local function ownedSelectable()
    local result = {}
    local folder = playerModels()
    if not folder then
        return result
    end
    for _, model in ipairs(folder:GetChildren()) do
        if isSelectable(model) then
            table.insert(result, model)
        end
    end
    return result
end

local function selectClick()
    local model = selectableFromTarget(Mouse.Target)
    if not model then
        return
    end
    toggleBlueprint(model)
    drawOutlines()
end

local function selectGroup()
    local model = selectableFromTarget(Mouse.Target)
    if not model then
        return
    end
    local name = itemName(model)
    local boxed = model:FindFirstChild("PurchasedBoxItemName") ~= nil
    local structure = isStructure(model)
    for _, other in ipairs(ownedSelectable()) do
        if itemName(other) == name and isStructure(other) == structure then
            local otherBoxed = other:FindFirstChild("PurchasedBoxItemName") ~= nil
            if not structure or otherBoxed == boxed then
                toggleBlueprint(other)
            end
        end
    end
    drawOutlines()
end

local function ensureLasso()
    if lassoGui and lassoGui.Parent then
        return
    end
    local host = outlineHost()
    if not host then
        return
    end
    lassoGui = make("ScreenGui", {
        Name = LASSO_NAME,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 20,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, host)
    lassoFrame = make("Frame", {
        BackgroundColor3 = Color3.fromRGB(60, 130, 255),
        BackgroundTransparency = 0.75,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 10,
    }, lassoGui)
    make("UIStroke", {
        Color = Color3.fromRGB(120, 180, 255),
        Thickness = 1.5,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, lassoFrame)
end

local function hideLasso()
    lassoDragging = false
    lassoStart = nil
    if lassoFrame then
        lassoFrame.Visible = false
    end
end

local function updateLasso(currentPos)
    if not lassoFrame or not lassoStart then
        return
    end
    local minX = math.min(lassoStart.X, currentPos.X)
    local minY = math.min(lassoStart.Y, currentPos.Y)
    local maxX = math.max(lassoStart.X, currentPos.X)
    local maxY = math.max(lassoStart.Y, currentPos.Y)
    lassoFrame.Position = UDim2.fromOffset(minX, minY)
    lassoFrame.Size = UDim2.fromOffset(maxX - minX, maxY - minY)
    lassoFrame.Visible = true
end

local function selectLasso(startPos, endPos)
    if not startPos or not endPos then
        return
    end
    local minX = math.min(startPos.X, endPos.X)
    local minY = math.min(startPos.Y, endPos.Y)
    local maxX = math.max(startPos.X, endPos.X)
    local maxY = math.max(startPos.Y, endPos.Y)
    if (maxX - minX) < 6 or (maxY - minY) < 6 then
        return
    end
    local cam = Workspace.CurrentCamera
    if not cam then
        return
    end
    local inset = Services.GuiService:GetGuiInset()
    for _, model in ipairs(ownedSelectable()) do
        local screenPos, onScreen = cam:WorldToScreenPoint(blueprintCenter(model))
        local sx = screenPos.X + inset.X
        local sy = screenPos.Y + inset.Y
        if onScreen and screenPos.Z > 0 and sx >= minX and sx <= maxX and sy >= minY and sy <= maxY then
            toggleBlueprint(model)
        end
    end
    drawOutlines()
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
    if not isBlueprint(model) or not table.find(chosen, model) then
        return
    end
    if #filteredPlanks == 0 then
        warn("[Jell] BP Filla: No planks to place")
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
        warn("[Jell] BP Filla: No planks to place")
        return
    end
    local blueprints = {}
    for _, model in ipairs(chosen) do
        if isBlueprint(model) and model.Parent then
            table.insert(blueprints, model)
        end
    end
    if #blueprints == 0 then
        warn("[Jell] BP Filla: No blueprints selected")
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

local function paintDelete()
    if deleteBtn and deleteBtn.Parent then
        deleteBtn.Text = deleting and "Stop" or "Delete"
    end
end

local function stopDelete()
    deleteToken += 1
    deleting = false
    paintDelete()
end

local function startDelete()
    if deleting then
        stopDelete()
        return
    end
    local targets = {}
    for _, model in ipairs(chosen) do
        if model.Parent and isSelectable(model) then
            table.insert(targets, model)
        end
    end
    if #targets == 0 then
        warn("[Jell] BP Filla: Nothing selected")
        return
    end
    local interaction = ReplicatedStorage:FindFirstChild("Interaction")
    local remote = interaction and interaction:FindFirstChild("DestroyStructure")
    if not remote then
        warn("[Jell] BP Filla: DestroyStructure remote not found")
        return
    end
    deleteToken += 1
    local token = deleteToken
    deleting = true
    paintDelete()
    task.spawn(function()
        for _, item in ipairs(targets) do
            if token ~= deleteToken or not started then
                break
            end
            if item.Parent then
                local elapsed = 0
                while item.Parent and elapsed < 5 do
                    if token ~= deleteToken or not started then
                        break
                    end
                    pcall(function()
                        remote:FireServer(item)
                    end)
                    task.wait(0.05)
                    elapsed += 0.05
                end
                if item.Parent then
                    warn("[Jell] BP Filla: Timed out deleting " .. item.Name)
                end
            end
        end
        if token ~= deleteToken then
            return
        end
        local keep = {}
        for _, model in ipairs(chosen) do
            if model.Parent then
                table.insert(keep, model)
            end
        end
        chosen = keep
        deleting = false
        drawOutlines()
        paintDelete()
    end)
end

local function clicksAccepted()
    return started and mounted and pageOpen
end

local function bindWorld()
    for _, conn in ipairs(worldConns) do
        conn:Disconnect()
    end
    table.clear(worldConns)
    table.insert(worldConns, UserInputService.InputBegan:Connect(function(input, processed)
        if not clicksAccepted() then
            return
        end
        if processed or input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return
        end
        if pointerOverDash() or UserInputService:GetFocusedTextBox() then
            return
        end
        if lasso then
            ensureLasso()
            lassoDragging = true
            lassoStart = UserInputService:GetMouseLocation()
            if lassoFrame then
                lassoFrame.Size = UDim2.fromOffset(0, 0)
                lassoFrame.Visible = false
            end
            return
        end
        if groupSelect then
            selectGroup()
            return
        end
        if clickSelect then
            selectClick()
            return
        end
        if clickFill then
            onBlueprintClicked(Mouse.Target)
        end
    end))
    table.insert(worldConns, UserInputService.InputChanged:Connect(function(input)
        if not (lassoDragging and input.UserInputType == Enum.UserInputType.MouseMovement) then
            return
        end
        if not clicksAccepted() then
            hideLasso()
            return
        end
        updateLasso(UserInputService:GetMouseLocation())
    end))
    table.insert(worldConns, UserInputService.InputEnded:Connect(function(input)
        if not (lassoDragging and input.UserInputType == Enum.UserInputType.MouseButton1) then
            return
        end
        local startPos = lassoStart
        local endPos = UserInputService:GetMouseLocation()
        hideLasso()
        if clicksAccepted() then
            selectLasso(startPos, endPos)
        end
    end))
end

local function unbindWorld()
    for _, conn in ipairs(worldConns) do
        conn:Disconnect()
    end
    table.clear(worldConns)
    hideLasso()
end

local function sweepOutlines()
    for _, parent in ipairs(uiParents()) do
        local existing = parent:FindFirstChild(OUTLINE_NAME)
        if existing and existing ~= outlineFolder then
            existing:Destroy()
        end
        local lassoExisting = parent:FindFirstChild(LASSO_NAME)
        if lassoExisting and lassoExisting ~= lassoGui then
            lassoExisting:Destroy()
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

local function closeMenu()
    menuAnchor = nil
    if menu then
        menu:Destroy()
        menu = nil
    end
end

local function menuHost()
    if dashWindow and dashWindow.Parent then
        return dashWindow
    end
    return root
end

local function openTypeMenu()
    if menuAnchor == typeButton then
        closeMenu()
        return
    end
    closeMenu()
    local host = menuHost()
    if not host or not typeButton then
        return
    end
    menuAnchor = typeButton
    local names = plankClasses()
    local count = math.max(#names, 1)
    local height = math.min(count * ROW_H, MENU_MAX)
    local btnTop = typeButton.AbsolutePosition.Y - host.AbsolutePosition.Y
    local below = host.AbsoluteSize.Y - (btnTop + typeButton.AbsoluteSize.Y)
    local y = btnTop + typeButton.AbsoluteSize.Y + 2
    if below < height + 4 then
        y = math.max(0, btnTop - height - 2)
    end
    local x = typeButton.AbsolutePosition.X - host.AbsolutePosition.X
    local width = typeButton.AbsoluteSize.X

    local backdrop = make("TextButton", {
        Name = "TypeMenuBackdrop",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 20,
    }, host)
    menu = backdrop
    backdrop.MouseButton1Click:Connect(function()
        task.defer(closeMenu)
    end)

    local list = make("ScrollingFrame", {
        Size = UDim2.fromOffset(width, height),
        Position = UDim2.fromOffset(x, y),
        BackgroundColor3 = MENU,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = STROKE,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Active = true,
        ZIndex = 21,
    }, backdrop)
    make("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, list)

    local rows = {}
    for _, name in ipairs(names) do
        table.insert(rows, name)
    end
    if #rows == 0 then
        table.insert(rows, nil)
    end
    for index, name in ipairs(rows) do
        local picked = name ~= nil and name == selectedClass
        local row = make("TextButton", {
            Size = UDim2.new(1, 0, 0, ROW_H),
            BackgroundColor3 = FIELD,
            BackgroundTransparency = picked and 0 or 1,
            BorderSizePixel = 0,
            Font = Enum.Font.SourceSans,
            Text = name or "None",
            TextSize = 15,
            TextColor3 = name and TEXT or MUTED,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false,
            LayoutOrder = index,
            Active = name ~= nil,
            ZIndex = 22,
        }, list)
        make("UIPadding", {
            PaddingLeft = UDim.new(0, 6),
        }, row)
        row.MouseEnter:Connect(function()
            if not name then
                return
            end
            row.BackgroundColor3 = HOVER
            row.BackgroundTransparency = 0
        end)
        row.MouseLeave:Connect(function()
            row.BackgroundColor3 = FIELD
            row.BackgroundTransparency = picked and 0 or 1
        end)
        row.MouseButton1Click:Connect(function()
            if not name then
                return
            end
            chooseClass(name)
            task.defer(closeMenu)
        end)
    end
end

local function setMode(mode, on)
    if on then
        clickSelect = mode == "click"
        groupSelect = mode == "group"
        lasso = mode == "lasso"
        if mode ~= "lasso" then
            hideLasso()
        end
    elseif mode == "click" then
        clickSelect = false
    elseif mode == "group" then
        groupSelect = false
    elseif mode == "lasso" then
        lasso = false
        hideLasso()
    end
    paintModes()
end

local function modeRow(parent, labelText, mode, order)
    local row = make("Frame", {
        Size = UDim2.new(1, 0, 0, ROW_H),
        BackgroundTransparency = 1,
        LayoutOrder = order,
    }, parent)
    make("TextLabel", {
        Size = UDim2.new(1, -40, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = labelText,
        TextSize = 15,
        TextColor3 = LABEL,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)
    local track = make("TextButton", {
        Size = UDim2.fromOffset(28, 14),
        Position = UDim2.new(1, -28, 0.5, -7),
        BackgroundColor3 = FIELD,
        Text = "",
        AutoButtonColor = false,
    }, row)
    make("UICorner", { CornerRadius = UDim.new(1, 0) }, track)
    local knob = make("Frame", {
        Size = UDim2.fromOffset(10, 10),
        Position = UDim2.fromOffset(2, 2),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
    }, track)
    make("UICorner", { CornerRadius = UDim.new(1, 0) }, knob)
    modeTracks[mode] = { track = track, knob = knob }
    track.MouseButton1Click:Connect(function()
        if not started then
            return
        end
        local enabled = (mode == "click" and clickSelect) or (mode == "group" and groupSelect) or (mode == "lasso" and lasso)
        setMode(mode, not enabled)
    end)
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

    local typeBlock = make("Frame", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundTransparency = 1,
        LayoutOrder = 2,
    }, list)
    make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = "Plank type",
        TextSize = 15,
        TextColor3 = LABEL,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, typeBlock)
    typeButton = make("TextButton", {
        Size = UDim2.new(1, 0, 0, ROW_H),
        Position = UDim2.fromOffset(0, 20),
        BackgroundColor3 = FIELD,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    }, typeBlock)
    typeLabel = make("TextLabel", {
        Size = UDim2.new(1, -22, 1, 0),
        Position = UDim2.fromOffset(6, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = "Select",
        TextSize = 15,
        TextColor3 = MUTED,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, typeButton)
    make("TextLabel", {
        Size = UDim2.fromOffset(16, ROW_H),
        Position = UDim2.new(1, -16, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = "v",
        TextSize = 14,
        TextColor3 = MUTED,
    }, typeButton)
    typeButton.MouseButton1Click:Connect(function()
        openTypeMenu()
    end)

    local countRow = make("Frame", {
        Size = UDim2.new(1, 0, 0, ROW_H),
        BackgroundTransparency = 1,
        LayoutOrder = 8,
    }, list)
    make("TextLabel", {
        Size = UDim2.new(1, -40, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = "Selected",
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

    range = rangeRow(list, "Y size", 3, 0, 10, filterMin, filterMax, function(low, high)
        filterMin = low
        filterMax = high
        if #allPlanks == 0 then
            return
        end
        refilter()
    end)

    modeRow(list, "Click selection", "click", 4)
    modeRow(list, "Group selection", "group", 5)
    modeRow(list, "Lasso", "lasso", 6)
    local clearBtn = actionRow(list, "Clear selection", "Clear", 7)
    clearBtn.MouseButton1Click:Connect(function()
        chosen = {}
        plankIndex = 1
        drawOutlines()
    end)

    heading(list, "Plank fill", 9)
    local clickRow = make("Frame", {
        Size = UDim2.new(1, 0, 0, ROW_H),
        BackgroundTransparency = 1,
        LayoutOrder = 10,
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
        if not clickFill and #chosen == 0 then
            warn("[Jell] BP Filla: Select blueprints first")
            clickFill = false
            paintClick()
            return
        end
        clickFill = not clickFill
        paintClick()
    end)

    fillBtn = actionRow(list, "Fill all blueprints", "Start", 11)
    fillBtn.MouseButton1Click:Connect(function()
        if not started then
            return
        end
        startFill()
    end)

    heading(list, "Deletion", 12)
    deleteBtn = actionRow(list, "Delete selection", "Delete", 13)
    deleteBtn.MouseButton1Click:Connect(function()
        if not started then
            return
        end
        startDelete()
    end)

    paintType()
    paintModes()
    paintFill()
    paintDelete()
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
    clickSelect = false
    groupSelect = false
    lasso = false
    clickFill = false
    stopDelete()
    closeMenu()
    hideLasso()
    if lassoGui then
        lassoGui:Destroy()
        lassoGui = nil
        lassoFrame = nil
    end
    stopFill()
    unbindWorld()
    selectedClass = nil
    allPlanks = {}
    filteredPlanks = {}
    chosen = {}
    filterMin = 1
    filterMax = 1.5
    plankIndex = 1
    clearOutlines()
    if range then
        range.setBounds(0, 10)
        range.set(filterMin, filterMax)
    end
    paintType()
    paintModes()
    paintClick()
    paintCount()
end

function api.setPageOpen(open)
    pageOpen = open == true
    applyOutlineVisibility()
    if not pageOpen then
        hideLasso()
    end
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
    closeMenu()
    hideLasso()
    disconnectAll()
    if root then
        root:Destroy()
        root = nil
    end
    range = nil
    fillBtn = nil
    deleteBtn = nil
    countLabel = nil
    typeButton = nil
    typeLabel = nil
    clickTrack = nil
    clickKnob = nil
    table.clear(modeTracks)
end

return api
