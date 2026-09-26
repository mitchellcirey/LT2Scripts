local Services = setmetatable({}, {
    __index = function(_, index)
        return game:GetService(index)
    end,
})

local Players = Services.Players
local RunService = Services.RunService
local UserInputService = Services.UserInputService
local Workspace = Services.Workspace
local ReplicatedStorage = Services.ReplicatedStorage

local Player = Players.LocalPlayer

local CONFIG_DIR = "LT2Scripts"
local CONFIG_FILE = CONFIG_DIR .. "/sawmill.json"

local TEXT = Color3.fromRGB(230, 230, 230)
local MUTED = Color3.fromRGB(160, 160, 160)
local RED = Color3.fromRGB(210, 70, 70)

local RADIUS_MIN = 1
local RADIUS_MAX = 64
local AURA_SEGMENTS = 64
local SELL_POSITION = Vector3.new(426, 10, 443.71)

local treeTypes = {
    Generic = false,
    Cherry = false,
    Birch = true,
    Oak = true,
    Walnut = false,
    Koa = false,
    Pine = false,
    Palm = false,
    Fir = false,
    Volcano = false,
    Frost = false,
    GreenSwampy = false,
    GoldSwampy = false,
    SnowGlow = false,
    CaveCrawler = false,
    LoneCave = false,
    Spook = false,
    Sinister = false,
}

local sawmillProperties = {
    Sawmill = { x = 2.6, y = 2.6, length = 10 },
    Sawmill2 = { x = 2.6, y = 2.6, length = 10 },
    Sawmill4 = { x = 2.6, y = 2.6, length = 10 },
    Sawmill4L = { x = 2.6, y = 2.6, length = 18 },
}

local sawmillOwner
local woodOwner
local radius = 8
local running = false
local mounted = false
local runToken = 0
local statusText = "Idle"
local lastLogErr

local ClientUserSettings
local permittedPlayer
local savedInteract

local auraConn
local auraFolder
local auraParts = {}

local root
local sawmillCaption
local woodCaption
local startBtn
local radiusLabel
local radiusFill
local radiusSlider
local statusLabel
local menu
local backdrop
local menuKind
local menuY = 0
local guiConns = {}

local api = {}

local function make(className, props, parent)
    local inst = Instance.new(className)
    for key, value in pairs(props) do
        inst[key] = value
    end
    inst.Parent = parent
    return inst
end

local function track(conn)
    table.insert(guiConns, conn)
    return conn
end

local function clearConns()
    for _, conn in ipairs(guiConns) do
        conn:Disconnect()
    end
    table.clear(guiConns)
end

local function round(val)
    return math.floor((val * 100) + 0.5) / 100
end

local function currentRoot()
    local character = Player.Character
    if not character then
        return nil
    end
    return character:FindFirstChild("HumanoidRootPart")
end

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

local function playerLabel(player)
    local display = player.DisplayName
    if display == "" then
        display = player.Name
    end
    return display .. " (@" .. player.Name .. ")"
end

local function ownerLabel(name)
    if type(name) ~= "string" or name == "" then
        return "Select"
    end
    local player = findPlayer(name)
    if not player then
        return "@" .. name
    end
    return playerLabel(player)
end

local function sortedPlayers()
    local list = Players:GetPlayers()
    table.sort(list, function(a, b)
        local aKey = string.lower(a.DisplayName .. "\0" .. a.Name)
        local bKey = string.lower(b.DisplayName .. "\0" .. b.Name)
        return aKey < bKey
    end)
    return list
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
        radius = radius,
    }
    local encodedOk, encoded = pcall(function()
        return Services.HttpService:JSONEncode(payload)
    end)
    if encodedOk then
        pcall(writefile, CONFIG_FILE, encoded)
    end
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
    local savedRadius = tonumber(data.radius)
    if savedRadius then
        radius = math.clamp(math.floor(savedRadius + 0.5), RADIUS_MIN, RADIUS_MAX)
    end
end

applySaved(readSavedConfig())

local function settingsModule()
    if ClientUserSettings then
        return ClientUserSettings
    end
    local scripts = Player:FindFirstChild("PlayerScripts")
    local module = scripts and scripts:FindFirstChild("ClientUserSettings")
    if not module then
        return nil
    end
    local ok, result = pcall(require, module)
    if ok then
        ClientUserSettings = result
        return result
    end
    return nil
end

local function setInteract(player, value)
    local settingsApi = settingsModule()
    if not settingsApi or not player then
        return false
    end
    if value == nil then
        value = false
    end
    local ok = pcall(function()
        settingsApi.SendUpdate("UserPermission", tostring(player.UserId), "Interact", value)
    end)
    return ok
