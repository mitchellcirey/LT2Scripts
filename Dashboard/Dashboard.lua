local Services = setmetatable({}, {
    __index = function(self, index)
        return game:GetService(index)
    end,
})

local Players = Services.Players
local UserInputService = Services.UserInputService
local ContextActionService = Services.ContextActionService
local RunService = Services.RunService
local Lighting = Services.Lighting

local Player = Players.LocalPlayer

local BASE = "https://raw.githubusercontent.com/mitchellcirey/LT2Scripts/main/"

local SCRIPTS = {
    {
        id = "Duper",
        name = "Duper",
        url = BASE .. "Duper/Duper.lua",
    },
    {
        id = "Chopper",
        name = "Chopper",
        url = BASE .. "Chopper/Chopper.lua",
    },
}

local GUI_NAME = "JellDashboard"
local CLICK_ACTION = "JellDashboardClickTp"
local LIGHTING_STEP = "JellDashboardLighting"
local MOVE_STEP = "JellDashboardShiftWalk"

local RED = Color3.fromRGB(210, 70, 70)
local GREEN = Color3.fromRGB(70, 190, 105)
local SIDEBAR = Color3.fromRGB(14, 14, 14)
local ROW = Color3.fromRGB(32, 32, 32)
local TEXT = Color3.fromRGB(230, 230, 230)
local MUTED = Color3.fromRGB(160, 160, 160)

local settings = {
    ctrlClick = true,
    disableShadows = true,
    disableFog = true,
    alwaysDay = true,
    disableShiftWalk = true,
}

local toggleKey = Enum.KeyCode.Tab
local savedLighting
local shownId

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

local function getUiParent()
    local parents = uiParents()
    if parents[1] then
        return parents[1]
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

local function captureLighting()
    if savedLighting then
        return
    end
    local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
    savedLighting = {
        ClockTime = Lighting.ClockTime,
        Brightness = Lighting.Brightness,
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        GlobalShadows = Lighting.GlobalShadows,
        FogStart = Lighting.FogStart,
        FogEnd = Lighting.FogEnd,
        Atmosphere = atmosphere,
        Density = atmosphere and atmosphere.Density,
        Haze = atmosphere and atmosphere.Haze,
    }
end

local function atmosphereOf()
    local saved = savedLighting
    if saved and saved.Atmosphere and saved.Atmosphere.Parent then
        return saved.Atmosphere
    end
    return Lighting:FindFirstChildOfClass("Atmosphere")
end

local function restoreAlwaysDay()
    local saved = savedLighting
    if not saved then
        return
    end
    Lighting.ClockTime = saved.ClockTime
    Lighting.Brightness = saved.Brightness
    Lighting.Ambient = saved.Ambient
    Lighting.OutdoorAmbient = saved.OutdoorAmbient
end

local function restoreShadows()
    if savedLighting then
        Lighting.GlobalShadows = savedLighting.GlobalShadows
    end
end

local function restoreFog()
    local saved = savedLighting
    if not saved then
        return
    end
    Lighting.FogStart = saved.FogStart
    Lighting.FogEnd = saved.FogEnd
    local atmosphere = atmosphereOf()
    if atmosphere and saved.Density ~= nil then
        atmosphere.Density = saved.Density
        atmosphere.Haze = saved.Haze
    end
end

local function applyLighting()
    captureLighting()
    if settings.alwaysDay then
        Lighting.ClockTime = 12
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    end
    if settings.disableShadows then
        Lighting.GlobalShadows = false
    end
    if settings.disableFog then
        Lighting.FogStart = 0
        Lighting.FogEnd = 1000000
        local atmosphere = atmosphereOf()
        if atmosphere then
            atmosphere.Density = 0
            atmosphere.Haze = 0
        end
    end
end

local function bindLighting()
    pcall(function()
        RunService:UnbindFromRenderStep(LIGHTING_STEP)
    end)
    if settings.alwaysDay or settings.disableShadows or settings.disableFog then
        RunService:BindToRenderStep(LIGHTING_STEP, Enum.RenderPriority.Last.Value, applyLighting)
    end
end

local function restoreLighting()
    pcall(function()
        RunService:UnbindFromRenderStep(LIGHTING_STEP)
    end)
    restoreAlwaysDay()
    restoreShadows()
    restoreFog()
end

