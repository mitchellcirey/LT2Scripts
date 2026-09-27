local Services = setmetatable({}, {
    __index = function(_, index)
        return game:GetService(index)
    end,
})

local Players = Services.Players
local Workspace = Services.Workspace
local ReplicatedStorage = Services.ReplicatedStorage

local Player = Players.LocalPlayer

local TEXT = Color3.fromRGB(230, 230, 230)
local MUTED = Color3.fromRGB(160, 160, 160)
local DARK = Color3.fromRGB(18, 18, 18)
local BUTTON = Color3.fromRGB(230, 230, 230)
local FIELD = Color3.fromRGB(58, 58, 58)
local LABEL = Color3.fromRGB(210, 210, 210)
local RED = Color3.fromRGB(210, 70, 70)
local CONFIRM = Color3.fromRGB(160, 40, 40)
local CONFIRM_TEXT = Color3.fromRGB(255, 160, 160)

local ROW_H = 22
local BTN_W = 88
local SAVE_COOLDOWN = 60

local mounted = false
local root = nil
local connections = {}
local saveReadyAt = 0
local saveToken = 0
local workToken = 0
local landUpdatePending = false
local wiping = false
local wipeConfirm = false
local wipeResetThread = nil
local deleteConfirm = false
local deleteResetThread = nil

local saveBtn = nil
local claimBtn = nil
local expandBtn = nil
local wipeBtn = nil
local deleteBtn = nil

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

local function setEnabled(button, enabled)
    if not (button and button.Parent) then
        return
    end
    button:SetAttribute("Enabled", enabled)
    button.Active = enabled
    button.BackgroundColor3 = enabled and BUTTON or FIELD
    button.TextColor3 = enabled and DARK or MUTED
end

local function isEnabled(button)
    return button and button:GetAttribute("Enabled") ~= false
end

local function flash(button, text, restore)
    if not (button and button.Parent) then
        return
    end
    button.Text = text
    task.delay(2, function()
        if button.Parent and button.Text == text then
            button.Text = restore
            local enabled = button:GetAttribute("Enabled")
            if enabled ~= nil then
                setEnabled(button, enabled)
            end
        end
    end)
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