end

local function getInteract(player)
    local settingsApi = settingsModule()
    if not settingsApi or not player then
        return nil, false
    end
    local ok, playerSettings = pcall(function()
        return settingsApi.GetSettings()
    end)
    if not ok or type(playerSettings) ~= "table" then
        return nil, false
    end
    local list = playerSettings.UserPermissionList
    if type(list) ~= "table" then
        return nil, true
    end
    local data = list[tostring(player.UserId)]
    if type(data) ~= "table" then
        return nil, true
    end
    return data.Interact, true
end

local function restorePermission()
    local player = permittedPlayer
    local previous = savedInteract
    permittedPlayer = nil
    savedInteract = nil
    if player and previous ~= true then
        setInteract(player, previous)
    end
end

local function allow(player)
    if permittedPlayer == player then
        return true
    end
    restorePermission()
    local current, ok = getInteract(player)
    if not ok then
        return false
    end
    if current ~= true and not setInteract(player, true) then
        return false
    end
    permittedPlayer = player
    savedInteract = current
    return true
end

local function destroyAura()
    if auraFolder then
        auraFolder:Destroy()
        auraFolder = nil
    end
    table.clear(auraParts)
    local leftover = Workspace:FindFirstChild("SawmillLoaderAura")
    if leftover then
        leftover:Destroy()
    end
end

local function drawAura(center, studs)
    if not running then
        return
    end
    if not auraFolder or not auraFolder.Parent then
        auraFolder = Instance.new("Folder")
        auraFolder.Name = "SawmillLoaderAura"
        auraFolder.Parent = Workspace
        table.clear(auraParts)
        for index = 1, AURA_SEGMENTS do
            local segment = Instance.new("Part")
            segment.Name = "Segment"
            segment.Anchored = true
            segment.CanCollide = false
            segment.CanQuery = false
            segment.CanTouch = false
            segment.CastShadow = false
            segment.Material = Enum.Material.Neon
            segment.Color = Color3.fromRGB(0, 170, 255)
            segment.Transparency = 0.25
            segment.Parent = auraFolder
            auraParts[index] = segment
        end
    end

    for index = 0, AURA_SEGMENTS - 1 do
        local angle1 = (index / AURA_SEGMENTS) * math.pi * 2
        local angle2 = ((index + 1) / AURA_SEGMENTS) * math.pi * 2
        local p1 = center + Vector3.new(math.cos(angle1) * studs, 0, math.sin(angle1) * studs)
        local p2 = center + Vector3.new(math.cos(angle2) * studs, 0, math.sin(angle2) * studs)
        local midpoint = (p1 + p2) / 2
        local segment = auraParts[index + 1]
        if segment then
            segment.Size = Vector3.new(0.15, 0.1, math.max((p2 - p1).Magnitude, 0.05))
            segment.CFrame = CFrame.lookAt(midpoint, p2)
        end
    end
end

local function refreshAuraBinding()
    if running and not auraConn then
        auraConn = RunService.Heartbeat:Connect(function()
            if not running then
                return
            end
            local rootPart = currentRoot()
            if not rootPart then
                return
            end
            drawAura(rootPart.Position, radius)
        end)
    elseif not running then
        if auraConn then
            auraConn:Disconnect()
            auraConn = nil
        end
        destroyAura()
    end
end

local function readSawmill(model, owner)
    local itemName = model:FindFirstChild("ItemName")
    local item = itemName and itemName.Value
    if not sawmillProperties[item] then
        return nil
    end
    local ownerValue = model:FindFirstChild("Owner")
    if not ownerValue or ownerValue.Value ~= owner then
        return nil
    end

    local conveyor = model:FindFirstChild("Conveyor")
    local conveyorModel = conveyor and conveyor:FindFirstChild("Model")
    local settings = model:FindFirstChild("Settings")
    local alert = model:FindFirstChild("BlockageAlert")
    local dimX = settings and settings:FindFirstChild("DimX")
    local dimZ = settings and settings:FindFirstChild("DimZ")
    if not (conveyorModel and dimX and dimZ and alert and alert:IsA("BasePart")) then
        return nil
    end

    local pos1
    local pos2
    for _, part in ipairs(conveyorModel:GetChildren()) do
        if part:IsA("BasePart") then
            if not pos1 then
                pos1 = part.Position
            else
                pos2 = part.Position
                break
            end
        end
    end
    if not pos1 or not pos2 then
        return nil
    end

    local diff = Vector3.new(round(pos2.X - pos1.X), round(pos2.Y - pos1.Y), round(pos2.Z - pos1.Z))
    local dir = Vector3.new(diff.X, 0, diff.Z)
    local rot
    if math.abs(dir.X) >= math.abs(dir.Z) then
        rot = CFrame.Angles(0, 0, math.rad(90) * math.sign(dir.X ~= 0 and dir.X or 1))
    else
        rot = CFrame.Angles(math.rad(90) * math.sign(dir.Z ~= 0 and dir.Z or 1), 0, 0)
    end

    local adjustment = 5
    local blockage = Vector3.new(alert.Position.X, alert.Position.Y - 1, alert.Position.Z)
    local tp = CFrame.new(blockage) + Vector3.new(diff.X * adjustment, -0.025, diff.Z * adjustment)

    return {
        Name = item,
        tpPosition = tp.Position,
        x = dimX.Value,
        y = dimZ.Value,
        rot = rot,
    }
