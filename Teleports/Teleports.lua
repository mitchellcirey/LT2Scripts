local Services = setmetatable({}, {
    __index = function(_, index)
        return game:GetService(index)
    end,
})

local Players = Services.Players
local Workspace = Services.Workspace

local Player = Players.LocalPlayer

local TEXT = Color3.fromRGB(230, 230, 230)
local MUTED = Color3.fromRGB(160, 160, 160)
local DARK = Color3.fromRGB(18, 18, 18)
local BUTTON = Color3.fromRGB(230, 230, 230)
local FIELD = Color3.fromRGB(58, 58, 58)
local MENU = Color3.fromRGB(32, 32, 32)
local HOVER = Color3.fromRGB(120, 120, 120)

local ROW_H = 22
local MENU_MAX = 176

local VEHICLES = {
    Pickup1_Vehicle = {
        Size = Vector3.new(10, 6, 18),
        Offset = CFrame.new(0, 3, 11.5),
    },
    UtilityTruck_Vehicle = {
        Size = Vector3.new(7, 3, 10),
        Offset = CFrame.new(0, 1.75, 5.75),
    },
    UtilityTruck2_Vehicle = {
        Size = Vector3.new(8, 3, 11),
        Offset = CFrame.new(0, 1.75, 6),
    },
}

local STORES = {
    ["Wood R Us"] = Vector3.new(265, 3, 57),
    ["Land Store"] = Vector3.new(257, 3, -99),
    ["Boxed Cars"] = Vector3.new(510, 3, -1465),
    ["Fancy Furnishings"] = Vector3.new(500, 3, -1720),
    ["Links Logic"] = Vector3.new(4607, 7, -795),
    ["Fine Arts Shop"] = Vector3.new(5207, -166, 719),
    ["Bob's Shack"] = Vector3.new(260, 8.4, -2542),
}

local REGIONS = {
    ["Cherry Meadow"] = Vector3.new(220.9, 59.8, 1305.8),
    ["Volcano"] = Vector3.new(-1585, 622, 1140),
    ["Swamp"] = Vector3.new(-1209, 132, -801),
    ["Tiaga Peak"] = Vector3.new(1448, 413, 3186),
    ["Snow Biome"] = Vector3.new(890, 59.8, 1195.6),
    ["SnowGlow Biome"] = Vector3.new(-1087.3, -5.9, -946.2),
    ["Cave"] = Vector3.new(3581, -179.5, 430),
    ["Palm Island 1"] = Vector3.new(2000, -6, -1500),
    ["Lonecave"] = Vector3.new(115, -214, -1095),
}

local PLACES = {
    ["Bridge"] = Vector3.new(112.3, 11, -782.4),
    ["Docks"] = Vector3.new(1114, -1.2, -197),
    ["The Den"] = Vector3.new(323, 41.8, 1930),
    ["Safari"] = Vector3.new(111.9, 11, -998.8),
    ["The Cabin"] = Vector3.new(1244, 63.6, 2306),
    ["Bird Cave"] = Vector3.new(4813.1, 17.7, -978.8),
    ["Strange Man"] = Vector3.new(1061, 16.8, 1131),
    ["Green Box"] = Vector3.new(-1668.1, 349.6, 1475.4),
    ["Light House"] = Vector3.new(1464.8, 355.2, 3257.2),
    ["Shrine of Sight"] = Vector3.new(-1600, 195.4, 919),
    ["Fridge"] = Vector3.new(550.17, -1, -1714.16),
}

local mounted = false
local selectedTarget = nil
local root = nil
local backdrop = nil
local menu = nil
local menuAnchor = nil
local playerCaption = nil
local playerField = nil
local playerBtn = nil
local addedConn = nil
local removingConn = nil

local function make(className, props, parent)
    local inst = Instance.new(className)
    for key, value in pairs(props) do
        inst[key] = value
    end
    inst.Parent = parent
    return inst
end

local function youTag()
    return Player.DisplayName .. " (You)"
end

local function sortedKeys(data)
    local keys = {}
    for key in pairs(data) do
        table.insert(keys, key)
    end
    table.sort(keys)
    return keys
end

local function placeOptions(data)
    local options = {}
    for _, name in ipairs(sortedKeys(data)) do
        table.insert(options, { id = name, label = name })
    end
    return options
end

local function playerOptions()
    local names = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Player then
            table.insert(names, player.DisplayName)
        end
    end
    table.sort(names)
    local options = {
        { id = youTag(), label = youTag() },
    }
    for _, name in ipairs(names) do
        table.insert(options, { id = name, label = name })
    end
    return options
