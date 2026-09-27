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
        id = "Catalog",
        name = "Catalog",
        url = BASE .. "Catalog/Catalog.lua",
    },
    {
        id = "Duper",
        name = "Legacy Mover",
        url = BASE .. "Duper/Duper.lua",
    },
    {
        id = "SawmillLoader",
        name = "Sawmill Loader",
        url = BASE .. "SawmillLoader/SawmillLoader.lua",
    },
    {
        id = "TreeCutter",
        name = "Auto Tree",
        url = BASE .. "TreeCutter/TreeCutter.lua",
    },
    {
        id = "Organizer",
        name = "Organizer",
        url = BASE .. "Organizer/Organizer.lua",
    },
    {
        id = "Management",
        name = "Management",
        url = BASE .. "Management/Management.lua",
        power = false,
    },
    {
        id = "Shop",
        name = "Shop",
        url = BASE .. "Shop/Shop.lua",
        power = false,
    },
    {
        id = "Teleports",
        name = "Teleports",
        url = BASE .. "Teleports/Teleports.lua",
        power = false,
    },
}

local GUI_NAME = "JellDashboard"
local CLICK_ACTION = "JellDashboardClickTp"
local TOGGLE_ACTION = "JellDashboardToggle"
local LIGHTING_STEP = "JellDashboardLighting"
local MOVE_STEP = "JellDashboardShiftWalk"
local AFK_CONN = "JellDashboardAfk"
local JUMP_CONN = "JellDashboardJump"
local NOCLIP_CONN = "JellDashboardNoclip"

local RED = Color3.fromRGB(210, 70, 70)
local GREEN = Color3.fromRGB(70, 190, 105)
local SIDEBAR = Color3.fromRGB(14, 14, 14)
local ROW = Color3.fromRGB(32, 32, 32)
local TEXT = Color3.fromRGB(230, 230, 230)
local MUTED = Color3.fromRGB(160, 160, 160)
local TOGGLE_OFF = Color3.fromRGB(58, 58, 58)
local TOGGLE_W = 28
local TOGGLE_H = 14
local TOGGLE_KNOB = 10
local TOGGLE_PAD = 2
local TOGGLE_TWEEN = TweenInfo.new(0.2)

local settings = {
    ctrlClick = true,
    disableShadows = false,
    disableFog = true,
    alwaysDay = false,
    disableShiftWalk = true,
    preventAfkKick = true,
    infiniteJump = false,
    noClip = false,
    enhancedVisuals = false,
    lowerBridge = false,
}

local toggleKey = Enum.KeyCode.Tab
local capturingKey = false
local savedLighting
local shownId

_G.JellSawmillCircleOk = false
_G.JellSawmillHighlightOk = false
_G.JellSawmillMoving = false
if type(_G.JellSawmillStop) == "function" then
    pcall(_G.JellSawmillStop)
end

local function clearSawmillRing()
    local world = Services.Workspace
    for _, child in ipairs(world:GetChildren()) do
        if child.Name == "AuraCircle" then
            child:Destroy()
        elseif child.Name == "SawmillLoaderAura" and not _G.JellSawmillCircleOk then
            child:Destroy()
        end
    end
    if _G.JellSawmillHighlightOk then
        return
    end
    for _, folderName in ipairs({ "LogModels", "PlayerModels" }) do
        local folder = world:FindFirstChild(folderName)
        if folder then
            for _, desc in ipairs(folder:GetDescendants()) do
                if desc.Name == "SawmillLoaderHighlight" then
                    desc:Destroy()
                end
            end
        end
    end
end

RunService:BindToRenderStep("JellClearSawmillRing", Enum.RenderPriority.Last.Value, clearSawmillRing)

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
        ExposureCompensation = Lighting.ExposureCompensation,
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

local bridgeBackup

local function lightingEffect(name, className)
    local effect = Lighting:FindFirstChild(name)
    if effect then
        return effect
    end
    effect = Instance.new(className)
    effect.Name = name
    effect.Parent = Lighting
    return effect
