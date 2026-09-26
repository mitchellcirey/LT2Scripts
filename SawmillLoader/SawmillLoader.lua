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
local GREEN = Color3.fromRGB(70, 190, 105)

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
local selectedMillKey
local selectedModel
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
local auraStyle = "off"
local previewTransparency = 0.4
local fadeFrom = 0.4
local fadeStarted = 0
local millHighlight
local highlightDismissed = false
local AURA_PREVIEW = Color3.fromRGB(0, 170, 255)
local AURA_RUN = Color3.fromRGB(70, 210, 110)

local root
local sawmillCaption
local woodCaption
local millCaption
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
        sawmill = selectedMillKey,
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
    if type(data.sawmill) == "string" and data.sawmill ~= "" then
        selectedMillKey = data.sawmill
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

local function auraAppearance()
    if auraStyle == "run" then
        return AURA_RUN, 0.15
    end
    return AURA_PREVIEW, previewTransparency
end

local function drawAura(center, studs)
    if auraStyle == "off" then
        return
    end
    local color, transparency = auraAppearance()
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
            segment.Color = color
            segment.Transparency = transparency
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
            segment.Color = color
            segment.Transparency = transparency
            segment.Size = Vector3.new(0.45, 0.35, math.max((p2 - p1).Magnitude, 0.05))
            segment.CFrame = CFrame.lookAt(midpoint, p2)
        end
    end
end

local function floorPoint(rootPart)
    local origin = rootPart.Position
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local ignore = {}
    if Player.Character then
        table.insert(ignore, Player.Character)
    end
    if auraFolder then
        table.insert(ignore, auraFolder)
    end
    params.FilterDescendantsInstances = ignore
    local hit = Workspace:Raycast(origin, Vector3.new(0, -80, 0), params)
    local ground = origin.Y - 3
    if hit then
        local drop = origin.Y - hit.Position.Y
        if drop >= 0 and drop < 12 then
            ground = hit.Position.Y
        end
    end
    return Vector3.new(origin.X, ground + 0.4, origin.Z)
end

local function wantsAura()
    return auraStyle == "pulse" or auraStyle == "fade" or auraStyle == "run"
end

local function stopAuraConnection()
    if auraConn then
        auraConn:Disconnect()
        auraConn = nil
    end
end

local function stepAura()
    if auraStyle == "pulse" then
        local wave = (math.sin(os.clock() * 2.6) + 1) / 2
        previewTransparency = 0.05 + wave * 0.55
    elseif auraStyle == "fade" then
        local alpha = math.clamp((os.clock() - fadeStarted) / 0.55, 0, 1)
        previewTransparency = fadeFrom + (1 - fadeFrom) * alpha
        if alpha >= 1 then
            auraStyle = "off"
            stopAuraConnection()
            destroyAura()
            return
        end
    end
    if not wantsAura() then
        return
    end
    local rootPart = currentRoot()
    if not rootPart then
        return
    end
    drawAura(floorPoint(rootPart), radius)
end

local function refreshAuraBinding()
    if wantsAura() then
        if not auraConn then
            auraConn = RunService.Heartbeat:Connect(stepAura)
        end
        stepAura()
    else
        stopAuraConnection()
        destroyAura()
    end
end

local function showRadiusPreview()
    auraStyle = "pulse"
    refreshAuraBinding()
end

local function hideRadiusPreview()
    if running then
        auraStyle = "run"
        refreshAuraBinding()
        return
    end
    fadeFrom = previewTransparency
    fadeStarted = os.clock()
    auraStyle = "fade"
    refreshAuraBinding()
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
    local position = alert.Position
    if model:IsA("Model") then
        position = model:GetPivot().Position
    end

    return {
        Name = item,
        model = model,
        position = position,
        tpPosition = tp.Position,
        x = dimX.Value,
        y = dimZ.Value,
        rot = rot,
    }
end

local function millKey(entry)
    local position = entry.position
    return string.format(
        "%s|%d|%d|%d",
        entry.Name,
        math.floor(position.X + 0.5),
        math.floor(position.Y + 0.5),
        math.floor(position.Z + 0.5)
    )
end

local function millLabels(list)
    local totals = {}
    for _, entry in ipairs(list) do
        totals[entry.Name] = (totals[entry.Name] or 0) + 1
    end
    local seen = {}
    local labels = {}
    for index, entry in ipairs(list) do
        local count = (seen[entry.Name] or 0) + 1
        seen[entry.Name] = count
        if totals[entry.Name] > 1 then
            labels[index] = entry.Name .. " " .. tostring(count)
        else
            labels[index] = entry.Name
        end
    end
    return labels
end

local function findMill(list)
    for index, entry in ipairs(list) do
        if selectedModel and entry.model == selectedModel then
            return entry, index
        end
    end
    if not selectedMillKey then
        return nil, nil
    end
    for index, entry in ipairs(list) do
        if millKey(entry) == selectedMillKey then
            return entry, index
        end
    end
    return nil, nil
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