local function actionRow(parent, labelText, buttonText, order, labelColor)
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
        TextColor3 = labelColor or LABEL,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, row)
    local button = make("TextButton", {
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
    button:SetAttribute("Enabled", true)
    return button
end

local function paintSave()
    if not (saveBtn and saveBtn.Parent) then
        return
    end
    local left = math.max(0, math.ceil(saveReadyAt - os.clock()))
    if left > 0 then
        saveBtn.Text = tostring(left) .. "s"
        setEnabled(saveBtn, false)
    else
        saveBtn.Text = "Save"
        setEnabled(saveBtn, true)
    end
end

local function runSaveCountdown()
    saveToken += 1
    local token = saveToken
    task.spawn(function()
        while token == saveToken and saveReadyAt > os.clock() do
            if mounted then
                paintSave()
            end
            task.wait(1)
        end
        if token == saveToken and mounted then
            paintSave()
        end
    end)
end

local function saveSlot()
    if saveReadyAt > os.clock() then
        return
    end
    local currentSlot = Player:FindFirstChild("CurrentSaveSlot")
    if not currentSlot or currentSlot.Value <= 0 then
        warn("[Jell] Management: No active slot")
        flash(saveBtn, "No slot", "Save")
        return
    end
    local requests = ReplicatedStorage:FindFirstChild("LoadSaveRequests")
    local requestSave = requests and requests:FindFirstChild("RequestSave")
    if not requestSave then
        warn("[Jell] Management: Save remote not found")
        flash(saveBtn, "Missing", "Save")
        return
    end
    local ok, result = pcall(function()
        return requestSave:InvokeServer(currentSlot.Value)
    end)
    if not ok then
        warn("[Jell] Management: Save failed: " .. tostring(result))
        flash(saveBtn, "Failed", "Save")
        return
    end
    saveReadyAt = os.clock() + SAVE_COOLDOWN
    runSaveCountdown()
end

local function updateLandButtons()
    local properties = Workspace:FindFirstChild("Properties")
    if not properties then
        return
    end
    local hasLand = false
    local landPieceCount = 0
    for _, plot in ipairs(properties:GetChildren()) do
        local owner = plot:FindFirstChild("Owner")
        if owner and owner.Value == Player then
            hasLand = true
            for _, child in ipairs(plot:GetChildren()) do
                if child:IsA("BasePart") then
                    landPieceCount += 1
                end
            end
            break
        end
    end
    setEnabled(claimBtn, not hasLand)
    setEnabled(expandBtn, hasLand and landPieceCount < 25)
end

local function scheduleLandUpdate()
    if landUpdatePending or not mounted then
        return
    end
    landUpdatePending = true
    task.delay(0.5, function()
        landUpdatePending = false
        if mounted then
            updateLandButtons()
        end
    end)
end

local function watchPlotOwner(plot)
    local owner = plot:FindFirstChild("Owner")
    if owner and owner:IsA("ObjectValue") then
        connect(owner.Changed, scheduleLandUpdate)
    end
end

local function bindProperties(properties)
    for _, plot in ipairs(properties:GetChildren()) do
        watchPlotOwner(plot)
    end
    connect(properties.ChildAdded, function(plot)
        watchPlotOwner(plot)
        scheduleLandUpdate()
    end)
    connect(properties.ChildRemoved, scheduleLandUpdate)
    updateLandButtons()
end

local function watchLand()
    local properties = Workspace:FindFirstChild("Properties")
    if properties then
        bindProperties(properties)
        return
    end
    local conn
    conn = Workspace.ChildAdded:Connect(function(child)
        if child.Name ~= "Properties" or not mounted then
            return
        end
        conn:Disconnect()
        bindProperties(child)
    end)
    table.insert(connections, conn)
end

local function claimLand()
    if not isEnabled(claimBtn) then
        return
    end
    local properties = Workspace:FindFirstChild("Properties")
    local purchasing = ReplicatedStorage:FindFirstChild("PropertyPurchasing")
    local claimRemote = purchasing and purchasing:FindFirstChild("ClientPurchasedProperty")
    if not properties or not claimRemote then
        warn("[Jell] Management: Claim remote not found")
        flash(claimBtn, "Missing", "Claim")
        return
    end
    for _, plot in ipairs(properties:GetChildren()) do
        local owner = plot:FindFirstChild("Owner")
        local origin = plot:FindFirstChild("OriginSquare")
        if owner and origin and owner.Value == nil then
            claimRemote:FireServer(plot, origin.OriginCFrame.Value.p + Vector3.new(0, 3, 0))
            flash(claimBtn, "Claimed", "Claim")
            local token = workToken
            task.spawn(function()
                task.wait(0.5)
                if token ~= workToken or not mounted then
                    return
                end
                local character = Player.Character
                if character then
                    character:MoveTo(origin.Position)
                end
                scheduleLandUpdate()
            end)
            return
        end
    end
    flash(claimBtn, "None", "Claim")
end

local function expandLand()
    if not isEnabled(expandBtn) then
        return
    end
    local properties = Workspace:FindFirstChild("Properties")
    local purchasing = ReplicatedStorage:FindFirstChild("PropertyPurchasing")
    local expandRemote = purchasing and purchasing:FindFirstChild("ClientExpandedProperty")
    if not properties or not expandRemote then
        warn("[Jell] Management: Expand remote not found")
        flash(expandBtn, "Missing", "Expand")
        return
    end
    local playerPlot = nil
    for _, plot in ipairs(properties:GetChildren()) do
        local owner = plot:FindFirstChild("Owner")
        if owner and owner.Value == Player then
            playerPlot = plot
            break
        end
    end
    local origin = playerPlot and playerPlot:FindFirstChild("OriginSquare")
    if not origin then
        flash(expandBtn, "No land", "Expand")
        return
    end
    local spos = origin.Position
    local offsets = {
        { 0, 40 }, { 0, -40 }, { 40, 0 }, { -40, 0 },
        { 40, 40 }, { 40, -40 }, { -40, 40 }, { -40, -40 },
        { 80, 0 }, { -80, 0 }, { 0, 80 }, { 0, -80 },
        { 80, 80 }, { 80, -80 }, { -80, 80 }, { -80, -80 },
        { 40, 80 }, { -40, 80 }, { 80, 40 }, { 80, -40 },
        { -80, 40 }, { -80, -40 }, { 40, -80 }, { -40, -80 },
    }
    local token = workToken
    setEnabled(expandBtn, false)
    task.spawn(function()
        for _, offset in ipairs(offsets) do
            if token ~= workToken or not mounted then
                return
            end
            expandRemote:FireServer(playerPlot, CFrame.new(spos.X + offset[1], spos.Y, spos.Z + offset[2]))
            task.wait(0.05)
        end
        if token == workToken and mounted then
            flash(expandBtn, "Done", "Expand")
            scheduleLandUpdate()
        end
    end)
end

local function findOwnedSoldSign()
    local playerModels = Workspace:FindFirstChild("PlayerModels")
    if not playerModels then
        return nil
    end
    for _, model in ipairs(playerModels:GetChildren()) do
        if model:IsA("Model") then
            local owner = model:FindFirstChild("Owner")
            local ownerStr = owner and owner:FindFirstChild("OwnerString")
            if ownerStr and ownerStr.Value == Player.Name then
                local settings = model:FindFirstChild("Settings")
                local soldFlag = settings and settings:FindFirstChild("PropertySoldSign")
                if soldFlag and soldFlag.Value == true then
                    return model
                end
            end
        end
    end
    return nil
end

local function deleteSoldSign(button)
    local interaction = ReplicatedStorage:FindFirstChild("Interaction")
    local destroyStructure = interaction and interaction:FindFirstChild("DestroyStructure")
    if not destroyStructure then
        warn("[Jell] Management: DestroyStructure remote not found")
        flash(button, "Missing", "Delete")
        return
    end
    local sign = findOwnedSoldSign()
    if not sign then
        warn("[Jell] Management: No sold property sign found")
        flash(button, "No sign", "Delete")
        return
    end
    destroyStructure:FireServer(sign)
    flash(button, "Deleted", "Delete")
end

local function resetDelete()
    deleteConfirm = false
    if deleteResetThread then
        task.cancel(deleteResetThread)
        deleteResetThread = nil
    end
    if deleteBtn and deleteBtn.Parent then
        deleteBtn.Text = "Delete"
        setEnabled(deleteBtn, true)
    end
end

local function onDeleteClick()
    if not isEnabled(deleteBtn) then
        return
    end
    if not deleteConfirm then
        deleteConfirm = true
        deleteBtn.BackgroundColor3 = CONFIRM
        deleteBtn.TextColor3 = CONFIRM_TEXT
        deleteBtn.Text = "Confirm?"
        if deleteResetThread then
            task.cancel(deleteResetThread)
        end
        deleteResetThread = task.delay(3, function()
            deleteResetThread = nil
            if mounted then
                resetDelete()
            end
        end)
        return
    end
    if deleteResetThread then
        task.cancel(deleteResetThread)
        deleteResetThread = nil
    end
    deleteConfirm = false
    setEnabled(deleteBtn, true)
    deleteSoldSign(deleteBtn)
end

local function resetWipe()
    wipeConfirm = false
    if wipeResetThread then
        task.cancel(wipeResetThread)
        wipeResetThread = nil
    end
    if wipeBtn and wipeBtn.Parent and not wiping then
        wipeBtn.Text = "Wipe"
        setEnabled(wipeBtn, true)
    end
end

local function wipePlot()
    local interaction = ReplicatedStorage:FindFirstChild("Interaction")
    local destroyRemote = interaction and interaction:FindFirstChild("DestroyStructure")
    local playerModels = Workspace:FindFirstChild("PlayerModels")
    if not playerModels or not destroyRemote then
        warn("[Jell] Management: Wipe system unavailable")
        setEnabled(wipeBtn, true)
        flash(wipeBtn, "Missing", "Wipe")
        return
    end
    local toDestroy = {}
    for _, model in ipairs(playerModels:GetChildren()) do
        local owner = model:FindFirstChild("Owner")
        if owner and owner.Value == Player then
            local main = model:FindFirstChild("Main") or model:FindFirstChildWhichIsA("BasePart")
            if main then
                table.insert(toDestroy, model)
            end
        end
    end
    if #toDestroy == 0 then
        warn("[Jell] Management: Nothing found to clear")
        setEnabled(wipeBtn, true)
        flash(wipeBtn, "Empty", "Wipe")
        return
    end
    wiping = true
    setEnabled(wipeBtn, false)
    wipeBtn.Text = "Wiping"
    local token = workToken
    task.spawn(function()
        local count = 0
        for _, model in ipairs(toDestroy) do
            if token ~= workToken or not mounted then
                wiping = false
                return
            end
            if model.Parent then
                local timeout = 5
                local elapsed = 0
                while model.Parent ~= nil and elapsed < timeout do
                    if token ~= workToken or not mounted then
                        wiping = false
                        return
                    end
                    pcall(destroyRemote.FireServer, destroyRemote, model)
                    task.wait(0.05)
                    elapsed += 0.05
                end
                if model.Parent == nil then
                    count += 1
                else
                    warn(("[Jell] Management: Timed out on '%s'"):format(model.Name))
                end
            end
        end
        wiping = false
        if token == workToken and mounted and wipeBtn and wipeBtn.Parent then
            setEnabled(wipeBtn, true)
            if count > 0 then
                flash(wipeBtn, "Wiped", "Wipe")
            else
                flash(wipeBtn, "Failed", "Wipe")
            end
        end
    end)
end

local function onWipeClick()
    if wiping or not isEnabled(wipeBtn) then
        return
    end
    if not wipeConfirm then
        wipeConfirm = true
        wipeBtn.BackgroundColor3 = CONFIRM
        wipeBtn.TextColor3 = CONFIRM_TEXT
        wipeBtn.Text = "Confirm?"
        if wipeResetThread then
            task.cancel(wipeResetThread)
        end
        wipeResetThread = task.delay(3, function()
            wipeResetThread = nil
            if mounted then
                resetWipe()
            end
        end)
        return
    end
    if wipeResetThread then
        task.cancel(wipeResetThread)
        wipeResetThread = nil
    end
    wipeConfirm = false
    wipePlot()
end

local function build(parent)
    root = make("Frame", {
        Name = "ManagementRoot",
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

    heading(list, "Management", 1)
    saveBtn = actionRow(list, "Save slot", "Save", 2)
    saveBtn.MouseButton1Click:Connect(saveSlot)

    heading(list, "Property", 3)
    claimBtn = actionRow(list, "Claim free land", "Claim", 4)
    expandBtn = actionRow(list, "Max land", "Expand", 5)
    deleteBtn = actionRow(list, "Delete sold sign", "Delete", 6)
    wipeBtn = actionRow(list, "Wipe plot", "Wipe", 7, RED)

    claimBtn.MouseButton1Click:Connect(claimLand)
    expandBtn.MouseButton1Click:Connect(expandLand)
    deleteBtn.MouseButton1Click:Connect(onDeleteClick)
    wipeBtn.MouseButton1Click:Connect(onWipeClick)
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
    build(parent)
    mounted = true
    watchLand()
    if saveReadyAt > os.clock() then
        runSaveCountdown()
    end
end

function api.unmount()
    mounted = false
    workToken += 1
    saveToken += 1
    wiping = false
    landUpdatePending = false
    wipeConfirm = false
    deleteConfirm = false
    if wipeResetThread then
        task.cancel(wipeResetThread)
        wipeResetThread = nil
    end
    if deleteResetThread then
        task.cancel(deleteResetThread)
        deleteResetThread = nil
    end
    disconnectAll()
    if root then
        root:Destroy()
        root = nil
    end
    saveBtn = nil
    claimBtn = nil
    expandBtn = nil
    wipeBtn = nil
    deleteBtn = nil
end

return api
