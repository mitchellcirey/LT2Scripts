local Services = setmetatable({}, {
    __index = function(_, index)
        return game:GetService(index)
    end,
})

local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local RunService = Services.RunService
local UserInputService = Services.UserInputService
local Workspace = Services.Workspace

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local ClientIsDragging = ReplicatedStorage:WaitForChild("Interaction"):WaitForChild("ClientIsDragging")

local CONFIG_DIR = "LT2Scripts"
local CONFIG_FILE = CONFIG_DIR .. "/organizer.json"

local TEXT = Color3.fromRGB(230, 230, 230)
local MUTED = Color3.fromRGB(160, 160, 160)
local DIM = Color3.fromRGB(110, 110, 110)
local RED = Color3.fromRGB(210, 70, 70)
local DARK = Color3.fromRGB(18, 18, 18)
local BUTTON = Color3.fromRGB(230, 230, 230)
local FIELD = Color3.fromRGB(58, 58, 58)
local TRACK = Color3.fromRGB(40, 40, 40)
local GREEN = Color3.fromRGB(70, 190, 105)
local WHITE = Color3.fromRGB(255, 255, 255)

local TOGGLE_W = 28
local TOGGLE_H = 14
local TOGGLE_KNOB = 10
local TOGGLE_PAD = 2

local PROXIMITY = 10
local PRE_FIRE = 0.05
local POST_DELAY = 0.1
local FALLBACK_WAIT = 0.5
local SELECT_COLOR = Color3.fromRGB(74, 120, 255)

local stackX = 5
local stackY = 1
local stackZ = 2
local padding = 0.1
local keepSelected = false
local returnToOrigin = true
local matchPlankSize = true
local ownershipTimeout = 1
local rotateXKey = Enum.KeyCode.R
local rotateYKey = Enum.KeyCode.T

local selected = {}
local boxes = {}
local previewParts = {}
local previewBoxes = {}
local clickSelect = false
local groupSelect = false
local lasso = false
local lassoDragging = false
local lassoStart = nil
local stackMode = false
local itemRotation = CFrame.new()
local busy = false
local selecting = false
local batchCancelled = false
local runToken = 0
local homeCFrame = nil
local started = false
local mounted = false
local bound = false
local capturing = nil
local statusText = "0 selected"

local dashWindow = nil
local overlay = nil
local lassoFrame = nil
local previewConn = nil
local conns = {}
local dragConns = {}
local root = nil
local ui = {}
local toggleKnobs = {}

local function make(className, props, parent)
    local inst = Instance.new(className)
    for key, value in pairs(props) do
        inst[key] = value
    end
    inst.Parent = parent
    return inst
end

local function uiParent()
    local ok, hui = pcall(gethui)
    if ok and hui then
        return hui
    end
    local coreOk, coreGui = pcall(function()
        return Services.CoreGui
    end)
    if coreOk and coreGui then
        return coreGui
    end
    return Player:FindFirstChild("PlayerGui") or Player:WaitForChild("PlayerGui")
end

local function camera()
    return Workspace.CurrentCamera
end

local function currentRoot()
    local character = Player.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function track(conn)
    table.insert(conns, conn)
    return conn
end

local function disconnectDrag()
    for _, conn in ipairs(dragConns) do
        conn:Disconnect()
    end
    dragConns = {}
end

local function keyFromName(name, fallback)
    if type(name) ~= "string" then
        return fallback
    end
    local ok, code = pcall(function()
        return Enum.KeyCode[name]
    end)
    if ok and typeof(code) == "EnumItem" then
        return code
    end
    return fallback
end

local function saveConfig()
    if type(writefile) ~= "function" then
        return
    end
    if type(makefolder) == "function" and type(isfolder) == "function" and not isfolder(CONFIG_DIR) then
        pcall(makefolder, CONFIG_DIR)
    end
    local payload = {
        stackX = stackX,
        stackY = stackY,
        stackZ = stackZ,
        padding = padding,
        keepSelected = keepSelected,
        returnToOrigin = returnToOrigin,
        matchPlankSize = matchPlankSize,
        ownershipTimeout = ownershipTimeout,
        rotateX = rotateXKey.Name,
        rotateY = rotateYKey.Name,
    }
    local encodedOk, encoded = pcall(function()
        return Services.HttpService:JSONEncode(payload)
    end)
    if encodedOk then
        pcall(writefile, CONFIG_FILE, encoded)
    end
end

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

local function applySaved(data)
    if type(data) ~= "table" then
        return
    end
    local savedX = tonumber(data.stackX)
    local savedY = tonumber(data.stackY)
    local savedZ = tonumber(data.stackZ)
    local savedPad = tonumber(data.padding)
    local savedTimeout = tonumber(data.ownershipTimeout)
    if savedX then
        stackX = math.clamp(math.floor(savedX + 0.5), 1, 40)
    end
    if savedY then
        stackY = math.clamp(math.floor(savedY + 0.5), 1, 20)
    end
    if savedZ then
        stackZ = math.clamp(math.floor(savedZ + 0.5), 1, 40)
    end
    if savedPad then
        padding = math.clamp(math.floor(savedPad * 100 + 0.5) / 100, 0, 1)
    end
    if savedTimeout then
        ownershipTimeout = math.clamp(math.floor(savedTimeout + 0.5), 1, 6)
    end
    if type(data.keepSelected) == "boolean" then
        keepSelected = data.keepSelected
    end
    if type(data.returnToOrigin) == "boolean" then
        returnToOrigin = data.returnToOrigin
    end
    if type(data.matchPlankSize) == "boolean" then
        matchPlankSize = data.matchPlankSize
    end
    rotateXKey = keyFromName(data.rotateX, rotateXKey)
    rotateYKey = keyFromName(data.rotateY, rotateYKey)