local function eachLoaderHighlight(callback)
    if millHighlight then
        callback(millHighlight)
    end
    local models = Workspace:FindFirstChild("PlayerModels")
    if not models then
        return
    end
    for _, desc in ipairs(models:GetDescendants()) do
        if desc:IsA("Highlight") and desc.Name == "SawmillLoaderHighlight" and desc ~= millHighlight then
            callback(desc)
        end
    end
end

local function clearHighlight()
    eachLoaderHighlight(function(highlight)
        if highlight.Parent then
            highlight:Destroy()
        end
    end)
    millHighlight = nil
end

local function dismissHighlight()
    highlightDismissed = true
    local fading = {}
    eachLoaderHighlight(function(highlight)
        if highlight.Parent then
            table.insert(fading, highlight)
        end
    end)
    millHighlight = nil
    if #fading == 0 then
        return
    end
    task.spawn(function()
        local started = os.clock()
        while os.clock() - started < 0.45 do
            local alpha = math.clamp((os.clock() - started) / 0.45, 0, 1)
            for _, highlight in ipairs(fading) do
                if highlight.Parent then
                    highlight.FillTransparency = 0.45 + (1 - 0.45) * alpha
                    highlight.OutlineTransparency = alpha
                end
            end
            task.wait()
        end
        for _, highlight in ipairs(fading) do
            if highlight.Parent then
                highlight:Destroy()
            end
        end
    end)
end

local function highlightModel(model, force)
    clearHighlight()
    if running or not model or not model.Parent then
        return
    end
    if highlightDismissed and not force then
        return
    end
    local highlight = Instance.new("Highlight")
    highlight.Name = "SawmillLoaderHighlight"
    highlight.Adornee = model
    highlight.FillColor = GREEN
    highlight.OutlineColor = Color3.fromRGB(190, 255, 205)
    highlight.FillTransparency = 0.45
    highlight.OutlineTransparency = 0
    highlight.Parent = model
    millHighlight = highlight
end

local function refreshHighlight()
    if highlightDismissed or running then
        clearHighlight()
        return
    end
    local owner = findPlayer(sawmillOwner)
    if not owner then
        clearHighlight()
        return
    end
    local entry = findMill(getPlayerSawmills(owner))
    if entry then
        selectedModel = entry.model
        highlightModel(entry.model)
    else
        clearHighlight()
    end
end

local function pause(seconds, alive)
    local left = math.max(seconds, 0)
    while left > 0 and alive() do
        local slice = math.min(left, 0.1)
        task.wait(slice)
        left -= slice
    end
end

local function moveLogs(player, chosen, alive)
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
    local chosen = findMill(sawmills)
    if not chosen then
        api.setStatus("Select sawmill")
        return
    end
    api.setStatus("Running")
    moveLogs(woodPlayer, chosen, alive)
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
        startBtn.BackgroundColor3 = GREEN
        startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end

local function millCaptionText()
    local owner = findPlayer(sawmillOwner)
    if not owner then
        return "Select"
    end
    local list = getPlayerSawmills(owner)
    local entry, index = findMill(list)
    if not entry then
        return "Select"
    end
    return millLabels(list)[index]
end

local function paintOwners()
    if sawmillCaption and sawmillCaption.Parent then
        sawmillCaption.Text = ownerLabel(sawmillOwner)
    end
    if woodCaption and woodCaption.Parent then
        woodCaption.Text = ownerLabel(woodOwner)
    end
    if millCaption and millCaption.Parent then
        millCaption.Text = millCaptionText()
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

local function beginRun()
    if running then
        return
    end
    running = true
    runToken += 1
    local token = runToken
    lastLogErr = nil
    dismissHighlight()
    auraStyle = "run"
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

local function releaseDrag()
    pcall(function()
        ReplicatedStorage.Interaction.ClientIsDragging:FireServer(nil)
    end)
end

local function endRun()
    local wasRunning = running
    running = false
    runToken += 1
    releaseDrag()
    pcall(restorePermission)
    if wasRunning then
        api.setStatus("Stopped")
    end
    auraStyle = "off"
    paintRun()
    refreshAuraBinding()
end

function api.start()
end

function api.stop()
    endRun()
end

local function closeMenu()
    local wasOpen = menuKind ~= nil
    menuKind = nil
    if menu then
        menu:Destroy()
        menu = nil
    end
    if backdrop then
        backdrop:Destroy()
        backdrop = nil
    end
    if wasOpen and not running then
        refreshHighlight()
    end
end

local function setOwner(kind, name)
    if kind == "sawmill" then
        if sawmillOwner ~= name then
            selectedMillKey = nil
            selectedModel = nil
        end
        sawmillOwner = name
        highlightDismissed = false
    else
        woodOwner = name
    end
    paintOwners()
    saveConfig()
    refreshHighlight()