end

local function vehicleSpecs(vehicleModel)
    local itemName = vehicleModel:FindFirstChild("ItemName")
    if itemName and itemName:IsA("StringValue") then
        return VEHICLES[itemName.Value]
    end
    return nil
end

local function teleport(pos)
    local character = Player.Character
    if not character then
        return
    end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        return
    end

    local targetCFrame = CFrame.new(pos + Vector3.new(0, 1, 0))
    local seatPart = humanoid and humanoid.SeatPart
    local vehicleModel = seatPart and seatPart:FindFirstAncestorOfClass("Model")
    if not vehicleModel then
        rootPart.CFrame = targetCFrame
        return
    end

    local anchored = {}
    for _, descendant in ipairs(vehicleModel:GetDescendants()) do
        if descendant:IsA("BasePart") then
            anchored[descendant] = descendant.Anchored
            descendant.Anchored = true
        end
    end

    local preset = vehicleSpecs(vehicleModel)
    if preset then
        local currentPivot = vehicleModel:GetPivot()
        local movement = targetCFrame * currentPivot:Inverse()
        local params = OverlapParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = { vehicleModel, character }
        params.RespectCanCollide = false
        local looseItems = Workspace:GetPartBoundsInBox(currentPivot * preset.Offset, preset.Size, params)
        local moved = {}
        for _, part in ipairs(looseItems) do
            if part:IsA("BasePart") and not part.Anchored then
                local model = part:FindFirstAncestorOfClass("Model")
                if model and model ~= Workspace then
                    if not moved[model] then
                        moved[model] = true
                        model:PivotTo(movement * model:GetPivot())
                    end
                elseif not moved[part] then
                    moved[part] = true
                    part.CFrame = movement * part.CFrame
                end
            end
        end
    end

    vehicleModel:PivotTo(targetCFrame)
    task.wait(0.05)
    for part, wasAnchored in pairs(anchored) do
        if part and part.Parent then
            part.Anchored = wasAnchored
        end
    end
end

local function go(pos)
    task.spawn(function()
        local ok, err = xpcall(function()
            teleport(pos)
        end, debug.traceback)
        if not ok then
            warn("[Jell] Teleports " .. tostring(err))
        end
    end)
end

local function ownerName(owner)
    if typeof(owner) == "Instance" and owner:IsA("Player") then
        return owner.DisplayName
    end
    if typeof(owner) == "string" then
        return owner
    end
    return ""
end

local function teleportToPlayer()
    if not selectedTarget or selectedTarget == Player.DisplayName then
        return
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player.DisplayName == selectedTarget and player.Character then
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                go(rootPart.Position)
            end
            return
        end
    end
end

local function teleportToPlot()
    local targetDisplay = selectedTarget or Player.DisplayName
    local properties = Workspace:FindFirstChild("Properties")
    if not properties then
        return
    end
    for _, plot in ipairs(properties:GetChildren()) do
        local owner = plot:FindFirstChild("Owner")
        if owner and ownerName(owner.Value) == targetDisplay then
            local origin = plot:FindFirstChild("OriginSquare")
                or plot:FindFirstChild("Origin")
                or plot:FindFirstChildOfClass("BasePart")
            if origin then
                go(origin.Position)
            end
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

local function paintChoice(label, text, placeholder)
    if not (label and label.Parent) then
        return
    end
    if text and text ~= "" then
        label.Text = text
        label.TextColor3 = TEXT
    else
        label.Text = placeholder
        label.TextColor3 = MUTED
    end
end