for _, parent in ipairs(uiParents()) do
    for _, name in ipairs({ GUI_NAME, "LT2DuperUI" }) do
        local existing = parent:FindFirstChild(name)
        if existing then
            existing:Destroy()
        end
    end
end

pcall(function()
    RunService:UnbindFromRenderStep(LIGHTING_STEP)
end)
pcall(function()
    RunService:UnbindFromRenderStep("LT2DuperLighting")
end)
ContextActionService:UnbindAction(CLICK_ACTION)
ContextActionService:UnbindAction("LT2DuperClickTp")

captureLighting()
applyLighting()
bindLighting()

local uiParent = getUiParent()
local screenGui = make("ScreenGui", {
    Name = GUI_NAME,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 999,
}, uiParent)

local window = make("Frame", {
    Name = "Window",
    Size = UDim2.fromOffset(640, 480),
    Position = UDim2.new(0.5, -320, 0.5, -240),
    BackgroundColor3 = Color3.fromRGB(18, 18, 18),
    BackgroundTransparency = 0.08,
    BorderSizePixel = 0,
    Active = true,
}, screenGui)

local titleBar = make("Frame", {
    Size = UDim2.new(1, 0, 0, 28),
    BackgroundTransparency = 1,
    Active = true,
}, window)

make("Frame", {
    Size = UDim2.new(1, -16, 0, 1),
    Position = UDim2.new(0, 8, 1, -1),
    BackgroundColor3 = Color3.fromRGB(48, 48, 48),
    BorderSizePixel = 0,
}, titleBar)