end

applySaved(readSavedConfig())

local function liveSelected()
    local list = {}
    for _, obj in ipairs(selected) do
        if obj and obj.Parent then
            table.insert(list, obj)
        end
    end
    return list
end

local function itemName(model)
    if not model then
        return nil
    end
    local value = model:FindFirstChild("ItemName")
    if value and value.Value ~= "" then
        return value.Value
    end
    return model.Name
end

local function ownerIdentity(model)
    if not model then
        return nil
    end
    local ownerValue = model:FindFirstChild("Owner")
    if not ownerValue then
        return nil
    end
    local val = ownerValue.Value
    if typeof(val) == "Instance" and val:IsA("Player") then
        return val.Name
    end
    return tostring(val)
end

local function modelSignature(model)
    local mainPart = model:FindFirstChild("Main") or model:FindFirstChildWhichIsA("BasePart")
    local mainClass = mainPart and mainPart.ClassName or "nil"
    local childKeys = {}
    for _, child in ipairs(model:GetChildren()) do
        if child.Name ~= "Type" then
            table.insert(childKeys, child.ClassName .. ":" .. child.Name)
        end
    end
    table.sort(childKeys)
    return mainClass .. "|" .. table.concat(childKeys, ",")
end

local function treeClass(model)
    local value = model and model:FindFirstChild("TreeClass")
    return value and tostring(value.Value) or nil
end

local function mainSizeY(model)
    local main = model:FindFirstChild("Main") or model:FindFirstChildWhichIsA("BasePart")
    if not main then
        return nil
    end
    return math.round(main.Size.Y * 100) / 100
end

local function getObjectData(target)
    if not target or not target:IsA("BasePart") or target.Anchored then
        return nil
    end
    if Player.Character and target:IsDescendantOf(Player.Character) then
        return nil
    end
    local current = target.Parent
    while current and current ~= Workspace do
        if current:IsA("Model") then
            local typeVal = current:FindFirstChild("Type")
            if typeVal and (typeVal.Value == "Vehicle" or typeVal.Value == "Structure")
                and not current:FindFirstChild("PurchasedBoxItemName") then
                return nil
            end
        end
        current = current.Parent
    end
    local model = target:FindFirstAncestorOfClass("Model")
    local main = (model and model:FindFirstChild("Main")) or target
    if main:IsA("BasePart") and not main.Anchored then
        return main, model
    end
    return nil
end

local function sameType()
    local list = liveSelected()
    if #list == 0 then
        return false
    end
    local refName, refSig, refTree, refSize
    for _, obj in ipairs(list) do
        local model = obj:FindFirstAncestorOfClass("Model")
        local name = model and itemName(model) or obj.Name
        local sig = model and modelSignature(model) or (obj.ClassName .. ":" .. obj.Name)
        local wood = model and treeClass(model) or nil
        local sizeY = model and mainSizeY(model) or nil
        if not refName then
            refName = name
            refSig = sig
            refTree = wood
            refSize = sizeY
        elseif name ~= refName or sig ~= refSig or wood ~= refTree then
            return false
        elseif sizeY ~= nil and refSize ~= nil and matchPlankSize and math.abs(sizeY - refSize) > 1 then
            return false
        end
    end
    return true
end

local function paintToggle(button, on)
    local knob = button and toggleKnobs[button]
    if not (button and button.Parent and knob) then
        return
    end
    local knobX = on and (TOGGLE_W - TOGGLE_KNOB - TOGGLE_PAD) or TOGGLE_PAD
    knob.Position = UDim2.fromOffset(knobX, (TOGGLE_H - TOGGLE_KNOB) / 2)
    button.BackgroundColor3 = on and GREEN or FIELD
end

local function paintAction(button, idleText, active, enabled)
    if not (button and button.Parent) then
        return
    end
    button.Active = enabled
    button.AutoButtonColor = false
    if not enabled then
        button.Text = idleText
        button.BackgroundColor3 = FIELD
        button.TextColor3 = DIM
        return
    end
    if active then
        button.Text = "Stop"
        button.BackgroundColor3 = RED
        button.TextColor3 = WHITE
    else
        button.Text = idleText
        button.BackgroundColor3 = BUTTON
        button.TextColor3 = DARK
    end
end

local function paintKey(button, keyName)
    if not (button and button.Parent) then
        return
    end
    local armed = capturing == button:GetAttribute("Bind")
    button.Text = keyName
    if armed then
        button.BackgroundColor3 = BUTTON
        button.TextColor3 = DARK
    else
        button.BackgroundColor3 = FIELD
        button.TextColor3 = TEXT
    end
end

local function setStatus(text)
    statusText = text
    if ui.status and ui.status.Parent then
        ui.status.Text = text
    end
end

local function slidersLocked()
    return busy or stackMode
end