end

local function getPlayerSawmills(owner)
    local sawmills = {}
    local models = Workspace:FindFirstChild("PlayerModels")
    if not models then
        return sawmills
    end
    for _, model in ipairs(models:GetChildren()) do
        local ok, entry = pcall(readSawmill, model, owner)
        if ok and entry then
            table.insert(sawmills, entry)
        end
    end
    return sawmills
end

local function pause(seconds, alive)
    local left = math.max(seconds, 0)
    while left > 0 and alive() do
        local slice = math.min(left, 0.1)
        task.wait(slice)
        left -= slice
    end
end

local function moveLogs(player, sawmills, alive)
    local logs = Workspace:FindFirstChild("LogModels")
    if not logs then
        return
    end

    local function loadLog(log)
        local ownerValue = log:FindFirstChild("Owner")
        if not ownerValue or log.Name == "PlaceholderPart" then
            return
        end
        if ownerValue.Value ~= nil and ownerValue.Value ~= player then
            return
        end

        local treeClass = log:FindFirstChild("TreeClass")
        if treeClass and not treeTypes[treeClass.Value] then
            return
        end

        local woodSection = log:FindFirstChild("WoodSection")
        local target = log:FindFirstChild("Main") or log:FindFirstChildWhichIsA("BasePart")
        if not (woodSection and woodSection:IsA("BasePart") and target and target:IsA("BasePart")) then
            return
        end

        local rootPart = currentRoot()
        if not rootPart or not alive() then
            return
        end
        local flat = (rootPart.Position - target.Position) * Vector3.new(1, 0, 1)
        if flat.Magnitude > radius then
            return
        end

        if woodSection.Size.X * woodSection.Size.Z < 0.24 then
            log:MoveTo(SELL_POSITION)
            return
        end
        if woodSection.Size.X > 2.6 or woodSection.Size.Z > 2.6 then
            return
        end

        local highestSawmill
        local highestSize = 0
        local woodVolume = woodSection.Size.X * woodSection.Size.Z * woodSection.Size.Y
        for index, sawmill in ipairs(sawmills) do
            local sawmillSize = sawmill.x * sawmill.y * 0.25
            if woodVolume >= sawmillSize and sawmillSize > highestSize then
                highestSize = sawmillSize
                highestSawmill = index
            end
        end

        local chosen = highestSawmill and sawmills[highestSawmill]
        if not chosen then
            return
        end
        local props = sawmillProperties[chosen.Name]
        if not props or woodSection.Size.Y > props.length then
            return
        end
        if not alive() then
            return
        end

        woodSection.CFrame = CFrame.new(chosen.tpPosition) * chosen.rot
        ReplicatedStorage.Interaction.ClientIsDragging:FireServer(log)
        pause(target.Size.Y / 2, alive)
    end

    for _, log in ipairs(logs:GetChildren()) do
        if not alive() then
            return
        end
        local ok, err = pcall(loadLog, log)
        if not ok then
            local message = tostring(err)
            if message ~= lastLogErr then
                lastLogErr = message
                warn("[Jell] SawmillLoader " .. message)
            end
        end
    end
end

local function step(alive)
    local sawmillPlayer = findPlayer(sawmillOwner)
    local woodPlayer = findPlayer(woodOwner)
    if not sawmillPlayer or not woodPlayer then
        restorePermission()
        api.setStatus("Select players")
        return
    end
    if not allow(sawmillPlayer) then
        api.setStatus("No permissions")
        return
    end
    local sawmills = getPlayerSawmills(sawmillPlayer)
    if #sawmills == 0 then
        api.setStatus("No sawmills")
        return
    end
    api.setStatus("Running")
    moveLogs(woodPlayer, sawmills, alive)
end

function api.setStatus(text)
    statusText = text
    if statusLabel and statusLabel.Parent then
        statusLabel.Text = text
    end
