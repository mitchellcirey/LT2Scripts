local Services = setmetatable({}, {
    __index = function(_, index)
        return game:GetService(index)
    end,
})

local Players = Services.Players
local Workspace = Services.Workspace
local ReplicatedStorage = Services.ReplicatedStorage
local HttpService = Services.HttpService
local RunService = Services.RunService

local Player = Players.LocalPlayer

local CONFIG_DIR = "LT2Scripts"
local CONFIG_FILE = CONFIG_DIR .. "/sawmillloader.json"

local TEXT = Color3.fromRGB(230, 230, 230)
local MUTED = Color3.fromRGB(160, 160, 160)
local FIELD = Color3.fromRGB(58, 58, 58)
local MENU = Color3.fromRGB(32, 32, 32)
local START_GREEN = Color3.fromRGB(70, 190, 105)
local STOP_RED = Color3.fromRGB(210, 70, 70)
local RING_CYAN = Color3.fromRGB(0, 200, 255)
local RING_GREEN = Color3.fromRGB(80, 230, 120)
local MILL_MARK = Color3.fromRGB(255, 210, 60)
local WOOD_MARK = Color3.fromRGB(255, 140, 40)
local RING_HEIGHT = 0.06
local MAX_WOOD_MARKS = 30

local MAX_STUDS = 8
local SELL_POSITION = Vector3.new(426, 10, 443.71)
local ROW_H = 22
local MENU_MAX = 176

local WOODS = {
    "Generic",
    "Cherry",
    "Birch",
    "Oak",
    "Walnut",
    "Koa",
    "Pine",
    "Palm",
    "Fir",
    "Volcano",
    "Frost",
    "GreenSwampy",
    "GoldSwampy",
    "SnowGlow",
    "CaveCrawler",
    "LoneCave",
    "Spook",
    "Sinister",
}

local woodSet = {}
for _, name in ipairs(WOODS) do
    woodSet[name] = true
end

local sawmillProperties = {
    Sawmill = { x = 2.6, y = 2.6, length = 10 },
    Sawmill2 = { x = 2.6, y = 2.6, length = 10 },
    Sawmill4 = { x = 2.6, y = 2.6, length = 10 },
    Sawmill4L = { x = 2.6, y = 2.6, length = 18 },
}

local sawmillOwner = Player.Name
local woodOwner = Player.Name
local selectedWood = "Oak"
local selectedSawmill = nil

local armed = false
local running = false
local session = 0
local mounted = false
local permissionPlayer = nil
local originalInteract = nil
local auraFolder = nil
local auraAt = nil
local circleConn = nil
local settingsModule = nil
local marks = {}
local watchConns = {}

local root = nil
local runBtn = nil
local captions = {}
local backdrop = nil
local menu = nil
local menuAnchor = nil
local startRun
local stopRun

local function round(val)
    return math.floor((val * 100) + 0.5) / 100
end

local function make(className, props, parent)
    local inst = Instance.new(className)
    for key, value in pairs(props) do
        inst[key] = value
    end
    inst.Parent = parent
    return inst
end