local function paintSlider(fill, label, caption, value, minValue, maxValue, text, locked)
    if label and label.Parent then
        label.Text = caption .. "  " .. text
        label.TextColor3 = locked and DIM or MUTED
    end
    if fill and fill.Parent then
        local span = maxValue - minValue
        local alpha = span == 0 and 1 or (value - minValue) / span
        fill.Size = UDim2.new(math.clamp(alpha, 0, 1), 0, 1, 0)
    end
end

local function paint()
    paintToggle(ui.click, clickSelect)
    paintToggle(ui.group, groupSelect)
    paintToggle(ui.lasso, lasso)
    local count = #liveSelected()
    local teleportOn = busy
    local sortOn = busy or stackMode
    paintAction(ui.teleport, "Start", teleportOn, busy or count > 0)
    paintAction(ui.sort, "Start", sortOn, busy or stackMode or sameType())
    paintAction(ui.clear, "Clear", false, true)
    local locked = slidersLocked()
    paintSlider(ui.xFill, ui.xLabel, "X", stackX, 1, 40, tostring(stackX), locked)
    paintSlider(ui.yFill, ui.yLabel, "Y", stackY, 1, 20, tostring(stackY), locked)
    paintSlider(ui.zFill, ui.zLabel, "Z", stackZ, 1, 40, tostring(stackZ), locked)
    paintSlider(ui.padFill, ui.padLabel, "Padding", padding, 0, 1, string.format("%.2f", padding), locked)
    paintSlider(ui.timeoutFill, ui.timeoutLabel, "Ownership timeout", ownershipTimeout, 1, 6, tostring(ownershipTimeout), false)
    paintToggle(ui.keep, keepSelected)
    paintToggle(ui.origin, returnToOrigin)
    paintToggle(ui.match, matchPlankSize)
    paintKey(ui.rotateX, rotateXKey.Name)
    paintKey(ui.rotateY, rotateYKey.Name)
    if ui.status and ui.status.Parent and not selecting then
        if busy then
            setStatus("Moving")
        elseif stackMode then
            setStatus("Placing")
        else
            setStatus(tostring(count) .. " selected")
        end
    end
end

local function destroyOverlay()
    if overlay then
        overlay:Destroy()
        overlay = nil
        lassoFrame = nil
    end
end