make("TextLabel", {
    Size = UDim2.new(1, -40, 1, 0),
    Position = UDim2.fromOffset(12, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.SourceSans,
    Text = "Jell",
    TextSize = 16,
    TextColor3 = TEXT,
    TextXAlignment = Enum.TextXAlignment.Left,
}, titleBar)

local closeBtn = make("TextButton", {
    Size = UDim2.fromOffset(28, 28),
    Position = UDim2.new(1, -28, 0, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.SourceSans,
    Text = "x",
    TextSize = 16,
    TextColor3 = MUTED,
    AutoButtonColor = false,
}, titleBar)

local body = make("Frame", {
    Size = UDim2.new(1, 0, 1, -28),
    Position = UDim2.fromOffset(0, 28),
    BackgroundTransparency = 1,
}, window)

local sidebar = make("Frame", {
    Size = UDim2.new(0, 200, 1, 0),
    BackgroundColor3 = SIDEBAR,
    BorderSizePixel = 0,
}, body)

make("Frame", {
    Size = UDim2.new(0, 1, 1, 0),
    Position = UDim2.fromOffset(200, 0),
    BackgroundColor3 = Color3.fromRGB(48, 48, 48),
    BorderSizePixel = 0,
}, body)

local content = make("Frame", {
    Size = UDim2.new(1, -201, 1, 0),
    Position = UDim2.fromOffset(201, 0),
    BackgroundTransparency = 1,
    ClipsDescendants = true,
}, body)

local settingsPage = make("Frame", {
    Size = UDim2.new(1, -24, 1, -24),
    Position = UDim2.fromOffset(12, 12),
    BackgroundTransparency = 1,
    Visible = false,
}, content)

local scriptHost = make("Frame", {
    Name = "ScriptHost",
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Visible = false,
}, content)

local settingsBtn = make("TextButton", {
    Size = UDim2.new(1, -16, 0, 24),
    Position = UDim2.fromOffset(8, 8),
    BackgroundColor3 = Color3.fromRGB(58, 58, 58),
    BorderSizePixel = 0,
    Font = Enum.Font.SourceSans,
    Text = "Settings",
    TextSize = 15,
    TextColor3 = Color3.fromRGB(210, 210, 210),
    AutoButtonColor = false,
}, sidebar)

local scriptsOpen = true
local scriptsBtn = make("TextButton", {
    Size = UDim2.new(1, -16, 0, 22),
    Position = UDim2.fromOffset(8, 40),
    BackgroundTransparency = 1,
    Font = Enum.Font.SourceSansBold,
    Text = "Scripts",
    TextSize = 15,
    TextColor3 = TEXT,
    TextXAlignment = Enum.TextXAlignment.Left,
    AutoButtonColor = false,
}, sidebar)

local scriptsChevron = make("TextLabel", {
    Size = UDim2.fromOffset(16, 22),
    Position = UDim2.new(1, -16, 0, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.SourceSans,
    Text = "v",
    TextSize = 14,
    TextColor3 = MUTED,
}, scriptsBtn)

local scriptList = make("ScrollingFrame", {
    Size = UDim2.new(1, -8, 1, -70),
    Position = UDim2.fromOffset(4, 66),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = Color3.fromRGB(70, 70, 70),
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollingDirection = Enum.ScrollingDirection.Y,
}, sidebar)

make("UIListLayout", {
    FillDirection = Enum.FillDirection.Vertical,
    Padding = UDim.new(0, 2),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, scriptList)

make("UIPadding", {
    PaddingTop = UDim.new(0, 2),
    PaddingLeft = UDim.new(0, 4),
    PaddingRight = UDim.new(0, 4),
}, scriptList)

local function pointerOverWindow()
    if not (window and window.Visible and window.Parent) then
        return false
    end
    local mousePos = UserInputService:GetMouseLocation()
    local gui = window:FindFirstAncestorWhichIsA("ScreenGui")
    local x, y = mousePos.X, mousePos.Y
    if not (gui and gui.IgnoreGuiInset) then
        local inset = Services.GuiService:GetGuiInset()
        x -= inset.X
        y -= inset.Y
    end
    local pos = window.AbsolutePosition
    local size = window.AbsoluteSize
    return x >= pos.X and x <= pos.X + size.X
        and y >= pos.Y and y <= pos.Y + size.Y
end

local function onClickTeleport(_, state)
    if state ~= Enum.UserInputState.Begin or not settings.ctrlClick then
        return Enum.ContextActionResult.Pass
    end
    if not (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
        or UserInputService:IsKeyDown(Enum.KeyCode.RightControl))
    then
        return Enum.ContextActionResult.Pass
    end
    if pointerOverWindow() or UserInputService:GetFocusedTextBox() then
        return Enum.ContextActionResult.Pass
    end
    local mouse = Player:GetMouse()
    if not (mouse.Target and mouse.Hit) then
        return Enum.ContextActionResult.Pass
    end
    local character = Player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        return Enum.ContextActionResult.Pass
    end
    local _, yaw = hrp.CFrame:ToEulerAnglesYXZ()
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    hrp.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0)) * CFrame.Angles(0, yaw, 0)
    return Enum.ContextActionResult.Sink
end

local function bindCtrl()
    ContextActionService:UnbindAction(CLICK_ACTION)
    if not settings.ctrlClick then
        return
    end
    ContextActionService:BindActionAtPriority(
        CLICK_ACTION,
        onClickTeleport,
        false,
        Enum.ContextActionPriority.High.Value + 1,
        Enum.UserInputType.MouseButton1
    )
end

bindCtrl()

local function shiftWalkHeld()
    if UserInputService:GetFocusedTextBox() then
        return false
    end
    local shift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
        or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
    if not shift then
        return false
    end
    return UserInputService:IsKeyDown(Enum.KeyCode.W)
        or UserInputService:IsKeyDown(Enum.KeyCode.A)
        or UserInputService:IsKeyDown(Enum.KeyCode.S)
        or UserInputService:IsKeyDown(Enum.KeyCode.D)
end

local function holdShiftWalk()
    if not settings.disableShiftWalk or not shiftWalkHeld() then
        return
    end
    local character = Player.Character
    if not character then
        return
    end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:Move(Vector3.zero, false)
    end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local velocity = hrp.AssemblyLinearVelocity
        hrp.AssemblyLinearVelocity = Vector3.new(0, velocity.Y, 0)
    end
end

local function bindShiftWalk()
    pcall(function()
        RunService:UnbindFromRenderStep(MOVE_STEP)
    end)
    if not settings.disableShiftWalk then
        return
    end
    RunService:BindToRenderStep(MOVE_STEP, Enum.RenderPriority.Last.Value, holdShiftWalk)
end

bindShiftWalk()

local ctx = {
    screenGui = screenGui,
    window = window,
}

local states = {}

local function paint(entry)
    local state = states[entry.id]
    state.nameBtn.TextColor3 = state.started and GREEN or RED
    local bg = state.shown and ROW or SIDEBAR
    state.row.BackgroundColor3 = bg
    state.gap.BackgroundColor3 = bg
end

local function ensureLoaded(entry)
    local state = states[entry.id]
    if state.module then
        return state.module
    end
    if state.loading then
        while state.loading do
            task.wait()
        end
        return state.module
    end
    state.loading = true
    local ok, result = pcall(function()
        local src = game:HttpGet(entry.url .. "?t=" .. tostring(os.time()))
        local fn, err = loadstring(src, entry.name)
        if not fn then
            error(err or "loadstring failed")
        end
        return fn()
    end)
    state.loading = false
    if not ok or type(result) ~= "table" then
        warn("[Jell] " .. entry.name .. " failed to load: " .. tostring(result))
        return nil
    end
    state.module = result
    return result
end

local function showSettings()
    settingsPage.Visible = true
    scriptHost.Visible = false
    shownId = nil
    settingsBtn.Font = Enum.Font.SourceSansBold
    settingsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    for _, entry in ipairs(SCRIPTS) do
        states[entry.id].shown = false
        paint(entry)
    end
end

local function openScript(entry)
    local state = states[entry.id]
    if state.opening then
        return
    end
    state.opening = true
    local ok, err = pcall(function()
        local module = ensureLoaded(entry)
        if not module or type(module.mount) ~= "function" then
            return
        end
        settingsPage.Visible = false
        scriptHost.Visible = true
        settingsBtn.Font = Enum.Font.SourceSans
        settingsBtn.TextColor3 = Color3.fromRGB(210, 210, 210)
        if shownId ~= entry.id or not state.mounted then
            if shownId and shownId ~= entry.id then
                local prev = states[shownId]
                if prev.module and type(prev.module.unmount) == "function" then
                    prev.module.unmount()
                end
                prev.mounted = false
                prev.shown = false
            end
            for _, child in ipairs(scriptHost:GetChildren()) do
                child:Destroy()
            end
            module.mount(scriptHost, ctx)
            state.mounted = true
            shownId = entry.id
        end
        for _, other in ipairs(SCRIPTS) do
            states[other.id].shown = other.id == entry.id
            paint(other)
        end
    end)
    state.opening = false
    if not ok then
        for _, child in ipairs(scriptHost:GetChildren()) do
            child:Destroy()
        end
        state.mounted = false
        if shownId == entry.id then
            shownId = nil
        end
        warn("[Jell] " .. entry.name .. " failed to open: " .. tostring(err))
    end
end

local function togglePower(entry)
    local state = states[entry.id]
    if state.powering then
        return
    end
    state.powering = true
    local ok, err = pcall(function()
        if state.started then
            if state.module and type(state.module.stop) == "function" then
                state.module.stop()
            end
            state.started = false
            paint(entry)
            return
        end
        local module = ensureLoaded(entry)
        if not module or type(module.start) ~= "function" then
            return
        end
        module.start(ctx)
        state.started = true
        paint(entry)
    end)
    state.powering = false
    if not ok then
        warn("[Jell] " .. entry.name .. " failed to start: " .. tostring(err))
    end
end

local function powerIcon(parent)
    local btn = make("TextButton", {
        Size = UDim2.fromOffset(22, 22),
        Position = UDim2.new(1, -46, 0.5, -11),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
    }, parent)
    local ring = make("Frame", {
        Size = UDim2.fromOffset(12, 12),
        Position = UDim2.fromOffset(5, 6),
        BackgroundTransparency = 1,
    }, btn)
    make("UICorner", {
        CornerRadius = UDim.new(1, 0),
    }, ring)
    make("UIStroke", {
        Color = Color3.fromRGB(210, 210, 210),
        Thickness = 1.4,
    }, ring)
    local gap = make("Frame", {
        Size = UDim2.fromOffset(4, 5),
        Position = UDim2.fromOffset(9, 2),
        BackgroundColor3 = SIDEBAR,
        BorderSizePixel = 0,
        ZIndex = 2,
    }, btn)
    make("Frame", {
        Size = UDim2.fromOffset(2, 6),
        Position = UDim2.fromOffset(10, 2),
        BackgroundColor3 = Color3.fromRGB(210, 210, 210),
        BorderSizePixel = 0,
        ZIndex = 3,
    }, btn)
    return btn, gap
end

for index, entry in ipairs(SCRIPTS) do
    local row = make("Frame", {
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundColor3 = SIDEBAR,
        BorderSizePixel = 0,
        LayoutOrder = index,
    }, scriptList)

    local nameBtn = make("TextButton", {
        Size = UDim2.new(1, -48, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = entry.name,
        TextSize = 15,
        TextColor3 = RED,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        AutoButtonColor = false,
    }, row)
    make("UIPadding", {
        PaddingLeft = UDim.new(0, 6),
    }, nameBtn)

    local powerBtn, gap = powerIcon(row)
    local arrowBtn = make("TextButton", {
        Size = UDim2.fromOffset(22, 22),
        Position = UDim2.new(1, -22, 0.5, -11),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = "→",
        TextSize = 16,
        TextColor3 = Color3.fromRGB(210, 210, 210),
        AutoButtonColor = false,
    }, row)

    states[entry.id] = {
        row = row,
        nameBtn = nameBtn,
        gap = gap,
        started = false,
        shown = false,
        mounted = false,
        loading = false,
        module = nil,
    }

    nameBtn.MouseButton1Click:Connect(function()
        task.spawn(ensureLoaded, entry)
    end)
    powerBtn.MouseButton1Click:Connect(function()
        task.spawn(togglePower, entry)
    end)
    arrowBtn.MouseButton1Click:Connect(function()
        task.spawn(openScript, entry)
    end)
end

local function toggleRow(labelText, key, y)
    make("TextLabel", {
        Size = UDim2.new(1, -64, 0, 22),
        Position = UDim2.fromOffset(0, y),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = labelText,
        TextSize = 15,
        TextColor3 = Color3.fromRGB(210, 210, 210),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, settingsPage)

    local btn = make("TextButton", {
        Size = UDim2.fromOffset(56, 22),
        Position = UDim2.new(1, -56, 0, y),
        BackgroundColor3 = Color3.fromRGB(58, 58, 58),
        BorderSizePixel = 0,
        Font = Enum.Font.SourceSans,
        Text = "On",
        TextSize = 15,
        TextColor3 = TEXT,
        AutoButtonColor = false,
    }, settingsPage)

    btn.MouseButton1Click:Connect(function()
        settings[key] = not settings[key]
        btn.Text = settings[key] and "On" or "Off"
        if key == "ctrlClick" then
            bindCtrl()
            return
        end
        if key == "disableShiftWalk" then
            bindShiftWalk()
            return
        end
        if key == "alwaysDay" and not settings.alwaysDay then
            restoreAlwaysDay()
        elseif key == "disableShadows" and not settings.disableShadows then
            restoreShadows()
        elseif key == "disableFog" and not settings.disableFog then
            restoreFog()
        end
        applyLighting()
        bindLighting()
    end)
end

toggleRow("Ctrl Click", "ctrlClick", 0)
toggleRow("Disable shadows", "disableShadows", 32)
toggleRow("Disable fog", "disableFog", 64)
toggleRow("Always Day", "alwaysDay", 96)
toggleRow("Disable shift walk", "disableShiftWalk", 128)

settingsBtn.MouseButton1Click:Connect(showSettings)

scriptsBtn.MouseButton1Click:Connect(function()
    scriptsOpen = not scriptsOpen
    scriptList.Visible = scriptsOpen
    scriptsChevron.Text = scriptsOpen and "v" or ">"
end)

local function shutdown()
    for _, entry in ipairs(SCRIPTS) do
        local state = states[entry.id]
        if state.started and state.module and type(state.module.stop) == "function" then
            pcall(function()
                state.module.stop()
            end)
        end
        if state.module and type(state.module.unmount) == "function" then
            pcall(function()
                state.module.unmount()
            end)
        end
    end
    ContextActionService:UnbindAction(CLICK_ACTION)
    pcall(function()
        RunService:UnbindFromRenderStep(MOVE_STEP)
    end)
    restoreLighting()
    screenGui:Destroy()
end

closeBtn.MouseButton1Click:Connect(shutdown)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then
        return
    end
    if gameProcessed or UserInputService:GetFocusedTextBox() then
        return
    end
    if input.KeyCode == toggleKey and window.Parent then
        window.Visible = not window.Visible
    end
end)

do
    local dragging = false
    local dragStart
    local startPos

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = window.Position
        end
    end)

    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

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