local function saveConfig()
    if type(writefile) ~= "function" then
        return
    end
    if type(makefolder) == "function" and type(isfolder) == "function" and not isfolder(CONFIG_DIR) then
        pcall(makefolder, CONFIG_DIR)
    end
    local payload = {
        sawmillOwner = sawmillOwner,
        woodOwner = woodOwner,
        sawmill = selectedSawmill,
        wood = selectedWood,
    }
    local encodedOk, encoded = pcall(function()
        return HttpService:JSONEncode(payload)
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
        return HttpService:JSONDecode(raw)
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
    if type(data.sawmillOwner) == "string" and data.sawmillOwner ~= "" then
        sawmillOwner = data.sawmillOwner
    end
    if type(data.woodOwner) == "string" and data.woodOwner ~= "" then
        woodOwner = data.woodOwner
    end
    if type(data.sawmill) == "string" and data.sawmill ~= "" then
        selectedSawmill = data.sawmill
    end
    if type(data.wood) == "string" and woodSet[data.wood] then
        selectedWood = data.wood
    end
end

applySaved(readSavedConfig())

local function findPlayer(name)
    if type(name) ~= "string" or name == "" then
        return nil
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name == name then
            return player
        end
    end
    return nil
end

local function loadSettings()
    if settingsModule then
        return settingsModule
    end
    local scripts = Player:FindFirstChild("PlayerScripts") or Player:WaitForChild("PlayerScripts", 5)
    local moduleScript = scripts and (scripts:FindFirstChild("ClientUserSettings") or scripts:WaitForChild("ClientUserSettings", 5))
    if not moduleScript then
        return nil
    end
    local ok, result = pcall(require, moduleScript)
    if ok then
        settingsModule = result
    end
    return settingsModule
end

local function getPermissionDataInteractValue(player)
    local settings = settingsModule or loadSettings()
    if not settings then
        return nil
    end
    local userId = tostring(player.UserId)
    local playerSettings = settings.GetSettings()
    local permissionData = playerSettings.UserPermissionList[userId]
    if not permissionData then
        return nil
    end
    return permissionData.Interact
end

local function changeUserPermissionInteract(player, value)
    local settings = settingsModule or loadSettings()
    if not settings or not player then
        return
    end
    if value == nil then
        value = false
    end
    settings.SendUpdate("UserPermission", tostring(player.UserId), "Interact", value)
end

local function currentRoot()
    local character = Player.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function getPlayerSawmills(player)
    local sawmills = {}
    local used = {}
    local playerModels = Workspace:FindFirstChild("PlayerModels")
    if not playerModels or not player then
        return sawmills
    end

    for _, model in pairs(playerModels:getChildren()) do
        if model:FindFirstChild("Owner") and model.Owner.Value == player and model:findFirstChild("ItemName") then
            local itemName = model.ItemName.Value
            if sawmillProperties[itemName] and model:FindFirstChild("Conveyor") and model.Conveyor:FindFirstChild("Model") and model:FindFirstChild("BlockageAlert") and model:FindFirstChild("Settings") then
                local pos1
                local pos2
                for _, part in pairs(model.Conveyor.Model:getChildren()) do
                    if part:IsA("BasePart") then
                        if pos1 == nil then
                            pos1 = part.Position
                        elseif pos2 == nil then
                            pos2 = part.Position
                        else
                            break
                        end
                    end
                end
                if pos1 and pos2 and model.Settings:FindFirstChild("DimX") and model.Settings:FindFirstChild("DimZ") then
                    local adjustment = 5
                    local diff = Vector3.new(round(pos2.X - pos1.X), round(pos2.Y - pos1.Y), round(pos2.Z - pos1.Z))
                    local dir = Vector3.new(diff.X, 0, diff.Z)
                    local rot
                    if math.abs(dir.X) >= math.abs(dir.Z) then
                        rot = CFrame.Angles(0, 0, math.rad(90) * math.sign(dir.X ~= 0 and dir.X or 1))
                    else
                        rot = CFrame.Angles(math.rad(90) * math.sign(dir.Z ~= 0 and dir.Z or 1), 0, 0)
                    end
                    local alert = model.BlockageAlert.Position
                    local blockageAlertPosition = Vector3.new(alert.X, alert.Y - 1, alert.Z)
                    local tpPosition = CFrame.new(blockageAlertPosition) + Vector3.new(diff.X * adjustment, -0.025, diff.Z * adjustment)
                    local base = string.format("%s|%d|%d|%d", itemName, math.floor(alert.X + 0.5), math.floor(alert.Y + 0.5), math.floor(alert.Z + 0.5))
                    local key = base
                    local n = 2
                    while used[key] do
                        key = base .. "|" .. tostring(n)
                        n = n + 1
                    end
                    used[key] = true
                    table.insert(sawmills, {
                        key = key,
                        name = itemName,
                        model = model,
                        alert = alert,
                        tpPosition = tpPosition.p,
                        x = model.Settings.DimX.Value,
                        y = model.Settings.DimZ.Value,
                        rot = rot,
                    })
                end
            end
        end
    end

    local counts = {}
    for _, mill in ipairs(sawmills) do
        counts[mill.name] = (counts[mill.name] or 0) + 1
    end
    for _, mill in ipairs(sawmills) do
        if counts[mill.name] > 1 then
            mill.label = string.format("%s  %d, %d", mill.name, math.floor(mill.alert.X + 0.5), math.floor(mill.alert.Z + 0.5))
        else
            mill.label = mill.name
        end
    end
    table.sort(sawmills, function(a, b)
        if a.label == b.label then
            return a.key < b.key
        end
        return a.label < b.label
    end)
    return sawmills
end

local function chosenSawmill(player)
    local mills = getPlayerSawmills(player)
    for _, mill in ipairs(mills) do
        if mill.key == selectedSawmill then
            return mill
        end
    end
    if #mills == 1 then
        if selectedSawmill ~= mills[1].key then
            selectedSawmill = mills[1].key
            saveConfig()
            local label = captions.sawmill
            if label and label.Parent then
                label.Text = mills[1].label
            end
        end
        return mills[1]
    end
    return nil
end

local function sleep(seconds, token)
    local elapsed = 0
    while elapsed < seconds do
        if token ~= session then
            return false
        end
        local step = math.min(0.1, seconds - elapsed)
        task.wait(step)
        elapsed = elapsed + step
    end
    return token == session
end

local function moveLogs(player, sawmill, rootPart, token)
    local logModels = Workspace:FindFirstChild("LogModels")
    if not logModels then
        return
    end
    local props = sawmillProperties[sawmill.name]
    if not props then
        return
    end

    for _, log in pairs(logModels:getChildren()) do
        if token ~= session then
            return
        end
        if log:FindFirstChild("Owner") and (log.Owner.Value == nil or log.Owner.Value == player) and log.Name ~= "PlaceholderPart" then
            local timeout = 0
            local woodSection = log:findFirstChild("WoodSection")
            local treeClass = log:findFirstChild("TreeClass")
            local target = log:FindFirstChild("Main") or log:FindFirstChildWhichIsA("BasePart")
            if woodSection and target and not (treeClass and treeClass.Value ~= selectedWood) then
                local flat = (rootPart.Position - target.Position) * Vector3.new(1, 0, 1)
                if flat.Magnitude <= MAX_STUDS then
                    if woodSection.Size.X * woodSection.Size.Z < 0.24 then
                        log:moveTo(SELL_POSITION)
                    elseif woodSection.Size.X <= 2.6 and woodSection.Size.Z <= 2.6 then
                        local woodVolume = woodSection.Size.X * woodSection.Size.Z * woodSection.Size.Y
                        local sawmillSize = sawmill.x * sawmill.y * 0.25
                        if woodVolume >= sawmillSize and woodSection.Size.Y <= props.length then
                            timeout = target.Size.Y / 2
                            woodSection.CFrame = CFrame.new(sawmill.tpPosition) * sawmill.rot
                            local remote = ReplicatedStorage:FindFirstChild("Interaction")
                            remote = remote and remote:FindFirstChild("ClientIsDragging")
                            if remote then
                                remote:FireServer(log)
                            end
                        end
                    end
                    if not sleep(timeout, token) then
                        return
                    end
                end
            end
        end
    end
end

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local function clearAura()
    if auraFolder then
        auraFolder:Destroy()
        auraFolder = nil
    end
    auraAt = nil
end

local function groundCenter(rootPart)
    local ignore = {}
    if rootPart.Parent then
        table.insert(ignore, rootPart.Parent)
    end
    if auraFolder then
        table.insert(ignore, auraFolder)
    end
    rayParams.FilterDescendantsInstances = ignore
    local hit = Workspace:Raycast(rootPart.Position, Vector3.new(0, -80, 0), rayParams)
    local y
    if hit then
        y = hit.Position.Y
    else
        local humanoid = rootPart.Parent and rootPart.Parent:FindFirstChildOfClass("Humanoid")
        local hip = humanoid and humanoid.HipHeight or 2
        y = rootPart.Position.Y - rootPart.Size.Y * 0.5 - hip
    end
    return Vector3.new(rootPart.Position.X, y + RING_HEIGHT * 0.5, rootPart.Position.Z)
end

local function drawAura(centerPosition)
    clearAura()
    local segments = 64
    local thickness = 0.15
    local folder = Instance.new("Folder")
    folder.Name = "SawmillLoaderAura"
    folder.Parent = Workspace
    auraFolder = folder
    auraAt = centerPosition

    for i = 0, segments - 1 do
        local angle1 = (i / segments) * math.pi * 2
        local angle2 = ((i + 1) / segments) * math.pi * 2
        local p1 = centerPosition + Vector3.new(math.cos(angle1) * MAX_STUDS, 0, math.sin(angle1) * MAX_STUDS)
        local p2 = centerPosition + Vector3.new(math.cos(angle2) * MAX_STUDS, 0, math.sin(angle2) * MAX_STUDS)
        local midpoint = (p1 + p2) / 2
        local segment = Instance.new("Part")
        segment.Anchored = true
        segment.CanCollide = false
        segment.CanQuery = false
        segment.CanTouch = false
        segment.Material = Enum.Material.Neon
        segment.Color = running and RING_GREEN or RING_CYAN
        segment.Transparency = 0.22
        segment.Size = Vector3.new(thickness, RING_HEIGHT, (p2 - p1).Magnitude)
        segment.CFrame = CFrame.lookAt(midpoint, p2)
        segment.Parent = folder
    end
end

local function circleActive()
    return armed or running or mounted
end

local function stopCircle()
    if circleConn then
        circleConn:Disconnect()
        circleConn = nil
    end
    clearAura()
end

local function ensureCircle()
    if circleConn then
        return
    end
    circleConn = RunService.Heartbeat:Connect(function()
        if not circleActive() then
            local conn = circleConn
            circleConn = nil
            if conn then
                conn:Disconnect()
            end
            clearAura()
            return
        end
        local rootPart = currentRoot()
        if not rootPart then
            return
        end
        local pos = groundCenter(rootPart)
        local moved = not auraAt
            or (Vector3.new(pos.X - auraAt.X, 0, pos.Z - auraAt.Z)).Magnitude > 0.4
            or math.abs(pos.Y - auraAt.Y) > 0.15
        if moved or not auraFolder then
            drawAura(pos)
        end
        if not auraFolder then
            return
        end
        local color = running and RING_GREEN or RING_CYAN
        local alpha = 0.22
        if running then
            alpha = 0.08 + 0.55 * (0.5 + 0.5 * math.sin(os.clock() * 5))
        end
        for _, part in ipairs(auraFolder:GetChildren()) do
            part.Color = color
            part.Transparency = alpha
        end
    end)
end

local function restorePermission()
    local player = permissionPlayer
    local previous = originalInteract
    permissionPlayer = nil
    originalInteract = nil
    if player and previous ~= true then
        pcall(changeUserPermissionInteract, player, previous)
    end
end

local function ensurePermission(player)
    if permissionPlayer == player then
        return
    end
    restorePermission()
    permissionPlayer = player
    originalInteract = getPermissionDataInteractValue(player)
    if originalInteract ~= true then
        changeUserPermissionInteract(player, true)
    end
end

local function clearHighlights()
    for _, mark in ipairs(marks) do
        if mark then
            mark:Destroy()
        end
    end
    table.clear(marks)
end

local function addMark(model, color)
    if not model or not model.Parent then
        return
    end
    local mark = Instance.new("Highlight")
    mark.Name = "SawmillLoaderHighlight"
    mark.Adornee = model
    mark.FillColor = color
    mark.OutlineColor = color
    mark.FillTransparency = 0.55
    mark.OutlineTransparency = 0
    mark.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    mark.Parent = model
    table.insert(marks, mark)
end

local function refreshHighlights()
    clearHighlights()
    if running then
        return
    end
    local owner = findPlayer(sawmillOwner)
    if owner and selectedSawmill then
        for _, mill in ipairs(getPlayerSawmills(owner)) do
            if mill.key == selectedSawmill then
                addMark(mill.model, MILL_MARK)
                break
            end
        end
    end
    local woodPlayer = findPlayer(woodOwner)
    local logModels = Workspace:FindFirstChild("LogModels")
    local rootPart = currentRoot()
    if not logModels or not woodPlayer then
        return
    end
    local matches = {}
    for _, log in ipairs(logModels:GetChildren()) do
        if log:FindFirstChild("Owner") and (log.Owner.Value == nil or log.Owner.Value == woodPlayer) and log.Name ~= "PlaceholderPart" then
            local treeClass = log:FindFirstChild("TreeClass")
            if treeClass and treeClass.Value == selectedWood then
                local target = log:FindFirstChild("Main") or log:FindFirstChildWhichIsA("BasePart")
                local dist = 0
                if target and rootPart then
                    dist = (target.Position - rootPart.Position).Magnitude
                end
                table.insert(matches, { model = log, dist = dist })
            end
        end
    end
    table.sort(matches, function(a, b)
        return a.dist < b.dist
    end)
    for index = 1, math.min(#matches, MAX_WOOD_MARKS) do
        addMark(matches[index].model, WOOD_MARK)
    end
end

local function unwatchHighlights()
    for _, conn in ipairs(watchConns) do
        conn:Disconnect()
    end
    table.clear(watchConns)
end

local function watchHighlights()
    unwatchHighlights()
    local function hook(folder)
        if not folder then
            return
        end
        table.insert(watchConns, folder.ChildAdded:Connect(function()
            task.delay(0.3, function()
                if not running then
                    refreshHighlights()
                end
            end)
        end))
        table.insert(watchConns, folder.ChildRemoved:Connect(function()
            if not running then
                refreshHighlights()
            end
        end))
    end
    hook(Workspace:FindFirstChild("LogModels"))
    hook(Workspace:FindFirstChild("PlayerModels"))
end

local function runLoop(token)
    loadSettings()
    if token ~= session then
        return
    end
    while token == session do
        local ok, err = pcall(function()
            if token ~= session then
                return
            end
            local rootPart = currentRoot()
            local sawmillPlayer = findPlayer(sawmillOwner)
            local woodPlayer = findPlayer(woodOwner)
            if rootPart and sawmillPlayer and woodPlayer then
                ensurePermission(sawmillPlayer)
                if token ~= session then
                    return
                end
                local sawmill = chosenSawmill(sawmillPlayer)
                if sawmill then
                    moveLogs(woodPlayer, sawmill, rootPart, token)
                end
            end
        end)
        if not ok and token == session then
            warn("[Jell] Sawmill Loader " .. tostring(err))
        end
        if not sleep(0.35, token) then
            return
        end
    end
end

local function closeMenu()
    menuAnchor = nil
    if backdrop then
        backdrop:Destroy()
        backdrop = nil
    end
    if menu then
        menu:Destroy()
        menu = nil
    end
end

local function paintCaption(key, text)
    local label = captions[key]
    if label and label.Parent then
        label.Text = text
    end
end

local function paintRun()
    if not (runBtn and runBtn.Parent) then
        return
    end
    if running then
        runBtn.Text = "Stop"
        runBtn.BackgroundColor3 = STOP_RED
        runBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        runBtn.Text = "Start"
        runBtn.BackgroundColor3 = START_GREEN
        runBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end

local function sawmillCaption()
    local player = findPlayer(sawmillOwner)
    if player then
        for _, mill in ipairs(getPlayerSawmills(player)) do
            if mill.key == selectedSawmill then
                return mill.label
            end
        end
        return "None"
    end
    if type(selectedSawmill) == "string" then
        local name = string.match(selectedSawmill, "^([^|]+)")
        if name and name ~= "" then
            return name
        end
    end
    return "None"
end

local function playerLabel(player)
    return player.DisplayName .. "  @" .. player.Name
end

local function playerCaption(name)
    local player = findPlayer(name)
    if player then
        return playerLabel(player)
    end
    if type(name) == "string" and name ~= "" then
        return "@" .. name
    end
    return "None"
end

local function playerOptions()
    local rows = {}
    for _, player in ipairs(Players:GetPlayers()) do
        table.insert(rows, {
            id = player.Name,
            label = playerLabel(player),
            sort = string.lower(player.DisplayName .. " " .. player.Name),
        })
    end
    table.sort(rows, function(a, b)
        return a.sort < b.sort
    end)
    local options = {}
    for _, row in ipairs(rows) do
        table.insert(options, { id = row.id, label = row.label })
    end
    return options
end

local function sawmillOptions()
    local options = {}
    local player = findPlayer(sawmillOwner)
    if not player then
        return options
    end
    for _, mill in ipairs(getPlayerSawmills(player)) do
        table.insert(options, { id = mill.key, label = mill.label })
    end
    return options
end

local function woodOptions()
    local options = {}
    for _, name in ipairs(WOODS) do
        table.insert(options, { id = name, label = name })
    end
    return options
end

local function openMenu(button, options, current, onPick)
    if menuAnchor == button then
        closeMenu()
        return
    end
    closeMenu()
    if not root or not button then
        return
    end
    menuAnchor = button
    backdrop = make("TextButton", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 4,
    }, root)
    backdrop.MouseButton1Click:Connect(function()
        task.defer(closeMenu)
    end)

    local count = math.max(#options, 1)
    local height = math.min(count * ROW_H, MENU_MAX)
    local btnTop = button.AbsolutePosition.Y - root.AbsolutePosition.Y
    local below = root.AbsoluteSize.Y - (btnTop + button.AbsoluteSize.Y)
    local y = btnTop + button.AbsoluteSize.Y + 2
    if below < height + 4 then
        y = math.max(0, btnTop - height - 2)
    end

    menu = make("ScrollingFrame", {
        Size = UDim2.new(1, -16, 0, height),
        Position = UDim2.fromOffset(8, y),
        BackgroundColor3 = MENU,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Color3.fromRGB(70, 70, 70),
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Active = true,
        ZIndex = 5,
    }, root)
    make("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, menu)

    local rows = options
    if #rows == 0 then
        rows = { { id = nil, label = "None" } }
    end
    for index, option in ipairs(rows) do
        local picked = option.id ~= nil and option.id == current
        local row = make("TextButton", {
            Size = UDim2.new(1, 0, 0, ROW_H),
            BackgroundColor3 = FIELD,
            BackgroundTransparency = picked and 0 or 1,
            BorderSizePixel = 0,
            Font = Enum.Font.SourceSans,
            Text = option.label,
            TextSize = 15,
            TextColor3 = option.id == nil and MUTED or TEXT,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false,
            LayoutOrder = index,
            Active = option.id ~= nil,
            ZIndex = 6,
        }, menu)
        make("UIPadding", {
            PaddingLeft = UDim.new(0, 6),
        }, row)
        row.MouseButton1Click:Connect(function()
            if option.id == nil then
                return
            end
            onPick(option.id)
            task.defer(closeMenu)
        end)
    end
end

local function field(parent, caption, order)
    local block = make("Frame", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundTransparency = 1,
        LayoutOrder = order,
    }, parent)
    make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = caption,
        TextSize = 14,
        TextColor3 = MUTED,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, block)
    local button = make("TextButton", {
        Size = UDim2.new(1, 0, 0, ROW_H),
        Position = UDim2.fromOffset(0, 20),
        BackgroundColor3 = FIELD,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    }, block)
    local captionLabel = make("TextLabel", {
        Size = UDim2.new(1, -22, 1, 0),
        Position = UDim2.fromOffset(6, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = "",
        TextSize = 15,
        TextColor3 = TEXT,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, button)
    make("TextLabel", {
        Size = UDim2.fromOffset(16, ROW_H),
        Position = UDim2.new(1, -16, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = "v",
        TextSize = 14,
        TextColor3 = MUTED,
    }, button)
    return button, captionLabel
end

local function build(parent)
    root = make("Frame", {
        Name = "SawmillLoaderRoot",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
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

    local sawmillOwnerBtn, sawmillOwnerCaption = field(list, "Sawmill owner", 1)
    local woodOwnerBtn, woodOwnerCaption = field(list, "Wood owner", 2)
    local sawmillBtn, sawmillLabel = field(list, "Sawmill", 3)
    local woodBtn, woodLabel = field(list, "Wood", 4)
    captions.sawmillOwner = sawmillOwnerCaption
    captions.woodOwner = woodOwnerCaption
    captions.sawmill = sawmillLabel
    captions.wood = woodLabel

    local runBlock = make("Frame", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundTransparency = 1,
        LayoutOrder = 5,
    }, list)
    make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = "Run",
        TextSize = 14,
        TextColor3 = MUTED,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, runBlock)
    runBtn = make("TextButton", {
        Size = UDim2.new(1, 0, 0, ROW_H),
        Position = UDim2.fromOffset(0, 20),
        BackgroundColor3 = START_GREEN,
        BorderSizePixel = 0,
        Font = Enum.Font.SourceSans,
        Text = "Start",
        TextSize = 15,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        AutoButtonColor = false,
    }, runBlock)

    local function paintFields()
        if selectedSawmill == nil then
            local player = findPlayer(sawmillOwner)
            local mills = player and getPlayerSawmills(player) or {}
            if #mills == 1 then
                selectedSawmill = mills[1].key
                saveConfig()
            end
        end
        paintCaption("sawmillOwner", playerCaption(sawmillOwner))
        paintCaption("woodOwner", playerCaption(woodOwner))
        paintCaption("sawmill", sawmillCaption())
        paintCaption("wood", selectedWood)
        paintRun()
        refreshHighlights()
    end

    sawmillOwnerBtn.MouseButton1Click:Connect(function()
        openMenu(sawmillOwnerBtn, playerOptions(), sawmillOwner, function(id)
            sawmillOwner = id
            selectedSawmill = nil
            local player = findPlayer(id)
            local mills = player and getPlayerSawmills(player) or {}
            if mills[1] then
                selectedSawmill = mills[1].key
            end
            saveConfig()
            paintFields()
        end)
    end)

    woodOwnerBtn.MouseButton1Click:Connect(function()
        openMenu(woodOwnerBtn, playerOptions(), woodOwner, function(id)
            woodOwner = id
            saveConfig()
            paintFields()
        end)
    end)

    sawmillBtn.MouseButton1Click:Connect(function()
        openMenu(sawmillBtn, sawmillOptions(), selectedSawmill, function(id)
            selectedSawmill = id
            saveConfig()
            paintFields()
        end)
    end)

    woodBtn.MouseButton1Click:Connect(function()
        openMenu(woodBtn, woodOptions(), selectedWood, function(id)
            selectedWood = id
            saveConfig()
            paintFields()
        end)
    end)

    runBtn.MouseButton1Click:Connect(function()
        closeMenu()
        if running then
            stopRun()
        else
            startRun()
        end
    end)

    paintFields()
end

local api = {}

function startRun()
    if running then
        return
    end
    running = true
    session = session + 1
    local token = session
    clearHighlights()
    ensureCircle()
    paintRun()
    task.spawn(function()
        local ok, err = xpcall(function()
            runLoop(token)
        end, debug.traceback)
        if token ~= session then
            return
        end
        running = false
        restorePermission()
        paintRun()
        if circleActive() then
            refreshHighlights()
        else
            stopCircle()
            clearHighlights()
            unwatchHighlights()
        end
        if not ok then
            warn("[Jell] Sawmill Loader " .. tostring(err))
        end
    end)
end

function stopRun()
    session = session + 1
    running = false
    restorePermission()
    paintRun()
    if circleActive() then
        ensureCircle()
        refreshHighlights()
    else
        stopCircle()
        clearHighlights()
        unwatchHighlights()
    end
end

function api.start()
    armed = true
    watchHighlights()
    if running then
        ensureCircle()
        paintRun()
        return
    end
    startRun()
end

function api.stop()
    armed = false
    session = session + 1
    running = false
    restorePermission()
    paintRun()
    if mounted then
        ensureCircle()
        refreshHighlights()
    else
        stopCircle()
        clearHighlights()
        unwatchHighlights()
    end
end

function api.mount(parent)
    if mounted then
        api.unmount()
    end
    build(parent)
    mounted = true
    ensureCircle()
    watchHighlights()
    if not running then
        refreshHighlights()
    end
end

function api.unmount()
    mounted = false
    closeMenu()
    if root then
        root:Destroy()
        root = nil
    end
    runBtn = nil
    captions = {}
    if not armed and not running then
        stopCircle()
        clearHighlights()
        unwatchHighlights()
    end
end

return api