end

local function paintRun()
    if not (startBtn and startBtn.Parent) then
        return
    end
    if running then
        startBtn.Text = "Stop"
        startBtn.BackgroundColor3 = RED
        startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        startBtn.Text = "Start"
        startBtn.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
        startBtn.TextColor3 = Color3.fromRGB(18, 18, 18)
    end
end

local function paintOwners()
    if sawmillCaption and sawmillCaption.Parent then
        sawmillCaption.Text = ownerLabel(sawmillOwner)
    end
    if woodCaption and woodCaption.Parent then
        woodCaption.Text = ownerLabel(woodOwner)
    end
end

local function paintRadius()
    if radiusLabel and radiusLabel.Parent then
        radiusLabel.Text = "Radius  " .. tostring(radius)
    end
    if radiusFill and radiusFill.Parent then
        local span = RADIUS_MAX - RADIUS_MIN
        radiusFill.Size = UDim2.new((radius - RADIUS_MIN) / span, 0, 1, 0)
    end
end

function api.start()
    if running then
        return
    end
    running = true
    runToken += 1
    local token = runToken
    lastLogErr = nil
    paintRun()
    refreshAuraBinding()
    task.spawn(function()
        local function alive()
            return running and token == runToken
        end
        while alive() do
            local stepOk, stepErr = xpcall(function()
                step(alive)
            end, debug.traceback)
            if not alive() then
                break
            end
            if not stepOk then
                local message = tostring(stepErr)
                if message ~= lastLogErr then
                    lastLogErr = message
                    warn("[Jell] SawmillLoader " .. message)
                end
                api.setStatus("Error")
                task.wait(1)
            else
                lastLogErr = nil
                task.wait(0.25)
            end
        end
    end)
end

function api.stop()
    local wasRunning = running
    running = false
    runToken += 1
    restorePermission()
    if wasRunning then
        api.setStatus("Stopped")
    end
    paintRun()
    refreshAuraBinding()
end

local function closeMenu()
    menuKind = nil
    if menu then
        menu:Destroy()
        menu = nil
    end
    if backdrop then
        backdrop:Destroy()
        backdrop = nil
    end
end

local function setOwner(kind, name)
    if kind == "sawmill" then
        sawmillOwner = name
    else
        woodOwner = name
    end
    paintOwners()
    saveConfig()
end