end

local function enableEnhanced()
    Lighting.Brightness = 3
    Lighting.ExposureCompensation = 0.5
    local bloom = lightingEffect("EnhancedBloom", "BloomEffect")
    bloom.Intensity = 1
    bloom.Size = 24
    bloom.Threshold = 2
    bloom.Enabled = true
    local correction = lightingEffect("EnhancedCC", "ColorCorrectionEffect")
    correction.Contrast = 0.1
    correction.Saturation = 0.15
    correction.TintColor = Color3.fromRGB(255, 253, 245)
    correction.Enabled = true
    local rays = lightingEffect("EnhancedRays", "SunRaysEffect")
    rays.Intensity = 0.1
    rays.Spread = 1
    rays.Enabled = true
end

local function restoreEnhanced()
    for _, name in ipairs({ "EnhancedBloom", "EnhancedCC", "EnhancedRays" }) do
        local effect = Lighting:FindFirstChild(name)
        if effect then
            effect.Enabled = false
        end
    end
    local saved = savedLighting
    if not saved then
        return
    end
    Lighting.Brightness = saved.Brightness
    Lighting.ExposureCompensation = saved.ExposureCompensation
end

local function rememberBridge()
    if bridgeBackup then
        return
    end
    local bridge = Services.Workspace:FindFirstChild("Bridge")
    if bridge then
        bridgeBackup = bridge:Clone()
    end
end

local function lowerBridge()
    rememberBridge()
    local bridge = Services.Workspace:FindFirstChild("Bridge")
    if not bridge then
        return
    end
    local liftBridge = bridge:FindFirstChild("VerticalLiftBridge")
    local lift = liftBridge and liftBridge:FindFirstChild("Lift")
    if lift then
        for _, child in ipairs(lift:GetChildren()) do
            if child:IsA("BasePart") and child.Name == "Base" then
                child.CFrame = CFrame.new(child.Position.X, 6.5, child.Position.Z) * child.CFrame.Rotation
            end
        end
    end
    local removeNames = {
        BRope = true,
        Structure = true,
        Weight = true,
        WRope = true,
    }
    if liftBridge then
        for _, child in ipairs(liftBridge:GetChildren()) do
            if removeNames[child.Name] then
                child:Destroy()
            end
        end
    end
end

local function restoreBridge()
    if not bridgeBackup then
        return
    end
    local restored = bridgeBackup:Clone()
    local current = Services.Workspace:FindFirstChild("Bridge")
    if current then
        current:Destroy()
    end
    restored.Parent = Services.Workspace
end

local function applyLighting()
    captureLighting()
    if settings.alwaysDay then
        Lighting.ClockTime = 12
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    end
    Lighting.GlobalShadows = not settings.disableShadows
    if settings.disableFog then
        Lighting.FogStart = 0
        Lighting.FogEnd = 1000000
        local atmosphere = atmosphereOf()
        if atmosphere then
            atmosphere.Density = 0
            atmosphere.Haze = 0
        end
    end
    if settings.enhancedVisuals then
        enableEnhanced()
    end
end

local function bindLighting()
    pcall(function()
        RunService:UnbindFromRenderStep(LIGHTING_STEP)
    end)
    if settings.alwaysDay or settings.disableShadows or settings.disableFog or settings.enhancedVisuals then
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
    restoreEnhanced()
    restoreBridge()
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