local function ensureOverlay()
    if overlay and overlay.Parent then
        return overlay
    end
    overlay = make("ScreenGui", {
        Name = "OrganizerOverlay",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 20,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, uiParent())
    lassoFrame = make("Frame", {
        BackgroundColor3 = Color3.fromRGB(60, 130, 255),
        BackgroundTransparency = 0.75,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 10,
    }, overlay)
    make("UIStroke", {
        Color = Color3.fromRGB(120, 180, 255),
        Thickness = 1.5,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, lassoFrame)
    return overlay
end

local function clearBoxes()
    for _, box in ipairs(boxes) do
        if box then
            box:Destroy()
        end
    end
    boxes = {}
end

local function refreshBoxes()
    clearBoxes()
    if not started then
        paint()
        return
    end
    local gui = ensureOverlay()
    for _, obj in ipairs(liveSelected()) do
        local box = Instance.new("SelectionBox")
        box.Name = "OrganizerSelection"
        box.Color3 = SELECT_COLOR
        box.LineThickness = 0.05
        box.Adornee = obj
        box.Parent = gui
        table.insert(boxes, box)
    end
    paint()
end

local function togglePart(main)
    local index = table.find(selected, main)
    if index then
        table.remove(selected, index)
    else
        table.insert(selected, main)
    end
end

local function overWindow()
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
        return math.clamp((1 / 20) * 20, 0.5, 1)
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
    return token ~= runToken or batchCancelled or not started
end

local function teleportSingle(target, goalCF, rootPart, token)
    if aborted(token) or not target or not target.Parent or not rootPart then
        return
    end
    local model = target:FindFirstAncestorOfClass("Model") or target.Parent
    local lastInteracted = findLastInteraction(model)
    local flat = (rootPart.Position - target.Position) * Vector3.new(1, 0, 1)
    if flat.Magnitude > PROXIMITY then
        rootPart.CFrame = CFrame.new(target.Position + Vector3.new(0, 3, 0))
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
                    ClientIsDragging:FireServer(model)
                end)
                task.wait()
            end
            if target and target.Parent then
                target.CFrame = goalCF
            end
            task.wait(0.2)
            if target and target.Parent and (target.Position - goalCF.Position).Magnitude < 2 then
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
            local deadline = tick() + ownershipTimeout
            while not fired and tick() < deadline do
                if aborted(token) then
                    break
                end
                pcall(function()
                    ClientIsDragging:FireServer(model)
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
                ClientIsDragging:FireServer(model)
            end)
            if not ok then
                break
            end
            task.wait()
        end
    end

    if not aborted(token) and target and target.Parent then
        target.CFrame = goalCF
    end
    task.wait(POST_DELAY)
end

local function playerAligned(position, rootPart)
    local look = rootPart.CFrame.LookVector
    local flatLook = Vector3.new(look.X, 0, look.Z)
    if flatLook.Magnitude < 0.001 then
        flatLook = Vector3.new(0, 0, -1)
    end
    flatLook = flatLook.Unit
    local yaw = math.atan2(-flatLook.X, -flatLook.Z)
    return CFrame.new(position) * CFrame.Angles(0, yaw, 0) * CFrame.Angles(math.rad(90), 0, 0)
end

local function runBatch(jobs, shouldReturn)
    if shouldReturn == nil then
        shouldReturn = returnToOrigin
    end
    local token = runToken
    if not started or #jobs == 0 then
        batchCancelled = false
        busy = false
        paint()
        return false
    end
    local rootPart = currentRoot()
    if not rootPart or batchCancelled then
        batchCancelled = false
        busy = false
        paint()
        return false
    end
    busy = true
    homeCFrame = rootPart.CFrame
    paint()
    local saved = rootPart.CFrame
    for _, job in ipairs(jobs) do
        if aborted(token) then
            break
        end
        if job.target and job.target.Parent then
            pcall(teleportSingle, job.target, job.goalCF, rootPart, token)
        end
    end
    local stillOurs = token == runToken
    if stillOurs and shouldReturn and rootPart.Parent then
        rootPart.CFrame = saved
    end
    if stillOurs then
        homeCFrame = nil
        busy = false
        if not keepSelected then
            selected = {}
        end
        refreshBoxes()
    else
        busy = false
    end
    return stillOurs and not batchCancelled
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
    local playerModels = Workspace:FindFirstChild("PlayerModels")
    local cam = camera()
    if not playerModels or not cam then
        return
    end
    local inset = Services.GuiService:GetGuiInset()
    local seen = {}
    for _, obj in ipairs(playerModels:GetDescendants()) do
        if obj:IsA("BasePart") then
            local main = getObjectData(obj)
            if main and not seen[main] then
                seen[main] = true
                local screenPos, onScreen = cam:WorldToScreenPoint(main.Position)
                local sx = screenPos.X + inset.X
                local sy = screenPos.Y + inset.Y
                if onScreen and screenPos.Z > 0
                    and sx >= minX and sx <= maxX
                    and sy >= minY and sy <= maxY then
                    togglePart(main)
                end
            end
        end
    end
    refreshBoxes()
end

local function rotatedSize(size, rotation)
    local right = rotation.RightVector
    local up = rotation.UpVector
    local look = -rotation.LookVector
    return Vector3.new(
        math.abs(right.X) * size.X + math.abs(up.X) * size.Y + math.abs(look.X) * size.Z,
        math.abs(right.Y) * size.X + math.abs(up.Y) * size.Y + math.abs(look.Y) * size.Z,
        math.abs(right.Z) * size.X + math.abs(up.Z) * size.Y + math.abs(look.Z) * size.Z
    )
end

local function stackPositions(origin, itemSize, countX, countY, countZ, totalItems)
    local stepX = itemSize.X + padding
    local stepY = itemSize.Y
    local stepZ = itemSize.Z + padding
    local raw = {}
    for y = 0, countY - 1 do
        for z = 0, countZ - 1 do
            for x = 0, countX - 1 do
                table.insert(raw, Vector3.new(x * stepX, y * stepY, z * stepZ))
                if #raw >= totalItems then
                    break
                end
            end
            if #raw >= totalItems then
                break
            end
        end
        if #raw >= totalItems then
            break
        end
    end
    if #raw == 0 then
        return {}
    end
    local sumX, sumZ = 0, 0
    for _, point in ipairs(raw) do
        sumX += point.X
        sumZ += point.Z
    end
    local cx = sumX / #raw
    local cz = sumZ / #raw
    local positions = {}
    for _, point in ipairs(raw) do
        table.insert(positions, origin + Vector3.new(point.X - cx, point.Y, point.Z - cz))
    end
    return positions
end

local function referenceInfo()
    for _, obj in ipairs(liveSelected()) do
        local model = obj:FindFirstAncestorOfClass("Model") or obj
        local bounds = obj.Size
        if model:IsA("Model") then
            local ok, size = pcall(function()
                local _, bb = model:GetBoundingBox()
                return bb
            end)
            if ok and typeof(size) == "Vector3" then
                bounds = size
            end
        end
        return model, obj.Size, bounds
    end
    return nil
end

local function clearPreview()
    if previewConn then
        previewConn:Disconnect()
        previewConn = nil
    end
    for _, box in ipairs(previewBoxes) do
        if box then
            box:Destroy()
        end
    end
    previewBoxes = {}
    for _, part in ipairs(previewParts) do
        if part then
            part:Destroy()
        end
    end
    previewParts = {}
end

local function stopStack(silent)
    stackMode = false
    itemRotation = CFrame.new()
    clearPreview()
    if not silent then
        paint()
    end
end

local function aimRay(exclude)
    local cam = camera()
    if not cam then
        return nil
    end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = exclude
    local unitRay = cam:ScreenPointToRay(Mouse.X, Mouse.Y)
    local result = Workspace:Raycast(unitRay.Origin, unitRay.Direction * 500, params)
    return result and result.Position or (unitRay.Origin + unitRay.Direction * 40)
end

local function previewExclude()
    local list = {}
    if Player.Character then
        table.insert(list, Player.Character)
    end
    for _, preview in ipairs(previewParts) do
        table.insert(list, preview)
    end
    return list
end

local function startStack()
    if stackMode then
        stopStack(false)
        return
    end
    if busy or not sameType() then
        return
    end
    local refModel, refSize, refBounds = referenceInfo()
    if not refModel then
        return
    end
    local capacity = stackX * stackY * stackZ
    local stackCount = math.min(capacity, #liveSelected())
    if stackCount < 1 then
        return
    end
    clearPreview()
    local gui = ensureOverlay()
    local archived = refModel.Archivable
    refModel.Archivable = true
    local function ghost(part)
        part.Transparency = 0.55
        part.Anchored = true
        part.CanCollide = false
        part.CanTouch = false
        part.CastShadow = false
    end
    for _ = 1, stackCount do
        local clone = refModel:Clone()
        if clone then
            clone.Name = "OrganizerPreview"
            if clone:IsA("BasePart") then
                ghost(clone)
            end
            for _, desc in ipairs(clone:GetDescendants()) do
                if desc:IsA("BasePart") then
                    ghost(desc)
                end
            end
            local main = clone:FindFirstChild("Main") or clone:FindFirstChildWhichIsA("BasePart")
            if clone:IsA("Model") and main then
                clone.PrimaryPart = main
            end
            clone.Parent = Workspace
            table.insert(previewParts, clone)
            local box = Instance.new("SelectionBox")
            box.Color3 = Color3.fromRGB(140, 180, 255)
            box.LineThickness = 0.03
            box.Adornee = clone
            box.Parent = gui
            table.insert(previewBoxes, box)
        end
    end
    refModel.Archivable = archived
    if #previewParts == 0 then
        clearPreview()
        return
    end
    stackMode = true
    paint()
    previewConn = RunService.RenderStepped:Connect(function()
        if not stackMode then
            return
        end
        local hit = aimRay(previewExclude())
        if not hit then
            return
        end
        local effective = rotatedSize(refSize, itemRotation)
        local lift = rotatedSize(refBounds, itemRotation).Y * 0.5
        local origin = hit + Vector3.new(0, lift, 0)
        local positions = stackPositions(origin, effective, stackX, stackY, stackZ, #previewParts)
        for index, preview in ipairs(previewParts) do
            if positions[index] and preview.Parent then
                local goal = CFrame.new(positions[index]) * itemRotation
                if preview:IsA("Model") then
                    preview:PivotTo(goal)
                elseif preview:IsA("BasePart") then
                    preview.CFrame = goal
                end
            end
        end
    end)
end

local function placeStack(hitPos)
    if not stackMode then
        return
    end
    if not sameType() then
        stopStack(false)
        return
    end
    local _, refSize, refBounds = referenceInfo()
    if not refSize then
        stopStack(false)
        return
    end
    local capacity = stackX * stackY * stackZ
    local list = liveSelected()
    local stackCount = math.min(capacity, #list)
    local captured = itemRotation
    local effective = rotatedSize(refSize, captured)
    local origin = hitPos + Vector3.new(0, rotatedSize(refBounds, captured).Y * 0.5, 0)
    local positions = stackPositions(origin, effective, stackX, stackY, stackZ, stackCount)
    stopStack(true)
    local jobs = {}
    for index = 1, stackCount do
        local obj = list[index]
        if obj and obj.Parent then
            table.insert(jobs, {
                target = obj,
                goalCF = CFrame.new(positions[index] or origin) * captured,
            })
        end
    end
    busy = true
    paint()
    task.spawn(runBatch, jobs)
end

local function teleportSelection()
    if not started then
        return
    end
    if busy then
        batchCancelled = true
        return
    end
    if stackMode then
        stopStack(true)
    end
    local rootPart = currentRoot()
    local list = liveSelected()
    if not rootPart or #list == 0 then
        paint()
        return
    end
    local goal = playerAligned(rootPart.Position, rootPart)
    local jobs = {}
    for _, obj in ipairs(list) do
        table.insert(jobs, {
            target = obj,
            goalCF = goal,
        })
    end
    busy = true
    paint()
    task.spawn(runBatch, jobs)
end

local function selectOne()
    local main = getObjectData(Mouse.Target)
    if not main then
        return
    end
    togglePart(main)
    refreshBoxes()
end

local function selectGroup()
    if selecting or busy then
        return
    end
    local _, targetModel = getObjectData(Mouse.Target)
    if not targetModel then
        return
    end
    local targetItem = itemName(targetModel)
    local targetOwner = ownerIdentity(targetModel)
    local targetSig = modelSignature(targetModel)
    local targetTree = treeClass(targetModel)
    local targetSize = mainSizeY(targetModel)
    if not targetItem then
        return
    end
    local playerModels = Workspace:FindFirstChild("PlayerModels")
    if not playerModels then
        return
    end
    selecting = true
    setStatus("Selecting")
    task.spawn(function()
        local seen = {}
        local step = 0
        for _, obj in ipairs(playerModels:GetDescendants()) do
            if not started then
                break
            end
            step += 1
            if step % 1000 == 0 then
                task.wait()
            end
            if obj:IsA("Model")
                and itemName(obj) == targetItem
                and ownerIdentity(obj) == targetOwner
                and modelSignature(obj) == targetSig
                and treeClass(obj) == targetTree
                and (not matchPlankSize
                    or targetSize == nil
                    or (mainSizeY(obj) ~= nil and math.abs(mainSizeY(obj) - targetSize) <= 1))
            then
                local rawPart = obj:FindFirstChild("Main") or obj:FindFirstChildWhichIsA("BasePart")
                if rawPart then
                    local main = getObjectData(rawPart)
                    if main and not seen[main] then
                        seen[main] = true
                        togglePart(main)
                    end
                end
            end
        end
        selecting = false
        if started then
            refreshBoxes()
        end
    end)
end

local function clearSelection()
    if stackMode then
        stopStack(true)
    end
    selected = {}
    batchCancelled = true
    refreshBoxes()
end

local function sweepStrays()
    for _, child in ipairs(Workspace:GetChildren()) do
        if child.Name == "OrganizerPreview" then
            child:Destroy()
        end
    end
    local parent = uiParent()
    local old = parent and parent:FindFirstChild("OrganizerOverlay")
    if old and old ~= overlay then
        old:Destroy()
    end
end

local function onSortClick()
    if stackMode then
        stopStack(false)
    elseif busy then
        batchCancelled = true
    else
        startStack()
    end
end

local function onMouseDown()
    if not started or capturing or busy or selecting then
        return
    end
    if overWindow() or UserInputService:GetFocusedTextBox() then
        return
    end
    if stackMode then
        local hit = aimRay(previewExclude())
        if hit then
            placeStack(hit)
        end
    elseif lasso then
        ensureOverlay()
        lassoDragging = true
        lassoStart = UserInputService:GetMouseLocation()
        if lassoFrame then
            lassoFrame.Size = UDim2.fromOffset(0, 0)
            lassoFrame.Visible = false
        end
    elseif groupSelect then
        selectGroup()
    elseif clickSelect then
        selectOne()
    end
end

local function onKey(input)
    if capturing then
        if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Unknown then
            capturing = nil
        elseif capturing == "x" then
            rotateXKey = input.KeyCode
            capturing = nil
            saveConfig()
        elseif capturing == "y" then
            rotateYKey = input.KeyCode
            capturing = nil
            saveConfig()
        end
        paint()
        return
    end
    if not stackMode or UserInputService:GetFocusedTextBox() then
        return
    end
    if input.KeyCode == rotateXKey then
        itemRotation = itemRotation * CFrame.Angles(0, math.rad(90), 0)
    elseif input.KeyCode == rotateYKey then
        itemRotation = itemRotation * CFrame.Angles(math.rad(90), 0, 0)
    end
end

local function bindInput()
    if bound then
        return
    end
    bound = true
    track(UserInputService.InputBegan:Connect(function(input, processed)
        if not started then
            return
        end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            onKey(input)
            return
        end
        if processed or input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return
        end
        onMouseDown()
    end))
    track(UserInputService.InputChanged:Connect(function(input)
        if lassoDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateLasso(UserInputService:GetMouseLocation())
        end
    end))
    track(UserInputService.InputEnded:Connect(function(input)
        if lassoDragging and input.UserInputType == Enum.UserInputType.MouseButton1 then
            lassoDragging = false
            if lassoFrame then
                lassoFrame.Visible = false
            end
            selectLasso(lassoStart, UserInputService:GetMouseLocation())
            lassoStart = nil
        end
    end))
end

local function unbind()
    for _, conn in ipairs(conns) do
        conn:Disconnect()
    end
    conns = {}
    bound = false
    lassoDragging = false
    if lassoFrame then
        lassoFrame.Visible = false
    end
end

local function setMode(mode, on)
    if on then
        clickSelect = mode == "click"
        groupSelect = mode == "group"
        lasso = mode == "lasso"
        if mode ~= "lasso" then
            lassoDragging = false
            if lassoFrame then
                lassoFrame.Visible = false
            end
        end
    else
        if mode == "click" then
            clickSelect = false
        elseif mode == "group" then
            groupSelect = false
        elseif mode == "lasso" then
            lasso = false
            lassoDragging = false
            if lassoFrame then
                lassoFrame.Visible = false
            end
        end
    end
    paint()
end

local function hookSlider(slider, read, apply, lock)
    local function held()
        return lock and lock()
    end
    slider.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 or held() then
            return
        end
        apply(read(input.Position.X))
        local dragging = true
        local moveConn
        local endConn
        moveConn = UserInputService.InputChanged:Connect(function(changed)
            if dragging and changed.UserInputType == Enum.UserInputType.MouseMovement and not held() then
                apply(read(changed.Position.X))
            end
        end)
        endConn = UserInputService.InputEnded:Connect(function(ended)
            if ended.UserInputType ~= Enum.UserInputType.MouseButton1 then
                return
            end
            dragging = false
            moveConn:Disconnect()
            endConn:Disconnect()
            local index = table.find(dragConns, moveConn)
            if index then
                table.remove(dragConns, index)
            end
            index = table.find(dragConns, endConn)
            if index then
                table.remove(dragConns, index)
            end
            saveConfig()
        end)
        table.insert(dragConns, moveConn)
        table.insert(dragConns, endConn)
    end)
end

local function integerRead(slider, minValue, maxValue)
    return function(x)
        local width = slider.AbsoluteSize.X
        if width <= 0 then
            return minValue
        end
        local alpha = math.clamp((x - slider.AbsolutePosition.X) / width, 0, 1)
        return math.clamp(math.floor(alpha * (maxValue - minValue) + minValue + 0.5), minValue, maxValue)
    end
end

local function fieldLabel(parent, text)
    return make("TextLabel", {
        Size = UDim2.new(1, -36, 0, 16),
        Position = UDim2.fromOffset(0, 3),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = text,
        TextSize = 14,
        TextColor3 = MUTED,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, parent)
end

local function block(parent, height, order)
    return make("Frame", {
        Size = UDim2.new(1, 0, 0, height),
        BackgroundTransparency = 1,
        LayoutOrder = order,
    }, parent)
end

local function toggleButton(parent)
    local track = make("TextButton", {
        Size = UDim2.fromOffset(TOGGLE_W, TOGGLE_H),
        Position = UDim2.new(1, -TOGGLE_W, 0, 4),
        BackgroundColor3 = FIELD,
        Text = "",
        AutoButtonColor = false,
    }, parent)
    make("UICorner", {
        CornerRadius = UDim.new(1, 0),
    }, track)
    make("UIStroke", {
        Color = Color3.fromRGB(70, 70, 70),
        Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, track)
    local knob = make("Frame", {
        Size = UDim2.fromOffset(TOGGLE_KNOB, TOGGLE_KNOB),
        Position = UDim2.fromOffset(TOGGLE_PAD, (TOGGLE_H - TOGGLE_KNOB) / 2),
        BackgroundColor3 = WHITE,
        BorderSizePixel = 0,
    }, track)
    make("UICorner", {
        CornerRadius = UDim.new(1, 0),
    }, knob)
    toggleKnobs[track] = knob
    return track
end

local function actionButton(parent, text)
    return make("TextButton", {
        Size = UDim2.fromOffset(72, 22),
        Position = UDim2.new(1, -72, 0, 0),
        BackgroundColor3 = BUTTON,
        BorderSizePixel = 0,
        Font = Enum.Font.SourceSans,
        Text = text,
        TextSize = 15,
        TextColor3 = DARK,
        AutoButtonColor = false,
    }, parent)
end

local function keyButton(parent, bind)
    local button = make("TextButton", {
        Size = UDim2.fromOffset(88, 22),
        Position = UDim2.new(1, -88, 0, 0),
        BackgroundColor3 = FIELD,
        BorderSizePixel = 0,
        Font = Enum.Font.SourceSans,
        Text = "",
        TextSize = 15,
        TextColor3 = TEXT,
        AutoButtonColor = false,
    }, parent)
    button:SetAttribute("Bind", bind)
    return button
end

local function sliderButton(parent)
    local slider = make("TextButton", {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.fromOffset(0, 20),
        BackgroundColor3 = TRACK,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    }, parent)
    local fill = make("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = BUTTON,
        BorderSizePixel = 0,
    }, slider)
    return slider, fill
end

local function scrollingPage(parent)
    local page = make("ScrollingFrame", {
        Size = UDim2.new(1, -16, 1, -36),
        Position = UDim2.fromOffset(8, 30),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Color3.fromRGB(70, 70, 70),
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
    }, parent)
    local list = make("Frame", {
        Size = UDim2.new(1, -8, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
    }, page)
    make("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
    }, list)
    return page, list
end

local function build(parent)
    disconnectDrag()
    toggleKnobs = {}
    ui = {}
    root = make("Frame", {
        Name = "OrganizerRoot",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
    }, parent)

    local toolsTab = make("TextButton", {
        Size = UDim2.new(0.5, -1, 0, 22),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSansBold,
        Text = "Tools",
        TextSize = 15,
        TextColor3 = WHITE,
        AutoButtonColor = false,
    }, root)
    local settingsTab = make("TextButton", {
        Size = UDim2.new(0.5, -1, 0, 22),
        Position = UDim2.new(0.5, 1, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = "Settings",
        TextSize = 15,
        TextColor3 = Color3.fromRGB(175, 175, 175),
        AutoButtonColor = false,
    }, root)

    local toolsPage, toolsList = scrollingPage(root)
    local settingsPage, settingsList = scrollingPage(root)
    settingsPage.Visible = false

    local function showPage(which)
        local toolsOn = which == "tools"
        toolsPage.Visible = toolsOn
        settingsPage.Visible = not toolsOn
        toolsTab.Font = toolsOn and Enum.Font.SourceSansBold or Enum.Font.SourceSans
        settingsTab.Font = toolsOn and Enum.Font.SourceSans or Enum.Font.SourceSansBold
        toolsTab.TextColor3 = toolsOn and WHITE or Color3.fromRGB(175, 175, 175)
        settingsTab.TextColor3 = toolsOn and Color3.fromRGB(175, 175, 175) or WHITE
    end
    toolsTab.MouseButton1Click:Connect(function()
        showPage("tools")
    end)
    settingsTab.MouseButton1Click:Connect(function()
        showPage("settings")
    end)

    local function labeledToggle(list, caption, order)
        local row = block(list, 22, order)
        fieldLabel(row, caption)
        return toggleButton(row)
    end

    local function labeledAction(list, caption, order, idleText)
        local row = block(list, 22, order)
        fieldLabel(row, caption).Size = UDim2.new(1, -80, 0, 16)
        return actionButton(row, idleText)
    end

    ui.click = labeledToggle(toolsList, "Click selection", 1)
    ui.group = labeledToggle(toolsList, "Group selection", 2)
    ui.lasso = labeledToggle(toolsList, "Lasso", 3)
    ui.clear = labeledAction(toolsList, "Clear selection", 4, "Clear")
    ui.teleport = labeledAction(toolsList, "Teleport", 5, "Start")

    local function labeledSlider(list, order)
        local row = block(list, 36, order)
        local label = make("TextLabel", {
            Size = UDim2.new(1, 0, 0, 16),
            BackgroundTransparency = 1,
            Font = Enum.Font.SourceSans,
            Text = "",
            TextSize = 14,
            TextColor3 = MUTED,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, row)
        local slider, fill = sliderButton(row)
        return label, slider, fill
    end

    ui.xLabel, ui.xSlider, ui.xFill = labeledSlider(toolsList, 6)
    ui.yLabel, ui.ySlider, ui.yFill = labeledSlider(toolsList, 7)
    ui.zLabel, ui.zSlider, ui.zFill = labeledSlider(toolsList, 8)
    ui.padLabel, ui.padSlider, ui.padFill = labeledSlider(toolsList, 9)
    ui.sort = labeledAction(toolsList, "Sort", 10, "Start")

    local statusBlock = block(toolsList, 16, 11)
    ui.status = make("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = statusText,
        TextSize = 14,
        TextColor3 = MUTED,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, statusBlock)

    local function labeledKey(caption, order, bind)
        local row = block(settingsList, 22, order)
        fieldLabel(row, caption).Size = UDim2.new(1, -96, 0, 16)
        return keyButton(row, bind)
    end

    ui.rotateX = labeledKey("Rotate X", 1, "x")
    ui.rotateY = labeledKey("Rotate Y", 2, "y")
    ui.keep = labeledToggle(settingsList, "Keep selection", 3)
    ui.origin = labeledToggle(settingsList, "Return to origin", 4)
    ui.match = labeledToggle(settingsList, "Match plank size", 5)
    ui.timeoutLabel, ui.timeoutSlider, ui.timeoutFill = labeledSlider(settingsList, 6)

    ui.click.MouseButton1Click:Connect(function()
        setMode("click", not clickSelect)
    end)
    ui.group.MouseButton1Click:Connect(function()
        setMode("group", not groupSelect)
    end)
    ui.lasso.MouseButton1Click:Connect(function()
        setMode("lasso", not lasso)
    end)
    ui.clear.MouseButton1Click:Connect(clearSelection)
    ui.teleport.MouseButton1Click:Connect(function()
        if busy or #liveSelected() > 0 then
            teleportSelection()
        end
    end)
    ui.sort.MouseButton1Click:Connect(function()
        if busy or stackMode or sameType() then
            onSortClick()
        end
    end)

    hookSlider(ui.xSlider, integerRead(ui.xSlider, 1, 40), function(value)
        stackX = value
        paint()
    end, slidersLocked)
    hookSlider(ui.ySlider, integerRead(ui.ySlider, 1, 20), function(value)
        stackY = value
        paint()
    end, slidersLocked)
    hookSlider(ui.zSlider, integerRead(ui.zSlider, 1, 40), function(value)
        stackZ = value
        paint()
    end, slidersLocked)
    hookSlider(ui.padSlider, function(x)
        local width = ui.padSlider.AbsoluteSize.X
        if width <= 0 then
            return padding
        end
        local alpha = math.clamp((x - ui.padSlider.AbsolutePosition.X) / width, 0, 1)
        return math.clamp(math.floor(alpha * 100 + 0.5) / 100, 0, 1)
    end, function(value)
        padding = value
        paint()
    end, slidersLocked)
    hookSlider(ui.timeoutSlider, integerRead(ui.timeoutSlider, 1, 6), function(value)
        ownershipTimeout = value
        paint()
    end)

    ui.keep.MouseButton1Click:Connect(function()
        keepSelected = not keepSelected
        paint()
        saveConfig()
    end)
    ui.origin.MouseButton1Click:Connect(function()
        returnToOrigin = not returnToOrigin
        paint()
        saveConfig()
    end)
    ui.match.MouseButton1Click:Connect(function()
        matchPlankSize = not matchPlankSize
        paint()
        saveConfig()
    end)

    local function armKey(bind)
        capturing = capturing == bind and nil or bind
        paint()
    end
    ui.rotateX.MouseButton1Click:Connect(function()
        armKey("x")
    end)
    ui.rotateY.MouseButton1Click:Connect(function()
        armKey("y")
    end)

    paint()
end

local api = {}

function api.start(ctx)
    if type(ctx) == "table" then
        dashWindow = ctx.window
    end
    if started then
        return
    end
    started = true
    batchCancelled = false
    sweepStrays()
    bindInput()
    if mounted then
        paint()
    end
end

function api.stop()
    started = false
    selecting = false
    batchCancelled = true
    runToken += 1
    busy = false
    capturing = nil
    local rootPart = currentRoot()
    if homeCFrame and returnToOrigin and rootPart then
        rootPart.CFrame = homeCFrame
    end
    homeCFrame = nil
    stopStack(true)
    selected = {}
    clearBoxes()
    destroyOverlay()
    unbind()
    sweepStrays()
    paint()
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
    paint()
end

function api.unmount()
    mounted = false
    capturing = nil
    disconnectDrag()
    toggleKnobs = {}
    ui = {}
    if root then
        root:Destroy()
        root = nil
    end
end

return api