local function paintPlayerButton()
    if not (playerBtn and playerBtn.Parent) then
        return
    end
    local enabled = selectedTarget ~= nil and selectedTarget ~= Player.DisplayName
    playerBtn.Active = enabled
    playerBtn.BackgroundColor3 = enabled and BUTTON or FIELD
    playerBtn.TextColor3 = enabled and DARK or MUTED
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
        row.MouseEnter:Connect(function()
            row.BackgroundColor3 = HOVER
            row.BackgroundTransparency = 0
        end)
        row.MouseLeave:Connect(function()
            row.BackgroundColor3 = FIELD
            row.BackgroundTransparency = picked and 0 or 1
        end)
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
        TextColor3 = MUTED,
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
        Font = Enum.Font.SourceSans,
        Text = text,
        TextSize = 15,
        TextColor3 = TEXT,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)
    local line = make("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = Color3.fromRGB(70, 70, 70),
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

local function action(parent, text, order)
    local button = make("TextButton", {
        Size = UDim2.new(1, 0, 0, ROW_H),
        BackgroundColor3 = BUTTON,
        BorderSizePixel = 0,
        Font = Enum.Font.SourceSans,
        Text = text,
        TextSize = 15,
        TextColor3 = DARK,
        AutoButtonColor = false,
        LayoutOrder = order,
    }, parent)
    return button
end

local function refreshPlayers()
    if not mounted then
        return
    end
    local stillHere = false
    if selectedTarget == Player.DisplayName then
        stillHere = true
    else
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Player and player.DisplayName == selectedTarget then
                stillHere = true
                break
            end
        end
    end
    if selectedTarget and not stillHere then
        selectedTarget = nil
        paintChoice(playerCaption, nil, "Select player")
        paintPlayerButton()
    end
    if menuAnchor == playerField then
        closeMenu()
    end
end

local function bindPlayers()
    addedConn = Players.PlayerAdded:Connect(refreshPlayers)
    removingConn = Players.PlayerRemoving:Connect(function()
        task.defer(refreshPlayers)
    end)
end

local function unbindPlayers()
    if addedConn then
        addedConn:Disconnect()
        addedConn = nil
    end
    if removingConn then
        removingConn:Disconnect()
        removingConn = nil
    end
end

local function build(parent)
    root = make("Frame", {
        Name = "TeleportsRoot",
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

    heading(list, "World teleports", 1)

    local storePick = nil
    local regionPick = nil
    local placePick = nil
    local storeBtn, storeLabel = field(list, "Stores", 2)
    local regionBtn, regionLabel = field(list, "Tree regions", 3)
    local placeBtn, placeLabel = field(list, "Other POIs", 4)
    paintChoice(storeLabel, nil, "Select store")
    paintChoice(regionLabel, nil, "Select region")
    paintChoice(placeLabel, nil, "Select location")

    storeBtn.MouseButton1Click:Connect(function()
        openMenu(storeBtn, placeOptions(STORES), storePick, function(id)
            storePick = id
            paintChoice(storeLabel, id, "Select store")
            local pos = STORES[id]
            if pos then
                go(pos)
            end
        end)
    end)
    regionBtn.MouseButton1Click:Connect(function()
        openMenu(regionBtn, placeOptions(REGIONS), regionPick, function(id)
            regionPick = id
            paintChoice(regionLabel, id, "Select region")
            local pos = REGIONS[id]
            if pos then
                go(pos)
            end
        end)
    end)
    placeBtn.MouseButton1Click:Connect(function()
        openMenu(placeBtn, placeOptions(PLACES), placePick, function(id)
            placePick = id
            paintChoice(placeLabel, id, "Select location")
            local pos = PLACES[id]
            if pos then
                go(pos)
            end
        end)
    end)

    heading(list, "Player & plot", 5)

    local playerBtnField, caption = field(list, "Select player", 6)
    playerField = playerBtnField
    playerCaption = caption
    paintChoice(playerCaption, nil, "Select player")
    playerBtnField.MouseButton1Click:Connect(function()
        local current = selectedTarget == Player.DisplayName and youTag() or selectedTarget
        openMenu(playerBtnField, playerOptions(), current, function(id)
            if id == youTag() then
                selectedTarget = Player.DisplayName
                paintChoice(playerCaption, id, "Select player")
            else
                selectedTarget = id
                paintChoice(playerCaption, id, "Select player")
            end
            paintPlayerButton()
        end)
    end)

    playerBtn = action(list, "Teleport to player", 7)
    paintPlayerButton()
    playerBtn.MouseButton1Click:Connect(function()
        closeMenu()
        teleportToPlayer()
    end)

    local plotBtn = action(list, "Teleport to plot", 8)
    plotBtn.MouseButton1Click:Connect(function()
        closeMenu()
        teleportToPlot()
    end)
end

local api = {}

function api.start()
end

function api.stop()
end

function api.mount(parent)
    if mounted then
        api.unmount()
    end
    selectedTarget = nil
    build(parent)
    bindPlayers()
    mounted = true
end

function api.unmount()
    mounted = false
    unbindPlayers()
    closeMenu()
    if root then
        root:Destroy()
        root = nil
    end
    playerCaption = nil
    playerField = nil
    playerBtn = nil
    selectedTarget = nil
end

return api