local window = make("CanvasGroup", {
    Name = "Window",
    Size = UDim2.fromOffset(640, 480),
    Position = UDim2.new(0.5, -320, 0.5, -228),
    BackgroundColor3 = Color3.fromRGB(18, 18, 18),
    BackgroundTransparency = 0.08,
    BorderSizePixel = 0,
    Active = true,
    GroupTransparency = 1,
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
    Font = Enum.Font.GothamBold,
    Text = "JELL'S DASHBOARD",
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

local settingsPage = make("ScrollingFrame", {
    Size = UDim2.new(1, -12, 1, -12),
    Position = UDim2.fromOffset(12, 8),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = Color3.fromRGB(70, 70, 70),
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollingDirection = Enum.ScrollingDirection.Y,
    Visible = false,
}, content)
make("UIListLayout", {
    FillDirection = Enum.FillDirection.Vertical,
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, settingsPage)
make("UIPadding", {
    PaddingRight = UDim.new(0, 8),
}, settingsPage)

local scriptHost = make("Frame", {
    Name = "ScriptHost",
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Visible = false,
}, content)

local enableNote = make("TextLabel", {
    Name = "EnableNote",
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Font = Enum.Font.SourceSans,
    Text = "Please enable this script",
    TextSize = 18,
    TextColor3 = Color3.fromRGB(210, 210, 210),
    Visible = false,
}, content)

local welcomePage = make("Frame", {
    Name = "Welcome",
    Size = UDim2.new(1, -24, 1, -24),
    Position = UDim2.fromOffset(12, 12),
    BackgroundTransparency = 1,
}, content)

local function titleRule(parent, text, y, height, textSize, color, order)
    local row = make("Frame", {
        Size = UDim2.new(1, 0, 0, height),
        Position = UDim2.fromOffset(0, y),
        BackgroundTransparency = 1,
        LayoutOrder = order or 0,
    }, parent)
    local label = make("TextLabel", {
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = string.upper(text),
        TextSize = textSize,
        TextColor3 = color,
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

titleRule(welcomePage, "Welcome", 0, 28, 22, TEXT)

make("TextLabel", {
    Size = UDim2.new(1, 0, 0, 22),
    Position = UDim2.fromOffset(0, 36),
    BackgroundTransparency = 1,
    Font = Enum.Font.SourceSans,
    Text = "A dashboard for Lumber Tycoon 2.",
    TextSize = 16,
    TextColor3 = Color3.fromRGB(210, 210, 210),
    TextXAlignment = Enum.TextXAlignment.Left,
}, welcomePage)

titleRule(welcomePage, "GitHub", 78, 22, 15, Color3.fromRGB(210, 210, 210))

local githubBox = make("TextBox", {
    Size = UDim2.new(1, 0, 0, 22),
    Position = UDim2.fromOffset(0, 104),
    BackgroundColor3 = Color3.fromRGB(58, 58, 58),
    BorderSizePixel = 0,
    ClearTextOnFocus = false,
    TextEditable = false,
    Font = Enum.Font.SourceSans,
    Text = "https://github.com/mitchellcirey/LT2Scripts",
    TextSize = 15,
    TextColor3 = TEXT,
    TextXAlignment = Enum.TextXAlignment.Left,
}, welcomePage)
make("UIPadding", {
    PaddingLeft = UDim.new(0, 6),
}, githubBox)

local leavingServer = false

local function forceSaveBeforeLeave()
    local requests = Services.ReplicatedStorage:FindFirstChild("LoadSaveRequests")
    local slot = Player:FindFirstChild("CurrentSaveSlot")
    if not slot then
        local data = Player:FindFirstChild("Data")
        slot = data and data:FindFirstChild("CurrentSaveSlot")
    end
    if not (requests and slot and slot.Value ~= -1) then
        return
    end
    local requestSave = requests:FindFirstChild("RequestSave")
    if not requestSave then
        return
    end
    pcall(function()
        requestSave:InvokeServer(slot.Value)
    end)
    task.wait(0.5)
end

local function rejoinServer()
    if leavingServer then
        return
    end
    leavingServer = true
    forceSaveBeforeLeave()
    local ok = pcall(function()
        Services.TeleportService:Teleport(game.PlaceId, Player)
    end)
    if not ok then
        leavingServer = false
        return
    end
    task.delay(8, function()
        leavingServer = false
    end)
end

local function serverHop(sortOrder)
    if leavingServer then
        return
    end
    leavingServer = true
    forceSaveBeforeLeave()
    local api = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=%s&limit=100"):format(game.PlaceId, sortOrder)
    local ok, result = pcall(function()
        return Services.HttpService:JSONDecode(game:HttpGet(api))
    end)
    if not ok or type(result) ~= "table" or type(result.data) ~= "table" then
        leavingServer = false
        warn("[Jell] Failed to fetch server list.")
        return
    end
    for _, server in ipairs(result.data) do
        if type(server.playing) == "number"
            and type(server.maxPlayers) == "number"
            and server.playing < server.maxPlayers
            and server.id ~= game.JobId
        then
            local joined = pcall(function()
                Services.TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, Player)
            end)
            if joined then
                task.delay(8, function()
                    leavingServer = false
                end)
                return
            end
        end
    end
    leavingServer = false
    warn("[Jell] No suitable server found.")
end

local function homeAction(labelText, buttonText, y, action)
    make("TextLabel", {
        Size = UDim2.new(1, -96, 0, 22),
        Position = UDim2.fromOffset(0, y),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = labelText,
        TextSize = 15,
        TextColor3 = Color3.fromRGB(210, 210, 210),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, welcomePage)
    local button = make("TextButton", {
        Size = UDim2.fromOffset(88, 22),
        Position = UDim2.new(1, -88, 0, y),
        BackgroundColor3 = Color3.fromRGB(58, 58, 58),
        BorderSizePixel = 0,
        Font = Enum.Font.SourceSans,
        Text = buttonText,
        TextSize = 15,
        TextColor3 = TEXT,
        AutoButtonColor = false,
    }, welcomePage)
    button.MouseButton1Click:Connect(function()
        task.spawn(action)
    end)
end

titleRule(welcomePage, "Server Management", 146, 22, 15, Color3.fromRGB(210, 210, 210))
homeAction("Rejoin server", "Rejoin", 176, rejoinServer)
homeAction("Descending", "Join", 208, function()
    serverHop("Asc")
end)
homeAction("Ascending", "Join", 240, function()
    serverHop("Desc")
end)

local homeBtn = make("TextButton", {
    Size = UDim2.new(1, -16, 0, 24),
    Position = UDim2.fromOffset(8, 8),
    BackgroundColor3 = Color3.fromRGB(58, 58, 58),
    BorderSizePixel = 0,
    Font = Enum.Font.SourceSansBold,
    Text = "Home",
    TextSize = 15,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    AutoButtonColor = false,
}, sidebar)

local settingsBtn = make("TextButton", {
    Size = UDim2.new(1, -16, 0, 24),
    Position = UDim2.fromOffset(8, 40),
    BackgroundColor3 = Color3.fromRGB(58, 58, 58),
    BorderSizePixel = 0,
    Font = Enum.Font.SourceSans,
    Text = "Settings",
    TextSize = 15,
    TextColor3 = Color3.fromRGB(210, 210, 210),
    AutoButtonColor = false,
}, sidebar)

local accountOpen = true
local scriptsOpen = true

local sideScroll = make("ScrollingFrame", {
    Size = UDim2.new(1, -8, 1, -76),
    Position = UDim2.fromOffset(4, 72),
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
}, sideScroll)
make("UIPadding", {
    PaddingTop = UDim.new(0, 2),
    PaddingLeft = UDim.new(0, 4),
    PaddingRight = UDim.new(0, 4),
}, sideScroll)

local function groupButton(text, order)
    local button = make("TextButton", {
        Size = UDim2.new(1, 0, 0, 22),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = string.upper(text),
        TextSize = 15,
        TextColor3 = TEXT,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
        LayoutOrder = order,
    }, sideScroll)
    local chevron = make("TextLabel", {
        Size = UDim2.fromOffset(16, 22),
        Position = UDim2.new(1, -16, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = "v",
        TextSize = 14,
        TextColor3 = MUTED,
    }, button)
    return button, chevron
end

local function groupList(order)
    local list = make("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = order,
    }, sideScroll)
    make("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, list)
    return list
end

local accountBtn, accountChevron = groupButton("Account", 1)
local accountList = groupList(2)
local scriptsBtn, scriptsChevron = groupButton("Scripts", 3)
local scriptList = groupList(4)

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

local function disconnectShared(key)
    local conn = shared[key]
    if not conn then
        return
    end
    pcall(function()
        conn:Disconnect()
    end)
    shared[key] = nil
end

local function bindAfk()
    disconnectShared(AFK_CONN)
    if not settings.preventAfkKick then
        return
    end
    shared[AFK_CONN] = Player.Idled:Connect(function()
        if not settings.preventAfkKick then
            return
        end
        pcall(function()
            local virtualUser = Services.VirtualUser
            virtualUser:CaptureController()
            virtualUser:ClickButton2(Vector2.new(0, 0))
        end)
    end)
end

local function bindJump()
    disconnectShared(JUMP_CONN)
    if not settings.infiniteJump then
        return
    end
    shared[JUMP_CONN] = UserInputService.JumpRequest:Connect(function()
        if not settings.infiniteJump then
            return
        end
        local character = Player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

local function bindNoclip()
    disconnectShared(NOCLIP_CONN)
    if not settings.noClip then
        return
    end
    shared[NOCLIP_CONN] = RunService.Stepped:Connect(function()
        if not settings.noClip then
            return
        end
        local character = Player.Character
        if not character then
            return
        end
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

bindAfk()
bindJump()
bindNoclip()

local ctx = {
    screenGui = screenGui,
    window = window,
}

local states = {}

local function paintToggle(state)
    if not state.track then
        return
    end
    local on = state.started
    if state.toggleOn == on then
        return
    end
    state.toggleOn = on
    local knobX = on and (TOGGLE_W - TOGGLE_KNOB - TOGGLE_PAD) or TOGGLE_PAD
    Services.TweenService:Create(state.knob, TOGGLE_TWEEN, {
        Position = UDim2.fromOffset(knobX, (TOGGLE_H - TOGGLE_KNOB) / 2),
    }):Play()
    Services.TweenService:Create(state.track, TOGGLE_TWEEN, {
        BackgroundColor3 = on and GREEN or TOGGLE_OFF,
    }):Play()
end

local function scriptNeedsPower(entry)
    return entry.power ~= false
end

local function shownEntry()
    if not shownId then
        return nil
    end
    for _, entry in ipairs(SCRIPTS) do
        if entry.id == shownId then
            return entry
        end
    end
    return nil
end

local function pageLocked()
    local entry = shownEntry()
    local state = shownId and states[shownId]
    return entry ~= nil
        and scriptNeedsPower(entry)
        and state ~= nil
        and not state.started
        and not settingsPage.Visible
end

local function clearHost()
    for _, child in ipairs(scriptHost:GetChildren()) do
        child:Destroy()
    end
end

local function unmountEntry(entry)
    local state = states[entry.id]
    if state.mounted and state.module and type(state.module.unmount) == "function" then
        state.module.unmount()
    end
    state.mounted = false
    if shownId == entry.id then
        clearHost()
    end
end

local function paintLock()
    local locked = pageLocked()
    enableNote.Visible = locked
    if not locked then
        return
    end
    scriptHost.Visible = false
    local focused = UserInputService:GetFocusedTextBox()
    if focused and focused:IsDescendantOf(scriptHost) then
        focused:ReleaseFocus()
    end
end

local function paint(entry)
    local state = states[entry.id]
    if entry.power == false then
        state.nameBtn.TextColor3 = state.shown and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(210, 210, 210)
    else
        state.nameBtn.TextColor3 = state.started and GREEN or RED
    end
    state.row.BackgroundColor3 = state.shown and ROW or SIDEBAR
    paintToggle(state)
    paintLock()
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

local homeShown = true

local function paintHome()
    homeBtn.Font = homeShown and Enum.Font.SourceSansBold or Enum.Font.SourceSans
    homeBtn.TextColor3 = homeShown and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(210, 210, 210)
end

local function showSettings()
    settingsPage.Visible = true
    scriptHost.Visible = false
    welcomePage.Visible = false
    shownId = nil
    homeShown = false
    settingsBtn.Font = Enum.Font.SourceSansBold
    settingsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    paintHome()
    for _, entry in ipairs(SCRIPTS) do
        states[entry.id].shown = false
        paint(entry)
    end
end

local function showScriptPage(entry)
    local state = states[entry.id]
    homeShown = false
    paintHome()
    settingsPage.Visible = false
    welcomePage.Visible = false
    settingsBtn.Font = Enum.Font.SourceSans
    settingsBtn.TextColor3 = Color3.fromRGB(210, 210, 210)
    if shownId and shownId ~= entry.id then
        local prev = states[shownId]
        if prev.mounted and prev.module and type(prev.module.unmount) == "function" then
            prev.module.unmount()
        end
        prev.mounted = false
        prev.shown = false
    end
    shownId = entry.id
    if scriptNeedsPower(entry) and not state.started then
        if state.mounted then
            unmountEntry(entry)
        end
        clearHost()
        scriptHost.Visible = false
        return
    end
    local module = ensureLoaded(entry)
    if not module or type(module.mount) ~= "function" then
        return
    end
    if not state.mounted then
        clearHost()
        module.mount(scriptHost, ctx)
        state.mounted = true
    end
    scriptHost.Visible = true
end

local function openScript(entry)
    local state = states[entry.id]
    if state.opening then
        return
    end
    state.opening = true
    local ok, err = pcall(function()
        showScriptPage(entry)
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
        if shownId == nil and not settingsPage.Visible then
            welcomePage.Visible = true
            scriptHost.Visible = false
            homeShown = true
            paintHome()
        end
        paintLock()
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
            if state.mounted then
                unmountEntry(entry)
            end
            if shownId == entry.id then
                scriptHost.Visible = false
            end
            paint(entry)
            return
        end
        local module = ensureLoaded(entry)
        if not module or type(module.start) ~= "function" then
            return
        end
        module.start(ctx)
        state.started = true
        if shownId == entry.id then
            showScriptPage(entry)
        end
        paint(entry)
    end)
    state.powering = false
    if not ok then
        warn("[Jell] " .. entry.name .. " failed to start: " .. tostring(err))
    end
end

local function toggleSwitch(parent)
    local track = make("TextButton", {
        Size = UDim2.fromOffset(TOGGLE_W, TOGGLE_H),
        Position = UDim2.new(1, -(TOGGLE_W + 4), 0.5, -TOGGLE_H / 2),
        BackgroundColor3 = TOGGLE_OFF,
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
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
    }, track)
    make("UICorner", {
        CornerRadius = UDim.new(1, 0),
    }, knob)
    return track, knob
end

local function paintSwitch(track, knob, on)
    local knobX = on and (TOGGLE_W - TOGGLE_KNOB - TOGGLE_PAD) or TOGGLE_PAD
    Services.TweenService:Create(knob, TOGGLE_TWEEN, {
        Position = UDim2.fromOffset(knobX, (TOGGLE_H - TOGGLE_KNOB) / 2),
    }):Play()
    Services.TweenService:Create(track, TOGGLE_TWEEN, {
        BackgroundColor3 = on and GREEN or TOGGLE_OFF,
    }):Play()
end

local function showHome()
    settingsPage.Visible = false
    scriptHost.Visible = false
    welcomePage.Visible = true
    shownId = nil
    settingsBtn.Font = Enum.Font.SourceSans
    settingsBtn.TextColor3 = Color3.fromRGB(210, 210, 210)
    homeShown = true
    paintHome()
    for _, entry in ipairs(SCRIPTS) do
        states[entry.id].shown = false
        paint(entry)
    end
end

homeBtn.MouseButton1Click:Connect(showHome)
paintHome()

for index, entry in ipairs(SCRIPTS) do
    local rowParent = entry.power == false and accountList or scriptList
    local row = make("Frame", {
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundColor3 = SIDEBAR,
        BorderSizePixel = 0,
        LayoutOrder = index,
    }, rowParent)

    local showPower = entry.power ~= false
    local nameBtn = make("TextButton", {
        Size = showPower and UDim2.new(1, -(TOGGLE_W + 8), 1, 0) or UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = entry.name,
        TextSize = 15,
        TextColor3 = showPower and RED or Color3.fromRGB(210, 210, 210),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        AutoButtonColor = false,
    }, row)
    make("UIPadding", {
        PaddingLeft = UDim.new(0, 6),
    }, nameBtn)

    local track, knob
    if showPower then
        track, knob = toggleSwitch(row)
    end

    states[entry.id] = {
        row = row,
        nameBtn = nameBtn,
        track = track,
        knob = knob,
        toggleOn = false,
        started = false,
        shown = false,
        mounted = false,
        loading = false,
        module = nil,
    }

    nameBtn.MouseButton1Click:Connect(function()
        task.spawn(openScript, entry)
    end)
    if track then
        track.MouseButton1Click:Connect(function()
            task.spawn(togglePower, entry)
        end)
    end
end

local function toggleRow(labelText, key, order)
    local row = make("Frame", {
        Size = UDim2.new(1, 0, 0, 22),
        BackgroundTransparency = 1,
        LayoutOrder = order,
    }, settingsPage)
    make("TextLabel", {
        Size = UDim2.new(1, -64, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = labelText,
        TextSize = 15,
        TextColor3 = Color3.fromRGB(210, 210, 210),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)
    local track, knob = toggleSwitch(row)
    local on = settings[key] == true
    local knobX = on and (TOGGLE_W - TOGGLE_KNOB - TOGGLE_PAD) or TOGGLE_PAD
    knob.Position = UDim2.fromOffset(knobX, (TOGGLE_H - TOGGLE_KNOB) / 2)
    track.BackgroundColor3 = on and GREEN or TOGGLE_OFF

    track.MouseButton1Click:Connect(function()
        settings[key] = not settings[key]
        paintSwitch(track, knob, settings[key])
        if key == "ctrlClick" then
            bindCtrl()
            return
        end
        if key == "disableShiftWalk" then
            bindShiftWalk()
            return
        end
        if key == "preventAfkKick" then
            bindAfk()
            return
        end
        if key == "infiniteJump" then
            bindJump()
            return
        end
        if key == "noClip" then
            bindNoclip()
            return
        end
        if key == "lowerBridge" then
            if settings.lowerBridge then
                lowerBridge()
            else
                restoreBridge()
            end
            return
        end
        if key == "alwaysDay" and not settings.alwaysDay then
            restoreAlwaysDay()
        elseif key == "disableFog" and not settings.disableFog then
            restoreFog()
        elseif key == "enhancedVisuals" and not settings.enhancedVisuals then
            restoreEnhanced()
        end
        applyLighting()
        bindLighting()
    end)
end

local headerColor = Color3.fromRGB(210, 210, 210)
titleRule(settingsPage, "Movement", 0, 22, 15, headerColor, 1)
toggleRow("Ctrl Click", "ctrlClick", 2)
toggleRow("Disable shift walk", "disableShiftWalk", 3)
toggleRow("Infinite jump", "infiniteJump", 4)
toggleRow("No clip", "noClip", 5)
titleRule(settingsPage, "World", 0, 22, 15, headerColor, 6)
toggleRow("Disable shadows", "disableShadows", 7)
toggleRow("Disable fog", "disableFog", 8)
toggleRow("Always Day", "alwaysDay", 9)
toggleRow("Enhanced visuals", "enhancedVisuals", 10)
toggleRow("Lower bridge", "lowerBridge", 11)
titleRule(settingsPage, "Player", 0, 22, 15, headerColor, 12)
toggleRow("Prevent AFK kick", "preventAfkKick", 13)
titleRule(settingsPage, "Window", 0, 22, 15, headerColor, 14)

local keyRow = make("Frame", {
    Size = UDim2.new(1, 0, 0, 22),
    BackgroundTransparency = 1,
    LayoutOrder = 15,
}, settingsPage)
make("TextLabel", {
    Size = UDim2.new(1, -96, 1, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.SourceSans,
    Text = "UI Toggle key",
    TextSize = 15,
    TextColor3 = Color3.fromRGB(210, 210, 210),
    TextXAlignment = Enum.TextXAlignment.Left,
}, keyRow)

local keyBtn = make("TextButton", {
    Size = UDim2.fromOffset(88, 22),
    Position = UDim2.new(1, -88, 0, 0),
    BackgroundColor3 = Color3.fromRGB(58, 58, 58),
    BorderSizePixel = 0,
    Font = Enum.Font.SourceSans,
    Text = toggleKey.Name,
    TextSize = 15,
    TextColor3 = TEXT,
    AutoButtonColor = false,
}, keyRow)

local function paintKeyButton()
    keyBtn.Text = toggleKey.Name
    if capturingKey then
        keyBtn.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
        keyBtn.TextColor3 = Color3.fromRGB(18, 18, 18)
    else
        keyBtn.BackgroundColor3 = Color3.fromRGB(58, 58, 58)
        keyBtn.TextColor3 = TEXT
    end
end

local lastFlip = 0

local function flipWindow()
    if capturingKey or UserInputService:GetFocusedTextBox() then
        return
    end
    local now = os.clock()
    if now - lastFlip < 0.05 then
        return
    end
    lastFlip = now
    if window.Parent then
        window.Visible = not window.Visible
    end
end

local function bindToggleKey()
    ContextActionService:UnbindAction(TOGGLE_ACTION)
    if capturingKey then
        return
    end
    ContextActionService:BindActionAtPriority(
        TOGGLE_ACTION,
        function(_, state)
            if state ~= Enum.UserInputState.Begin then
                return Enum.ContextActionResult.Pass
            end
            flipWindow()
            return Enum.ContextActionResult.Sink
        end,
        false,
        Enum.ContextActionPriority.High.Value + 1,
        toggleKey
    )
end

bindToggleKey()

keyBtn.MouseButton1Click:Connect(function()
    capturingKey = not capturingKey
    bindToggleKey()
    paintKeyButton()
end)

settingsBtn.MouseButton1Click:Connect(showSettings)

accountBtn.MouseButton1Click:Connect(function()
    accountOpen = not accountOpen
    accountList.Visible = accountOpen
    accountChevron.Text = accountOpen and "v" or ">"
end)

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
    ContextActionService:UnbindAction(TOGGLE_ACTION)
    pcall(function()
        RunService:UnbindFromRenderStep(MOVE_STEP)
    end)
    pcall(function()
        RunService:UnbindFromRenderStep("JellClearSawmillRing")
    end)
    _G.JellSawmillCircleOk = false
    _G.JellSawmillHighlightOk = false
    clearSawmillRing()
    restoreLighting()
    disconnectShared(AFK_CONN)
    disconnectShared(JUMP_CONN)
    disconnectShared(NOCLIP_CONN)
    screenGui:Destroy()
end

closeBtn.MouseButton1Click:Connect(shutdown)

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then
        return
    end
    if capturingKey then
        if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Unknown then
            capturingKey = false
        else
            toggleKey = input.KeyCode
            capturingKey = false
        end
        bindToggleKey()
        paintKeyButton()
        return
    end
    if input.KeyCode == toggleKey then
        flipWindow()
    end
end)

local introTween = Services.TweenService:Create(
    window,
    TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    {
        GroupTransparency = 0,
        Position = UDim2.new(0.5, -320, 0.5, -240),
    }
)
introTween:Play()

do
    local dragging = false
    local dragStart
    local startPos

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            introTween:Cancel()
            window.GroupTransparency = 0
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