end

local function setMill(entry)
    highlightDismissed = false
    selectedModel = entry.model
    selectedMillKey = millKey(entry)
    paintOwners()
    saveConfig()
    refreshHighlight()
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

    local rows = {}
    if kind == "mill" then
        local owner = findPlayer(sawmillOwner)
        local mills = owner and getPlayerSawmills(owner) or {}
        local labels = millLabels(mills)
        for index, entry in ipairs(mills) do
            local picked = entry
            table.insert(rows, {
                text = labels[index],
                selected = picked.model == selectedModel or millKey(picked) == selectedMillKey,
                choose = function()
                    setMill(picked)
                end,
                hover = function()
                    highlightModel(picked.model, true)
                end,
                unhover = function()
                    if running or highlightDismissed then
                        clearHighlight()
                        return
                    end
                    refreshHighlight()
                end,
            })
        end
    else
        local current = kind == "sawmill" and sawmillOwner or woodOwner
        for _, player in ipairs(sortedPlayers()) do
            local picked = player
            table.insert(rows, {
                text = playerLabel(picked),
                selected = picked.Name == current,
                choose = function()
                    setOwner(kind, picked.Name)
                end,
            })
        end
    end

    local height = math.clamp(#rows * 22, 22, 160)
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

    for index, item in ipairs(rows) do
        local row = make("TextButton", {
            Size = UDim2.new(1, 0, 0, 22),
            BackgroundColor3 = Color3.fromRGB(58, 58, 58),
            BackgroundTransparency = item.selected and 0 or 1,
            BorderSizePixel = 0,
            Font = Enum.Font.SourceSans,
            Text = item.text,
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
        if item.hover then
            row.MouseEnter:Connect(item.hover)
            row.MouseLeave:Connect(item.unhover)
        end
        row.MouseButton1Click:Connect(function()
            item.choose()
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
    fieldLabel("Sawmill", 108)
    local millBtn
    millBtn, millCaption = dropdownButton(126)

    radiusLabel = make("TextLabel", {
        Size = UDim2.new(1, -16, 0, 16),
        Position = UDim2.fromOffset(8, 158),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = "Radius  " .. tostring(radius),
        TextSize = 14,
        TextColor3 = MUTED,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, root)

    radiusSlider = make("TextButton", {
        Size = UDim2.new(1, -16, 0, 14),
        Position = UDim2.fromOffset(8, 178),
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
        Position = UDim2.fromOffset(8, 206),
        BackgroundColor3 = GREEN,
        BorderSizePixel = 0,
        Font = Enum.Font.SourceSans,
        Text = "Start",
        TextSize = 15,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        AutoButtonColor = false,
        ZIndex = 3,
    }, root)

    statusLabel = make("TextLabel", {
        Size = UDim2.new(1, -16, 0, 16),
        Position = UDim2.fromOffset(8, 234),
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
    millBtn.MouseButton1Click:Connect(function()
        if menuKind == "mill" then
            closeMenu()
        else
            openMenu("mill", 126)
        end
    end)
    startBtn.MouseButton1Click:Connect(function()
        if running then
            endRun()
        else
            beginRun()
        end
        pcall(closeMenu)
    end)

    radiusSlider.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return
        end
        radius = radiusFromX(input.Position.X)
        paintRadius()
        showRadiusPreview()
        local dragging = true
        local moveConn
        local endConn
        local function finishDrag()
            if not dragging then
                return
            end
            dragging = false
            if moveConn then
                moveConn:Disconnect()
            end
            if endConn then
                endConn:Disconnect()
            end
            hideRadiusPreview()
            saveConfig()
        end
        moveConn = UserInputService.InputChanged:Connect(function(changed)
            if not dragging or changed.UserInputType ~= Enum.UserInputType.MouseMovement then
                return
            end
            radius = radiusFromX(changed.Position.X)
            paintRadius()
            if auraStyle ~= "pulse" and not running then
                showRadiusPreview()
            end
        end)
        task.defer(function()
            if not dragging then
                return
            end
            if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                finishDrag()
                return
            end
            endConn = UserInputService.InputEnded:Connect(function(ended)
                if ended.UserInputType ~= Enum.UserInputType.MouseButton1 then
                    return
                end
                if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                    return
                end
                finishDrag()
            end)
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
    pcall(refreshHighlight)
    refreshAuraBinding()
end

function api.unmount()
    mounted = false
    closeMenu()
    clearHighlight()
    clearConns()
    if root then
        root:Destroy()
        root = nil
    end
    sawmillCaption = nil
    woodCaption = nil
    millCaption = nil
    if not running then
        auraStyle = "off"
    end
    startBtn = nil
    radiusLabel = nil
    radiusFill = nil
    radiusSlider = nil
    statusLabel = nil
    refreshAuraBinding()
end

return api