local function openMenu(kind, y)
    closeMenu()
    if not root then
        return
    end
    menuKind = kind
    menuY = y

    backdrop = make("TextButton", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 2,
    }, root)
    backdrop.MouseButton1Click:Connect(function()
        task.defer(closeMenu)
    end)

    local players = sortedPlayers()
    local current = kind == "sawmill" and sawmillOwner or woodOwner
    local height = math.min(#players * 22, 198)
    menu = make("ScrollingFrame", {
        Size = UDim2.new(1, -16, 0, height),
        Position = UDim2.fromOffset(8, y + 24),
        BackgroundColor3 = Color3.fromRGB(32, 32, 32),
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Color3.fromRGB(70, 70, 70),
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Active = true,
        ZIndex = 5,
    }, root)
    make("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, menu)

    for index, player in ipairs(players) do
        local picked = player
        local selected = picked.Name == current
        local row = make("TextButton", {
            Size = UDim2.new(1, 0, 0, 22),
            BackgroundColor3 = Color3.fromRGB(58, 58, 58),
            BackgroundTransparency = selected and 0 or 1,
            BorderSizePixel = 0,
            Font = Enum.Font.SourceSans,
            Text = playerLabel(picked),
            TextSize = 15,
            TextColor3 = TEXT,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            AutoButtonColor = false,
            LayoutOrder = index,
            ZIndex = 5,
        }, menu)
        make("UIPadding", {
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
        }, row)
        row.MouseButton1Click:Connect(function()
            setOwner(kind, picked.Name)
            task.defer(closeMenu)
        end)
    end
end

local function refreshPlayers()
    paintOwners()
    if menuKind then
        openMenu(menuKind, menuY)
    end
end

local function fieldLabel(text, y)
    make("TextLabel", {
        Size = UDim2.new(1, -16, 0, 16),
        Position = UDim2.fromOffset(8, y),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = text,
        TextSize = 14,
        TextColor3 = MUTED,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, root)
end

local function dropdownButton(y)
    local btn = make("TextButton", {
        Size = UDim2.new(1, -16, 0, 22),
        Position = UDim2.fromOffset(8, y),
        BackgroundColor3 = Color3.fromRGB(58, 58, 58),
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 3,
    }, root)
    local caption = make("TextLabel", {
        Size = UDim2.new(1, -22, 1, 0),
        Position = UDim2.fromOffset(6, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = "Select",
        TextSize = 15,
        TextColor3 = TEXT,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 3,
    }, btn)
    make("TextLabel", {
        Size = UDim2.fromOffset(16, 22),
        Position = UDim2.new(1, -16, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = "v",
        TextSize = 14,
        TextColor3 = MUTED,
        ZIndex = 3,
    }, btn)
    return btn, caption
end

local function radiusFromX(x)
    local width = radiusSlider.AbsoluteSize.X
    if width <= 0 then
        return radius
    end
    local alpha = math.clamp((x - radiusSlider.AbsolutePosition.X) / width, 0, 1)
    local span = RADIUS_MAX - RADIUS_MIN
    return math.clamp(math.floor(alpha * span + RADIUS_MIN + 0.5), RADIUS_MIN, RADIUS_MAX)
end

local function build(parent)
    root = make("Frame", {
        Name = "SawmillLoaderRoot",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
    }, parent)

    fieldLabel("Sawmill owner", 8)
    local sawmillBtn
    sawmillBtn, sawmillCaption = dropdownButton(26)
    fieldLabel("Wood owner", 58)
    local woodBtn
    woodBtn, woodCaption = dropdownButton(76)

    radiusLabel = make("TextLabel", {
        Size = UDim2.new(1, -16, 0, 16),
        Position = UDim2.fromOffset(8, 108),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = "Radius  " .. tostring(radius),
        TextSize = 14,
        TextColor3 = MUTED,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, root)

    radiusSlider = make("TextButton", {
        Size = UDim2.new(1, -16, 0, 14),
        Position = UDim2.fromOffset(8, 128),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    }, root)
    radiusFill = make("Frame", {
        Size = UDim2.new((radius - RADIUS_MIN) / (RADIUS_MAX - RADIUS_MIN), 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(230, 230, 230),
        BorderSizePixel = 0,
    }, radiusSlider)

    startBtn = make("TextButton", {
        Size = UDim2.new(1, -16, 0, 22),
        Position = UDim2.fromOffset(8, 156),
        BackgroundColor3 = Color3.fromRGB(230, 230, 230),
        BorderSizePixel = 0,
        Font = Enum.Font.SourceSans,
        Text = "Start",
        TextSize = 15,
        TextColor3 = Color3.fromRGB(18, 18, 18),
        AutoButtonColor = false,
        ZIndex = 3,
    }, root)

    statusLabel = make("TextLabel", {
        Size = UDim2.new(1, -16, 0, 16),
        Position = UDim2.fromOffset(8, 184),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = statusText,
        TextSize = 14,
        TextColor3 = Color3.fromRGB(140, 140, 140),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, root)

    sawmillBtn.MouseButton1Click:Connect(function()
        if menuKind == "sawmill" then
            closeMenu()
        else
            openMenu("sawmill", 26)
        end
    end)
    woodBtn.MouseButton1Click:Connect(function()
        if menuKind == "wood" then
            closeMenu()
        else
            openMenu("wood", 76)
        end
    end)
    startBtn.MouseButton1Click:Connect(function()
        closeMenu()
        if running then
            api.stop()
        else
            api.start()
        end
    end)

    radiusSlider.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return
        end
        radius = radiusFromX(input.Position.X)
        paintRadius()
        local dragging = true
        local moveConn
        local endConn
        moveConn = UserInputService.InputChanged:Connect(function(changed)
            if dragging and changed.UserInputType == Enum.UserInputType.MouseMovement then
                radius = radiusFromX(changed.Position.X)
                paintRadius()
            end
        end)
        endConn = UserInputService.InputEnded:Connect(function(ended)
            if ended.UserInputType ~= Enum.UserInputType.MouseButton1 then
                return
            end
            dragging = false
            moveConn:Disconnect()
            endConn:Disconnect()
            saveConfig()
        end)
    end)

    track(Players.PlayerAdded:Connect(refreshPlayers))
    track(Players.PlayerRemoving:Connect(function()
        task.defer(refreshPlayers)
    end))

    paintOwners()
    paintRadius()
    paintRun()
end

function api.mount(parent)
    if mounted then
        api.unmount()
    end
    build(parent)
    mounted = true
    refreshAuraBinding()
end

function api.unmount()
    mounted = false
    closeMenu()
    clearConns()
    if root then
        root:Destroy()
        root = nil
    end
    sawmillCaption = nil
    woodCaption = nil
    startBtn = nil
    radiusLabel = nil
    radiusFill = nil
    radiusSlider = nil
    statusLabel = nil
    refreshAuraBinding()
end

return api
