local __modules = {}
__modules["LT2Axes"] = function() return assert(loadstring([[-- ==========================================
--              LT2Axes
--  Shared axe data for Lumber Tycoon 2.
--
--  Usage:
--    local LT2Axes  = require(ReplicatedStorage.LT2Axes)
--    local dmg      = LT2Axes.GetDamage("Rukiryaxe", "Generic")
--    local rank     = LT2Axes.Rank["Amber Axe"]   -- lower = better
-- ==========================================
local LT2Axes = {}

-- ==========================================
--  DAMAGE TABLE
--  Each entry is  function(treeClass) → number
--  Context-sensitive axes return different
--  values depending on the tree being cut.
--  Base (non-boosted) damage is the fallback.
-- ==========================================
LT2Axes.Damage = {

    -- ── Joke / Novelty ─────────────────────
    ["Inverse Axe"]          = function(_)  return -1   end,
    ["Refined Axe"] = function(tc)
        if tc == "Plank" then return 12 end   -- or however you want to key it
        return 0
    end,
    ["Candy Cane Axe"]       = function(_)  return  0   end,

    -- ── Standard Progression ───────────────
    ["Basic Hatchet"]        = function(_)  return  0.20 end,
    ["Plain Axe"]            = function(_)  return  0.55 end,
    ["Rusty Axe"]            = function(_)  return  0.55 end,
    ["Spearmint Axe"]        = function(_)  return  0.80 end,
    ["CHICKEN AXE"]          = function(_)  return  0.90 end,
    ["Steel Axe"]            = function(_)  return  0.93 end,
    ["Hardened Axe"]         = function(_)  return  1.45 end,
    ["Beta Axe of Bosses"]   = function(_)  return  1.45 end,
    ["Beesaxe"]              = function(_)  return  1.40 end,
    ["Alpha Axe of Testing"] = function(_)  return  1.50 end,
    ["Pig Axe"]              = function(_)  return  1.50 end,
    ["End Times Axe"]        = function(_)  return  1.58 end,  -- see context below
    ["Silver Axe"]           = function(_)  return  1.60 end,
    ["Rukiryaxe"]            = function(_)  return  1.68 end,
    ["Candy Corn Axe"]       = function(_)  return  1.75 end,
    ["Amber Axe"]            = function(_)  return  3.39 end,
    ["The Many Axe"]         = function(_)  return 10.2  end,

    -- ── Context-Sensitive ──────────────────
    ["Pie Axe"] = function(tc)
        if tc == "Cherry"      then return 1.90 end
        return 0.95
    end,
    ["Fire Axe"] = function(tc)
        if tc == "Volcano"     then return 6.35 end
        return 0.60
    end,
    ["Cave Axe"] = function(tc)
        if tc == "CaveCrawler" then return 7.20 end
        return 0.40
    end,
    ["Frost Axe"] = function(tc)
        if tc == "Frost"       then return 6.00 end
        return 0.36
    end,
    ["Bird Axe"] = function(tc)
        if tc == "CaveCrawler" then return 3.90
        elseif tc == "Volcano" then return 2.50 end
        return 1.65
    end,
    ["Bluesteel Axe"] = function(tc)
        if tc == "BlueSpruce"  then return 12.10 end
        return 2.80
    end,
    ["OverGrown Axe"] = function(tc)
        if tc == "GreenSwampy" then return 7.00
        elseif tc == "GoldSwampy" then return 5.30 end
        return 0.80
    end,
    ["Gingerbread Axe"] = function(tc)
        if tc == "Koa"         then return 11.00
        elseif tc == "Walnut"  then return  8.50 end
        return 1.20
    end,
    ["End Times Axe"] = function(tc)
        if tc == "LoneCave"    then return 1e7  end
        return 1.58
    end,
}

LT2Axes.Priority = {
    "The Many Axe",            -- 10.20
    "Amber Axe",               --  3.39
    "Bluesteel Axe",           --  2.80  base  (12.10 vs BlueSpruce)
    "Johiro",                  --  1.80
    "Candy Corn Axe",          --  1.75
    "Rukiryaxe",               --  1.68
    "Bird Axe",                --  1.65  base  (3.90 vs CaveCrawler)
    "Silver Axe",              --  1.60
    "End Times Axe",           --  1.58  base  (1e7  vs LoneCave)
    "Alpha Axe of Testing",    --  1.50
    "Pig Axe",                 --  1.50
    "Hardened Axe",            --  1.45
    "Beta Axe of Bosses",      --  1.45
    "Beesaxe",                 --  1.40
    "Gingerbread Axe",         --  1.20  base  (11.00 vs Koa)
    "Pie Axe",                 --  0.95  base  (1.90  vs Cherry)
    "Steel Axe",               --  0.93
    "CHICKEN AXE",             --  0.90
    "OverGrown Axe",           --  0.80  base  (7.00  vs GreenSwampy)
    "Spearmint Axe",           --  0.80
    "Fire Axe",                --  0.60  base  (6.35  vs Volcano)
    "Plain Axe",               --  0.55
    "Rusty Axe",               --  0.55
    "Cave Axe",                --  0.40  base  (7.20  vs CaveCrawler)
    "Frost Axe",               --  0.36  base  (6.00  vs Frost)
    "Basic Hatchet",           --  0.20
    "Candy Cane Axe",          --  0.00
    "Refined Axe",             --  0.00
    "Inverse Axe",             -- -1.00
}

-- ==========================================
--  RANK LOOKUP
--  Quick integer rank by name.
--  Lower = higher priority. Unknown → nil.
-- ==========================================
LT2Axes.Rank = {}
for rank, name in ipairs(LT2Axes.Priority) do
    LT2Axes.Rank[name] = rank
end

-- ==========================================
--  GetDamage(axeName, treeClass)
--  Returns damage for the given axe against
--  the given tree class.
--  Falls back to 1.0 for unknown axes.
-- ==========================================
function LT2Axes.GetDamage(axeName, treeClass)
    local fn = LT2Axes.Damage[axeName]
    return fn and fn(treeClass) or 1.0
end

return LT2Axes
]], "LT2Axes"))() end
__modules["Logo"] = function() return assert(loadstring([=[-- [[ BRAND MODULE ]] --
-- Auto-spawns a 3D Dynxe logo bar in the workspace

local BrandModule = {}

local TweenService = game:GetService("TweenService")

local THEME = {
    Accent      = Color3.fromRGB(74,  120, 255),
    Background  = Color3.fromRGB(18,  18,  22),
    Surface     = Color3.fromRGB(24,  24,  29),
    TextWhite   = Color3.fromRGB(255, 255, 255),
    TextPrimary = Color3.fromRGB(220, 220, 220),
    Stroke      = Color3.fromRGB(40,  40,  48),
}

function BrandModule.Init(version, position, rotation, width, height)
    local VERSION  = version  or "v0.0.272"
    local POSITION = position or Vector3.new(43.5, 18, 55.3)
    local ROTATION = rotation or Vector3.new(0, -105, 0)
    local BAR_W    = width    or 60
    local BAR_H    = height   or 20
    local BAR_D    = BAR_W * 0.04

    -- Clean up any previous instance
    local existing = workspace:FindFirstChild("DynxeBrand")
    if existing then existing:Destroy() end

    local rootCF = CFrame.new(POSITION)
        * CFrame.Angles(
            math.rad(ROTATION.X),
            math.rad(ROTATION.Y),
            math.rad(ROTATION.Z)
        )

    local Model = Instance.new("Model")
    Model.Name = "DynxeBrand"

    local function MakePart(name, size, color, material)
        local p = Instance.new("Part")
        p.Name          = name
        p.Size          = size
        p.Color         = color
        p.Material      = material or Enum.Material.SmoothPlastic
        p.Anchored      = true
        p.CanCollide    = false
        p.CastShadow    = false
        p.TopSurface    = Enum.SurfaceType.Smooth
        p.BottomSurface = Enum.SurfaceType.Smooth
        p.Parent        = Model
        return p
    end

    local function MakeLabel(cf, size, text, font, color, xAlign)
        local p = MakePart("Label", size, Color3.new())
        p.Transparency = 1
        p.CFrame       = cf

        local sg = Instance.new("SurfaceGui", p)
        sg.Face           = Enum.NormalId.Front
        sg.SizingMode     = Enum.SurfaceGuiSizingMode.PixelsPerStud
        sg.PixelsPerStud  = 50
        sg.AlwaysOnTop    = false
        sg.LightInfluence = 0

        local lbl = Instance.new("TextLabel", sg)
        lbl.Size                   = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text                   = text
        lbl.Font                   = font
        lbl.TextScaled             = true
        lbl.TextColor3             = color
        lbl.TextXAlignment         = xAlign

        local pad = Instance.new("UIPadding", lbl)
        pad.PaddingLeft  = UDim.new(0, 10)
        pad.PaddingRight = UDim.new(0, 10)
    end

    -- ── Main bar ──────────────────────────────────────────────────
    local Bar = MakePart("Bar", Vector3.new(BAR_W, BAR_H, BAR_D), THEME.Background)
    Bar.CFrame = rootCF

    -- ── Accent side caps ──────────────────────────────────────────
    local capSize = Vector3.new(0.18, BAR_H, BAR_D + 0.04)
    local CapL = MakePart("CapLeft",  capSize, THEME.Accent, Enum.Material.Neon)
    local CapR = MakePart("CapRight", capSize, THEME.Accent, Enum.Material.Neon)
    CapL.CFrame = rootCF * CFrame.new(-(BAR_W / 2 + 0.09), 0, -0.02)
    CapR.CFrame = rootCF * CFrame.new( (BAR_W / 2 + 0.09), 0, -0.02)

    -- ── Bottom accent strip ───────────────────────────────────────
    local Strip = MakePart("AccentStrip", Vector3.new(BAR_W, 0.18, BAR_D + 0.04), THEME.Accent, Enum.Material.Neon)
    Strip.CFrame = rootCF * CFrame.new(0, -(BAR_H / 2 + 0.09), -0.02)

    -- ── Layout constants ──────────────────────────────────────────
    local FRONT_Z = -(BAR_D / 2 + 0.05)
    local TOP_Y   = BAR_H / 2
    local HDR_H   = BAR_H * 0.28
    local HDR_Y   = TOP_Y - HDR_H / 2 - BAR_H * 0.04
    local HALF_W  = BAR_W / 2 - 0.2

    -- ── Version (left side of header) ─────────────────────────────
    MakeLabel(
        rootCF * CFrame.new(-(HALF_W / 2), HDR_Y, FRONT_Z),
        Vector3.new(HALF_W, HDR_H * 0.65, 0.1),
        VERSION,
        Enum.Font.Gotham,
        THEME.Accent,
        Enum.TextXAlignment.Left
    )

    -- ── "Dynxe" (right side of header) ────────────────────────────
    MakeLabel(
        rootCF * CFrame.new( (HALF_W / 2), HDR_Y, FRONT_Z),
        Vector3.new(HALF_W, HDR_H, 0.1),
        "Dynxe",
        Enum.Font.GothamBold,
        THEME.TextWhite,
        Enum.TextXAlignment.Right
    )

    -- ── Divider strip below the header ────────────────────────────
    local DIV_Y   = HDR_Y - HDR_H / 2 - BAR_H * 0.04
    local DIV_H   = BAR_H * 0.022
    local Divider = MakePart("Divider", Vector3.new(BAR_W * 0.92, DIV_H, 0.06), THEME.Stroke)
    Divider.CFrame = rootCF * CFrame.new(0, DIV_Y, FRONT_Z)

    -- ── Thank-you message ─────────────────────────────────────────
    local MSG_Y = DIV_Y - DIV_H / 2 - (BAR_H * 0.28)
    local MSG_H = BAR_H * 0.50
    MakeLabel(
        rootCF * CFrame.new(0, MSG_Y, FRONT_Z),
        Vector3.new(BAR_W * 0.92, MSG_H, 0.1),
        "Thank you for using Dynxe!",
        Enum.Font.GothamMedium,
        THEME.TextPrimary,
        Enum.TextXAlignment.Center
    )

    Model.PrimaryPart = Bar
    Model.Parent      = workspace

    -- ── Neon pulse ────────────────────────────────────────────────
    task.spawn(function()
        while Model and Model.Parent do
            TweenService:Create(Strip, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Color = Color3.fromRGB(100, 150, 255)
            }):Play()
            task.wait(1.4)
            TweenService:Create(Strip, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Color = THEME.Accent
            }):Play()
            task.wait(1.4)
        end
    end)

    return Model
end

return BrandModule
]=], "Logo"))() end
__modules["Home"] = function() return assert(loadstring([[local HomeModule = {}

function HomeModule.Init(Tab, Library)
    local Player            = game:GetService("Players").LocalPlayer
    local TeleportService   = game:GetService("TeleportService")
    local HttpService       = game:GetService("HttpService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local function ForceSaveBeforeLeave()
        local loadSaveRequests = ReplicatedStorage:FindFirstChild("LoadSaveRequests")
        local currentSlot = Player:FindFirstChild("CurrentSaveSlot")
                         or (Player:FindFirstChild("Data") and Player.Data:FindFirstChild("CurrentSaveSlot"))
        if not (loadSaveRequests and currentSlot and currentSlot.Value ~= -1) then return end

        local RequestSaveRemote = loadSaveRequests:FindFirstChild("RequestSave")
        if not RequestSaveRemote then return end

        Library:Notify("Dynxe LT2", "Saving plot before leaving...")
        pcall(function()
            RequestSaveRemote:InvokeServer(currentSlot.Value)
        end)
        task.wait(0.5)
    end

    Tab:CreateSection("Server Management")

    local function ServerHop(sortOrder, label)
        ForceSaveBeforeLeave()
        Library:Notify("Dynxe LT2", "Searching for " .. label .. " server...")
        local api = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=%s&limit=100"):format(game.PlaceId, sortOrder)
        local ok, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(api))
        end)
        if not ok or not result or not result.data then
            Library:Notify("Error 100", "Failed to fetch server list.")
            return
        end
        for _, s in ipairs(result.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, Player)
                return
            end
        end
        Library:Notify("Error 101", "No suitable server found.")
    end

    Tab:CreateAction("Rejoin Server", "Rejoin", function()
        ForceSaveBeforeLeave()
        TeleportService:Teleport(game.PlaceId, Player)
    end)

    local HopRow = Tab:CreateRow()
    HopRow:CreateAction("Descending", "Join", function() ServerHop("Asc",  "least populated") end)
    HopRow:CreateAction("Ascending",  "Join", function() ServerHop("Desc", "most populated")  end)

    Tab:CreateSection("Community & Support")

    Tab:CreateAction("Discord Server", "Copy", function()
        setclipboard("https://discord.gg/bSaWYeaw7Q")
        Library:Notify("Dynxe LT2", "Discord link copied!")
    end)
    Tab:CreateAction("Dynxe Services", "Copy", function()
        setclipboard("https://dynxe.services/")
        Library:Notify("Dynxe LT2", "Website link copied!")
    end)
    Tab:CreateAction("Donate", "Copy", function()
        setclipboard("https://ko-fi.com/dynxe")
        Library:Notify("Dynxe LT2", "Donation link copied!")
    end):AddTooltip("Donations go directly to server hosting and development costs for Dynxe!")
end

return HomeModule]], "Home"))() end
__modules["Player"] = function() return assert(loadstring([[local Player = {}

function Player.Init(Tab)
    local Players          = game:GetService("Players")
    local RunService       = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Workspace        = game:GetService("Workspace")
    local LocalPlayer      = Players.LocalPlayer
    local Mouse            = LocalPlayer:GetMouse()
    local Camera           = Workspace.CurrentCamera

    local env = getgenv and getgenv() or _G

    if env.PM_Connections then
        for _, conn in pairs(env.PM_Connections) do
            if typeof(conn) == "RBXScriptConnection" then
                conn:Disconnect()
            end
        end
    end
    env.PM_Connections = {}

    -- ===========================
    -- STATE VARIABLES
    -- ===========================
    env.WalkSpeed     = 16
    env.SprintEnabled = false
    env.SprintSpeed   = 32
    env.IsSprinting   = false

    env.JumpHeight = 50
    env.InfJump    = false

    env.FlyMasterSwitch = true
    env.IsFlying        = false
    env.FlySpeed        = 100

    env.Noclip      = false
    env.WaterWalk   = false
    env.ClickTP     = false
    env.HardDragger = false

    local flyVelocity     = nil
    local flyGyro         = nil
    local hardDraggerConn = nil

    -- Freecam state
    local freecamActive = false
    local freecamPos    = Vector3.new(0, 50, 0)
    local freecamYaw    = 0
    local freecamPitch  = 0
    local freecamRMB    = false
    local freecamConn   = nil
    local FREECAM_SENS  = 0.003

    local undoStack  = {}
    local btoolsConn = nil
    local ctrlHeld   = false

    -- ===========================
    -- CLEANUP ORPHANED OBJECTS
    -- ===========================
    local function CleanupOrphanedFlyObjects()
        local char = LocalPlayer.Character
        if not char then return end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")

        if hrp then
            for _, v in pairs(hrp:GetChildren()) do
                if v.Name == "ExploitFlyVelocity" or v.Name == "ExploitFlyGyro" then
                    v:Destroy()
                end
            end
            pcall(function() hrp.Velocity    = Vector3.new(0, 0, 0) end)
            pcall(function() hrp.RotVelocity = Vector3.new(0, 0, 0) end)
        end

        if hum then
            hum.PlatformStand = false
            task.delay(0.05, function()
                hum:ChangeState(Enum.HumanoidStateType.Freefall)
            end)
        end

        env.IsFlying = false
        env.Noclip   = false
        flyVelocity  = nil
        flyGyro      = nil

        -- Disable freecam on character reset so camera returns to normal
        if freecamActive then
            freecamActive                  = false
            if freecamConn then freecamConn:Disconnect(); freecamConn = nil end
            Camera.CameraType              = Enum.CameraType.Custom
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            freecamRMB                     = false
        end
    end

    CleanupOrphanedFlyObjects()

    table.insert(env.PM_Connections, LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.1)
        CleanupOrphanedFlyObjects()
    end))

    -- ===========================
    -- PHYSICS & UTILS
    -- ===========================
    local function UpdateFlyPhysics(state)
        local char = LocalPlayer.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")

        if state and hrp and hum then
            if not flyVelocity or not flyVelocity.Parent then
                flyVelocity = Instance.new("BodyVelocity")
                flyVelocity.Name     = "ExploitFlyVelocity"
                flyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
                flyVelocity.Velocity = Vector3.new(0, 0, 0)
                flyVelocity.Parent   = hrp
            end
            if not flyGyro or not flyGyro.Parent then
                flyGyro = Instance.new("BodyGyro")
                flyGyro.Name      = "ExploitFlyGyro"
                flyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
                flyGyro.P         = 10000
                flyGyro.Parent    = hrp
            end
            hum.PlatformStand = true
        else
            if flyVelocity then flyVelocity:Destroy(); flyVelocity = nil end
            if flyGyro     then flyGyro:Destroy();     flyGyro     = nil end
            if hum then
                hum.PlatformStand = false
                task.wait(0.05)
                hum:ChangeState(Enum.HumanoidStateType.Freefall)
            end
        end
    end

    -- ===========================
    -- FREECAM
    -- ===========================
    local function SetFreecam(state)
        freecamActive = state

        if freecamConn then freecamConn:Disconnect(); freecamConn = nil end

        if not state then
            Camera.CameraType              = Enum.CameraType.Custom
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            freecamRMB                     = false
            return
        end

        -- Seed position and angles from where the camera currently sits
        freecamPos    = Camera.CFrame.Position
        local lookVec = Camera.CFrame.LookVector
        freecamYaw    = math.atan2(-lookVec.X, -lookVec.Z)
        freecamPitch  = math.asin(math.clamp(lookVec.Y, -1, 1))

        Camera.CameraType = Enum.CameraType.Scriptable

        freecamConn = RunService.RenderStepped:Connect(function(dt)
            if not freecamActive then return end

            -- Rotation: sample GetMouseDelta every frame while RMB is held
            if freecamRMB then
                local delta  = UserInputService:GetMouseDelta()
                freecamYaw   = freecamYaw   - delta.X * FREECAM_SENS
                freecamPitch = math.clamp(
                    freecamPitch - delta.Y * FREECAM_SENS,
                    math.rad(-89), math.rad(89)
                )
            end

            local speed = env.FlySpeed * dt
            local rot   = CFrame.Angles(0, freecamYaw, 0) * CFrame.Angles(freecamPitch, 0, 0)

            local moveDir = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W)         then moveDir += rot.LookVector       end
            if UserInputService:IsKeyDown(Enum.KeyCode.S)         then moveDir -= rot.LookVector       end
            if UserInputService:IsKeyDown(Enum.KeyCode.A)         then moveDir -= rot.RightVector      end
            if UserInputService:IsKeyDown(Enum.KeyCode.D)         then moveDir += rot.RightVector      end
            if UserInputService:IsKeyDown(Enum.KeyCode.E)         then moveDir += Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir -= Vector3.new(0, 1, 0) end

            if moveDir.Magnitude > 0 then
                freecamPos += moveDir.Unit * speed
            end

            Camera.CFrame = CFrame.new(freecamPos)
                * CFrame.Angles(0, freecamYaw, 0)
                * CFrame.Angles(freecamPitch, 0, 0)
        end)
    end

    -- ===========================
    -- HARD DRAGGER
    -- ===========================
    local function SetHardDragger(state)
        if hardDraggerConn then
            hardDraggerConn:Disconnect()
            hardDraggerConn = nil
        end
        if not state then return end
    
        hardDraggerConn = RunService.Stepped:Connect(function()
            local dragger = Workspace:FindFirstChild("Dragger")
            if dragger then
                local bp = dragger:FindFirstChild("BodyPosition")
                local bg = dragger:FindFirstChild("BodyGyro")
                if bp then
                    bp.P        = 120000
                    bp.D        = 1000
                    bp.maxForce = Vector3.new(1, 1, 1) * math.huge
                end
                if bg then
                    bg.maxTorque = Vector3.new(1, 1, 1) * math.huge
                    bg.P         = 1200
                    bg.D         = 140
                end
            end
        end)
    end

    -- ===========================
    -- INPUT CONNECTIONS
    -- ===========================
    table.insert(env.PM_Connections, UserInputService.InputBegan:Connect(function(input, processed)
        -- Ctrl + Click TP
        if not processed and env.ClickTP
            and input.UserInputType == Enum.UserInputType.MouseButton1
            and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
            end
        end

        -- Freecam: lock mouse position while RMB held for smooth rotation
        if freecamActive and input.UserInputType == Enum.UserInputType.MouseButton2 then
            freecamRMB                     = true
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
        end
    end))

    table.insert(env.PM_Connections, UserInputService.InputEnded:Connect(function(input)
        -- Freecam: unlock mouse when RMB released
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            freecamRMB = false
            if freecamActive then
                UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            end
        end
    end))

    table.insert(env.PM_Connections, UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.LeftAlt then ctrlHeld = true end
    end))
    table.insert(env.PM_Connections, UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.LeftAlt then ctrlHeld = false end
    end))

    table.insert(env.PM_Connections, UserInputService.JumpRequest:Connect(function()
        if env.InfJump then
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState("Jumping") end
        end
    end))

    -- ===========================
    -- UI SECTIONS
    -- ===========================
    Tab:CreateSection("Movement")
    Tab:CreateSlider("Walk Speed",   16,  500,  16,  function(v) env.WalkSpeed   = v end)
    Tab:CreateSlider("Jump Height",  50,  800,  50,  function(v) env.JumpHeight  = v end)
    Tab:CreateSlider("Sprint Speed", 32,  1000, 32,  function(v) env.SprintSpeed = v end)
    Tab:CreateSlider("Fly Speed",    50,  1000, 100, function(v) env.FlySpeed    = v end)

    local SprintRow = Tab:CreateRow()
    SprintRow:CreateToggle("Sprint", false, function(s) env.SprintEnabled = s end)
    SprintRow:CreateKeybind("KeyBind", Enum.KeyCode.LeftShift, function()
        env.IsSprinting = not env.IsSprinting
    end)

    local FlyRow = Tab:CreateRow()
    FlyRow:CreateToggle("Fly", true, function(s)
        env.FlyMasterSwitch = s
        if not s and env.IsFlying then
            env.IsFlying = false
            UpdateFlyPhysics(false)
        end
    end)
    FlyRow:CreateKeybind("KeyBind", Enum.KeyCode.Q, function()
        if env.FlyMasterSwitch and not freecamActive then
            env.IsFlying = not env.IsFlying
            UpdateFlyPhysics(env.IsFlying)
        end
    end)

    Tab:CreateSection("Camera")
    Tab:CreateSlider("Field of View", 60, 120, 70, function(v) Camera.FieldOfView = v end)
    Tab:CreateToggle("Infinite Zoom", false, function(s)
        LocalPlayer.CameraMaxZoomDistance = s and 10000 or 128
        LocalPlayer.CameraMinZoomDistance = 0.5
    end):AddTooltip("Disable fog in world tab for the best results. At extreme distances, fog can block your view.")
    Tab:CreateToggle("Freecam", false, function(s)
        SetFreecam(s)
    end):AddTooltip("WASD = move  |  E / Shift = up / down  |  Hold right-click to rotate  |  Speed uses Fly Speed slider.")
    
    Tab:CreateSection("Utility")
    Tab:CreateToggle("Infinite Jump",   false, function(s) env.InfJump   = s end)
    Tab:CreateToggle("Noclip",          false, function(s) env.Noclip    = s end)
    Tab:CreateToggle("Water Walk",      false, function(s) env.WaterWalk = s end)
    Tab:CreateToggle("Ctrl + Click TP", false, function(s) env.ClickTP   = s end)
    Tab:CreateToggle("Hard Dragger",    false, function(s)
        env.HardDragger = s
        SetHardDragger(s)
    end)
    Tab:CreateToggle("BTools", false, function(state)
        if state then
            undoStack = {}

            local deleteTool            = Instance.new("Tool")
            deleteTool.Name             = "Delete"
            deleteTool.ToolTip          = "Click an object to delete it"
            deleteTool.RequiresHandle   = false
            deleteTool.CanBeDropped     = false
            deleteTool.Parent           = LocalPlayer.Backpack -- <-- FIXED HERE

            local undoTool              = Instance.new("Tool")
            undoTool.Name               = "Undo"
            undoTool.ToolTip            = "Click to undo last deletion"
            undoTool.RequiresHandle     = false
            undoTool.CanBeDropped       = false
            undoTool.Parent             = LocalPlayer.Backpack -- <-- FIXED HERE

            local function GetWholeObject(part)
                local node = part
                while node.Parent
                    and node.Parent ~= workspace
                    and node.Parent:IsA("Model")
                do
                    node = node.Parent
                end
                return node
            end

            local deleteConn = deleteTool.Activated:Connect(function()
                local target = Mouse.Target
                if not target or not target:IsA("BasePart") then return end
                if target:IsDescendantOf(LocalPlayer.Character or Instance.new("Folder")) then return end
                if target == workspace.Terrain then return end
                if target.Parent == workspace then return end

                local toDelete = target
                if ctrlHeld then
                    toDelete = GetWholeObject(target)
                end

                table.insert(undoStack, {
                    part   = toDelete,
                    parent = toDelete.Parent,
                    cframe = toDelete:IsA("BasePart") and toDelete.CFrame or nil,
                })
                toDelete.Parent = nil
                print(("[BTools] Deleted '%s' (%s) — %d item(s) in undo stack"):format(toDelete.Name, toDelete.ClassName, #undoStack))
            end)

            local undoConn = undoTool.Activated:Connect(function()
                if #undoStack == 0 then
                    print("[BTools] Nothing to undo.")
                    return
                end
                local entry = table.remove(undoStack, #undoStack)
                if entry.part then
                    entry.part.Parent = entry.parent
                    if entry.part:IsA("BasePart") then
                        entry.part.CFrame = entry.cframe
                    end
                    print(("[BTools] Restored '%s' — %d item(s) remaining"):format(entry.part.Name, #undoStack))
                end
            end)

            btoolsConn = {
                deleteConn = deleteConn,
                undoConn   = undoConn,
                deleteTool = deleteTool,
                undoTool   = undoTool,
            }

        else
            if btoolsConn then
                btoolsConn.deleteConn:Disconnect()
                btoolsConn.undoConn:Disconnect()

                local char = LocalPlayer.Character -- <-- FIXED HERE
                if char then
                    local equipped = char:FindFirstChildOfClass("Tool")
                    if equipped and (equipped == btoolsConn.deleteTool or equipped == btoolsConn.undoTool) then
                        equipped.Parent = LocalPlayer.Backpack -- <-- FIXED HERE
                    end
                end

                btoolsConn.deleteTool:Destroy()
                btoolsConn.undoTool:Destroy()
                btoolsConn = nil
            end

            -- NOTE: If you want deleted objects to STAY deleted when you turn BTools off,
            -- remove or comment out this block entirely. Otherwise, turning BTools off restores everything.
            for i = #undoStack, 1, -1 do
                local entry = undoStack[i]
                if entry.part then
                    entry.part.Parent = entry.parent
                    if entry.part:IsA("BasePart") then
                        entry.part.CFrame = entry.cframe
                    end
                end
            end
            undoStack = {}
        end
    end)
    Tab:CreateAction("Reset Character", "Kill", function()
        if LocalPlayer.Character then LocalPlayer.Character:BreakJoints() end
    end)

    -- ===========================
    -- MASTER LOOP
    -- ===========================
    table.insert(env.PM_Connections, RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end

        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")

        if hum and not env.IsFlying then
            hum.PlatformStand = false
        end

        if env.Noclip then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end

        if hum then
            hum.UseJumpPower = true
            if freecamActive then
                -- Freeze the character completely while freecam is active
                hum.WalkSpeed = 0
                hum.JumpPower = 0
            else
                hum.JumpPower = env.JumpHeight
                if env.SprintEnabled and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    hum.WalkSpeed = env.SprintSpeed
                else
                    hum.WalkSpeed = env.WalkSpeed
                end
            end
        end

        if env.WaterWalk and hrp then
            if hrp.Position.Y <= 1 and hrp.Position.Y >= -5 then
                hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
                hrp.CFrame   = hrp.CFrame + Vector3.new(0, 0.1, 0)
            end
        end

        if env.IsFlying and hrp then
            if not hrp:FindFirstChild("ExploitFlyVelocity") then UpdateFlyPhysics(true) end
            if flyVelocity and flyGyro then
                local moveVector = Vector3.new(0, 0, 0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + Camera.CFrame.LookVector  end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - Camera.CFrame.LookVector  end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + Camera.CFrame.RightVector end
                local vel = (moveVector.Magnitude > 0) and (moveVector.Unit * env.FlySpeed) or Vector3.new(0, 0, 0)
                flyVelocity.Velocity = vel
                flyGyro.CFrame       = Camera.CFrame
            end
        end
    end))
end

return Player
]], "Player"))() end
__modules["Teleport"] = function() return assert(loadstring([[local TeleportModule = {}

function TeleportModule.Init(Tab)
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    local VehiclePresets = {
        ["Pickup1_Vehicle"] = {
            Size = Vector3.new(10, 6, 18),
            Offset = CFrame.new(0, 3, 11.5)
        },
        ["UtilityTruck_Vehicle"] = {
            Size = Vector3.new(7, 3, 10),
            Offset = CFrame.new(0, 1.75, 5.75)
        },
        ["UtilityTruck2_Vehicle"] = {
            Size = Vector3.new(8, 3, 11),
            Offset = CFrame.new(0, 1.75, 6)
        },
    }

    local selectedTarget = nil
    local localTag = LocalPlayer.DisplayName .. " (You)"
    
    local tpBtn 

    local function GetPlayerList()
        local list = { localTag }
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                table.insert(list, p.DisplayName)
            end
        end
        return list
    end

    local function GetVehicleSpecs(vehicleModel)
        if not vehicleModel then return nil end
        
        local itemNameObj = vehicleModel:FindFirstChild("ItemName")
        if itemNameObj and itemNameObj:IsA("StringValue") then
            return VehiclePresets[itemNameObj.Value]
        end
        return nil
    end

    local function Teleport(Pos)
        local Character = LocalPlayer.Character
        if not Character then return end
        
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        if not HumanoidRootPart then return end

        local targetCFrame = CFrame.new(Pos + Vector3.new(0, 1, 0))

        local seatPart = Humanoid and Humanoid.SeatPart
        local vehicleModel = seatPart and seatPart:FindFirstAncestorOfClass("Model")

        if vehicleModel then
            local vehicleParts = {}
            for _, descendant in ipairs(vehicleModel:GetDescendants()) do
                if descendant:IsA("BasePart") then
                    vehicleParts[descendant] = descendant.Anchored
                    descendant.Anchored = true
                end
            end

            local preset = GetVehicleSpecs(vehicleModel)
            
            if preset then
                local detectionSize = preset.Size
                local detectionOffset = preset.Offset
                
                local currentPivot = vehicleModel:GetPivot()
                local movementTransform = targetCFrame * currentPivot:Inverse()
                
                local detectionCFrame = currentPivot * detectionOffset
                local overlapParams = OverlapParams.new()
                overlapParams.FilterType = Enum.RaycastFilterType.Exclude
                overlapParams.FilterDescendantsInstances = {vehicleModel, Character}
                overlapParams.RespectCanCollide = false
                
                local looseItems = workspace:GetPartBoundsInBox(detectionCFrame, detectionSize, overlapParams)
                local processedItems = {}
                
                for _, part in ipairs(looseItems) do
                    if part:IsA("BasePart") and not part.Anchored then
                        local rootModel = part:FindFirstAncestorOfClass("Model")
                        if rootModel and rootModel ~= workspace then
                            if not processedItems[rootModel] then
                                processedItems[rootModel] = true
                                rootModel:PivotTo(movementTransform * rootModel:GetPivot())
                            end
                        else
                            if not processedItems[part] then
                                processedItems[part] = true
                                part.CFrame = movementTransform * part.CFrame
                            end
                        end
                    end
                end
            end
            
            vehicleModel:PivotTo(targetCFrame)
            
            task.wait(0.05)
            for part, originalAnchorState in pairs(vehicleParts) do
                if part and part.Parent then
                    part.Anchored = originalAnchorState
                end
            end
        else
            HumanoidRootPart.CFrame = targetCFrame
        end
    end

    local storeData = {
        ["Wood R Us"]          = Vector3.new(265, 3, 57),
        ["Land Store"]         = Vector3.new(257, 3, -99),
        ["Boxed Cars"]         = Vector3.new(510, 3, -1465),
        ["Fancy Furnishings"]  = Vector3.new(500, 3, -1720),
        ["Links Logic"]        = Vector3.new(4607, 7, -795),
        ["Fine Arts Shop"]     = Vector3.new(5207, -166, 719),
        ["Bob's Shack"]        = Vector3.new(260, 8.4, -2542.0),
    }

    local regionData = {
        ["Cherry Meadow"]      = Vector3.new(220.9, 59.8, 1305.8),
        ["Volcano"]            = Vector3.new(-1585, 622, 1140),
        ["Swamp"]              = Vector3.new(-1209, 132, -801),
        ["Tiaga Peak"]         = Vector3.new(1448, 413, 3186),
        ["Snow Biome"]         = Vector3.new(890.0, 59.8, 1195.6),
        ["SnowGlow Biome"]     = Vector3.new(-1087.3, -5.9, -946.2),
        ["Cave"]               = Vector3.new(3581.0, -179.5, 430.0),
        ["Palm Island 1"]      = Vector3.new(2000, -6, -1500),
        ["Lonecave"]           = Vector3.new(115, -214, -1095),
    }

    local otherData = {
        ["Bridge"]             = Vector3.new(112.3, 11.0, -782.4),
        ["Docks"]              = Vector3.new(1114.0, -1.2, -197.0),
        ["The Den"]            = Vector3.new(323.0, 41.8, 1930.0),
        ["Safari"]             = Vector3.new(111.9, 11.0, -998.8),
        ["The Cabin"]          = Vector3.new(1244.0, 63.6, 2306.0),
        ["Bird Cave"]          = Vector3.new(4813.1, 17.7, -978.8),
        ["Strange Man"]        = Vector3.new(1061.0, 16.8, 1131.0),
        ["Green Box"]          = Vector3.new(-1668.1, 349.6, 1475.4),
        ["Light House"]        = Vector3.new(1464.8, 355.2, 3257.2),
        ["Shrine of Sight"]    = Vector3.new(-1600.0, 195.4, 919.0),
        ["Fridge"]             = Vector3.new(550.17,-1, -1714.16),
    }

    local function GetSortedKeys(DataTable)
        local keys = {}
        for k in pairs(DataTable) do table.insert(keys, k) end
        table.sort(keys)
        return keys
    end

    Tab:CreateSection("World Teleports")

    Tab:CreateDropdown("Stores", GetSortedKeys(storeData), "Select Store...", function(val)
        Teleport(storeData[val])
    end)

    Tab:CreateDropdown("Tree Regions", GetSortedKeys(regionData), "Select Region...", function(val)
        Teleport(regionData[val])
    end)

    Tab:CreateDropdown("Other POIs", GetSortedKeys(otherData), "Select Location...", function(val)
        Teleport(otherData[val])
    end)

    Tab:CreateSection("Player & Plot")
    
    local playerDropdown = Tab:CreateDropdown("Select Player", GetPlayerList(), "Select...", function(val)
        if val == localTag then
            selectedTarget = LocalPlayer.DisplayName
            if tpBtn then tpBtn:SetDisabled(true) end
        else
            selectedTarget = val
            if tpBtn then tpBtn:SetDisabled(false) end
        end
    end)
    
    tpBtn = Tab:CreateAction("Teleport to Player", "Player", function()
        if selectedTarget and selectedTarget ~= LocalPlayer.DisplayName then
            for _, p in pairs(Players:GetPlayers()) do
                if p.DisplayName == selectedTarget and p.Character then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then Teleport(hrp.Position) end
                end
            end
        end
    end)

    Tab:CreateAction("Teleport to Plot", "Plot", function()
        local targetDisplay = selectedTarget or LocalPlayer.DisplayName
        local properties = workspace:FindFirstChild("Properties")
        if not properties then return end
        
        for _, plot in pairs(properties:GetChildren()) do
            local owner = plot:FindFirstChild("Owner")
            if owner and owner.Value then
                local ownerName = ""
                if typeof(owner.Value) == "Instance" and owner.Value:IsA("Player") then
                    ownerName = owner.Value.DisplayName
                elseif typeof(owner.Value) == "string" then
                    ownerName = owner.Value 
                end

                if ownerName == targetDisplay then
                    local origin = plot:FindFirstChild("OriginSquare")
                        or plot:FindFirstChild("Origin")
                        or plot:FindFirstChildOfClass("BasePart")
                    if origin then 
                        Teleport(origin.Position) 
                    end
                    break
                end
            end
        end
    end)

    tpBtn:SetDisabled(true)

    Tab:CreateSection("Coordinates")

    local function GetCurrentPosition()
        local Character = LocalPlayer.Character
        if not Character then return nil end

        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        local seatPart = Humanoid and Humanoid.SeatPart
        local vehicleModel = seatPart and seatPart:FindFirstAncestorOfClass("Model")

        if vehicleModel then
            return vehicleModel:GetPivot().Position
        elseif Character:FindFirstChild("HumanoidRootPart") then
            return Character.HumanoidRootPart.Position
        end
        return nil
    end

    local waypoints = {}
    local waypointCounter = 0
    local selectedWaypoint = nil

    local function GetWaypointNames()
        local list = {}
        for name in pairs(waypoints) do table.insert(list, name) end
        table.sort(list)
        return list
    end

    local waypointDropdown = Tab:CreateDropdown("Waypoints", GetWaypointNames(), "Select Waypoint...", function(val)
        selectedWaypoint = val
    end)

    Tab:CreateAction("Save Waypoint", "Save", function()
        local pos = GetCurrentPosition()
        if not pos then return end

        waypointCounter += 1
        local name = "Waypoint " .. waypointCounter
        waypoints[name] = pos
        selectedWaypoint = name
        waypointDropdown:SetOptions(GetWaypointNames())
    end)

    Tab:CreateAction("Teleport", "TP", function()
        if selectedWaypoint and waypoints[selectedWaypoint] then
            Teleport(waypoints[selectedWaypoint])
        end
    end)

    local function RefreshPlayerList()
        local list = GetPlayerList()
        playerDropdown:SetOptions(list)
        
        if selectedTarget then
            local stillPresent = false
            for _, name in ipairs(list) do
                if name == selectedTarget then stillPresent = true; break end
            end
            
            if not stillPresent then
                selectedTarget = nil
                tpBtn:SetDisabled(true)
            end
        end
    end

    Players.PlayerAdded:Connect(RefreshPlayerList)
    Players.PlayerRemoving:Connect(function()
        task.defer(RefreshPlayerList)
    end)
end

return TeleportModule]], "Teleport"))() end
__modules["World"] = function() return assert(loadstring([[local World = {}

function World.Init(Tab, Lib)
    local Lighting    = game:GetService("Lighting")
    local RunService  = game:GetService("RunService")
    local Workspace   = game:GetService("Workspace")

    _G.TimeOfDay              = 12
    _G.TimeLock               = false
    _G.FullBright             = false
    _G.ShadowsEnabled         = true
    _G.FogEnabled             = true
    _G.WaterEnabled           = true
    _G.PostProcessing         = true
    _G.SpookEvent             = false
    _G.EnhancedGraphics       = false

    local waterParts             = {}
    local boulderParts           = {}
    local effectCache            = {}
    local originalLightingSettings = {}

    local cachedAtmosphere = Lighting:FindFirstChildOfClass("Atmosphere")

    local _volcanoSweepAccum = 0

    local function SweepVolcanoBoulders()
        local spawner = Workspace:FindFirstChild("Region_Volcano")
            and Workspace.Region_Volcano:FindFirstChild("PartSpawner")
        if not spawner then return end
        for _, obj in ipairs(spawner:GetDescendants()) do
            if obj.Name == "VolcanoBoulder" then
                pcall(function() obj:Destroy() end)
            end
        end
    end

    local bridgeBackup = nil
    if Workspace:FindFirstChild("Bridge") then
        bridgeBackup = Workspace.Bridge:Clone()
    end

    local waterRoot   = Workspace:FindFirstChild("Water")
    local boulderRoot = Workspace:FindFirstChild("Region_Snow")
        and Workspace.Region_Snow:FindFirstChild("PartSpawner")

    local _tundraConn = nil 

    local function IsTundraBoulder(obj)
        return obj:IsA("BasePart")
            and (obj.Name == "Boulder" or obj.Name == "SmallBoulder")
            and not (obj:FindFirstChild("LavaLight") or obj:FindFirstChild("Fire"))
    end

    local function ApplyBoulderState(data)
        local part = data.Instance
        if part and part.Parent then
            part.Transparency = _G.BouldersEnabled and data.OriginalTransparency or 1
            part.CanCollide   = _G.BouldersEnabled
        end
    end

    local function StartTundraWatcher()
        if _tundraConn or not boulderRoot then return end
        _tundraConn = boulderRoot.ChildAdded:Connect(function(obj)
            if not IsTundraBoulder(obj) then return end
            local data = { Instance = obj, OriginalTransparency = obj.Transparency }
            table.insert(boulderParts, data)
            if not _G.BouldersEnabled then ApplyBoulderState(data) end
        end)
    end

    local function StopTundraWatcher()
        if _tundraConn then _tundraConn:Disconnect(); _tundraConn = nil end
    end

    local function ScanContainer(root, fn)
        if not root then return end
        local descendants = root:GetDescendants()
        for i, obj in ipairs(descendants) do
            if i % 500 == 0 then task.wait() end
            fn(obj)
        end
    end

    local function ScanWorld()
        waterParts   = {}
        boulderParts = {}

        originalLightingSettings.FogEnd = Lighting.FogEnd
        originalLightingSettings.FogStart = Lighting.FogStart
        if cachedAtmosphere then
            originalLightingSettings.AtmosphereDensity = cachedAtmosphere.Density
            originalLightingSettings.AtmosphereGlare = cachedAtmosphere.Glare
            originalLightingSettings.AtmosphereHaze = cachedAtmosphere.Haze
        end

        ScanContainer(waterRoot, function(obj)
            if obj:IsA("BasePart") and obj.Name == "Water" then
                table.insert(waterParts, { Instance = obj, OriginalTransparency = obj.Transparency })
            end
        end)

        ScanContainer(boulderRoot, function(obj)
            if IsTundraBoulder(obj) then
                table.insert(boulderParts, { Instance = obj, OriginalTransparency = obj.Transparency })
            end
        end)

        for _, effect in ipairs(Lighting:GetChildren()) do
            if effect:IsA("PostProcessEffect") or effect:IsA("BlurEffect")
            or effect:IsA("BloomEffect") or effect:IsA("ColorCorrectionEffect")
            or effect:IsA("SunRaysEffect") then
                effectCache[effect] = effect.Enabled
            end
        end

        StartTundraWatcher()

        if Lib and Lib.Notify then
            Lib:Notify("System", "World Scan Complete!", 2)
        end
    end

    task.spawn(ScanWorld)

    local function ToggleBridge(state)
        if state then
            local bridge = Workspace:FindFirstChild("Bridge")
            if bridge then
                local vlb  = bridge:FindFirstChild("VerticalLiftBridge")
                local lift = vlb and vlb:FindFirstChild("Lift")
                if lift then
                    for _, child in ipairs(lift:GetChildren()) do
                        if child:IsA("BasePart") and child.Name == "Base" then
                            child.CFrame = CFrame.new(child.Position.X, 6.5, child.Position.Z) * child.CFrame.Rotation
                        end
                    end
                end
                local targets = { BRope = true, Structure = true, Weight = true, WRope = true }
                if vlb then
                    for _, child in ipairs(vlb:GetChildren()) do
                        if targets[child.Name] then child:Destroy() end
                    end
                end
            end
        else
            if bridgeBackup then
                if Workspace:FindFirstChild("Bridge") then
                    Workspace.Bridge:Destroy()
                end
                bridgeBackup:Clone().Parent = Workspace
            end
        end
    end

    local function ToggleEnhanced(state)
        if state then
            originalLightingSettings.Brightness            = Lighting.Brightness
            originalLightingSettings.OutdoorAmbient        = Lighting.OutdoorAmbient
            originalLightingSettings.ExposureCompensation  = Lighting.ExposureCompensation

            Lighting.Brightness             = 3
            Lighting.ExposureCompensation   = 0.5

            local bloom = Lighting:FindFirstChild("EnhancedBloom") or Instance.new("BloomEffect", Lighting)
            bloom.Name = "EnhancedBloom"; bloom.Intensity = 1; bloom.Size = 24; bloom.Threshold = 2; bloom.Enabled = true

            local cc = Lighting:FindFirstChild("EnhancedCC") or Instance.new("ColorCorrectionEffect", Lighting)
            cc.Name = "EnhancedCC"; cc.Contrast = 0.1; cc.Saturation = 0.15
            cc.TintColor = Color3.fromRGB(255, 253, 245); cc.Enabled = true

            local rays = Lighting:FindFirstChild("EnhancedRays") or Instance.new("SunRaysEffect", Lighting)
            rays.Name = "EnhancedRays"; rays.Intensity = 0.1; rays.Spread = 1; rays.Enabled = true
        else
            Lighting.Brightness             = originalLightingSettings.Brightness or 2
            Lighting.ExposureCompensation   = originalLightingSettings.ExposureCompensation or 0
            for _, n in ipairs({ "EnhancedBloom", "EnhancedCC", "EnhancedRays" }) do
                local e = Lighting:FindFirstChild(n)
                if e then e.Enabled = false end
            end
        end
    end

    local function ToggleWater(state)
        for _, data in ipairs(waterParts) do
            local part = data.Instance
            if part and part.Parent then
                part.Transparency = state and data.OriginalTransparency or 1
                part.CanCollide   = false
                part.CanTouch     = state
            end
        end
    end

    local function ToggleBoulders(state)
        for _, data in ipairs(boulderParts) do
            ApplyBoulderState(data)
        end
    end

    Tab:CreateSection("Lighting & Time")

    Tab:CreateSlider("Time of Day", 0, 24, 12, function(v)
        _G.TimeOfDay = v
        Lighting.ClockTime = v
    end)

    Tab:CreateToggle("Time Lock", false, function(s) _G.TimeLock = s end)

    Tab:CreateToggle("Full Bright", false, function(s)
        _G.FullBright = s
    end)

    Tab:CreateToggle("Shadows", true, function(s)
        _G.ShadowsEnabled       = s
        Lighting.GlobalShadows  = s
    end)

    Tab:CreateToggle("Fog", true, function(s)
        _G.FogEnabled = s
        if s then
            Lighting.FogEnd = originalLightingSettings.FogEnd or 1000
            Lighting.FogStart = originalLightingSettings.FogStart or 0
            if cachedAtmosphere then
                cachedAtmosphere.Density = originalLightingSettings.AtmosphereDensity or 0.3
                cachedAtmosphere.Glare = originalLightingSettings.AtmosphereGlare or 0
                cachedAtmosphere.Haze = originalLightingSettings.AtmosphereHaze or 0
            end
        end
    end)

    Tab:CreateSection("Environment")

    Tab:CreateToggle("Enhanced Visuals", false, function(s)
        _G.EnhancedGraphics = s
        ToggleEnhanced(s)
        if Lib and Lib.Notify then Lib:Notify("Graphics", s and "Visuals Enhanced!" or "Visuals reset.", 3) end
    end)

    Tab:CreateToggle("Spook Event", false, function(s)
        _G.SpookEvent = s
        local spook = Lighting:FindFirstChild("Spook")
        if spook then
            spook.Value = s
        elseif Lib and Lib.Notify then
            Lib:Notify("Error", "Spook object not found in Lighting!", 3)
        end
    end)

    Tab:CreateToggle("Post-Processing", true, function(s)
        _G.PostProcessing = s
        for effect, originalState in pairs(effectCache) do
            if effect then effect.Enabled = s and originalState or false end
        end
    end)

    Tab:CreateToggle("Water Enabled", true, function(s)
        _G.WaterEnabled = s
        ToggleWater(s)
    end)

    Tab:CreateToggle("Lower Bridge", false, function(s)
        _G.BridgeDown = s
        ToggleBridge(s)
    end)

    Tab:CreateToggle("Tundra Boulders", true, function(s)
        _G.BouldersEnabled = s
        ToggleBoulders(s)
    end)

    Tab:CreateToggle("Volcano Boulders", true, function(s)
        _G.VolcanoBouldersEnabled = s
        if not s then SweepVolcanoBoulders() end
    end)

    RunService.RenderStepped:Connect(function(dt)
        if _G.TimeLock then
            Lighting.ClockTime = _G.TimeOfDay
        end

        if _G.FullBright then
            Lighting.Ambient        = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness     = 2
        end

        if not _G.FogEnabled then
            Lighting.FogEnd = 1e6
            Lighting.FogStart = 1e6
            
            if not cachedAtmosphere then
                cachedAtmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
            end
            
            if cachedAtmosphere then
                cachedAtmosphere.Density = 0
                cachedAtmosphere.Glare = 0
                cachedAtmosphere.Haze = 0
            end
        end

        if _G.VolcanoBouldersEnabled == false then
            _volcanoSweepAccum += dt
            if _volcanoSweepAccum >= 0.05 then
                _volcanoSweepAccum = 0
                SweepVolcanoBoulders()
            end
        end
    end)
end

return World
]], "World"))() end
__modules["Settings"] = function() return assert(loadstring([[local SettingsModule = {}
local CoreGui      = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
_G.NexusConnections = _G.NexusConnections or {}

function SettingsModule.Init(Tab, MainUI, RepoConfig, Config)
    local ScreenGui, MainFrame, SidebarFrame
    if typeof(MainUI) == "table" then
        ScreenGui    = MainUI.UI
        MainFrame    = MainUI.Frame
        SidebarFrame = MainUI.Sidebar
    elseif typeof(MainUI) == "Instance" then
        ScreenGui = MainUI
    end
    if not ScreenGui or not ScreenGui.Parent then
        ScreenGui = CoreGui:FindFirstChild("DynxeHub")
    end

    local W = Config and Config.Window

    if Config and MainFrame then

        Tab:CreateSection("Customization")

        local themeModule = _G.DynxeTheme
        if themeModule then
            Tab:CreateToggle("Dark Theme", themeModule.IsEnabled(), function(state)
                if state then
                    themeModule.Enable()
                else
                    themeModule.Disable()
                end
            end)
        end

        Tab:CreateSlider("Width", 300, 500, W.Width, function(val)
            W.Width = val
            TweenService:Create(MainFrame, TweenInfo.new(0.2), {
                Size = UDim2.new(0, val, 0, W.Height),
            }):Play()
        end)

        Tab:CreateSlider("Height", 400, 600, W.Height, function(val)
            W.Height = val
            TweenService:Create(MainFrame, TweenInfo.new(0.2), {
                Size = UDim2.new(0, W.Width, 0, val),
            }):Play()
        end)

        Tab:CreateSlider("Menu Opacity", 0, 100, 85, function(val)
            TweenService:Create(MainFrame, TweenInfo.new(0.2), {
                BackgroundTransparency = 1 - (val / 100)
            }):Play()
        end)
    end

    Tab:CreateSection("System")

    _G.DynxeMenuClamped = false
    Tab:CreateToggle("Clamp Menu", false, function(state)
        _G.DynxeMenuClamped = state
    end)

    Tab:CreateKeybind("Toggle Menu", Enum.KeyCode.LeftAlt, function()
        if ScreenGui then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)

    local function Unload()
        _G.NexusActive = false
        for _, conn in pairs(_G.NexusConnections) do
            if typeof(conn) == "RBXScriptConnection" and conn.Connected then
                conn:Disconnect()
            end
        end
        _G.NexusConnections = {}
        pcall(function() game:GetService("Lighting").ClockTime = 12 end)
        pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Custom end)
        if ScreenGui and ScreenGui.Parent then ScreenGui:Destroy() end
    end

    local ReloadAction = Tab:CreateAction("Reload Script", "Reload", function()
        Unload()
        task.wait(0.1)
        local ok, result = pcall(function()
            return game:HttpGet("https://api.dynxe.services/loader")
        end)
        if ok and result and result ~= "" then
            local fn = loadstring(result)
            if fn then fn() else warn("[Settings] Reload: loadstring failed") end
        else
            warn("[Settings] Reload: HttpGet failed — " .. tostring(result))
        end
    end)
    ReloadAction:SetDisabled(true)

    local UnloadAction = Tab:CreateAction("Unload Script", "Unload", Unload)
    UnloadAction:SetDisabled(true)

    Tab:CreateSection("Data Management")

    Tab:CreateAction("Open Folder", "Open", function()
        pcall(function()
            if isfolder and not isfolder("Dynxe") then
                makefolder("Dynxe")
            end
        end)
    
        local opened = false
    
        -- Synapse X
        if not opened and syn and syn.open_folder then
            pcall(function() syn.open_folder("Dynxe") end)
            opened = true
        end
    
        -- Fluxus / some others
        if not opened and explorerfolder then
            pcall(function() explorerfolder("Dynxe") end)
            opened = true
        end
    
        -- Krnl / Wave / some others
        if not opened and openfolder then
            pcall(function() openfolder("Dynxe") end)
            opened = true
        end
    
        -- openfile fallback
        if not opened and openfile then
            pcall(function() openfile("Dynxe") end)
            opened = true
        end
    
        if not opened then
            warn("[Settings] Executor: " .. tostring(identifyexecutor and identifyexecutor() or "unknown") .. " does not support opening folders.")
        end
    end)

    local FolderAction = Tab:CreateAction("Delete Folder", "Delete", function()
        pcall(function()
            if isfolder and isfolder("Dynxe") then
                delfolder("Dynxe")
            elseif isfile and isfile("Dynxe") then
                delfile("Dynxe")
            end
        end)

        task.wait(0.5)

        pcall(function()
            game:GetService("Players").LocalPlayer:Kick(
                "\n[Dynxe Hub]\nData reset initiated.\n\nThe 'Dynxe' folder has been removed.\nPlease rejoin to generate new configs."
            )
        end)
    end)
    FolderAction:AddTooltip("Deletes the storage folder for Dynxe. Also kicks you from the game to prevent any errors from occuring.")
end

return SettingsModule]], "Settings"))() end
__modules["AntiVoid"] = function() return assert(loadstring([[local AntiVoid = {}
function AntiVoid.Init(Tab)
    local RunService  = game:GetService("RunService")
    local Players     = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    _G.AntiVoidEnabled = false
    local VOID_THRESHOLD  = -60
    local FALLBACK_POSITION = Vector3.new(257.4, 3.2, 57.7)

    local function GetSafeDestination()
        -- 1. Try to find the player's plot
        local properties = workspace:FindFirstChild("Properties")
        if properties then
            for _, plot in ipairs(properties:GetChildren()) do
                local owner = plot:FindFirstChild("Owner")
                if owner and owner.Value == LocalPlayer then
                    local origin = plot:FindFirstChild("Origin")
                    if origin then
                        return origin.CFrame + Vector3.new(0, 5, 0)
                    end
                end
            end
        end
        -- 2. Fallback to the safe spawn position
        return CFrame.new(FALLBACK_POSITION)
    end

    Tab:CreateToggle("Anti-Void", false, function(state)
        _G.AntiVoidEnabled = state
    end)

    RunService.Heartbeat:Connect(function()
        if not _G.AntiVoidEnabled then return end
        local char = LocalPlayer.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and hrp.Position.Y < VOID_THRESHOLD then
            hrp.AssemblyLinearVelocity  = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            hrp.CFrame = GetSafeDestination()
        end
    end)
end
return AntiVoid
]], "AntiVoid"))() end
__modules["AntiRagdoll"] = function() return assert(loadstring([[local AntiRagdoll = {}

function AntiRagdoll.Init(Tab)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer


    -- STATE VARIABLES
    _G.AntiRagdollEnabled = true


    -- CORE LOGIC
    local function SetStates(hum, state)
        if not hum then return end
        
        -- Disable the specific physics states that cause "falling over"
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, not state)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, not state)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, not state)
        
        if state then
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end


    -- UI SECTIONS
    Tab:CreateToggle("Anti-Ragdoll", true, function(s)
        _G.AntiRagdollEnabled = s
        
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            SetStates(hum, s)
        end
    end)
    -- MASTER LOOP
    RunService.Stepped:Connect(function()
        if not _G.AntiRagdollEnabled then return end
        
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if hum then
            -- If the humanoid enters a "fallen" state, force it back to GettingUp immediately
            local currentState = hum:GetState()
            if currentState == Enum.HumanoidStateType.FallingDown or currentState == Enum.HumanoidStateType.Ragdoll then
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end
    end)

    -- Ensure it stays active after death/respawn
    LocalPlayer.CharacterAdded:Connect(function(newChar)
        if _G.AntiRagdollEnabled then
            local hum = newChar:WaitForChild("Humanoid")
            task.wait(0.1) -- Small delay for character physics to initialize
            SetStates(hum, true)
        end
    end)
end

return AntiRagdoll
]], "AntiRagdoll"))() end
__modules["AntiAFK"] = function() return assert(loadstring([[local AntiAFK = {}

function AntiAFK.Init(Tab)
    local Players = game:GetService("Players")
    local VirtualUser = game:GetService("VirtualUser")
    local LocalPlayer = Players.LocalPlayer


    -- STATE VARIABLES
    _G.AntiAFKEnabled = true


    -- UI SECTION
    Tab:CreateToggle("Anti-AFK", true, function(state)
        _G.AntiAFKEnabled = state
    end)


    -- MASTER LOGIC
    -- Connect to the Idled event of the player
    LocalPlayer.Idled:Connect(function()
        if _G.AntiAFKEnabled then
            -- This simulates a mouse movement/click on the screen to reset the AFK timer
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
            
            warn("[Anti-AFK]: Prevented disconnect at " .. os.date("%X"))
        end
    end)
end

return AntiAFK
]], "AntiAFK"))() end
__modules["AxeRecovery"] = function() return assert(loadstring([[local AxeRecoverModule = {}

-- ==========================================
--               SETTINGS
-- ==========================================
local Settings = {
    RespawnSettleDelay = 0.1,   -- seconds to wait after respawn before scanning
    PickupTimeout      = 3,     -- seconds to keep retrying one axe before skipping
    PickupFireRate     = 0.15,  -- seconds between remote fires during retry loop
    AxeRecoverRadius   = 50,    -- studs around death position to search
    MaxAxesToRecover   = 9,    -- hard cap on axes processed per respawn
}

-- ==========================================
--               SERVICES & VARS
-- ==========================================
local Players           = game:GetService("Players")
local Workspace         = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player           = Players.LocalPlayer
local ClientInteracted = ReplicatedStorage:WaitForChild("Interaction"):WaitForChild("ClientInteracted")

local _autoRecoverOn   = false
local _autoRecoverConn = nil 
local _deathPosition   = nil 
local _deathHumConn    = nil 

-- ==========================================
--               HELPERS
-- ==========================================

local function GetOwnedAxesNearDeath()
    local axes         = {}
    local playerModels = Workspace:FindFirstChild("PlayerModels")
    if not playerModels then return axes end

    for _, obj in ipairs(playerModels:GetDescendants()) do
        if not (obj.Name == "Model" and obj:IsA("Model")) then continue end

        local ownerFolder = obj:FindFirstChild("Owner")
        if not ownerFolder then continue end
        local ownerStr = ownerFolder:FindFirstChild("OwnerString")
        if not ownerStr or ownerStr.Value ~= player.Name then continue end

        if _deathPosition then
            local handle = obj:FindFirstChild("Handle") or obj.PrimaryPart
            if not handle then continue end
            if (handle.Position - _deathPosition).Magnitude > Settings.AxeRecoverRadius then continue end
        end

        table.insert(axes, obj)
    end
    return axes
end

local function CountHeldTools()
    local count = 0
    local containers = {player.Backpack, player.Character, Workspace:FindFirstChild(player.Name)}
    
    for _, container in ipairs(containers) do
        if container then
            for _, v in ipairs(container:GetChildren()) do
                if v.Name == "Tool" and v:IsA("Tool") then count += 1 end
            end
        end
    end
    return count
end

local function PickupAxeWithRetry(axe)
    local handle = axe:FindFirstChild("Handle") or axe.PrimaryPart
    if not handle then return false end

    local before   = CountHeldTools()
    local deadline = tick() + Settings.PickupTimeout

    while tick() < deadline do
        if not axe or not axe.Parent then return false end
        
        -- Fire remote without moving the character
        ClientInteracted:FireServer(axe, "Pick up tool", handle.CFrame)
        
        task.wait(Settings.PickupFireRate)
        if CountHeldTools() > before then
            return true
        end
    end
    return false
end

-- ==========================================
--               CORE LOGIC
-- ==========================================

local function OnRespawnedRecover(char)
    task.wait(Settings.RespawnSettleDelay)
    if not _autoRecoverOn then return end

    local axes = GetOwnedAxesNearDeath()
    if #axes == 0 then return end

    if #axes > Settings.MaxAxesToRecover then
        axes = {table.unpack(axes, 1, Settings.MaxAxesToRecover)}
    end

    local picked = 0
    for i, axe in ipairs(axes) do
        if PickupAxeWithRetry(axe) then
            picked += 1
            print(("[AxeRecoverModule] Recovered %d/%d"):format(i, #axes))
        end
    end
end

local function HookDeathPosition(char)
    if _deathHumConn then _deathHumConn:Disconnect() end
    local hum = char:WaitForChild("Humanoid", 10)
    if not hum then return end
    _deathHumConn = hum.Died:Connect(function()
        local hrp = char:FindFirstChild("HumanoidRootPart")
        _deathPosition = hrp and hrp.Position or nil
    end)
end

local function Start()
    if _autoRecoverConn then return end
    _autoRecoverOn = true
    if player.Character then task.spawn(HookDeathPosition, player.Character) end
    _autoRecoverConn = player.CharacterAdded:Connect(function(char)
        task.spawn(HookDeathPosition, char)
        task.spawn(OnRespawnedRecover, char)
    end)
end

local function Stop()
    _autoRecoverOn = false
    if _autoRecoverConn then _autoRecoverConn:Disconnect(); _autoRecoverConn = nil end
    if _deathHumConn then _deathHumConn:Disconnect(); _deathHumConn = nil end
    _deathPosition = nil
end

function AxeRecoverModule.Init(Tab)
    Tab:CreateToggle("Axe Recovery", true, function(state)
        if state then Start() else Stop() end
    end)
    Start()
end

return AxeRecoverModule
]], "AxeRecovery"))() end
__modules["LooseObjectTeleport"] = function() return assert(loadstring([=[-- [[ LOOSE OBJECT TELEPORT MODULE ]] --
-- Designed for Dynxe LT2 UI Engine

local LooseObjectTeleport = {}

local UIS          = game:GetService("UserInputService")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local GuiService   = game:GetService("GuiService")
local Players      = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player    = Players.LocalPlayer
local Camera    = workspace.CurrentCamera
local Mouse     = Player:GetMouse()

local ClientIsDragging = ReplicatedStorage:WaitForChild("Interaction"):WaitForChild("ClientIsDragging")

-- ┌─────────────────────────────────────────────────────────────────┐
-- │                        SIGNAL UTILITY                           │
-- └─────────────────────────────────────────────────────────────────┘
local function NewSignal()
    local sig = { _listeners = {} }
    function sig:Connect(fn)
        local id = {}
        self._listeners[id] = fn
        return { Disconnect = function() self._listeners[id] = nil end }
    end
    function sig:Wait()
        local co = coroutine.running()
        local conn
        conn = self:Connect(function(...)
            conn:Disconnect()
            task.spawn(co, ...)
        end)
        return coroutine.yield()
    end
    function sig:_Fire(...)
        for _, fn in pairs(self._listeners) do
            task.spawn(fn, ...)
        end
    end
    return sig
end

-- ┌─────────────────────────────────────────────────────────────────┐
-- │                     CONFIGURATION & STATE                       │
-- └─────────────────────────────────────────────────────────────────┘
local Settings = {
    OwnershipTimeout = 1,
    FallbackWait     = 0.5,
    PreFireWait      = 0.05,
    PostObjectDelay  = 0.1,
    ProximityRadius  = 10,

    SelectionColor   = Color3.fromRGB(74, 120, 255),
    OutlineThickness = 0.05,

    StackX       = 5,
    StackY       = 1,
    StackZ       = 2,
    StackPadding = 0.1,

    PyramidMode  = false,
    KeepSelected   = false,
    ReturnToOrigin = true,
    MatchPlankSize = true,
}

local State = {
    SelectedObjects = {},
    SelectionBoxes  = {},
    Connections     = {},
    IsBusy          = false,
    BatchCancelled  = false,

    ClickSelectMode = false,
    GroupSelectMode = false,
    LassoMode       = false,
    LassoDragging   = false,
    LassoStartPos   = nil,
    LassoGui        = nil,
    LassoFrame      = nil,
    TpBtn           = nil,

    StackMode         = false,
    StackPreviewParts = {},
    StackPreviewBoxes = {},
    StackPreviewConn  = nil,
    StackStartBtn     = nil,
    StackRotation     = CFrame.new(),
    ItemRotation      = CFrame.new(),

    Library        = nil,
    BatchCompleted = NewSignal(),

    -- Set in Init once both action buttons exist.
    -- Called by UpdateVisuals on every selection change so button
    -- disabled-states always reflect the current selection.
    SyncButtons    = nil,
}

-- ┌─────────────────────────────────────────────────────────────────┐
-- │                        HELPER FUNCTIONS                         │
-- └─────────────────────────────────────────────────────────────────┘
local function GetItemName(model)
    if not model then return nil end
    local iv = model:FindFirstChild("ItemName")
    return (iv and iv.Value ~= "") and iv.Value or model.Name
end

local function GetOwnerIdentity(model)
    if not model then return nil end
    local ownerValue = model:FindFirstChild("Owner")
    if ownerValue then
        local val = ownerValue.Value
        if typeof(val) == "Instance" and val:IsA("Player") then return val.Name end
        return tostring(val)
    end
    return nil
end

local function GetModelSignature(model)
    local mainPart  = model:FindFirstChild("Main") or model:FindFirstChildWhichIsA("BasePart")
    local mainClass = mainPart and mainPart.ClassName or "nil"
    local childKeys = {}
    for _, child in ipairs(model:GetChildren()) do
        if child.Name == "Type" then continue end
        table.insert(childKeys, child.ClassName .. ":" .. child.Name)
    end
    table.sort(childKeys)
    return mainClass .. "|" .. table.concat(childKeys, ",")
end

local function GetTreeClass(model)
    local tc = model:FindFirstChild("TreeClass")
    return tc and tostring(tc.Value) or nil
end

-- Single source of truth for object eligibility.
-- All three selection modes (click, group, lasso) run candidates through
-- this so their rules are always identical.
local function getObjectData(target)
    if not target or not target:IsA("BasePart") or target.Anchored then return nil end
    if target:IsDescendantOf(Player.Character) then return nil end

    local current = target.Parent
    while current and current ~= workspace do
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
    local main  = (model and model:FindFirstChild("Main")) or target
    if main:IsA("BasePart") and not main.Anchored then
        return main, (model and model.Name or target.Name), model
    end
    return nil
end

local function UpdateVisuals()
    for _, v in pairs(State.SelectionBoxes) do v:Destroy() end
    State.SelectionBoxes = {}
    for _, obj in ipairs(State.SelectedObjects) do
        if obj and obj.Parent then
            local box         = Instance.new("SelectionBox")
            box.Color3        = Settings.SelectionColor
            box.LineThickness = Settings.OutlineThickness
            box.Adornee       = obj
            box.Parent        = game:GetService("CoreGui")
            table.insert(State.SelectionBoxes, box)
        end
    end
    -- Sync button disabled-states whenever selection changes.
    if State.SyncButtons then State.SyncButtons() end
end

-- ┌─────────────────────────────────────────────────────────────────┐
-- │                      CORE TELEPORT LOGIC                        │
-- └─────────────────────────────────────────────────────────────────┘
local function GetDynamicDelay()
    local samples = {}
    local last = workspace.DistributedGameTime
    for _ = 1, 5 do
        RunService.Heartbeat:Wait()
        local now = workspace.DistributedGameTime
        if now ~= last then
            table.insert(samples, now - last)
            last = now
        end
    end
    local avg = if #samples > 0
        then (function() local s = 0 for _, v in ipairs(samples) do s += v end return s / #samples end)()
        else 1/20  -- pessimistic fallback if no change was observed

    -- 60 hz server ≈ 0.016 s → ~0.25 s delay
    -- 20 hz server ≈ 0.050 s → ~0.75 s delay
    --  5 hz server ≈ 0.200 s → ~2.00 s delay (clamped)
    return math.clamp(avg * 20, 0.5, 1)
end

local function PlayerAlignedCFrame(position, root)
    local look     = root.CFrame.LookVector
    local flatLook = Vector3.new(look.X, 0, look.Z)
    if flatLook.Magnitude < 0.001 then
        flatLook = Vector3.new(0, 0, -1)
    end
    flatLook = flatLook.Unit
    local yaw = math.atan2(-flatLook.X, -flatLook.Z)
    return CFrame.new(position) * CFrame.Angles(0, yaw, 0) * CFrame.Angles(math.rad(90), 0, 0)
end
    
local function FindLastInteraction(model)
    local ownerFolder = model:FindFirstChild("Owner")
    if ownerFolder then
        local li = ownerFolder:FindFirstChild("LastInteraction")
        if li then return li end
    end
    return model:FindFirstChild("LastInteraction")
end

local function TeleportSingle(target, goalCF, root)
    if not target or not target.Parent then return end

    local model          = target:FindFirstAncestorOfClass("Model") or target.Parent
    local lastInteracted = FindLastInteraction(model)

    local flat = (root.Position - target.Position) * Vector3.new(1, 0, 1)
    if flat.Magnitude > Settings.ProximityRadius then
        root.CFrame = CFrame.new(target.Position + Vector3.new(0, 3, 0))
    end

    local ownerFolder = model:FindFirstChild("Owner")
    local ownerString = ownerFolder and ownerFolder:FindFirstChild("OwnerString")
    if ownerString and ownerString.Value ~= Player.Name then
        local MAX_ATTEMPTS = 5
        local BASE_DELAY   = GetDynamicDelay()
    
        for attempt = 1, MAX_ATTEMPTS do
            local deadline = tick() + (BASE_DELAY * attempt)
            while tick() < deadline do
                pcall(ClientIsDragging.FireServer, ClientIsDragging, model)
                task.wait()
            end
    
            if target and target.Parent then
                target.CFrame = goalCF
            end
            task.wait(0.2)
    
            local dist = (target.Position - goalCF.Position).Magnitude
            if dist < 2 then break end
        end
    
        task.wait(Settings.PostObjectDelay)
        return
    end

    task.wait(Settings.PreFireWait)

    if lastInteracted then
        local co    = coroutine.running()
        local fired = false

        local conn = lastInteracted:GetPropertyChangedSignal("Value"):Connect(function()
            if not fired then
                fired = true
                task.spawn(co)
            end
        end)

        local fireLoop = task.spawn(function()
            local deadline = tick() + Settings.OwnershipTimeout

            local ok, err = pcall(function()
                while not fired and tick() < deadline do
                    ClientIsDragging:FireServer(model)
                    task.wait()
                end
            end)

            if not fired then
                fired = true
                task.spawn(co)
                if not ok then
                    warn(("[LOT] FireServer errored on '%s': %s")
                        :format(model.Name, tostring(err)))
                else
                    warn(("[LOT] LastInteraction on '%s' never changed within %.1fs — proceeding anyway.")
                        :format(model.Name, Settings.OwnershipTimeout))
                end
            end
        end)

        coroutine.yield()
        conn:Disconnect()
        pcall(task.cancel, fireLoop)
    else
        warn(("[LOT] No Owner.LastInteraction found on '%s' — using fallback wait."):format(model.Name))
        local deadline = tick() + Settings.FallbackWait
        while tick() < deadline do
            local ok, err = pcall(ClientIsDragging.FireServer, ClientIsDragging, model)
            if not ok then
                warn(("[LOT] Fallback FireServer errored on '%s': %s"):format(model.Name, tostring(err)))
                break
            end
            task.wait()
        end
    end

    if target and target.Parent then
        target.CFrame = goalCF
    end

    task.wait(Settings.PostObjectDelay)
end

-- `returnToOrigin`: nil → use Settings.ReturnToOrigin (the toggle).
--                  true/false → explicit per-call override; toggle unchanged.
local function RunBatch(jobs, returnToOrigin)
    if returnToOrigin == nil then
        returnToOrigin = Settings.ReturnToOrigin
    end

    if #jobs == 0 then
        State.BatchCompleted:_Fire(true, 0)
        return true
    end

    local char = Player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not char or not root then
        State.BatchCompleted:_Fire(false, 0)
        return false
    end

    State.IsBusy         = true
    State.BatchCancelled = false

    local savedCFrame = root.CFrame

    for _, job in ipairs(jobs) do
        if State.BatchCancelled then break end
        if job.target and job.target.Parent then
            local ok, err = pcall(TeleportSingle, job.target, job.goalCF, root)
            if not ok then
                warn(("[LOT] TeleportSingle failed, skipping object: %s"):format(tostring(err)))
            end
        end
    end

    if returnToOrigin and root and root.Parent then
        root.CFrame = savedCFrame
    end

    State.IsBusy = false

    local success = not State.BatchCancelled
    State.BatchCompleted:_Fire(success, #jobs)
    return success
end

-- ┌─────────────────────────────────────────────────────────────────┐
-- │                         LASSO ENGINE                            │
-- └─────────────────────────────────────────────────────────────────┘
local function InitLassoGui()
    if State.LassoGui then State.LassoGui:Destroy() end
    local sg = Instance.new("ScreenGui")
    sg.Name           = "LassoDragGui"
    sg.ResetOnSpawn   = false
    sg.IgnoreGuiInset = true
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent         = game:GetService("CoreGui")

    local frame = Instance.new("Frame")
    frame.BackgroundColor3       = Color3.fromRGB(60, 130, 255)
    frame.BackgroundTransparency = 0.75
    frame.BorderSizePixel        = 0
    frame.Visible                = false
    frame.ZIndex                 = 10
    frame.Parent                 = sg

    local stroke           = Instance.new("UIStroke")
    stroke.Color           = Color3.fromRGB(120, 180, 255)
    stroke.Thickness       = 1.5
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent          = frame

    State.LassoGui   = sg
    State.LassoFrame = frame
end

local function UpdateLassoFrame(currentPos)
    if not State.LassoFrame or not State.LassoStartPos then return end
    local minX = math.min(State.LassoStartPos.X, currentPos.X)
    local minY = math.min(State.LassoStartPos.Y, currentPos.Y)
    local maxX = math.max(State.LassoStartPos.X, currentPos.X)
    local maxY = math.max(State.LassoStartPos.Y, currentPos.Y)
    State.LassoFrame.Position = UDim2.fromOffset(minX, minY)
    State.LassoFrame.Size     = UDim2.fromOffset(maxX - minX, maxY - minY)
    State.LassoFrame.Visible  = true
end

-- Searches PlayerModels using the same getObjectData eligibility rules
-- as Click Selection. `seen` prevents the same resolved Main part from
-- being toggled more than once across nested model paths.
local function SelectObjectsInLassoRect(startPos, endPos)
    local minX = math.min(startPos.X, endPos.X)
    local minY = math.min(startPos.Y, endPos.Y)
    local maxX = math.max(startPos.X, endPos.X)
    local maxY = math.max(startPos.Y, endPos.Y)
    if (maxX - minX) < 6 or (maxY - minY) < 6 then return end

    local playerModels = workspace:FindFirstChild("PlayerModels")
    if not playerModels then return end

    local inset = GuiService:GetGuiInset()
    local seen  = {}

    for _, obj in ipairs(playerModels:GetDescendants()) do
        if obj:IsA("BasePart") then
            local main = getObjectData(obj)   -- same rules as click selection
            if main and not seen[main] then
                seen[main] = true
                local screenPos, onScreen = Camera:WorldToScreenPoint(main.Position)
                local sx = screenPos.X + inset.X
                local sy = screenPos.Y + inset.Y
                if onScreen and screenPos.Z > 0
                    and sx >= minX and sx <= maxX
                    and sy >= minY and sy <= maxY then
                    local idx = table.find(State.SelectedObjects, main)
                    if idx then
                        table.remove(State.SelectedObjects, idx)
                    else
                        table.insert(State.SelectedObjects, main)
                    end
                end
            end
        end
    end

    UpdateVisuals()
end

-- ┌─────────────────────────────────────────────────────────────────┐
-- │                         STACK ENGINE                            │
-- └─────────────────────────────────────────────────────────────────┘

local function GetMainPartSizeY(model)
    local main = model:FindFirstChild("Main") or model:FindFirstChildWhichIsA("BasePart")
    if not main then return nil end
    return math.round(main.Size.Y * 100) / 100
end
    
local function AllSelectedSameType()
    if #State.SelectedObjects == 0 then return false, "Queue is empty." end
    local refName, refSig, refTreeClass, refSizeY
    for _, obj in ipairs(State.SelectedObjects) do
        if not (obj and obj.Parent) then continue end
        local model     = obj:FindFirstAncestorOfClass("Model")
        local name      = model and GetItemName(model) or obj.Name
        local sig       = model and GetModelSignature(model) or (obj.ClassName .. ":" .. obj.Name)
        local treeClass = model and GetTreeClass(model) or nil
        local sizeY     = model and GetMainPartSizeY(model) or nil

        if not refName then
            refName = name; refSig = sig
            refTreeClass = treeClass; refSizeY = sizeY
        else
            if name ~= refName or sig ~= refSig then
                return false, "Mixed item types — all items must be identical."
            end
            if treeClass ~= refTreeClass then
                return false, "Mixed wood types — all items must be the same tree class."
            end
            if sizeY ~= nil and refSizeY ~= nil then
                if Settings.MatchPlankSize and math.abs(sizeY - refSizeY) > 1 then
                    return false, "Mixed sizes — all items must be the same size."
                end
            end
        end
    end
    return true, "OK"
end

local function GetStackPositions(origin, itemSize, countX, countY, countZ, totalItems, stackRotation)
    stackRotation = stackRotation or CFrame.new()
    local stepX = itemSize.X + Settings.StackPadding
    local stepY = itemSize.Y
    local stepZ = itemSize.Z + Settings.StackPadding

    local raw = {}
    for y = 0, countY - 1 do
        for z = 0, countZ - 1 do
            for x = 0, countX - 1 do
                table.insert(raw, Vector3.new(x * stepX, y * stepY, z * stepZ))
                if #raw >= totalItems then break end
            end
            if #raw >= totalItems then break end
        end
        if #raw >= totalItems then break end
    end

    local sumX, sumZ = 0, 0
    for _, p in ipairs(raw) do sumX += p.X; sumZ += p.Z end
    local cx = sumX / #raw
    local cz = sumZ / #raw

    local positions = {}
    for _, p in ipairs(raw) do
        local centered = Vector3.new(p.X - cx, p.Y, p.Z - cz)
        table.insert(positions, origin + stackRotation:VectorToWorldSpace(centered))
    end
    return positions
end

local function GetPyramidCapacity(countX, countZ)
    local total, layer = 0, 0
    while true do
        local lx = countX - layer
        local lz = countZ - layer
        if lx <= 0 or lz <= 0 then break end
        total += lx * lz
        layer += 1
    end
    return math.max(total, 1)
end

local function GetPyramidPositions(origin, itemSize, countX, countZ, totalItems, stackRotation)
    stackRotation = stackRotation or CFrame.new()
    local stepX = itemSize.X + Settings.StackPadding
    local stepY = itemSize.Y
    local stepZ = itemSize.Z + Settings.StackPadding

    local raw   = {}
    local layer = 0

    while #raw < totalItems do
        local lx = countX - layer
        local lz = countZ - layer
        if lx <= 0 or lz <= 0 then break end

        -- Each layer shrinks inward so it sits centred on the one below
        local offsetX = layer * stepX * 0.5
        local offsetZ = layer * stepZ * 0.5

        for z = 0, lz - 1 do
            for x = 0, lx - 1 do
                table.insert(raw, Vector3.new(
                    x * stepX + offsetX,
                    layer * stepY,
                    z * stepZ + offsetZ
                ))
                if #raw >= totalItems then break end
            end
            if #raw >= totalItems then break end
        end
        layer += 1
    end

    local sumX, sumZ = 0, 0
    for _, p in ipairs(raw) do sumX += p.X; sumZ += p.Z end
    local cx = sumX / #raw
    local cz = sumZ / #raw

    local positions = {}
    for _, p in ipairs(raw) do
        local centered = Vector3.new(p.X - cx, p.Y, p.Z - cz)
        table.insert(positions, origin + stackRotation:VectorToWorldSpace(centered))
    end
    return positions
end
    
local function ClearStackPreview()
    if State.StackPreviewConn then State.StackPreviewConn:Disconnect() State.StackPreviewConn = nil end
    for _, box in ipairs(State.StackPreviewBoxes) do if box and box.Parent then box:Destroy() end end
    State.StackPreviewBoxes = {}
    for _, p in ipairs(State.StackPreviewParts) do if p and p.Parent then p:Destroy() end end
    State.StackPreviewParts = {}
end

local function SetTpBtnLabel(label)
    if State.TpBtn and State.TpBtn.SetText then
        State.TpBtn:SetText(label)
    end
end

local function SetStackBtnLabel(label)
    if State.StackStartBtn and State.StackStartBtn.SetText then
        State.StackStartBtn:SetText(label)
    end
end

local function StopStackMode(silent)
    State.StackMode     = false
    State.StackRotation = CFrame.new()
    State.ItemRotation  = CFrame.new()
    ClearStackPreview()
    if not silent then
        SetStackBtnLabel("Start")
        if State.SyncButtons then State.SyncButtons() end
    end
end

-- Returns the world-space bounding box size of an object after
-- applying a rotation. Used so stack steps match the rotated dimensions.
local function RotatedBoundingSize(size, rotation)
    local c1 = rotation.RightVector
    local c2 = rotation.UpVector
    local c3 = -rotation.LookVector
    return Vector3.new(
        math.abs(c1.X)*size.X + math.abs(c2.X)*size.Y + math.abs(c3.X)*size.Z,
        math.abs(c1.Y)*size.X + math.abs(c2.Y)*size.Y + math.abs(c3.Y)*size.Z,
        math.abs(c1.Z)*size.X + math.abs(c2.Z)*size.Y + math.abs(c3.Z)*size.Z
    )
end
    
-- silent=true → called from PerformStackExecute, which owns its label lifecycle.
-- Don't reset the label or call SyncButtons here in that case.
local function StartStackMode()
    if State.StackMode then StopStackMode() return end

    local ok = AllSelectedSameType()
    if not ok then return end

    local capacity = Settings.PyramidMode
        and GetPyramidCapacity(Settings.StackX, Settings.StackZ)
        or  (Settings.StackX * Settings.StackY * Settings.StackZ)
    local stackCount = math.min(capacity, #State.SelectedObjects)

    -- Reference model + sizes
    local refModel  = nil
    local refSize   = Vector3.new(4, 4, 4)
    local refBBSize = Vector3.new(4, 4, 4)
    for _, obj in ipairs(State.SelectedObjects) do
        if obj and obj.Parent then
            refModel = obj:FindFirstAncestorOfClass("Model") or obj.Parent
            refSize  = obj.Size
            local _, bbSize = refModel:GetBoundingBox()
            refBBSize = bbSize
            break
        end
    end
    if not refModel then return end

    ClearStackPreview()
    for i = 1, stackCount do
        local clone = refModel:Clone()
        for _, desc in ipairs(clone:GetDescendants()) do
            if desc:IsA("BasePart") then
                desc.Transparency = 0.55
                desc.Anchored     = true
                desc.CanCollide   = false
                desc.CanTouch     = false
                desc.CastShadow   = false
            end
        end
        local main = clone:FindFirstChild("Main") or clone:FindFirstChildWhichIsA("BasePart")
        if main then clone.PrimaryPart = main end
        clone.Parent = workspace
        table.insert(State.StackPreviewParts, clone)

        local box         = Instance.new("SelectionBox")
        box.Color3        = Color3.fromRGB(140, 180, 255)
        box.LineThickness = 0.03
        box.Adornee       = clone
        box.Parent        = game:GetService("CoreGui")
        table.insert(State.StackPreviewBoxes, box)
    end

    State.StackMode = true
    SetStackBtnLabel("Stop")
    if State.SyncButtons then State.SyncButtons() end

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude

    State.StackPreviewConn = RunService.RenderStepped:Connect(function()
        if not State.StackMode then return end

        local excludeList = {}
        if Player.Character then table.insert(excludeList, Player.Character) end
        for _, preview in ipairs(State.StackPreviewParts) do
            for _, part in ipairs(preview:GetDescendants()) do
                if part:IsA("BasePart") then table.insert(excludeList, part) end
            end
        end
        rayParams.FilterDescendantsInstances = excludeList

        local unitRay = Camera:ScreenPointToRay(Mouse.X, Mouse.Y)
        local result  = workspace:Raycast(unitRay.Origin, unitRay.Direction * 500, rayParams)
        -- Use bounding box height so the full model sits on the ground, not just the Main part
        local effectiveSize = RotatedBoundingSize(refSize, State.ItemRotation)
        local groundOrigin  = result
            and (result.Position + Vector3.new(0, RotatedBoundingSize(refBBSize, State.ItemRotation).Y * 0.5, 0))
            or  (unitRay.Origin + unitRay.Direction * 40)
        
        local positions = Settings.PyramidMode
            and GetPyramidPositions(
                    groundOrigin, effectiveSize,
                    Settings.StackX, Settings.StackZ,
                    #State.StackPreviewParts, State.StackRotation)
            or  GetStackPositions(
                    groundOrigin, effectiveSize,
                    Settings.StackX, Settings.StackY, Settings.StackZ,
                    #State.StackPreviewParts, State.StackRotation)

        for i, preview in ipairs(State.StackPreviewParts) do
            if positions[i] then
                preview:PivotTo(CFrame.new(positions[i]) * State.StackRotation * State.ItemRotation)
            end
        end
    end)
end

-- Keeps "Stop" on the stack button while the batch runs, resets to "Start" after.
local function PerformStackExecute(hitPos)
    if not State.StackMode then return end
    local ok = AllSelectedSameType()
    if not ok then StopStackMode() return end

    local refModel  = nil
    local refSize   = Vector3.new(4, 4, 4)
    local refBBSize = Vector3.new(4, 4, 4)
    for _, obj in ipairs(State.SelectedObjects) do
        if obj and obj.Parent then
            refModel = obj:FindFirstAncestorOfClass("Model") or obj.Parent
            refSize  = obj.Size
            local _, bbSize = refModel:GetBoundingBox()
            refBBSize = bbSize
            break
        end
    end
    
    local capacity = Settings.PyramidMode
        and GetPyramidCapacity(Settings.StackX, Settings.StackZ)
        or  (Settings.StackX * Settings.StackY * Settings.StackZ)
    local stackCount = math.min(capacity, #State.SelectedObjects)
    
    local capturedRotation     = State.StackRotation
        local capturedItemRotation = State.ItemRotation
    
        local effectiveSize = RotatedBoundingSize(refSize, capturedItemRotation)
        local groundOrigin  = hitPos + Vector3.new(0, RotatedBoundingSize(refBBSize, capturedItemRotation).Y * 0.5, 0)
        local goalPositions = Settings.PyramidMode
            and GetPyramidPositions(
                    groundOrigin, effectiveSize,
                    Settings.StackX, Settings.StackZ,
                    stackCount, capturedRotation)
            or  GetStackPositions(
                    groundOrigin, effectiveSize,
                    Settings.StackX, Settings.StackY, Settings.StackZ,
                    stackCount, capturedRotation)
    
    -- silent=true: don't let StopStackMode reset the label; we manage it below.
    StopStackMode(true)

    local jobs = {}
    for i = 1, stackCount do
        local obj = State.SelectedObjects[i]
        if obj and obj.Parent then
            table.insert(jobs, {
                target = obj,
                goalCF = CFrame.new(goalPositions[i] or groundOrigin) * capturedRotation * capturedItemRotation
            })
        end
    end

    task.spawn(function()
        SetStackBtnLabel("Stop")
        -- IsBusy is about to become true; ensure button stays enabled for cancel.
        if State.SyncButtons then State.SyncButtons() end

        RunBatch(jobs)

        SetStackBtnLabel("Start")
        if not Settings.KeepSelected then State.SelectedObjects = {} end
        UpdateVisuals()   -- also calls SyncButtons
    end)
end

-- ┌─────────────────────────────────────────────────────────────────┐
-- │                     BUTTON / HOTKEY ACTIONS                     │
-- └─────────────────────────────────────────────────────────────────┘
local function PerformSingleSelect()
    local main = getObjectData(Mouse.Target)
    if main then
        local idx = table.find(State.SelectedObjects, main)
        if not idx then
            table.insert(State.SelectedObjects, main)
        else
            table.remove(State.SelectedObjects, idx)
        end
        UpdateVisuals()
    end
end
    
-- Searches PlayerModels using the same getObjectData eligibility rules
-- as Click Selection. `seen` prevents double-toggling the same Main part.
local function PerformGroupSelect()
    local _, _, targetModel = getObjectData(Mouse.Target)
    if not targetModel then return end

    local targetItemName  = GetItemName(targetModel)
    local targetOwnerIden = GetOwnerIdentity(targetModel)
    local targetSig       = GetModelSignature(targetModel)
    local targetTreeClass = GetTreeClass(targetModel)
    local targetSizeY = targetModel and GetMainPartSizeY(targetModel) or nil

    if not targetItemName then return end

    local playerModels = workspace:FindFirstChild("PlayerModels")
    if not playerModels then return end

    local seen = {}
    local i    = 0
    for _, obj in ipairs(playerModels:GetDescendants()) do
        i += 1
        if i % 1000 == 0 then task.wait() end

        if obj:IsA("Model")
            and GetItemName(obj) == targetItemName
            and GetOwnerIdentity(obj) == targetOwnerIden
            and GetModelSignature(obj) == targetSig
            and GetTreeClass(obj) == targetTreeClass
            and (not Settings.MatchPlankSize
                or targetSizeY == nil
                or (GetMainPartSizeY(obj) ~= nil and math.abs(GetMainPartSizeY(obj) - targetSizeY) <= 1))
        then  -- <-- this was missing
            local rawPart = obj:FindFirstChild("Main") or obj:FindFirstChildWhichIsA("BasePart")
            if rawPart then
                local main = getObjectData(rawPart)
                if main and not seen[main] then
                    seen[main] = true
                    local idx = table.find(State.SelectedObjects, main)
                    if idx then
                        table.remove(State.SelectedObjects, idx)
                    else
                        table.insert(State.SelectedObjects, main)
                    end
                end
            end
        end
    end
    UpdateVisuals()
end

local function PerformClear()
    if State.StackMode then StopStackMode() end
    State.SelectedObjects = {}
    State.BatchCancelled  = true
    UpdateVisuals()
end

local function PerformExecute()
    if State.IsBusy then
        State.BatchCancelled = true
        return
    end

    if #State.SelectedObjects == 0 or not Player.Character then return end
    local char = Player.Character
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local finalPos = root.Position

    local jobs = {}
    for _, obj in ipairs(State.SelectedObjects) do
        if obj and obj.Parent then
            table.insert(jobs, {
                target = obj,
                goalCF = PlayerAlignedCFrame(finalPos, root)
            })
        end
    end

    task.spawn(function()
        SetTpBtnLabel("Stop")
        -- IsBusy is about to become true; keep button enabled for cancel.
        if State.SyncButtons then State.SyncButtons() end

        RunBatch(jobs)

        SetTpBtnLabel("Start")
        if not Settings.KeepSelected then State.SelectedObjects = {} end
        UpdateVisuals()   -- also calls SyncButtons
    end)
end

-- ┌─────────────────────────────────────────────────────────────────┐
-- │                         PUBLIC API                              │
-- └─────────────────────────────────────────────────────────────────┘
function LooseObjectTeleport.Select(part)
    assert(typeof(part) == "Instance" and part:IsA("BasePart"), "LOT.Select: expected BasePart")
    if State.IsBusy then warn("LOT.Select: ignored — batch running.") return end
    if not table.find(State.SelectedObjects, part) then
        table.insert(State.SelectedObjects, part)
        UpdateVisuals()
    end
end

function LooseObjectTeleport.Deselect(part)
    local idx = table.find(State.SelectedObjects, part)
    if idx then table.remove(State.SelectedObjects, idx) UpdateVisuals() end
end

function LooseObjectTeleport.Clear()
    PerformClear()
end

function LooseObjectTeleport.TeleportTo(goalCF, returnToOrigin)
    assert(typeof(goalCF) == "CFrame", "LOT.TeleportTo: expected CFrame")
    if #State.SelectedObjects == 0 then return false end
    if State.IsBusy then warn("LOT.TeleportTo: ignored — batch running.") return false end
    local jobs = {}
    for _, obj in ipairs(State.SelectedObjects) do
        if obj and obj.Parent then table.insert(jobs, { target = obj, goalCF = goalCF }) end
    end
    local success = RunBatch(jobs, returnToOrigin)
    State.SelectedObjects = {}
    UpdateVisuals()
    return success
end

function LooseObjectTeleport.TeleportObjectTo(part, goalCF, returnToOrigin)
    assert(typeof(part) == "Instance" and part:IsA("BasePart"), "LOT.TeleportObjectTo: expected BasePart")
    assert(typeof(goalCF) == "CFrame", "LOT.TeleportObjectTo: expected CFrame")
    if State.IsBusy then warn("LOT.TeleportObjectTo: ignored — batch running.") return false end
    return RunBatch({ { target = part, goalCF = goalCF } }, returnToOrigin)
end

function LooseObjectTeleport.TeleportMany(jobs, returnToOrigin)
    assert(type(jobs) == "table", "LOT.TeleportMany: expected table of jobs")
    if State.IsBusy then warn("LOT.TeleportMany: ignored — batch running.") return false end
    return RunBatch(jobs, returnToOrigin)
end

function LooseObjectTeleport.WaitForBatch()
    if not State.IsBusy then return true, 0 end
    return State.BatchCompleted:Wait()
end

function LooseObjectTeleport.IsBusy()
    return State.IsBusy
end

function LooseObjectTeleport.GetQueueSize()
    return #State.SelectedObjects
end

LooseObjectTeleport.BatchCompleted = nil

-- ┌─────────────────────────────────────────────────────────────────┐
-- │                          INITIALIZE                             │
-- └─────────────────────────────────────────────────────────────────┘
function LooseObjectTeleport.Init(Tab, LibraryInstance)
    State.Library = LibraryInstance
    LooseObjectTeleport.BatchCompleted = State.BatchCompleted

    for _, conn in ipairs(State.Connections) do conn:Disconnect() end
    State.Connections = {}

    InitLassoGui()

    local ClickToggle, GroupToggle, LassoToggle

    local function DisableOtherSelectionModes(except)
        if except ~= "click" and State.ClickSelectMode then
            State.ClickSelectMode = false
            if ClickToggle then ClickToggle:SetState(false) end
        end
        if except ~= "group" and State.GroupSelectMode then
            State.GroupSelectMode = false
            if GroupToggle then GroupToggle:SetState(false) end
        end
        if except ~= "lasso" and State.LassoMode then
            State.LassoMode     = false
            State.LassoDragging = false
            if State.LassoFrame then State.LassoFrame.Visible = false end
            if LassoToggle then LassoToggle:SetState(false) end
        end
    end

    local Notice = Tab:CreateInfoBox()
    Notice:AddText("⚠  Server Performance Notice", {
        Bold = true,
        Size = 14,
    })
    Notice:AddDivider()
    Notice:AddText(
        "You may experience delays or failures in heavily populated servers " ..
        "or on low tick-rate servers. If objects fail to move, try increasing " ..
        "the Ownership Timeout slider below.",
        {
            Size    = 13,
            Opacity = 0.80,
            Italic  = true,
            Wrap    = true,
        }
    )
    
    Tab:CreateSection("Selection Tools")
    ClickToggle = Tab:CreateToggle("Click Selection", false, function(val)
        State.ClickSelectMode = val
        if val then DisableOtherSelectionModes("click") end
    end)
    GroupToggle = Tab:CreateToggle("Group Selection", false, function(val)
        State.GroupSelectMode = val
        if val then DisableOtherSelectionModes("group") end
    end)
    LassoToggle = Tab:CreateToggle("Lasso Tool", false, function(val)
        State.LassoMode = val
        if val then
            DisableOtherSelectionModes("lasso")
        else
            State.LassoDragging = false
            if State.LassoFrame then State.LassoFrame.Visible = false end
        end
    end)

    local MainRow = Tab:CreateRow()
    MainRow:CreateAction("Clear Selection", "Clear", PerformClear)
    State.TpBtn = MainRow:CreateAction("Teleport Selection", "Start", function()
        task.spawn(PerformExecute)
    end)

    Tab:CreateSection("Sorting")
    local xSlider       = Tab:CreateSlider("X", 1, 40, Settings.StackX, function(val) Settings.StackX = val end)
    local ySlider       = Tab:CreateSlider("Y", 1, 20, Settings.StackY, function(val) Settings.StackY = val end)
    local zSlider       = Tab:CreateSlider("Z", 1, 40, Settings.StackZ, function(val) Settings.StackZ = val end)
    local paddingSlider = Tab:CreateSlider("Padding", 0, 1, Settings.StackPadding, function(val)
        Settings.StackPadding = val
    end, 2)

    local StackRow = Tab:CreateRow()
    State.StackStartBtn = StackRow:CreateAction("Sort Selected Objects", "Start", function()
        if State.StackMode then
            StopStackMode()
        elseif State.IsBusy then
            State.BatchCancelled = true
        else
            StartStackMode()
        end
    end)

    -- ── Button disabled-state logic ──────────────────────────────────────
    -- Defined here (after both action elements exist) and stored in State so
    -- UpdateVisuals and mode-change helpers can call it without forward-ref issues.
    --
    -- TpBtn:
    --   Disabled  → nothing selected AND not currently executing
    --   Enabled   → something selected OR currently executing (shows "Stop" to cancel)
    --
    -- StackBtn:
    --   Disabled  → selection empty or mixed types, AND not in preview/exec
    --   Enabled   → valid same-type selection, OR in stack-preview, OR executing
    --               (in both active states it must stay clickable to cancel/stop)
    local function syncButtons()
        local stackLocked = State.IsBusy or State.StackMode
    
        if State.TpBtn then
            State.TpBtn:SetDisabled(not State.IsBusy and #State.SelectedObjects == 0)
        end
    
        if State.StackStartBtn then
            local disable
            if State.IsBusy or State.StackMode then
                disable = false
            else
                local ok = AllSelectedSameType()
                disable  = not ok
            end
            State.StackStartBtn:SetDisabled(disable)
        end
    
        -- Lock all sorting sliders while preview is active or batch is running
        xSlider:SetDisabled(stackLocked)
        -- Y slider has its own disabled state from Pyramid Mode toggle;
        -- only re-enable it if pyramid mode is also off
        if not stackLocked then
            ySlider:SetDisabled(Settings.PyramidMode)
        else
            ySlider:SetDisabled(true)
        end
        zSlider:SetDisabled(stackLocked)
        paddingSlider:SetDisabled(stackLocked)
    end

    State.SyncButtons = syncButtons
    syncButtons()   -- apply correct initial state (both disabled; nothing selected yet)

    Tab:CreateSection("Settings")
    local RotRow = Tab:CreateRow()
    RotRow:CreateKeybind("Rotate (X)", Enum.KeyCode.R, function()
        if State.StackMode then
            State.ItemRotation = State.ItemRotation * CFrame.Angles(0, math.rad(90), 0)
        end
    end)
    RotRow:CreateKeybind("Rotate (Y)", Enum.KeyCode.T, function()
        if State.StackMode then
            State.ItemRotation = State.ItemRotation * CFrame.Angles(math.rad(90), 0, 0)
        end
    end)
    Tab:CreateToggle("Pyramid Sorter", false, function(val)
        Settings.PyramidMode = val
        ySlider:SetDisabled(val)
    end):AddTooltip("Stacks objects into a pyramid shape. Y layer is unused in pyramid mode.")
    Tab:CreateToggle("Keep Selection After TP", false, function(val)
        Settings.KeepSelected = val
    end)
    Tab:CreateToggle("Return To Origin After TP", true, function(val)
        Settings.ReturnToOrigin = val
    end)
    Tab:CreateToggle("Match Plank Y Size (Group Select)", true, function(val)
    Settings.MatchPlankSize = val
    end):AddTooltip("When on, group selection only picks planks within 1 stud of the target's Y size. When off, Y size is ignored.")
    Tab:CreateSlider("Ownership Timeout (s)", 1, 6, Settings.OwnershipTimeout, function(val)
        Settings.OwnershipTimeout = val
    end):AddTooltip("Max amount of seconds to attempt obtaining ownership of the object.")

    table.insert(State.Connections, UIS.InputBegan:Connect(function(input, processed)
        if processed then return end
                    
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        if State.IsBusy then return end

        if State.StackMode then
            local excludeList = {}
            if Player.Character then table.insert(excludeList, Player.Character) end
            for _, preview in ipairs(State.StackPreviewParts) do
                for _, part in ipairs(preview:GetDescendants()) do
                    if part:IsA("BasePart") then table.insert(excludeList, part) end
                end
            end
            local rayParams = RaycastParams.new()
            rayParams.FilterType                 = Enum.RaycastFilterType.Exclude
            rayParams.FilterDescendantsInstances = excludeList
            local unitRay = Camera:ScreenPointToRay(Mouse.X, Mouse.Y)
            local result  = workspace:Raycast(unitRay.Origin, unitRay.Direction * 500, rayParams)
            local hitPos  = result and result.Position or (unitRay.Origin + unitRay.Direction * 40)
            task.spawn(PerformStackExecute, hitPos)

        elseif State.LassoMode then
            State.LassoDragging = true
            State.LassoStartPos = UIS:GetMouseLocation()
            if State.LassoFrame then State.LassoFrame.Size = UDim2.fromOffset(0, 0) State.LassoFrame.Visible = false end

        elseif State.GroupSelectMode then
            PerformGroupSelect()

        elseif State.ClickSelectMode then
            PerformSingleSelect()
        end
    end))

    table.insert(State.Connections, UIS.InputChanged:Connect(function(input)
        if State.LassoDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            UpdateLassoFrame(UIS:GetMouseLocation())
        end
    end))

    table.insert(State.Connections, UIS.InputEnded:Connect(function(input)
        if State.LassoDragging and input.UserInputType == Enum.UserInputType.MouseButton1 then
            State.LassoDragging = false
            if State.LassoFrame then State.LassoFrame.Visible = false end
            SelectObjectsInLassoRect(State.LassoStartPos, UIS:GetMouseLocation())
            State.LassoStartPos = nil
        end
    end))

    UpdateVisuals()
end

function LooseObjectTeleport.Unload()
    StopStackMode(true)
    for _, conn in ipairs(State.Connections) do conn:Disconnect() end
    for _, v in pairs(State.SelectionBoxes) do v:Destroy() end
    if State.LassoGui then State.LassoGui:Destroy() end
end

return LooseObjectTeleport
]=], "LooseObjectTeleport"))() end
__modules["Vehicle"] = function() return assert(loadstring([[local VehicleModule = {}

local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player            = Players.LocalPlayer

local selectedPadRoot  = nil
local selectedPadEvent = nil
local isAutoRolling    = false
local targetColorCode  = 1032

local customSettings = {
    MaxSpeed      = 0,
    SteerAngle    = 0,
    SteerVelocity = 0,
}

local vehicleDefaults  = {}
local trueDefaults     = {}
local cachedConfig     = nil
local cachedVehicle    = nil

local VehicleColors = {
    { Name = "Orange-Brown",           Color = Color3.fromRGB(143, 76, 42),  Code = 345 },
    { Name = "Black",         Color = Color3.fromRGB(17, 17, 17),   Code = 1003 },
    { Name = "Muted Red",           Color = Color3.fromRGB(123, 46, 47),  Code = 154 },
    { Name = "Cool Gray",   Color = Color3.fromRGB(156, 163, 168), Code = 131 },
    { Name = "Chocolate Brown",        Color = Color3.fromRGB(98, 71, 50),   Code = 25  },
    { Name = "Slate Gray",    Color = Color3.fromRGB(87, 88, 87),   Code = 148 },
    { Name = "Dusty Rose",        Color = Color3.fromRGB(149, 121, 119), Code = 153 },
    { Name = "Earthy Gray",          Color = Color3.fromRGB(109, 110, 108), Code = 27 },
    { Name = "Pale Mint",         Color = Color3.fromRGB(120, 144, 130), Code = 151 },
    { Name = "Olive",         Color = Color3.fromRGB(130, 138, 93),  Code = 200 },
    { Name = "Sage Green",           Color = Color3.fromRGB(112, 149, 120), Code = 210 },
    { Name = "Beige",         Color = Color3.fromRGB(215, 197, 154), Code = 5 },
    { Name = "Olive-Brown",          Color = Color3.fromRGB(104, 92, 67),  Code = 108 },
    { Name = "Hot Pink",      Color = Color3.fromRGB(255, 0, 191),   Code = 1032 },
}

local ColorCodeMap = {}
for _, entry in ipairs(VehicleColors) do
    ColorCodeMap[entry.Name] = entry.Code
end


local function GetVehicleConfig()
    local char = player.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    local seat = hum and hum.SeatPart
    if not seat then return nil, nil end

    local vehicle = seat
    while vehicle.Parent and vehicle.Parent ~= workspace and vehicle.Parent.Name ~= "PlayerModels" do
        vehicle = vehicle.Parent
    end

    if vehicle and vehicle:IsA("Model") then
        local config = vehicle:FindFirstChild("Configuration", true)
        if config and config:FindFirstChild("MaxSpeed") then
            return config, vehicle
        end
    end

    return nil, nil
end

local function ReadConfigValue(config, name)
    if not config then return nil end
    local setting = config:FindFirstChild(name)
    if setting and setting:IsA("ValueBase") then
        return setting.Value
    end
    return nil
end

local function WriteConfigValues(config, values)
    if not config or not values then return end
    for name, value in pairs(values) do
        local setting = config:FindFirstChild(name)
        if setting and setting:IsA("ValueBase") then
            setting.Value = value
        end
    end
end

local function ApplyCustomization(name, value)
    customSettings[name] = value
    if cachedConfig then
        local setting = cachedConfig:FindFirstChild(name)
        if setting and setting:IsA("ValueBase") then
            setting.Value = value
        end
    end
end

local function SafeUpdateSlider(slider, value)
    if not slider then return end
    pcall(function()
        if type(slider.SetValue) == "function" then
            slider:SetValue(value)
        elseif type(slider.Set) == "function" then
            slider:Set(value)
        end
    end)
end

local function FlipVehicle()
    local character = player.Character
    local humanoid  = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.SeatPart then
        local veh   = humanoid.SeatPart.Parent
        local tPart = veh:IsA("Model") and (veh.PrimaryPart or humanoid.SeatPart) or humanoid.SeatPart
        tPart.CFrame = tPart.CFrame * CFrame.Angles(0, 0, math.pi) + Vector3.new(0, 2, 0)
    end
end

local function InteractWithPad()
    local Interaction = ReplicatedStorage:FindFirstChild("Interaction")
    local RemoteProxy = Interaction and Interaction:FindFirstChild("RemoteProxy")
    if selectedPadEvent and RemoteProxy then
        RemoteProxy:FireServer(selectedPadEvent)
    end
end

function VehicleModule.Init(Tab, Library)

    Tab:CreateSection("Vehicle Modifications")

    local SpeedSlider = Tab:CreateSlider("Max Speed", 0.1, 10.0, 0.1, function(val)
        ApplyCustomization("MaxSpeed", val)
    end, 2)
    SpeedSlider:SetDisabled(true)

    local SteerAngleSlider = Tab:CreateSlider("Steer Angle", 0.1, 2.0, 0.1, function(val)
        ApplyCustomization("SteerAngle", val)
    end, 2)
    SteerAngleSlider:SetDisabled(true)

    local SteerVelocitySlider = Tab:CreateSlider("Steer Velocity", 0.01, 0.03, 0.01, function(val)
        ApplyCustomization("SteerVelocity", val)
    end, 3)
    SteerVelocitySlider:SetDisabled(true)

    local FlipButton = Tab:CreateAction("Flip Vehicle", "No Vehicle", function()
        FlipVehicle()
    end)
    FlipButton:SetDisabled(true)

    local ResetButton = Tab:CreateAction("Reset Vehicle Modifications", "Reset", function()
        local defaults = (cachedVehicle and trueDefaults[cachedVehicle]) or vehicleDefaults
        if not defaults or not defaults.MaxSpeed then return end
        WriteConfigValues(cachedConfig, defaults)
        customSettings.MaxSpeed      = 0
        customSettings.SteerAngle    = 0
        customSettings.SteerVelocity = 0
        SafeUpdateSlider(SpeedSlider,         math.clamp(defaults.MaxSpeed,      0.1, 10.0))
        SafeUpdateSlider(SteerAngleSlider,    math.clamp(defaults.SteerAngle,    0.1, 2.0))
        SafeUpdateSlider(SteerVelocitySlider, math.clamp(defaults.SteerVelocity, 0.01, 0.03))
    end)
    ResetButton:SetDisabled(true)

    local resetOnExit = true
    Tab:CreateToggle("Reset Vehicle Modifications On Exit", true, function(state)
        resetOnExit = state
    end)

    Tab:CreateSection("Vehicle Pad Spawner")

    Tab:CreateDropdown("Target Color", VehicleColors, VehicleColors[14], function(color, name)
        local code = ColorCodeMap[name]
        if code then
            targetColorCode = code
            if Library then
                Library:Notify("Auto-Roll", "Target set to " .. name .. " (Code: " .. code .. ")", 3)
            end
        end
    end)

    local SpawnButton
    local AutoToggle
    local SelectButton
    SelectButton = Tab:CreateAction("Select Vehicle Pad", "Select", function()
        SelectButton:SetText("Click Pad!")
        local conn
        conn = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
            conn:Disconnect()

            local mp     = UserInputService:GetMouseLocation()
            local ray    = workspace.CurrentCamera:ViewportPointToRay(mp.X, mp.Y)
            local result = workspace:Raycast(ray.Origin, ray.Direction * 1000)

            if result and result.Instance then
                local current = result.Instance
                for _ = 1, 10 do
                    if not current then break end
                    local ev = current:FindFirstChild("ButtonRemote_SpawnButton")
                    if ev then
                        selectedPadRoot  = current
                        selectedPadEvent = ev
                        SelectButton:SetText(current.Name)
                        SpawnButton:SetDisabled(false)
                        AutoToggle:SetDisabled(false)
                        return
                    end
                    current = current.Parent
                end
                SelectButton:SetText("Not Found")
            else
                SelectButton:SetText("Missed")
            end
        end)
    end)

    SpawnButton = Tab:CreateAction("Respawn Vehicle", "Respawn", function()
        InteractWithPad()
    end)
    SpawnButton:SetDisabled(true)

    local SPAWN_INTERVAL = 0.5
    local POLL_RATE      = 0.02

    local function SpawnAndGetColor()
        local watchFolder = workspace:FindFirstChild("PlayerModels") or workspace
        local existing = {}
        for _, m in ipairs(watchFolder:GetChildren()) do existing[m] = true end

        local done, result = false, nil

        local conn = watchFolder.ChildAdded:Connect(function(model)
            if done or existing[model] or not model:IsA("Model") then return end
            local settings = model:WaitForChild("Settings", 0.5)
            if not settings then return end
            local colorVal = settings:WaitForChild("Color", 0.5)
            if not colorVal then return end
            local deadline = tick() + 0.4
            while colorVal.Value == 0 and tick() < deadline do task.wait(POLL_RATE) end
            if colorVal.Value ~= 0 and not done then
                done   = true
                result = colorVal.Value
            end
        end)

        InteractWithPad()

        local deadline = tick() + SPAWN_INTERVAL
        while not done and tick() < deadline and isAutoRolling do
            task.wait(POLL_RATE)
        end

        conn:Disconnect()
        return result
    end

    AutoToggle = Tab:CreateToggle("Auto-Roll Color", false, function(state)
        if not selectedPadEvent then
            AutoToggle:SetState(false)
            return
        end
        isAutoRolling = state

        if isAutoRolling then
            task.spawn(function()
                while isAutoRolling and selectedPadEvent do
                    local color = SpawnAndGetColor()
                    if color == targetColorCode then
                        isAutoRolling = false
                        AutoToggle:SetState(false)
                        if Library then
                            Library:Notify("Auto-Roll", "Found target color: " .. tostring(targetColorCode), 5)
                        end
                        break
                    end
                end
            end)
        end
    end)
    AutoToggle:SetDisabled(true)

    task.spawn(function()
        local lastSeat = nil

        while task.wait(0.5) do
            local char        = player.Character
            local hum         = char and char:FindFirstChildOfClass("Humanoid")
            local currentSeat = hum and hum.SeatPart

            if currentSeat ~= lastSeat then
                lastSeat = currentSeat

                if currentSeat then
                    -- PLAYER ENTERED VEHICLE
                    FlipButton:SetDisabled(false)
                    FlipButton:SetText("Flip 180°")
                    ResetButton:SetDisabled(false)
                    SpeedSlider:SetDisabled(false)
                    SteerAngleSlider:SetDisabled(false)
                    SteerVelocitySlider:SetDisabled(false)

                    cachedConfig  = nil
                    cachedVehicle = nil

                    for _ = 1, 6 do
                        local config, vehicle = GetVehicleConfig()
                        if config and vehicle then
                            cachedConfig  = config
                            cachedVehicle = vehicle
                            break
                        end
                        task.wait(0.5)
                    end

                    if cachedConfig and cachedVehicle then
                        if not trueDefaults[cachedVehicle] then
                            trueDefaults[cachedVehicle] = {
                                MaxSpeed      = ReadConfigValue(cachedConfig, "MaxSpeed"),
                                SteerAngle    = ReadConfigValue(cachedConfig, "SteerAngle"),
                                SteerVelocity = ReadConfigValue(cachedConfig, "SteerVelocity"),
                            }
                        end

                        vehicleDefaults = {
                            MaxSpeed      = ReadConfigValue(cachedConfig, "MaxSpeed"),
                            SteerAngle    = ReadConfigValue(cachedConfig, "SteerAngle"),
                            SteerVelocity = ReadConfigValue(cachedConfig, "SteerVelocity"),
                        }

                        SafeUpdateSlider(SpeedSlider,         math.clamp(vehicleDefaults.MaxSpeed,      0.1, 10.0))
                        SafeUpdateSlider(SteerAngleSlider,    math.clamp(vehicleDefaults.SteerAngle,    0.1, 2.0))
                        SafeUpdateSlider(SteerVelocitySlider, math.clamp(vehicleDefaults.SteerVelocity, 0.01, 0.05))

                        if customSettings.MaxSpeed      > 0 then ApplyCustomization("MaxSpeed",      customSettings.MaxSpeed)      end
                        if customSettings.SteerAngle    > 0 then ApplyCustomization("SteerAngle",    customSettings.SteerAngle)    end
                        if customSettings.SteerVelocity > 0 then ApplyCustomization("SteerVelocity", customSettings.SteerVelocity) end
                    end
                else
                    if resetOnExit and cachedConfig and cachedVehicle and trueDefaults[cachedVehicle] then
                        WriteConfigValues(cachedConfig, trueDefaults[cachedVehicle])
                    end

                    cachedConfig         = nil
                    cachedVehicle        = nil
                    vehicleDefaults      = {}
                    customSettings.MaxSpeed      = 0
                    customSettings.SteerAngle    = 0
                    customSettings.SteerVelocity = 0

                    FlipButton:SetDisabled(true)
                    FlipButton:SetText("No Vehicle")
                    ResetButton:SetDisabled(true)
                    SpeedSlider:SetDisabled(true)
                    SafeUpdateSlider(SpeedSlider, 0.1)
                    SteerAngleSlider:SetDisabled(true)
                    SafeUpdateSlider(SteerAngleSlider, 0.1)
                    SteerVelocitySlider:SetDisabled(true)
                    SafeUpdateSlider(SteerVelocitySlider, 0.01)
                end
            end
        end
    end)

end

return VehicleModule
]], "Vehicle"))() end
__modules["Plot"] = function() return assert(loadstring([[-- Plot.lua
local Plot = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players           = game:GetService("Players")
local Workspace         = game:GetService("Workspace")

function Plot.Init(Tab, Library)
    if not Tab then return warn("Plot Module: Tab was nil!") end

    local LocalPlayer        = Players.LocalPlayer
    local loadSaveRequests   = ReplicatedStorage:FindFirstChild("LoadSaveRequests")
    local propertyPurchasing = ReplicatedStorage:FindFirstChild("PropertyPurchasing")
    local interaction        = ReplicatedStorage:FindFirstChild("Interaction")
    local destroyStructure   = interaction and interaction:FindFirstChild("DestroyStructure")

    -- ==========================================
    -- SAVE & LOAD MANAGEMENT
    -- ==========================================
    Tab:CreateSection("Management")
    local selectedSlotToLoad = 1
    if Tab.CreateDropdown then
        Tab:CreateDropdown("Select Slot to Load", {"1","2","3","4","5","6"}, "1", function(value)
            selectedSlotToLoad = tonumber(value)
        end)
    end

    Tab:CreateAction("Load Selected Slot", "Load", function()
        local RequestLoadRemote = loadSaveRequests and loadSaveRequests:FindFirstChild("RequestLoad")
        if RequestLoadRemote then
            RequestLoadRemote:InvokeServer(selectedSlotToLoad)
            if Library and Library.Notify then
                Library:Notify("SUCCESS", "Loading slot " .. selectedSlotToLoad, 5)
            end
        end
    end)

    local saveCooldownActive = false
    local saveBtn

    saveBtn = Tab:CreateAction("Save Slot", "Save", function()
        if saveCooldownActive then return end

        local currentSlot = LocalPlayer:FindFirstChild("CurrentSaveSlot")
        if not currentSlot or currentSlot.Value <= 0 then
            if Library and Library.Notify then
                Library:Notify("ERROR", "No active slot detected. Load a slot first!", 5)
            end
            return
        end

        local RequestSaveRemote = loadSaveRequests and loadSaveRequests:FindFirstChild("RequestSave")
        if RequestSaveRemote then
            if Library and Library.Notify then
                Library:Notify("SAVING", "Forcing save for slot " .. currentSlot.Value .. "...", 3)
            end

            local success, result = pcall(function()
                return RequestSaveRemote:InvokeServer(currentSlot.Value)
            end)

            if success then
                if Library and Library.Notify then
                    Library:Notify("SUCCESS", "Save request sent!", 5)
                end
                saveCooldownActive = true
                saveBtn:SetDisabled(true)
                task.spawn(function()
                    for i = 60, 1, -1 do
                        saveBtn:SetText("" .. i .. "s")
                        task.wait(1)
                    end
                    saveBtn:SetText("Save Slot")
                    saveBtn:SetDisabled(false)
                    saveCooldownActive = false
                end)
            else
                if Library and Library.Notify then
                    Library:Notify("ERROR", "Save failed: " .. tostring(result), 5)
                end
            end
        else
            if Library and Library.Notify then
                Library:Notify("ERROR", "Save remote not found.", 5)
            end
        end
    end)

    local claimBtn
    local expandBtn
    local propertiesFolder = Workspace:FindFirstChild("Properties")
    local playerModels     = Workspace:FindFirstChild("PlayerModels")

    -- ==========================================
    -- SOLD SIGN FINDER
    -- ==========================================
    local function FindOwnedSoldSign()
        if not playerModels then return nil end
        for _, model in ipairs(playerModels:GetChildren()) do
            if not model:IsA("Model") then continue end
            local owner    = model:FindFirstChild("Owner")
            local ownerStr = owner and owner:FindFirstChild("OwnerString")
            if not ownerStr or ownerStr.Value ~= LocalPlayer.Name then continue end
            local settings = model:FindFirstChild("Settings")
            local soldFlag = settings and settings:FindFirstChild("PropertySoldSign")
            if soldFlag and soldFlag.Value == true then
                return model
            end
        end
        return nil
    end

    -- ==========================================
    -- PLOT HELPERS & COLOR MANAGEMENT
    -- ==========================================
    local DEFAULT_PLOT_COLOR = Color3.fromRGB(126, 104, 63)
    local activePlotColor    = nil -- Stores the chosen color so we can apply it to new tiles

    -- Returns the player's owned plot model, or nil.
    local function GetPlayerPlot()
        if not propertiesFolder then return nil end
        for _, plot in ipairs(propertiesFolder:GetChildren()) do
            local owner = plot:FindFirstChild("Owner")
            if owner and owner.Value == LocalPlayer then
                return plot
            end
        end
        return nil
    end

    -- Returns the current Color3 of the player's plot squares.
    -- Checks OriginSquare first, then any BasePart child, then falls back
    -- to the default LT2 dirt colour.
    local function GetCurrentPlotColor()
        if activePlotColor then return activePlotColor end -- Return the custom color if set
        
        local plot = GetPlayerPlot()
        if not plot then return DEFAULT_PLOT_COLOR end
        -- Prefer OriginSquare
        local origin = plot:FindFirstChild("OriginSquare")
        if origin and origin:IsA("BasePart") then return origin.Color end
        -- Fall back to the first Square tile
        for _, child in ipairs(plot:GetChildren()) do
            if child:IsA("BasePart") then return child.Color end
        end
        return DEFAULT_PLOT_COLOR
    end

    -- Sets Color on every BasePart in EVERY plot (all players).
    -- Covers OriginSquare + every Square expansion tile across all properties.
    local function SetPlotColor(color)
        activePlotColor = color -- Save state so future tiles get this color
        if not propertiesFolder then return end
        for _, plot in ipairs(propertiesFolder:GetChildren()) do
            for _, child in ipairs(plot:GetChildren()) do
                if child:IsA("BasePart") then
                    child.Color = color
                end
            end
        end
    end

    -- ==========================================
    -- BUTTON STATE UPDATERS
    -- ==========================================
    local function UpdateLandButtons()
        if not propertiesFolder then return end
        local hasLand        = false
        local landPieceCount = 0
        for _, plot in pairs(propertiesFolder:GetChildren()) do
            local owner = plot:FindFirstChild("Owner")
            if owner and owner.Value == LocalPlayer then
                hasLand = true
                for _, child in pairs(plot:GetChildren()) do
                    if child:IsA("BasePart") then landPieceCount += 1 end
                end
                break
            end
        end
        if claimBtn  then claimBtn:SetDisabled(hasLand) end
        if expandBtn then expandBtn:SetDisabled(not hasLand or landPieceCount >= 25) end
    end

    -- ==========================================
    -- DEBOUNCED LAND SCHEDULER
    -- ==========================================
    local landUpdatePending = false
    local function ScheduleLandUpdate()
        if landUpdatePending then return end
        landUpdatePending = true
        task.delay(0.5, function()
            landUpdatePending = false
            UpdateLandButtons()
        end)
    end

    -- ==========================================
    -- LAND ACTIONS
    -- ==========================================
    Tab:CreateSection("Property Management")

    claimBtn = Tab:CreateAction("Claim Free Land", "Claim", function()
        if not propertiesFolder or not propertyPurchasing then return end
        local claimRemote = propertyPurchasing:FindFirstChild("ClientPurchasedProperty")
        for _, plot in pairs(propertiesFolder:GetChildren()) do
            local owner  = plot:FindFirstChild("Owner")
            local origin = plot:FindFirstChild("OriginSquare")
            if owner and origin and owner.Value == nil then
                claimRemote:FireServer(plot, origin.OriginCFrame.Value.p + Vector3.new(0, 3, 0))
                if Library and Library.Notify then Library:Notify("PROPERTY", "Claimed!", 3) end
                task.wait(0.5)
                if LocalPlayer.Character then LocalPlayer.Character:MoveTo(origin.Position) end
                break
            end
        end
    end)

    expandBtn = Tab:CreateAction("Max Land (Full Expand)", "Expand", function()
        if not propertiesFolder or not propertyPurchasing then return end
        local expandRemote = propertyPurchasing:FindFirstChild("ClientExpandedProperty")
        local playerPlot   = nil
        for _, plot in pairs(propertiesFolder:GetChildren()) do
            if plot.Owner.Value == LocalPlayer then playerPlot = plot break end
        end
        if playerPlot and playerPlot:FindFirstChild("OriginSquare") then
            local spos = playerPlot.OriginSquare.Position
            local offsets = {
                {0,40},{0,-40},{40,0},{-40,0},
                {40,40},{40,-40},{-40,40},{-40,-40},
                {80,0},{-80,0},{0,80},{0,-80},
                {80,80},{80,-80},{-80,80},{-80,-80},
                {40,80},{-40,80},{80,40},{80,-40},
                {-80,40},{-80,-40},{40,-80},{-40,-80}
            }
            for _, offset in ipairs(offsets) do
                expandRemote:FireServer(playerPlot, CFrame.new(spos.X + offset[1], spos.Y, spos.Z + offset[2]))
                task.wait(0.05)
            end
            if Library and Library.Notify then Library:Notify("SUCCESS", "Plot fully expanded!", 3) end
        end
    end)

    -- ==========================================
    -- PLOT COLOR PICKER
    -- ==========================================
    local colorDebounceThread = nil
    Tab:CreateColorPicker("Plot Color", GetCurrentPlotColor(), function(color)
        if colorDebounceThread then task.cancel(colorDebounceThread) end
        colorDebounceThread = task.delay(0.15, function()
            colorDebounceThread = nil
            SetPlotColor(color)
        end)
    end)

    -- Button always enabled. Checks for the sign on click.
    Tab:CreateAction("Delete 'Sold To' Sign", "Delete", function()
        if not destroyStructure then
            if Library and Library.Notify then Library:Notify("ERROR", "DestroyStructure remote not found.", 3) end
            return
        end
        local sign = FindOwnedSoldSign()
        if not sign then
            if Library and Library.Notify then Library:Notify("ERROR", "No sold property sign found.", 3) end
            return
        end
        destroyStructure:FireServer(sign)
        if Library and Library.Notify then Library:Notify("SUCCESS", "Sign deleted!", 3) end
    end)

    Tab:CreateAction("Wipe Plot", "Wipe", function()
        local destroyRemote = interaction and interaction:FindFirstChild("DestroyStructure")
        if not playerModels or not destroyRemote then
            if Library and Library.Notify then Library:Notify("ERROR", "Wipe system unavailable", 3) end
            return
        end
        local toDestroy = {}
        for _, model in pairs(playerModels:GetChildren()) do
            local owner = model:FindFirstChild("Owner")
            if owner and owner.Value == LocalPlayer then
                local main = model:FindFirstChild("Main") or model:FindFirstChildWhichIsA("BasePart")
                if main then table.insert(toDestroy, { model = model, main = main }) end
            end
        end
        if #toDestroy == 0 then
            if Library and Library.Notify then Library:Notify("WIPE", "Nothing found to clear.", 3) end
            return
        end
        if Library and Library.Notify then
            Library:Notify("WIPE", "Clearing " .. #toDestroy .. " object(s)...", math.ceil(#toDestroy * 0.1))
        end
        local count = 0
        for _, entry in ipairs(toDestroy) do
            if not entry.model.Parent then continue end
            local timeout = 5
            local elapsed = 0
            while entry.model.Parent ~= nil and elapsed < timeout do
                pcall(destroyRemote.FireServer, destroyRemote, entry.model)
                task.wait(0.05)
                elapsed += 0.05
            end
            if entry.model.Parent == nil then
                count += 1
            else
                warn(("[Wipe] Timed out on '%s'."):format(entry.model.Name))
            end
        end
        if Library and Library.Notify then Library:Notify("SUCCESS", "Wiped " .. count .. " object(s).", 4) end
    end, true)

    -- ==========================================
    -- LAND EVENT LISTENERS
    -- ==========================================
    local function WatchPlotOwner(plot)
        local owner = plot:FindFirstChild("Owner")
        if owner and owner:IsA("ObjectValue") then
            owner.Changed:Connect(function()
                ScheduleLandUpdate()
            end)
        end
    end

    if propertiesFolder then
        -- THIS FIXES NEW TILES: Listen for any new parts entering the Properties folder
        propertiesFolder.DescendantAdded:Connect(function(descendant)
            if activePlotColor and descendant:IsA("BasePart") then
                -- Color it automatically on the next frame so it has time to finish rendering
                task.defer(function()
                    descendant.Color = activePlotColor
                end)
            end
        end)

        for _, plot in ipairs(propertiesFolder:GetChildren()) do
            WatchPlotOwner(plot)
        end

        propertiesFolder.ChildAdded:Connect(function(plot)
            WatchPlotOwner(plot)
            ScheduleLandUpdate()
        end)

        propertiesFolder.ChildRemoved:Connect(function()
            ScheduleLandUpdate()
        end)

        UpdateLandButtons()
    end
end

return Plot]], "Plot"))() end
__modules["Tree"] = function() return assert(loadstring([[local TreeModule = {}

-- ==========================================
--             SYSTEM SETTINGS
-- ==========================================
local Settings = {
    SyncDelay       = 0.1,
    ReadyDelay      = 0.1,

    -- [ Cut Settings ]
    FiresPerSection = 100,
    FireDelay       = 0.01,
    SweepDelay      = 0.1,

    -- [ LOT Settings ]
    LogDropDistance = 6,

    -- [ Sell Location ]
    SellPosition    = Vector3.new(315, 0, 88),

    -- [ Death Handling ]
    RespawnResumeDelay = 1,   -- seconds to wait after respawn before resuming
}

-- ==========================================
--             CORE SERVICES & VARS
-- ==========================================
local Players           = game:GetService("Players")
local Workspace         = game:GetService("Workspace")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local isChopping          = false
local preChopCFrame       = nil
local preChopCameraCFrame = nil
local preChopLogModels    = {}

-- ==========================================
--   SILENCE TROLL SOUNDS
-- ==========================================
local function SilenceRegionAlternates()
    local function killAlternate(parent)
        for _, child in ipairs(parent:GetChildren()) do
            if child.Name == "Alternate" and child:IsA("Sound") then
                child.Volume = 0
                pcall(function() child:Stop() end)
            end
        end
        parent.ChildAdded:Connect(function(child)
            if child.Name == "Alternate" and child:IsA("Sound") then
                child.Volume = 0
                pcall(function() child:Stop() end)
            end
        end)
    end

    local function scanClientSounds()
        local pg     = player:WaitForChild("PlayerGui", 10)
        local sounds = pg and pg:FindFirstChild("ClientSounds")
        if not sounds then return end

        local function processRegion(folder)
            killAlternate(folder)
        end

        local function scanAll()
            for _, child in ipairs(sounds:GetChildren()) do
                if child.Name == "Region_Main" or child.Name == "Region_Mountain" then
                    processRegion(child)
                end
            end
        end

        scanAll()

        sounds.ChildAdded:Connect(function(child)
            if child.Name == "Region_Main" or child.Name == "Region_Mountain" then
                processRegion(child)
            end
        end)
    end

    task.spawn(scanClientSounds)
end

SilenceRegionAlternates()

-- ==========================================
--             UTILITY
-- ==========================================

local function ReadAxeName(tool)
    if not tool then return nil end
    local tipChild = tool:FindFirstChild("ToolTip")
    return (tipChild and tipChild:IsA("StringValue")) and tipChild.Value or tool.ToolTip
end

local function GetBackpackAxe(treeClass)
    local candidates = {}

    local function TryAdd(tool)
        if not tool:IsA("Tool") then return end
        if tool.Name == "BlueprintTool" then return end

        local axeName = ReadAxeName(tool)
        if not axeName then return end

        local score = treeClass
            and _G.LT2Axes.GetDamage(axeName, treeClass)
            or (1 / (_G.LT2Axes.Rank[axeName] or 2^53))

        table.insert(candidates, { tool = tool, axeName = axeName, score = score })
    end

    local char = player.Character
    if char then
        local equipped = char:FindFirstChildOfClass("Tool")
        if equipped then TryAdd(equipped) end
    end
    for _, tool in ipairs(player.Backpack:GetChildren()) do
        TryAdd(tool)
    end

    if #candidates == 0 then return nil, nil end

    table.sort(candidates, function(a, b) return a.score > b.score end)

    local best = candidates[1]
    return best.tool, best.axeName
end

local function FindPriorityTree(treeClass)
    local bestModel   = nil
    local maxSections = -1
    for _, folder in ipairs(Workspace:GetChildren()) do
        if folder.Name:lower():match("treeregion") then
            for _, model in ipairs(folder:GetChildren()) do
                if model:IsA("Model")
                and model:FindFirstChild("TreeClass")
                and model.TreeClass.Value == treeClass then
                    local count = 0
                    for _, part in ipairs(model:GetChildren()) do
                        if part.Name == "WoodSection" then count += 1 end
                    end
                    if treeClass == "Generic" and count < 12 then continue end
                    if count > maxSections then
                        maxSections = count
                        bestModel   = model
                    end
                end
            end
        end
    end
    return bestModel
end

local function GetSectionsBottomFirst(treeModel)
    local sections = {}
    for _, part in ipairs(treeModel:GetChildren()) do
        if part.Name == "WoodSection" then
            table.insert(sections, part)
        end
    end
    table.sort(sections, function(a, b)
        return a.Position.Y < b.Position.Y
    end)
    return sections
end

local function SnapshotLogModels()
    preChopLogModels = {}
    local logModels = Workspace:FindFirstChild("LogModels")
    if not logModels then return end
    for _, model in ipairs(logModels:GetChildren()) do
        preChopLogModels[model] = true
    end
end

-- ==========================================
--   OWNERSHIP CHECK
-- ==========================================
local function IsOwnedByLocalPlayer(model)
    local ownerObj = model:FindFirstChild("Owner")
    if ownerObj then
        if ownerObj:IsA("ObjectValue") and ownerObj.Value == player then return true end
        if ownerObj:IsA("StringValue") and ownerObj.Value == player.Name then return true end
    end
    local ownerStr = model:FindFirstChild("OwnerString")
    if ownerStr and ownerStr:IsA("StringValue") and ownerStr.Value == player.Name then
        return true
    end
    return false
end

local function CountWoodSections(model)
    local count = 0
    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("BasePart") and desc.Name == "WoodSection" then
            count += 1
        end
    end
    return count
end

local function CountTreeSections(model)
    local count = 0
    for _, part in ipairs(model:GetChildren()) do
        if part.Name == "WoodSection" then count += 1 end
    end
    return count
end

local function ScanForTreeTypes()
    local found, seen = {}, {}
    for _, folder in ipairs(Workspace:GetChildren()) do
        if folder.Name:lower():match("treeregion") then
            for _, model in ipairs(folder:GetChildren()) do
                if model:IsA("Model") then
                    local tc = model:FindFirstChild("TreeClass")
                    if tc and tc:IsA("StringValue") and not seen[tc.Value] then
                        if CountTreeSections(model) > 1 then
                            seen[tc.Value] = true
                            table.insert(found, tc.Value)
                        end
                    end
                end
            end
        end
    end
    return #found > 0 and found or {"None Found"}
end

local function CollectNewStumps(treeClass)
    local results   = {}
    local logModels = Workspace:FindFirstChild("LogModels")
    if not logModels then return results end
    for _, model in ipairs(logModels:GetChildren()) do
        if preChopLogModels[model] then continue end
        if model:IsA("Model") then
            local tc = model:FindFirstChild("TreeClass")
            if tc and tc.Value == treeClass then
                local iw = model:FindFirstChild("InnerWood")
                if iw and iw:IsA("BasePart") then
                    table.insert(results, iw)
                end
            end
        end
    end
    if #results == 0 then
        warn("[TreeModule] No InnerWood found after chop for TreeClass:", treeClass)
    end
    return results
end

local function CollectAllOwnedStumps()
    local results   = {}
    local logModels = Workspace:FindFirstChild("LogModels")
    if not logModels then return results end
    for _, model in ipairs(logModels:GetChildren()) do
        if not model:IsA("Model") then continue end
        if not IsOwnedByLocalPlayer(model) then continue end
        local iw = model:FindFirstChild("InnerWood")
        if iw and iw:IsA("BasePart") then
            table.insert(results, iw)
        end
    end
    if #results == 0 then
        warn("[TreeModule] No owned InnerWood found.")
    end
    return results
end

local function CollectSingleSectionStumps()
    local results   = {}
    local logModels = Workspace:FindFirstChild("LogModels")
    if not logModels then return results end
    for _, model in ipairs(logModels:GetChildren()) do
        if not model:IsA("Model") then continue end
        if not IsOwnedByLocalPlayer(model) then continue end
        if CountWoodSections(model) ~= 1 then continue end
        local iw = model:FindFirstChild("InnerWood")
        if iw and iw:IsA("BasePart") then
            table.insert(results, iw)
        end
    end
    if #results == 0 then
        warn("[TreeModule] No single-section logs ready to sell. Chop logs into sections first.")
    end
    return results
end

local function SellLogModelSectionBySection(model, LOT, sellPos, sectionIndex)
    sectionIndex = sectionIndex or 0

    local sections = {}
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") and part.Name == "WoodSection" then
            table.insert(sections, part)
        end
    end
    table.sort(sections, function(a, b) return a.Position.Y < b.Position.Y end)

    if #sections == 0 then
        warn("[TreeModule] No WoodSections found in model:", model.Name)
        return sectionIndex
    end

    for _, section in ipairs(sections) do
        if not section or not section.Parent then continue end

        for _, desc in ipairs(model:GetDescendants()) do
            if desc:IsA("Weld") or desc:IsA("WeldConstraint") or desc:IsA("ManualWeld") then
                if desc.Part0 == section or desc.Part1 == section then
                    pcall(function() desc:Destroy() end)
                end
            end
        end

        task.wait(0.1)

        sectionIndex += 1
        local cf = CFrame.new(sellPos.X + ((sectionIndex - 1) * 3), sellPos.Y, sellPos.Z)
        if LOT.IsBusy() then repeat task.wait(0.05) until not LOT.IsBusy() end
        LOT.TeleportObjectTo(section, cf)
        repeat task.wait(0.05) until not LOT.IsBusy()
    end

    return sectionIndex
end

local function SellAllOwnedTreesSectionBySection(LOT, sellPos, onComplete)
    task.spawn(function()
        local logModels = Workspace:FindFirstChild("LogModels")
        if not logModels then
            if onComplete then onComplete() end
            return
        end

        local ownedModels = {}
        for _, model in ipairs(logModels:GetChildren()) do
            if model:IsA("Model") and IsOwnedByLocalPlayer(model) then
                table.insert(ownedModels, model)
            end
        end

        if #ownedModels == 0 then
            warn("[TreeModule] No owned log models found.")
            if onComplete then onComplete() end
            return
        end

        print(("[TreeModule] Selling %d log model(s) section by section."):format(#ownedModels))

        local globalIndex = 0
        for _, model in ipairs(ownedModels) do
            if not model or not model.Parent then continue end
            globalIndex = SellLogModelSectionBySection(model, LOT, sellPos, globalIndex)
        end

        if onComplete then onComplete() end
    end)
end

local function CleanupState()
    isChopping = false

    local char = player.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")

    if hrp and preChopCFrame then
        hrp.CFrame = preChopCFrame
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end

    player.CameraMode = Enum.CameraMode.Classic

    if preChopCameraCFrame then
        camera.CFrame = preChopCameraCFrame
    end
end

local function WaitForLogsToSettle(treeClass)
    local VELOCITY_THRESHOLD = 0.5
    local STABLE_DURATION    = 0.3
    local TIMEOUT            = 10
    local POLL_RATE          = 0.05

    local logModels = Workspace:FindFirstChild("LogModels")
    if not logModels then task.wait(1.5) return end

    local innerWoods = {}
    for _, model in ipairs(logModels:GetChildren()) do
        if preChopLogModels[model] then continue end
        if model:IsA("Model") then
            local tc = model:FindFirstChild("TreeClass")
            if tc and tc.Value == treeClass then
                local iw = model:FindFirstChild("InnerWood")
                if iw and iw:IsA("BasePart") then
                    table.insert(innerWoods, iw)
                end
            end
        end
    end

    if #innerWoods == 0 then task.wait(1.5) return end

    local deadline   = tick() + TIMEOUT
    local stableFrom = nil

    while tick() < deadline do
        local allStill = true
        for _, iw in ipairs(innerWoods) do
            if not iw or not iw.Parent then continue end
            if iw.AssemblyLinearVelocity.Magnitude > VELOCITY_THRESHOLD then
                allStill = false
                break
            end
        end
        if allStill then
            if not stableFrom then
                stableFrom = tick()
            elseif tick() - stableFrom >= STABLE_DURATION then
                return
            end
        else
            stableFrom = nil
        end
        task.wait(POLL_RATE)
    end
    warn("[TreeModule] WaitForLogsToSettle timed out — proceeding anyway.")
end

-- ==========================================
--   LOT BATCH HELPER
-- ==========================================
local function RunLOTBatch(LOT, stumps, goalCFBuilder, onComplete)
    if not LOT then if onComplete then onComplete() end return end
    if #stumps == 0 then
        warn("[TreeModule] RunLOTBatch: nothing to teleport.")
        if onComplete then onComplete() end
        return
    end

    task.spawn(function()
        for i, stump in ipairs(stumps) do
            if LOT.IsBusy() then
                repeat task.wait(0.1) until not LOT.IsBusy()
            end
            local goalCF = goalCFBuilder(i, stump)
            LOT.TeleportObjectTo(stump, goalCF, true)
            task.spawn(function()
                repeat task.wait(0.1) until not LOT.IsBusy()
            end)
        end
        if onComplete then onComplete() end
    end)
end

-- ==========================================
--   PLANK SELLING
-- ==========================================
local PLANK_SELL_CF = CFrame.new(315, 0, 88) * CFrame.Angles(math.rad(90), 0, 0)
local PLANK_LOCK_TIME = 1
local _sellPlanksOn = false
local _hoverOutline = nil
local _hoverPlank   = nil
local _plankConn    = nil
local _clickConn    = nil
local _isSelling    = false

local function FindOwnedPlank(part)
    if not part then return nil end
    local current = part
    while current and current ~= Workspace do
        if current.Name == "Plank" and current:IsA("Model") then
            local playerModels = Workspace:FindFirstChild("PlayerModels")
            if not playerModels then return nil end
            if current.Parent ~= playerModels then return nil end
            local owner = current:FindFirstChild("Owner")
            if not owner then return nil end
            local ownerStr = owner:FindFirstChild("OwnerString")
            if not ownerStr or not ownerStr:IsA("StringValue") then return nil end
            if ownerStr.Value ~= player.Name then return nil end
            return current
        end
        current = current.Parent
    end
    return nil
end

local function ClearHoverOutline()
    if _hoverOutline then _hoverOutline:Destroy(); _hoverOutline = nil end
    _hoverPlank = nil
end

local function ApplyHoverOutline(model)
    if _hoverPlank == model then return end
    ClearHoverOutline()
    _hoverPlank                       = model
    _hoverOutline                     = Instance.new("SelectionBox")
    _hoverOutline.Adornee             = model
    _hoverOutline.Color3              = Color3.fromRGB(74, 120, 255)
    _hoverOutline.LineThickness       = 0.08
    _hoverOutline.SurfaceColor3       = Color3.fromRGB(74, 120, 255)
    _hoverOutline.SurfaceTransparency = 0.65
    _hoverOutline.Parent              = Workspace
end

local function StopSellPlanks()
    _sellPlanksOn = false
    _isSelling    = false
    ClearHoverOutline()
    if _plankConn then _plankConn:Disconnect(); _plankConn = nil end
    if _clickConn then _clickConn:Disconnect(); _clickConn = nil end
end

local function StartSellPlanks(LOT)
    if not LOT then warn("[TreeModule] LOT not available for Sell Planks.") return end

    _sellPlanksOn = true
    _isSelling    = false
    local mouse   = player:GetMouse()

    _plankConn = RunService.RenderStepped:Connect(function()
        if not _sellPlanksOn then return end
        if _isSelling then ClearHoverOutline() return end
        local plank = FindOwnedPlank(mouse.Target)
        if plank then ApplyHoverOutline(plank) else ClearHoverOutline() end
    end)

    _clickConn = mouse.Button1Down:Connect(function()
        if not _sellPlanksOn or _isSelling then return end
        if not _hoverPlank or not _hoverPlank.Parent then return end

        local plank = _hoverPlank
        ClearHoverOutline()
        _isSelling = true

        task.spawn(function()
            if LOT.IsBusy() then repeat task.wait(0.05) until not LOT.IsBusy() end

            local target = plank.PrimaryPart
            if not target then
                for _, v in ipairs(plank:GetDescendants()) do
                    if v:IsA("BasePart") then target = v; break end
                end
            end

            if not target then
                warn("[TreeModule] Plank has no BasePart to teleport.")
                _isSelling = false
                return
            end

            LOT.TeleportObjectTo(target, PLANK_SELL_CF)
            repeat task.wait(0.05) until not LOT.IsBusy()

            -- hold the plank pinned at the sell spot so the sale registers
            local lockDeadline = tick() + PLANK_LOCK_TIME
            while tick() < lockDeadline and target and target.Parent do
                target.CFrame = PLANK_SELL_CF
                target.AssemblyLinearVelocity  = Vector3.new(0, 0, 0)
                target.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                RunService.Heartbeat:Wait()
            end

            _isSelling = false
        end)
    end)
end

-- ==========================================
--   REMOTE CUT
-- ==========================================
local RemoteProxy = ReplicatedStorage:WaitForChild("Interaction"):WaitForChild("RemoteProxy")
local NPCDialogRemote = ReplicatedStorage:WaitForChild("NPCDialog"):WaitForChild("PlayerChatted")
local NPCPromptChat   = ReplicatedStorage:WaitForChild("NPCDialog"):WaitForChild("PromptChat")

local function CutHeightFrac(sizeY)
    return math.clamp(0.1 + (8 - sizeY) / 60, 0.1, 0.2)
end

local function FireCutSection(section, tool, axeName, treeClass, stopFn)
    if not section or not section.Parent then return end

    local idObj = section:FindFirstChild("ID")
    if not idObj then return end

    local cutEvent = section:FindFirstChild("CutEvent")
                  or section.Parent:FindFirstChild("CutEvent")
                  or (section.Parent.Parent and section.Parent.Parent:FindFirstChild("CutEvent"))
    if not cutEvent then return end

    local damage = _G.LT2Axes.GetDamage(axeName, treeClass)
    local height = section.Size.Y * CutHeightFrac(section.Size.Y)

    local args = {
        sectionId    = idObj.Value,
        faceVector   = Vector3.new(0, 0, -1),
        height       = height,
        hitPoints    = damage,
        cooldown     = 0,
        cuttingClass = "Axe",
        tool         = tool,
    }

    for _ = 1, Settings.FiresPerSection do
        if not section.Parent then break end
        if stopFn and stopFn() then break end
        RemoteProxy:FireServer(cutEvent, args)
        task.wait(Settings.FireDelay)
    end
end

local function FireCutAtHeight(section, tool, axeName, treeClass, height)
    if not section or not section.Parent then return end
    local idObj = section:FindFirstChild("ID")
    if not idObj then return end

    local cutEvent = section:FindFirstChild("CutEvent")
                  or section.Parent:FindFirstChild("CutEvent")
                  or (section.Parent.Parent and section.Parent.Parent:FindFirstChild("CutEvent"))

    if not cutEvent then
        warn("[TreeModule] CutEvent not found for section:", section:GetFullName())
        for _, c in ipairs(section.Parent:GetChildren()) do
            print("  parent child:", c.Name, c.ClassName)
        end
        return
    end

    local damage = _G.LT2Axes.GetDamage(axeName, treeClass)
    local args = {
        sectionId    = idObj.Value,
        faceVector   = Vector3.new(0, 0, -1),
        height       = height,
        hitPoints    = damage,
        cooldown     = 0,
        cuttingClass = "Axe",
        tool         = tool,
    }

    for _ = 1, Settings.FiresPerSection do
        if not section.Parent then break end
        RemoteProxy:FireServer(cutEvent, args)
        task.wait(Settings.FireDelay)
    end
end

-- ==========================================
--   CHOP LOGS INTO INDIVIDUAL SECTIONS
-- ==========================================
local _chopLogsActive = false
local function ChopLogsIntoSections(onComplete)
    local logModels = Workspace:FindFirstChild("LogModels")
    if not logModels then
        warn("[TreeModule] No LogModels folder.")
        if onComplete then onComplete() end
        return
    end

    local ownedModels = {}
    for _, model in ipairs(logModels:GetChildren()) do
        if model:IsA("Model") and IsOwnedByLocalPlayer(model) then
            table.insert(ownedModels, model)
        end
    end

    if #ownedModels == 0 then
        warn("[TreeModule] No owned log models to chop.")
        if onComplete then onComplete() end
        return
    end

    local function SnapshotModels()
        local snap = {}
        for _, m in ipairs(logModels:GetChildren()) do snap[m] = true end
        return snap
    end

    local function SectionCount(model)
        local count = 0
        for _, desc in ipairs(model:GetDescendants()) do
            if desc:IsA("BasePart") and desc.Name == "WoodSection" then
                count += 1
            end
        end
        return count
    end

    local function BuildConnectionMap(model)
        local map = {}
        for _, desc in ipairs(model:GetDescendants()) do
            if (desc:IsA("Weld") or desc:IsA("ManualWeld")) and desc.Name == "Tree Weld" then
                local p0, p1 = desc.Part0, desc.Part1
                if p0 and p1 and p0.Name == "WoodSection" and p1.Name == "WoodSection" then
                    map[p0] = (map[p0] or 0) + 1
                    map[p1] = (map[p1] or 0) + 1
                end
            end
        end
        return map
    end

    local function FindStump(model)
        local iw = model:FindFirstChild("InnerWood", true)
        if not iw then return nil end
        for _, desc in ipairs(model:GetDescendants()) do
            if (desc:IsA("Weld") or desc:IsA("ManualWeld")) then
                local p0, p1 = desc.Part0, desc.Part1
                if p0 == iw and p1 and p1.Name == "WoodSection" then return p1 end
                if p1 == iw and p0 and p0.Name == "WoodSection" then return p0 end
            end
        end
        return nil
    end

    local function FindTipWeld(model, tip)
        for _, desc in ipairs(model:GetDescendants()) do
            if (desc:IsA("Weld") or desc:IsA("ManualWeld")) and desc.Name == "Tree Weld" then
                local p0, p1 = desc.Part0, desc.Part1
                if p0 == tip and p1 and p1.Name == "WoodSection" then return desc, p1 end
                if p1 == tip and p0 and p0.Name == "WoodSection" then return desc, p0 end
            end
        end
        return nil
    end

    task.spawn(function()
        _chopLogsActive = true
        local queue = {}
        for _, m in ipairs(ownedModels) do
            table.insert(queue, m)
        end

        while #queue > 0 do
            if not _chopLogsActive then break end
            local model = table.remove(queue, 1)
            if not model or not model.Parent then continue end

            local tc        = model:FindFirstChild("TreeClass")
            local treeClass = tc and tc.Value or "Generic"
            local tool, axeName = GetBackpackAxe(treeClass)
            local stump     = FindStump(model)

            if not tool then
                warn("[TreeModule] No axe found for model:", model.Name, "— skipping.")
                continue
            end

            while model and model.Parent and SectionCount(model) > 1 do
                if not _chopLogsActive then break end
                local connMap = BuildConnectionMap(model)

                local tip = nil
                for section, count in pairs(connMap) do
                    if count == 1 and section ~= stump and section.Parent then
                        tip = section
                        break
                    end
                end

                if not tip then break end

                local weld, parent = FindTipWeld(model, tip)
                if not weld or not parent then break end

                local cutSection    = parent:FindFirstChild("ID") and parent or tip
                local jointWorldPos = (weld.Part0.CFrame * weld.C0).Position
                local localY        = (cutSection.CFrame:Inverse() * CFrame.new(jointWorldPos)).Position.Y
                local height        = math.clamp(localY + cutSection.Size.Y / 2, 0.05, cutSection.Size.Y - 0.05)

                local char = player.Character
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = CFrame.new(jointWorldPos + cutSection.CFrame.RightVector * 4)
                    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    task.wait(0.1)
                end

                local before = SnapshotModels()

                FireCutAtHeight(cutSection, tool, axeName, treeClass, height)

                task.wait(0.1)

                for _, m in ipairs(logModels:GetChildren()) do
                    if not before[m] and m:IsA("Model") and IsOwnedByLocalPlayer(m) then
                        if SectionCount(m) > 1 then
                            table.insert(queue, m)
                        end
                    end
                end
            end
        end

        _chopLogsActive = false
        print("[TreeModule] Done chopping logs into sections.")
        if onComplete then onComplete() end
    end)
end

-- ==========================================
--   BRIDGE TOLL (LoneCave only)
-- ==========================================
local _bridgeNPCID       = nil
local _bridgeLastPaid    = 0
local BRIDGE_PAID_WINDOW = 120

local function BridgeSafeInvoke(npcArg, action)
    local co   = coroutine.running()
    local done = false
    local thread = task.spawn(function()
        pcall(function() NPCDialogRemote:InvokeServer(npcArg, action) end)
        if not done then done = true; task.spawn(co) end
    end)
    task.delay(7, function()
        if not done then done = true; pcall(task.cancel, thread); task.spawn(co) end
    end)
    coroutine.yield()
end

local function PayBridgeToll()
    local seranok = Workspace:FindFirstChild("Bridge")
        and Workspace.Bridge:FindFirstChild("TollBooth0")
        and Workspace.Bridge.TollBooth0:FindFirstChild("Seranok")

    if not seranok then
        warn("[TreeModule] Seranok not found — cannot lower bridge.")
        return
    end

    local char = player.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local npcRoot = seranok:FindFirstChild("HumanoidRootPart")
    hrp.CFrame = npcRoot
        and CFrame.new(npcRoot.Position + Vector3.new(3, 0, 0))
        or seranok:GetPivot() * CFrame.new(3, 0, 0)
    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    task.wait(0.1)

    if not seranok:FindFirstChild("Dialog") then
        Instance.new("Dialog", seranok)
    end

    if not _bridgeNPCID then
        local lastData = nil
        local conn = NPCPromptChat.OnClientEvent:Connect(function(_, data)
            if data then lastData = data end
        end)
        pcall(function() NPCPromptChat:FireServer(true, seranok, seranok.Dialog) end)
        local t = tick()
        repeat task.wait(0.05) until lastData or tick() - t > 5
        conn:Disconnect()
        pcall(function() NPCPromptChat:FireServer(false, seranok, seranok.Dialog) end)
        task.wait(0.1)

        if lastData then
            _bridgeNPCID = lastData.ID
        else
            warn("[TreeModule] Failed to get Seranok NPC ID.")
            return
        end
    end

    local npcArg = {
        ID        = _bridgeNPCID,
        Character = seranok,
        Name      = "Seranok",
        Dialog    = seranok.Dialog,
    }

    BridgeSafeInvoke(npcArg, "Initiate")
    task.wait(0.05)
    BridgeSafeInvoke(npcArg, "ConfirmPurchase")
    task.wait(0.05)
    BridgeSafeInvoke(npcArg, "EndChat")

    print("[TreeModule] Bridge toll paid — waiting for bridge to lower.")
    task.wait(1.5)
end

-- ==========================================
--   FALL DETECTION
-- ==========================================
local function TreeHasFallen(treeClass)
    local logModels = Workspace:FindFirstChild("LogModels")
    if not logModels then return false end
    for _, model in ipairs(logModels:GetChildren()) do
        if preChopLogModels[model] then continue end
        if not model:IsA("Model") then continue end
        local tc = model:FindFirstChild("TreeClass")
        if tc and tc.Value == treeClass then return true end
    end
    return false
end

-- ==========================================
--   DEATH / RESPAWN HANDLING
-- ==========================================
local function WaitForRespawn()
    print("[TreeModule] Player died — waiting for respawn...")

    local char = player.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if not char or not hum or hum.Health <= 0 then
        player.CharacterAdded:Wait()
    end

    local deadline = tick() + 30
    repeat
        task.wait(0.1)
        char = player.Character
        hum  = char and char:FindFirstChildOfClass("Humanoid")
    until (char and hum and hum.Health > 0 and char:FindFirstChild("HumanoidRootPart"))
       or tick() > deadline

    print(("[TreeModule] Respawned — resuming in %ds"):format(Settings.RespawnResumeDelay))
    task.wait(Settings.RespawnResumeDelay)
end

-- ==========================================
--   MAIN CHOP SEQUENCE
-- ==========================================
local function StartChopping(treeClass, LOT, onComplete)
    if isChopping then return end

    SnapshotLogModels()

    local treeModel = FindPriorityTree(treeClass)
    if not treeModel then
        warn("[TreeModule] No tree found for class:", treeClass)
        if onComplete then onComplete() end
        return
    end

    local sections = GetSectionsBottomFirst(treeModel)
    if #sections == 0 then
        warn("[TreeModule] Tree has no WoodSections.")
        if onComplete then onComplete() end
        return
    end

    local tool, axeName = GetBackpackAxe(treeClass)
    if not tool then
        warn("[TreeModule] No tool found in Backpack. Cannot chop.")
        if onComplete then onComplete() end
        return
    end
    print(("[TreeModule] Using '%s' from Backpack for tree class '%s'."):format(axeName, treeClass))

    local char = player.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        if onComplete then onComplete() end
        return
    end

    preChopCFrame       = hrp.CFrame
    preChopCameraCFrame = camera.CFrame
    isChopping          = true

    if treeClass == "LoneCave" then
        PayBridgeToll()
        char = player.Character
        hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then
            isChopping = false
            if onComplete then onComplete() end
            return
        end
    end

    local targetPart = sections[1]
    for _, s in ipairs(sections) do
        local idObj = s:FindFirstChild("ID")
        if idObj and idObj.Value == 1 then
            targetPart = s
            break
        end
    end
    hrp.CFrame = targetPart.CFrame
    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)

    local lockConn = nil

    local function StartLockConn()
        if lockConn then lockConn:Disconnect() end
        lockConn = RunService.Heartbeat:Connect(function()
            local c = player.Character
            local r = c and c:FindFirstChild("HumanoidRootPart")
            if r and targetPart and targetPart.Parent then
                r.CFrame = targetPart.CFrame
                r.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end
        end)
    end

    local function StopLockConn()
        if lockConn then lockConn:Disconnect(); lockConn = nil end
    end

    local playerDied = false
    local diedConn   = nil

    local function HookDiedEvent()
        if diedConn then diedConn:Disconnect(); diedConn = nil end
        local c    = player.Character
        local hum2 = c and c:FindFirstChildOfClass("Humanoid")
        if not hum2 then return end
        diedConn = hum2.Died:Connect(function()
            playerDied = true
            StopLockConn()
            print("[TreeModule] Death detected during chop.")
        end)
    end

    HookDiedEvent()
    StartLockConn()
    task.wait(Settings.SyncDelay)

    task.spawn(function()
        local baseSection = nil

        local function RefreshBaseSection()
            baseSection = nil
            local fresh = GetSectionsBottomFirst(treeModel)
            if #fresh == 0 then return end
            baseSection = fresh[1]
            for _, s in ipairs(fresh) do
                local idObj = s:FindFirstChild("ID")
                if idObj and idObj.Value == 1 then
                    baseSection = s
                    break
                end
            end
        end

        RefreshBaseSection()

        while not TreeHasFallen(treeClass) and isChopping do
            if playerDied then
                StopLockConn()
                WaitForRespawn()
                if not isChopping then break end
                if TreeHasFallen(treeClass) then break end

                tool, axeName = GetBackpackAxe(treeClass)
                if not tool then
                    warn("[TreeModule] No axe found after respawn — stopping.")
                    isChopping = false
                    break
                end
                print(("[TreeModule] Resumed with '%s' after respawn."):format(axeName))

                local newChar = player.Character
                local newHRP  = newChar and newChar:FindFirstChild("HumanoidRootPart")
                if newHRP and targetPart and targetPart.Parent then
                    newHRP.CFrame = targetPart.CFrame
                    newHRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                end

                playerDied = false
                HookDiedEvent()
                StartLockConn()
                task.wait(Settings.SyncDelay)

                RefreshBaseSection()
            end

            if not baseSection or not baseSection.Parent then
                RefreshBaseSection()
                if not baseSection then break end
            end

            FireCutSection(baseSection, tool, axeName, treeClass, function()
                return TreeHasFallen(treeClass) or playerDied
            end)

            task.wait(Settings.SweepDelay)
        end

        StopLockConn()
        if diedConn then diedConn:Disconnect(); diedConn = nil end

        if not isChopping then
            CleanupState()
            if onComplete then onComplete() end
            return
        end

        print("[TreeModule] Tree is down. Returning player.")
        task.wait(0.3)
        CleanupState()

        local stumps     = CollectNewStumps(treeClass)
        local currentHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

        RunLOTBatch(LOT, stumps, function(i, _)
            return currentHRP
                and (currentHRP.CFrame * CFrame.new((i - 1) * 5, 0, -Settings.LogDropDistance))
                or CFrame.new(0, 0, 0)
        end, onComplete)
    end)
end

-- ==========================================
--   LIVE TREE REMOVAL WATCHER
-- ==========================================
local function WatchForRemovedTreeTypes(onClassEmpty)
    local connections = {}
    
    local function CountTreeClass(className)
        local count = 0
        for _, folder in ipairs(Workspace:GetChildren()) do
            if folder.Name:lower():match("treeregion") then
                for _, model in ipairs(folder:GetChildren()) do
                    if model:IsA("Model") then
                        local tc = model:FindFirstChild("TreeClass")
                        if tc and tc.Value == className and CountTreeSections(model) > 1 then
                            count += 1
                        end
                    end
                end
            end
        end
        return count
    end

    local function WatchFolder(folder)
        local conn = folder.ChildRemoved:Connect(function(model)
            if not model:IsA("Model") then return end
            local tc = model:FindFirstChild("TreeClass")
            if not tc or not tc:IsA("StringValue") then return end
            local className = tc.Value
            -- small delay to let the engine settle before we recount
            task.delay(0.5, function()
                local remaining = CountTreeClass(className)
                onClassEmpty(className, remaining == 0)
            end)
        end)
        table.insert(connections, conn)
    end

    for _, folder in ipairs(Workspace:GetChildren()) do
        if folder.Name:lower():match("treeregion") then
            WatchFolder(folder)
        end
    end

    local workspaceConn = Workspace.ChildAdded:Connect(function(child)
        if child.Name:lower():match("treeregion") then
            WatchFolder(child)
        end
    end)
    table.insert(connections, workspaceConn)

    return function()
        for _, conn in ipairs(connections) do conn:Disconnect() end
    end
end

-- ==========================================
--   LIVE TREE TYPE WATCHER
-- ==========================================
-- Calls `onNewClass(className)` whenever a tree class appears in any
-- TreeRegion folder that wasn't present in `knownSet` at call time.
-- Returns a cleanup function that disconnects all listeners.
local function WatchForNewTreeTypes(knownSet, onNewClass)
    local connections = {}

    -- Hook ChildAdded on a single TreeRegion folder
    local function WatchFolder(folder)
        local conn = folder.ChildAdded:Connect(function(model)
            if not model:IsA("Model") then return end

            -- The TreeClass StringValue may not exist yet if the model
            -- is still streaming in — wait a short moment for it.
            task.delay(0.5, function()
                if not model or not model.Parent then return end
                local tc = model:FindFirstChild("TreeClass")
                if not tc or not tc:IsA("StringValue") then return end
                if CountTreeSections(model) <= 1 then return end
                local className = tc.Value
                if knownSet[className] then return end
                knownSet[className] = true
                onNewClass(className)
            end)
        end)
        table.insert(connections, conn)
    end

    -- Watch all TreeRegion folders that exist right now
    for _, folder in ipairs(Workspace:GetChildren()) do
        if folder.Name:lower():match("treeregion") then
            WatchFolder(folder)
        end
    end

    -- Also watch for TreeRegion folders that haven't loaded yet
    local workspaceConn = Workspace.ChildAdded:Connect(function(child)
        if child.Name:lower():match("treeregion") then
            WatchFolder(child)
        end
    end)
    table.insert(connections, workspaceConn)

    -- Return a cleanup function so Init can disconnect everything on
    -- shutdown if needed (e.g. if the Tab is destroyed)
    return function()
        for _, conn in ipairs(connections) do
            conn:Disconnect()
        end
    end
end

-- ==========================================
--             DYNXE UI
-- ==========================================
function TreeModule.Init(Tab, LOT)
    Tab:CreateSection("Auto-Tree Configuration")

    local PRIORITY_TREES = {
        "Generic", "Cherry", "Birch", "Oak", "Walnut", "Koa", "Pine", "Palm", "Fir",
        "Volcano", "Frost", "GreenSwampy", "GoldSwampy",
        "SnowGlow", "CaveCrawler", "LoneCave", "Spook", "Sinister",
    }

    local treeTypes = ScanForTreeTypes()
    
    -- Also scan for ALL tree classes present regardless of section count
    -- so we can show them in the list but disabled
    local function ScanAllTreeClasses()
        local found, seen = {}, {}
        for _, folder in ipairs(Workspace:GetChildren()) do
            if folder.Name:lower():match("treeregion") then
                for _, model in ipairs(folder:GetChildren()) do
                    if model:IsA("Model") then
                        local tc = model:FindFirstChild("TreeClass")
                        if tc and tc:IsA("StringValue") and not seen[tc.Value] then
                            seen[tc.Value] = true
                            table.insert(found, tc.Value)
                        end
                    end
                end
            end
        end
        return found
    end
    
    local allTreeClasses = ScanAllTreeClasses()
    
    local foundSet    = {}
    for _, t in ipairs(treeTypes) do foundSet[t] = true end
    local prioritySet = {}
    for _, t in ipairs(PRIORITY_TREES) do prioritySet[t] = true end
    
    -- allClassSet = every class present in workspace (even single-section ones)
    local allClassSet = {}
    for _, t in ipairs(allTreeClasses) do allClassSet[t] = true end
    
    local orderedOptions = {}
    local disabledInDrop = {}
    
    -- 1. Priority trees with valid (>1 section) trees — enabled
    for _, t in ipairs(PRIORITY_TREES) do
        if foundSet[t] then table.insert(orderedOptions, t) end
    end
    -- 2. Non-priority trees with valid trees — enabled
    for _, t in ipairs(treeTypes) do
        if not prioritySet[t] then table.insert(orderedOptions, t) end
    end
    -- 3. Priority trees that exist but only have single-section trees — disabled
    for _, t in ipairs(PRIORITY_TREES) do
        if not foundSet[t] and allClassSet[t] then
            table.insert(orderedOptions, t)
            disabledInDrop[t] = true
        end
    end
    -- 4. Priority trees completely absent from workspace — disabled
    for _, t in ipairs(PRIORITY_TREES) do
        if not allClassSet[t] then
            table.insert(orderedOptions, t)
            disabledInDrop[t] = true
        end
    end

    -- Default to first available (non-disabled) option
    local selectedTree = "Error"
    for _, t in ipairs(orderedOptions) do
        if not disabledInDrop[t] then selectedTree = t; break end
    end

    local chopQuantity      = 1
    local chopButton
    local chopSessionActive = false

    local treeDropdown = Tab:CreateDropdown("Target Tree Type", orderedOptions, selectedTree, function(sel)
        selectedTree = sel
    end)

    for t in pairs(disabledInDrop) do
        treeDropdown:SetOptionDisabled(t, true)
    end

    -- ── Live watcher ─────────────────────────────────────────────
    -- `knownSet` starts as a copy of foundSet so the watcher only
    -- fires for classes that were genuinely absent at init time.
    local knownSet = {}
    for k, v in pairs(foundSet) do knownSet[k] = v end

    WatchForNewTreeTypes(knownSet, function(newClass)
        print(("[TreeModule] New tree type detected: %s — enabling in dropdown."):format(newClass))

        -- If it's a known priority tree that was sitting disabled at
        -- the bottom, just re-enable it.  Otherwise add it fresh
        -- (between existing enabled options and the disabled block).
        if disabledInDrop[newClass] then
            disabledInDrop[newClass] = nil
            treeDropdown:SetOptionDisabled(newClass, false)
        else
            -- Truly new class (not in PRIORITY_TREES at all) —
            -- insert it before the first disabled entry so it lands
            -- in the "workspace extras" region of the list.
            local insertAt = #orderedOptions + 1
            for i, opt in ipairs(orderedOptions) do
                if disabledInDrop[opt] then
                    insertAt = i
                    break
                end
            end
            table.insert(orderedOptions, insertAt, newClass)
            treeDropdown:AddOption(newClass, insertAt)
        end

        -- If nothing was selectable before, auto-select this new class
        if selectedTree == "Error" then
            selectedTree = newClass
            treeDropdown:SetSelected(newClass)
        end
    end)
    -- ─────────────────────────────────────────────────────────────

    WatchForRemovedTreeTypes(function(className, isEmpty)
        if isEmpty then
            -- tree class has no more instances in any region — disable it
            disabledInDrop[className] = true
            treeDropdown:SetOptionDisabled(className, true)
            print(("[TreeModule] No more '%s' trees — disabled in dropdown."):format(className))
    
            -- if the player had this selected, reset to next available
            if selectedTree == className then
                selectedTree = "Error"
                for _, t in ipairs(orderedOptions) do
                    if not disabledInDrop[t] then
                        selectedTree = t
                        treeDropdown:SetSelected(t)
                        break
                    end
                end
            end
        else
            -- tree grew back / still has instances — make sure it's enabled
            if disabledInDrop[className] then
                disabledInDrop[className] = nil
                treeDropdown:SetOptionDisabled(className, false)
                print(("[TreeModule] '%s' trees available again — enabled in dropdown."):format(className))
            end
        end
    end)
    
    Tab:CreateSlider("Quantity", 1, 25, 1, function(val)
        chopQuantity = val
    end)

    chopButton = Tab:CreateAction("Get Tree", "Start", function()
        if chopSessionActive then
            chopSessionActive = false
            isChopping = false
            if type(chopButton) == "table" and chopButton.SetText then
                chopButton:SetText("Start")
            end
        else
            if selectedTree == "None Found" or selectedTree == "Error" then return end
            chopSessionActive = true
            if type(chopButton) == "table" and chopButton.SetText then
                chopButton:SetText("Stop")
            end

            local remaining = chopQuantity
            local function chopNext()
                if not chopSessionActive or remaining <= 0 then
                    chopSessionActive = false
                    if type(chopButton) == "table" and chopButton.SetText then
                        chopButton:SetText("Start")
                    end
                    return
                end
                remaining -= 1
                StartChopping(selectedTree, LOT, function()
                    chopNext()
                end)
            end

            chopNext()
        end
    end)

    Tab:CreateSection("Log Management")

    local chopSectionsButton
    chopSectionsButton = Tab:CreateAction("Chop All Trees", "Start", function()
        if _chopLogsActive then
            _chopLogsActive = false
            if type(chopSectionsButton) == "table" and chopSectionsButton.SetText then
                chopSectionsButton:SetText("Start")
            end
            return
        end

        if not LOT then warn("[TreeModule] LOT not available.") return end

        if type(chopSectionsButton) == "table" and chopSectionsButton.SetText then
            chopSectionsButton:SetText("Stop")
        end

        ChopLogsIntoSections(function()
            if type(chopSectionsButton) == "table" and chopSectionsButton.SetText then
                chopSectionsButton:SetText("Start")
            end
        end)
    end)
    
    local LogRow = Tab:CreateRow()

    local tpAllButton = LogRow:CreateAction("TP All Logs", "TP", function()
        if not LOT then warn("[TreeModule] LOT not available.") return end
        if LOT.IsBusy() then warn("[TreeModule] LOT busy.") return end
    
        local stumps     = CollectAllOwnedStumps()
        local currentHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if #stumps == 0 then return end
    
        if type(tpAllButton) == "table" and tpAllButton.SetText then
            tpAllButton:SetText("Working...")
        end
    
        RunLOTBatch(LOT, stumps, function(_, _)
            return currentHRP
                and (currentHRP.CFrame * CFrame.new(0, 0, -Settings.LogDropDistance))
                or CFrame.new(0, 0, 0)
        end, function()
            if type(tpAllButton) == "table" and tpAllButton.SetText then
                tpAllButton:SetText("TP")
            end
        end)
    end)
    
    local sellButton = LogRow:CreateAction("Sell All Logs", "Sell", function()
        if not LOT then warn("[TreeModule] LOT not available.") return end
        if LOT.IsBusy() then warn("[TreeModule] LOT busy.") return end
    
        local stumps = CollectSingleSectionStumps()
        if #stumps == 0 then return end
    
        if type(sellButton) == "table" and sellButton.SetText then
            sellButton:SetText("Selling...")
        end
    
        local sellPos = Settings.SellPosition
        RunLOTBatch(LOT, stumps, function(_, _)
            return CFrame.new(sellPos.X, sellPos.Y, sellPos.Z)
        end, function()
            if type(sellButton) == "table" and sellButton.SetText then
                sellButton:SetText("Sell")
            end
        end)
    end)
    Tab:CreateToggle("Click To Sell (Planks)", false, function(state)
        if state then StartSellPlanks(LOT) else StopSellPlanks() end
    end)
    
    local pc_enabled        = false
    local pc_isCutting      = false
    local pc_outline        = nil
    local pc_cutPlanes      = {}
    local pc_trackedSection = nil
    local pc_currentTarget  = nil
    local pc_hoverConn      = nil
    local pc_clickConn      = nil
    local pc_visualConn     = nil
    local pc_mouse          = player:GetMouse()
    local pc_queue          = {}
    
    local PC_FIRE_DELAY    = 0.03
    local PC_CUT_TIMEOUT   = 90
    local PC_BLUE          = Color3.fromRGB(74, 120, 255)
    local PC_QUEUE_COLOR   = Color3.fromRGB(255, 170, 60)
    local pc_queueHighlights = {}
    local PC_MAX_CUT_UNITS = 100
    local PC_DETECT_RADIUS = 8
    local RemoteProxyPC    = ReplicatedStorage:WaitForChild("Interaction"):WaitForChild("RemoteProxy")
    
    local function pc_ReadAxeName(tool)
        if not tool then return nil end
        local tip = tool:FindFirstChild("ToolTip")
        return (tip and tip:IsA("StringValue")) and tip.Value or tool.ToolTip
    end
    
    local function pc_GetPlankTreeClass(plankModel)
        if not plankModel then return nil end
        local tc = plankModel:FindFirstChild("TreeClass")
        if tc and tc:IsA("StringValue") then return tc.Value end
        for _, v in ipairs(plankModel:GetDescendants()) do
            if v.Name == "TreeClass" and v:IsA("StringValue") then return v.Value end
        end
        return nil
    end
    
    local function pc_GetBestAxe(treeClass)
        local candidates = {}
        local function TryAdd(tool)
            if not tool:IsA("Tool") then return end
            if tool.Name == "BlueprintTool" then return end
            local name = pc_ReadAxeName(tool)
            if not name then return end
            if treeClass == "LoneCave" and name ~= "End Times Axe" then return end
            local dmg = _G.LT2Axes.GetDamage(name, treeClass) or 0
            table.insert(candidates, { tool = tool, name = name, dmg = dmg })
        end
        local char = player.Character
        if char then
            local eq = char:FindFirstChildOfClass("Tool")
            if eq then TryAdd(eq) end
        end
        for _, t in ipairs(player.Backpack:GetChildren()) do TryAdd(t) end
        if #candidates == 0 then return nil, nil, 0 end

        -- Refined Axe does 12 damage to planks — always prefer it for 1x1 cutting
        for _, c in ipairs(candidates) do
            if c.name == "Refined Axe" then
                return c.tool, c.name, 12
            end
        end

        table.sort(candidates, function(a, b) return a.dmg > b.dmg end)
        local best = candidates[1]
        return best.tool, best.name, best.dmg
    end
    
    local function pc_FindOwnedPlank(part)
        if not part then return nil end
        local pm = Workspace:FindFirstChild("PlayerModels")
        if not pm then return nil end
        local cur = part
        while cur and cur.Parent ~= pm do cur = cur.Parent end
        if not cur or not cur:IsA("Model") or cur.Name ~= "Plank" then return nil end
        local owner    = cur:FindFirstChild("Owner")
        local ownerStr = owner and owner:FindFirstChild("OwnerString")
        if not ownerStr or ownerStr.Value ~= player.Name then return nil end
        return cur
    end
    
    local function pc_GetPlankSection(model)
        if not model then return nil end
        for _, d in ipairs(model:GetDescendants()) do
            if d:IsA("BasePart") and d:FindFirstChild("ID") then return d end
        end
        return nil
    end
    
    local function pc_GetCutStep(section)
        return math.max(0.5, 1 / math.min(section.Size.X, section.Size.Z))
    end
    
    local PC_MIN_LEFTOVER = 1 -- studs; a trailing piece shorter than this is left uncut rather than sliced off

    local function pc_GetCutHeights(section)
        local sizeY = section.Size.Y
        local step  = pc_GetCutStep(section)
        local out   = {}
        local h     = step
        -- only add a cut if what's left above it would still be >= PC_MIN_LEFTOVER
        while h <= sizeY - PC_MIN_LEFTOVER + 0.001 do table.insert(out, h); h = h + step end
        return out, step
    end
    
    local function pc_IsPlankEligible(section, treeClass)
        if not section then return false end
        local heights = pc_GetCutHeights(section)
        if #heights == 0 then return false end
        if #heights > PC_MAX_CUT_UNITS then return false end
        if treeClass == "LoneCave" then
            local t = pc_GetBestAxe("LoneCave")
            if not t then return false end
        end
        return true
    end

    local function pc_AddQueueHighlight(plank)
        if not plank or pc_queueHighlights[plank] then return end
        local box = Instance.new("SelectionBox")
        box.Color3 = PC_QUEUE_COLOR
        box.SurfaceColor3 = PC_QUEUE_COLOR
        box.LineThickness = 0.03
        box.SurfaceTransparency = 0.85
        box.Adornee = plank
        box.Parent = Workspace
        pc_queueHighlights[plank] = box
    end

    local function pc_RemoveQueueHighlight(plank)
        local box = pc_queueHighlights[plank]
        if box then
            pcall(function() box:Destroy() end)
            pc_queueHighlights[plank] = nil
        end
    end

    local function pc_ClearQueueHighlights()
        for _, box in pairs(pc_queueHighlights) do
            pcall(function() box:Destroy() end)
        end
        pc_queueHighlights = {}
    end

    local function pc_QueuePlank(plank)
        if not plank or plank == pc_currentTarget then return end
        for _, queued in ipairs(pc_queue) do
            if queued == plank then return end
        end
        table.insert(pc_queue, plank)
        pc_AddQueueHighlight(plank)
    end

    local function pc_PopNextQueued()
        while #pc_queue > 0 do
            local candidate = table.remove(pc_queue, 1)
            pc_RemoveQueueHighlight(candidate)
            if candidate and candidate.Parent then
                local sec = pc_GetPlankSection(candidate)
                local tc  = pc_GetPlankTreeClass(candidate)
                if sec and pc_IsPlankEligible(sec, tc) then
                    return candidate
                end
            end
        end
        return nil
    end
    
    local function pc_EnsureOutline()
        if pc_outline and pc_outline.Parent then return end
        pc_outline = Instance.new("SelectionBox")
        pc_outline.Color3 = PC_BLUE
        pc_outline.SurfaceColor3 = PC_BLUE
        pc_outline.LineThickness = 0.04
        pc_outline.SurfaceTransparency = 0.8
        pc_outline.Parent = Workspace
    end
    
    local function pc_SetOutlineTarget(model)
        pc_EnsureOutline()
        if pc_outline.Adornee ~= model then pc_outline.Adornee = model end
    end
    
    local function pc_ClearCutPlanes()
        for _, e in ipairs(pc_cutPlanes) do pcall(function() e.part:Destroy() end) end
        pc_cutPlanes = {}
        pc_trackedSection = nil
    end
    
    local function pc_RebuildCutPlanes(section)
        pc_ClearCutPlanes()
        if not section or not section.Parent then return end
        local heights = pc_GetCutHeights(section)
        local sx    = section.Size.X + 0.08
        local sz    = section.Size.Z + 0.08
        local sizeY = section.Size.Y
        for _, h in ipairs(heights) do
            local localCF = CFrame.new(0, -sizeY / 2 + h, 0)
            local p = Instance.new("Part")
            p.Anchored = true; p.CanCollide = false; p.CanTouch = false
            p.CanQuery = false; p.CastShadow = false
            p.Size = Vector3.new(sx, 0.04, sz)
            p.Color = PC_BLUE; p.Material = Enum.Material.Neon
            p.Transparency = 0.2
            p.CFrame = section.CFrame * localCF
            p.Parent = Workspace
            table.insert(pc_cutPlanes, { part = p, localCF = localCF })
        end
        pc_trackedSection = section
    end
    
    local function pc_FindCutEvent(section)
        local cur = section
        while cur and cur ~= Workspace do
            local ce = cur:FindFirstChild("CutEvent")
            if ce then return ce end
            cur = cur.Parent
        end
        return nil
    end
    
    local function pc_FireUntilSplit(section, tool, damage, height)
        local idObj    = section:FindFirstChild("ID")
        local cutEvent = pc_FindCutEvent(section)
        if not idObj or not cutEvent then return nil end
        local pm = Workspace:FindFirstChild("PlayerModels")
        local snapshot = {}
        if pm then for _, m in ipairs(pm:GetChildren()) do snapshot[m] = true end end
        local args = {
            sectionId = idObj.Value, faceVector = Vector3.new(0,0,-1),
            height = height, hitPoints = damage, cooldown = 0,
            cuttingClass = "Axe", tool = tool,
        }
        local lastPos = section.Position
        local function FindNewSection()
            if not pm then return nil end
            for _, m in ipairs(pm:GetChildren()) do
                if not snapshot[m] and m:IsA("Model") and m.Name == "Plank" then
                    local owner = m:FindFirstChild("Owner")
                    local ownerStr = owner and owner:FindFirstChild("OwnerString")
                    if ownerStr and ownerStr.Value == player.Name then
                        local sec = pc_GetPlankSection(m)
                        if sec and (sec.Position - lastPos).Magnitude <= PC_DETECT_RADIUS then
                            return sec
                        end
                    end
                end
            end
            return nil
        end
        local originalSizeY = section.Size.Y
        local deadline = tick() + PC_CUT_TIMEOUT
        while tick() < deadline and pc_enabled do
            if section.Parent then lastPos = section.Position end
            if not section.Parent then task.wait(0.05); return FindNewSection() end
            RemoteProxyPC:FireServer(cutEvent, args)
            task.wait(PC_FIRE_DELAY)
            if not section.Parent or section.Size.Y ~= originalSizeY then
                task.wait(0.05); return FindNewSection()
            end
        end
        return nil
    end
    
    local function pc_TeleportAbovePlank(section, cutHeight)
        local char = player.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp or not section or not section.Parent then return end
        local bottomY   = -section.Size.Y / 2
        local localCutY = bottomY + (cutHeight or 0)
        local worldPos  = (section.CFrame * CFrame.new(0, localCutY + 3, 0)).Position
        if (hrp.Position - worldPos).Magnitude <= PC_DETECT_RADIUS then return end
        hrp.CFrame = CFrame.new(worldPos)
        hrp.AssemblyLinearVelocity  = Vector3.new(0, 0, 0)
        hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end
    
    local pc_statusBB = nil
    local pc_sessionCutCount = 0
    local pc_sessionCutTotal = 0.0

    local function pc_ShowStatus(text)
        if pc_statusBB then pc_statusBB:Destroy(); pc_statusBB = nil end
        local char = player.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local bb = Instance.new("BillboardGui")
        bb.Name        = "DynxeCutStatus"
        bb.Size        = UDim2.new(0, 220, 0, 48)
        bb.StudsOffset = Vector3.new(0, 4, 0)
        bb.AlwaysOnTop = true
        bb.Adornee     = hrp
        bb.Parent      = game:GetService("CoreGui")

        local bg = Instance.new("Frame")
        bg.Size                   = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3       = Color3.fromRGB(18, 18, 22)
        bg.BackgroundTransparency = 0.1
        bg.BorderSizePixel        = 0
        bg.Parent                 = bb
        local corner = Instance.new("UICorner", bg)
        corner.CornerRadius = UDim.new(0, 6)
        local stroke = Instance.new("UIStroke", bg)
        stroke.Color     = Color3.fromRGB(74, 120, 255)
        stroke.Thickness = 1.5

        local topBar = Instance.new("Frame")
        topBar.Size             = UDim2.new(1, 0, 0, 3)
        topBar.BackgroundColor3 = Color3.fromRGB(74, 120, 255)
        topBar.BorderSizePixel  = 0
        topBar.ZIndex           = 3
        topBar.Parent           = bg

        local lbl = Instance.new("TextLabel")
        lbl.Size                   = UDim2.new(1, -10, 1, -6)
        lbl.Position               = UDim2.new(0, 5, 0, 5)
        lbl.BackgroundTransparency = 1
        lbl.Text                   = text
        lbl.TextColor3             = Color3.fromRGB(210, 215, 240)
        lbl.Font                   = Enum.Font.GothamBold
        lbl.TextSize               = 13
        lbl.TextXAlignment         = Enum.TextXAlignment.Center
        lbl.TextYAlignment         = Enum.TextYAlignment.Center
        lbl.ZIndex                 = 4
        lbl.Parent                 = bg

        pc_statusBB = bb
        return lbl
    end

    local function pc_HideStatus()
        if pc_statusBB then pc_statusBB:Destroy(); pc_statusBB = nil end
    end

    local function pc_CountCuts(section)
        local heights = pc_GetCutHeights(section)
        return #heights, #heights + 1  -- cuts needed, planks produced
    end

    local function pc_CutPlankIntoUnits(plankModel)
        pc_isCutting     = true
        pc_currentTarget = plankModel
        pc_SetOutlineTarget(plankModel)
        local treeClass = pc_GetPlankTreeClass(plankModel)
        local tool, axeName, damage = pc_GetBestAxe(treeClass)
        if not tool then
            pc_SetOutlineTarget(nil); pc_ClearCutPlanes()
            pc_isCutting = false; pc_currentTarget = nil; return
        end
        local section = pc_GetPlankSection(plankModel)
        if not section then
            pc_SetOutlineTarget(nil); pc_ClearCutPlanes()
            pc_isCutting = false; pc_currentTarget = nil; return
        end

        local step            = pc_GetCutStep(section)
        local cutsNeeded, planksTotal = pc_CountCuts(section)
        local statusLbl       = pc_ShowStatus(
            string.format("✂  %d planks  ·  ETA --", planksTotal)
        )

        local cutsDone    = 0
        local avgCutTime  = nil

        local function formatETA(secsLeft)
            local s = math.floor(secsLeft)
            local m = math.floor(s / 60)
            s = s % 60
            return m > 0 and string.format("%dm %ds", m, s) or string.format("%ds", s)
        end

        local function updateStatus()
            if not statusLbl or not statusLbl.Parent then return end
            local planksLeft = math.max(0, planksTotal - cutsDone - 1)
            local cutsLeft   = math.max(0, cutsNeeded - cutsDone)
            local etaStr     = "--"
            if avgCutTime and cutsLeft > 0 then
                etaStr = formatETA(avgCutTime * cutsLeft)
            elseif cutsLeft == 0 then
                etaStr = "done"
            end
            local queueSuffix = #pc_queue > 0 and string.format("  ·  +%d queued", #pc_queue) or ""
            statusLbl.Text = string.format("✂  %d planks  ·  ETA %s%s", planksLeft, etaStr, queueSuffix)
        end

        pc_TeleportAbovePlank(section, step)
        task.wait(0.1)

        local cur = section
        while pc_enabled and cur and cur.Parent do
            if cur.Size.Y - step < PC_MIN_LEFTOVER - 0.001 then break end
            pc_RebuildCutPlanes(cur)
            pc_currentTarget = cur.Parent
            pc_SetOutlineTarget(pc_currentTarget)
            pc_TeleportAbovePlank(cur, step)

            local t0     = tick()
            local newSec = pc_FireUntilSplit(cur, tool, damage, step)
            local elapsed = tick() - t0

            cutsDone += 1

            pc_sessionCutCount += 1
            pc_sessionCutTotal += elapsed
            avgCutTime = pc_sessionCutTotal / pc_sessionCutCount

            pc_ClearCutPlanes()
            updateStatus()

            if not newSec then break end
            local nextPiece = cur
            if not (cur.Parent and cur.Size.Y > newSec.Size.Y) then nextPiece = newSec end
            if nextPiece and nextPiece.Parent then
                cur = nextPiece
                pc_currentTarget = nextPiece.Parent
                pc_SetOutlineTarget(pc_currentTarget)
            end
            task.wait(0.1)
        end

        pc_sessionCutCount = 0
        pc_sessionCutTotal = 0.0
        pc_ClearCutPlanes()
        pc_HideStatus()
        pc_isCutting = false

        if pc_enabled then
            local nextPlank = pc_PopNextQueued()
            if nextPlank then
                task.spawn(pc_CutPlankIntoUnits, nextPlank)
            end
        end
    end
    
    Tab:CreateToggle("1x1 Cutter", false, function(state)
        if state then
            pc_enabled   = true
            pc_isCutting = false
    
            pc_visualConn = RunService.Heartbeat:Connect(function()
                if not pc_trackedSection or not pc_trackedSection.Parent then return end
                local cf = pc_trackedSection.CFrame
                for _, e in ipairs(pc_cutPlanes) do
                    if e.part.Parent then e.part.CFrame = cf * e.localCF end
                end
            end)
    
            local lastSection = nil
            pc_hoverConn = RunService.RenderStepped:Connect(function()
                if not pc_enabled or pc_isCutting then return end
                local target = pc_mouse.Target
                local plank  = pc_FindOwnedPlank(target)
                if plank then
                    local sec = pc_GetPlankSection(plank)
                    local tc  = pc_GetPlankTreeClass(plank)
                    if sec and pc_IsPlankEligible(sec, tc) then
                        if pc_currentTarget ~= plank then
                            pc_currentTarget = plank
                            pc_SetOutlineTarget(plank)
                        end
                        if sec ~= lastSection then
                            lastSection = sec
                            pc_RebuildCutPlanes(sec)
                        end
                    else
                        if pc_currentTarget then
                            pc_currentTarget = nil
                            pc_SetOutlineTarget(nil)
                            pc_ClearCutPlanes()
                            lastSection = nil
                        end
                    end
                else
                    local clearOk = true
                    if pc_currentTarget and target and target:IsDescendantOf(pc_currentTarget) then
                        clearOk = false
                    end
                    if clearOk and pc_currentTarget then
                        pc_currentTarget = nil
                        pc_SetOutlineTarget(nil)
                        pc_ClearCutPlanes()
                        lastSection = nil
                    end
                end
            end)
    
            pc_clickConn = pc_mouse.Button1Down:Connect(function()
                if not pc_enabled then return end
                local plank = pc_FindOwnedPlank(pc_mouse.Target)
                if not plank then return end
                local sec = pc_GetPlankSection(plank)
                local tc  = pc_GetPlankTreeClass(plank)
                if not pc_IsPlankEligible(sec, tc) then return end
                if pc_isCutting then
                    pc_QueuePlank(plank)
                else
                    task.spawn(function() pc_CutPlankIntoUnits(plank) end)
                end
            end)
    
        else
            pc_sessionCutCount = 0
            pc_sessionCutTotal = 0.0
            pc_enabled = false
            pc_queue = {}
            pc_ClearQueueHighlights()
            if pc_hoverConn  then pc_hoverConn:Disconnect();  pc_hoverConn  = nil end
            if pc_clickConn  then pc_clickConn:Disconnect();  pc_clickConn  = nil end
            if pc_visualConn then pc_visualConn:Disconnect(); pc_visualConn = nil end
            if pc_outline    then pc_outline.Adornee = nil end
            pc_ClearCutPlanes()
            pc_currentTarget = nil
            pc_HideStatus()
        end
    end)

    -- ==========================================
    --   HOVER VALUE DISPLAY
    -- ==========================================
    local TREE_RATES = {
        Generic     = 1.5,  Cherry    = 1.3,  Birch      = 2.25,
        Oak         = 0.75, Walnut    = 1.2,  Koa        = 2.8,
        Pine        = 3.2,  Palm      = 2.9,  Fir        = 3.2,
        Volcano     = 3.5,  Frost     = 9.0,  GreenSwampy = 4.4,
        GoldSwampy  = 5.7,  SnowGlow  = 1.5,  CaveCrawler = 8.0,
        LoneCave    = 150.0, BlueSpruce = 20.0, Spook    = 19.0,
        SpookNeon   = 25.0,
    }
    local PLANK_RATES = {
        Generic     = 10,   Cherry    = 10.5, Birch      = 15,
        Oak         = 6,    Walnut    = 11,   Koa        = 26.4,
        Pine        = 18,   Palm      = 32,   Fir        = 18,
        Volcano     = 28,   Frost     = 106.0, GreenSwampy = 30.0,
        GoldSwampy  = 36.0, SnowGlow  = 10,   CaveCrawler = 36.0,
        LoneCave    = 420.0, BlueSpruce = 40.0, Spook    = 54.0,
        SpookNeon   = 90.0,
    }

    local hv_billboard  = nil
    local hv_lastModel  = nil
    local hv_hoverConn  = nil
    local hv_mouse      = player:GetMouse()
    local hv_CoreGui    = game:GetService("CoreGui")

    local HV_ACCENT  = Color3.fromRGB(74,  120, 255)
    local HV_BG      = Color3.fromRGB(18,  18,  22)
    local HV_STROKE  = Color3.fromRGB(40,  40,  48)
    local HV_MUTED   = Color3.fromRGB(120, 120, 130)

    local function hv_DestroyBillboard()
        if hv_billboard and hv_billboard.Parent then hv_billboard:Destroy() end
        hv_billboard = nil
        hv_lastModel = nil
    end

    local function hv_CreateBillboard(adornPart, heightOffset, valueText, labelText)
        if hv_billboard then hv_billboard:Destroy(); hv_billboard = nil end

        local char = player.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local bb = Instance.new("BillboardGui")
        bb.Name          = "DynxeHoverValue"
        bb.Size          = UDim2.new(0, 200, 0, 56)
        bb.StudsOffset   = Vector3.new(0, 4, 0)
        bb.AlwaysOnTop   = true
        bb.MaxDistance   = 800
        bb.Adornee       = hrp
        bb.Parent        = hv_CoreGui

        local bg = Instance.new("Frame")
        bg.Size                   = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3       = Color3.fromRGB(18, 18, 22)
        bg.BackgroundTransparency = 0.1
        bg.BorderSizePixel        = 0
        bg.Parent                 = bb
        local corner = Instance.new("UICorner", bg)
        corner.CornerRadius = UDim.new(0, 6)
        local stroke = Instance.new("UIStroke", bg)
        stroke.Color     = HV_ACCENT
        stroke.Thickness = 1.5

        local topBar = Instance.new("Frame")
        topBar.Size             = UDim2.new(1, 0, 0, 3)
        topBar.BackgroundColor3 = HV_ACCENT
        topBar.BorderSizePixel  = 0
        topBar.ZIndex           = 3
        topBar.Parent           = bg

        local valueLbl = Instance.new("TextLabel")
        valueLbl.Size                   = UDim2.new(1, -12, 0, 28)
        valueLbl.Position               = UDim2.new(0, 6, 0, 6)
        valueLbl.BackgroundTransparency = 1
        valueLbl.Text                   = valueText
        valueLbl.TextColor3             = HV_ACCENT
        valueLbl.Font                   = Enum.Font.GothamBold
        valueLbl.TextSize               = 20
        valueLbl.TextXAlignment         = Enum.TextXAlignment.Center
        valueLbl.ZIndex                 = 4
        valueLbl.Parent                 = bg

        local subLbl = Instance.new("TextLabel")
        subLbl.Size                   = UDim2.new(1, -12, 0, 14)
        subLbl.Position               = UDim2.new(0, 6, 0, 36)
        subLbl.BackgroundTransparency = 1
        subLbl.Text                   = labelText
        subLbl.TextColor3             = Color3.fromRGB(210, 215, 240)
        subLbl.Font                   = Enum.Font.Gotham
        subLbl.TextSize               = 12
        subLbl.TextXAlignment         = Enum.TextXAlignment.Center
        subLbl.ZIndex                 = 4
        subLbl.Parent                 = bg

        hv_billboard = bb
    end

    local function hv_GetWoodVolume(model)
        local total = 0
        for _, part in ipairs(model:GetChildren()) do
            if part.Name == "WoodSection" and part:IsA("BasePart") then
                total += part.Size.X * part.Size.Y * part.Size.Z
            end
        end
        return total
    end

    local function hv_FormatMoney(n)
        local s      = tostring(math.floor(n + 0.5))
        local result = ""
        local len    = #s
        for i = 1, len do
            if i > 1 and (len - i + 1) % 3 == 0 then result ..= "," end
            result ..= s:sub(i, i)
        end
        return "$" .. result
    end

    local function hv_EvaluateModel(model)
        if not model or not model.Parent then return nil end
        local parent   = model.Parent
        local mainPart = model:FindFirstChild("Main") or model:FindFirstChildWhichIsA("BasePart")
        if not mainPart then return nil end

        local bbCF, bbSize = model:GetBoundingBox()
        local topY         = bbCF.Position.Y + bbSize.Y * 0.5
        local heightOffset = math.clamp((topY - mainPart.Position.Y) + 3, 3, 12)

        if parent.Name:lower():match("treeregion") then
            local tc   = model:FindFirstChild("TreeClass")
            local cls  = tc and tc.Value or "Unknown"
            local vol  = hv_GetWoodVolume(model)
            if vol <= 0 then return nil end
            return mainPart, heightOffset,
                hv_FormatMoney(vol * (TREE_RATES[cls] or 1.0)),
                cls .. "  ·  Tree"
        end

        if parent.Name == "PlayerModels" then
            local vol = hv_GetWoodVolume(model)
            if vol <= 0 then return nil end
            local tc  = model:FindFirstChild("TreeClass")
            local cls = tc and tc.Value or nil
            return mainPart, heightOffset,
                hv_FormatMoney(vol * ((cls and PLANK_RATES[cls]) or 1.0)),
                (cls or "Unknown") .. "  ·  Plank"
        end

        if parent.Name == "LogModels" then
            local vol = hv_GetWoodVolume(model)
            if vol <= 0 then return nil end
            local tc  = model:FindFirstChild("TreeClass")
            local cls = tc and tc.Value or nil
            return mainPart, heightOffset,
                hv_FormatMoney(vol * ((cls and TREE_RATES[cls]) or 1.0)),
                (cls or "Unknown") .. "  ·  Log"
        end

        return nil
    end

    local function hv_Enable()
        if hv_hoverConn then hv_hoverConn:Disconnect() end
        hv_hoverConn = RunService.RenderStepped:Connect(function()
            local target = hv_mouse.Target
            local model  = target and target:FindFirstAncestorOfClass("Model")
            if model == hv_lastModel then return end
            hv_lastModel = model
            if not model then hv_DestroyBillboard(); return end
            local adornPart, heightOffset, valueText, subText = hv_EvaluateModel(model)
            if adornPart then
                hv_CreateBillboard(adornPart, heightOffset, valueText, subText)
            else
                hv_DestroyBillboard()
            end
        end)
    end

    local function hv_Disable()
        if hv_hoverConn then hv_hoverConn:Disconnect(); hv_hoverConn = nil end
        hv_DestroyBillboard()
    end

    Tab:CreateToggle("Hover Value Display", false, function(on)
        if on then hv_Enable() else hv_Disable() end
    end)
end

return TreeModule]], "Tree"))() end
__modules["AxeDupe"] = function() return assert(loadstring([[-- RespawnLoad.lua
local RespawnLoad = {}
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")

function RespawnLoad.Init(Tab, Library)
    if not Tab then return warn("[RespawnLoad] Tab was nil!") end
    local LocalPlayer      = Players.LocalPlayer
    local loadSaveRequests = ReplicatedStorage:FindFirstChild("LoadSaveRequests")

    local function Notify(title, body, duration)
        if Library and Library.Notify then
            Library:Notify(title, body, duration or 4)
        else
            warn(("[RespawnLoad] %s — %s"):format(title, body))
        end
    end

    -- ================================================================
    --  CAMERA FIX
    --  Called for every new character. Waits until the character is
    --  physically out of the void before touching the camera — otherwise
    --  we'd "fix" it while the character is still at Y=-100 and it
    --  would immediately look wrong again.
    --  Also hard-resets cam.CFrame so the engine doesn't slowly
    --  interpolate up from the void position.
    -- ================================================================
    local function FixCameraForChar(char)
        task.spawn(function()
            local hum = char:WaitForChild("Humanoid", 10)
            local hrp = char:WaitForChild("HumanoidRootPart", 10)
            if not hum or not hrp then return end
    
            -- Wait until the character is above void.
            local giveUp = tick() + 20
            repeat task.wait(0.15) until hrp.Position.Y > -10 or tick() > giveUp
    
            -- Wait for the save/load cycle to fully finish before touching the
            -- camera. While CurrentlySavingOrLoading is true the game is showing
            -- the plot-selection preview; resetting the camera during that window
            -- would break the preview.
            local savingFlag = LocalPlayer:FindFirstChild("CurrentlySavingOrLoading")
            if savingFlag then
                local flagDeadline = tick() + 30
                repeat task.wait(0.1) until savingFlag.Value == false or tick() > flagDeadline
            end
    
            -- 1 s buffer so the plot-selection UI has time to finish its own
            -- camera work before we override it.
            task.wait(1)
    
            local cam = workspace.CurrentCamera
            if not cam then return end
    
            LocalPlayer.CameraMode = Enum.CameraMode.Classic
            cam.CameraType         = Enum.CameraType.Custom
            cam.CameraSubject      = hum
            cam.CFrame             = CFrame.new(hrp.Position + Vector3.new(0, 3, 8))
    
            local enforceUntil = tick() + 6
            local conn
            conn = RunService.RenderStepped:Connect(function()
                if tick() > enforceUntil then conn:Disconnect(); return end
                local c   = LocalPlayer.Character
                local h   = c and c:FindFirstChildOfClass("Humanoid")
                local cam = workspace.CurrentCamera
                if not (cam and h) then return end
                if cam.CameraType ~= Enum.CameraType.Custom
                or cam.CameraSubject ~= h then
                    LocalPlayer.CameraMode = Enum.CameraMode.Classic
                    cam.CameraType         = Enum.CameraType.Custom
                    cam.CameraSubject      = h
                end
            end)
        end)
    end

    -- ================================================================
    --  CORE LOGIC
    -- ================================================================
    local function ReloadCurrentSlot()
        -- 1. Read active slot
        local slotObj = LocalPlayer:FindFirstChild("CurrentSaveSlot")
        if not slotObj or slotObj.Value == -1 then
            Notify("ERROR", "No save slot is currently loaded.", 5)
            return
        end
        local slot = slotObj.Value

        -- 2. Validate remotes
        if not loadSaveRequests then
            Notify("ERROR", "LoadSaveRequests folder not found.", 5)
            return
        end

        local RequestLoadRemote = loadSaveRequests:FindFirstChild("RequestLoad")
        local ClientMayLoad     = loadSaveRequests:FindFirstChild("ClientMayLoad")

        if not RequestLoadRemote or not ClientMayLoad then
            Notify("ERROR", "Necessary load remotes missing.", 5)
            return
        end

        -- 3. Pre-check: can we load right now?
        local success, result = pcall(function()
            return ClientMayLoad:InvokeServer(slot)
        end)

        if not success then
            Notify("ERROR", "ClientMayLoad failed to communicate.", 5)
            return
        elseif result ~= true then
            Notify("DENIED", "Server denied load request (Cooldown?).", 5)
            return
        end

        -- 4. Character validation
        local char     = LocalPlayer.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        local hrp      = char and char:FindFirstChild("HumanoidRootPart")

        if not humanoid or humanoid.Health <= 0 then
            Notify("ERROR", "Character not found or already dead.", 5)
            return
        end

        -- 5. Subscribe to CharacterAdded BEFORE killing the player.
        --    Using Connect (not Wait) means we never miss the event even if
        --    the server responds to InvokeServer while CharacterAdded is
        --    already firing. The connection covers both the auto-respawn after
        --    death and the second spawn triggered by the load itself.
        --    It self-cleans after 40 s to avoid leaking.
        local charConn
        charConn = LocalPlayer.CharacterAdded:Connect(function(newChar)
            FixCameraForChar(newChar)
        end)
        task.delay(40, function()
            if charConn then charConn:Disconnect() end
        end)

        Notify("RELOADING", "Permissions valid. Reloading slot " .. slot .. "…", 4)

        -- 6. Drop into void and wait for death
        hrp.CFrame = CFrame.new(hrp.Position.X, -100, hrp.Position.Z)
        humanoid.Died:Wait()

        -- 7. Fire RequestLoad
        local ok, err = pcall(function()
            RequestLoadRemote:InvokeServer(slot)
        end)

        if not ok then
            Notify("FAILED", "RequestLoad failed: " .. tostring(err), 6)
            return
        end

        Notify("SUCCESS", "Slot " .. slot .. " reloaded!", 5)
    end

    -- ================================================================
    --  UI
    -- ================================================================
    Tab:CreateSection("Axe Duplication")
    Tab:CreateAction("Inventory Axes", "Dupe", function()
        task.spawn(ReloadCurrentSlot)
    end)
end

return RespawnLoad
]], "AxeDupe"))() end
__modules["Duplication"] = function() return assert(loadstring([[local Duplication = {}

function Duplication.Init(Tab, LOT)
    local Players           = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LocalPlayer       = Players.LocalPlayer

    -- ===========================
    -- REMOTES
    -- ===========================
    local ClientPlacedStructure = nil
    local ClientPlacedWire      = nil

    task.spawn(function()
        ClientPlacedStructure = ReplicatedStorage
            :WaitForChild("PlaceStructure")
            :WaitForChild("ClientPlacedStructure")
        ClientPlacedWire = ReplicatedStorage
            :WaitForChild("PlaceStructure")
            :WaitForChild("ClientPlacedWire")
    end)

    -- ===========================
    -- STATE
    -- ===========================
    local env = getgenv and getgenv() or _G
    env.DupeSource     = nil
    env.DupeTarget     = nil
    env.DupeTimeout    = 5
    env.PM_Connections = env.PM_Connections or {}
    env.DupeItems = {
        Structures = false,
        Blueprints = false,
        Furniture  = false,
        Wires      = false,
    }

    local sourceItemCounts = { Structures = 0, Furniture = 0, Wires = 0 }

    local UpdateButtonState
    local isProcessing = false
    local shouldStop   = false

    -- ===========================
    -- HELPERS
    -- ===========================
    local function GetPlayerNames()
        local names = {}
        for _, p in pairs(Players:GetPlayers()) do
            table.insert(names, p.Name)
        end
        return names
    end

    local function GetPropertyModel(playerName)
        local propertiesFolder = workspace:FindFirstChild("Properties")
        if not propertiesFolder then
            warn("[Dupe] workspace.Properties not found")
            return nil
        end
        for _, propertyModel in pairs(propertiesFolder:GetChildren()) do
            local owner = propertyModel:FindFirstChild("Owner")
            if owner and owner.Value and owner.Value.Name == playerName then
                return propertyModel
            end
        end
        warn("[Dupe] No property found for: " .. playerName)
        return nil
    end

    local function GetPlotCFrame(propertyModel)
        if propertyModel.PrimaryPart then
            return propertyModel.PrimaryPart.CFrame
        end
        return propertyModel:GetPivot()
    end

    local function GetPlotSquareCount(playerName)
        local propertiesFolder = workspace:FindFirstChild("Properties")
        if not propertiesFolder then return 0 end
        for _, propertyModel in pairs(propertiesFolder:GetChildren()) do
            local owner = propertyModel:FindFirstChild("Owner")
            if owner and owner.Value and owner.Value.Name == playerName then
                local count = 0
                for _, obj in pairs(propertyModel:GetDescendants()) do
                    if obj.Name == "Square" or obj.Name == "OriginSquare" then
                        count = count + 1
                    end
                end
                return count
            end
        end
        return 0
    end

    local function GetPlayerStructures(playerName)
        local playerModels = workspace:FindFirstChild("PlayerModels")
        if not playerModels then return {} end
        local results = {}
        for _, model in pairs(playerModels:GetChildren()) do
            local typeVal = model:FindFirstChild("Type")
            if not typeVal or typeVal.Value ~= "Structure" then continue end
            if model:FindFirstChild("PurchasedBoxItemName") then continue end
            local ownerFolder = model:FindFirstChild("Owner")
            local ownerString = ownerFolder and ownerFolder:FindFirstChild("OwnerString")
            if ownerString and ownerString.Value == playerName then
                table.insert(results, model)
            end
        end
        return results
    end

    local function GetPlayerFurniture(playerName)
        local playerModels = workspace:FindFirstChild("PlayerModels")
        if not playerModels then return {} end
        local results = {}
        for _, model in pairs(playerModels:GetChildren()) do
            local typeVal = model:FindFirstChild("Type")
            if not typeVal or typeVal.Value ~= "Furniture" then continue end
            if model:FindFirstChild("PurchasedBoxItemName") then continue end
            local ownerFolder = model:FindFirstChild("Owner")
            local ownerString = ownerFolder and ownerFolder:FindFirstChild("OwnerString")
            if ownerString and ownerString.Value == playerName then
                table.insert(results, model)
            end
        end
        return results
    end

    local function GetPlayerWires(playerName)
        local playerModels = workspace:FindFirstChild("PlayerModels")
        if not playerModels then return {} end
        local results = {}
        for _, model in pairs(playerModels:GetChildren()) do
            local typeVal = model:FindFirstChild("Type")
            if not typeVal or typeVal.Value ~= "Wire" then continue end
            if model:FindFirstChild("PurchasedBoxItemName") then continue end
            local ownerFolder = model:FindFirstChild("Owner")
            local ownerString = ownerFolder and ownerFolder:FindFirstChild("OwnerString")
            if ownerString and ownerString.Value == playerName then
                table.insert(results, model)
            end
        end
        return results
    end

    local function GetStructureCFrame(model)
        return (model:FindFirstChild("MainCFrame")         and model.MainCFrame.Value)
            or (model:FindFirstChild("BuildDependentWood") and model.BuildDependentWood.CFrame)
            or (model.PrimaryPart                          and model.PrimaryPart.CFrame)
    end

    local function GetItemName(model)
        local obj = model:FindFirstChild("ItemName")
        if obj then return tostring(obj.Value) end
        return model.Name
    end

    local function RefreshSourceCounts()
        if not env.DupeSource then
            sourceItemCounts = { Structures = 0, Furniture = 0, Wires = 0 }
            return
        end
        sourceItemCounts.Structures = #GetPlayerStructures(env.DupeSource)
        sourceItemCounts.Furniture  = #GetPlayerFurniture(env.DupeSource)
        sourceItemCounts.Wires      = #GetPlayerWires(env.DupeSource)
    end

    local function AnyToggleEnabled()
        for _, v in pairs(env.DupeItems) do
            if v then return true end
        end
        return false
    end

    local function SourceHasEnabledItems()
        local map = {
            Structures = "Structures",
            Furniture  = "Furniture",
            Wires      = "Wires",
        }
        for key, countKey in pairs(map) do
            if env.DupeItems[key] and sourceItemCounts[countKey] > 0 then
                return true
            end
        end
        return false
    end

    -- ===========================
    -- EVENT-DRIVEN PLACEMENT
    -- ===========================
    local function PlaceWithConfirmation(fireFunc, matchFunc)
        local playerModels = workspace:FindFirstChild("PlayerModels")
        if not playerModels then return false end

        local success = false

        local conn = playerModels.ChildAdded:Connect(function(model)
            if success then return end
            task.wait()
            if matchFunc(model) then
                success = true
            end
        end)

        local deadline = tick() + env.DupeTimeout
        repeat
            fireFunc()
            task.wait(0.3)
        until success or tick() >= deadline or shouldStop

        conn:Disconnect()
        return success
    end

    local function MatchStructure(model, targetName, itemName)
        local typeVal = model:FindFirstChild("Type")
        if not typeVal or typeVal.Value ~= "Structure" then return false end
        if model:FindFirstChild("PurchasedBoxItemName") then return false end
        local ownerFolder = model:FindFirstChild("Owner")
        local ownerString = ownerFolder and ownerFolder:FindFirstChild("OwnerString")
        if not ownerString or ownerString.Value ~= targetName then return false end
        return GetItemName(model) == itemName
    end

    local function MatchFurniture(model, targetName, itemName)
        local typeVal = model:FindFirstChild("Type")
        if not typeVal or typeVal.Value ~= "Furniture" then return false end
        if model:FindFirstChild("PurchasedBoxItemName") then return false end
        local ownerFolder = model:FindFirstChild("Owner")
        local ownerString = ownerFolder and ownerFolder:FindFirstChild("OwnerString")
        if not ownerString or ownerString.Value ~= targetName then return false end
        return GetItemName(model) == itemName
    end

    local function MatchWire(model, targetName, itemName)
        local typeVal = model:FindFirstChild("Type")
        if not typeVal or typeVal.Value ~= "Wire" then return false end
        if model:FindFirstChild("PurchasedBoxItemName") then return false end
        local ownerFolder = model:FindFirstChild("Owner")
        local ownerString = ownerFolder and ownerFolder:FindFirstChild("OwnerString")
        if not ownerString or ownerString.Value ~= targetName then return false end
        return GetItemName(model) == itemName
    end

    -- ===========================
    -- UI — BASE DUPLICATION
    -- ===========================
    Tab:CreateSection("BASE DUPLICATION")

    local SourceDropdown = Tab:CreateDropdown(
        "Base To Duplicate:", GetPlayerNames(), "Select Owner",
        function(sel)
            env.DupeSource = sel
            RefreshSourceCounts()
            if UpdateButtonState then UpdateButtonState() end
        end
    )
    local TargetDropdown = Tab:CreateDropdown(
        "Base To Drop To:", GetPlayerNames(), "Select Target",
        function(sel)
            env.DupeTarget = sel
            if UpdateButtonState then UpdateButtonState() end
        end
    )

    local function RefreshLists()
        local names = GetPlayerNames()
        SourceDropdown:SetOptions(names)
        TargetDropdown:SetOptions(names)
    end
    table.insert(env.PM_Connections, Players.PlayerAdded:Connect(RefreshLists))
    table.insert(env.PM_Connections, Players.PlayerRemoving:Connect(RefreshLists))

    local StartButton

    StartButton = Tab:CreateAction("Duplicate", "Start", function()
        if isProcessing then
            shouldStop = true
            StartButton:SetText("Stopping...")
            StartButton:SetDisabled(true)
            return
        end

        if not ClientPlacedStructure then
            warn("[Dupe] Remotes not ready yet, please wait a moment.")
            return
        end

        isProcessing = true
        shouldStop   = false
        StartButton:SetText("Stop")

        local sourceProp = GetPropertyModel(env.DupeSource)
        local targetProp = GetPropertyModel(env.DupeTarget)

        if not sourceProp or not targetProp then
            warn("[Dupe] Could not resolve one or both plots. Aborting.")
            isProcessing = false
            StartButton:SetText("Start")
            UpdateButtonState()
            return
        end

        local sourcePlotCF = GetPlotCFrame(sourceProp)
        local targetPlotCF = GetPlotCFrame(targetProp)

        local placed, failed, timedOut = 0, 0, 0

        -- ---- STRUCTURES ----
        if env.DupeItems.Structures and not shouldStop then
            local structures = GetPlayerStructures(env.DupeSource)
            print(("[Dupe] Processing %d structures"):format(#structures))

            local jobs = {}
            for _, model in ipairs(structures) do
                local structCF = GetStructureCFrame(model)
                if not structCF then
                    warn("[Dupe] Skipping structure (no CFrame): " .. model.Name)
                    failed = failed + 1
                    continue
                end
                table.insert(jobs, {
                    model     = model,
                    targetCF  = targetPlotCF * (sourcePlotCF:Inverse() * structCF),
                    itemName  = GetItemName(model),
                    woodClass = model:FindFirstChild("BlueprintWoodClass")
                                and model.BlueprintWoodClass.Value or nil,
                })
            end

            for _, job in ipairs(jobs) do
                if shouldStop then break end
                local success = PlaceWithConfirmation(
                    function()
                        ClientPlacedStructure:FireServer(
                            job.itemName, job.targetCF, LocalPlayer, job.woodClass, job.model, true
                        )
                    end,
                    function(m) return MatchStructure(m, env.DupeTarget, job.itemName) end
                )
                if success then
                    placed = placed + 1
                    print(("[Dupe] Placed structure: %s (%d done)"):format(job.itemName, placed))
                else
                    timedOut = timedOut + 1
                    warn(("[Dupe] Timed out structure: %s"):format(job.itemName))
                end
            end
        end

        -- ---- FURNITURE ----
        if env.DupeItems.Furniture and not shouldStop then
            local furniture = GetPlayerFurniture(env.DupeSource)
            print(("[Dupe] Processing %d furniture"):format(#furniture))

            local jobs = {}
            for _, model in ipairs(furniture) do
                table.insert(jobs, {
                    model    = model,
                    targetCF = targetPlotCF * (sourcePlotCF:Inverse() * model:GetPivot()),
                    itemName = GetItemName(model),
                })
            end

            for _, job in ipairs(jobs) do
                if shouldStop then break end
                local success = PlaceWithConfirmation(
                    function()
                        ClientPlacedStructure:FireServer(
                            job.itemName, job.targetCF, LocalPlayer, false, job.model, true
                        )
                    end,
                    function(m) return MatchFurniture(m, env.DupeTarget, job.itemName) end
                )
                if success then
                    placed = placed + 1
                    print(("[Dupe] Placed furniture: %s (%d done)"):format(job.itemName, placed))
                else
                    timedOut = timedOut + 1
                    warn(("[Dupe] Timed out furniture: %s"):format(job.itemName))
                end
            end
        end

        -- ---- WIRES ----
        if env.DupeItems.Wires and not shouldStop then
            local wires = GetPlayerWires(env.DupeSource)
            print(("[Dupe] Processing %d wires"):format(#wires))

            local jobs = {}
            for _, model in ipairs(wires) do
                local wireCF = GetStructureCFrame(model)
                if not wireCF then
                    warn("[Dupe] Skipping wire (no CFrame): " .. model.Name)
                    failed = failed + 1
                    continue
                end
                table.insert(jobs, {
                    model    = model,
                    targetCF = targetPlotCF * (sourcePlotCF:Inverse() * wireCF),
                    itemName = GetItemName(model),
                })
            end

            for _, job in ipairs(jobs) do
                if shouldStop then break end
                local success = PlaceWithConfirmation(
                    function()
                        ClientPlacedWire:FireServer(
                            job.itemName, job.targetCF, LocalPlayer, job.model, true
                        )
                    end,
                    function(m) return MatchWire(m, env.DupeTarget, job.itemName) end
                )
                if success then
                    placed = placed + 1
                    print(("[Dupe] Placed wire: %s (%d done)"):format(job.itemName, placed))
                else
                    timedOut = timedOut + 1
                    warn(("[Dupe] Timed out wire: %s"):format(job.itemName))
                end
            end
        end

        if shouldStop then
            print(("[Dupe] Stopped early — placed %d, timed out %d, failed %d")
                :format(placed, timedOut, failed))
        else
            print(("[Dupe] Complete — placed %d, timed out %d, failed %d")
                :format(placed, timedOut, failed))
        end

        isProcessing = false
        shouldStop   = false
        StartButton:SetDisabled(false)
        StartButton:SetText("Start")
        UpdateButtonState()
    end)

    UpdateButtonState = function()
        if isProcessing then return end
        local plotsMatch = false
        if env.DupeSource and env.DupeTarget then
            local sourceSquares = GetPlotSquareCount(env.DupeSource)
            local targetSquares = GetPlotSquareCount(env.DupeTarget)
            plotsMatch = sourceSquares > 0
                      and targetSquares >= sourceSquares
            if not plotsMatch and env.DupeSource ~= env.DupeTarget then
                print(("[Dupe] Plot too small — %s has %d squares, %s only has %d squares")
                    :format(env.DupeSource, sourceSquares, env.DupeTarget, targetSquares))
            end
        end
        local ready = env.DupeSource ~= nil
                   and env.DupeTarget ~= nil
                   and env.DupeSource ~= env.DupeTarget
                   and AnyToggleEnabled()
                   and SourceHasEnabledItems()
                   and plotsMatch
        StartButton:SetDisabled(not ready)
    end

    StartButton:SetDisabled(true)

    -- ===========================
    -- UI — OBJECT SELECTION
    -- ===========================
    Tab:CreateSection("Object Selection")

    Tab:CreateToggle("Structures", false, function(s)
        env.DupeItems.Structures = s
        UpdateButtonState()
    end)

    local BlueprintToggle = Tab:CreateToggle("Blueprints", false, function(s)
        env.DupeItems.Blueprints = s
        UpdateButtonState()
    end)
    BlueprintToggle:SetDisabled(true)
    BlueprintToggle:AddTooltip("Blueprints are not supported yet.")

    Tab:CreateToggle("Furniture", false, function(s)
        env.DupeItems.Furniture = s
        UpdateButtonState()
    end)

    Tab:CreateToggle("Wires", false, function(s)
        env.DupeItems.Wires = s
        UpdateButtonState()
    end)

    -- ===========================
    -- UI — SETTINGS
    -- ===========================
    Tab:CreateSection("Settings")
    local Notice = Tab:CreateInfoBox()
    Notice:AddText("⚠ PLEASE READ!", {
        Bold = true,
        Size = 14,
    })
    Notice:AddDivider()
    Notice:AddText(
        "This is in its early developement phase and doesnt currently 'dupe' anything. " ..
        "It will only move the objects from one plot to another. Im currently working " ..
        "on some methods to improve this process.",
        {
            Size    = 13,
            Opacity = 0.80,
            Italic  = true,
            Wrap    = true,
        }
    )
    Tab:CreateSlider("Place Timeout (s)", 1, 10, 3, function(val)
        env.DupeTimeout = val
    end)
end

return Duplication
]], "Duplication"))() end
__modules["Build"] = function() return assert(loadstring([[local BuildModule = {}

function BuildModule.Init(Tab, LOT)
    local UIS     = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local CoreGui = game:GetService("CoreGui")
    local Player  = Players.LocalPlayer
    local Mouse   = Player:GetMouse()

    -- ══════════════════════════════════════════════════════════
    -- STATE
    -- ══════════════════════════════════════════════════════════
    local selectedClass  = nil
    local allPlanks      = {}
    local filteredPlanks = {}
    local yMin, yMax     = 0, 0
    local filterMin      = 1      -- low end of the Y-size range filter
    local filterMax      = 1.5    -- high end of the Y-size range filter
    local plankIndex     = 1

    local pickingMode    = false
    local pickConn       = nil
    local bpClickMode    = false
    local bpClickConn    = nil

    -- Selection outline tracking
    local selectionBoxes     = {}
    local outlineConnections = {}

    local selectBtn, RangeSlider, bpClickToggle, autoFillBtn

    -- ══════════════════════════════════════════════════════════
    -- OUTLINE MANAGEMENT
    -- ══════════════════════════════════════════════════════════
    local function ClearOutlines()
        for _, conn in ipairs(outlineConnections) do conn:Disconnect() end
        outlineConnections = {}
        for _, box in ipairs(selectionBoxes) do
            if box and box.Parent then box:Destroy() end
        end
        selectionBoxes = {}
    end

    local function RefreshBPStatus() end -- forward declaration, defined below

    local function DrawOutlines()
        ClearOutlines()
        for _, entry in ipairs(filteredPlanks) do
            if entry.part and entry.part.Parent then
                local box               = Instance.new("SelectionBox")
                box.Adornee             = entry.part
                box.Color3              = Color3.fromRGB(74, 120, 255)
                box.LineThickness       = 0.03
                box.SurfaceColor3       = Color3.fromRGB(74, 120, 255)
                box.SurfaceTransparency = 0.75
                box.Parent              = CoreGui
                table.insert(selectionBoxes, box)

                local conn = entry.part.Destroying:Connect(function()
                    box:Destroy()
                    for i, e in ipairs(filteredPlanks) do
                        if e.part == entry.part then table.remove(filteredPlanks, i); break end
                    end
                    for i, e in ipairs(allPlanks) do
                        if e.part == entry.part then table.remove(allPlanks, i); break end
                    end
                    plankIndex = math.max(1, math.min(plankIndex, #filteredPlanks))
                    RefreshBPStatus()
                end)
                table.insert(outlineConnections, conn)
            end
        end
    end

    -- ══════════════════════════════════════════════════════════
    -- HELPERS
    -- ══════════════════════════════════════════════════════════
    local function IsOwned(model)
        local owner = model:FindFirstChild("Owner")
        if not owner then return false end
        local ownerStr = owner:FindFirstChild("OwnerString")
        return ownerStr and ownerStr:IsA("StringValue") and ownerStr.Value == Player.Name
    end

    local function GetPlayerModels()
        return workspace:FindFirstChild("PlayerModels")
    end

    local function ResolveModel(target)
        local pm = GetPlayerModels()
        if not pm or not target then return nil end
        local current = target
        while current and current.Parent ~= pm do
            current = current.Parent
            if not current or current == workspace then return nil end
        end
        return (current and current:IsA("Model")) and current or nil
    end

    local function IsBlueprint(model)
        if not model or not model:IsA("Model") then return false end
        if not IsOwned(model) then return false end
        local typeVal = model:FindFirstChild("Type")
        return typeVal and typeVal:IsA("StringValue") and typeVal.Value == "Blueprint"
    end

    local function GetBlueprintCenter(model)
        if model.PrimaryPart then return model.PrimaryPart.Position end
        local sum, count = Vector3.new(0, 0, 0), 0
        for _, part in ipairs(model:GetDescendants()) do
            if part:IsA("BasePart") then
                sum   = sum + part.Position
                count = count + 1
            end
        end
        return count > 0 and (sum / count) or Vector3.new(0, 0, 0)
    end

    local function ScanPlanksForClass(className)
        local pm, result = GetPlayerModels(), {}
        if not pm or not className then return result end
        for _, model in ipairs(pm:GetChildren()) do
            if model.Name == "Plank" and model:IsA("Model") and IsOwned(model) then
                local tc = model:FindFirstChild("TreeClass")
                if tc and tc:IsA("StringValue") and tc.Value == className then
                    local part = model:FindFirstChild("Main") or model:FindFirstChildWhichIsA("BasePart")
                    if part and part:IsA("BasePart") then
                        table.insert(result, {
                            model = model,
                            part  = part,
                            sizeY = math.floor(part.Size.Y * 10 + 0.5) / 10,
                        })
                    end
                end
            end
        end
        return result
    end

    local function GetOwnedBlueprints()
        local pm, result = GetPlayerModels(), {}
        if not pm then return result end
        for _, model in ipairs(pm:GetChildren()) do
            if IsBlueprint(model) then table.insert(result, model) end
        end
        return result
    end

    -- Now filters on BOTH ends: sizeY must fall within [filterMin, filterMax]
    local function ApplyYFilter()
        filteredPlanks = {}
        for _, e in ipairs(allPlanks) do
            if e.sizeY >= filterMin and e.sizeY <= filterMax then
                table.insert(filteredPlanks, e)
            end
        end
        plankIndex = 1
        DrawOutlines()
    end

    -- ══════════════════════════════════════════════════════════
    -- PLANK SELECTION
    -- ══════════════════════════════════════════════════════════
    Tab:CreateSection("Plank Selection")

    local function StopPickingMode()
        pickingMode = false
        if pickConn then pickConn:Disconnect(); pickConn = nil end
        if selectBtn then selectBtn:SetText("Start") end
    end

    local function OnPlankPicked(target)
        local model = ResolveModel(target)
        if not model or model.Name ~= "Plank" or not IsOwned(model) then
            StopPickingMode(); return
        end
        local tc = model:FindFirstChild("TreeClass")
        if not tc or not tc:IsA("StringValue") or tc.Value == "" then
            StopPickingMode(); return
        end

        selectedClass = tc.Value
        allPlanks     = ScanPlanksForClass(selectedClass)

        if #allPlanks > 0 then
            yMin, yMax = math.huge, -math.huge
            for _, e in ipairs(allPlanks) do
                if e.sizeY < yMin then yMin = e.sizeY end
                if e.sizeY > yMax then yMax = e.sizeY end
            end
            -- Snap both filter bounds to the actual scanned range and
            -- push the update to the range slider UI in one call
            filterMin = yMin
            filterMax = yMax
            if RangeSlider then RangeSlider:SetValue(yMin, yMax) end
        else
            yMin, yMax = 0, 0
            filterMin, filterMax = 0, 0
            if RangeSlider then RangeSlider:SetValue(0, 0) end
        end

        ApplyYFilter()
        RefreshBPStatus()
        StopPickingMode()
    end

    local function StartPickingMode()
        if pickingMode then StopPickingMode(); return end
        pickingMode = true
        if selectBtn then selectBtn:SetText("Click a Plank...") end

        pickConn = UIS.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
            OnPlankPicked(Mouse.Target)
        end)
    end

    selectBtn = Tab:CreateAction("Select Plank Type", "Start", StartPickingMode)

    -- ══════════════════════════════════════════════════════════
    -- SIZE FILTER  –  range slider (min Y — max Y)
    -- ══════════════════════════════════════════════════════════
    RangeSlider = Tab:CreateRangeSlider("Y Size Range", 0, 10, 1, 1.5, function(low, high)
        filterMin = low
        filterMax = high
        if #allPlanks == 0 then return end
        ApplyYFilter()
        RefreshBPStatus()
    end, 1)

    -- ══════════════════════════════════════════════════════════
    -- BLUEPRINT FILL
    -- ══════════════════════════════════════════════════════════
    Tab:CreateSection("Blueprint Fill")

    local function StopBPClickMode()
        bpClickMode = false
        if bpClickConn then bpClickConn:Disconnect(); bpClickConn = nil end
        if bpClickToggle then bpClickToggle:SetState(false) end
    end

    local function OnBlueprintClicked(target)
        local model = ResolveModel(target)
        if not IsBlueprint(model) then return end
        if #filteredPlanks == 0 then
            warn("[Build] No filtered planks to place."); return
        end
        local entry = filteredPlanks[plankIndex]
        if not entry or not entry.part or not entry.part.Parent then
            plankIndex = (plankIndex % #filteredPlanks) + 1
            RefreshBPStatus(); return
        end
        task.spawn(function()
            if LOT then LOT.TeleportObjectTo(entry.part, CFrame.new(GetBlueprintCenter(model))) end
        end)
        plankIndex = (plankIndex % #filteredPlanks) + 1
        RefreshBPStatus()
    end

    local function StartBPClickMode()
        bpClickMode = true
        bpClickConn = UIS.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
            if not bpClickMode then return end
            OnBlueprintClicked(Mouse.Target)
        end)
    end

    bpClickToggle = Tab:CreateToggle("Click to Fill", false, function(state)
        if state then
            if #filteredPlanks == 0 then
                warn("[Build] Select and filter planks first.")
                bpClickToggle:SetState(false)
                return
            end
            RefreshBPStatus()
            StartBPClickMode()
        else
            StopBPClickMode()
        end
    end)

    local fillCancelled = false
    autoFillBtn = Tab:CreateAction("Fill All Blueprints", "Start", function()
        if autoFillBtn and autoFillBtn._running then
            fillCancelled = true
            return
        end

        if not LOT then warn("[Build] LOT not available.") return end
        if LOT.IsBusy() then warn("[Build] LOT busy.") return end
        if #filteredPlanks == 0 then warn("[Build] No filtered planks selected.") return end

        local blueprints = GetOwnedBlueprints()
        if #blueprints == 0 then warn("[Build] No owned blueprints found.") return end

        fillCancelled = false
        autoFillBtn._running = true
        autoFillBtn:SetText("Stop")

        task.spawn(function()
            for i, blueprint in ipairs(blueprints) do
                if fillCancelled then break end
                local entry = filteredPlanks[((i - 1) % #filteredPlanks) + 1]
                if not entry or not entry.part or not entry.part.Parent then continue end
                LOT.TeleportObjectTo(entry.part, CFrame.new(GetBlueprintCenter(blueprint)))
                LOT.WaitForBatch()
                task.wait(0.05)
            end
            autoFillBtn._running = false
            autoFillBtn:SetText("Start")
        end)
    end)

    -- ══════════════════════════════════════════════════════════
    -- LONG WIRE
    -- ══════════════════════════════════════════════════════════
    Tab:CreateSection("Other")

    local undoStack  = {}
    local btoolsConn = nil

    Tab:CreateToggle("BTools", false, function(state)
        if state then
            undoStack = {}

            local deleteTool            = Instance.new("Tool")
            deleteTool.Name             = "Delete"
            deleteTool.ToolTip          = "Click an object to delete it"
            deleteTool.RequiresHandle   = false
            deleteTool.CanBeDropped     = false
            deleteTool.Parent           = Player.Backpack

            local undoTool              = Instance.new("Tool")
            undoTool.Name               = "Undo"
            undoTool.ToolTip            = "Click to undo last deletion"
            undoTool.RequiresHandle     = false
            undoTool.CanBeDropped       = false
            undoTool.Parent             = Player.Backpack

            local deleteConn = deleteTool.Activated:Connect(function()
                local target = Mouse.Target
                if not target or not target:IsA("BasePart") then return end
                if target:IsDescendantOf(Player.Character or Instance.new("Folder")) then return end
                if target == workspace.Terrain then return end
                if target.Parent == workspace then return end

                table.insert(undoStack, {
                    part   = target,
                    parent = target.Parent,
                    cframe = target.CFrame,
                })
                target.Parent = nil
                print(("[BTools] Deleted '%s' — %d item(s) in undo stack"):format(target.Name, #undoStack))
            end)

            local undoConn = undoTool.Activated:Connect(function()
                if #undoStack == 0 then
                    print("[BTools] Nothing to undo.")
                    return
                end
                local entry = table.remove(undoStack, #undoStack)
                if entry.part then
                    entry.part.Parent = entry.parent
                    if entry.part:IsA("BasePart") then
                        entry.part.CFrame = entry.cframe
                    end
                    print(("[BTools] Restored '%s' — %d item(s) remaining"):format(entry.part.Name, #undoStack))
                end
            end)

            btoolsConn = {
                deleteConn = deleteConn,
                undoConn   = undoConn,
                deleteTool = deleteTool,
                undoTool   = undoTool,
            }

        else
            if btoolsConn then
                btoolsConn.deleteConn:Disconnect()
                btoolsConn.undoConn:Disconnect()

                local char = Player.Character
                if char then
                    local equipped = char:FindFirstChildOfClass("Tool")
                    if equipped and (equipped == btoolsConn.deleteTool or equipped == btoolsConn.undoTool) then
                        equipped.Parent = Player.Backpack
                    end
                end

                btoolsConn.deleteTool:Destroy()
                btoolsConn.undoTool:Destroy()
                btoolsConn = nil
            end

            for i = #undoStack, 1, -1 do
                local entry = undoStack[i]
                if entry.part then
                    entry.part.Parent = entry.parent
                    if entry.part:IsA("BasePart") then
                        entry.part.CFrame = entry.cframe
                    end
                end
            end
            undoStack = {}
        end
    end)

    RefreshBPStatus()
end

return BuildModule
]], "Build"))() end
__modules["Shop"] = function() return assert(loadstring([=[-- [[ SHOP MODULE ]] --
-- Designed for Dynxe LT2 UI Engine

local ShopModule = {}

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui        = game:GetService("StarterGui")
local Player            = Players.LocalPlayer

-- ┌─────────────────────────────────────────────────────────────────┐
-- │                     LOT REFERENCE                               │
-- └─────────────────────────────────────────────────────────────────┘
local _LOT = nil

function ShopModule.SetLOT(lot)
    _LOT = lot
end

-- ┌─────────────────────────────────────────────────────────────────┐
-- │                  MODULE-LEVEL SHARED STATE                      │
-- │  _ShopItems   — item list loaded on Init, exposed via API.      │
-- │  _cachedFunds — last known balance, refreshed on a background   │
-- │                 poll so UI updates don't block on remotes.      │
-- └─────────────────────────────────────────────────────────────────┘
local _ShopItems   = nil
local _cachedFunds = nil

-- ============================================================
-- SETTINGS
-- ============================================================
-- Quick Purchase: if true and a purchase lands in under 1 second,
-- the return TP skips LOT and directly sets the item's CFrame.
-- This is faster but may cause failures if the server hasn't fully
-- handed off ownership yet. Toggle via the Settings UI section.
local _quickPurchase = false

-- Force Respawn on Stuck NPC: enables NuclearReset as the final escalation
-- step when HardResetNPC fails to free a pinned ChattingPlayer. Off by
-- default — toggle via the Settings UI section.
local _allowNuclearReset = false

-- ┌─────────────────────────────────────────────────────────────────┐
-- │                     NPC / REMOTE SETUP                          │
-- └─────────────────────────────────────────────────────────────────┘
local NPCs = {
    Thom    = workspace.Stores.WoodRUs.Thom,
    Corey   = workspace.Stores.FurnitureStore.Corey,
    Jenny   = workspace.Stores.CarStore.Jenny,
    Bob     = workspace.Stores.ShackShop.Bob,
    Timothy = workspace.Stores.FineArt.Timothy,
    Lincoln = workspace.Stores.LogicStore.Lincoln,
}

local Remote      = ReplicatedStorage.NPCDialog.PlayerChatted
local PromptChat  = ReplicatedStorage.NPCDialog.PromptChat
local Interact    = ReplicatedStorage.Interaction.ClientInteracted
local DragRemote  = ReplicatedStorage.Interaction:WaitForChild("ClientIsDragging")

-- ┌─────────────────────────────────────────────────────────────────┐
-- │                   PER-STORE CONFIGURATION                       │
-- └─────────────────────────────────────────────────────────────────┘
local StoreConfigs = {
    WoodRUs = {
        NPCName     = "Thom",
        PlayerBuyCF = CFrame.new(262.1, 3.2,  64.8),
    },
    FurnitureStore = {
        NPCName     = "Corey",
        PlayerBuyCF = CFrame.new(481.4, 3.2, -1712.5),
    },
    CarStore = {
        NPCName     = "Jenny",
        PlayerBuyCF = CFrame.new(524.9, 3.2, -1466.6),
    },
    ShackShop = {
        NPCName     = "Bob",
        PlayerBuyCF = CFrame.new(256.7, 8.4, -2546.7),
    },
    FineArt = {
        NPCName     = "Timothy",
        PlayerBuyCF = CFrame.new(5232.4, -166.0, 737.3),
    },
    LogicStore = {
        NPCName     = "Lincoln",
        PlayerBuyCF = CFrame.new(4598.4, 7.0, -778.4),
    },
}

-- ┌─────────────────────────────────────────────────────────────────┐
-- │              COUNTER-BASED ITEM DROP CF RESOLVER                │
-- └─────────────────────────────────────────────────────────────────┘
local CounterCache = {}

local function GetCounterPart(storeName)
    if CounterCache[storeName] ~= nil then
        return CounterCache[storeName] or nil
    end

    local config = StoreConfigs[storeName]
    if not config then CounterCache[storeName] = false; return nil end

    local npc   = NPCs[config.NPCName]
    local store = npc and npc.Parent
    if not store then CounterCache[storeName] = false; return nil end

    local counter = store:FindFirstChild("Counter")
    if not counter then CounterCache[storeName] = false; return nil end

    local part
    if counter:IsA("BasePart") then
        part = counter
    elseif counter:IsA("Model") then
        part = counter.PrimaryPart
        if not part then
            for _, desc in ipairs(counter:GetDescendants()) do
                if desc:IsA("BasePart") then part = desc; break end
            end
        end
    end

    CounterCache[storeName] = part or false
    return part or nil
end

local function ComputeDropCF(storeName, mainPart)
    local counterPart = GetCounterPart(storeName)
    if not counterPart then return nil end

    local up         = counterPart.CFrame.UpVector
    local surfaceTop = counterPart.Position + up * (counterPart.Size.Y / 2)
    local itemRise   = mainPart and (mainPart.Size.Y / 2) or 0
    return CFrame.new(surfaceTop + up * (itemRise + 0.05))
end

-- ┌─────────────────────────────────────────────────────────────────┐
-- │                       FUNDS REMOTE                              │
-- └─────────────────────────────────────────────────────────────────┘
local GetFundsRemote = nil

local function FindRemoteRecursive(root, name)
    for _, child in ipairs(root:GetDescendants()) do
        if child.Name == name and child:IsA("RemoteFunction") then
            return child
        end
    end
    return nil
end

local function FetchFunds()
    if not GetFundsRemote then
        GetFundsRemote = FindRemoteRecursive(ReplicatedStorage, "GetFunds")
        if not GetFundsRemote then return nil end
    end
    local ok, result = pcall(function()
        return GetFundsRemote:InvokeServer()
    end)
    if ok and type(result) == "number" then return result end
    return nil
end

-- ┌─────────────────────────────────────────────────────────────────┐
-- │                      NPC ID FETCHING                            │
-- └─────────────────────────────────────────────────────────────────┘
local NPCIDs = {}

local function FetchNPCID(npcName)
    local npc = NPCs[npcName]
    if not npc then return nil end

    if not npc:FindFirstChild("Dialog") then
        Instance.new("Dialog", npc)
    end

    local lastData
    local conn = PromptChat.OnClientEvent:Connect(function(active, chatData)
        -- CRITICAL: filter by NPC Character and only accept "open" events.
        -- The server's 1Hz proximity loop fires PromptChat for any nearby
        -- NPC. Without this filter, lastData can be set to a DIFFERENT
        -- NPC's data during our 5s wait — poisoning the ID cache and
        -- sending all future EndChats to the wrong NPC. That cached-wrong-ID
        -- state survives until rejoin.
        if active and chatData and chatData.Character == npc then
            lastData = chatData
        end
    end)

    pcall(function() PromptChat:FireServer(true, npc, npc.Dialog) end)
    local t = tick()
    repeat task.wait(0.05) until lastData or tick() - t > 5
    conn:Disconnect()

    pcall(function() PromptChat:FireServer(false, npc, npc.Dialog) end)
    task.wait(0.2)

    if lastData and lastData.Character == npc and lastData.ID then
        NPCIDs[npcName] = lastData.ID
        return lastData.ID
    end

    warn("[Shop] Failed to fetch ID for NPC:", npcName)
    return nil
end

local function EnsureNPCID(npcName)
    if NPCIDs[npcName] then return NPCIDs[npcName] end
    return FetchNPCID(npcName)
end

local function InvalidateNPCID(npcName)
    NPCIDs[npcName] = nil
end

local function FetchAllNPCIDs()
    for name, _ in pairs(NPCs) do
        if not NPCIDs[name] then
            FetchNPCID(name)
            task.wait(0.15)
        end
    end
end

-- ┌─────────────────────────────────────────────────────────────────┐
-- │          PROXIMITY-BASED CASHIER FINDER (fallback only)         │
-- └─────────────────────────────────────────────────────────────────┘
local function FindNearestCashierToItem(mainPart)
    if not mainPart then return nil, nil end
    local itemPos  = mainPart.Position
    local bestNPC, bestName, bestDist = nil, nil, math.huge

    for name, npc in pairs(NPCs) do
        local head = npc:FindFirstChild("Head")
        if head then
            local dist = (head.Position - itemPos).Magnitude
            if dist < bestDist then
                bestDist = dist
                bestNPC  = npc
                bestName = name
            end
        end
    end

    return bestNPC, bestName
end

-- ┌─────────────────────────────────────────────────────────────────┐
-- │                   NPC ARG BUILDER                               │
-- └─────────────────────────────────────────────────────────────────┘
local function BuildNPCArg(npcName, npc)
    if not npc then return nil end
    if not npc:FindFirstChild("Dialog") then
        Instance.new("Dialog", npc)
    end
    local id = EnsureNPCID(npcName)
    if not id then return nil end
    return {
        ID        = id,
        Character = npc,
        Name      = npcName,
        Dialog    = npc.Dialog,
    }
end

local function GetNPCArgForItem(storeName, mainPart)
    local config = StoreConfigs[storeName]
    if config then
        local npc = NPCs[config.NPCName]
        if npc then
            local arg = BuildNPCArg(config.NPCName, npc)
            if arg then return arg, config.NPCName end
        end
    end

    if mainPart then
        local proxNPC, proxName = FindNearestCashierToItem(mainPart)
        if proxNPC and proxName then
            local arg = BuildNPCArg(proxName, proxNPC)
            if arg then return arg, proxName end
        end
    end

    return nil, nil
end

-- ┌─────────────────────────────────────────────────────────────────┐
-- │               SAFE INVOKE — HARD TIMEOUT + CLEANUP              │
-- └─────────────────────────────────────────────────────────────────┘
-- Tunables for the remote-invoke lifecycle.
local INVOKE_TIMEOUT      = 4       -- per-call hard timeout (s)
local POST_TIMEOUT_SETTLE = 0.6     -- wait after timeout before cleanup EndChat
local CLEANUP_ENDCHATS    = 3       -- EndChats fired after a timeout
local CLEANUP_GAP         = 0.3     -- spacing between cleanup EndChats
local CLEANUP_CALL_BUDGET = 1.5     -- per-EndChat hard cap during cleanup

local _lastInvokeTimedOut = false

local function SafeInvoke(npcArg, action)
    local co       = coroutine.running()
    local done     = false
    local timedOut = false

    local fireThread = task.spawn(function()
        pcall(function()
            Remote:InvokeServer(npcArg, action)
        end)
        if not done then
            done = true
            task.spawn(co)
        end
    end)

    task.delay(INVOKE_TIMEOUT, function()
        if not done then
            done     = true
            timedOut = true
            pcall(task.cancel, fireThread)
            task.spawn(co)
        end
    end)

    coroutine.yield()
    _lastInvokeTimedOut = timedOut

    -- If we timed out on anything other than EndChat, the server is likely
    -- still processing our action. Wait for it to settle, then synchronously
    -- fire multiple EndChats so the late-arriving action gets cleared BEFORE
    -- the next iteration starts a new dialog. The async cleanup in the old
    -- version was the root of half the stuck-NPC cases.
    if timedOut and action ~= "EndChat" then
        task.wait(POST_TIMEOUT_SETTLE)
        for _ = 1, CLEANUP_ENDCHATS do
            local cleanupDone   = false
            local cleanupThread = task.spawn(function()
                pcall(function() Remote:InvokeServer(npcArg, "EndChat") end)
                cleanupDone = true
            end)
            local cleanupDeadline = tick() + CLEANUP_CALL_BUDGET
            while not cleanupDone and tick() < cleanupDeadline do
                task.wait(0.05)
            end
            if not cleanupDone then
                pcall(task.cancel, cleanupThread)
            end
            task.wait(CLEANUP_GAP)
        end
    end
end

-- Compat alias for any existing references
local SafeInvokeTracked = SafeInvoke

-- ┌─────────────────────────────────────────────────────────────────┐
-- │                     POWER OF EASE PURCHASE                      │
-- └─────────────────────────────────────────────────────────────────┘
local POE_PRICE    = 10009000
local POE_TP_CF    = CFrame.new(1059.4, 17.2, 1130.3)
local POE_TIMEOUT  = 60
local POE_INTERVAL = 0.2

local function PurchasePowerOfEase()
    local funds = FetchFunds()
    if funds == nil then return end
    if funds < POE_PRICE then return end

    FetchAllNPCIDs()

    local char = Player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local returnCF = root.CFrame
    root.CFrame = POE_TP_CF
    task.wait(0.15)

    local bestDist = math.huge
    local bestNPC, bestName

    for name, npc in pairs(NPCs) do
        local store = npc.Parent
        if store and store:FindFirstChild("Counter") then
            local dist = (store.Counter.CFrame.p - root.Position).Magnitude
            if dist < bestDist then
                bestDist = dist
                bestNPC  = npc
                bestName = name
            end
        end
    end

    if not bestNPC then
        root.CFrame = returnCF
        return
    end

    if not bestNPC:FindFirstChild("Dialog") then
        Instance.new("Dialog", bestNPC)
    end

    local npcArg = BuildNPCArg(bestName, bestNPC)
    if not npcArg then
        root.CFrame = returnCF
        return
    end

    local deadline = tick() + POE_TIMEOUT

    while tick() < deadline do
        SafeInvoke(npcArg, "Initiate")
        SafeInvoke(npcArg, "ConfirmPurchase")
        SafeInvoke(npcArg, "EndChat")

        local newFunds = FetchFunds()
        if newFunds and newFunds < funds then break end

        task.wait(POE_INTERVAL)
    end

    task.wait(0.1)
    local returnChar = Player.Character
    local returnRoot = returnChar and returnChar:FindFirstChild("HumanoidRootPart")
    if returnRoot then returnRoot.CFrame = returnCF end
end

-- ┌─────────────────────────────────────────────────────────────────┐
-- │                       PURCHASE SEQUENCE                         │
-- └─────────────────────────────────────────────────────────────────┘
local SPAM_TIMEOUT       = 30
local CYCLE_GAP          = 0.1      -- widened from 0.05 — less server pressure
local INNER_DEADLINE     = 3        -- per-Initiate confirm-spam window
local FAIL_BACKOFF_AFTER = 8
local FAIL_BACKOFF_WAIT  = 0.6
local ID_REFETCH_AFTER   = 16

-- Per-NPC recovery
local NPC_FAIL_THRESHOLD  = 3       -- DoPurchase failures before HardResetNPC
local NPC_NUCLEAR_AFTER   = 2       -- HardResetNPCs before forced respawn (if enabled)
local _npcFailStreak      = {}
local _npcResetStreak     = {}

local function IsSuccessParent(parent)
    if not parent then return false end
    if parent.Name == "PlayerModels" then return true end
    if parent == Player.Backpack     then return true end
    if parent == Player.Character    then return true end
    local current = parent
    while current do
        if current.Name == "PlayerModels" then return true end
        current = current.Parent
    end
    return false
end

local function CheckItemState(mainPart)
    if not mainPart then return "gone" end
    local parent = mainPart.Parent
    if IsSuccessParent(parent) then return "success" end
    if parent == nil then
        task.wait(0.12)
        local newParent = mainPart.Parent
        if IsSuccessParent(newParent) then return "success" end
        if newParent == nil             then return "gone"    end
    end
    return "pending"
end

local function FlushDialog(npcArg, count)
    count = count or 2
    for _ = 1, count do
        SafeInvoke(npcArg, "EndChat")
        task.wait(0.05)
    end
end

local function SpamPurchase(mainPart, npcArg, itemName, npcName)
    local startTime = tick()
    local deadline  = tick() + SPAM_TIMEOUT

    while tick() < deadline do
        local state = CheckItemState(mainPart)
        if state == "success" then return true,  tick() - startTime end
        if state == "gone"    then return false, tick() - startTime end

        -- Open a fresh dialog session
        SafeInvoke(npcArg, "Initiate")
        if _lastInvokeTimedOut then
            -- SafeInvoke already did the synchronous cleanup. Refresh ID
            -- (it might be stale; filter in FetchNPCID prevents poisoning)
            -- and retry the outer loop.
            InvalidateNPCID(npcName)
            local newID = FetchNPCID(npcName)
            if newID then npcArg.ID = newID end
            task.wait(0.2)
            continue
        end

        -- Recheck immediately — Initiate alone can sometimes finalize state
        state = CheckItemState(mainPart)
        if state == "success" then SafeInvoke(npcArg, "EndChat"); return true,  tick() - startTime end
        if state == "gone"    then SafeInvoke(npcArg, "EndChat"); return false, tick() - startTime end

        -- Fire ConfirmPurchase tightly until state changes or window expires
        local innerDeadline = tick() + INNER_DEADLINE
        while tick() < innerDeadline do
            state = CheckItemState(mainPart)
            if state == "success" then
                SafeInvoke(npcArg, "EndChat")
                return true, tick() - startTime
            end
            if state == "gone" then
                SafeInvoke(npcArg, "EndChat")
                return false, tick() - startTime
            end

            SafeInvoke(npcArg, "ConfirmPurchase")

            -- If ConfirmPurchase timed out, cleanup already fired. Bail
            -- out of the inner loop and let the outer loop restart cleanly.
            if _lastInvokeTimedOut then break end

            task.wait(CYCLE_GAP)
        end

        -- Inner loop expired — close session and retry from Initiate
        SafeInvoke(npcArg, "EndChat")
        task.wait(0.2)
    end

    SafeInvoke(npcArg, "EndChat")
    return false, tick() - startTime
end

-- ┌─────────────────────────────────────────────────────────────────┐
-- │                      PURCHASE PART                              │
-- └─────────────────────────────────────────────────────────────────┘
local function PositionForPurchase(mainPart, item, pressedCF)
    local storeName = item.Store
    local config    = StoreConfigs[storeName]
    if not config then return nil, nil end

    local dropCF = ComputeDropCF(storeName, mainPart)
    if not dropCF then return nil, nil end

    local success = _LOT.TeleportMany({ { target = mainPart, goalCF = dropCF } })
    if _LOT.IsBusy() then success = _LOT.WaitForBatch() end
    if not success then return nil, nil end

    local char = Player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil, nil end

    root.CFrame = config.PlayerBuyCF

    local npcArg, resolvedNPCName = GetNPCArgForItem(storeName, mainPart)
    if not npcArg or not npcArg.ID then return nil, nil end

    return npcArg, resolvedNPCName
end

local function DoPurchase(mainPart, item, npcArg, resolvedNPCName, pressedCF)
    local purchased, elapsed = SpamPurchase(mainPart, npcArg, item.Name, resolvedNPCName)

    if purchased then
        if mainPart and mainPart.Parent then
            -- Quick Purchase: if enabled and the item was bought in under 1 second,
            -- skip the LOT ownership pipeline and set CFrame directly.
            -- The item is freshly parented to PlayerModels so the client has
            -- network ownership — a direct CFrame is authoritative and faster.
            -- May cause failures on slow servers where ownership hasn't fully
            -- transferred; toggle off if items slingshot or disappear.
            if _quickPurchase and elapsed < 1 then
                mainPart.CFrame                   = pressedCF
                mainPart.AssemblyLinearVelocity   = Vector3.new()
                mainPart.AssemblyAngularVelocity  = Vector3.new()
            else
                _LOT.TeleportMany({ { target = mainPart, goalCF = pressedCF } })
            end
        end
        local returnChar = Player.Character
        local returnRoot = returnChar and returnChar:FindFirstChild("HumanoidRootPart")
        if returnRoot then
            returnRoot.CFrame = pressedCF * CFrame.new(0, 0, 3)
        end
    end

    return purchased
end

-- ┌─────────────────────────────────────────────────────────────────┐
-- │                     REMOTE ITEM LIST LOADER                     │
-- └─────────────────────────────────────────────────────────────────┘
local function LoadItemList()
    local lm = _G.LoadModule or getgenv().LoadModule
    if type(lm) ~= "function" then
        warn("[Shop] LoadModule not available")
        return nil
    end

    local storeMap = lm("LT2ItemList")
    if not storeMap then return nil end

    local ClientItemInfo = ReplicatedStorage:FindFirstChild("ClientItemInfo")
    if not ClientItemInfo then
        warn("[Shop] ClientItemInfo not found in ReplicatedStorage")
        return nil
    end

    local items = {}
    for _, entry in ipairs(storeMap) do
        local ok, err = pcall(function()
            local folder = ClientItemInfo:FindFirstChild(entry.BoxItemName)
            if not folder then return end

            local nameVal  = folder:FindFirstChild("ItemName")
            local imageVal = folder:FindFirstChild("ItemImage")
            local priceVal = folder:FindFirstChild("Price")

            if not (nameVal and imageVal and priceVal) then
                warn("[Shop] Incomplete ClientItemInfo for:", entry.BoxItemName)
                return
            end

            local price = (function()
                local raw = priceVal.Value
                if type(raw) == "number" then return raw end
                return tonumber(tostring(raw):gsub("[^%d]", "")) or 0
            end)()

            table.insert(items, {
                Name        = nameVal.Value,
                Image       = imageVal.Value,
                Price       = price,
                BoxItemName = entry.BoxItemName,
                Store       = entry.Store,
                IsBlueprint = entry.IsBlueprint == true,
            })
        end)
        if not ok then
            warn("[Shop] Failed to load entry:", entry.BoxItemName, "|", err)
        end
    end

    return #items > 0 and items or nil
end

-- ┌─────────────────────────────────────────────────────────────────┐
-- │                   SHOPITEMS ↔ STORE MATCHER                     │
-- └─────────────────────────────────────────────────────────────────┘
local ShopItemsCache = {}

local function GetShopItemsForStore(storeName)
    if ShopItemsCache[storeName] ~= nil then
        return ShopItemsCache[storeName] or nil
    end

    local config = StoreConfigs[storeName]
    if not config then
        ShopItemsCache[storeName] = false
        return nil
    end

    local npc   = NPCs[config.NPCName]
    local store = npc and npc.Parent
    local anchor

    if store and store:FindFirstChild("Counter") then
        anchor = store.Counter.CFrame.p
    elseif store and store:IsA("Model") then
        local ok, piv = pcall(function() return store:GetPivot().Position end)
        if ok then anchor = piv end
    end

    if not anchor then
        ShopItemsCache[storeName] = false
        return nil
    end

    local stores = workspace:FindFirstChild("Stores")
    if not stores then
        ShopItemsCache[storeName] = false
        return nil
    end

    local bestContainer, bestDist = nil, math.huge

    for _, child in ipairs(stores:GetChildren()) do
        if child.Name ~= "ShopItems" then continue end

        local samplePos
        for _, desc in ipairs(child:GetDescendants()) do
            if desc:IsA("BasePart") then
                samplePos = desc.Position
                break
            end
        end

        if samplePos then
            local dist = (samplePos - anchor).Magnitude
            if dist < bestDist then
                bestDist      = dist
                bestContainer = child
            end
        end
    end

    ShopItemsCache[storeName] = bestContainer or false
    return bestContainer
end

-- ┌─────────────────────────────────────────────────────────────────┐
-- │                      WORLD PATH RESOLVER                        │
-- └─────────────────────────────────────────────────────────────────┘
local function ResolveItemParts(item, limit)
    local stores = workspace:FindFirstChild("Stores")
    if not stores then return {} end

    local results = {}

    local function searchContainer(shopItems)
        for _, box in ipairs(shopItems:GetChildren()) do
            if #results >= limit then break end
            if not (box:IsA("Model") and box.Name == "Box") then continue end

            local nameVal = box:FindFirstChild("BoxItemName")
            if not (nameVal and nameVal:IsA("StringValue")) then continue end
            if nameVal.Value ~= item.BoxItemName then continue end

            local main = box:FindFirstChild("Main")
            if main and main:IsA("BasePart") and not main.Anchored then
                table.insert(results, main)
            end
        end
    end

    local storeName = item.Store
    if storeName then
        local targetContainer = GetShopItemsForStore(storeName)
        if targetContainer then
            searchContainer(targetContainer)
            return results
        end
    end

    for _, child in ipairs(stores:GetChildren()) do
        if #results >= limit then break end
        if child.Name ~= "ShopItems" then continue end
        searchContainer(child)
    end

    return results
end

-- ┌─────────────────────────────────────────────────────────────────┐
-- │              RECOVERY — STUCK NPC ESCALATION                    │
-- └─────────────────────────────────────────────────────────────────┘
local function HardResetNPC(npcArg, npcName)
    warn("[Shop] HardResetNPC for", npcName)

    -- Step out of proximity briefly. Two reasons:
    --   1) Gets us out of the server's 1Hz prompt-fire window for this NPC,
    --      cleaning up the OnClientEvent stream before we refetch the ID.
    --   2) Defensive — if server chat state ties to proximity in any way
    --      not visible in the script, this gives that a chance to act.
    local char    = Player.Character
    local root    = char and char:FindFirstChild("HumanoidRootPart")
    local savedCF = root and root.CFrame
    if root then
        root.CFrame = root.CFrame * CFrame.new(0, 0, 40)
        task.wait(1.0)
    end

    -- Re-fetch the NPC ID from scratch (with the filtered FetchNPCID)
    InvalidateNPCID(npcName)
    local newID = FetchNPCID(npcName)
    if newID then npcArg.ID = newID end

    -- Spam EndChat to clear any pinned server-side dialog state
    for _ = 1, 5 do
        local d = false
        local t = task.spawn(function()
            pcall(function() Remote:InvokeServer(npcArg, "EndChat") end)
            d = true
        end)
        local deadline = tick() + CLEANUP_CALL_BUDGET
        while not d and tick() < deadline do task.wait(0.05) end
        if not d then pcall(task.cancel, t) end
        task.wait(0.3)
    end

    -- Restore position
    local rc = Player.Character
    local rr = rc and rc:FindFirstChild("HumanoidRootPart")
    if rr and savedCF then
        rr.CFrame = savedCF
        task.wait(0.3)
    end
end

local function NuclearReset()
    warn("[Shop] NuclearReset — forcing character respawn to free pinned ChattingPlayer")
    local char = Player.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.Health = 0 end

    local deadline = tick() + 10
    repeat
        task.wait(0.2)
    until (Player.Character
           and Player.Character:FindFirstChild("HumanoidRootPart"))
       or tick() > deadline
    task.wait(0.5)
end

-- ┌─────────────────────────────────────────────────────────────────┐
-- │                    RESTOCK-AWARE BUY LOOP                       │
-- └─────────────────────────────────────────────────────────────────┘
local RESTOCK_POLL_RATE = 0.5
local RESTOCK_TIMEOUT   = 120

local _isBuying = false

local function RunBuyLoop(item, totalQty, pressedCF, onDone)
    _isBuying = true
    FetchAllNPCIDs()

    local bought       = 0
    local restockTimer = 0

    while bought < totalQty and _isBuying do
        local stillNeed = totalQty - bought
        local parts     = ResolveItemParts(item, stillNeed)

        if #parts == 0 then
            task.wait(RESTOCK_POLL_RATE)
            restockTimer += RESTOCK_POLL_RATE
            if restockTimer >= RESTOCK_TIMEOUT then break end
            continue
        end

        restockTimer = 0

        for _, mainPart in ipairs(parts) do
            if not _isBuying      then break end
            if bought >= totalQty then break end
            if not mainPart or not mainPart.Parent then continue end
            if _LOT.IsBusy() then _LOT.WaitForBatch() end

            local npcArg, resolvedNPCName = PositionForPurchase(mainPart, item, pressedCF)
            if not npcArg then continue end

            local ok     = false
            local giveUp = tick() + 90

            while not ok and _isBuying and tick() < giveUp do
                if not mainPart or not mainPart.Parent then break end

                ok = DoPurchase(mainPart, item, npcArg, resolvedNPCName, pressedCF)

                if ok then
                    -- Success — clear failure tracking for this NPC
                    _npcFailStreak[resolvedNPCName]  = 0
                    _npcResetStreak[resolvedNPCName] = 0
                else
                    _npcFailStreak[resolvedNPCName] =
                        (_npcFailStreak[resolvedNPCName] or 0) + 1

                    if _npcFailStreak[resolvedNPCName] >= NPC_FAIL_THRESHOLD then
                        _npcFailStreak[resolvedNPCName]  = 0
                        _npcResetStreak[resolvedNPCName] =
                            (_npcResetStreak[resolvedNPCName] or 0) + 1

                        if _allowNuclearReset
                           and _npcResetStreak[resolvedNPCName] >= NPC_NUCLEAR_AFTER then
                            _npcResetStreak[resolvedNPCName] = 0
                            NuclearReset()
                            FetchAllNPCIDs()
                            -- Re-position at counter after respawn
                            npcArg, resolvedNPCName =
                                PositionForPurchase(mainPart, item, pressedCF)
                            if not npcArg then break end
                        else
                            HardResetNPC(npcArg, resolvedNPCName)
                            -- HardResetNPC restores position; re-pin at counter
                            local rChar = Player.Character
                            local rRoot = rChar and rChar:FindFirstChild("HumanoidRootPart")
                            local cfg   = StoreConfigs[item.Store]
                            if rRoot and cfg then
                                rRoot.CFrame = cfg.PlayerBuyCF
                                task.wait(0.15)
                            end
                        end
                    else
                        task.wait(0.3)
                    end
                end
            end

            if ok then bought += 1 end
        end
    end

    _isBuying = false
    if onDone then onDone() end
end

-- ┌─────────────────────────────────────────────────────────────────┐
-- │              BLUEPRINT — PURCHASE WITHOUT ITEM TP               │
-- └─────────────────────────────────────────────────────────────────┘
local function PurchaseBlueprintPart(mainPart, item)
    local npcArg, resolvedNPCName = PositionForPurchase(mainPart, item, nil)
    if not npcArg then return false end
    local purchased, _ = SpamPurchase(mainPart, npcArg, item.Name, resolvedNPCName)
    return purchased
end

-- ┌─────────────────────────────────────────────────────────────────┐
-- │              BLUEPRINT — OPEN BOX FROM PLAYERMODELS             │
-- └─────────────────────────────────────────────────────────────────┘
local BOX_OPEN_TIMEOUT = 10

local function OpenBlueprintBox(boxItemName)
    local PlayerModels = workspace:FindFirstChild("PlayerModels")
    if not PlayerModels then return false end

    local deadline = tick() + BOX_OPEN_TIMEOUT

    while tick() < deadline do
        for _, model in ipairs(PlayerModels:GetChildren()) do
            if model:IsA("Model") and model.Name:find("Box Purchased by") then
                local nameVal = model:FindFirstChild("PurchasedBoxItemName")
                if nameVal and nameVal.Value == boxItemName then
                    local char = Player.Character
                    local head = char and char:FindFirstChild("Head")
                    if head then
                        Interact:FireServer(model, "Open box", head.CFrame)
                        task.wait(0.5)
                        return true
                    end
                end
            end
        end
        task.wait(0.2)
    end

    warn("[Blueprints] Timed out waiting for box:", boxItemName)
    return false
end

-- ┌─────────────────────────────────────────────────────────────────┐
-- │                   PURCHASE ALL BLUEPRINTS                       │
-- └─────────────────────────────────────────────────────────────────┘
local _isBuyingBlueprints = false

local function RunBlueprintLoop(ShopItems, onDone)
    _isBuyingBlueprints = true

    FetchAllNPCIDs()

    local char     = Player.Character
    local root     = char and char:FindFirstChild("HumanoidRootPart")
    local returnCF = root and root.CFrame

    local blueprints = {}
    for _, item in ipairs(ShopItems) do
        if item.IsBlueprint then
            table.insert(blueprints, item)
        end
    end

    if #blueprints == 0 then
        warn("[Blueprints] No blueprint items found in item list.")
        _isBuyingBlueprints = false
        if onDone then onDone() end
        return
    end

    print("[Blueprints] Found " .. #blueprints .. " blueprints to purchase.")

    for _, item in ipairs(blueprints) do
        if not _isBuyingBlueprints then break end

        local parts = ResolveItemParts(item, 1)
        if #parts == 0 then
            warn("[Blueprints] No stock found for:", item.Name, "— skipping.")
            continue
        end

        local mainPart = parts[1]
        if not mainPart or not mainPart.Parent then
            warn("[Blueprints] mainPart gone for:", item.Name, "— skipping.")
            continue
        end

        local blueprintsFolder = Player:FindFirstChild("PlayerBlueprints")
            and Player.PlayerBlueprints:FindFirstChild("Blueprints")
        if blueprintsFolder and blueprintsFolder:FindFirstChild(item.BoxItemName) then
            print("[Blueprints] Already owned, skipping:", item.Name)
            continue
        end

        local funds = FetchFunds()
        if funds == nil or funds < item.Price then
            warn("[Blueprints] Not enough funds for:", item.Name, "(need $" .. item.Price .. ")")
            continue
        end

        print("[Blueprints] Purchasing:", item.Name)
        local purchased = PurchaseBlueprintPart(mainPart, item)

        if purchased then
            print("[Blueprints] Purchased! Opening box for:", item.Name)
            local boxName = item.BoxItemName or item.Name
            OpenBlueprintBox(boxName)
        else
            warn("[Blueprints] Failed to purchase:", item.Name)
        end

        task.wait(0.2)
    end

    local returnChar = Player.Character
    local returnRoot = returnChar and returnChar:FindFirstChild("HumanoidRootPart")
    if returnRoot and returnCF then
        returnRoot.CFrame = returnCF
    end

    print("[Blueprints] All done!")
    _isBuyingBlueprints = false
    if onDone then onDone() end
end

-- ┌─────────────────────────────────────────────────────────────────┐
-- │                         MODULE INIT                             │
-- └─────────────────────────────────────────────────────────────────┘
function ShopModule.Init(Tab, lot)
    if lot ~= nil then _LOT = lot end

    _ShopItems = LoadItemList()
    local ShopItems = _ShopItems

    if not ShopItems or #ShopItems == 0 then
        Tab:CreateSection("Hardware Store")
        return
    end

    local SelectedItem = ShopItems[1]
    local Quantity     = 1

    local PurchaseBtn

    local function RefreshFundsCache()
        task.spawn(function()
            local f = FetchFunds()
            if f ~= nil then _cachedFunds = f end
            if PurchaseBtn and SelectedItem and not _isBuying then
                local canAfford = _cachedFunds ~= nil and _cachedFunds >= SelectedItem.Price
                PurchaseBtn:SetDisabled(not canAfford)
            end
        end)
    end

    local function UpdateDisplay()
        if not SelectedItem or not PurchaseBtn then return end
        if _isBuying then return end
        local cost      = SelectedItem.Price * Quantity
        local canAfford = _cachedFunds ~= nil and _cachedFunds >= SelectedItem.Price
        PurchaseBtn:SetText(("$%d"):format(cost))
        PurchaseBtn:SetDisabled(not canAfford)
    end

    local function SetBuyingState(buying)
        if not PurchaseBtn then return end
        if buying then
            PurchaseBtn:SetText("Stop")
            PurchaseBtn:SetDisabled(false)
        else
            RefreshFundsCache()
            UpdateDisplay()
        end
    end

    -- ── Stores ──────────────────────────────────────────────────────
    Tab:CreateSection("Shop")

    local Catalog = Tab:CreateImageSelector("Select an Item", {
        MultiSelect = false,
        VisibleRows = 3,
        SlotSize    = UDim2.new(0, 73, 0, 73),
    }, function(name)
        for _, item in pairs(ShopItems) do
            if item.Name == name then
                SelectedItem = item
                break
            end
        end
        UpdateDisplay()
    end)

    local BlueprintSlotObjs = {}
    local SlotRefs = {}

    for _, item in ipairs(ShopItems) do
        pcall(function()
            local slotObj = Catalog:AddSlot("", item.Name, "$" .. tostring(item.Price))
            SlotRefs[item.Name] = { slotObj = slotObj, item = item }
            if item.IsBlueprint then
                BlueprintSlotObjs[item.Name] = slotObj
            end
        end)
    end

    task.spawn(function()
        for _, item in ipairs(ShopItems) do
            task.wait()
            pcall(function()
                if not item.Image or item.Image == "" then return end
                local ref = SlotRefs[item.Name]
                if not ref or not ref.slotObj.ImageLabel then return end
                ref.slotObj.ImageLabel.Image = item.Image
            end)
        end
    end)

    Tab:CreateSlider("Quantity", 1, 100, 1, function(val)
        Quantity = val
        UpdateDisplay()
    end)

    PurchaseBtn = Tab:CreateAction("Purchase", ("$%d"):format(ShopItems[1].Price), function()
        if _isBuying then
            _isBuying = false
            return
        end

        if not SelectedItem                       then return end
        if _LOT == nil                            then return end
        if not SelectedItem.Store                 then return end
        if not StoreConfigs[SelectedItem.Store]   then return end
        if _LOT.IsBusy()                          then return end

        local funds = FetchFunds()
        if funds == nil               then return end
        if funds < SelectedItem.Price then return end

        local totalCost = SelectedItem.Price * Quantity
        local targetQty = Quantity
        if funds < totalCost then
            targetQty = math.floor(funds / SelectedItem.Price)
        end

        local char      = Player.Character
        local root      = char and char:FindFirstChild("HumanoidRootPart")
        local pressedCF = root and root.CFrame

        SetBuyingState(true)

        task.spawn(function()
            RunBuyLoop(SelectedItem, targetQty, pressedCF, function()
                SetBuyingState(false)
            end)
        end)
    end, false)

    RefreshFundsCache()
    task.spawn(function()
        while true do
            task.wait(3)
            RefreshFundsCache()
        end
    end)

    UpdateDisplay()
    ShopModule.UpdateDisplay = UpdateDisplay

    -- ── Special ─────────────────────────────────────────────────────
    Tab:CreateSection("Special")

    Tab:CreateAction("Power of Ease ($10,009,000)", "Buy", function()
        task.spawn(PurchasePowerOfEase)
    end, false)

    local BlueprintItems = {}
    for _, item in ipairs(ShopItems) do
        if item.IsBlueprint then
            table.insert(BlueprintItems, item)
        end
    end

    local function CheckAllBlueprintsOwned()
        if #BlueprintItems == 0 then return false end
        local playerBP = Player:FindFirstChild("PlayerBlueprints")
        if not playerBP then return false end
        local blueprintsFolder = playerBP:FindFirstChild("Blueprints")
        if not blueprintsFolder then return false end
        local owned = 0
        for _, item in ipairs(BlueprintItems) do
            if blueprintsFolder:FindFirstChild(item.BoxItemName) then
                owned += 1
            end
        end
        return owned >= #BlueprintItems
    end

    local BlueprintBtn

    local function GetTotalBlueprintCost()
        local blueprintsFolder = Player:FindFirstChild("PlayerBlueprints")
            and Player.PlayerBlueprints:FindFirstChild("Blueprints")
        local total = 0
        for _, item in ipairs(BlueprintItems) do
            local owned = blueprintsFolder and blueprintsFolder:FindFirstChild(item.BoxItemName)
            if not owned then
                total += tonumber(item.Price) or 0
            end
        end
        return total
    end

    local function UpdateBlueprintBtnState()
        if not BlueprintBtn then return end
        if _isBuyingBlueprints then return end
        local allOwned = CheckAllBlueprintsOwned()
        BlueprintBtn:SetDisabled(allOwned)
        if allOwned then
            BlueprintBtn:SetText("All Owned")
        else
            local total = GetTotalBlueprintCost()
            if total > 0 then
                BlueprintBtn:SetText("$" .. tostring(total))
            else
                BlueprintBtn:SetText(#BlueprintItems .. " blueprints")
            end
        end
    end

    BlueprintBtn = Tab:CreateAction("Purchase All Blueprints", "Buy", function()
        if _isBuyingBlueprints then
            _isBuyingBlueprints = false
            UpdateBlueprintBtnState()
            return
        end
        BlueprintBtn:SetText("Stop")
        task.spawn(function()
            RunBlueprintLoop(ShopItems, function()
                UpdateBlueprintBtnState()
            end)
        end)
    end, false)

    UpdateBlueprintBtnState()

    -- ── Rukiry Axe ──────────────────────────────────────────────────
    local RUKIRY_ITEMS = {
        { BoxItemName = "CanOfWorms", GoalCF = CFrame.new(317.3, 46.0, 1918.1) },
        { BoxItemName = "BagOfSand",  GoalCF = CFrame.new(319.5, 46.0, 1914.9) },
        { BoxItemName = "LightBulb",  GoalCF = CFrame.new(322.4, 43.6, 1916.4) },
    }

    local RUKIRY_PLAYER_CF = CFrame.new(320.6, 45.8, 1919.2)

    local RukiryBtn
    local _isBuyingRukiry = false

    local function PurchaseRukiryItem(mainPart, item, goalCF)
        local npcArg, resolvedNPCName = PositionForPurchase(mainPart, item, nil)
        if not npcArg then return false end

        local purchased, _ = SpamPurchase(mainPart, npcArg, item.Name, resolvedNPCName)

        if purchased then
            task.wait(0.05)

            local PlayerModels = workspace:FindFirstChild("PlayerModels")
            local existingModels = {}
            if PlayerModels then
                for _, m in ipairs(PlayerModels:GetChildren()) do
                    existingModels[m] = true
                end
            end

            local boxModel = mainPart and mainPart.Parent
            if boxModel and boxModel:IsA("Model") then
                local ch   = Player.Character
                local head = ch and ch:FindFirstChild("Head")
                if head then
                    Interact:FireServer(boxModel, "Open box", head.CFrame)
                end
            end

            local spawnedPart = nil
            local deadline = tick() + 5
            while tick() < deadline do
                task.wait(0.1)
                if PlayerModels then
                    for _, m in ipairs(PlayerModels:GetChildren()) do
                        if not existingModels[m] and m:IsA("Model") then
                            local itemNameVal = m:FindFirstChild("ItemName")
                            if not (itemNameVal and itemNameVal.Value == item.BoxItemName) then continue end
                            local ownerFolder = m:FindFirstChild("Owner")
                            local ownerString = ownerFolder and ownerFolder:FindFirstChild("OwnerString")
                            if not (ownerString and ownerString.Value == Player.Name) then continue end
                            local foundMain = m:FindFirstChild("Main")
                            if foundMain then
                                spawnedPart = foundMain
                                break
                            end
                        end
                    end
                end
                if spawnedPart then break end
            end

            if spawnedPart and spawnedPart.Parent then
                _LOT.TeleportMany({ { target = spawnedPart, goalCF = goalCF } })
                if _LOT.IsBusy() then _LOT.WaitForBatch() end
            else
                warn("[Rukiry] Could not find spawned item after box open")
            end
        end

        return purchased
    end

    local function RunRukiryLoop()
        _isBuyingRukiry = true
        FetchAllNPCIDs()

        local returnChar = Player.Character
        local returnRoot = returnChar and returnChar:FindFirstChild("HumanoidRootPart")
        local rukiryReturnCF = returnRoot and returnRoot.CFrame

        for _, rukiryItem in ipairs(RUKIRY_ITEMS) do
            if not _isBuyingRukiry then break end

            local itemDef = nil
            for _, shopItem in ipairs(ShopItems) do
                if shopItem.BoxItemName == rukiryItem.BoxItemName then
                    itemDef = shopItem
                    break
                end
            end

            if not itemDef then
                warn("[Rukiry] Item not found in list:", rukiryItem.BoxItemName)
                continue
            end

            local funds = FetchFunds()
            if funds == nil or funds < itemDef.Price then
                warn("[Rukiry] Not enough funds for:", itemDef.Name, "(need $" .. itemDef.Price .. ")")
                continue
            end

            local parts = ResolveItemParts(itemDef, 1)
            if #parts == 0 then
                warn("[Rukiry] No stock found for:", itemDef.Name)
                continue
            end

            local mainPart = parts[1]
            if not mainPart or not mainPart.Parent then
                warn("[Rukiry] mainPart gone for:", itemDef.Name)
                continue
            end

            print("[Rukiry] Purchasing:", itemDef.Name)
            local purchased = PurchaseRukiryItem(mainPart, itemDef, rukiryItem.GoalCF)

            if purchased then
                print("[Rukiry] Placed:", itemDef.Name)
            else
                warn("[Rukiry] Failed:", itemDef.Name)
            end

            task.wait(0.2)
        end

        local retChar = Player.Character
        local retRoot = retChar and retChar:FindFirstChild("HumanoidRootPart")
        if retRoot then retRoot.CFrame = RUKIRY_PLAYER_CF end

        print("[Rukiry] Waiting for axe to spawn...")
        local axeModel    = nil
        local axeDeadline = tick() + 20
        while tick() < axeDeadline do
            task.wait(0.2)
            local PlayerModels = workspace:FindFirstChild("PlayerModels")
            if not PlayerModels then continue end

            local ch   = Player.Character
            local root = ch and ch:FindFirstChild("HumanoidRootPart")

            for _, m in ipairs(PlayerModels:GetChildren()) do
                if not (m:IsA("Model") and m.Name == "Model") then continue end
                local toolName = m:FindFirstChild("ToolName")
                if not (toolName and toolName.Value == "Rukiryaxe") then continue end
                local ownerFolder = m:FindFirstChild("Owner")
                local ownerString = ownerFolder and ownerFolder:FindFirstChild("OwnerString")
                if not (ownerString and ownerString.Value == "") then continue end
                local lastInteraction = ownerFolder and ownerFolder:FindFirstChild("LastInteraction")
                if not (lastInteraction and lastInteraction.Value == 0) then continue end
                if root then
                    local handle = m:FindFirstChild("Handle") or m.PrimaryPart
                    if handle and (handle.Position - root.Position).Magnitude > 50 then continue end
                end
                axeModel = m
                break
            end

            if axeModel then break end
        end

        if axeModel then
            -- The axe is unowned, so we CAN'T reliably drag it to us — the server
            -- reverts CFrame changes from non-owners. Instead bring OUR character
            -- to the axe (always authoritative), claim it with the drag remote,
            -- fire the pickup, and confirm the loose model actually left the world.
            local function AxeGone()
                return (not axeModel.Parent) or (not axeModel:IsDescendantOf(workspace))
            end

            print("[Rukiry] Found axe — moving to it and picking up...")
            local picked   = false
            local deadline = tick() + 8

            while tick() < deadline and _isBuyingRukiry and not picked do
                local handle = axeModel:FindFirstChild("Handle") or axeModel.PrimaryPart
                if not handle then break end

                local rc = Player.Character
                local rr = rc and rc:FindFirstChild("HumanoidRootPart")
                if rr then
                    rr.CFrame = handle.CFrame + Vector3.new(0, 3, 0)
                    rr.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                end
                task.wait(0.1)

                -- Claim the axe via the drag remote, then fire the pickup.
                for _ = 1, 8 do
                    pcall(DragRemote.FireServer, DragRemote, axeModel)
                    task.wait()
                end
                local h = axeModel:FindFirstChild("Handle") or axeModel.PrimaryPart
                if h then
                    Interact:FireServer(axeModel, "Pick up tool", h.CFrame)
                end
                task.wait(0.3)

                if AxeGone() then picked = true end
            end

            if picked then
                print("[Rukiry] Axe picked up!")
            else
                warn("[Rukiry] Could not confirm axe pickup — it may still be on the ground.")
            end

            task.wait(0.1)
            local rc2 = Player.Character
            local rr2 = rc2 and rc2:FindFirstChild("HumanoidRootPart")
            if rr2 and rukiryReturnCF then
                rr2.CFrame = rukiryReturnCF
                print("[Rukiry] Returned to original position.")
            end
        else
            warn("[Rukiry] Axe did not spawn within timeout")
        end

        print("[Rukiry] Done!")
        _isBuyingRukiry = false
        RukiryBtn:SetText("$7,400")
    end

    RukiryBtn = Tab:CreateAction("Purchase Rukiry Axe", "$7,400", function()
        if _isBuyingRukiry then
            _isBuyingRukiry = false
            RukiryBtn:SetText("$7,400")
            return
        end
        RukiryBtn:SetText("Stop")
        task.spawn(RunRukiryLoop)
    end, false)

    -- ── Settings ────────────────────────────────────────────────────
    Tab:CreateSection("Settings")

    local QuickPurchaseToggle = Tab:CreateToggle("Quick Purchase", false, function(state)
        _quickPurchase = state
    end)

    QuickPurchaseToggle:AddTooltip(
        "If an item is purchased within 1 second of being teleported to\n" ..
        "the counter, its CFrame is set directly instead of using LOT.\n" ..
        "Faster, but may cause failures on slow servers.\n\n" ..
        "⚠ Warning: this may cause failures."
    )

    local NuclearToggle = Tab:CreateToggle("Force Respawn on Stuck NPC", false, function(state)
        _allowNuclearReset = state
    end)

    NuclearToggle:AddTooltip(
        "If an NPC stays stuck after multiple soft resets, force a\n" ..
        "character respawn to free the server-side ChattingPlayer pin."
    )

    -- ── Blueprint slot watcher ──────────────────────────────────────
    local function GetBlueprintsFolder()
        local playerBP = Player:FindFirstChild("PlayerBlueprints")
        return playerBP and playerBP:FindFirstChild("Blueprints")
    end

    local function UpdateBlueprintSlots()
        local bpFolder = GetBlueprintsFolder()
        for _, item in ipairs(BlueprintItems) do
            local owned = bpFolder ~= nil and bpFolder:FindFirstChild(item.BoxItemName) ~= nil
            local slotObj = BlueprintSlotObjs[item.Name]
            if slotObj then slotObj:SetEnabled(not owned) end
        end
    end

    local _bpFolderConns = {}

    local function WireBlueprintFolder(folder)
        for _, c in ipairs(_bpFolderConns) do c:Disconnect() end
        _bpFolderConns = {}
        if not folder then return end
        table.insert(_bpFolderConns, folder.ChildAdded:Connect(function()
            UpdateBlueprintSlots()
            UpdateBlueprintBtnState()
        end))
        table.insert(_bpFolderConns, folder.ChildRemoved:Connect(function()
            UpdateBlueprintSlots()
            UpdateBlueprintBtnState()
        end))
    end

    local function WatchPlayerBlueprints()
        local playerBP = Player:FindFirstChild("PlayerBlueprints")
        if not playerBP then
            Player.ChildAdded:Connect(function(child)
                if child.Name ~= "PlayerBlueprints" then return end
                local sub = child:FindFirstChild("Blueprints")
                if sub then
                    WireBlueprintFolder(sub)
                    UpdateBlueprintSlots()
                    UpdateBlueprintBtnState()
                else
                    child.ChildAdded:Connect(function(subchild)
                        if subchild.Name == "Blueprints" then
                            WireBlueprintFolder(subchild)
                            UpdateBlueprintSlots()
                            UpdateBlueprintBtnState()
                        end
                    end)
                end
            end)
            return
        end

        local folder = playerBP:FindFirstChild("Blueprints")
        if folder then
            WireBlueprintFolder(folder)
        else
            playerBP.ChildAdded:Connect(function(child)
                if child.Name == "Blueprints" then
                    WireBlueprintFolder(child)
                    UpdateBlueprintSlots()
                    UpdateBlueprintBtnState()
                end
            end)
        end

        Player.ChildRemoved:Connect(function(child)
            if child.Name == "PlayerBlueprints" then
                for _, c in ipairs(_bpFolderConns) do c:Disconnect() end
                _bpFolderConns = {}
                UpdateBlueprintSlots()
                UpdateBlueprintBtnState()
                WatchPlayerBlueprints()
            end
        end)
    end

    WatchPlayerBlueprints()
    UpdateBlueprintSlots()
    UpdateBlueprintBtnState()
end

-- ┌─────────────────────────────────────────────────────────────────┐
-- │                         PUBLIC API                              │
-- └─────────────────────────────────────────────────────────────────┘
function ShopModule.GetItems()
    return _ShopItems
end

function ShopModule.PurchaseItem(itemName, quantity, pressedCF, onDone)
    if _isBuying               then return false, "already buying"    end
    if not _ShopItems          then return false, "not initialised"   end

    local item
    for _, i in ipairs(_ShopItems) do
        if i.Name == itemName then item = i; break end
    end

    if not item                     then return false, "item not found"    end
    if not item.Store               then return false, "item has no store" end
    if not StoreConfigs[item.Store] then return false, "no store config"   end

    quantity  = math.max(1, quantity or 1)
    pressedCF = pressedCF or (function()
        local c = Player.Character
        local r = c and c:FindFirstChild("HumanoidRootPart")
        return r and r.CFrame
    end)()

    task.spawn(function()
        RunBuyLoop(item, quantity, pressedCF, onDone)
    end)

    return true
end

function ShopModule.PurchaseSingleBlueprint(boxItemName)
    if _isBuying then return false, "already buying" end
    if not _ShopItems then
        _ShopItems = LoadItemList()
        if not _ShopItems then return false, "item list unavailable" end
    end

    local pb = Player:FindFirstChild("PlayerBlueprints")
    local bf = pb and pb:FindFirstChild("Blueprints")
    if bf and bf:FindFirstChild(boxItemName) then return true, "already owned" end

    local item
    for _, i in ipairs(_ShopItems) do
        if i.BoxItemName == boxItemName and i.IsBlueprint then item = i; break end
    end
    if not item then return false, "blueprint not found in shop" end

    local funds = FetchFunds()
    if not funds then return false, "could not check funds" end
    if funds < item.Price then return false, "insufficient funds (need $" .. item.Price .. ")" end

    local parts = ResolveItemParts(item, 1)
    if #parts == 0 then return false, "no stock in store" end
    local mainPart = parts[1]
    if not mainPart or not mainPart.Parent then return false, "item unavailable" end

    FetchAllNPCIDs()
    local purchased = PurchaseBlueprintPart(mainPart, item)
    if not purchased then return false, "purchase failed" end

    local opened = OpenBlueprintBox(boxItemName)
    if not opened then return false, "box open failed (blueprint may still be acquired)" end

    return true, "purchased"
end

return ShopModule]=], "Shop"))() end
__modules["ModTree"] = function() return assert(loadstring([=[-- [[ MOD TREE MODULE ]]
-- Designed for Dynxe LT2 UI Engine

local ModTreeModule = {}

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")

local Player      = Players.LocalPlayer
local Mouse       = Player:GetMouse()
local RemoteProxy = ReplicatedStorage:WaitForChild("Interaction"):WaitForChild("RemoteProxy")

local ClientPlacedBlueprint = ReplicatedStorage
    :WaitForChild("PlaceStructure")
    :WaitForChild("ClientPlacedBlueprint")

local _LOT = nil
local _Lib = nil

function ModTreeModule.SetLOT(lot) _LOT = lot end

-- ============================================================
-- DEBUG  (default OFF — flip to true to see console output)
-- ============================================================
local _debugMode = false

local function DebugLog(level, ...)
    if not _debugMode then return end
    if level == "warn" then warn(...) else print(...) end
end

-- Constants
local MOD_TP_CF            = CFrame.new(-1420, 380, 1400)
local DROP_ZONE_CF         = CFrame.new(-360, 92, -100)
local DISAPPEAR_TIMEOUT    = 60
local CHOP_FIRES           = 100
local CHOP_FIRE_DELAY      = 0.03
local CHOP_CONFIRM_TIMEOUT = 40

-- Blueprint placement constants
local BLUEPRINT_NAME  = "Wall2"
local TILE_END_OFFSET = CFrame.new(0, 5, -1.8)
local TILE_OFFSET_4L  = CFrame.new(0, 8.5, -1.8)
local MATCH_TOLERANCE = 1

-- Session state
local _isModding      = false
local _isModSawmill   = false
local _currentSession = nil

-- ┌─────────────────────────────────────────────────────────────────┐
-- │  Module-level alive refs — stored here so the cancel handlers   │
-- │  can set [1] = false and immediately unblock any WaitFor loop.  │
-- └─────────────────────────────────────────────────────────────────┘
local _modAliveRef     = { false }
local _sawmillAliveRef = { false }

-- ============================================================
-- NOTIFY HELPER
-- ============================================================

local function Notify(title, text)
    if _Lib and _Lib.Notify then
        _Lib:Notify(title, text)
    end
end

local function NotifyDebug(title, text)
    Notify(title, text)
    DebugLog("print", ("[%s] %s"):format(title, text))
end

-- ============================================================
-- SAWMILL BLUEPRINT HELPERS
-- ============================================================

local function GetBlueprintOffset(sawmill)
    local itemName = sawmill:FindFirstChild("ItemName")
    if itemName and itemName.Value == "Sawmill4L" then return TILE_OFFSET_4L end
    return TILE_END_OFFSET
end

local function GetSawmillParticlesCF(sawmill)
    local particles = sawmill:FindFirstChild("Particles", true)
    if particles and particles:IsA("BasePart") then return particles.CFrame end
    return select(1, sawmill:GetBoundingBox())
end

local function FindExistingBlueprint(targetCF)
    local pm = workspace:FindFirstChild("PlayerModels")
    if not pm then return nil end
    for _, model in ipairs(pm:GetChildren()) do
        local itemName = model:FindFirstChild("ItemName")
        if not itemName or itemName.Value ~= BLUEPRINT_NAME then continue end
        local owner       = model:FindFirstChild("Owner")
        local ownerString = owner and owner:FindFirstChild("OwnerString")
        local ownerVal    = owner and owner.Value
        local isOwner = (ownerString and ownerString.Value == Player.Name)
                     or (ownerVal    and ownerVal           == Player)
        if not isOwner then continue end
        local cf = (model:FindFirstChild("MainCFrame") and model.MainCFrame.Value)
                or (model.PrimaryPart and model.PrimaryPart.CFrame)
                or model:GetPivot()
        if (cf.Position - targetCF.Position).Magnitude <= MATCH_TOLERANCE then
            return model
        end
    end
    return nil
end

local function PlaceBlueprintAtSawmill(sawmill)
    local particlesCF = GetSawmillParticlesCF(sawmill)
    local offset      = GetBlueprintOffset(sawmill)
    local finalCF     = particlesCF * offset * CFrame.Angles(math.rad(90), 0, 0)
    local existing    = FindExistingBlueprint(finalCF)
    if existing then
        DebugLog("print", "[ModTree] Blueprint already at sawmill — skipping placement.")
        return false
    end
    DebugLog("print", "[ModTree] Placing blueprint at sawmill output...")
    ClientPlacedBlueprint:FireServer(BLUEPRINT_NAME, finalCF, Player)
    DebugLog("print", "[ModTree] Blueprint placed.")
    return true  -- newly placed
end

-- ============================================================
-- AXE HELPERS
-- ============================================================

local function ReadAxeName(tool)
    if not tool then return nil end
    local tip = tool:FindFirstChild("ToolTip")
    return (tip and tip:IsA("StringValue")) and tip.Value or tool.ToolTip
end

local function GetBestAxe(treeClass)
    local candidates = {}

    local function TryAdd(tool)
        if not tool:IsA("Tool") or tool.Name == "BlueprintTool" then return end
        local name = ReadAxeName(tool)
        if not name then return end
        local score = treeClass
            and _G.LT2Axes.GetDamage(name, treeClass)
            or (1 / (_G.LT2Axes.Rank[name] or 2^53))
        table.insert(candidates, { tool = tool, name = name, score = score })
    end

    local char = Player.Character
    if char then
        local equipped = char:FindFirstChildOfClass("Tool")
        if equipped then TryAdd(equipped) end
    end
    for _, tool in ipairs(Player.Backpack:GetChildren()) do TryAdd(tool) end

    if #candidates == 0 then return nil, nil, 0 end
    table.sort(candidates, function(a, b) return a.score > b.score end)

    local best = candidates[1]
    return best.tool, best.name, best.score
end

-- ============================================================
-- TREE ANALYSIS
-- ============================================================

local function AnalyzeTree(treeModel)
    local entries = {}

    for _, part in ipairs(treeModel:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "Stump" then
            local idVal = part:FindFirstChild("ID")
            if idVal and (idVal:IsA("IntValue") or idVal:IsA("NumberValue")) then
                local childIDs    = {}
                local childFolder = part:FindFirstChild("ChildIDs")
                if childFolder then
                    for _, child in ipairs(childFolder:GetChildren()) do
                        if child.Name == "Child" and (child:IsA("IntValue") or child:IsA("NumberValue")) then
                            table.insert(childIDs, child.Value)
                        end
                    end
                end
                table.insert(entries, {
                    part        = part,
                    id          = idVal.Value,
                    childIDs    = childIDs,
                    hasChildren = #childIDs > 0,
                })
            end
        end
    end

    table.sort(entries, function(a, b) return a.id < b.id end)

    local stumpEntry, targetEntry = entries[1], nil
    for i = #entries, 1, -1 do
        if entries[i].hasChildren then targetEntry = entries[i]; break end
    end

    local tipID = nil
    if targetEntry then
        for _, cid in ipairs(targetEntry.childIDs) do
            if not tipID or cid > tipID then tipID = cid end
        end
    end

    return { all = entries, stump = stumpEntry, target = targetEntry, tipID = tipID }
end

-- ============================================================
-- CLICK HELPERS
-- ============================================================

local function GetAncestorModel(instance)
    local current = instance
    while current and not current:IsA("Model") do current = current.Parent end
    return current
end

local SAWMILL_NAMES = {
    Sawmill = true, Sawmill2 = true, Sawmill3 = true,
    Sawmill4 = true, Sawmill4L = true,
}

local function IsValidSawmill(model)
    if not model or not model:IsA("Model") then return false end
    local itemName = model:FindFirstChild("ItemName")
    return itemName and itemName:IsA("StringValue") and SAWMILL_NAMES[itemName.Value] == true
end

local function IsValidTree(model)
    if not model or not model:IsA("Model") then return false end
    local logModels = workspace:FindFirstChild("LogModels")
    if not logModels or model.Parent ~= logModels then return false end
    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("BasePart") and desc:FindFirstChild("ID") then return true end
    end
    return false
end

-- WaitForSawmillClick: waits for a single sawmill click, unchanged from original.
local function WaitForSawmillClick(aliveRef)
    local result, done, conn = nil, false, nil
    conn = Mouse.Button1Down:Connect(function()
        local target = Mouse.Target
        if not target then return end
        local playerModels = workspace:FindFirstChild("PlayerModels")
        if not playerModels then return end
        local current = target
        while current and current.Parent ~= playerModels do current = current.Parent end
        if IsValidSawmill(current) then
            result = current; done = true; conn:Disconnect()
        end
    end)
    while not done and aliveRef[1] do task.wait() end
    if conn.Connected then conn:Disconnect() end
    return result
end

-- WaitForTreeQueueThenSawmill:
--   Lets the player click any number of trees to queue them.
--   The FIRST sawmill click ends selection and returns both the queue
--   and the selected sawmill — no extra button needed.
local function WaitForTreeQueueThenSawmill(aliveRef)
    local queue    = {}
    local queueSet = {}
    local sawmill  = nil
    local done     = false
    local conn

    conn = Mouse.Button1Down:Connect(function()
        if not aliveRef[1] or done then return end
        local target = Mouse.Target
        if not target then return end

        -- Check for sawmill first — this ends selection.
        do
            local playerModels = workspace:FindFirstChild("PlayerModels")
            if playerModels then
                local current = target
                while current and current.Parent ~= playerModels do
                    current = current.Parent
                end
                if IsValidSawmill(current) then
                    sawmill = current
                    done    = true
                    conn:Disconnect()
                    return
                end
            end
        end

        -- Otherwise check for a tree and add to queue.
        local model = GetAncestorModel(target)
        if not IsValidTree(model) then return end
        if queueSet[model] then
            Notify("Mod Tree", ("Already queued — %d tree(s) selected. Click your sawmill when ready."):format(#queue))
            return
        end
        queueSet[model] = true
        table.insert(queue, model)
        DebugLog("print", ("[ModTree] Tree queued: %s (total=%d)"):format(model.Name, #queue))
        Notify("Mod Tree", ("%d tree(s) queued — click your sawmill when ready."):format(#queue))
    end)

    while not done and aliveRef[1] do task.wait() end
    if conn.Connected then conn:Disconnect() end

    return queue, sawmill
end

-- ============================================================
-- REMOTE CUT
-- ============================================================

local function FireCutSection(section, tool, axeName, treeClass, stopFn)
    if not section or not section.Parent then return false end

    local idObj = section:FindFirstChild("ID")
    if not idObj then
        DebugLog("warn", "[ModTree] FireCutSection: no ID on", section:GetFullName()); return false
    end

    local cutEvent, current = nil, section
    while current and current ~= workspace do
        cutEvent = current:FindFirstChild("CutEvent")
        if cutEvent then break end
        current = current.Parent
    end
    if not cutEvent then
        DebugLog("warn", "[ModTree] FireCutSection: CutEvent not found for", section:GetFullName()); return false
    end

    local char = Player.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.lookAt(section.Position + section.CFrame.RightVector * 4, section.Position)
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        task.wait(0.1)
    end

    local sizeY  = section.Size.Y
    local height = sizeY * math.clamp(0.1 + (8 - sizeY) / 60, 0.1, 0.2)
    local damage = _G.LT2Axes.GetDamage(axeName, treeClass)

    local args = {
        sectionId    = idObj.Value,
        faceVector   = Vector3.new(0, 0, -1),
        height       = height,
        hitPoints    = damage,
        cooldown     = 0,
        cuttingClass = "Axe",
        tool         = tool,
    }

    for _ = 1, CHOP_FIRES do
        if not section.Parent then break end
        if stopFn and stopFn() then break end
        RemoteProxy:FireServer(cutEvent, args)
        task.wait(CHOP_FIRE_DELAY)
    end

    return true
end

-- ============================================================
-- LAVA HELPERS
-- ============================================================

local function GetAllLavaTouchParts()
    local parts = {}
    local volcano = workspace:FindFirstChild("Region_Volcano")
    if not volcano then
        DebugLog("warn", "[ModTree] Region_Volcano not found.")
        return parts
    end
    for _, child in ipairs(volcano:GetChildren()) do
        for _, desc in ipairs(child:GetDescendants()) do
            if desc:IsA("BasePart")
            and (desc:FindFirstChildOfClass("TouchTransmitter") or desc:FindFirstChild("TouchInterest")) then
                table.insert(parts, desc)
            end
        end
    end
    return parts
end

-- ============================================================
-- LOT HELPERS
-- ============================================================

local function SafeTeleportMany(batch)
    if _LOT.IsBusy() then _LOT.WaitForBatch() end
    _LOT.TeleportMany(batch)
    if _LOT.IsBusy() then _LOT.WaitForBatch() end
end

-- ============================================================
-- SINGLE TREE MOD
-- ============================================================

local function RunSingleTreeMod(aliveRef, sawmill, sawmillCF, treeModel, treeIndex, treeTotal)
    local session = {
        touchParts   = nil,
        touchSizes   = nil,
        touchCFs     = nil,
        lavaRestored = false,
    }

    local finished = false

    local function RestoreLava()
        if session.lavaRestored then return end
        session.lavaRestored = true
        if session.touchParts then
            for i, tp in ipairs(session.touchParts) do
                pcall(function()
                    if tp and tp.Parent then
                        tp.Size   = session.touchSizes[i]
                        tp.CFrame = session.touchCFs[i]
                    end
                end)
            end
        end
    end

    local function Cancelled()
        return (not aliveRef[1]) or (not _isModding)
    end

    local function Sleep(duration)
        local deadline = tick() + duration
        while tick() < deadline do
            if Cancelled() then return false end
            task.wait()
        end
        return not Cancelled()
    end

    local function Bail(title, text)
        if not finished then
            finished = true
            RestoreLava()
            if title then Notify(title, text) end
        end
        return false
    end

    local prefix = ("[%d/%d]"):format(treeIndex, treeTotal)

    -- ── Analyse tree ─────────────────────────────────────────
    DebugLog("print", ("[ModTree] %s Analysing tree: %s"):format(prefix, treeModel.Name))
    local analysis = AnalyzeTree(treeModel)

    if #analysis.all == 0 then
        return Bail("Mod Tree", prefix .. " No wood sections found.")
    end
    if not analysis.target then
        return Bail("Mod Tree", prefix .. " No weld-holding section found.")
    end

    local baseSection = nil
    for _, entry in ipairs(analysis.all) do
        if entry.id == 1 then baseSection = entry.part; break end
    end
    if not baseSection then baseSection = analysis.all[1].part end
    if not baseSection then
        return Bail("Mod Tree", prefix .. " Could not resolve base section.")
    end

    local treeClassObj = treeModel:FindFirstChild("TreeClass")
    local treeClass    = treeClassObj and treeClassObj.Value or nil

    local logModels  = workspace:FindFirstChild("LogModels")
    local beforeLogs = {}
    if logModels then
        for _, m in ipairs(logModels:GetChildren()) do beforeLogs[m] = true end
    end

    local function GetOurNewLogModels()
        local result = {}
        if logModels then
            for _, m in ipairs(logModels:GetChildren()) do
                if not beforeLogs[m] and m:IsA("Model") then
                    table.insert(result, m)
                end
            end
        end
        return result
    end

    local function FindSectionInScope(targetID)
        for _, entry in ipairs(analysis.all) do
            if entry.id == targetID and entry.part and entry.part.Parent then
                return entry.part
            end
        end
        for _, desc in ipairs(treeModel:GetDescendants()) do
            if desc:IsA("BasePart") then
                local idVal = desc:FindFirstChild("ID")
                if idVal and idVal.Value == targetID then return desc end
            end
        end
        for _, model in ipairs(GetOurNewLogModels()) do
            for _, desc in ipairs(model:GetDescendants()) do
                if desc:IsA("BasePart") then
                    local idVal = desc:FindFirstChild("ID")
                    if idVal and idVal.Value == targetID then return desc end
                end
            end
        end
        return nil
    end

    if Cancelled() then return Bail(nil, nil) end

    -- ── LOT to drop zone, then CFrame to mod zone ─────────────
    DebugLog("print", ("[ModTree] %s Teleporting tree to mod zone..."):format(prefix))
    local tpOk, tpErr = pcall(function()
        SafeTeleportMany({ { target = baseSection, goalCF = DROP_ZONE_CF } })
        baseSection.CFrame = MOD_TP_CF
    end)
    if not tpOk then
        return Bail("Mod Tree", prefix .. " Teleport failed: " .. tostring(tpErr))
    end
    if Cancelled() then return Bail(nil, nil) end

    -- ── Shrink lava touch parts ───────────────────────────────
    local touchParts = GetAllLavaTouchParts()
    if #touchParts == 0 then
        return Bail("Mod Tree", prefix .. " No lava touch parts found.")
    end
    DebugLog("print", ("[ModTree] %s Found %d lava touch part(s)."):format(prefix, #touchParts))

    local touchSizes, touchCFs = {}, {}
    for i, tp in ipairs(touchParts) do
        touchSizes[i] = tp.Size
        touchCFs[i]   = tp.CFrame
        pcall(function() tp.Size = Vector3.new(0.1, 0.1, 0.1) end)
    end
    session.touchParts = touchParts
    session.touchSizes = touchSizes
    session.touchCFs   = touchCFs

    -- ── Lock lava parts onto weld-holder ("Burning") ──────────
    local targetSection = analysis.target.part
    local tipID         = analysis.tipID
    DebugLog("print", ("[ModTree] %s Target ID=%d | Tip ID=%d"):format(prefix, analysis.target.id, tipID))

    local MAX_BURN_ATTEMPTS = 5
    local burnConfirmed     = false

    for attempt = 1, MAX_BURN_ATTEMPTS do
        if Cancelled() then break end

        if attempt > 1 then
            DebugLog("print", ("[ModTree] %s Retrying burn (%d/%d)."):format(prefix, attempt, MAX_BURN_ATTEMPTS))
            pcall(function() baseSection.CFrame = MOD_TP_CF end)
            if not Sleep(0.1) then break end
        end

        local lockConn = RunService.Heartbeat:Connect(function()
            pcall(function()
                local targetCF = targetSection.CFrame
                for _, tp in ipairs(touchParts) do
                    tp.Size   = Vector3.new(0.1, 0.1, 0.1)
                    tp.CFrame = targetCF
                end
            end)
        end)
        local lockOk = Sleep(0.1)
        lockConn:Disconnect()

        for i, tp in ipairs(touchParts) do
            pcall(function() tp.Size = touchSizes[i]; tp.CFrame = touchCFs[i] end)
        end

        if not lockOk then break end
        if not Sleep(0.1) then break end

        if treeModel:FindFirstChild("Burning") then
            DebugLog("print", ("[ModTree] %s Burning confirmed (attempt %d/%d)."):format(prefix, attempt, MAX_BURN_ATTEMPTS))
            burnConfirmed = true
            break
        end

        DebugLog("warn", ("[ModTree] %s Burning not detected (attempt %d/%d)."):format(prefix, attempt, MAX_BURN_ATTEMPTS))
    end

    RestoreLava()

    if Cancelled() then return Bail(nil, nil) end
    if not burnConfirmed then
        return Bail("Mod Tree", prefix .. " Could not confirm the tree is burning.")
    end

    -- ── Reposition sections ───────────────────────────────────
    DebugLog("print", ("[ModTree] %s Repositioning sections."):format(prefix))
    local tipSection = FindSectionInScope(tipID)
    pcall(function() targetSection.CFrame = CFrame.new(1279, 52, 2328) end)
    pcall(function() baseSection.CFrame = DROP_ZONE_CF end)

    if tipSection and tipSection.Parent then
        local halfHeight = tipSection.Size.Y / 2
        local adjustedCF = sawmillCF * CFrame.new(0, 0, 0)
        pcall(function() tipSection.CFrame = adjustedCF end)
        DebugLog("print", ("[ModTree] %s Tip (ID=%d) placed at sawmill (height offset %.2f)."):format(prefix, tipID, halfHeight))
        if not Sleep(1) then return Bail(nil, nil) end
    else
        DebugLog("warn", ("[ModTree] %s Tip (ID=%d) not available at burn time."):format(prefix, tipID))
    end

    -- ── Wait for weld-holder to be destroyed ──────────────────
    DebugLog("print", ("[ModTree] %s Waiting for weld-holder removal..."):format(prefix))
    local disappearDeadline = tick() + DISAPPEAR_TIMEOUT
    while tick() < disappearDeadline do
        if Cancelled() then return Bail(nil, nil) end
        if not targetSection or not targetSection.Parent then break end
        task.wait(0.1)
    end
    if targetSection and targetSection.Parent then
        DebugLog("warn", ("[ModTree] %s Weld-holder did not disappear in time — proceeding."):format(prefix))
    else
        DebugLog("print", ("[ModTree] %s Weld-holder removed."):format(prefix))
    end

    -- ── Chop the stump section ────────────────────────────────
    DebugLog("print", ("[ModTree] %s Chopping stump..."):format(prefix))

    local stumpID      = analysis.stump and analysis.stump.id or 1
    local stumpSection = FindSectionInScope(stumpID)

    local tool, axeName = GetBestAxe(treeClass)
    if not tool then
        DebugLog("warn", ("[ModTree] %s No axe found — skipping stump chop."):format(prefix))
        Notify("Mod Tree", prefix .. " No axe found — equip one to chop the stump.")
    else
        DebugLog("print", ("[ModTree] %s Using '%s' (treeClass=%s)."):format(prefix, axeName, tostring(treeClass)))

        local initialSize = stumpSection and stumpSection.Size
                         or Vector3.new(math.huge, math.huge, math.huge)

        local function TreeHasFallen()
            if not stumpSection or not stumpSection.Parent then return true end
            return stumpSection.Size.Y < initialSize.Y - 1
        end

        local chopDone     = false
        local chopDeadline = tick() + CHOP_CONFIRM_TIMEOUT

        while not chopDone and tick() < chopDeadline do
            if Cancelled() then return Bail(nil, nil) end
            if not stumpSection or not stumpSection.Parent then
                stumpSection = FindSectionInScope(stumpID)
                if stumpSection then initialSize = stumpSection.Size end
            end
            if not stumpSection or not stumpSection.Parent then
                DebugLog("warn", ("[ModTree] %s Stump section lost — aborting chop."):format(prefix)); break
            end
            FireCutSection(stumpSection, tool, axeName, treeClass,
                function() return Cancelled() or TreeHasFallen() end)
            chopDone = TreeHasFallen()
        end

        if Cancelled() then return Bail(nil, nil) end

        if chopDone then
            DebugLog("print", ("[ModTree] %s Chop confirmed."):format(prefix))
        else
            DebugLog("warn", ("[ModTree] %s Chop timed out — proceeding anyway."):format(prefix))
        end
    end

    -- ── Success ───────────────────────────────────────────────
    if Cancelled() then return Bail(nil, nil) end
    DebugLog("print", ("[ModTree] %s Done."):format(prefix))
    finished = true
    return true
end

-- ============================================================
-- MAIN MOD LOOP
-- ============================================================

local function RunModLoop(onDone)
    _modAliveRef = { true }
    local aliveRef = _modAliveRef

    _isModding = true

    local char0    = Player.Character
    local root0    = char0 and char0:FindFirstChild("HumanoidRootPart")
    local preModCF = root0 and root0.CFrame

    local finished = false

    local function ReturnPlayer(cf)
        if not cf then return end
        local ch  = Player.Character
        local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
        if hrp then
            pcall(function()
                hrp.CFrame = cf
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end)
        end
    end

    local function Finish(notifyTitle, notifyText, returnCF)
        if finished then return end
        finished = true
        ReturnPlayer(returnCF or preModCF)
        if notifyTitle then Notify(notifyTitle, notifyText) end
        _isModding      = false
        _currentSession = nil
        if onDone then onDone() end
    end

    local function Cancelled()
        return (not aliveRef[1]) or (not _isModding)
    end

    local function FinishCancel()
        DebugLog("print", "[ModTree] Cancelled — returning player.")
        Finish(nil, nil, preModCF)
    end

    local function FinishError(msg)
        DebugLog("warn", "[ModTree] " .. msg)
        Finish("Mod Tree", "Failed: " .. msg, preModCF)
    end

    -- ── Preflight ─────────────────────────────────────────────
    if not _LOT    then return FinishError("LOT teleport module is not available.") end
    if not _G.LT2Axes then return FinishError("LT2Axes is not loaded.") end

    -- ── Step 1: collect tree queue; sawmill click ends selection ─
    NotifyDebug("Mod Tree", "Click trees to queue them, then click your sawmill to start.")

    local treeQueue, sawmill = WaitForTreeQueueThenSawmill(aliveRef)

    if Cancelled() then return FinishCancel() end
    if not sawmill then return FinishError("No sawmill was selected.") end
    if #treeQueue == 0 then return FinishError("No trees were selected.") end

    DebugLog("print", ("[ModTree] %d tree(s) queued. Sawmill: %s"):format(#treeQueue, sawmill.Name))

    -- Resolve sawmill CF once, shared across all trees.
    local sawmillParticles = sawmill:FindFirstChild("Particles", true)
    local sawmillCF
    if sawmillParticles and sawmillParticles:IsA("BasePart") then
        sawmillCF = sawmillParticles.CFrame
    else
        DebugLog("warn", "[ModTree] Particles part not found — using bounding box.")
        sawmillCF = select(1, sawmill:GetBoundingBox())
    end

    local function SawmillStandCF()
        return sawmillCF * CFrame.new(0, 8, 6)
    end

    NotifyDebug("Mod Tree", ("Processing %d tree(s)..."):format(#treeQueue))

    -- ── Step 2: process each tree in order ───────────────────
    local successCount = 0
    for i, treeModel in ipairs(treeQueue) do
        if Cancelled() then return FinishCancel() end

        DebugLog("print", ("[ModTree] Starting tree %d/%d: %s"):format(i, #treeQueue, treeModel.Name))
        Notify("Mod Tree", ("Tree %d/%d — modding %s"):format(i, #treeQueue, treeModel.Name))

        local ok = RunSingleTreeMod(aliveRef, sawmill, sawmillCF, treeModel, i, #treeQueue)

        if Cancelled() then return FinishCancel() end

        if ok then
            successCount = successCount + 1
            DebugLog("print", ("[ModTree] Tree %d/%d succeeded."):format(i, #treeQueue))
        else
            DebugLog("warn", ("[ModTree] Tree %d/%d failed/skipped."):format(i, #treeQueue))
        end

        -- Brief pause between trees so the game can settle.
        if i < #treeQueue then task.wait(1) end
    end

    -- ── Step 3: final summary ─────────────────────────────────
    local summary = ("Done! %d/%d tree(s) modded."):format(successCount, #treeQueue)
    DebugLog("print", "[ModTree] " .. summary)
    Finish("Mod Tree", summary, SawmillStandCF())
end

-- ============================================================
-- MODULE INIT
-- ============================================================

function ModTreeModule.Init(Tab, lot, lib)
    if lot ~= nil then _LOT = lot end
    if lib ~= nil then _Lib = lib end

    Tab:CreateSection("Mod Tree Options")

    -- ── Mod Sawmill button ──────────────────────────────────
    local ModSawmillBtn

    local function SetSawmillState(active)
        if ModSawmillBtn then
            ModSawmillBtn:SetText(active and "Cancel" or "Sawmill")
        end
    end

    ModSawmillBtn = Tab:CreateAction("Mod Sawmill", "Sawmill", function()
        if _isModSawmill then
            _isModSawmill       = false
            _sawmillAliveRef[1] = false
            SetSawmillState(false)
            DebugLog("print", "[ModTree] Mod Sawmill cancelled.")
            return
        end

        _isModSawmill = true
        SetSawmillState(true)

        task.spawn(function()
            _sawmillAliveRef = { true }
            local aliveRef = _sawmillAliveRef

            local function done()
                _isModSawmill = false
                SetSawmillState(false)
            end

            NotifyDebug("Mod Sawmill", "Click your sawmill.")

            local sawmill = WaitForSawmillClick(aliveRef)
            if not aliveRef[1] then return end

            if not sawmill then
                Notify("Mod Sawmill", "No sawmill selected.")
                return done()
            end

            local ok, placed = pcall(function() return PlaceBlueprintAtSawmill(sawmill) end)
            if ok then
                if placed then
                    Notify("Mod Sawmill", "Fill the blueprint!")
                else
                    Notify("Mod Sawmill", "Blueprint already placed — fill it if you haven't!")
                end
            else
                DebugLog("warn", "[ModTree] Mod Sawmill failed: " .. tostring(placed))
                Notify("Mod Sawmill", "Failed to place blueprint.")
            end

            done()
        end)
    end, false)

    ModSawmillBtn:AddTooltip(
        "Places a Floor2 blueprint at your sawmill's output end.\n" ..
        "Run this BEFORE modding a tree.\n" ..
        "After placement, fill the blueprint with wood planks\n" ..
        "so the modded log lands on a full surface."
    )

    -- ── Mod Tree button ─────────────────────────────────────
    local ModBtn

    local function SetState(modding)
        if ModBtn then ModBtn:SetText(modding and "Cancel" or "Tree") end
    end

    ModBtn = Tab:CreateAction("Mod Tree", "Tree", function()
        if _isModding then
            _isModding      = false
            _modAliveRef[1] = false
            SetState(false)
            DebugLog("print", "[ModTree] Cancel requested.")
            return
        end

        SetState(true)
        task.spawn(function() RunModLoop(function() SetState(false) end) end)
    end, false)

    ModBtn:AddTooltip(
        "Click trees to queue them, then click your sawmill to begin.\n" ..
        "Each tree is modded one at a time in order."
    )
end

return ModTreeModule]=], "ModTree"))() end
__modules["TreeSearcher"] = function() return assert(loadstring([[local TreeSearcher = {}

function TreeSearcher.Init(Tab, Library)
    local Players          = game:GetService("Players")
    local TeleportService  = game:GetService("TeleportService")
    local HttpService      = game:GetService("HttpService")
    local UserInputService = game:GetService("UserInputService")
    local CoreGui          = game:GetService("CoreGui")
    local TweenService     = game:GetService("TweenService")
    local player           = Players.LocalPlayer

    local FOLDER      = "Dynxe"
    local STATE_FILE  = FOLDER .. "/cc_state.json"
    local BOOTSTRAP_FILE = FOLDER .. "/cc_bootstrap.lua"
    local QUEUE_LINE  = "pcall(function() loadstring(readfile('Dynxe/cc_bootstrap.lua'))() end)"
    local HUD_NAME    = "TreeSearcherHUD"

    local LOAD_WAIT   = 6
    local RETRY_WAIT  = 5
    local HOP_TIMEOUT = 20

    local SIZE_THRESHOLDS = {
        CaveCrawler = { Small = 0, Medium = 1000, Large = 2000 },
        LoneCave    = { Small = 0, Medium = 1000, Large = 2000 },
    }

    if not isfolder(FOLDER) then makefolder(FOLDER) end

    local function ReadState()
        local ok, data = pcall(readfile, STATE_FILE)
        if not ok or not data or data == "" then return nil end
        local ok2, decoded = pcall(HttpService.JSONDecode, HttpService, data)
        return ok2 and decoded or nil
    end

    local function WriteState(state)
        local ok, encoded = pcall(HttpService.JSONEncode, HttpService, state)
        if ok then pcall(writefile, STATE_FILE, encoded) end
    end

    local function SetActive(active)
        local state = ReadState() or {}
        state.active = active
        WriteState(state)
    end

    local function DestroyHUD()
        local existing = CoreGui:FindFirstChild(HUD_NAME)
        if existing then existing:Destroy() end
    end

    local function CreateHUD(treeType)
        DestroyHUD()
        local gui = Instance.new("ScreenGui")
        gui.Name            = HUD_NAME
        gui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
        gui.DisplayOrder    = 998
        gui.ResetOnSpawn    = false
        gui.IgnoreGuiInset  = true
        gui.Parent          = CoreGui

        local bar = Instance.new("Frame")
        bar.Name                   = "Bar"
        bar.Size                   = UDim2.new(1, 0, 0, 58)
        bar.Position               = UDim2.new(0, 0, 0.9, -29)
        bar.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
        bar.BackgroundTransparency = 0.45
        bar.BorderSizePixel        = 0
        bar.Parent                 = gui

        local topLine = Instance.new("Frame")
        topLine.Size             = UDim2.new(1, 0, 0, 1)
        topLine.BackgroundColor3 = Color3.fromRGB(74, 120, 255)
        topLine.BackgroundTransparency = 0.5
        topLine.BorderSizePixel  = 0
        topLine.Parent           = bar

        local botLine = Instance.new("Frame")
        botLine.Size             = UDim2.new(1, 0, 0, 1)
        botLine.Position         = UDim2.new(0, 0, 1, -1)
        botLine.BackgroundColor3 = Color3.fromRGB(74, 120, 255)
        botLine.BackgroundTransparency = 0.5
        botLine.BorderSizePixel  = 0
        botLine.Parent           = bar

        local topRow = Instance.new("Frame")
        topRow.Name                   = "TopRow"
        topRow.Size                   = UDim2.new(1, 0, 0, 28)
        topRow.Position               = UDim2.new(0, 0, 0, 2)
        topRow.BackgroundTransparency = 1
        topRow.Parent                 = bar

        local badge = Instance.new("TextLabel")
        badge.Size                   = UDim2.new(0, 160, 1, 0)
        badge.Position               = UDim2.new(0, 16, 0, 0)
        badge.BackgroundTransparency = 1
        badge.Text                   = "TREE SEARCHER"
        badge.TextColor3             = Color3.fromRGB(74, 120, 255)
        badge.Font                   = Enum.Font.GothamBold
        badge.TextSize               = 13
        badge.TextXAlignment         = Enum.TextXAlignment.Left
        badge.Parent                 = topRow

        local treeLabel = Instance.new("TextLabel")
        treeLabel.Size               = UDim2.new(1, -340, 1, 0)
        treeLabel.Position           = UDim2.new(0, 180, 0, 0)
        treeLabel.BackgroundTransparency = 1
        treeLabel.Text               = treeType or "Unknown"
        treeLabel.TextColor3         = Color3.fromRGB(220, 220, 220)
        treeLabel.Font               = Enum.Font.GothamMedium
        treeLabel.TextSize           = 13
        treeLabel.TextXAlignment     = Enum.TextXAlignment.Center
        treeLabel.Parent             = topRow

        local f1hint = Instance.new("TextLabel")
        f1hint.Size                  = UDim2.new(0, 140, 1, 0)
        f1hint.AnchorPoint           = Vector2.new(1, 0)
        f1hint.Position              = UDim2.new(1, -16, 0, 0)
        f1hint.BackgroundTransparency = 1
        f1hint.Text                  = "F1 / Backspace to stop"
        f1hint.TextColor3            = Color3.fromRGB(100, 100, 110)
        f1hint.Font                  = Enum.Font.Gotham
        f1hint.TextSize              = 12
        f1hint.TextXAlignment        = Enum.TextXAlignment.Right
        f1hint.Parent                = topRow

        local div = Instance.new("Frame")
        div.Size             = UDim2.new(1, -32, 0, 1)
        div.Position         = UDim2.new(0, 16, 0, 30)
        div.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        div.BorderSizePixel  = 0
        div.Parent           = bar

        local statusLabel = Instance.new("TextLabel")
        statusLabel.Name                 = "StatusLabel"
        statusLabel.Size                 = UDim2.new(1, -32, 0, 24)
        statusLabel.Position             = UDim2.new(0, 16, 0, 32)
        statusLabel.BackgroundTransparency = 1
        statusLabel.Text                 = "Initializing..."
        statusLabel.TextColor3           = Color3.fromRGB(180, 180, 190)
        statusLabel.Font                 = Enum.Font.Gotham
        statusLabel.TextSize             = 12
        statusLabel.TextXAlignment       = Enum.TextXAlignment.Center
        statusLabel.Parent               = bar
    end

    local function SetHUDStatus(msg)
        local gui = CoreGui:FindFirstChild(HUD_NAME)
        if not gui then return end
        local bar   = gui:FindFirstChild("Bar")
        local label = bar and bar:FindFirstChild("StatusLabel")
        if label then label.Text = msg end
    end

    local function SetHUDFound(posStr, treeType)
        local gui = CoreGui:FindFirstChild(HUD_NAME)
        if not gui then return end
        local bar = gui:FindFirstChild("Bar")
        if not bar then return end
        TweenService:Create(bar, TweenInfo.new(0.4), {
            BackgroundColor3 = Color3.fromRGB(15, 55, 20)
        }):Play()
        local label = bar:FindFirstChild("StatusLabel")
        if label then
            label.Text       = treeType .. " found!  Position: " .. posStr .. "  |  F1 / Backspace to dismiss"
            label.TextColor3 = Color3.fromRGB(120, 230, 130)
        end
    end

    local BOOTSTRAP_SRC = [=[
task.wait(2)
local HttpService = game:GetService("HttpService")
local ok, raw = pcall(readfile, "Dynxe/cc_state.json")
if not ok or not raw or raw == "" then return end
local ok2, state = pcall(HttpService.JSONDecode, HttpService, raw)
if not ok2 or not state or state.active ~= true then return end

-- inline hopper using state values
local Players          = game:GetService("Players")
local TeleportService  = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")
local TweenService     = game:GetService("TweenService")
local player           = Players.LocalPlayer
local PLACE_ID         = game.PlaceId

local treeClass = state.treeType or "CaveCrawler"
local minVolume = state.minVolume or 0
local QUEUE_LINE  = "pcall(function() loadstring(readfile('Dynxe/cc_bootstrap.lua'))() end)"
local LOAD_WAIT   = 6
local RETRY_WAIT  = 5
local HOP_TIMEOUT = 20
local HUD_NAME    = "TreeSearcherHUD"

if getgenv()._ccRunning then return end
getgenv()._ccRunning = true

local function SaveActive(val)
    local ok3, raw2 = pcall(readfile, "Dynxe/cc_state.json")
    local st = {}
    if ok3 and raw2 then
        local ok4, d = pcall(HttpService.JSONDecode, HttpService, raw2)
        if ok4 and d then st = d end
    end
    st.active = val
    local ok5, enc = pcall(HttpService.JSONEncode, HttpService, st)
    if ok5 then pcall(writefile, "Dynxe/cc_state.json", enc) end
end

local function DestroyHUD()
    local e = CoreGui:FindFirstChild(HUD_NAME)
    if e then e:Destroy() end
end

local function CreateHUD(tt)
    DestroyHUD()
    local gui = Instance.new("ScreenGui")
    gui.Name = HUD_NAME; gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true; gui.DisplayOrder = 998
    gui.Parent = CoreGui
    local bar = Instance.new("Frame", gui)
    bar.Name = "Bar"
    bar.Size = UDim2.new(1,0,0,58)
    bar.Position = UDim2.new(0,0,0.9,-29)
    bar.BackgroundColor3 = Color3.fromRGB(0,0,0)
    bar.BackgroundTransparency = 0.45
    bar.BorderSizePixel = 0
    local sl = Instance.new("TextLabel", bar)
    sl.Name = "StatusLabel"
    sl.Size = UDim2.new(1,-32,0,24)
    sl.Position = UDim2.new(0,16,0,32)
    sl.BackgroundTransparency = 1
    sl.Text = "Scanning for " .. tt .. "..."
    sl.TextColor3 = Color3.fromRGB(180,180,190)
    sl.Font = Enum.Font.Gotham
    sl.TextSize = 12
    sl.TextXAlignment = Enum.TextXAlignment.Center
end

local function SetStatus(msg)
    local g = CoreGui:FindFirstChild(HUD_NAME)
    local b = g and g:FindFirstChild("Bar")
    local l = b and b:FindFirstChild("StatusLabel")
    if l then l.Text = msg end
end

local running = true
CreateHUD(treeClass)

UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and (input.KeyCode == Enum.KeyCode.F1 or input.KeyCode == Enum.KeyCode.Backspace) then
        running = false
        getgenv()._ccRunning = nil
        SaveActive(false)
        DestroyHUD()
    end
end)

local function GetTreeVolume(model)
    local total = 0
    for _, part in ipairs(model:GetChildren()) do
        if part.Name == "WoodSection" and part:IsA("BasePart") then
            total += part.Size.X * part.Size.Y * part.Size.Z
        end
    end
    return total
end

local function FindTree(cls)
    for _, folder in ipairs(workspace:GetChildren()) do
        if folder.Name:lower():match("treeregion") then
            for _, model in ipairs(folder:GetChildren()) do
                if model:IsA("Model") then
                    local tc = model:FindFirstChild("TreeClass")
                    if tc and tc:IsA("StringValue") and tc.Value == cls then
                        if minVolume > 0 and GetTreeVolume(model) < minVolume then continue end
                        return true, model
                    end
                end
            end
        end
    end
    return false, nil
end

local function SafeGet(url)
    local ok6, res = pcall(function() return game:HttpGet(url) end)
    return (ok6 and res and res ~= "") and res or nil
end

local function FetchServers()
    local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(PLACE_ID)
    local body = SafeGet(url)
    if not body then return {} end
    local ok7, dec = pcall(HttpService.JSONDecode, HttpService, body)
    return (ok7 and type(dec) == "table" and dec.data) or {}
end

local function ArmAndHop()
    local servers = FetchServers()
    local currentId = game.JobId
    local cands = {}
    for _, s in ipairs(servers) do
        if s.id ~= currentId and type(s.playing) == "number" and type(s.maxPlayers) == "number" and s.playing < s.maxPlayers then
            table.insert(cands, s)
        end
    end
    if #cands == 0 or not queue_on_teleport then return false end
    SaveActive(true)
    queue_on_teleport(QUEUE_LINE)
    local ok8 = pcall(TeleportService.TeleportToPlaceInstance, TeleportService, PLACE_ID, cands[math.random(1,#cands)].id, player)
    if not ok8 then SaveActive(false) return false end
    return true
end

task.wait(LOAD_WAIT)

while running do
    SetStatus("Scanning for " .. treeClass .. "...")
    local found, treeModel = FindTree(treeClass)
    if found then
        local pos = treeModel and treeModel:GetPivot().Position or Vector3.zero
        local posStr = ("%.1f, %.1f, %.1f"):format(pos.X, pos.Y, pos.Z)
        SetStatus(treeClass .. " found! " .. posStr .. " | F1 to dismiss")
        running = false
        getgenv()._ccRunning = nil
        SaveActive(false)
        break
    end
    if not running then break end
    SetStatus("Not found. Hopping...")
    local hopped = ArmAndHop()
    if hopped then
        local deadline = tick() + HOP_TIMEOUT
        while running and tick() < deadline do task.wait(1) end
    else
        SetStatus("No servers. Retrying...")
        task.wait(RETRY_WAIT)
    end
end
]=]

    Tab:CreateSection("Tree Server Search")

    local TREE_OPTIONS = { "CaveCrawler", "LoneCave", "BlueSpruce", "Spooky", "SpookyNeon" }
    local DISABLED     = { BlueSpruce = true, Spooky = true, SpookyNeon = true }

    local selectedTree = "CaveCrawler"
    local selectedSize = "Small"
    local searchActive = false
    local startBtn

    local treeDropdown = Tab:CreateDropdown("Target Tree", TREE_OPTIONS, "CaveCrawler", function(sel)
        if not DISABLED[sel] then selectedTree = sel end
    end)
    for name in pairs(DISABLED) do
        treeDropdown:SetOptionDisabled(name, true)
    end

    Tab:CreateDropdown("Size", { "Small", "Medium", "Large", "I DONT CARE (any)" }, "Small", function(sel)
        selectedSize = sel
    end)

    local function GetTreeVolume(model)
        local total = 0
        for _, part in ipairs(model:GetChildren()) do
            if part.Name == "WoodSection" and part:IsA("BasePart") then
                total += part.Size.X * part.Size.Y * part.Size.Z
            end
        end
        return total
    end

    local function FindTree(cls)
        local treeThresholds = SIZE_THRESHOLDS[cls] or { Small = 0, Medium = 0, Large = 0 }
        local minVol = treeThresholds[selectedSize] or 0
        for _, folder in ipairs(workspace:GetChildren()) do
            if folder.Name:lower():match("treeregion") then
                for _, model in ipairs(folder:GetChildren()) do
                    if model:IsA("Model") then
                        local tc = model:FindFirstChild("TreeClass")
                        if tc and tc:IsA("StringValue") and tc.Value == cls then
                            if minVol > 0 and GetTreeVolume(model) < minVol then continue end
                            return true, model
                        end
                    end
                end
            end
        end
        return false, nil
    end

    local function SafeHttpGet(url)
        local ok, res = pcall(function() return game:HttpGet(url) end)
        if ok and res and res ~= "" then return res end
        return nil
    end

    local function FetchServers()
        local url  = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(game.PlaceId)
        local body = SafeHttpGet(url)
        if not body then return {} end
        local ok, decoded = pcall(HttpService.JSONDecode, HttpService, body)
        return (ok and type(decoded) == "table" and decoded.data) or {}
    end

    local function WriteFiles()
        if not isfolder(FOLDER) then makefolder(FOLDER) end
        local treeThresholds = SIZE_THRESHOLDS[selectedTree] or { Small = 0, Medium = 0, Large = 0 }
        local threshold = treeThresholds[selectedSize] or 0
        -- single state file
        WriteState({
            active    = true,
            treeType  = selectedTree,
            minVolume = threshold,
        })
        pcall(writefile, BOOTSTRAP_FILE, BOOTSTRAP_SRC)
    end

    local function StopSearch()
        if not searchActive then return end
        searchActive = false
        getgenv()._ccRunning = nil
        SetActive(false)
        if startBtn then startBtn:SetText("Start") end
        treeDropdown:SetDisabled(false)
        DestroyHUD()
    end

    local function ArmNextHop()
        if not queue_on_teleport then
            SetHUDStatus("queue_on_teleport unavailable - search cannot persist across servers")
            return false
        end
        SetActive(true)
        queue_on_teleport(QUEUE_LINE)
        return true
    end

    local function HopToServer()
        local servers    = FetchServers()
        local currentId  = game.JobId
        local candidates = {}
        for _, s in ipairs(servers) do
            if s.id ~= currentId
            and type(s.playing) == "number"
            and type(s.maxPlayers) == "number"
            and s.playing < s.maxPlayers then
                table.insert(candidates, s)
            end
        end
        if #candidates == 0 then
            SetHUDStatus("No available servers found. Retrying...")
            return false
        end
        SetHUDStatus("Hopping to next server...")
        if not ArmNextHop() then return false end
        local target = candidates[math.random(1, #candidates)]
        local ok = pcall(TeleportService.TeleportToPlaceInstance,
            TeleportService, game.PlaceId, target.id, player)
        if not ok then
            SetHUDStatus("Teleport failed. Retrying...")
            SetActive(false)
            return false
        end
        return true
    end

    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.F1 or input.KeyCode == Enum.KeyCode.Backspace then
            if searchActive then StopSearch() else DestroyHUD() end
        end
    end)

    local function OnStartStop()
        if searchActive then StopSearch() return end
        if getgenv()._ccRunning then
            SetHUDStatus("A search is already running.")
            return
        end

        searchActive = true
        if startBtn then startBtn:SetText("Stop") end
        treeDropdown:SetDisabled(true)

        WriteFiles()
        CreateHUD(selectedTree)

        local treeThresholds = SIZE_THRESHOLDS[selectedTree] or { Small = 0, Medium = 0, Large = 0 }
        local minVol  = treeThresholds[selectedSize] or 0
        local sizeTag = minVol > 0 and (" | " .. selectedSize .. " vol >= " .. minVol) or " | Any size"
        SetHUDStatus("Starting search for " .. selectedTree .. sizeTag .. "...")

        task.spawn(function()
            getgenv()._ccRunning = true
            SetHUDStatus("Waiting for world to finish loading...")
            task.wait(LOAD_WAIT)

            while searchActive and getgenv()._ccRunning do
                local treeT = SIZE_THRESHOLDS[selectedTree] or { Small = 0, Medium = 0, Large = 0 }
                local minV  = treeT[selectedSize] or 0
                local sTag  = minV > 0 and (" | min vol " .. minV) or ""
                SetHUDStatus("Scanning for " .. selectedTree .. sTag .. "...")

                local found, treeModel = FindTree(selectedTree)

                if found then
                    local pos    = treeModel and treeModel:GetPivot().Position or Vector3.zero
                    local posStr = ("%.1f, %.1f, %.1f"):format(pos.X, pos.Y, pos.Z)
                    SetHUDFound(posStr, selectedTree)
                    searchActive = false
                    getgenv()._ccRunning = nil
                    SetActive(false)
                    if startBtn then startBtn:SetText("Start") end
                    treeDropdown:SetDisabled(false)
                    break
                end

                if not searchActive then break end
                SetHUDStatus(selectedTree .. " not found here. Hopping...")

                local hopped = HopToServer()
                if hopped then
                    local deadline = tick() + HOP_TIMEOUT
                    while searchActive and getgenv()._ccRunning and tick() < deadline do
                        task.wait(1)
                    end
                    if searchActive and getgenv()._ccRunning then
                        SetHUDStatus("Teleport timed out. Retrying hop...")
                    end
                else
                    task.wait(RETRY_WAIT)
                end
            end

            getgenv()._ccRunning = nil
        end)
    end

    startBtn = Tab:CreateAction("Search for Tree", "Start", OnStartStop)
end

return TreeSearcher
]], "TreeSearcher"))() end
__modules["WireArt"] = function() return assert(loadstring([[-- Blueprints.lua Module
local Blueprints = {}

-- LOT is optional; passed in from the host script when available.
-- It exposes: LOT.TeleportObjectTo(part, cframe)  LOT.IsBusy()  LOT.WaitForBatch()
function Blueprints.Init(Tab, Library, LOT)
    local Players           = game:GetService("Players")
    local RunService        = game:GetService("RunService")
    local UserInputService  = game:GetService("UserInputService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local GuiService        = game:GetService("GuiService")
    local CoreGui           = game:GetService("CoreGui")
    local DestroyStructure = ReplicatedStorage:FindFirstChild("Interaction")
        and ReplicatedStorage.Interaction:FindFirstChild("DestroyStructure")

    local ClientPlacedStructure  = nil
    local ClientPlacedWire       = nil
    local ClientPlacedBlueprint  = nil
    task.spawn(function()
        ClientPlacedStructure = ReplicatedStorage
            :WaitForChild("PlaceStructure")
            :WaitForChild("ClientPlacedStructure")
        ClientPlacedWire = ReplicatedStorage
            :WaitForChild("PlaceStructure")
            :WaitForChild("ClientPlacedWire")
        ClientPlacedBlueprint = ReplicatedStorage
            :WaitForChild("PlaceStructure")
            :WaitForChild("ClientPlacedBlueprint")
    end)

    local LocalPlayer = Players.LocalPlayer
    local Character   = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local Mouse       = LocalPlayer:GetMouse()

    -- ================================================================
    --  STATE
    -- ================================================================
    local Settings     = { Scale = 2, Spacing = 2 }
    local PlaceMode    = false
    local Placing      = false
    local WireRotation = CFrame.new()

    local SelectedWires      = {}
    local SelectedStructures = {}
    local SelectedFurniture  = {}
    local SelectedBlueprints = {}
    local SelectionBoxes     = {}
    local ClickSelectMode    = false
    local GroupSelectMode    = false
    local placementWires  = {}
    local MoveMode       = false
    local moveWires      = {}
    local moveStrokes    = {}
    local moveStructures = {}  -- {model, offsetPos, cf, itemName, treeValue}
    local moveFurniture  = {}  -- {model, offsetPos, cf, itemName}
    local moveBlueprints = {}  -- {model, offsetPos, cf, itemName}
    local movePreviewModels = {}  -- clones shown during move preview; cleared on StopPlacing

    -- Pending structure/furniture data from a loaded file.
    local pendingStructures = {}  -- array of {itemName, cf, treeValue}
    local pendingFurniture  = {}  -- array of {itemName, cf}
    local pendingIsWorldSpace = false

    -- Grid snap
    local snapToGrid = true
    local GRID_SIZE  = 0.5

    -- Object selection toggles
    local selectStructures = true
    local selectFurniture  = true
    local selectWires      = true
    local selectBlueprints = true
    local groupByTreeValue = false

    local BlueprintMode  = false
    local blueprintWires = {}
    local blueprintTypes = {}
    local usePropertyOrigin = false
    local BlueprintBuild = nil
    local GetPlayerProperty, GetPropertyCenter, GetPropertySquares, PointInSquares, StrokeInsideProperty
    local SetWireLength
    local MergeWrappedLines

    -- Lasso state
    local LassoMode      = false
    local LassoDragging  = false
    local LassoStartPos  = nil
    local LassoGui       = nil
    local LassoFrame     = nil

    local PreviewModel    = Instance.new("Model")
    PreviewModel.Name     = "WireArtPreview"
    PreviewModel.Parent   = workspace

    local BLUE        = Color3.fromRGB(74, 120, 255)
    local DEFAULT_MAX = 69.89

    -- ================================================================
    --  PLANK SELECTION STATE
    -- ================================================================
    local allPlanks           = {}    -- all owned planks (every TreeClass), scanned on Build File
    local filteredPlanks      = {}    -- planks that pass the Y-size range filter
    local plankFilterMin      = 1
    local plankFilterMax      = 2
    local plankIndex          = 1     -- round-robin cursor into filteredPlanks
    local plankSelectionBoxes = {}
    local plankOutlineConns   = {}
    local plankRangeSlider    = nil   -- UI range slider reference

    -- ================================================================
    --  GRID SNAP
    -- ================================================================
    local function SnapToGrid(pos)
        if not snapToGrid then return pos end
        local g = GRID_SIZE
        return Vector3.new(
            math.round(pos.X / g) * g,
            pos.Y,
            math.round(pos.Z / g) * g
        )
    end

    -- ================================================================
    --  WIRE TYPE HELPER
    -- ================================================================
    local function GetWireTypeName(wireObj)
        if not wireObj then return nil end
        local itemName = wireObj:FindFirstChild("ItemName")
                      or wireObj:FindFirstChild("PurchasedBoxItemName")
        if itemName and itemName.Value and itemName.Value ~= "" then
            return itemName.Value
        end
        return nil
    end

    -- ================================================================
    --  WIRE MAX-LENGTH HELPER
    -- ================================================================
    local function GetWireMaxLength(wireObj)
        local ClientItemInfo = ReplicatedStorage:FindFirstChild("ClientItemInfo")
        if not ClientItemInfo then return DEFAULT_MAX end
        local itemName = wireObj:FindFirstChild("ItemName")
                      or wireObj:FindFirstChild("PurchasedBoxItemName")
        if not itemName then return DEFAULT_MAX end
        local info = ClientItemInfo:FindFirstChild(itemName.Value, true)
        if not info then return DEFAULT_MAX end
        local maxLen = info:FindFirstChild("MaxLength") or info:FindFirstChild("MaxDistance")
        if maxLen and maxLen.Value and maxLen.Value > 0 then
            return maxLen.Value
        end
        return DEFAULT_MAX
    end

    -- ================================================================
    --  STRUCTURE / FURNITURE HELPERS
    -- ================================================================
    local function GetItemName(model)
        local obj = model:FindFirstChild("ItemName")
        if obj and tostring(obj.Value) ~= "" then return tostring(obj.Value) end
        local boxed = model:FindFirstChild("PurchasedBoxItemName")
        if boxed and tostring(boxed.Value) ~= "" then return tostring(boxed.Value) end
        return model.Name
    end

    local function GetStructureCFrame(model)
        return (model:FindFirstChild("MainCFrame")         and model.MainCFrame.Value)
            or (model:FindFirstChild("BuildDependentWood") and model.BuildDependentWood.CFrame)
            or (model.PrimaryPart                          and model.PrimaryPart.CFrame)
            or model:GetPivot()
    end

    local function GetStructureTreeValue(model)
        local bwc = model:FindFirstChild("BlueprintWoodClass")
        if bwc and bwc.Value and bwc.Value ~= "" then
            return bwc.Value
        end
        return nil
    end

    local function IsOwnedByLocalPlayer(model)
        local ownerFolder = model:FindFirstChild("Owner")
        local ownerString = ownerFolder and ownerFolder:FindFirstChild("OwnerString")
        return ownerString and ownerString.Value == LocalPlayer.Name
    end

    local function GetOwnedStructures()
        local pm = workspace:FindFirstChild("PlayerModels")
        if not pm then return {} end
        local results = {}
        for _, model in ipairs(pm:GetChildren()) do
            local typeVal = model:FindFirstChild("Type")
            if not typeVal or typeVal.Value ~= "Structure" then continue end
            if model:FindFirstChild("PurchasedBoxItemName") then continue end
            if IsOwnedByLocalPlayer(model) then
                table.insert(results, model)
            end
        end
        return results
    end

    local function GetOwnedFurniture()
        local pm = workspace:FindFirstChild("PlayerModels")
        if not pm then return {} end
        local results = {}
        for _, model in ipairs(pm:GetChildren()) do
            local typeVal = model:FindFirstChild("Type")
            if not typeVal or typeVal.Value ~= "Furniture" then continue end
            if model:FindFirstChild("PurchasedBoxItemName") then continue end
            if IsOwnedByLocalPlayer(model) then
                table.insert(results, model)
            end
        end
        return results
    end

    local function GetOwnedWires()
        local pm = workspace:FindFirstChild("PlayerModels")
        if not pm then return {} end
        local results = {}
        for _, model in ipairs(pm:GetChildren()) do
            local typeVal  = model:FindFirstChild("Type")
            local owner    = model:FindFirstChild("Owner")
            local ownerStr = owner and owner:FindFirstChild("OwnerString")
            if typeVal and typeVal.Value == "Wire"
            and ownerStr and ownerStr.Value == LocalPlayer.Name
            and not model:FindFirstChild("PurchasedBoxItemName") then
                table.insert(results, model)
            end
        end
        return results
    end

    -- ================================================================
    --  PLANK HELPERS  (ported from BuildModule)
    -- ================================================================
    local function ClearPlankOutlines()
        for _, conn in ipairs(plankOutlineConns) do conn:Disconnect() end
        plankOutlineConns = {}
        for _, box in ipairs(plankSelectionBoxes) do
            if box and box.Parent then box:Destroy() end
        end
        plankSelectionBoxes = {}
    end

    local function DrawPlankOutlines()
        ClearPlankOutlines()
        for _, entry in ipairs(filteredPlanks) do
            if entry.part and entry.part.Parent then
                local box               = Instance.new("SelectionBox")
                box.Adornee             = entry.part
                box.Color3              = Color3.fromRGB(74, 120, 255)
                box.LineThickness       = 0.03
                box.SurfaceColor3       = Color3.fromRGB(74, 120, 255)
                box.SurfaceTransparency = 0.75
                box.Parent              = CoreGui
                table.insert(plankSelectionBoxes, box)

                local conn = entry.part.Destroying:Connect(function()
                    box:Destroy()
                    for i, e in ipairs(filteredPlanks) do
                        if e.part == entry.part then table.remove(filteredPlanks, i); break end
                    end
                    for i, e in ipairs(allPlanks) do
                        if e.part == entry.part then table.remove(allPlanks, i); break end
                    end
                    plankIndex = math.max(1, math.min(plankIndex, math.max(1, #filteredPlanks)))
                end)
                table.insert(plankOutlineConns, conn)
            end
        end
    end

    -- Scans every owned Plank model regardless of TreeClass.
    -- Called automatically when Build File is triggered.
    local function ScanAllOwnedPlanks()
        local pm = workspace:FindFirstChild("PlayerModels")
        local result = {}
        if not pm then return result end
        for _, model in ipairs(pm:GetChildren()) do
            if model.Name == "Plank" and model:IsA("Model") and IsOwnedByLocalPlayer(model) then
                local tc   = model:FindFirstChild("TreeClass")
                local part = model:FindFirstChild("Main") or model:FindFirstChildWhichIsA("BasePart")
                if part and part:IsA("BasePart") then
                    local sz  = part.Size
                    local vol = math.floor(sz.X * sz.Y * sz.Z * 10 + 0.5) / 10
                    table.insert(result, {
                        model     = model,
                        part      = part,
                        volume    = vol,
                        treeClass = tc and tc:IsA("StringValue") and tc.Value or "",
                    })
                end
            end
        end
        return result
    end

    local function ApplyPlankYFilter()
        filteredPlanks = {}
        for _, e in ipairs(allPlanks) do
            if e.volume >= plankFilterMin and e.volume <= plankFilterMax then
                table.insert(filteredPlanks, e)
            end
        end
        plankIndex = 1
        DrawPlankOutlines()
    end

    -- Returns the next available plank entry for a given treeClass (or any class if nil).
    -- Advances the round-robin cursor and returns nil if no matching plank exists.
    local function GetNextPlankForClass(treeClass)
        if #filteredPlanks == 0 then return nil end
        -- If a specific tree class is requested, try to find a matching plank.
        if treeClass and treeClass ~= "" then
            -- Search from current index forward (wrap around once)
            local startIdx = plankIndex
            for attempt = 1, #filteredPlanks do
                local idx = ((startIdx - 1 + attempt - 1) % #filteredPlanks) + 1
                local entry = filteredPlanks[idx]
                if entry and entry.part and entry.part.Parent then
                    if entry.treeClass == treeClass then
                        plankIndex = (idx % #filteredPlanks) + 1
                        return entry
                    end
                end
            end
            -- No type match found; fall back to any available plank
        end
        -- Round-robin any plank
        for attempt = 1, #filteredPlanks do
            local idx = ((plankIndex - 1 + attempt - 1) % #filteredPlanks) + 1
            local entry = filteredPlanks[idx]
            if entry and entry.part and entry.part.Parent then
                plankIndex = (idx % #filteredPlanks) + 1
                return entry
            end
        end
        return nil
    end

    -- ================================================================
    --  CFRAME SERIALIZATION HELPERS
    -- ================================================================
    local function CFrameToString(cf)
        local c = {cf:GetComponents()}
        local parts = {}
        for _, v in ipairs(c) do
            local s = string.format("%.7g", v)
            table.insert(parts, s)
        end
        return table.concat(parts, ", ")
    end

    local function StringToCFrame(s)
        local nums = {}
        for n in s:gmatch("[^,]+") do
            table.insert(nums, tonumber(n:match("^%s*(.-)%s*$")))
        end
        if #nums == 12 then
            return CFrame.new(table.unpack(nums))
        elseif #nums == 3 then
            return CFrame.new(nums[1], nums[2], nums[3])
        end
        return nil
    end

    -- ================================================================
    --  SELECTION HELPERS
    -- ================================================================
    local function UpdateSelectionVisuals()
        for _, box in ipairs(SelectionBoxes) do box:Destroy() end
        SelectionBoxes = {}
        local function addBox(model)
            if model and model.Parent then
                local box         = Instance.new("SelectionBox")
                box.Color3        = BLUE
                box.LineThickness = 0.05
                box.Adornee       = model
                box.Parent        = workspace
                table.insert(SelectionBoxes, box)
            end
        end
        for _, w in ipairs(SelectedWires)      do addBox(w) end
        for _, s in ipairs(SelectedStructures) do addBox(s) end
        for _, f in ipairs(SelectedFurniture)  do addBox(f) end
        for _, b in ipairs(SelectedBlueprints) do addBox(b) end
    end

    local function ClearSelection()
        SelectedWires      = {}
        SelectedStructures = {}
        SelectedFurniture  = {}
        SelectedBlueprints = {}
        structureUseIndex  = {}
        UpdateSelectionVisuals()
    end

    local function FindWireModelFromPart(part)
        if not part then return nil end
        local pm = workspace:FindFirstChild("PlayerModels")
        if not pm then return nil end
        local cur = part
        while cur and cur.Parent ~= pm do cur = cur.Parent end
        if not cur or not cur:IsA("Model") then return nil end
        local typeVal = cur:FindFirstChild("Type")
        if not typeVal or typeVal.Value ~= "Wire" then return nil end
        return cur
    end

    local function FindStructureModelFromPart(part)
        if not part then return nil end
        local pm = workspace:FindFirstChild("PlayerModels")
        if not pm then return nil end
        local cur = part
        while cur and cur.Parent ~= pm do cur = cur.Parent end
        if not cur or not cur:IsA("Model") then return nil end
        local typeVal = cur:FindFirstChild("Type")
        if not typeVal or (typeVal.Value ~= "Structure" and typeVal.Value ~= "Vehicle Spot") then return nil end
        return cur
    end

    local function FindFurnitureModelFromPart(part)
        if not part then return nil end
        local pm = workspace:FindFirstChild("PlayerModels")
        if not pm then return nil end
        local cur = part
        while cur and cur.Parent ~= pm do cur = cur.Parent end
        if not cur or not cur:IsA("Model") then return nil end
        local typeVal = cur:FindFirstChild("Type")
        if not typeVal or typeVal.Value ~= "Furniture" then return nil end
        if cur:FindFirstChild("PurchasedBoxItemName") then return nil end
        return cur
    end

    local function FindBlueprintModelFromPart(part)
        if not part then return nil end
        local pm = workspace:FindFirstChild("PlayerModels")
        if not pm then return nil end
        local cur = part
        while cur and cur.Parent ~= pm do cur = cur.Parent end
        if not cur or not cur:IsA("Model") then return nil end
        local typeVal = cur:FindFirstChild("Type")
        if not typeVal or typeVal.Value ~= "Blueprint" then return nil end
        return cur
    end

    -- ================================================================
    --  LASSO ENGINE
    -- ================================================================
    local function InitLassoGui()
        if LassoGui then LassoGui:Destroy() end
        local sg = Instance.new("ScreenGui")
        sg.Name           = "WireArtLassoGui"
        sg.ResetOnSpawn   = false
        sg.IgnoreGuiInset = true
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        sg.Parent         = game:GetService("CoreGui")

        local frame = Instance.new("Frame")
        frame.BackgroundColor3       = Color3.fromRGB(60, 130, 255)
        frame.BackgroundTransparency = 0.75
        frame.BorderSizePixel        = 0
        frame.Visible                = false
        frame.ZIndex                 = 10
        frame.Parent                 = sg

        local stroke           = Instance.new("UIStroke")
        stroke.Color           = Color3.fromRGB(120, 180, 255)
        stroke.Thickness       = 1.5
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Parent          = frame

        LassoGui   = sg
        LassoFrame = frame
    end

    local function UpdateLassoFrame(currentPos)
        if not LassoFrame or not LassoStartPos then return end
        local minX = math.min(LassoStartPos.X, currentPos.X)
        local minY = math.min(LassoStartPos.Y, currentPos.Y)
        local maxX = math.max(LassoStartPos.X, currentPos.X)
        local maxY = math.max(LassoStartPos.Y, currentPos.Y)
        LassoFrame.Position = UDim2.fromOffset(minX, minY)
        LassoFrame.Size     = UDim2.fromOffset(maxX - minX, maxY - minY)
        LassoFrame.Visible  = true
    end

    local function ProjectToScreen(worldPos)
        local Camera = workspace.CurrentCamera
        local inset  = GuiService:GetGuiInset()
        local screenPos, onScreen = Camera:WorldToScreenPoint(worldPos)
        if not onScreen or screenPos.Z <= 0 then return nil end
        return Vector2.new(screenPos.X + inset.X, screenPos.Y + inset.Y)
    end

    local function SelectWiresInLassoRect(startPos, endPos)
        local minX = math.min(startPos.X, endPos.X)
        local minY = math.min(startPos.Y, endPos.Y)
        local maxX = math.max(startPos.X, endPos.X)
        local maxY = math.max(startPos.Y, endPos.Y)
        if (maxX - minX) < 6 or (maxY - minY) < 6 then return end

        local pm = workspace:FindFirstChild("PlayerModels")
        if not pm then return end

        local seen = {}

        local function trySelect(model, targetList)
            if seen[model] then return end
            seen[model] = true

            local worldPos
            local okBB, cf = pcall(model.GetBoundingBox, model)
            if okBB and cf then
                worldPos = cf.Position
            else
                local firstPart = model:FindFirstChildWhichIsA("BasePart")
                worldPos = firstPart and firstPart.Position
            end
            if not worldPos then return end

            local sp = ProjectToScreen(worldPos)
            if not sp then return end
            if sp.X >= minX and sp.X <= maxX and sp.Y >= minY and sp.Y <= maxY then
                local idx = table.find(targetList, model)
                if idx then table.remove(targetList, idx)
                else table.insert(targetList, model) end
            end
        end

        for _, model in ipairs(pm:GetChildren()) do
            if not model:IsA("Model") then continue end
            local isBoxed = model:FindFirstChild("PurchasedBoxItemName") ~= nil
            local typeVal = model:FindFirstChild("Type")
            if not typeVal then continue end
            -- Boxed structures and boxed wires are selectable; boxed furniture/blueprints are not.
            if typeVal.Value == "Wire"      and selectWires      then trySelect(model, SelectedWires) end
            if (typeVal.Value == "Structure" or typeVal.Value == "Vehicle Spot") and selectStructures then trySelect(model, SelectedStructures) end
            if typeVal.Value == "Furniture" and selectFurniture  and not isBoxed then trySelect(model, SelectedFurniture) end
            if typeVal.Value == "Blueprint" and selectBlueprints and not isBoxed then trySelect(model, SelectedBlueprints) end
        end

        UpdateSelectionVisuals()
    end

    -- ================================================================
    --  WIRE HELPERS
    -- ================================================================
    local function GetOwnedBoxedWires()
        local wires = {}
        local pm    = workspace:FindFirstChild("PlayerModels")
        if not pm then
            Library:Notify("Blueprints", "PlayerModels not found!")
            return wires
        end
        for _, model in pairs(pm:GetChildren()) do
            local typeVal   = model:FindFirstChild("Type")
            local owner     = model:FindFirstChild("Owner")
            local ownerStr  = owner and owner:FindFirstChild("OwnerString")
            local boxedName = model:FindFirstChild("PurchasedBoxItemName")
            if typeVal   and typeVal.Value  == "Wire"
            and ownerStr and ownerStr.Value == LocalPlayer.Name
            and boxedName then
                table.insert(wires, model)
            end
        end
        Library:Notify("Blueprints", "Found " .. #wires .. " boxed wires!")
        return wires
    end

    local function GetWireInfo(wireObj)
        local itemName = wireObj:FindFirstChild("ItemName")
                      or wireObj:FindFirstChild("PurchasedBoxItemName")
        if not itemName then return nil end
        local ClientItemInfo = ReplicatedStorage:FindFirstChild("ClientItemInfo")
        return ClientItemInfo and ClientItemInfo:FindFirstChild(itemName.Value, true)
    end

    -- Same pattern as GetWireInfo but for structure/boxed-structure objects.
    local function GetStructureInfo(srcModel)
        local itemName = srcModel:FindFirstChild("ItemName")
                      or srcModel:FindFirstChild("PurchasedBoxItemName")
        if not itemName then return nil end
        local ClientItemInfo = ReplicatedStorage:FindFirstChild("ClientItemInfo")
        return ClientItemInfo and ClientItemInfo:FindFirstChild(itemName.Value, true)
    end

    -- ================================================================
    --  PROPERTY HELPER
    -- ================================================================
    function GetPlayerProperty()
        local Properties = workspace:FindFirstChild("Properties")
        if not Properties then return nil end
        for _, prop in ipairs(Properties:GetChildren()) do
            local owner = prop:FindFirstChild("Owner")
            if not owner then continue end
            -- ObjectValue whose .Value is the Player instance
            if owner:IsA("ObjectValue") and owner.Value == LocalPlayer then
                return prop
            end
            -- StringValue or folder containing an OwnerString StringValue
            if owner:IsA("StringValue") and owner.Value == LocalPlayer.Name then
                return prop
            end
            local ownerStr = owner:FindFirstChild("OwnerString")
            if ownerStr and ownerStr:IsA("StringValue") and ownerStr.Value == LocalPlayer.Name then
                return prop
            end
        end
        return nil
    end

    function GetPropertyCenter()
        local prop = GetPlayerProperty()
        if not prop then return nil end
        local origin = prop:FindFirstChild("OriginSquare", true)
        if origin then
            if origin:IsA("BasePart") then
                return origin.Position
            elseif origin:IsA("Model") then
                if origin.PrimaryPart then return origin.PrimaryPart.Position end
                local ok, cf = pcall(origin.GetBoundingBox, origin)
                if ok and cf then return cf.Position end
            end
        end
        if prop.PrimaryPart then return prop.PrimaryPart.Position end
        if prop:IsA("Model") then
            local ok, cf = pcall(prop.GetBoundingBox, prop)
            if ok and cf then return cf.Position end
        end
        return nil
    end

    function GetPropertySquares()
        local prop = GetPlayerProperty()
        if not prop then return nil end
        local rects = {}
        for _, child in ipairs(prop:GetChildren()) do
            if child:IsA("BasePart")
            and (child.Name == "Square" or child.Name == "OriginSquare") then
                local pos     = child.Position
                local halfX   = child.Size.X * 0.5
                local halfZ   = child.Size.Z * 0.5
                table.insert(rects, {
                    minX = pos.X - halfX, maxX = pos.X + halfX,
                    minZ = pos.Z - halfZ, maxZ = pos.Z + halfZ,
                })
            end
        end
        if #rects == 0 then return nil end
        return rects
    end

    function PointInSquares(x, z, rects)
        local EPS = 0.01
        for _, r in ipairs(rects) do
            if x >= r.minX - EPS and x <= r.maxX + EPS
            and z >= r.minZ - EPS and z <= r.maxZ + EPS then
                return true
            end
        end
        return false
    end

    function StrokeInsideProperty(stroke, rects)
        for _, pt in ipairs(stroke) do
            if not PointInSquares(pt.X, pt.Z, rects) then return false end
        end
        return true
    end

    -- ================================================================
    --  WIRE POINTS EXTRACTION
    -- ================================================================
    local function GetWirePoints(wireObj)
        if not wireObj or not wireObj.Parent then return nil end
        local end1 = wireObj:FindFirstChild("End1")
        local end2 = wireObj:FindFirstChild("End2")
        if not (end1 and end1:IsA("BasePart") and end2 and end2:IsA("BasePart")) then
            return nil
        end
        local middle = {}
        for _, child in ipairs(wireObj:GetChildren()) do
            if child:IsA("BasePart") then
                local n = child.Name:match("^Point(%d+)$")
                if n then table.insert(middle, { idx = tonumber(n), part = child }) end
            end
        end
        table.sort(middle, function(a, b) return a.idx < b.idx end)
        local pts = { end1.Position }
        for _, m in ipairs(middle) do table.insert(pts, m.part.Position) end
        table.insert(pts, end2.Position)
        return pts
    end

    local function GetSelectionAnchor(wires)
        local minX, maxX = math.huge, -math.huge
        local minY       = math.huge
        local minZ, maxZ = math.huge, -math.huge
        local any = false
        for _, w in ipairs(wires) do
            local pts = GetWirePoints(w)
            if pts then
                for _, p in ipairs(pts) do
                    if p.X < minX then minX = p.X end
                    if p.X > maxX then maxX = p.X end
                    if p.Y < minY then minY = p.Y end
                    if p.Z < minZ then minZ = p.Z end
                    if p.Z > maxZ then maxZ = p.Z end
                    any = true
                end
            end
        end
        if not any then return nil end
        return Vector3.new((minX + maxX) * 0.5, minY, (minZ + maxZ) * 0.5)
    end

    local function BuildMoveStrokes(wires)
        local anchor = GetSelectionAnchor(wires)
        if not anchor then return nil, "Could not read wire points" end
        local strokes = {}
        local validWires = {}
        for _, w in ipairs(wires) do
            local pts = GetWirePoints(w)
            if pts and #pts >= 2 then
                local offsets = {}
                for _, p in ipairs(pts) do table.insert(offsets, p - anchor) end
                table.insert(strokes, offsets)
                table.insert(validWires, w)
            end
        end
        if #strokes == 0 then return nil, "No readable wires" end
        return strokes, nil, validWires
    end

    -- ================================================================
    --  BLUEPRINT TEXT BUILD / PARSE
    -- ================================================================
    local function BuildBlueprintText(wires, structures, furniture, relativeToProperty)
        local origin
        if relativeToProperty then
            origin = GetPropertyCenter()
            if not origin then
                return nil, "No owned property found for relative export"
            end
        end

        local function fmt(n)
            local s = string.format("%.7g", n)
            if s == "-0" then s = "0" end
            return s
        end

        -- Compute ONE shared origin from ALL content: wires + structures + furniture
        local sharedOrigin = origin
        if not sharedOrigin then
            local sx, sy, sz, cnt = 0, 0, 0, 0
            for _, w in ipairs(wires or {}) do
                local pts = GetWirePoints(w)
                if pts then
                    for _, p in ipairs(pts) do
                        sx += p.X; sy += p.Y; sz += p.Z; cnt += 1
                    end
                end
            end
            for _, s in ipairs(structures or {}) do
                local c = GetStructureCFrame(s)
                if c then sx += c.Position.X; sy += c.Position.Y; sz += c.Position.Z; cnt += 1 end
            end
            for _, f in ipairs(furniture or {}) do
                local c = f:GetPivot()
                sx += c.Position.X; sy += c.Position.Y; sz += c.Position.Z; cnt += 1
            end
            sharedOrigin = cnt > 0 and Vector3.new(sx/cnt, sy/cnt, sz/cnt) or Vector3.new()
        end

        local function cfRelative(cf)
            return CFrame.new(cf.Position - sharedOrigin) * (CFrame.new(cf.Position):Inverse() * cf)
        end

        local lines = {}
        if relativeToProperty then
            table.insert(lines, "true")
        end

        -- Wires
        local wireLines = {}
        for _, w in ipairs(wires or {}) do
            local pts = GetWirePoints(w)
            if pts and #pts >= 2 then
                local typeName = GetWireTypeName(w) or ""
                local parts    = { typeName }
                local ref = sharedOrigin
                for _, p in ipairs(pts) do
                    local rel = p - ref
                    table.insert(parts, fmt(rel.X) .. "," .. fmt(rel.Y) .. "," .. fmt(rel.Z))
                end
                table.insert(wireLines, table.concat(parts, " | "))
            end
        end
        local hasOther = (#(structures or {}) + #(furniture or {})) > 0
        if #wireLines > 0 then
            if hasOther then table.insert(lines, "[Wires]") end
            for _, l in ipairs(wireLines) do table.insert(lines, l) end
        end

        -- Structures
        if structures and #structures > 0 then

            if groupByTreeValue then
                local groups = {}
                local groupOrder = {}
                for _, s in ipairs(structures) do
                    local tv = GetStructureTreeValue(s) or "(none)"
                    if not groups[tv] then
                        groups[tv] = {}
                        table.insert(groupOrder, tv)
                    end
                    table.insert(groups[tv], s)
                end
                for _, tv in ipairs(groupOrder) do
                    table.insert(lines, "-- " .. tv)
                    for _, s in ipairs(groups[tv]) do
                        local cf = GetStructureCFrame(s)
                        if not cf then continue end
                        local name = GetItemName(s)
                        local tv2  = GetStructureTreeValue(s) or ""
                        table.insert(lines, name .. " | " .. CFrameToString(cfRelative(cf)) .. " | " .. tv2)
                    end
                end
            else
                for _, s in ipairs(structures) do
                    local cf = GetStructureCFrame(s)
                    if not cf then continue end
                    local name = GetItemName(s)
                    local tv   = GetStructureTreeValue(s) or ""
                    table.insert(lines, name .. " | " .. CFrameToString(cfRelative(cf)) .. " | " .. tv)
                end
            end
        end

        -- Furniture
        if furniture and #furniture > 0 then
            for _, f in ipairs(furniture) do
                local cf   = f:GetPivot()
                local name = GetItemName(f)
                table.insert(lines, name .. " | " .. CFrameToString(cfRelative(cf)))
            end
        end

        if #lines == 0 or (#lines == 1 and lines[1] == "true") then
            return nil, "Nothing to export in selection"
        end

        return table.concat(lines, "\n"), nil
    end

    -- Parse a combined file back into tables
    local function ParseCombinedBlueprint(input)
        local wires      = {}
        local wireTypes  = {}
        local structures = {}
        local furniture  = {}
        local skipped    = 0
        local useProperty = false
        local currentSection = "wires"

        local function trim(s) return s:match("^%s*(.-)%s*$") or "" end

        local vars = {}

        local function substituteVars(text)
            return (text:gsub("%$([%a_][%w_]*)", function(name)
                local v = vars[name]
                if v == nil then return "$" .. name end
                return tostring(v)
            end))
        end

        local function matchVarLine(line)
            if line:find("|", 1, true) then return nil end
            local name, value = line:match("^([%a_][%w_]*)%s*=%s*(.+)$")
            if not name then return nil end
            local raw = trim(value)
            local q = raw:match('^"(.*)"$') or raw:match("^'(.*)'$")
            if q then return name, q end
            local n = tonumber(raw)
            if n then return name, n end
            return name, raw
        end

        local normalized = input
            :gsub("\r\n", "\0"):gsub("\r", "\0"):gsub("\n", "\0")

        -- First pass: collect variable definitions
        local headerLocked = false
        local lines = {}
        for line in (normalized .. "\0"):gmatch("([^\0]*)\0") do
            line = trim(line)
            if line ~= "" then
                if not headerLocked then
                    local name, val = matchVarLine(line)
                    if name then
                        vars[name] = val
                    else
                        headerLocked = true
                        table.insert(lines, line)
                    end
                else
                    table.insert(lines, line)
                end
            end
        end

        lines = MergeWrappedLines(lines)

        for _, line in ipairs(lines) do
            line = trim(line)
            if line == "" or line:sub(1,2) == "--" then continue end

            if (line:lower() == "true" or line:lower() == "false") and not line:find("|", 1, true) then
                useProperty = (line:lower() == "true")
                continue
            end

            local sectionHeader = line:match("^%[(.-)%]$")
            if sectionHeader then
                local sl = sectionHeader:lower()
                if sl == "wires"      then currentSection = "wires"
                elseif sl == "structures" then currentSection = "structures"
                elseif sl == "furniture"  then currentSection = "furniture"
                end
                continue
            end

            local fields = {}
            for f in (line .. " | "):gmatch("([^|]*)|") do
                table.insert(fields, trim(f))
            end

            -- Auto-detect section when no header is present:
            -- If we're in "wires" but field 2 looks like a 12-number CFrame, treat as struct/furniture.
            if currentSection == "wires" and #fields >= 2 then
                local f2nums = 0
                for _ in fields[2]:gmatch("[^,]+") do f2nums += 1 end
                if f2nums == 12 then
                    -- 3+ fields = structure (has treeValue slot); 2 fields = furniture
                    if #fields >= 3 then
                        currentSection = "structures"
                    else
                        currentSection = "furniture"
                    end
                end
            end

            if currentSection == "wires" then
                if #fields < 3 then skipped += 1; continue end
                local typeField = (fields[1] ~= "") and fields[1] or nil
                local pts = {}
                for i = 2, #fields do
                    if fields[i] == "" then continue end
                    local xs, ys, zs = fields[i]:match("^([^,]+),([^,]+),([^,]+)$")
                    if xs then
                        local x, y, z = tonumber(xs), tonumber(ys), tonumber(zs)
                        if x and y and z then table.insert(pts, Vector3.new(x, y, z)) end
                    end
                end
                if #pts >= 2 then
                    table.insert(wires, pts)
                    table.insert(wireTypes, typeField)
                else skipped += 1 end
                -- Reset auto-detect after each wire entry
                currentSection = "wires"

            elseif currentSection == "structures" then
                if #fields < 2 then skipped += 1; continue end
                local name = substituteVars(fields[1])
                local cf   = StringToCFrame(substituteVars(fields[2]))
                if not name or name == "" or not cf then skipped += 1; continue end
                local tv = (fields[3] and fields[3] ~= "") and fields[3] or nil
                table.insert(structures, { itemName = name, cf = cf, treeValue = tv })
                currentSection = "wires"  -- reset for next headerless line

            elseif currentSection == "furniture" then
                if #fields < 2 then skipped += 1; continue end
                local name = substituteVars(fields[1])
                local cf   = StringToCFrame(substituteVars(fields[2]))
                if not name or name == "" or not cf then skipped += 1; continue end
                table.insert(furniture, { itemName = name, cf = cf })
                currentSection = "wires"  -- reset for next headerless line
            end
        end

        if useProperty then
            local propCenter = GetPropertyCenter()
            if propCenter then
                for _, entry in ipairs(structures) do
                    local rel = entry.cf
                    entry.cf = CFrame.new(propCenter + rel.Position) * (CFrame.new(rel.Position):Inverse() * rel)
                end
                for _, entry in ipairs(furniture) do
                    local rel = entry.cf
                    entry.cf = CFrame.new(propCenter + rel.Position) * (CFrame.new(rel.Position):Inverse() * rel)
                end
            end
        end

        return wires, wireTypes, structures, furniture, skipped, useProperty
    end

    -- ================================================================
    --  STROKE MAX-LENGTH CHECK
    -- ================================================================
    local function StrokeExceedsMax(stroke, maxDist)
        local total = 0
        for i = 2, #stroke do total += (stroke[i] - stroke[i-1]).Magnitude end
        return total > maxDist
    end

    -- ================================================================
    --  TYPE-AWARE WIRE ASSIGNMENT
    -- ================================================================
    local function AssignWiresByType(typesNeeded, wirePool)
        local buckets   = {}
        local anyBucket = {}
        local used      = {}

        for _, w in ipairs(wirePool) do
            if w and w.Parent then
                local tname = GetWireTypeName(w)
                if tname then
                    buckets[tname] = buckets[tname] or {}
                    table.insert(buckets[tname], w)
                else
                    table.insert(anyBucket, w)
                end
            end
        end

        local needCount = {}
        local anyCount  = 0
        for _, tname in ipairs(typesNeeded) do
            if tname and tname ~= "" then
                needCount[tname] = (needCount[tname] or 0) + 1
            else anyCount += 1 end
        end

        local missing = {}
        for tname, need in pairs(needCount) do
            local have = (buckets[tname] and #buckets[tname]) or 0
            if have < need then table.insert(missing, { type = tname, need = need, have = have }) end
        end
        local leftoverForAny = #anyBucket
        for tname, need in pairs(needCount) do
            local have = (buckets[tname] and #buckets[tname]) or 0
            if have > need then leftoverForAny += (have - need) end
        end
        if leftoverForAny < anyCount then
            table.insert(missing, { type = "(any)", need = anyCount, have = leftoverForAny })
        end
        if #missing > 0 then return nil, false, missing end

        local assignments = {}
        for i, tname in ipairs(typesNeeded) do
            if tname and tname ~= "" then
                local bucket = buckets[tname]
                local picked
                if bucket then
                    for j = 1, #bucket do
                        local w = bucket[j]
                        if w and w.Parent and not used[w] then
                            picked = w; used[w] = true; break
                        end
                    end
                end
                assignments[i] = picked
            end
        end
        local function takeAny()
            for _, w in ipairs(anyBucket) do
                if w and w.Parent and not used[w] then used[w] = true; return w end
            end
            for _, bucket in pairs(buckets) do
                for _, w in ipairs(bucket) do
                    if w and w.Parent and not used[w] then used[w] = true; return w end
                end
            end
            return nil
        end
        for i, tname in ipairs(typesNeeded) do
            if (not tname) or tname == "" then assignments[i] = takeAny() end
        end

        return assignments, true, nil
    end

    local function FormatMissingReport(missing)
        local parts = {}
        for _, m in ipairs(missing) do
            table.insert(parts, m.type .. ": need " .. m.need .. ", have " .. m.have)
        end
        return "Missing wires — " .. table.concat(parts, "; ")
    end

    -- ================================================================
    --  LETTER DEFINITIONS
    -- ================================================================
    local function GetLetterPoints(letter, origin)
        local s  = Settings.Scale
        local t  = s
        local m  = s * 0.5
        local b  = 0
        local l  = -s * 0.4
        local r  =  s * 0.4
        local c  =  0
        local v3 = Vector3.new

        local function o(tbl)
            local out = {}
            for _, v in ipairs(tbl) do table.insert(out, origin + v) end
            return out
        end
        local function OS(...)
            return {o({...})}
        end
        local function OM(...)
            local result = {}
            for _, stroke in ipairs({...}) do table.insert(result, o(stroke)) end
            return result
        end

        local map = {
            A = OS(v3(l,b,0),v3(c,t,0),v3(r,b,0), v3((c+r)/2,m,0),v3((c+l)/2,m,0)),
            B = OS(v3(l,b,0),v3(l,t,0),v3(r*.6,t,0),v3(r,t*.75,0),v3(r*.6,m,0),v3(l,m,0),v3(r*.6,m,0),v3(r,m*.4,0),v3(r*.6,b,0),v3(l,b,0)),
            C = OS(v3(r,t,0),v3(l,t,0),v3(l,b,0),v3(r,b,0)),
            D = OS(v3(l,t,0),v3(l,b,0),v3(r,b+m*.3,0),v3(r,t-m*.3,0),v3(l,t,0)),
            E = OS(v3(r,t,0),v3(l,t,0),v3(l,b,0),v3(r,b,0), v3(l,b,0),v3(l,m,0),v3(r*.7,m,0)),
            F = OS(v3(l,b,0),v3(l,t,0),v3(r,t,0), v3(l,t,0),v3(l,m,0),v3(r*.7,m,0)),
            G = OS(v3(r,t,0),v3(l,t,0),v3(l,b,0),v3(r,b,0),v3(r,m,0),v3(c,m,0)),
            H = OS(v3(l,t,0),v3(l,b,0), v3(l,m,0),v3(r,m,0), v3(r,t,0),v3(r,b,0)),
            I = OS(v3(l,t,0),v3(r,t,0), v3(c,t,0),v3(c,b,0), v3(l,b,0),v3(r,b,0)),
            J = OS(v3(l,t,0),v3(r,t,0), v3(c,t,0),v3(c,b+m*.2,0),v3(l*.7,b,0),v3(l,b+m*.2,0)),
            K = OS(v3(l,t,0),v3(l,b,0), v3(l,m,0),v3(r,t,0), v3(l,m,0),v3(r,b,0)),
            L = OS(v3(l,t,0),v3(l,b,0),v3(r,b,0)),
            M = OS(v3(l,b,0),v3(l,t,0),v3(c,m,0),v3(r,t,0),v3(r,b,0)),
            N = OS(v3(l,b,0),v3(l,t,0),v3(r,b,0),v3(r,t,0)),
            O = OS(v3(l,t,0),v3(r,t,0),v3(r,b,0),v3(l,b,0),v3(l,t,0)),
            P = OS(v3(l,b,0),v3(l,t,0),v3(r,t,0),v3(r,m,0),v3(l,m,0)),
            Q = OS(v3(l,t,0),v3(r,t,0),v3(r,b,0),v3(l,b,0),v3(l,t,0), v3(r*.3,b+m*.3,0),v3(r,b,0)),
            R = OS(v3(l,b,0),v3(l,t,0),v3(r,t,0),v3(r,m,0),v3(l,m,0), v3(r,b,0)),
            S = OS(v3(r,t,0),v3(l,t,0),v3(l,m,0),v3(r,m,0),v3(r,b,0),v3(l,b,0)),
            T = OS(v3(l,t,0),v3(r,t,0), v3(c,t,0),v3(c,b,0)),
            U = OS(v3(l,t,0),v3(l,b,0),v3(r,b,0),v3(r,t,0)),
            V = OS(v3(l,t,0),v3(c,b,0),v3(r,t,0)),
            W = OS(v3(l,t,0),v3(l*.5,b,0),v3(c,m,0),v3(r*.5,b,0),v3(r,t,0)),
            X = OS(v3(l,t,0),v3(r,b,0), v3(c,m,0),v3(l,b,0),v3(r,t,0)),
            Y = OS(v3(l,t,0),v3(c,m,0),v3(r,t,0), v3(c,m,0),v3(c,b,0)),
            Z = OS(v3(l,t,0),v3(r,t,0),v3(l,b,0),v3(r,b,0)),
            ["0"] = OS(v3(l,t,0),v3(r,t,0),v3(r,b,0),v3(l,b,0),v3(l,t,0),v3(r,b,0)),
            ["1"] = OS(v3(l,t*.7,0), v3(c,t,0), v3(c,b,0), v3(l,b,0), v3(r,b,0)),
            ["2"] = OS(v3(l,t*.8,0),v3(r*.6,t,0),v3(r,t*.5,0),v3(l,m*.3,0),v3(l,b,0),v3(r,b,0)),
            ["3"] = OS(v3(l,t,0),v3(r,t,0),v3(r,m,0),v3(l*.4,m,0), v3(r,m,0),v3(r,b,0),v3(l,b,0)),
            ["4"] = OS(v3(l,t,0),v3(l,m,0),v3(r,m,0), v3(r,t,0),v3(r,b,0)),
            ["5"] = OS(v3(r,t,0),v3(l,t,0),v3(l,m,0),v3(r,m,0),v3(r,b,0),v3(l,b,0)),
            ["6"] = OS(v3(r,t,0),v3(l,t,0),v3(l,b,0),v3(r,b,0),v3(r,m,0),v3(l*.2,m,0)),
            ["7"] = OS(v3(l,t,0), v3(r,t,0), v3(r*.3,m,0), v3(l*.45,m,0), v3(r*.3,m,0), v3(l*.2,b,0)),
            ["8"] = OS(v3(c,m,0),v3(l,m*1.3,0),v3(l,t,0),v3(r,t,0),v3(r,m*1.3,0),v3(c,m,0),v3(l,m*.7,0),v3(l,b,0),v3(r,b,0),v3(r,m*.7,0),v3(c,m,0)),
            ["9"] = OS(v3(r,b,0),v3(r,t,0),v3(l,t,0),v3(l,m,0),v3(r,m,0)),
            ["-"]  = OS(v3(l*.8,m,0), v3(r*.8,m,0)),
            ["_"]  = OS(v3(l,b,0), v3(r,b,0)),
            ["="]  = OM({v3(l*.8,m+s*.15,0), v3(r*.8,m+s*.15,0)},{v3(l*.8,m-s*.15,0), v3(r*.8,m-s*.15,0)}),
            ["+"]  = OM({v3(l*.8,m,0),  v3(r*.8,m,0)},{v3(c,t*.85,0), v3(c,s*.08,0)}),
            ["["]  = OS(v3(r*.55,t,0),v3(l*.55,t,0),v3(l*.55,b,0),v3(r*.55,b,0)),
            ["]"]  = OS(v3(l*.55,t,0),v3(r*.55,t,0),v3(r*.55,b,0),v3(l*.55,b,0)),
            ["\\"] = OS(v3(l,t,0),v3(r,b,0)),
            ["|"]  = OS(v3(c,t,0),v3(c,b,0)),
            [";"]  = OM({v3(c,m*1.45,0), v3(l*.12,m*1.2,0)},{v3(c,m*.75,0),  v3(l*.4,s*.06,0)}),
            [":"]  = OM({v3(c - 0.25, m*1.45, 0), v3(c + 0.25, m*1.45, 0)},{v3(c - 0.25, m*.55,  0), v3(c + 0.25, m*.55,  0)}),
            ["'"]  = OS(v3(c,t,0),v3(c,t*.72,0)),
            ['"']  = OM({v3(l*.42,t,0), v3(l*.42,t*.72,0)},{v3(r*.42,t,0), v3(r*.42,t*.72,0)}),
            [","]  = OS(v3(c,m*.3,0),v3(l*.4,s*.05,0)),
            ["<"]  = OS(v3(r*.7,t,0),v3(l,m,0),v3(r*.7,b,0)),
            [">"]  = OS(v3(l*.7,t,0),v3(r,m,0),v3(l*.7,b,0)),
            ["."]  = OS(v3(l*.2,s*.1,0),v3(r*.2,s*.1,0)),
            ["/"]  = OS(v3(l,b,0),v3(r,t,0)),
            ["?"]  = OM({v3(l,t*.8,0),v3(c,t,0),v3(r,t*.8,0),v3(r,m*1.5,0),v3(c,m*1.1,0),v3(c,m*.5,0)},{v3(l*.2,s*.1,0), v3(r*.2,s*.1,0)}),
            ["!"]  = OM({v3(c,t,0),    v3(c,m*.55,0)},{v3(l*.22,s*.1,0), v3(r*.22,s*.1,0)}),
            ["#"]  = OM({v3(l*.3,t*.9,0),   v3(l*.3,s*.08,0)},{v3(r*.3,t*.9,0),   v3(r*.3,s*.08,0)},{v3(l*.82,m*1.35,0),v3(r*.82,m*1.35,0)},{v3(l*.82,m*.65,0), v3(r*.82,m*.65,0)}),
            ["^"]  = OS(v3(l*.75,m,0),v3(c,t,0),v3(r*.75,m,0)),
        }

        return map[letter:upper()] or map[letter]
    end

    -- ================================================================
    --  PREVIEW POOL
    -- ================================================================
    local linePool    = {}
    local ballPool    = {}
    local activeLines = {}
    local activeBalls = {}
    local lineIndex   = 0
    local ballIndex   = 0

    local function BeginPreview()  lineIndex = 0; ballIndex = 0 end

    local function EndPreview()
        for i = lineIndex + 1, #activeLines do
            local p = activeLines[i]
            if p.Size.Z ~= 0 then p.Size = Vector3.new(0, 0, 0) end
        end
        for i = ballIndex + 1, #activeBalls do
            local p = activeBalls[i]
            if p.Size.X ~= 0 then p.Size = Vector3.new(0, 0, 0) end
        end
    end

    local function AcquireLine()
        lineIndex += 1
        local part = activeLines[lineIndex]
        if not part then
            part = table.remove(linePool)
            if not part then
                part            = Instance.new("Part")
                part.Anchored   = true
                part.CanCollide = false
                part.CastShadow = false
                part.Material   = Enum.Material.Neon
                part.Color = Color3.fromRGB(27, 42, 53)
            end
            activeLines[lineIndex] = part
        end
        part.Parent = PreviewModel
        return part
    end

    local function AcquireBall()
        ballIndex += 1
        local part = activeBalls[ballIndex]
        if not part then
            part = table.remove(ballPool)
            if not part then
                part            = Instance.new("Part")
                part.Anchored   = true
                part.CanCollide = false
                part.Shape      = Enum.PartType.Ball
                part.Material   = Enum.Material.Neon
                part.Color = Color3.fromRGB(27, 42, 53)
                part.Size       = Vector3.new(0.2, 0.2, 0.2)
            end
            activeBalls[ballIndex] = part
        end
        part.Parent = PreviewModel
        return part
    end

    local function ClearPreview()
        for i = 1, #activeLines do
            local p = activeLines[i]; p.Parent = nil; table.insert(linePool, p)
        end
        for i = 1, #activeBalls do
            local p = activeBalls[i]; p.Parent = nil; table.insert(ballPool, p)
        end
        table.clear(activeLines); table.clear(activeBalls)
        lineIndex = 0; ballIndex = 0
    end

    local function DrawPreviewLine(a, b)
        local dist = (b - a).Magnitude
        if dist < 0.01 then return end
        local part  = AcquireLine()
        part.Size   = Vector3.new(0.15, 0.15, dist)
        part.CFrame = CFrame.new((a + b) / 2, b)
    end

    local function DrawPreviewBall(pos)
        local part  = AcquireBall()
        part.CFrame = CFrame.new(pos)
        if part.Size.X == 0 then part.Size = Vector3.new(0.3, 0.3, 0.3) end
    end

    local function DrawLetterPreview(strokes)
        for _, stroke in ipairs(strokes) do
            for i, point in ipairs(stroke) do
                if i < #stroke then DrawPreviewLine(point, stroke[i + 1]) end
                if i > 1 and i < #stroke then DrawPreviewBall(point) end
            end
        end
    end

    local function RotateStrokes(rawStrokes, letterOrigin)
        local rotated = {}
        for _, stroke in ipairs(rawStrokes) do
            local rotatedStroke = {}
            for _, pt in ipairs(stroke) do
                local offset        = pt - letterOrigin
                local rotatedOffset = WireRotation:VectorToWorldSpace(offset)
                table.insert(rotatedStroke, letterOrigin + rotatedOffset)
            end
            table.insert(rotated, rotatedStroke)
        end
        return rotated
    end

    function MergeWrappedLines(lineList)
        local merged = {}
        for _, line in ipairs(lineList) do
            local trimmed = line:match("^%s*(.-)%s*$") or ""
            local isContinuation = false
            if trimmed:sub(1, 1) == "|" then
                isContinuation = true
            else
                local firstField = (trimmed:match("^([^|]*)") or ""):match("^%s*(.-)%s*$") or ""
                isContinuation = firstField:match("^%-?%d[%d%.]*%s*,%s*%-?%d[%d%.]*%s*,%s*%-?%d[%d%.]*$") ~= nil
            end
            if isContinuation and #merged > 0 then
                merged[#merged] = merged[#merged] .. " | " .. trimmed
            else
                table.insert(merged, line)
            end
        end
        return merged
    end

    -- ================================================================
    --  BLUEPRINT PARSER  (wire-only legacy format)
    -- ================================================================
    local function ParseBlueprint(input)
        local parsed      = {}
        local types       = {}
        local skipped     = 0
        local MIN_DIST    = 0
        local useProperty = false
        local vars        = {}

        local normalized = input
            :gsub("\r\n", "\0"):gsub("\r", "\0"):gsub("\n", "\0"):gsub("||", "\0")

        local function trim(s) return s:match("^%s*(.-)%s*$") or "" end

        local function isBoolHeader(line)
            if line:find("|", 1, true) then return false end
            local low = line:lower()
            return low == "true" or low == "false"
        end

        local function matchVarLine(line)
            if line:find("|", 1, true) then return nil end
            local name, value = line:match("^([%a_][%w_]*)%s*=%s*(.+)$")
            if not name then return nil end
            return name, trim(value)
        end

        local function coerceValue(raw)
            local q = raw:match('^"(.*)"$') or raw:match("^'(.*)'$")
            if q then return q end
            local n = tonumber(raw)
            if n then return n end
            return raw
        end

        local function substituteVars(text)
            return (text:gsub("%$([%a_][%w_]*)", function(name)
                local v = vars[name]
                if v == nil then return "$" .. name end
                return tostring(v)
            end))
        end

        local function evalNumeric(expr)
            local n = tonumber(expr)
            if n then return n end
            local pos = 1
            local function peek()
                while pos <= #expr and expr:sub(pos, pos):match("%s") do pos += 1 end
                return expr:sub(pos, pos)
            end
            local function consume() local c = peek(); pos += 1; return c end
            local parseExpr
            local function parseNumber()
                local start = pos
                while pos <= #expr do
                    local c = expr:sub(pos, pos)
                    if c:match("[%d%.]") then pos += 1 else break end
                end
                return tonumber(expr:sub(start, pos - 1))
            end
            local function parsePrimary()
                local c = peek()
                if c == "(" then consume(); local v = parseExpr(); if peek() ~= ")" then return nil end; consume(); return v
                elseif c == "-" then consume(); local v = parsePrimary(); if v == nil then return nil end; return -v
                elseif c == "+" then consume(); return parsePrimary()
                elseif c:match("[%d%.]") then return parseNumber() end
                return nil
            end
            local function parseTerm()
                local v = parsePrimary(); if v == nil then return nil end
                while true do
                    local c = peek()
                    if c == "*" or c == "/" then
                        consume(); local rhs = parsePrimary(); if rhs == nil then return nil end
                        if c == "*" then v = v * rhs else if rhs == 0 then return nil end; v = v / rhs end
                    else break end
                end
                return v
            end
            parseExpr = function()
                local v = parseTerm(); if v == nil then return nil end
                while true do
                    local c = peek()
                    if c == "+" or c == "-" then
                        consume(); local rhs = parseTerm(); if rhs == nil then return nil end
                        if c == "+" then v = v + rhs else v = v - rhs end
                    else break end
                end
                return v
            end
            local result = parseExpr()
            if peek() ~= "" then return nil end
            return result
        end

        local headerLocked = false
        local pendingWireLines = {}

        for wireDef in (normalized .. "\0"):gmatch("([^\0]*)\0") do
            wireDef = trim(wireDef)
            if wireDef ~= "" then
                if not headerLocked and isBoolHeader(wireDef) then
                    useProperty = (wireDef:lower() == "true")
                elseif not headerLocked then
                    local name, rawValue = matchVarLine(wireDef)
                    if name then vars[name] = coerceValue(rawValue)
                    else headerLocked = true; table.insert(pendingWireLines, wireDef) end
                else table.insert(pendingWireLines, wireDef) end
            end
        end

        pendingWireLines = MergeWrappedLines(pendingWireLines)

        for _, wireDef in ipairs(pendingWireLines) do
            local raw       = {}
            local typeField = nil
            local partIndex = 0
            for part in (wireDef .. "|"):gmatch("([^|]*)|") do
                part = trim(part); partIndex += 1
                if partIndex == 1 then
                    if part ~= "" then
                        local sub = substituteVars(part)
                        local unq = sub:match('^"(.*)"$') or sub:match("^'(.*)'$") or sub
                        if unq ~= "" then typeField = unq end
                    end
                elseif part ~= "" then
                    local sub = substituteVars(part)
                    local xs, ys, zs = sub:match("^([^,]+),([^,]+),([^,]+)$")
                    if xs then
                        local x = evalNumeric(trim(xs))
                        local y = evalNumeric(trim(ys))
                        local z = evalNumeric(trim(zs))
                        if x and y and z then table.insert(raw, Vector3.new(x, y, z)) end
                    end
                end
            end

            if #raw < 2 then skipped += 1
            else
                local points = { raw[1] }
                for i = 2, #raw do
                    if (raw[i] - raw[i-1]).Magnitude >= MIN_DIST then table.insert(points, raw[i]) end
                end
                if #points < 2 then skipped += 1
                else table.insert(parsed, points); table.insert(types, typeField) end
            end
        end

        return parsed, types, skipped, useProperty
    end

    -- ── Text art preview ──
    local function UpdatePreview(origin, word)
        if not word or word == "" then return end
        local maxDist = DEFAULT_MAX
        if placementWires and placementWires[1] then
            maxDist = GetWireMaxLength(placementWires[1])
        end
        local rects = GetPropertySquares()
        local posIndex = 0
        for i = 1, #word do
            local ch = word:sub(i, i)
            if ch ~= " " then
                local letterOrigin = origin + WireRotation:VectorToWorldSpace(
                    Vector3.new(posIndex * Settings.Spacing, 0, 0)
                )
                local rawStrokes = GetLetterPoints(ch, letterOrigin)
                if rawStrokes then
                    local rotated = RotateStrokes(rawStrokes, letterOrigin)
                    for _, stroke in ipairs(rotated) do
                        local lengthOk = not StrokeExceedsMax(stroke, maxDist)
                        local boundsOk = (not rects) or StrokeInsideProperty(stroke, rects)
                        if lengthOk and boundsOk then DrawLetterPreview({stroke}) end
                    end
                end
            end
            posIndex += 1
        end
    end

    -- ── Blueprint preview ──
    local function UpdateBlueprintPreview(origin)
        local rects = GetPropertySquares()
        for i, offsetStroke in ipairs(blueprintWires) do
            local maxDist = DEFAULT_MAX
            local assignedWire = placementWires[i]
            if assignedWire then maxDist = GetWireMaxLength(assignedWire) end
            local worldStroke = {}
            for _, offset in ipairs(offsetStroke) do
                table.insert(worldStroke, origin + WireRotation:VectorToWorldSpace(offset))
            end
            local lengthOk = not StrokeExceedsMax(worldStroke, maxDist)
            local boundsOk = (not rects) or StrokeInsideProperty(worldStroke, rects)
            if lengthOk and boundsOk then DrawLetterPreview({worldStroke}) end
        end
    end

    -- ================================================================
    --  RAYCAST
    -- ================================================================
    local RayParams      = RaycastParams.new()
    RayParams.FilterType = Enum.RaycastFilterType.Exclude

    local function GetCursorWorldPos()
        RayParams.FilterDescendantsInstances = {PreviewModel, Character}
        local unitRay = workspace.CurrentCamera:ScreenPointToRay(Mouse.X, Mouse.Y)
        local result  = workspace:Raycast(unitRay.Origin, unitRay.Direction * 500, RayParams)
        if result then return result.Position end
        local t = -unitRay.Origin.Y / unitRay.Direction.Y
        if t and t > 0 then return unitRay.Origin + unitRay.Direction * t end
        return unitRay.Origin + unitRay.Direction * 50
    end

    -- ================================================================
    --  PLACE LOGIC
    -- ================================================================
    local function FireWire(wireObj, points, Info)
        DrawLetterPreview({points})
        local attempts = 0
        repeat
            ReplicatedStorage.PlaceStructure.ClientPlacedWire:FireServer(
                Info, points, LocalPlayer, wireObj, true
            )
            task.wait(0.25)
            attempts += 1
        until wireObj.Parent == nil or attempts >= 10
        ClearPreview()
        task.wait(0.2)
    end

    local currentWord   = ""
    local ActionElement = nil
    local MoveElement   = nil
    local PreviewActive = false

    local keepSelection    = false
    local exportToProperty = false

    local function PruneDeadWires()
        local alive = {}
        for _, wire in ipairs(SelectedWires) do
            if wire and wire.Parent then table.insert(alive, wire) end
        end
        SelectedWires = alive
        local aliveS = {}
        for _, s in ipairs(SelectedStructures) do
            if s and s.Parent then table.insert(aliveS, s) end
        end
        SelectedStructures = aliveS
        local aliveF = {}
        for _, f in ipairs(SelectedFurniture) do
            if f and f.Parent then table.insert(aliveF, f) end
        end
        SelectedFurniture = aliveF
        local aliveB = {}
        for _, b in ipairs(SelectedBlueprints) do
            if b and b.Parent then table.insert(aliveB, b) end
        end
        SelectedBlueprints = aliveB
        UpdateSelectionVisuals()
    end

    local function StopPlacing()
        PlaceMode      = false
        Placing        = false
        PreviewActive  = false
        BlueprintMode  = false
        MoveMode       = false
        WireRotation   = CFrame.new()
        placementWires = {}
        blueprintWires = {}
        blueprintTypes = {}
        moveWires      = {}
        moveStrokes    = {}
        moveStructures = {}
        moveFurniture  = {}
        moveBlueprints = {}
        for _, clone in ipairs(movePreviewModels) do
            pcall(function() clone:Destroy() end)
        end
        movePreviewModels  = {}
        pendingStructures  = {}
        pendingFurniture   = {}
        pendingIsWorldSpace = false
        usePropertyOrigin = false
        ClearPreview()
        ClearPlankOutlines()
        structureUseIndex = {}
        LassoDragging = false
        if LassoFrame then LassoFrame.Visible = false end
        if not keepSelection then
            ClearSelection()
        else
            PruneDeadWires()
        end
        if ActionElement then
            ActionElement:SetText("Start")
            ActionElement:SetDisabled(false)
        end
        if BlueprintBuild then
            BlueprintBuild:SetText("Start")
            BlueprintBuild:SetDisabled(false)
        end
        if MoveElement then
            MoveElement:SetText("Move")
            MoveElement:SetDisabled(false)
        end
    end

    local function StartPlacing()
        local word = currentWord:upper():gsub("[^A-Z0-9 %-_=+%[%]\\|;:'\",./<>?!#%^]", "")
        if word:gsub(" ", "") == "" then
            Library:Notify("Blueprints", "Enter some text first!")
            return
        end
        if #SelectedWires == 0 then
            Library:Notify("Blueprints", "No wires selected! Use Click Selection or Select All first.", 4)
            return
        end
        placementWires = SelectedWires
        local needed = 0
        for i = 1, #word do
            local ch = word:sub(i,i)
            if ch ~= " " then
                local strokes = GetLetterPoints(ch, Vector3.new())
                needed += (strokes and #strokes or 1)
            end
        end
        if #placementWires < needed then
            Library:Notify("Blueprints", "Need " .. needed .. " wires, selected " .. #placementWires .. "!")
            return
        end
        PlaceMode     = true
        PreviewActive = true
        Library:Notify("Blueprints", "Preview active — left-click to place!")
        if ActionElement then ActionElement:SetText("Cancel") end
    end

    -- ================================================================
    --  PLACEMENT HELPERS (structures, furniture, blueprints)
    -- ================================================================
    local PLACE_TIMEOUT = 8

    local function PlaceWithConfirmation(pm, fireFunc, matchFunc, excludeSet, timeout)
        timeout = timeout or PLACE_TIMEOUT

        local before = {}
        for _, m in ipairs(pm:GetChildren()) do
            before[m] = true
        end

        local deadline  = tick() + timeout
        local retryAt   = 0

        while tick() < deadline do
            if tick() >= retryAt then
                fireFunc()
                retryAt = tick() + 1
            end

            for _, m in ipairs(pm:GetChildren()) do
                if before[m] then continue end
                if excludeSet and excludeSet[m] then continue end
                if matchFunc(m) then
                    if excludeSet then excludeSet[m] = true end
                    return true, m
                end
            end

            task.wait()
        end

        return false, nil
    end

    local function PlaceOneStructure(srcModel, newCF, treeValue, destroyAfter, excludeSet)
        if not ClientPlacedStructure then return false end
        if not srcModel or not srcModel.Parent then return false end
        local itemName = GetItemName(srcModel)

        local pm = workspace:FindFirstChild("PlayerModels")
        if not pm then return false end

        local function fireFunc()
            ClientPlacedStructure:FireServer(itemName, newCF, LocalPlayer, treeValue or false, srcModel, true)
        end
        local function matchFunc(m)
            local typeVal = m:FindFirstChild("Type")
            if not typeVal or (typeVal.Value ~= "Structure" and typeVal.Value ~= "Vehicle Spot") then return false end
            if m:FindFirstChild("PurchasedBoxItemName") then return false end
            local ownerFolder = m:FindFirstChild("Owner")
            local ownerStr    = ownerFolder and ownerFolder:FindFirstChild("OwnerString")
            if not ownerStr or ownerStr.Value ~= LocalPlayer.Name then return false end
            local iname = m:FindFirstChild("ItemName")
            if iname and iname.Value ~= "" and iname.Value ~= itemName then return false end
            return true
        end

        local ok, newModel = PlaceWithConfirmation(pm, fireFunc, matchFunc, excludeSet)
        if not ok then
            warn(("[Blueprints] Structure timed out: %s"):format(itemName))
            return false
        end

        if destroyAfter and srcModel and srcModel.Parent and DestroyStructure then
            pcall(DestroyStructure.FireServer, DestroyStructure, srcModel)
        end
        return true
    end

    -- Places a boxed (PurchasedBox) structure at a specific CFrame.
    --
    -- Correct signature found in reference's Spawn Building section:
    --   FireServer(itemName, newCF, LocalPlayer, nil, srcModel, false, true)
    --   6th arg = false, 7th arg = true — different from placed structures (true, no 7th).
    -- Confirmation: the box disappears from PlayerModels (srcModel.Parent == nil).
    local function PlaceOneBoxedStructure(srcModel, newCF)
        if not ClientPlacedStructure then return false end
        if not srcModel or not srcModel.Parent then return false end
        local itemName = GetItemName(srcModel)
        local attempts = 0
        repeat
            ClientPlacedStructure:FireServer(itemName, newCF, LocalPlayer, nil, srcModel, false, true)
            task.wait(0.25)
            attempts += 1
        until srcModel.Parent == nil or attempts >= 10
        if srcModel.Parent ~= nil then
            warn(("[Blueprints] Boxed structure timed out: %s"):format(itemName))
            return false
        end
        return true
    end
    local function PlaceOneFurniture(srcModel, newCF, destroyAfter, excludeSet)
        if not ClientPlacedStructure then return false end
        if not srcModel or not srcModel.Parent then return false end
        local itemName = GetItemName(srcModel)

        local pm = workspace:FindFirstChild("PlayerModels")
        if not pm then return false end

        local function fireFunc()
            ClientPlacedStructure:FireServer(itemName, newCF, LocalPlayer, false, srcModel, true)
        end
        local function matchFunc(m)
            local typeVal = m:FindFirstChild("Type")
            if not typeVal or typeVal.Value ~= "Furniture" then return false end
            if m:FindFirstChild("PurchasedBoxItemName") then return false end
            local ownerFolder = m:FindFirstChild("Owner")
            local ownerStr    = ownerFolder and ownerFolder:FindFirstChild("OwnerString")
            if not ownerStr or ownerStr.Value ~= LocalPlayer.Name then return false end
            local iname = m:FindFirstChild("ItemName")
            if iname and iname.Value ~= "" and iname.Value ~= itemName then return false end
            return true
        end

        local ok, newModel = PlaceWithConfirmation(pm, fireFunc, matchFunc, excludeSet)
        if not ok then
            warn(("[Blueprints] Furniture timed out: %s"):format(itemName))
            return false
        end

        if destroyAfter and srcModel and srcModel.Parent and DestroyStructure then
            pcall(DestroyStructure.FireServer, DestroyStructure, srcModel)
        end
        return true
    end

    -- ================================================================
    --  PlaceOneBlueprintFromFile
    --  Places a blueprint via ClientPlacedBlueprint and, once confirmed,
    --  teleports a matching plank into it via LOT.
    --  This is ONLY used by the Build File path — NOT by Move Selection.
    -- ================================================================
    local function PlaceOneBlueprintFromFile(itemName, newCF, treeValue, excludeSet)
        if not ClientPlacedBlueprint then return false, nil end

        local pm = workspace:FindFirstChild("PlayerModels")
        if not pm then return false, nil end

        local function fireFunc()
            ClientPlacedBlueprint:FireServer(itemName, newCF, LocalPlayer)
        end
        local function matchFunc(m)
            local typeVal = m:FindFirstChild("Type")
            if not typeVal or typeVal.Value ~= "Blueprint" then return false end
            local ownerFolder = m:FindFirstChild("Owner")
            local ownerStr    = ownerFolder and ownerFolder:FindFirstChild("OwnerString")
            if not ownerStr or ownerStr.Value ~= LocalPlayer.Name then return false end
            local iname = m:FindFirstChild("ItemName")
            if iname and iname.Value ~= "" and iname.Value ~= itemName then return false end
            return true
        end

        local ok, newModel = PlaceWithConfirmation(pm, fireFunc, matchFunc, excludeSet)
        if not ok then
            warn(("[Blueprints] Blueprint timed out (file build): %s"):format(itemName))
            return false, nil
        end

        -- Auto-fill: teleport plank to blueprint once via LOT, then pin it
        -- in place by directly setting CFrame every 0.1s until the blueprint
        -- disappears (filled) or times out (60s). Direct CFrame avoids physics
        -- so elevated blueprints don't drop the plank to the floor.
        if LOT and newModel and newModel.Parent then
            local entry = GetNextPlankForClass(treeValue)
            if entry then
                local function getBlueprintCenter(bp)
                    if bp.PrimaryPart then return bp.PrimaryPart.Position end
                    local sum, count = Vector3.new(), 0
                    for _, p in ipairs(bp:GetDescendants()) do
                        if p:IsA("BasePart") then sum += p.Position; count += 1 end
                    end
                    return count > 0 and (sum / count) or Vector3.new()
                end

                -- Initial teleport via LOT to get the plank to the right place
                LOT.TeleportObjectTo(entry.part, CFrame.new(getBlueprintCenter(newModel)))
                if LOT.WaitForBatch then LOT.WaitForBatch() end

                -- Pin loop: keep CFrame-locking the plank until blueprint is gone
                local deadline = tick() + 3
                while newModel and newModel.Parent and tick() < deadline do
                    if entry.part and entry.part.Parent then
                        local target = getBlueprintCenter(newModel)
                        entry.part.CFrame    = CFrame.new(target)
                        entry.part.Velocity  = Vector3.zero
                        entry.part.RotVelocity = Vector3.zero
                    end
                    task.wait(0.1)
                end
            else
                warn(("[Blueprints] No filtered plank for class '%s'"):format(tostring(treeValue)))
            end
        end

        return true, newModel
    end

    -- Original PlaceOneBlueprint kept for Move Selection (no plank fill)
    local function PlaceOneBlueprint(srcModel, newCF, destroyAfter, excludeSet)
        if not ClientPlacedBlueprint then return false end
        if not srcModel or not srcModel.Parent then return false end
        local itemName = GetItemName(srcModel)

        local pm = workspace:FindFirstChild("PlayerModels")
        if not pm then return false end

        local function fireFunc()
            ClientPlacedBlueprint:FireServer(itemName, newCF, LocalPlayer)
        end
        local function matchFunc(m)
            local typeVal = m:FindFirstChild("Type")
            if not typeVal or typeVal.Value ~= "Blueprint" then return false end
            local ownerFolder = m:FindFirstChild("Owner")
            local ownerStr    = ownerFolder and ownerFolder:FindFirstChild("OwnerString")
            if not ownerStr or ownerStr.Value ~= LocalPlayer.Name then return false end
            local iname = m:FindFirstChild("ItemName")
            if iname and iname.Value ~= "" and iname.Value ~= itemName then return false end
            return true
        end

        local ok, newModel = PlaceWithConfirmation(pm, fireFunc, matchFunc, excludeSet)
        if not ok then
            warn(("[Blueprints] Blueprint timed out: %s"):format(itemName))
            return false
        end

        if destroyAfter and srcModel and srcModel.Parent and DestroyStructure then
            pcall(DestroyStructure.FireServer, DestroyStructure, srcModel)
        end
        return true
    end

    -- FindSourceStructure: returns a selected structure matching itemName.
    -- Only searches SelectedStructures — never grabs unselected objects from the plot.
    -- Uses round-robin so each selected instance is consumed once per build.
    -- Returns nil if nothing selected matches (caller will skip that entry).
    local structureUseIndex = {}  -- tracks next index per itemName within SelectedStructures
    local function FindSourceStructure(itemName)
        if #SelectedStructures == 0 then return nil end
        local startIdx = structureUseIndex[itemName] or 1
        for attempt = 1, #SelectedStructures do
            local idx = ((startIdx - 1 + attempt - 1) % #SelectedStructures) + 1
            local model = SelectedStructures[idx]
            if model and model.Parent and GetItemName(model) == itemName then
                structureUseIndex[itemName] = (idx % #SelectedStructures) + 1
                return model
            end
        end
        return nil
    end

    local function FindSourceFurniture(itemName)
        local pm = workspace:FindFirstChild("PlayerModels")
        if not pm then return nil end
        for _, model in ipairs(pm:GetChildren()) do
            local typeVal = model:FindFirstChild("Type")
            if not typeVal or typeVal.Value ~= "Furniture" then continue end
            if model:FindFirstChild("PurchasedBoxItemName") then continue end
            if not IsOwnedByLocalPlayer(model) then continue end
            if GetItemName(model) == itemName then return model end
        end
        return nil
    end

    -- ================================================================
    --  UI ELEMENTS
    -- ================================================================
    InitLassoGui()

    Tab:CreateSection("Selection Tools")

    local ClickToggle, LassoToggle, GroupSelectToggle

    ClickToggle = Tab:CreateToggle("Click Selection", false, function(val)
        ClickSelectMode = val
        if val then
            if LassoMode then
                LassoMode     = false
                LassoDragging = false
                if LassoFrame then LassoFrame.Visible = false end
                if LassoToggle then LassoToggle:SetState(false) end
            end
            if GroupSelectMode then
                GroupSelectMode = false
                if GroupSelectToggle then GroupSelectToggle:SetState(false) end
            end
        end
    end)

    GroupSelectToggle = Tab:CreateToggle("Group Selection", false, function(val)
        GroupSelectMode = val
        if val then
            if ClickSelectMode then
                ClickSelectMode = false
                if ClickToggle then ClickToggle:SetState(false) end
            end
            if LassoMode then
                LassoMode     = false
                LassoDragging = false
                if LassoFrame then LassoFrame.Visible = false end
                if LassoToggle then LassoToggle:SetState(false) end
            end
        end
    end)

    LassoToggle = Tab:CreateToggle("Lasso Tool", false, function(val)
        LassoMode = val
        if val then
            if ClickSelectMode then
                ClickSelectMode = false
                if ClickToggle then ClickToggle:SetState(false) end
            end
            if GroupSelectMode then
                GroupSelectMode = false
                if GroupSelectToggle then GroupSelectToggle:SetState(false) end
            end
        else
            LassoDragging = false
            if LassoFrame then LassoFrame.Visible = false end
        end
    end)

    local SelectRow = Tab:CreateRow()
    SelectRow:CreateAction("Clear Selection", "Clear", ClearSelection)
    MoveElement = SelectRow:CreateAction("Move Selection", "Move", function()
        if PlaceMode or Placing then StopPlacing(); return end

        local hasWires  = #SelectedWires > 0
        local hasStruct = #SelectedStructures > 0
        local hasFurn   = #SelectedFurniture > 0
        local hasBP     = #SelectedBlueprints > 0

        if not hasWires and not hasStruct and not hasFurn and not hasBP then
            Library:Notify("Blueprints", "No items selected!"); return
        end

        local anchorPos = Vector3.new()
        local anchorCount = 0
        for _, w in ipairs(SelectedWires) do
            local pts = GetWirePoints(w)
            if pts and #pts > 0 then
                anchorPos = anchorPos + pts[1]
                anchorCount += 1
            end
        end
        for _, s in ipairs(SelectedStructures) do
            local cf = GetStructureCFrame(s)
            if cf then anchorPos = anchorPos + cf.Position; anchorCount += 1 end
        end
        for _, f in ipairs(SelectedFurniture) do
            local cf = f:GetPivot()
            anchorPos = anchorPos + cf.Position; anchorCount += 1
        end
        for _, b in ipairs(SelectedBlueprints) do
            local cf = GetStructureCFrame(b) or b:GetPivot()
            if cf then anchorPos = anchorPos + cf.Position; anchorCount += 1 end
        end
        if anchorCount == 0 then Library:Notify("Blueprints", "Could not compute selection anchor.", 4); return end
        anchorPos = anchorPos / anchorCount

        if hasWires then
            local _, err, validWires = BuildMoveStrokes(SelectedWires)
            if not validWires then Library:Notify("Blueprints", err or "Could not prepare wire move", 4); return end
            moveWires      = validWires
            placementWires = validWires
            blueprintTypes = {}
        end

        local lowestY = math.huge

        local function GetItemBBInfo(model, getCFFunc)
            local placedCF = getCFFunc()
            if not placedCF then return nil end
            local ok, bbCF, bbSize = pcall(function() return model:GetBoundingBox() end)
            local bottomY, halfH, halfX, halfZ
            if ok and bbSize then
                -- bbSize is along the model's LOCAL axes. For rotated models
                -- (e.g. a wall lying on its long side) bbSize.Y is NOT the world
                -- vertical extent, so project the 8 OBB corners into world space
                -- and take the true min/max world Y.
                local hx, hy, hz = bbSize.X * 0.5, bbSize.Y * 0.5, bbSize.Z * 0.5
                local minWY, maxWY = math.huge, -math.huge
                for _, sx in ipairs({-1, 1}) do
                    for _, sy in ipairs({-1, 1}) do
                        for _, sz in ipairs({-1, 1}) do
                            local wy = (bbCF * CFrame.new(sx*hx, sy*hy, sz*hz)).Position.Y
                            if wy < minWY then minWY = wy end
                            if wy > maxWY then maxWY = wy end
                        end
                    end
                end
                bottomY = minWY
                halfH   = (maxWY - minWY) * 0.5
                halfX   = hx
                halfZ   = hz
            else
                halfH, halfX, halfZ = 1, 1, 1
                bottomY = placedCF.Position.Y - halfH
            end
            return { cf = placedCF, bottomY = bottomY, halfH = halfH, halfX = halfX, halfZ = halfZ }
        end

        local structInfos   = {}
        local furnInfos     = {}

        for _, s in ipairs(SelectedStructures) do
            local info = GetItemBBInfo(s, function() return GetStructureCFrame(s) end)
            if info then
                table.insert(structInfos, { model = s, info = info })
                if info.bottomY < lowestY then lowestY = info.bottomY end
            end
        end
        for _, f in ipairs(SelectedFurniture) do
            local info = GetItemBBInfo(f, function() return f:GetPivot() end)
            if info then
                table.insert(furnInfos, { model = f, info = info })
                if info.bottomY < lowestY then lowestY = info.bottomY end
            end
        end

        local bpInfos = {}
        for _, b in ipairs(SelectedBlueprints) do
            local placedCF = GetStructureCFrame(b) or b:GetPivot()
            if placedCF then
                local info = {
                    cf      = placedCF,
                    bottomY = placedCF.Position.Y,
                    halfH   = 0,
                    halfX   = 4,
                    halfZ   = 4,
                }
                table.insert(bpInfos, { model = b, info = info })
                if info.bottomY < lowestY then lowestY = info.bottomY end
            end
        end

        if lowestY == math.huge then lowestY = anchorPos.Y end

        if hasWires then
            blueprintWires = {}
            for _, w in ipairs(moveWires) do
                local pts = GetWirePoints(w)
                if pts then
                    local offsets = {}
                    for _, p in ipairs(pts) do
                        offsets[#offsets+1] = Vector3.new(
                            p.X - anchorPos.X,
                            p.Y - lowestY,
                            p.Z - anchorPos.Z
                        )
                    end
                    blueprintWires[#blueprintWires+1] = offsets
                end
            end
        end

        moveStructures = {}
        for _, entry in ipairs(structInfos) do
            local s   = entry.model
            local inf = entry.info
            local xzOff  = Vector3.new(inf.cf.Position.X - anchorPos.X, 0, inf.cf.Position.Z - anchorPos.Z)
            local yAbove = inf.cf.Position.Y - lowestY
            table.insert(moveStructures, {
                model      = s,
                offsetPos  = inf.cf.Position - anchorPos,
                xzOffset   = xzOff,
                yAbove     = yAbove,
                halfH      = inf.halfH,
                halfX      = inf.halfX,
                halfZ      = inf.halfZ,
                cf         = inf.cf,
                itemName   = GetItemName(s),
                treeValue  = GetStructureTreeValue(s),
            })
        end

        moveFurniture = {}
        for _, entry in ipairs(furnInfos) do
            local f   = entry.model
            local inf = entry.info
            local xzOff  = Vector3.new(inf.cf.Position.X - anchorPos.X, 0, inf.cf.Position.Z - anchorPos.Z)
            local yAbove = inf.cf.Position.Y - lowestY
            table.insert(moveFurniture, {
                model      = f,
                offsetPos  = inf.cf.Position - anchorPos,
                xzOffset   = xzOff,
                yAbove     = yAbove,
                halfH      = inf.halfH,
                halfX      = inf.halfX,
                halfZ      = inf.halfZ,
                cf         = inf.cf,
                itemName   = GetItemName(f),
            })
        end

        moveBlueprints = {}
        for _, entry in ipairs(bpInfos) do
            local b   = entry.model
            local inf = entry.info
            local xzOff  = Vector3.new(inf.cf.Position.X - anchorPos.X, 0, inf.cf.Position.Z - anchorPos.Z)
            local yAbove = inf.cf.Position.Y - lowestY
            table.insert(moveBlueprints, {
                model      = b,
                offsetPos  = inf.cf.Position - anchorPos,
                xzOffset   = xzOff,
                yAbove     = yAbove,
                halfH      = inf.halfH,
                halfX      = inf.halfX,
                halfZ      = inf.halfZ,
                cf         = inf.cf,
                itemName   = GetItemName(b),
                isBlueprint = true,
            })
        end

        usePropertyOrigin = false

        for _, clone in ipairs(movePreviewModels) do pcall(function() clone:Destroy() end) end
        movePreviewModels = {}

        local function MakePreviewClone(model)
            local clone = model:Clone()
            for _, part in ipairs(clone:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                    part.CastShadow = false
                    part.Anchored   = true
                end
            end
            if clone:IsA("BasePart") then
                clone.CanCollide = false
                clone.CastShadow = false
                clone.Anchored   = true
            end
            clone.Parent = PreviewModel
            return clone
        end

        for _, entry in ipairs(moveStructures) do
            local clone = MakePreviewClone(entry.model)
            table.insert(movePreviewModels, clone)
            entry.previewClone = clone
        end
        for _, entry in ipairs(moveFurniture) do
            local clone = MakePreviewClone(entry.model)
            table.insert(movePreviewModels, clone)
            entry.previewClone = clone
        end
        for _, entry in ipairs(moveBlueprints) do
            local clone = MakePreviewClone(entry.model)
            table.insert(movePreviewModels, clone)
            entry.previewClone = clone
        end

        MoveMode      = true
        BlueprintMode = hasWires
        PlaceMode     = true
        PreviewActive = true
        MoveElement:SetText("Cancel")
        Library:Notify("Blueprints", "Move preview — left-click to place.", 3)
    end)

-- ================================================================
    --  PLANK FILL SECTION
    -- ================================================================
    Tab:CreateSection("Plank Fill")

    -- Static list of every plank type — no scanning, no lag. Selecting a type
    -- the player doesn't own (within the Settings Y range) turns off + disables
    -- the Click-to-Fill toggle and disables the Fill button.
    -- NOTE: these must match your planks' TreeClass values exactly (case-sensitive).
    local PLANK_TYPES = {
        "Generic", "Cherry", "Birch", "Oak", "Walnut", "Koa", "Pine", "Palm", "Fir",
        "Volcano", "Frost", "GreenSwampy", "GoldSwampy",
        "SnowGlow", "CaveCrawler", "LoneCave", "Spook", "Sinister",
    }

    local clickFillMode     = false
    local selectedPlankType = PLANK_TYPES[1]

    local fillRunning = false
    local fillCancel  = false

    local PlankTypeDropdown
    local FillAllBtn
    local ClickFillToggle

    local function GetBlueprintCenter(bp)
        if bp.PrimaryPart then return bp.PrimaryPart.Position end
        local sum, count = Vector3.new(), 0
        for _, p in ipairs(bp:GetDescendants()) do
            if p:IsA("BasePart") then sum += p.Position; count += 1 end
        end
        return count > 0 and (sum / count) or Vector3.new()
    end

    -- TP a plank into a blueprint via LOT and pin it for 1s.
    local function FillBlueprintWithPlank(bp, entry)
        if not LOT then return false end
        if not (bp and bp.Parent and entry and entry.part and entry.part.Parent) then return false end
        LOT.TeleportObjectTo(entry.part, CFrame.new(GetBlueprintCenter(bp)))
        if LOT.WaitForBatch then LOT.WaitForBatch() end
        local deadline = tick() + 1
        while bp and bp.Parent and tick() < deadline do
            if entry.part and entry.part.Parent then
                entry.part.CFrame      = CFrame.new(GetBlueprintCenter(bp))
                entry.part.Velocity    = Vector3.zero
                entry.part.RotVelocity = Vector3.zero
            end
            task.wait(0.1)
        end
        return true
    end

    -- Cheap, on-demand check: does the player own a plank of `cls` within the
    -- Settings Y range? Doesn't touch filteredPlanks/outlines, so no lag.
    local function PlayerHasPlankType(cls)
        local pm = workspace:FindFirstChild("PlayerModels")
        if not pm then return false end
        for _, model in ipairs(pm:GetChildren()) do
            if model.Name == "Plank" and model:IsA("Model") and IsOwnedByLocalPlayer(model) then
                local tc   = model:FindFirstChild("TreeClass")
                local part = model:FindFirstChild("Main") or model:FindFirstChildWhichIsA("BasePart")
                if part and part:IsA("BasePart") then
                    local tcv = (tc and tc:IsA("StringValue") and tc.Value) or ""
                    local sz  = part.Size
                    local vol = math.floor(sz.X * sz.Y * sz.Z * 10 + 0.5) / 10
                    if tcv == cls and vol >= plankFilterMin and vol <= plankFilterMax then
                        return true
                    end
                end
            end
        end
        return false
    end

    -- Returns whether the selected type is owned, but never disables the UI.
    -- The button/toggle stay enabled regardless; fill actions notify if empty.
    local function ValidateSelectedType()
        return selectedPlankType and PlayerHasPlankType(selectedPlankType)
    end

    PlankTypeDropdown = Tab:CreateDropdown("Plank Type", PLANK_TYPES, PLANK_TYPES[1], function(val)
        selectedPlankType = val
        ValidateSelectedType()
    end)

    local PlankFillRow = Tab:CreateRow()
    FillAllBtn = PlankFillRow:CreateAction("Fill Blueprints", "Start", function()
        -- Clicking while a fill is in progress = Stop.
        if fillRunning then
            fillCancel = true
            return
        end

        if not LOT then
            Library:Notify("Blueprints", "LOT not available — cannot fill.", 4); return
        end
        if not ValidateSelectedType() then
            Library:Notify("Blueprints", "No '" .. tostring(selectedPlankType) .. "' planks in the Y range.", 5); return
        end
        local cls = selectedPlankType
        local pm = workspace:FindFirstChild("PlayerModels")
        if not pm then Library:Notify("Blueprints", "PlayerModels not found.", 4); return end
        local blueprints = {}
        for _, m in ipairs(pm:GetChildren()) do
            local typeVal = m:FindFirstChild("Type")
            if typeVal and typeVal.Value == "Blueprint" and IsOwnedByLocalPlayer(m) then
                table.insert(blueprints, m)
            end
        end
        if #blueprints == 0 then
            ClearPlankOutlines()
            Library:Notify("Blueprints", "No blueprints to fill.", 4); return
        end
        -- Only highlight/prepare planks once we know there's something to fill.
        allPlanks = ScanAllOwnedPlanks()
        ApplyPlankYFilter()

        fillRunning = true
        fillCancel  = false
        FillAllBtn:SetText("Stop")

        task.spawn(function()
            local filled = 0
            for _, bp in ipairs(blueprints) do
                if fillCancel then break end
                if bp.Parent then
                    local entry = GetNextPlankForClass(cls)
                    if not entry then
                        Library:Notify("Blueprints", "Ran out of matching planks in Y range.", 4)
                        break
                    end
                    if FillBlueprintWithPlank(bp, entry) then filled += 1 end
                end
            end
            local cancelled = fillCancel
            fillRunning = false
            fillCancel  = false
            FillAllBtn:SetText("Start")
            ClearPlankOutlines()
            Library:Notify("Blueprints",
                (cancelled and "Stopped — filled %d/%d blueprint(s)." or "Filled %d/%d blueprint(s)."):format(filled, #blueprints), 4)
        end)
    end)
    ClickFillToggle = PlankFillRow:CreateToggle("Click to Fill", false, function(val)
        clickFillMode = val
        if val then
            allPlanks = ScanAllOwnedPlanks()
            ApplyPlankYFilter()
        else
            ClearPlankOutlines()
        end
    end)

    ValidateSelectedType()

    -- ================================================================
    --  TEXT ART SECTION
    -- ================================================================
    Tab:CreateSection("Wire Text Art")
    local WordInput = Tab:CreateInput("Text Field", "Enter...", function(text)
        text = text:upper():gsub("[^A-Z0-9 %-_=+%[%]\\|;:\'\",./<>?!#%^]", "")
        currentWord = text
        WordInput:SetText(text)
    end)
    local ScaleSlider = Tab:CreateSlider("Scale", 2, 10, Settings.Scale, function(val)
        Settings.Scale = val
    end, 1)
    local SpacingSlider = Tab:CreateSlider("Spacing", 1, 12, Settings.Spacing, function(val)
        Settings.Spacing = val
    end, 1)
    ActionElement = Tab:CreateAction("Process", "Start", function()
        if PlaceMode then StopPlacing() else StartPlacing() end
    end)

    -- ================================================================
    --  CUSTOM INPUT / FILE SECTION
    -- ================================================================
    Tab:CreateSection("Blueprint Builder")

    local BLUEPRINT_FOLDER = "Dynxe/Blueprints"
    local LEGACY_FOLDER    = "Dynxe/WireArt"  -- old name; auto-migrated on load
    
    -- ================================================================
    --  ENSURE FOLDER STRUCTURE EXISTS (guaranteed on module init)
    -- ================================================================
    if isfolder and makefolder then
        -- Create main Dynxe folder if missing
        if not isfolder("Dynxe") then
            pcall(makefolder, "Dynxe")
        end
        -- Create Blueprints subfolder if missing
        if not isfolder(BLUEPRINT_FOLDER) then
            pcall(makefolder, BLUEPRINT_FOLDER)
        end
    end
    
    pcall(function()
        if not (isfolder and makefolder) then return end

        -- One-time migration: if an old "WireArt" folder exists, copy its
        -- contents into "Blueprints" verbatim (same file names, same data).
        -- Existing files in Blueprints are NEVER overwritten, then the old
        -- folder is removed once everything has been copied over.
        if isfolder(LEGACY_FOLDER) and listfiles and readfile and writefile then
            local function migrate(folder)
                local ok, entries = pcall(listfiles, folder)
                if not ok or type(entries) ~= "table" then return end
                for _, path in ipairs(entries) do
                    if type(path) == "string" then
                        local isDir = pcall(function() return isfolder(path) end) and isfolder(path)
                        if isDir then
                            migrate(path)  -- recurse into any subfolders
                        else
                            local rel = path:match("WireArt[/\\](.+)$") or path:match("([^/\\]+)$")
                            if rel then
                                local dest = BLUEPRINT_FOLDER .. "/" .. rel
                                -- recreate nested subfolders if the file lived in one
                                local subDir = dest:match("^(.*)[/\\][^/\\]+$")
                                if subDir and not isfolder(subDir) then
                                    pcall(makefolder, subDir)
                                end
                                local exists = false
                                if isfile then
                                    local iok, ires = pcall(isfile, dest)
                                    exists = iok and ires
                                end
                                if not exists then
                                    local rok, data = pcall(readfile, path)
                                    if rok and data ~= nil then
                                        pcall(writefile, dest, data)
                                    end
                                end
                            end
                        end
                    end
                end
            end
            migrate(LEGACY_FOLDER)
            if delfolder then pcall(delfolder, LEGACY_FOLDER) end
        end
    end)

    local function ScanBlueprintFiles()
        local files = {}
        local seen = {}
        local function scan(folder)
            local ok, result = pcall(function()
                if listfiles then return listfiles(folder) end
                return {}
            end)
            if not ok or not result then return end
            for _, path in ipairs(result) do
                if type(path) == "string" then
                    local isDir = pcall(function() return isfolder and isfolder(path) end) and isfolder(path)
                    if isDir then
                        scan(path)
                    elseif path:lower():match("%.txt$") or path:lower():match("%.dynxe$") then
                        local rel = path:match("Blueprints[/\\](.+)$") or path:match("WireArt[/\\](.+)$") or path:match("([^/\\]+)$") or path
                        if not seen[rel] then
                            seen[rel] = true
                            table.insert(files, rel)
                        end
                    end
                end
            end
        end
        scan(BLUEPRINT_FOLDER)
        table.sort(files, function(a, b) return a:lower() < b:lower() end)
        return files
    end

    local selectedFile = nil
    local fileList = ScanBlueprintFiles()
    if #fileList == 0 then table.insert(fileList, "No files found") end

    local FileDropdown = Tab:CreateDropdown("Blueprint File", fileList, fileList[1], function(val)
        selectedFile = (val ~= "No files found") and val or nil
    end)
    if fileList[1] and fileList[1] ~= "No files found" then
        selectedFile = fileList[1]
    end

    local BuildRow = Tab:CreateRow()
    BuildRow:CreateAction("Refresh Files", "Refresh", function()
        fileList = ScanBlueprintFiles()
        if #fileList == 0 then fileList = {"No files found"}; selectedFile = nil
        else selectedFile = fileList[1] end
        FileDropdown:SetOptions(fileList)
        Library:Notify("Blueprints", "Found " .. (selectedFile and #fileList or 0) .. " blueprint file(s)", 3)
    end)

    -- ================================================================
    --  BuildFilePlacementData
    -- ================================================================
    local function BuildFilePlacementData(structEntries, furnEntries, isPropertyMode, wireOrigin, sharedLowestY)
        for _, clone in ipairs(movePreviewModels) do pcall(function() clone:Destroy() end) end
        movePreviewModels = {}
        moveStructures    = {}
        moveFurniture     = {}

        local function MakePreviewClone(model)
            local clone = model:Clone()
            for _, part in ipairs(clone:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false; part.CastShadow = false; part.Anchored = true
                end
            end
            if clone:IsA("BasePart") then
                clone.CanCollide = false; clone.CastShadow = false; clone.Anchored = true
            end
            clone.Parent = PreviewModel
            return clone
        end

        local function FindPreviewSource(itemName)
            local pm = workspace:FindFirstChild("PlayerModels")
            if not pm then return nil end
            for _, m in ipairs(pm:GetChildren()) do
                local typeVal = m:FindFirstChild("Type")
                if typeVal and (typeVal.Value == "Blueprint" or typeVal.Value == "Structure" or typeVal.Value == "Vehicle Spot")
                and IsOwnedByLocalPlayer(m)
                and GetItemName(m) == itemName then
                    return m
                end
            end
            return nil
        end

        if isPropertyMode then
            for _, entry in ipairs(structEntries) do
                local src = FindPreviewSource(entry.itemName)
                local clone = src and MakePreviewClone(src) or nil
                table.insert(moveStructures, {
                    isFileBuild    = true,
                    isPropertyMode = true,
                    worldCF        = entry.cf,
                    cf             = entry.cf,
                    itemName       = entry.itemName,
                    treeValue      = entry.treeValue,
                    xzOffset       = Vector3.new(0, 0, 0),
                    yAbove         = 0,
                    halfH          = 1, halfX = 1, halfZ = 1,
                    previewClone   = clone,
                })
                if clone then
                    table.insert(movePreviewModels, clone)
                    pcall(function()
                        if clone.PrimaryPart then clone:SetPrimaryPartCFrame(entry.cf)
                        else clone:PivotTo(entry.cf) end
                    end)
                end
            end

            for _, entry in ipairs(furnEntries) do
                local src = FindSourceFurniture(entry.itemName)
                if not src then continue end
                local clone = MakePreviewClone(src)
                table.insert(moveFurniture, {
                    model          = src,
                    xzOffset       = Vector3.new(0, 0, 0),
                    yAbove         = 0,
                    halfH          = 1, halfX = 1, halfZ = 1,
                    worldCF        = entry.cf,
                    cf             = entry.cf,
                    itemName       = entry.itemName,
                    isFileBuild    = true,
                    isPropertyMode = true,
                    previewClone   = clone,
                })
                table.insert(movePreviewModels, clone)
                pcall(function()
                    if clone.PrimaryPart then clone:SetPrimaryPartCFrame(entry.cf)
                    else clone:PivotTo(entry.cf) end
                end)
            end

        else
            -- ── ROBUST BOTTOM-ANCHORING ──────────────────────────────────────
            -- Don't predict pivot-to-bottom from a source model — that breaks when
            -- the live source's orientation differs from the saved CFrame (e.g. a
            -- vehicle spot upright on the plot vs. saved flat). Instead POSITION each
            -- clone at its saved CFrame using the SAME method the render loop uses,
            -- then measure its real world-space bottom. The lowest measured bottom is
            -- the floor that lands at the cursor. With wires present, sharedLowestY is
            -- the agreed baseline so structures stay aligned to the wires.
            local function PositionClone(clone, cf)
                pcall(function()
                    if clone.PrimaryPart then clone:SetPrimaryPartCFrame(cf) else clone:PivotTo(cf) end
                end)
            end

            local function MeasuredBottomY(clone, cf)
                PositionClone(clone, cf)
                local ok, bbCF, bbSize = pcall(function() return clone:GetBoundingBox() end)
                if not (ok and bbCF and bbSize) then return cf.Position.Y end
                local hx, hy, hz = bbSize.X * 0.5, bbSize.Y * 0.5, bbSize.Z * 0.5
                local minWY = math.huge
                for _, sx in ipairs({-1, 1}) do
                    for _, sy in ipairs({-1, 1}) do
                        for _, sz in ipairs({-1, 1}) do
                            local wy = (bbCF * CFrame.new(sx*hx, sy*hy, sz*hz)).Position.Y
                            if wy < minWY then minWY = wy end
                        end
                    end
                end
                return minWY
            end

            local structItems, furnItems = {}, {}
            local groupBottomRelY = sharedLowestY or math.huge

            for _, entry in ipairs(structEntries) do
                local src   = FindPreviewSource(entry.itemName)
                local clone = src and MakePreviewClone(src) or nil
                if clone and not sharedLowestY then
                    local botY = MeasuredBottomY(clone, entry.cf)
                    if botY < groupBottomRelY then groupBottomRelY = botY end
                end
                table.insert(structItems, { entry = entry, clone = clone })
            end
            for _, entry in ipairs(furnEntries) do
                local src = FindSourceFurniture(entry.itemName)
                if src then
                    local clone = MakePreviewClone(src)
                    if not sharedLowestY then
                        local botY = MeasuredBottomY(clone, entry.cf)
                        if botY < groupBottomRelY then groupBottomRelY = botY end
                    end
                    table.insert(furnItems, { entry = entry, clone = clone, src = src })
                end
            end
            if groupBottomRelY == math.huge then groupBottomRelY = 0 end

            for _, it in ipairs(structItems) do
                local entry, clone = it.entry, it.clone
                local relPos = entry.cf.Position
                table.insert(moveStructures, {
                    isFileBuild = true,
                    xzOffset    = wireOrigin and Vector3.new(relPos.X - wireOrigin.X, 0, relPos.Z - wireOrigin.Z) or Vector3.new(relPos.X, 0, relPos.Z),
                    yAbove      = relPos.Y - groupBottomRelY,
                    halfH = 1, halfX = 1, halfZ = 1,
                    cf = entry.cf, relCF = entry.cf,
                    itemName = entry.itemName, treeValue = entry.treeValue,
                    previewClone = clone,
                })
                if clone then table.insert(movePreviewModels, clone) end
            end
            for _, it in ipairs(furnItems) do
                local entry, clone, src = it.entry, it.clone, it.src
                local relPos = entry.cf.Position
                table.insert(moveFurniture, {
                    model = src,
                    xzOffset = wireOrigin and Vector3.new(relPos.X - wireOrigin.X, 0, relPos.Z - wireOrigin.Z) or Vector3.new(relPos.X, 0, relPos.Z),
                    yAbove = relPos.Y - groupBottomRelY,
                    halfH = 1, halfX = 1, halfZ = 1,
                    cf = entry.cf, relCF = entry.cf,
                    itemName = entry.itemName, isFileBuild = true,
                    previewClone = clone,
                })
                table.insert(movePreviewModels, clone)
            end
        end
    end

    BlueprintBuild = BuildRow:CreateAction("Build File", "Start", function()
        if PlaceMode or Placing then StopPlacing(); return end

        local function hasCFrameLine(txt)
            for line in (txt .. "\n"):gmatch("([^\n]*)\n") do
                local f2 = line:match("^[^|]+|([^|]+)")
                if f2 then
                    local nums = 0
                    for _ in f2:gmatch("[^,]+") do nums += 1 end
                    if nums == 12 then return true end
                end
            end
            return false
        end

        if not selectedFile then
            Library:Notify("Blueprints", "No blueprint file selected" .. BLUEPRINT_FOLDER .. "/", 5)
            return
        end

        local filePath = BLUEPRINT_FOLDER .. "/" .. selectedFile
        local clipText = nil
        local readOk, readResult = pcall(function()
            if not readfile then return nil, "no readfile" end
            return readfile(filePath)
        end)
        if readOk and readResult and readResult ~= "" then
            clipText = readResult
        end
        if not clipText then
            local reason = "unknown"
            if not readfile then reason = "readfile not available"
            elseif not readOk then reason = "read error: " .. tostring(readResult)
            elseif not readResult or readResult == "" then reason = "file empty or not found"
            end
            Library:Notify("Blueprints", "Could not read file: " .. selectedFile .. " (" .. reason .. ")", 5)
            return
        end
        local isCombined = clipText:find("%[Wires%]") or clipText:find("%[Structures%]")
            or clipText:find("%[Furniture%]") or hasCFrameLine(clipText)

        -- Does this file contain anything that needs a plank? (structure line with
        -- a non-empty treeValue = wood blueprint). If not, never touch the planks.
        local function FileNeedsWood(text)
            local inStructures = false
            for line in (text .. "\n"):gmatch("([^\n]*)\n") do
                local trimmed = line:match("^%s*(.-)%s*$") or ""
                if trimmed:match("^%[(.-)%]$") then
                    inStructures = trimmed:lower():find("structures") ~= nil
                elseif trimmed ~= "" and trimmed:sub(1,2) ~= "--" then
                    local fields = {}
                    for f in (trimmed .. " | "):gmatch("([^|]*)|") do
                        table.insert(fields, f:match("^%s*(.-)%s*$") or "")
                    end
                    -- headerless auto-detect: a 12-num field 2 means struct/furniture
                    local f2nums = 0
                    if fields[2] then for _ in fields[2]:gmatch("[^,]+") do f2nums += 1 end end
                    if (inStructures or f2nums == 12) and #fields >= 3 and fields[3] ~= "" then
                        return true
                    end
                end
            end
            return false
        end

        local needsWood = FileNeedsWood(clipText)

        if needsWood then
            allPlanks = ScanAllOwnedPlanks()
            ApplyPlankYFilter()
            if LOT and #allPlanks > 0 then
                Library:Notify("Blueprints",
                    ("Planks scanned: %d total, %d in Y range %.1f–%.1f"):format(
                        #allPlanks, #filteredPlanks, plankFilterMin, plankFilterMax), 3)
            end
        else
            ClearPlankOutlines()
        end

        -- Pre-flight plank count check: count how many wood-blueprint structures
        -- are in the file so we can warn before starting if planks are insufficient.
        local function CountBlueprintStructures(text)
            local count = 0
            local inStructures = false
            for line in (text .. "\n"):gmatch("([^\n]*)\n") do
                local trimmed = line:match("^%s*(.-)%s*$") or ""
                if trimmed:match("^%[(.-)%]$") then
                    inStructures = trimmed:lower():find("structures") ~= nil
                elseif inStructures and trimmed ~= "" and trimmed:sub(1,2) ~= "--" then
                    -- treeValue is the 3rd pipe-delimited field; non-empty = wood blueprint
                    local fields = {}
                    for f in (trimmed .. " | "):gmatch("([^|]*)|") do
                        table.insert(fields, f:match("^%s*(.-)%s*$") or "")
                    end
                    if #fields >= 3 and fields[3] ~= "" then count += 1 end
                end
            end
            return count
        end

        if LOT and clipText then
            local needed = CountBlueprintStructures(clipText)
            if needed > 0 and #filteredPlanks < needed then
                Library:Notify("Blueprints",
                    ("Not enough planks — need %d, have %d in Y range %.1f–%.1f"):format(
                        totalNeeded, #filteredPlanks, plankFilterMin, plankFilterMax), 7)
                return
            end
        end

        if isCombined then
            local wires, wireTypes, structures, furniture, skipped, useProperty =
                ParseCombinedBlueprint(clipText)

            if skipped > 0 then
                Library:Notify("Blueprints", skipped .. " entry(s) skipped — bad format", 3)
            end

            local hasWires      = #wires > 0
            local hasStructures = #structures > 0
            local hasFurniture  = #furniture > 0

            -- Pre-flight plank check using parsed structures directly
            if LOT and hasStructures then
                local neededByClass = {}
                for _, entry in ipairs(structures) do
                    if entry.treeValue and entry.treeValue ~= "" then
                        -- If user has a selected structure of this type, it won't need a plank
                        local src = FindSourceStructure(entry.itemName)
                        if not src then
                            neededByClass[entry.treeValue] = (neededByClass[entry.treeValue] or 0) + 1
                        end
                    end
                end
                -- Reset the round-robin index so placement starts fresh
                structureUseIndex = {}
                local totalNeeded = 0
                for _, count in pairs(neededByClass) do totalNeeded += count end
                if totalNeeded > 0 and #filteredPlanks < totalNeeded then
                    Library:Notify("Blueprints",
                        ("Not enough planks — need %d, have %d in Y range %.1f–%.1f"):format(
                            totalNeeded, #filteredPlanks, plankFilterMin, plankFilterMax), 7)
                    return
                end
            end

            -- Pre-flight: non-wood structures need matching selected sources
            if hasStructures then
                local structNeeded = {}
                for _, entry in ipairs(structures) do
                    if not entry.treeValue or entry.treeValue == "" then
                        structNeeded[entry.itemName] = (structNeeded[entry.itemName] or 0) + 1
                    end
                end
                local structHave = {}
                for _, model in ipairs(SelectedStructures) do
                    if model and model.Parent then
                        local n = GetItemName(model)
                        structHave[n] = (structHave[n] or 0) + 1
                    end
                end
                local structMissing = {}
                for name, need in pairs(structNeeded) do
                    local have = structHave[name] or 0
                    if have < need then
                        table.insert(structMissing, name .. ": need " .. need .. ", selected " .. have)
                    end
                end
                if #structMissing > 0 then
                    Library:Notify("Blueprints", "Missing structures — " .. table.concat(structMissing, "; "), 7)
                    return
                end
            end

            -- Pre-flight: each furniture type needs at least one owned copy
            if hasFurniture then
                local furnMissing = {}
                local checked = {}
                for _, entry in ipairs(furniture) do
                    if not checked[entry.itemName] then
                        checked[entry.itemName] = true
                        if not FindSourceFurniture(entry.itemName) then
                            table.insert(furnMissing, entry.itemName)
                        end
                    end
                end
                if #furnMissing > 0 then
                    Library:Notify("Blueprints", "Missing furniture — not owned: " .. table.concat(furnMissing, ", "), 7)
                    return
                end
            end

            if not hasWires and not hasStructures and not hasFurniture then
                Library:Notify("Blueprints", "No valid entries found in " .. selectedFile, 4); return
            end

            if hasWires then
                if #SelectedWires == 0 then
                    Library:Notify("Blueprints", "File has wires but none selected! Select wires first.", 4); return
                end
                local assignments, ok2, missing = AssignWiresByType(wireTypes, SelectedWires)
                if not ok2 then
                    Library:Notify("Blueprints", FormatMissingReport(missing), 6); return
                end

                blueprintWires = {}
                local propertyOrig = useProperty and GetPropertyCenter()
                if useProperty and not propertyOrig then
                    Library:Notify("Blueprints", "Property-relative mode but no owned property!", 5); return
                end
                local ref
                if useProperty then
                    ref = nil
                else
                    -- Use wire-only centroid so preview centers on cursor correctly.
                    -- Structures use their stored relCF positions directly as xzOffset,
                    -- which are already relative to the same shared save origin.
                    local sum, count = Vector3.new(), 0
                    for _, stroke in ipairs(wires) do
                        for _, pt in ipairs(stroke) do
                            sum = sum + pt
                            count += 1
                        end
                    end
                    ref = count > 0 and (sum / count) or Vector3.new()
                end

                -- Find lowestY across all content so wires and structures share the same baseline
                local lowestY = math.huge
                for _, stroke in ipairs(wires) do
                    for _, pt in ipairs(stroke) do
                        if pt.Y < lowestY then lowestY = pt.Y end
                    end
                end
                for _, entry in ipairs(structures) do
                    if entry.cf.Position.Y < lowestY then lowestY = entry.cf.Position.Y end
                end
                for _, entry in ipairs(furniture) do
                    if entry.cf.Position.Y < lowestY then lowestY = entry.cf.Position.Y end
                end
                if lowestY == math.huge then lowestY = 0 end

                for _, stroke in ipairs(wires) do
                    local offsets = {}
                    for _, pt in ipairs(stroke) do
                        offsets[#offsets+1] = Vector3.new(
                            pt.X,
                            pt.Y - lowestY,
                            pt.Z
                        )
                    end
                    table.insert(blueprintWires, offsets)
                end
                blueprintTypes    = wireTypes
                placementWires    = assignments
                usePropertyOrigin = useProperty
                BlueprintMode     = true
                PlaceMode         = true
                PreviewActive     = true
                BlueprintBuild:SetText("Cancel")
            end

            if hasStructures or hasFurniture then
                pendingStructures   = structures
                pendingFurniture    = furniture
                pendingIsWorldSpace = useProperty
                BuildFilePlacementData(structures, furniture, useProperty, ref, lowestY)

                if not hasWires then
                    if useProperty then
                        -- Property mode: CFs are already world-space — fire immediately.
                        BlueprintBuild:SetText("Placing...")
                        BlueprintBuild:SetDisabled(true)
                        task.spawn(function()
                        local pm4 = workspace:FindFirstChild("PlayerModels")
                        local sb4 = {}
                        if pm4 then for _, m in ipairs(pm4:GetChildren()) do sb4[m] = true end end
                        local sTotal  = #moveStructures + #moveFurniture
                        local sPlaced = 0
                        local origin = Vector3.new()
                        if not useProperty then
                            local char = LocalPlayer.Character
                            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                            origin = hrp and hrp.Position or Vector3.new()
                        end
                        for _, entry in ipairs(moveStructures) do
                            local newCF
                            if useProperty then
                                newCF = entry.worldCF
                            else
                                local relCF = entry.relCF or entry.cf
                                local newPos = Vector3.new(
                                    origin.X + relCF.Position.X,
                                    origin.Y + entry.yAbove,
                                    origin.Z + relCF.Position.Z
                                )
                                newCF = CFrame.new(newPos) * relCF.Rotation
                            end
                            if entry.treeValue and entry.treeValue ~= "" then
                                local ok, _ = PlaceOneBlueprintFromFile(entry.itemName, newCF, entry.treeValue, sb4)
                                if ok then sPlaced += 1 end
                            else
                                local src = FindSourceStructure(entry.itemName)
                                if src then
                                    local ok
                                    if src:FindFirstChild("PurchasedBoxItemName") then
                                        ok = PlaceOneBoxedStructure(src, newCF, sb4)
                                    else
                                        ok = PlaceOneStructure(src, newCF, nil, false, sb4)
                                    end
                                    if ok then sPlaced += 1 end
                                end
                            end
                        end
                        for _, entry in ipairs(moveFurniture) do
                            local src = FindSourceFurniture(entry.itemName)
                            if src then
                                local newCF
                                if useProperty then
                                    newCF = entry.worldCF
                                else
                                    local relCF = entry.relCF or entry.cf
                                    local newPos = Vector3.new(
                                        origin.X + relCF.Position.X,
                                        origin.Y + entry.yAbove,
                                        origin.Z + relCF.Position.Z
                                    )
                                    newCF = CFrame.new(newPos) * relCF.Rotation
                                end
                                local ok = PlaceOneFurniture(src, newCF, false, sb4)
                                if ok then sPlaced += 1 end
                            end
                        end
                        Library:Notify("Blueprints",
                            ("Done! %d/%d placed."):format(sPlaced, sTotal), 5)
                        StopPlacing()
                    end)
                    else
                        -- Cursor mode: show preview and wait for click, same as wires.
                        BlueprintMode = false
                        MoveMode      = true
                        PlaceMode     = true
                        PreviewActive = true
                        BlueprintBuild:SetText("Cancel")
                        Library:Notify("Blueprints",
                            ("%d structures & %d furniture Loaded "):format(
                                #moveStructures, #moveFurniture), 5)
                    end
                    return
                end
            end

        else
            if #SelectedWires == 0 then
                Library:Notify("Blueprints", "No wires selected"); return
            end
            local parsed, types, skipped, useProperty = ParseBlueprint(clipText)
            if #parsed == 0 then
                Library:Notify("Blueprints", "No valid wires found"); return
            end
            if skipped > 0 then
                Library:Notify("Blueprints", skipped .. " Wires skipped due to invalid formating")
            end
            if useProperty then
                local center = GetPropertyCenter()
                if not center then
                    Library:Notify("Blueprints", "Property not found"); return
                end
            end
            local assignments, ok2, missing = AssignWiresByType(types, SelectedWires)
            if not ok2 then Library:Notify("Blueprints", FormatMissingReport(missing), 6); return end
            blueprintWires = {}
            if useProperty then
                for _, stroke in ipairs(parsed) do
                    local offsets = {}
                    for _, pt in ipairs(stroke) do table.insert(offsets, pt) end
                    table.insert(blueprintWires, offsets)
                end
            else
                -- Compute centroid of all wire points for centering on cursor
                local sum, count = Vector3.new(), 0
                for _, stroke in ipairs(parsed) do
                    for _, pt in ipairs(stroke) do
                        sum = sum + pt
                        count += 1
                    end
                end
            local ref = count > 0 and (sum / count) or parsed[1][1]

            -- Bottom-anchor Y so the cursor sits at the bottom-center, not the
            -- vertical center. XZ stays centroid-relative for horizontal centering.
            local lowestY = math.huge
            for _, stroke in ipairs(parsed) do
                for _, pt in ipairs(stroke) do
                    if pt.Y < lowestY then lowestY = pt.Y end
                end
            end
            if lowestY == math.huge then lowestY = ref.Y end

            for _, stroke in ipairs(parsed) do
                local offsets = {}
                for _, pt in ipairs(stroke) do
                    table.insert(offsets, Vector3.new(pt.X - ref.X, pt.Y - lowestY, pt.Z - ref.Z))
                end
                table.insert(blueprintWires, offsets)
            end
            end
            blueprintTypes    = types
            placementWires    = assignments
            usePropertyOrigin = useProperty
            BlueprintMode     = true
            PlaceMode         = true
            PreviewActive     = true
            BlueprintBuild:SetText(useProperty and "Cancel (Property)" or "Cancel")
            Library:Notify("Blueprints",
                "Loaded " .. #parsed .. " wires from " .. selectedFile .. " — " ..
                (useProperty and "property-anchored" or "click to place") .. "!", 4)
        end
    end)

    -- ================================================================
    --  OBJECT SELECTION SECTION
    -- ================================================================
    Tab:CreateSection("Object Selection")
    local BuildRow1 = Tab:CreateRow()
    BuildRow1:CreateToggle("Structures", true, function(val)
        selectStructures = val
    end)
    BuildRow1:CreateToggle("Blueprints", true, function(val)
        selectBlueprints = val
    end)

    local BuildRow2 = Tab:CreateRow()
    BuildRow2:CreateToggle("Furniture", true, function(val)
        selectFurniture = val
    end)
    BuildRow2:CreateToggle("Wires", true, function(val)
        selectWires = val
    end)

    -- ================================================================
    --  SETTINGS SECTION
    -- ================================================================
    Tab:CreateSection("Settings")
    local RotRow = Tab:CreateRow()
    RotRow:CreateKeybind("Rotate [X]", Enum.KeyCode.R, function() end)
    RotRow:CreateKeybind("Rotate [Y]", Enum.KeyCode.T, function() end)
    Tab:CreateToggle("Snap to Grid", true, function(val)
        snapToGrid = val
    end)
    Tab:CreateToggle("Keep Selection After Place", false, function(val)
        keepSelection = val
    end)
    Tab:CreateToggle("Save Relative to Property", false, function(val)
        exportToProperty = val
    end):AddTooltip("When on, saved coordinates are relative to your property center instead of the selection center.")
    Tab:CreateToggle("Group by Wood Type", false, function(val)
        groupByTreeValue = val
    end):AddTooltip(
        "Used with Group Selection.\n" ..
        "When on, clicking a structure only selects other structures\n" ..
        "with the same BlueprintWoodClass (same wood material)."
    )
    Tab:CreateToggle("Long Wire", false, function(state)
        SetWireLength(state and 50 or 20)
    end)

    plankRangeSlider = Tab:CreateRangeSlider("Plank Volume Range", 0, 10, plankFilterMin, plankFilterMax,
        function(low, high)
            plankFilterMin = low
            plankFilterMax = high
            if #allPlanks == 0 then return end
            ApplyPlankYFilter()
        end, 1)
    plankRangeSlider:AddTooltip("Filters planks by volume. \nThis feature is used for click/auto blueprint fill & Build Blueprint Files. \nDefualt Values are set to allow")

    -- Save Selection
    local SaveBtn = Tab:CreateAction("Save Selection", "Save", function()
        local totalSelected = #SelectedWires + #SelectedStructures + #SelectedFurniture
        if totalSelected == 0 then
            Library:Notify("Blueprints", "No items selected!"); return
        end
        local text, err = BuildBlueprintText(SelectedWires, SelectedStructures, SelectedFurniture, exportToProperty)
        if not text then
            Library:Notify("Blueprints", err or "Failed to build blueprint", 5); return
        end
        if not writefile then
            Library:Notify("Blueprints", "writefile not available in this environment", 5); return
        end
        local stamp    = os.date("%Y-%m-%d_%H-%M-%S")
        local filename = "blueprint_" .. stamp .. ".txt"
        local path     = BLUEPRINT_FOLDER .. "/" .. filename
        local ok, writeErr = pcall(writefile, path, text)
        if not ok then
            Library:Notify("Blueprints", "Save failed: " .. tostring(writeErr), 5); return
        end
        fileList = ScanBlueprintFiles()
        if #fileList == 0 then fileList = {"No files found"} end
        FileDropdown:SetOptions(fileList)
        selectedFile = filename
        local summary = {}
        if #SelectedStructures > 0 then table.insert(summary, #SelectedStructures .. " structures") end
        if #SelectedFurniture  > 0 then table.insert(summary, #SelectedFurniture  .. " furniture") end
        if #SelectedWires      > 0 then table.insert(summary, #SelectedWires      .. " wires") end
        Library:Notify("Blueprints",
            "Saved " .. filename .. " (" .. table.concat(summary, ", ") ..
            (exportToProperty and ", property-relative)" or ")"), 4)
    end)
    SaveBtn:AddTooltip("Exports selected wires, structures, and furniture to a timestamped .txt file in " .. BLUEPRINT_FOLDER .. "/")

    Tab:CreateAction("Delete Selection", "Delete", function()
        local total = #SelectedWires + #SelectedStructures + #SelectedFurniture + #SelectedBlueprints
        if total == 0 then Library:Notify("Blueprints", "No items selected!"); return end
        if not DestroyStructure then
            Library:Notify("Blueprints", "DestroyStructure remote not found.", 4); return
        end
        local toDestroy = {}
        for _, w in ipairs(SelectedWires) do if w and w.Parent then table.insert(toDestroy, w) end end
        for _, s in ipairs(SelectedStructures) do if s and s.Parent then table.insert(toDestroy, s) end end
        for _, f in ipairs(SelectedFurniture) do if f and f.Parent then table.insert(toDestroy, f) end end
        for _, b in ipairs(SelectedBlueprints) do if b and b.Parent then table.insert(toDestroy, b) end end
        Library:Notify("Blueprints", "Deleting " .. #toDestroy .. " item(s)...", math.max(2, math.ceil(#toDestroy * 0.1)))
        task.spawn(function()
            local destroyed = 0
            for _, item in ipairs(toDestroy) do
                if not item.Parent then continue end
                local timeout = 5; local elapsed = 0
                while item.Parent ~= nil and elapsed < timeout do
                    pcall(DestroyStructure.FireServer, DestroyStructure, item)
                    task.wait(0.05); elapsed += 0.05
                end
                if not item.Parent then destroyed += 1 end
            end
            Library:Notify("Blueprints", "Deleted " .. destroyed .. "/" .. #toDestroy .. " item(s).", 4)
            PruneDeadWires()
        end)
    end, true)

    function SetWireLength(length)
        for _, item in next, game:GetService("ReplicatedStorage").ClientItemInfo:GetChildren() do
            if item.Name:lower():find("wire") then
                local maxLength = item:FindFirstChild("OtherInfo") and item.OtherInfo:FindFirstChild("MaxLength")
                if maxLength then maxLength.Value = length end
            end
        end
    end
    -- ================================================================
    --  CLICK HANDLER
    -- ================================================================
    Mouse.Button1Down:Connect(function()
        if clickFillMode and not LassoMode and not PlaceMode and not Placing then
            local b = FindBlueprintModelFromPart(Mouse.Target)
            if b then
                if not LOT then
                    Library:Notify("Blueprints", "LOT not available — cannot fill.", 4); return
                end
                if not selectedPlankType then
                    Library:Notify("Blueprints", "No plank type selected.", 4); return
                end
                local cls = (selectedPlankType == "(none)") and "" or selectedPlankType
                local bp  = b
                task.spawn(function()
                    -- Rescan if the toggle's scan didn't populate (or planks were consumed).
                    if #filteredPlanks == 0 then
                        allPlanks = ScanAllOwnedPlanks()
                        ApplyPlankYFilter()
                    end
                    -- GetNextPlankForClass skips dead/consumed planks automatically.
                    local entry = GetNextPlankForClass(cls)
                    if not entry then
                        Library:Notify("Blueprints", "No matching plank in Y range.", 4); return
                    end
                    FillBlueprintWithPlank(bp, entry)
                end)
            end
            return
        end

        if GroupSelectMode and not LassoMode and not PlaceMode and not Placing then
            local target = Mouse.Target
            local matched = false

            local wire = FindWireModelFromPart(target)
            if wire then
                matched = true
                local pm = workspace:FindFirstChild("PlayerModels")
                if pm then
                    local alreadySelected = table.find(SelectedWires, wire) ~= nil
                    if alreadySelected then
                        local newSel = {}
                        for _, model in ipairs(SelectedWires) do
                            local typeVal = model:FindFirstChild("Type")
                            if not (typeVal and typeVal.Value == "Wire") then
                                table.insert(newSel, model)
                            end
                        end
                        SelectedWires = newSel
                        Library:Notify("Blueprints", "Group deselected wires.")
                    else
                        -- Match same wire type name AND same kind (boxed vs placed).
                        local wireTypeName = GetWireTypeName(wire)
                        local wireIsBoxed  = wire:FindFirstChild("PurchasedBoxItemName") ~= nil
                        for _, model in ipairs(pm:GetChildren()) do
                            local typeVal = model:FindFirstChild("Type")
                            if typeVal and typeVal.Value == "Wire" then
                                local modelIsBoxed = model:FindFirstChild("PurchasedBoxItemName") ~= nil
                                local nameMatch    = GetWireTypeName(model) == wireTypeName
                                if nameMatch and modelIsBoxed == wireIsBoxed then
                                    if not table.find(SelectedWires, model) then
                                        table.insert(SelectedWires, model)
                                    end
                                end
                            end
                        end
                        local kindLabel = wireIsBoxed and " (boxed)" or ""
                        Library:Notify("Blueprints", "Group selected " .. #SelectedWires .. " wire(s)" .. kindLabel .. ".")
                    end
                    UpdateSelectionVisuals()
                end
            end

            if not matched and selectStructures then
                local s = FindStructureModelFromPart(target)
                if s then
                    matched = true
                    local matchTree = groupByTreeValue and GetStructureTreeValue(s) or nil
                    local pm = workspace:FindFirstChild("PlayerModels")
                    if pm then
                        local alreadySelected = table.find(SelectedStructures, s) ~= nil
                        if alreadySelected then
                            if matchTree == nil then
                                SelectedStructures = {}
                            else
                                local kept = {}
                                for _, model in ipairs(SelectedStructures) do
                                    if GetStructureTreeValue(model) ~= matchTree then
                                        table.insert(kept, model)
                                    end
                                end
                                SelectedStructures = kept
                            end
                            local label = matchTree and (" (" .. matchTree .. ")") or ""
                            Library:Notify("Blueprints", "Group deselected structure(s)" .. label .. ".")
                        else
                            -- Group by item name + same kind (boxed vs placed) + wood type when enabled.
                            local matchName   = GetItemName(s)
                            local matchBoxed  = s:FindFirstChild("PurchasedBoxItemName") ~= nil
                            for _, model in ipairs(pm:GetChildren()) do
                                local typeVal = model:FindFirstChild("Type")
                                if typeVal and (typeVal.Value == "Structure" or typeVal.Value == "Vehicle Spot") then
                                    local modelIsBoxed = model:FindFirstChild("PurchasedBoxItemName") ~= nil
                                    local nameMatch    = GetItemName(model) == matchName
                                    local kindMatch    = modelIsBoxed == matchBoxed
                                    local treeMatch    = matchTree == nil or GetStructureTreeValue(model) == matchTree
                                    if nameMatch and kindMatch and treeMatch then
                                        if not table.find(SelectedStructures, model) then
                                            table.insert(SelectedStructures, model)
                                        end
                                    end
                                end
                            end
                            local kindLabel = matchBoxed and " (boxed)" or ""
                            local label = matchTree and (" (" .. matchTree .. ")") or ""
                            Library:Notify("Blueprints", "Group selected " .. #SelectedStructures .. " " .. matchName .. "(s)" .. kindLabel .. label .. ".")
                        end
                        UpdateSelectionVisuals()
                    end
                end
            end

            if not matched and selectBlueprints then
                local b = FindBlueprintModelFromPart(target)
                if b then
                    matched = true
                    local pm = workspace:FindFirstChild("PlayerModels")
                    if pm then
                        local alreadySelected = table.find(SelectedBlueprints, b) ~= nil
                        if alreadySelected then
                            SelectedBlueprints = {}
                            Library:Notify("Blueprints", "Group deselected blueprints.")
                        else
                            local matchName = GetItemName(b)
                            for _, model in ipairs(pm:GetChildren()) do
                                local typeVal = model:FindFirstChild("Type")
                                if typeVal and typeVal.Value == "Blueprint"
                                and not model:FindFirstChild("PurchasedBoxItemName") then
                                    if GetItemName(model) == matchName then
                                        if not table.find(SelectedBlueprints, model) then
                                            table.insert(SelectedBlueprints, model)
                                        end
                                    end
                                end
                            end
                            Library:Notify("Blueprints", "Group selected " .. #SelectedBlueprints .. " " .. matchName .. " blueprint(s).")
                        end
                        UpdateSelectionVisuals()
                    end
                end
            end

            return
        end

        if ClickSelectMode and not LassoMode and not PlaceMode and not Placing then
            local target = Mouse.Target
            local wire = FindWireModelFromPart(target)
            if wire then
                local idx = table.find(SelectedWires, wire)
                if idx then table.remove(SelectedWires, idx) else table.insert(SelectedWires, wire) end
                UpdateSelectionVisuals(); return
            end
            if selectStructures then
                local s = FindStructureModelFromPart(target)
                if s then
                    local idx = table.find(SelectedStructures, s)
                    if idx then table.remove(SelectedStructures, idx) else table.insert(SelectedStructures, s) end
                    UpdateSelectionVisuals(); return
                end
            end
            if selectFurniture then
                local f = FindFurnitureModelFromPart(target)
                if f then
                    local idx = table.find(SelectedFurniture, f)
                    if idx then table.remove(SelectedFurniture, idx) else table.insert(SelectedFurniture, f) end
                    UpdateSelectionVisuals(); return
                end
            end
            if selectBlueprints then
                local b = FindBlueprintModelFromPart(target)
                if b then
                    local idx = table.find(SelectedBlueprints, b)
                    if idx then table.remove(SelectedBlueprints, idx) else table.insert(SelectedBlueprints, b) end
                    UpdateSelectionVisuals(); return
                end
            end
            return
        end

        if not PlaceMode or Placing then return end

        Placing       = true
        PlaceMode     = false
        PreviewActive = false
        ClearPreview()
        for _, clone in ipairs(movePreviewModels) do
            pcall(function() clone:Destroy() end)
        end
        movePreviewModels = {}

        local origin
        if BlueprintMode and usePropertyOrigin then
            origin = GetPropertyCenter()
            if not origin then
                Library:Notify("Blueprints", "Property no longer available — placement cancelled.", 5)
                StopPlacing(); return
            end
        else
            origin = SnapToGrid(GetCursorWorldPos())
        end
        local capturedRot = WireRotation
        local wires       = placementWires

        -- ── Move mode with no wires (Move Selection — no plank fill) ─────────
        -- FIX: ComputeNewPos no longer stacks Y based on bounding-box collisions.
        --      It now exactly matches the preview's RepositionClone logic so items
        --      land exactly where the ghost clone was shown.
        if MoveMode and not BlueprintMode then
            MoveElement:SetText("Placing...")
            MoveElement:SetDisabled(true)
            for _, box in ipairs(SelectionBoxes) do box:Destroy() end
            SelectionBoxes = {}
            task.spawn(function()
                local sPlaced, sTotal = 0, #moveStructures + #moveFurniture + #moveBlueprints
                local pm = workspace:FindFirstChild("PlayerModels")
                local sharedBefore = {}
                if pm then for _, m in ipairs(pm:GetChildren()) do sharedBefore[m] = true end end

                -- Matches RepositionClone exactly: flat XZ rotation + yAbove, no stacking.
                local function ComputeNewPos(entry)
                    local rotatedXZ = WireRotation:VectorToWorldSpace(entry.xzOffset)
                    return Vector3.new(
                        origin.X + rotatedXZ.X,
                        origin.Y + entry.yAbove,
                        origin.Z + rotatedXZ.Z
                    )
                end

                for _, entry in ipairs(moveStructures) do
                    local newPos = ComputeNewPos(entry)
                    local newCF  = CFrame.new(newPos) * WireRotation.Rotation * entry.cf.Rotation
                    if entry.isFileBuild then
                        local src = FindSourceStructure(entry.itemName)
                        if src then
                            local ok
                            if src:FindFirstChild("PurchasedBoxItemName") then
                                ok = PlaceOneBoxedStructure(src, newCF)
                            else
                                ok = PlaceOneStructure(src, newCF, entry.treeValue, true, sharedBefore)
                            end
                            if ok then sPlaced += 1 end
                        elseif entry.treeValue and entry.treeValue ~= "" then
                            local ok, _ = PlaceOneBlueprintFromFile(entry.itemName, newCF, entry.treeValue, sharedBefore)
                            if ok then sPlaced += 1 end
                        end
                    elseif entry.model and entry.model.Parent then
                        local ok = PlaceOneStructure(entry.model, newCF, entry.treeValue, true, sharedBefore)
                        if ok then sPlaced += 1 end
                    end
                end
                for _, entry in ipairs(moveFurniture) do
                    if entry.model and entry.model.Parent then
                        local newPos = ComputeNewPos(entry)
                        local newCF  = CFrame.new(newPos) * WireRotation.Rotation * entry.cf.Rotation
                        local ok = PlaceOneFurniture(entry.model, newCF, true, sharedBefore)
                        if ok then sPlaced += 1 end
                    end
                end
                for _, entry in ipairs(moveBlueprints) do
                    if entry.model and entry.model.Parent then
                        local newPos = ComputeNewPos(entry)
                        local newCF  = entry.cf - entry.cf.Position + newPos
                        -- Move Selection: PlaceOneBlueprint — no plank fill
                        local ok = PlaceOneBlueprint(entry.model, newCF, true, sharedBefore)
                        if ok then sPlaced += 1 end
                    end
                end
                Library:Notify("Blueprints", ("Moved %d/%d item(s)."):format(sPlaced, sTotal), 4)
                StopPlacing()
            end)
            return
        end

        if BlueprintMode then
            local blueprint   = blueprintWires
            local boundsRects = GetPropertySquares()
            BlueprintBuild:SetText("Placing...")
            BlueprintBuild:SetDisabled(true)

            task.spawn(function()
                local placed, outOfBounds = 0, 0
                for i, offsetStroke in ipairs(blueprint) do
                    local wireObj = wires[i]
                    if not wireObj or not wireObj.Parent then
                        Library:Notify("Blueprints", "Ran out of wires at wire " .. i .. "!")
                        StopPlacing(); return
                    end
                    local requiredType = blueprintTypes[i]
                    if requiredType and requiredType ~= "" then
                        local actualType = GetWireTypeName(wireObj)
                        if actualType ~= requiredType then
                            Library:Notify("Blueprints",
                                "Type mismatch at wire " .. i .. " — expected \'" .. requiredType .. "\', got \'" .. tostring(actualType) .. "\'", 5)
                            StopPlacing(); return
                        end
                    end
                    local maxDist = GetWireMaxLength(wireObj)
                    local worldStroke = {}
                    for _, offset in ipairs(offsetStroke) do
                        table.insert(worldStroke, origin + capturedRot:VectorToWorldSpace(offset))
                    end
                    if StrokeExceedsMax(worldStroke, maxDist) then
                        Library:Notify("Blueprints",
                            "Cancelled — wire " .. i .. " exceeds max length (" .. maxDist .. " studs).", 4)
                        StopPlacing(); return
                    end
                    if boundsRects and not StrokeInsideProperty(worldStroke, boundsRects) then
                        outOfBounds = outOfBounds + 1
                    else
                        local Info = GetWireInfo(wireObj)
                        if Info then FireWire(wireObj, worldStroke, Info); placed = placed + 1 end
                    end
                end
                local msg = "Blueprint placed! (" .. placed .. "/" .. #blueprint .. " wires)"
                if outOfBounds > 0 then msg = msg .. " — " .. outOfBounds .. " skipped (outside property)" end
                Library:Notify("Blueprints", msg, 4)

                -- Place any pending structures from a combined file as BLUEPRINTS + fill
                if not MoveMode and (#moveStructures > 0 or #moveFurniture > 0) then
                    local pm3 = workspace:FindFirstChild("PlayerModels")
                    local sb3 = {}
                    if pm3 then for _, m in ipairs(pm3:GetChildren()) do sb3[m] = true end end
                    local sTotal = #moveStructures + #moveFurniture
                    local sPlaced = 0

                    for _, entry in ipairs(moveStructures) do
                        local newCF
                        if entry.isPropertyMode then
                            newCF = entry.worldCF
                        else
                            local rotatedXZ = capturedRot:VectorToWorldSpace(entry.xzOffset)
                            local newPos = Vector3.new(
                                origin.X + rotatedXZ.X,
                                origin.Y + entry.yAbove,
                                origin.Z + rotatedXZ.Z
                            )
                            newCF = CFrame.new(newPos) * capturedRot.Rotation * entry.cf.Rotation
                        end
                        -- Wood blueprints (treeValue set) → ClientPlacedBlueprint + auto plank fill.
                        -- Non-wood structures (Glass, etc.) → ClientPlacedStructure directly.
                        if entry.treeValue and entry.treeValue ~= "" then
                            local ok, _ = PlaceOneBlueprintFromFile(entry.itemName, newCF, entry.treeValue, sb3)
                            if ok then sPlaced += 1 end
                        else
                            local src = FindSourceStructure(entry.itemName)
                            if src then
                                local ok
                                if src:FindFirstChild("PurchasedBoxItemName") then
                                    ok = PlaceOneBoxedStructure(src, newCF, sb3)
                                else
                                    ok = PlaceOneStructure(src, newCF, nil, false, sb3)
                                end
                                if ok then sPlaced += 1 end
                            end
                        end
                    end
                    for _, entry in ipairs(moveFurniture) do
                        local src = FindSourceFurniture(entry.itemName)
                        if src then
                            local newCF
                            if entry.isPropertyMode then
                                newCF = entry.worldCF
                            else
                            local rotatedXZ = capturedRot:VectorToWorldSpace(entry.xzOffset)
                            local newPos = Vector3.new(
                                origin.X + rotatedXZ.X,
                                origin.Y + entry.yAbove,
                                origin.Z + rotatedXZ.Z
                            )
                            newCF = CFrame.new(newPos) * capturedRot.Rotation * entry.cf.Rotation
                            end
                            local ok = PlaceOneFurniture(src, newCF, false, sb3)
                            if ok then sPlaced += 1 end
                        end
                    end
                    if sTotal > 0 then
                        Library:Notify("Blueprints", ("Placed %d/%d structure blueprint(s)/furniture."):format(sPlaced, sTotal), 4)
                    end
                end

                -- Move mode also has structures/furniture (wires + selected together)
                -- FIX: Added WireRotation.Rotation to struct/furniture CFrame so rotation
                --      matches the preview clone's RepositionClone logic.
                if MoveMode and (#moveStructures > 0 or #moveFurniture > 0 or #moveBlueprints > 0) then
                    local sPlaced, sTotal = 0, #moveStructures + #moveFurniture + #moveBlueprints
                    local pm2 = workspace:FindFirstChild("PlayerModels")
                    local sharedBefore = {}
                    if pm2 then for _, m in ipairs(pm2:GetChildren()) do sharedBefore[m] = true end end
                    for _, entry in ipairs(moveStructures) do
                        if entry.model and entry.model.Parent then
                            local rotatedXZ = WireRotation:VectorToWorldSpace(entry.xzOffset)
                            local newPos    = Vector3.new(
                                origin.X + rotatedXZ.X,
                                origin.Y + entry.yAbove,
                                origin.Z + rotatedXZ.Z
                            )
                            local newCF = CFrame.new(newPos) * WireRotation.Rotation * entry.cf.Rotation
                            local ok = PlaceOneStructure(entry.model, newCF, entry.treeValue, true, sharedBefore)
                            if ok then sPlaced += 1 end
                        end
                    end
                    for _, entry in ipairs(moveFurniture) do
                        if entry.model and entry.model.Parent then
                            local rotatedXZ = WireRotation:VectorToWorldSpace(entry.xzOffset)
                            local newPos    = Vector3.new(
                                origin.X + rotatedXZ.X,
                                origin.Y + entry.yAbove,
                                origin.Z + rotatedXZ.Z
                            )
                            local newCF = CFrame.new(newPos) * WireRotation.Rotation * entry.cf.Rotation
                            local ok = PlaceOneFurniture(entry.model, newCF, true, sharedBefore)
                            if ok then sPlaced += 1 end
                        end
                    end
                    for _, entry in ipairs(moveBlueprints) do
                        if entry.model and entry.model.Parent then
                            local rotatedXZ = WireRotation:VectorToWorldSpace(entry.xzOffset)
                            local newPos    = Vector3.new(
                                origin.X + rotatedXZ.X,
                                origin.Y + entry.yAbove,
                                origin.Z + rotatedXZ.Z
                            )
                            local newCF = entry.cf - entry.cf.Position + newPos
                            -- Move Selection: no plank fill
                            local ok = PlaceOneBlueprint(entry.model, newCF, true, sharedBefore)
                            if ok then sPlaced += 1 end
                        end
                    end
                    if sTotal > 0 then
                        Library:Notify("Blueprints", ("Moved %d/%d item(s)."):format(sPlaced, sTotal), 3)
                    end
                end

                StopPlacing()
            end)

        else
            if ActionElement then ActionElement:SetText("Placing..."); ActionElement:SetDisabled(true) end
            local word        = currentWord:upper():gsub("[^A-Z0-9 %-_=+%[%]\\|;:\'\",./<>?!#%^]", "")
            local boundsRects = GetPropertySquares()

            task.spawn(function()
                local wireIndex, posIndex = 1, 0
                local ranOut = false
                local placed, outOfBounds = 0, 0

                for i = 1, #word do
                    if ranOut then break end
                    local ch = word:sub(i, i)
                    if ch ~= " " then
                        local letterOrigin = origin + capturedRot:VectorToWorldSpace(
                            Vector3.new(posIndex * Settings.Spacing, 0, 0)
                        )
                        local rawStrokes = GetLetterPoints(ch, letterOrigin)
                        if rawStrokes then
                            local rotated = RotateStrokes(rawStrokes, letterOrigin)
                            for _, stroke in ipairs(rotated) do
                                local wireObj = wires[wireIndex]
                                if not wireObj or not wireObj.Parent then
                                    Library:Notify("Blueprints", "Ran out of wires at letter \'" .. ch .. "\'!")
                                    ranOut = true; break
                                end
                                local maxDist = GetWireMaxLength(wireObj)
                                if StrokeExceedsMax(stroke, maxDist) then
                                    Library:Notify("Blueprints",
                                        "Cancelled — stroke for \'" .. ch .. "\' exceeds max length (" .. maxDist .. " studs).", 4)
                                    StopPlacing(); return
                                end
                                if boundsRects and not StrokeInsideProperty(stroke, boundsRects) then
                                    outOfBounds = outOfBounds + 1
                                else
                                    local Info = GetWireInfo(wireObj)
                                    if Info then FireWire(wireObj, stroke, Info); placed = placed + 1 end
                                    wireIndex = wireIndex + 1
                                end
                            end
                        end
                    end
                    posIndex = posIndex + 1
                end

                local msg = "Placed \'" .. word .. "\'! (" .. placed .. " wires)"
                if outOfBounds > 0 then msg = msg .. " — " .. outOfBounds .. " skipped (outside property)" end
                Library:Notify("Blueprints", msg, 4)
                StopPlacing()
            end)
        end
    end)

    -- ================================================================
    --  RENDER LOOP
    -- ================================================================
    local previewWasActive = false
    RunService.RenderStepped:Connect(function()
        if PreviewActive and PlaceMode and not Placing then
            BeginPreview()
            local origin
            if BlueprintMode and usePropertyOrigin then
                origin = GetPropertyCenter() or GetCursorWorldPos()
            else
                origin = GetCursorWorldPos()
            end

            local snappedOrigin = SnapToGrid(origin)

            if #moveStructures > 0 or #moveFurniture > 0 or #moveBlueprints > 0 then
                local function RepositionClone(entry)
                    if not entry.previewClone then return end
                    if not entry.previewClone.Parent then return end
                    if entry.isPropertyMode then return end
                    local rotatedXZ = WireRotation:VectorToWorldSpace(entry.xzOffset)
                    local newPos    = Vector3.new(
                        snappedOrigin.X + rotatedXZ.X,
                        snappedOrigin.Y + entry.yAbove,
                        snappedOrigin.Z + rotatedXZ.Z
                    )
                    local newCF
                    if entry.isBlueprint then
                        local baseCF = entry.relCF or entry.cf
                        newCF = baseCF - baseCF.Position + newPos
                    else
                        local rotSource = entry.relCF or entry.cf
                        newCF = CFrame.new(newPos) * WireRotation.Rotation * rotSource.Rotation
                    end
                    pcall(function()
                        if entry.previewClone.PrimaryPart then
                            entry.previewClone:SetPrimaryPartCFrame(newCF)
                        else
                            entry.previewClone:PivotTo(newCF)
                        end
                    end)
                end

                for _, entry in ipairs(moveStructures) do RepositionClone(entry) end
                for _, entry in ipairs(moveFurniture)  do RepositionClone(entry) end
                for _, entry in ipairs(moveBlueprints) do RepositionClone(entry) end

                if BlueprintMode then
                    UpdateBlueprintPreview(snappedOrigin)
                end
            elseif BlueprintMode then
                UpdateBlueprintPreview(snappedOrigin)
            else
                UpdatePreview(snappedOrigin, currentWord:upper())
            end

            EndPreview()
            previewWasActive = true
        elseif not Placing then
            if previewWasActive then ClearPreview(); previewWasActive = false end
        end
    end)

    -- ================================================================
    --  KEYBINDS
    -- ================================================================
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if PlaceMode then
            if input.KeyCode == Enum.KeyCode.R then
                WireRotation = WireRotation * CFrame.Angles(0, math.rad(90), 0)
            elseif input.KeyCode == Enum.KeyCode.T then
                WireRotation = WireRotation * CFrame.Angles(math.rad(90), 0, 0)
            end
        end
        if LassoMode and not PlaceMode and not Placing
        and input.UserInputType == Enum.UserInputType.MouseButton1 then
            LassoDragging = true
            LassoStartPos = UserInputService:GetMouseLocation()
            if LassoFrame then LassoFrame.Size = UDim2.fromOffset(0, 0); LassoFrame.Visible = false end
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if LassoDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            UpdateLassoFrame(UserInputService:GetMouseLocation())
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if LassoDragging and input.UserInputType == Enum.UserInputType.MouseButton1 then
            LassoDragging = false
            if LassoFrame then LassoFrame.Visible = false end
            SelectWiresInLassoRect(LassoStartPos, UserInputService:GetMouseLocation())
            LassoStartPos = nil
        end
    end)

    LocalPlayer.CharacterAdded:Connect(function(char)
        Character = char
        StopPlacing()
    end)
end

return Blueprints]], "WireArt"))() end
__modules["LT2ItemList"] = function() return assert(loadstring([=[-- [[ LT2 ITEM LIST ]]
-- Stores ONLY the static data that can't be read from ReplicatedStorage:
--   BoxItemName  — matches the folder name under ClientItemInfo
--   Store        — which store sells this item (drives NPC + counter lookup)
--
-- Name, Image (asset URL), and Price are read at runtime from:
--   game:GetService("ReplicatedStorage").ClientItemInfo.<BoxItemName>
--     ├─ ItemName   (StringValue)
--     ├─ ItemImage  (StringValue)   e.g. "http://www.roblox.com/Game/Tools/ThumbnailAsset.ashx?..."
--     └─ Price      (IntValue / NumberValue)

return {
    -- ── Axes ────────────────────────────────────────────────────────────
    { BoxItemName = "BasicHatchet",  Store = "WoodRUs" },
    { BoxItemName = "Axe1",          Store = "WoodRUs" },
    { BoxItemName = "Axe2",          Store = "WoodRUs" },
    { BoxItemName = "Axe3",          Store = "WoodRUs" },
    { BoxItemName = "SilverAxe",     Store = "WoodRUs" },

    -- ── Conveyors ───────────────────────────────────────────────────────
    { BoxItemName = "StraightConveyor",           Store = "WoodRUs" },
    { BoxItemName = "TightTurnConveyor",           Store = "WoodRUs" },
    { BoxItemName = "TiltConveyor",               Store = "WoodRUs" },
    { BoxItemName = "ConveyorFunnel",             Store = "WoodRUs" },
    { BoxItemName = "ConveyorSwitch",             Store = "WoodRUs" },
    { BoxItemName = "StraightSwitchConveyorLeft", Store = "WoodRUs" },
    { BoxItemName = "StraightSwitchConveyorRight",Store = "WoodRUs" },
    { BoxItemName = "LogSweeper",                 Store = "WoodRUs" },
    { BoxItemName = "ConveyorSupports",           Store = "WoodRUs" },
    { BoxItemName = "TightTurnConveyorSupports",  Store = "WoodRUs" },

    -- ── Sawmills ────────────────────────────────────────────────────────
    { BoxItemName = "Sawmill",   Store = "WoodRUs" },
    { BoxItemName = "Sawmill2",  Store = "WoodRUs" },
    { BoxItemName = "Sawmill3",  Store = "WoodRUs" },
    { BoxItemName = "Sawmill4",  Store = "WoodRUs" },
    { BoxItemName = "Sawmill4L", Store = "WoodRUs" },
    { BoxItemName = "ChopSaw",   Store = "WoodRUs" },

    -- ── Logic / Wires ───────────────────────────────────────────────────
    { BoxItemName = "Wire",                   Store = "WoodRUs"       },
    { BoxItemName = "IcicleWireMaple",        Store = "FurnitureStore" },
    { BoxItemName = "IcicleWireCandy",        Store = "FurnitureStore" },
    { BoxItemName = "IcicleWireHalloween",    Store = "FurnitureStore" },
    { BoxItemName = "IcicleWireHalloweenGreen", Store = "FurnitureStore" },
    { BoxItemName = "IcicleWireAmber",        Store = "FurnitureStore" },
    { BoxItemName = "IcicleWireBlue",         Store = "FurnitureStore" },
    { BoxItemName = "IcicleWireGreen",        Store = "FurnitureStore" },
    { BoxItemName = "IcicleWireRed",          Store = "FurnitureStore" },
    { BoxItemName = "NeonWireWhite",          Store = "LogicStore"    },
    { BoxItemName = "NeonWireRed",            Store = "LogicStore"    },
    { BoxItemName = "NeonWireOrange",         Store = "LogicStore"    },
    { BoxItemName = "NeonWireYellow",         Store = "LogicStore"    },
    { BoxItemName = "NeonWireGreen",          Store = "LogicStore"    },
    { BoxItemName = "NeonWireCyan",           Store = "LogicStore"    },
    { BoxItemName = "NeonWireBlue",           Store = "LogicStore"    },
    { BoxItemName = "NeonWireViolet",         Store = "LogicStore"    },
    { BoxItemName = "Button0",        Store = "WoodRUs"    },
    { BoxItemName = "Lever0",         Store = "WoodRUs"    },
    { BoxItemName = "PressurePlate",  Store = "WoodRUs"    },
    { BoxItemName = "GateNOT",        Store = "LogicStore" },
    { BoxItemName = "SignalSustain",  Store = "LogicStore" },
    { BoxItemName = "SignalDelay",    Store = "LogicStore" },
    { BoxItemName = "GateAND",        Store = "LogicStore" },
    { BoxItemName = "GateOR",         Store = "LogicStore" },
    { BoxItemName = "GateXOR",        Store = "LogicStore" },
    { BoxItemName = "ClockSwitch",    Store = "LogicStore" },
    { BoxItemName = "WoodChecker",    Store = "LogicStore" },
    { BoxItemName = "Laser",          Store = "LogicStore" },
    { BoxItemName = "LaserReceiver",  Store = "LogicStore" },
    { BoxItemName = "Hatch",          Store = "LogicStore" },

    -- ── Vehicles ────────────────────────────────────────────────────────
    { BoxItemName = "UtilityTruck",  Store = "WoodRUs"  },
    { BoxItemName = "UtilityTruck2", Store = "CarStore"  },
    { BoxItemName = "Pickup1",       Store = "CarStore"  },
    { BoxItemName = "SmallTrailer",  Store = "CarStore"  },
    { BoxItemName = "Trailer2",      Store = "CarStore"  },

    -- ── Furniture ───────────────────────────────────────────────────────
    { BoxItemName = "Seat_Armchair",    Store = "FurnitureStore" },
    { BoxItemName = "Seat_Loveseat",    Store = "FurnitureStore" },
    { BoxItemName = "Bed1",             Store = "FurnitureStore" },
    { BoxItemName = "FloorLamp1",       Store = "FurnitureStore" },
    { BoxItemName = "Lamp1",            Store = "FurnitureStore" },
    { BoxItemName = "WallLight1",       Store = "FurnitureStore" },
    { BoxItemName = "WallLight2",       Store = "FurnitureStore" },
    { BoxItemName = "Refridgerator",    Store = "FurnitureStore" },
    { BoxItemName = "Stove",            Store = "FurnitureStore" },
    { BoxItemName = "Dishwasher",       Store = "FurnitureStore" },
    { BoxItemName = "Toilet",           Store = "FurnitureStore" },
    { BoxItemName = "FireworkLauncher", Store = "FurnitureStore" },
    { BoxItemName = "GlassDoor1",       Store = "FurnitureStore" },
    { BoxItemName = "GlassPane4",       Store = "FurnitureStore" },
    { BoxItemName = "GlassPane3",       Store = "FurnitureStore" },
    { BoxItemName = "GlassPane2",       Store = "FurnitureStore" },
    { BoxItemName = "GlassPane1",       Store = "FurnitureStore" },

    -- ── Paintings ───────────────────────────────────────────────────────
    { BoxItemName = "Painting3", Store = "FineArt" },
    { BoxItemName = "Painting2", Store = "FineArt" },
    { BoxItemName = "Painting1", Store = "FineArt" },
    { BoxItemName = "Painting7", Store = "FineArt" },
    { BoxItemName = "Painting6", Store = "FineArt" },
    { BoxItemName = "Painting9", Store = "FineArt" },
    { BoxItemName = "Painting8", Store = "FineArt" },

    -- ── Other ────────────────────────────────────────────────────────────
    { BoxItemName = "BagOfSand",   Store = "WoodRUs"    },
    { BoxItemName = "CanOfWorms",  Store = "ShackShop"  },
    { BoxItemName = "LightBulb",   Store = "FurnitureStore" },
    { BoxItemName = "Dynamite",    Store = "ShackShop"  },
    { BoxItemName = "WorkLight",   Store = "WoodRUs"    },

    -- ── Blueprints ───────────────────────────────────────────────────────
    -- Smooth walls
    { BoxItemName = "Wall2Tall",         Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wall2",             Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wall2Short",        Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wall2TallThin",     Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wall2Thin",         Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wall2ShortThin",    Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wall2TallCorner",   Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wall2Corner",       Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wall2ShortCorner",  Store = "WoodRUs", IsBlueprint = true },
    -- Corrugated walls
    { BoxItemName = "Wall1Tall",         Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wall1",             Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wall1Short",        Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wall1TallThin",     Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wall1Thin",         Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wall1ShortThin",    Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wall1TallCorner",   Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wall1Corner",       Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wall1ShortCorner",  Store = "WoodRUs", IsBlueprint = true },
    -- Fence
    { BoxItemName = "Wall3Tall",         Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wall3",             Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wall3TallThin",     Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wall3Thin",         Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wall3TallCorner",   Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wall3Corner",       Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Floor1Large",  Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Floor1",       Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Floor1Small",  Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Floor1Tiny",   Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Floor2Large",  Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Floor2",       Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Floor2Small",  Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Floor2Tiny",   Store = "WoodRUs", IsBlueprint = true },
    -- Wedges
    { BoxItemName = "Wedge1",       Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wedge1_Thin",  Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wedge2",       Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wedge2_Thin",  Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wedge3",       Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wedge3_Thin",  Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wedge4",       Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wedge4_Thin",  Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wedge5",       Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wedge5_Thin",  Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wedge6",       Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wedge6_Thin",  Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wedge7",       Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wedge7_Thin",  Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wedge8",       Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wedge8_Thin",  Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wedge9",       Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wedge9_Thin",  Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wedge10",      Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wedge10_Thin", Store = "WoodRUs", IsBlueprint = true },
    -- Stairs / misc structures
    { BoxItemName = "Stair1",  Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Stair2",  Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Ladder1", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Post",    Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Door1",   Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Door2",   Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Door3",   Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Table1",  Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Table2",  Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Chair1",  Store = "WoodRUs", IsBlueprint = true },
    -- Kitchen / cabinets
    { BoxItemName = "Cabinet1CornerWide",  Store = "FurnitureStore", IsBlueprint = true },
    { BoxItemName = "Cabinet1",            Store = "FurnitureStore", IsBlueprint = true },
    { BoxItemName = "Cabinet1Thin",        Store = "FurnitureStore", IsBlueprint = true },
    { BoxItemName = "Cabinet1CornerTight", Store = "FurnitureStore", IsBlueprint = true },
    { BoxItemName = "CounterTop1",         Store = "FurnitureStore", IsBlueprint = true },
    { BoxItemName = "CounterTop1Thin",     Store = "FurnitureStore", IsBlueprint = true },
    { BoxItemName = "CounterTop1Sink",     Store = "FurnitureStore", IsBlueprint = true },
}]=], "LT2ItemList"))() end
__modules["Theme"] = function() return assert(loadstring([[local Theme = {
    MainBG      = Color3.fromRGB(20, 20, 30),
    RowBG       = Color3.fromRGB(30, 30, 45),
    SidebarBG   = Color3.fromRGB(13, 13, 20),
    AccentBlue  = Color3.fromRGB(30, 120, 255),
    FilledBtn   = Color3.fromRGB(20, 90, 210),
    Text        = Color3.fromRGB(255, 255, 255),
    SubText     = Color3.fromRGB(180, 180, 195),
    Border      = Color3.fromRGB(40, 40, 60),
    DropShadow  = Color3.fromRGB(8, 8, 14),
}

local Scale = {
    UIScale = .9,
}

local Fonts = {
    Body   = Enum.Font.GothamMedium,
    Bold   = Enum.Font.GothamBold,
    Button = Enum.Font.GothamBold,
}

local TextSizes = {
    Offset     =  0,
    SectionMin = 13,
    BodyMin    = 12,
    ButtonMin  = 12,
}

local Player    = game:GetService("Players").LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local DynxeTheme = {}

local enabled          = true
local watching         = {}
local propertyConns    = {}
local originals        = {}
local originalScales   = {}

local TRACKED_PROPS = {
    "BackgroundColor3", "BackgroundTransparency", "BorderSizePixel",
    "TextColor3", "Font", "TextSize",
}

local function SaveOriginals(obj)
    if originals[obj] then return end
    local saved = {}
    for _, prop in ipairs(TRACKED_PROPS) do
        local ok, val = pcall(function() return obj[prop] end)
        if ok then saved[prop] = val end
    end
    originals[obj] = saved
end

local function RestoreOriginals(obj)
    local saved = originals[obj]
    if not saved then return end
    for prop, val in pairs(saved) do
        pcall(function() obj[prop] = val end)
    end
end

local function ApplyUIScale(screenGui)
    if not screenGui:IsA("ScreenGui") then return end
    local existing = screenGui:FindFirstChildOfClass("UIScale")
    if existing then
        if originalScales[screenGui] == nil then
            originalScales[screenGui] = existing.Scale
        end
        existing.Scale = Scale.UIScale
    else
        if originalScales[screenGui] == nil then
            originalScales[screenGui] = false
        end
        local s       = Instance.new("UIScale")
        s.Name        = "DynxeUIScale"
        s.Scale       = Scale.UIScale
        s.Parent      = screenGui
    end
end

local function RemoveUIScale(screenGui)
    if not screenGui:IsA("ScreenGui") then return end
    local orig = originalScales[screenGui]
    if orig == false then
        local s = screenGui:FindFirstChild("DynxeUIScale")
        if s then s:Destroy() end
    elseif orig then
        local existing = screenGui:FindFirstChildOfClass("UIScale")
        if existing then existing.Scale = orig end
    end
    originalScales[screenGui] = nil
end

local function BuildApplier(obj)
    if obj:IsA("Frame") or obj:IsA("ScrollingFrame") then
        local nameLower = obj.Name:lower()
        local color

        if nameLower:match("sidebar") or nameLower:match("nav") then
            color = Theme.SidebarBG
        elseif nameLower:match("shadow") or nameLower:match("drop") then
            color = Color3.fromRGB(0, 0, 0)
        elseif obj.Name == "Main" or nameLower:match("container")
            or nameLower:match("window") or nameLower:match("panel") then
            color = Theme.MainBG
        elseif nameLower:match("row") or nameLower:match("item")
            or nameLower:match("entry") or nameLower:match("cell") then
            color = Theme.RowBG
        else
            color = Theme.MainBG
        end

        local isShadow = nameLower:match("shadow") or nameLower:match("drop")

        return function()
            obj.BorderSizePixel = 0
            obj.BackgroundColor3 = color
            if isShadow then obj.BackgroundTransparency = 0.6 end
        end

    elseif obj:IsA("TextButton") then
        local nameLower = obj.Name:lower()
        local textLower = obj.Text and obj.Text:lower() or ""
        local bgColor, textColor, bgTransparency

        if textLower == "tp" or textLower == "plot" then
            bgColor = Theme.FilledBtn
            textColor = Theme.Text
            bgTransparency = 0
        elseif textLower:match("select") or nameLower:match("select")
            or nameLower:match("teleport") or textLower:match("teleport")
            or nameLower:match("^tp$") then
            bgColor = Color3.fromRGB(0, 0, 0)
            textColor = Theme.AccentBlue
            bgTransparency = 1
        else
            bgColor = Theme.RowBG
            textColor = Theme.Text
            bgTransparency = 0
        end

        return function()
            obj.BorderSizePixel = 0
            obj.Font = Fonts.Button
            obj.TextSize = math.max(TextSizes.ButtonMin, obj.TextSize) + TextSizes.Offset
            obj.BackgroundColor3 = bgColor
            obj.BackgroundTransparency = bgTransparency
            obj.TextColor3 = textColor
        end

    elseif obj:IsA("ImageButton") then
        return function()
            obj.BackgroundColor3 = Theme.SidebarBG
            obj.BackgroundTransparency = 0
            obj.BorderSizePixel = 0
        end

    elseif obj:IsA("TextLabel") then
        local nameLower = obj.Name:lower()
        local textVal   = obj.Text or ""

        if nameLower == "dropshadow" or nameLower:match("drop_shadow") then
            return function()
                obj.BackgroundTransparency = 1
                obj.TextColor3 = Theme.DropShadow
                obj.Font = Fonts.Body
            end
        end

        local isHeader = nameLower:match("section") or nameLower:match("heading")
            or nameLower:match("header") or nameLower:match("title")
            or (textVal == textVal:upper() and #textVal > 2)
            or obj.TextSize >= 18

        local isSub = nameLower:match("sub") or nameLower:match("hint")
            or nameLower:match("desc")

        local textColor = isHeader and Theme.AccentBlue
                       or isSub    and Theme.SubText
                       or Theme.Text
        local font      = isHeader and Fonts.Bold or Fonts.Body
        local minSize   = isHeader and TextSizes.SectionMin or TextSizes.BodyMin

        return function()
            obj.BackgroundTransparency = 1
            obj.TextColor3 = textColor
            obj.Font = font
            obj.TextSize = math.max(minSize, obj.TextSize) + TextSizes.Offset
        end

    elseif obj:IsA("ImageLabel") then
        return function()
            obj.BackgroundTransparency = 1
        end
    end

    return nil
end

local function ThemeAndWatch(obj)
    if watching[obj] then return end
    if not enabled then return end

    local applier = BuildApplier(obj)
    if not applier then return end

    SaveOriginals(obj)
    watching[obj] = true
    applier()

    local reapplying = false

    local function onReset()
        if reapplying or not enabled then return end
        task.delay(0.15, function()
            if not obj or not obj.Parent or not enabled then return end
            reapplying = true
            applier()
            reapplying = false
        end)
    end

    if obj:IsA("GuiObject") then
        local c = obj:GetPropertyChangedSignal("BackgroundColor3"):Connect(onReset)
        table.insert(propertyConns, c)
    end
    if obj:IsA("TextLabel") or obj:IsA("TextButton") then
        local c1 = obj:GetPropertyChangedSignal("TextColor3"):Connect(onReset)
        local c2 = obj:GetPropertyChangedSignal("Font"):Connect(onReset)
        table.insert(propertyConns, c1)
        table.insert(propertyConns, c2)
    end

    local dc = obj.Destroying:Connect(function()
        watching[obj]  = nil
        originals[obj] = nil
    end)
    table.insert(propertyConns, dc)
end

local function ThemeAll(parent)
    for _, child in ipairs(parent:GetChildren()) do
        if child:IsA("ScreenGui") then ApplyUIScale(child) end
    end
    for _, child in ipairs(parent:GetDescendants()) do
        ThemeAndWatch(child)
    end
end

function DynxeTheme.Enable()
    if enabled then return end
    enabled = true
    ThemeAll(PlayerGui)
end

function DynxeTheme.Disable()
    if not enabled then return end
    enabled = false

    -- Disconnect all per-element watchers
    for _, conn in ipairs(propertyConns) do
        if conn and conn.Connected then conn:Disconnect() end
    end
    propertyConns = {}

    -- Restore every element to its original look
    for obj, _ in pairs(originals) do
        if obj and obj.Parent then
            RestoreOriginals(obj)
        end
    end
    originals = {}
    watching  = {}

    -- Undo UIScale on all ScreenGuis
    for _, child in ipairs(PlayerGui:GetChildren()) do
        if child:IsA("ScreenGui") then
            RemoveUIScale(child)
        end
    end
    originalScales = {}
end

function DynxeTheme.IsEnabled()
    return enabled
end

PlayerGui.DescendantAdded:Connect(function(descendant)
    if not enabled then return end
    task.wait(0.1)
    ThemeAndWatch(descendant)
    if descendant:IsA("ScreenGui") then
        ApplyUIScale(descendant)
    end
end)
ThemeAll(PlayerGui)

_G.DynxeTheme = DynxeTheme
return DynxeTheme
]], "Theme"))() end

local function LoadModule(ModuleName)
    local fn = __modules[ModuleName]
    if not fn then
        warn("[Dynxe] Module not found in bundle: " .. tostring(ModuleName))
        return nil
    end
    local ok, result = pcall(fn)
    if not ok then
        warn("[Dynxe] Module error (" .. ModuleName .. "): " .. tostring(result))
        return nil
    end
    return result
end

_G.LoadModule = LoadModule
getgenv().LoadModule = LoadModule

local User    = "learnhtsd"
local Repo    = "lt2"
local Branch  = "main"
local Version = "v0.0.755"
local BaseURL = "https://api.dynxe.services"

if _G.__DynxeLoaded then
    warn("[Dynxe] Already loaded — ignoring duplicate execution.")
    return
end
_G.__DynxeLoaded = true
local _iconCacheReady = false

_iconCacheReady = true

local Config = {
    Window = {
        Width  = 400,
        Height = 500,
        SidebarWidth = 40,
    },
    Elements = {
        Scale = 0.80,
    },
    Theme = {
        Accent          = Color3.fromRGB(74,  120, 255),
        Background      = Color3.fromRGB(18,  18,  22),
        Surface         = Color3.fromRGB(24,  24,  29),
        SurfaceDeep     = Color3.fromRGB(35,  35,  42),
        Sidebar         = Color3.fromRGB(14,  14,  17),
        Stroke          = Color3.fromRGB(40,  40,  48),
        TextPrimary     = Color3.fromRGB(220, 220, 220),
        TextSecondary   = Color3.fromRGB(120, 120, 130),
        TextDark        = Color3.fromRGB(180, 180, 180),
        TextWhite       = Color3.fromRGB(255, 255, 255),
        Success         = Color3.fromRGB(45,  160, 75),
        Warning         = Color3.fromRGB(100, 155, 255),
        NotifBackground = Color3.fromRGB(24,  24,  29),
    },
}

local function ES(n) return math.round(n * Config.Elements.Scale) end
local function FS(n) return math.max(8, math.round(n * Config.Elements.Scale)) end
local T = Config.Theme
local W = Config.Window

local CoreGui               = game:GetService("CoreGui")
local UserInputService      = game:GetService("UserInputService")
local TweenService          = game:GetService("TweenService")
local ContextActionService  = game:GetService("ContextActionService")
local TextService           = game:GetService("TextService")
local GuiService            = game:GetService("GuiService")

local TI_02    = TweenInfo.new(0.2)
local TI_03    = TweenInfo.new(0.3)
local TI_015   = TweenInfo.new(0.15)
local TI_025   = TweenInfo.new(0.25)
local TI_025Q  = TweenInfo.new(0.25, Enum.EasingStyle.Quart)
local TI_04Q_O = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local TI_04Q_I = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

local function Corner(parent, radius)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = radius or UDim.new(0, 6)
    return c
end

local Library = {}

for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name == "DynxeHub" then v:Destroy() end
    if v.Name == "DynxeNotifications" then v:Destroy() end
end

local function FileExists(path)
    local ok, data = pcall(readfile, path)
    return ok and type(data) == "string" and #data > 0
end

getgenv().GetImage = function(folder, fileName)
    local base       = "Dynxe"
    local localPath  = (folder ~= "" and folder ~= nil)
                       and (base .. "/" .. folder .. "/" .. fileName)
                       or  (base .. "/" .. fileName)
    local folderPath = (folder ~= "" and folder ~= nil)
                       and (base .. "/" .. folder)
                       or  base
    local placeholderLocal = base .. "/Placeholder.png"
    local placeholderUrl = BaseURL .. "/Images/Placeholder.png"
    if isfolder and not isfolder(base)       then makefolder(base)       end
    if isfolder and not isfolder(folderPath) then makefolder(folderPath) end
    if not FileExists(placeholderLocal) then
        local pOk, pData = pcall(function() return game:HttpGet(placeholderUrl) end)
        if pOk and #pData > 100 then writefile(placeholderLocal, pData) end
    end
    if FileExists(localPath) then return getcustomasset(localPath) end
    local url = (folder ~= "" and folder ~= nil)
        and string.format("%s/Images/%s/%s", BaseURL, folder, fileName)
        or  string.format("%s/Images/%s", BaseURL, fileName)
    local ok, content = pcall(function() return game:HttpGet(url) end)
    if ok and content and not content:find("404: Not Found") and #content > 100 then
        writefile(localPath, content)
        return getcustomasset(localPath)
    else
        warn("Asset Missing: " .. fileName)
        return FileExists(placeholderLocal) and getcustomasset(placeholderLocal) or "rbxassetid://6023426923"
    end
end

local function AddDepthStroke(frame)
    local Stroke = Instance.new("UIStroke")
    Stroke.Parent          = frame
    Stroke.Color           = T.Stroke
    Stroke.Thickness       = 1
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
end

function Library:CreateWindow()
    local Window     = {}
    local CurrentTab = nil
    local tabIndex = 0

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name            = "DynxeHub"
    ScreenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
    ScreenGui.IgnoreGuiInset  = true
    ScreenGui.Parent          = CoreGui

    local TooltipGui = Instance.new("TextLabel")
    TooltipGui.Size                = UDim2.new(0, 0, 0, 0)
    TooltipGui.AutomaticSize       = Enum.AutomaticSize.XY
    TooltipGui.BackgroundColor3    = Color3.fromRGB(15, 15, 25)
    TooltipGui.TextColor3          = T.TextDark
    TooltipGui.Font                = Enum.Font.GothamMedium
    TooltipGui.TextSize            = FS(12)
    TooltipGui.RichText            = true
    TooltipGui.Visible             = false
    TooltipGui.ZIndex              = 100
    TooltipGui.Parent              = ScreenGui
    local TTPad = Instance.new("UIPadding", TooltipGui)
    TTPad.PaddingTop    = UDim.new(0, ES(6))
    TTPad.PaddingBottom = UDim.new(0, ES(6))
    TTPad.PaddingLeft   = UDim.new(0, ES(8))
    TTPad.PaddingRight  = UDim.new(0, ES(8))
    Corner(TooltipGui, UDim.new(0, 4))

    function Library.ShowTooltip(text)
        TooltipGui.Text    = text
        TooltipGui.Visible = true
    end
    function Library.HideTooltip()
        TooltipGui.Visible = false
    end
    local _inset = GuiService:GetGuiInset()
    UserInputService.InputChanged:Connect(function(input)
        if TooltipGui.Visible and input.UserInputType == Enum.UserInputType.MouseMovement then
            TooltipGui.Position = UDim2.new(
                0, math.round(input.Position.X + 12),
                0, math.round(input.Position.Y + _inset.Y + 12)
            )
        end
    end)

    local function AttachTooltip(TitleLabel, ElementTable)
        function ElementTable:AddTooltip(text)
            local InfoIcon = Instance.new("TextLabel")
            InfoIcon.Size               = UDim2.new(0, ES(16), 0, ES(16))
            InfoIcon.AnchorPoint        = Vector2.new(0, 0.5)
            InfoIcon.BackgroundTransparency = 1
            InfoIcon.Text               = "(?)"
            InfoIcon.TextColor3         = T.TextSecondary
            InfoIcon.Font               = Enum.Font.Gotham
            InfoIcon.TextSize           = FS(12)
            InfoIcon.Parent             = TitleLabel
            local function updatePos()
                InfoIcon.Position = UDim2.new(0, TitleLabel.TextBounds.X + 6, 0.5, 0)
            end
            TitleLabel:GetPropertyChangedSignal("TextBounds"):Connect(updatePos)
            updatePos()
            InfoIcon.MouseEnter:Connect(function()
                InfoIcon.TextColor3 = T.Accent
                Library.ShowTooltip(text)
            end)
            InfoIcon.MouseLeave:Connect(function()
                InfoIcon.TextColor3 = T.TextSecondary
                Library.HideTooltip()
            end)
            return ElementTable
        end
        return ElementTable
    end

    local ShadowFrame = Instance.new("Frame")
    ShadowFrame.Size             = UDim2.new(0, W.Width + 8, 0, W.Height + 8)
    ShadowFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
    ShadowFrame.BackgroundTransparency = 0.7
    ShadowFrame.BorderSizePixel  = 0
    ShadowFrame.ZIndex           = 1
    ShadowFrame.Parent           = ScreenGui
    Corner(ShadowFrame, UDim.new(0, 9))

    local MainFrame = Instance.new("Frame")
    MainFrame.Size                 = UDim2.new(0, W.Width, 0, W.Height)
    MainFrame.Position             = UDim2.new(0, 0, 1, -(W.Height + 160))
    MainFrame.BackgroundColor3     = T.Background
    MainFrame.BackgroundTransparency = 0.2
    MainFrame.BorderSizePixel      = 0
    MainFrame.ZIndex               = 2
    MainFrame.Parent               = ScreenGui
    Corner(MainFrame)

    local function SyncShadow()
        ShadowFrame.Position = UDim2.new(
            MainFrame.Position.X.Scale,
            MainFrame.Position.X.Offset - 4,
            MainFrame.Position.Y.Scale,
            MainFrame.Position.Y.Offset - 4
        )
        ShadowFrame.Size = UDim2.new(
            0, MainFrame.Size.X.Offset + 8,
            0, MainFrame.Size.Y.Offset + 8
        )
        ShadowFrame.BackgroundTransparency = math.max(0.7, MainFrame.BackgroundTransparency)
    end
    SyncShadow()
    MainFrame:GetPropertyChangedSignal("Position"):Connect(SyncShadow)
    MainFrame:GetPropertyChangedSignal("Size"):Connect(SyncShadow)
    MainFrame:GetPropertyChangedSignal("BackgroundTransparency"):Connect(SyncShadow)

    local Sidebar = Instance.new("Frame")
    Sidebar.Size             = UDim2.new(0, W.SidebarWidth, 1, 0)
    Sidebar.BackgroundColor3 = T.Sidebar
    Sidebar.BorderSizePixel  = 0
    Sidebar.Parent           = MainFrame
    Corner(Sidebar)

    local SideBlock = Instance.new("Frame")
    SideBlock.Size             = UDim2.new(0, 10, 1, 0)
    SideBlock.Position         = UDim2.new(1, -10, 0, 0)
    SideBlock.BackgroundColor3 = T.Sidebar
    SideBlock.BorderSizePixel  = 0
    SideBlock.Parent           = Sidebar

    local HeaderTitle = Instance.new("TextLabel")
    HeaderTitle.Size               = UDim2.new(1, -(W.SidebarWidth + 25), 0, 30)
    HeaderTitle.Position = UDim2.new(0, W.SidebarWidth + 7, 0, 10)
    HeaderTitle.BackgroundTransparency = 1
    
    local r = math.round(T.Accent.R * 255)
    local g = math.round(T.Accent.G * 255)
    local b = math.round(T.Accent.B * 255)
    local accentHex = string.format("#%02x%02x%02x", r, g, b)
    
    HeaderTitle.Text               = "<b>Dynxe</b> <font color=\"" .. accentHex .. "\">LT2</font> <font color=\"#555555\" size=\"" .. FS(12) .. "\">" .. Version .. "</font>"
    
    HeaderTitle.RichText           = true
    HeaderTitle.TextColor3         = T.TextWhite
    HeaderTitle.Font               = Enum.Font.GothamMedium
    HeaderTitle.TextSize           = FS(16)
    HeaderTitle.TextXAlignment     = Enum.TextXAlignment.Left
    HeaderTitle.Parent             = MainFrame

    local ActiveTabLabel = Instance.new("TextLabel")
    ActiveTabLabel.Size            = UDim2.new(0, 150, 0, 30)
    ActiveTabLabel.Position        = UDim2.new(1, -165, 0, 10)
    ActiveTabLabel.BackgroundTransparency = 1
    ActiveTabLabel.Text            = ""
    ActiveTabLabel.TextColor3      = T.Accent
    ActiveTabLabel.Font            = Enum.Font.GothamMedium
    ActiveTabLabel.TextSize        = FS(12)
    ActiveTabLabel.TextXAlignment  = Enum.TextXAlignment.Right
    ActiveTabLabel.Parent          = MainFrame
    
    local FerryLabel = Instance.new("TextLabel")
    FerryLabel.Size            = UDim2.new(1, -(W.SidebarWidth + 25), 0, 14)
    FerryLabel.Position        = UDim2.new(0, W.SidebarWidth + 7, 0, 32)
    FerryLabel.BackgroundTransparency = 1
    FerryLabel.Text            = "Ferry: --"
    FerryLabel.TextColor3      = T.TextSecondary
    FerryLabel.Font            = Enum.Font.Gotham
    FerryLabel.TextSize        = FS(11)
    FerryLabel.TextXAlignment  = Enum.TextXAlignment.Left
    FerryLabel.Parent          = MainFrame
    
    task.spawn(function()
        local Ferry = game.Workspace:WaitForChild("Ferry", 10)
        if not Ferry then return end
        local TimeToDeparture = Ferry:WaitForChild("TimeToDeparture", 10)
        if not TimeToDeparture then return end
    
        local function UpdateFerry()
            local val = TimeToDeparture.Value
            if val <= 0 then
                FerryLabel.Text      = "Ferry has Departed"
                FerryLabel.TextColor3 = T.TextSecondary
            elseif val <= 10 then
                FerryLabel.Text      = "Ferry Departs: " .. val .. "s"
                FerryLabel.TextColor3 = T.Warning
            else
                FerryLabel.Text      = "Ferry Departs: " .. val .. "s"
                FerryLabel.TextColor3 = T.TextSecondary
            end
        end
    
        UpdateFerry()
        TimeToDeparture.Changed:Connect(UpdateFerry)
    end)
    
    -- TAB CONTAINER
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Name              = "TabContainer"
    TabContainer.Size              = UDim2.new(1, 0, 1, 0)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.BorderSizePixel   = 0
    TabContainer.ScrollingDirection = Enum.ScrollingDirection.Y
    TabContainer.Parent            = Sidebar

    local SidebarList = Instance.new("UIListLayout")
    SidebarList.Parent             = TabContainer
    SidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    SidebarList.VerticalAlignment  = Enum.VerticalAlignment.Top
    SidebarList.SortOrder          = Enum.SortOrder.LayoutOrder
    SidebarList.Padding = UDim.new(0, ES(8))

    local SidebarPadding = Instance.new("UIPadding")
    SidebarPadding.Parent     = TabContainer
    SidebarPadding.PaddingTop = UDim.new(0, ES(12))

    SidebarList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContainer.CanvasSize = UDim2.new(0, 0, 0, SidebarList.AbsoluteContentSize.Y + 30)
    end)

    local SidebarFade = Instance.new("Frame")
    SidebarFade.Size             = UDim2.new(1, 0, 0, ES(40))
    SidebarFade.AnchorPoint      = Vector2.new(0, 1)
    SidebarFade.Position         = UDim2.new(0, 0, 1, 0)
    SidebarFade.BackgroundColor3 = T.Sidebar
    SidebarFade.BorderSizePixel  = 0
    SidebarFade.ZIndex           = 5
    SidebarFade.Visible          = false
    SidebarFade.Parent           = Sidebar
    Corner(SidebarFade, UDim.new(0, 9))
    local SidebarFadeGrad = Instance.new("UIGradient", SidebarFade)
    SidebarFadeGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0),
    })
    SidebarFadeGrad.Rotation = 90

    local ScrollArrow = Instance.new("TextLabel")
    ScrollArrow.Size                   = UDim2.new(1, 0, 0, ES(14))
    ScrollArrow.AnchorPoint            = Vector2.new(0.5, 1)
    ScrollArrow.Position               = UDim2.new(0.5, 0, 1, -ES(4))
    ScrollArrow.BackgroundTransparency = 1
    ScrollArrow.Text                   = "∨"
    ScrollArrow.TextColor3             = T.TextSecondary
    ScrollArrow.Font                   = Enum.Font.GothamBold
    ScrollArrow.TextSize               = FS(10)
    ScrollArrow.ZIndex                 = 6
    ScrollArrow.Parent                 = Sidebar

    -- Show/hide fade based on scroll position and content size
    local function UpdateSidebarFade()
        local contentH = SidebarList.AbsoluteContentSize.Y + 30
        local viewH    = TabContainer.AbsoluteSize.Y
        local scrollY  = TabContainer.CanvasPosition.Y
        local canScroll = contentH > viewH
        local atBottom  = scrollY >= contentH - viewH - 2
        SidebarFade.Visible  = canScroll and not atBottom
        ScrollArrow.Visible  = canScroll and not atBottom
    end

    SidebarList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSidebarFade)
    TabContainer:GetPropertyChangedSignal("CanvasPosition"):Connect(UpdateSidebarFade)
    TabContainer:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateSidebarFade)

    -- CONTENT AREA
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Size     = UDim2.new(1, -(W.SidebarWidth + 14), 1, -60)
    ContentContainer.Position = UDim2.new(0, W.SidebarWidth + 7, 0, 52)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.ClipsDescendants  = true
    ContentContainer.Parent            = MainFrame

    -- NOTIFICATIONS
    local NotifGui = Instance.new("ScreenGui")
    NotifGui.Name            = "DynxeNotifications"
    NotifGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
    NotifGui.DisplayOrder    = 999
    NotifGui.ResetOnSpawn    = false
    NotifGui.Parent          = CoreGui

    -- AnchorPoint(1,0) + Position(1,0,...) pins the right edge flush to the screen.
    local NotificationContainer = Instance.new("Frame")
    NotificationContainer.Name        = "NotificationContainer"
    NotificationContainer.Size        = UDim2.new(0, 270, 1, -20)
    NotificationContainer.AnchorPoint = Vector2.new(1, 0)
    NotificationContainer.Position    = UDim2.new(1, 0, 0, 10)
    NotificationContainer.BackgroundTransparency = 1
    NotificationContainer.Parent      = NotifGui

    local NotifList = Instance.new("UIListLayout")
    NotifList.Parent            = NotificationContainer
    NotifList.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NotifList.SortOrder         = Enum.SortOrder.LayoutOrder
    NotifList.Padding           = UDim.new(0, 6)

    function Library:Notify(Title, Text, Duration)
        Duration = Duration or 2

        local CR     = 4
        local OPEN_H = ES(72)

        local NotifFrame = Instance.new("Frame")
        NotifFrame.Size                   = UDim2.new(1, CR, 0, 0)
        NotifFrame.BackgroundColor3       = T.NotifBackground
        NotifFrame.BackgroundTransparency = 0.08
        NotifFrame.BorderSizePixel        = 0
        NotifFrame.Parent                 = NotificationContainer
        Corner(NotifFrame, UDim.new(0, CR))

        local AccentBar = Instance.new("Frame")
        AccentBar.Size             = UDim2.new(0, 2, 1, 0)
        AccentBar.AnchorPoint      = Vector2.new(1, 0)
        AccentBar.Position         = UDim2.new(1, -CR, 0, 0)
        AccentBar.BackgroundColor3 = T.Accent
        AccentBar.BorderSizePixel  = 0
        AccentBar.Parent           = NotifFrame

        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Size               = UDim2.new(1, -(CR + ES(20)), 0, ES(20))
        TitleLabel.Position           = UDim2.new(0, ES(10), 0, ES(8))
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Text               = Title:upper()
        TitleLabel.TextColor3         = T.Accent
        TitleLabel.Font               = Enum.Font.GothamBold
        TitleLabel.TextSize           = FS(14)   -- increased
        TitleLabel.TextXAlignment     = Enum.TextXAlignment.Right
        TitleLabel.TextTruncate       = Enum.TextTruncate.AtEnd
        TitleLabel.Parent             = NotifFrame

        local DividerTrack = Instance.new("Frame")
        DividerTrack.Size                   = UDim2.new(1, -(CR + ES(12)), 0, ES(2))
        DividerTrack.Position               = UDim2.new(0, ES(6), 0, ES(31))
        DividerTrack.BackgroundColor3       = T.Stroke
        DividerTrack.BackgroundTransparency = 0.3
        DividerTrack.BorderSizePixel        = 0
        DividerTrack.ClipsDescendants       = true
        DividerTrack.Parent                 = NotifFrame
        Corner(DividerTrack, UDim.new(1, 0))

        local DividerFill = Instance.new("Frame")
        DividerFill.AnchorPoint      = Vector2.new(1, 0)
        DividerFill.Position         = UDim2.new(1, 0, 0, 0)
        DividerFill.Size             = UDim2.new(1, 0, 1, 0)
        DividerFill.BackgroundColor3 = T.Accent
        DividerFill.BackgroundTransparency = 0.35
        DividerFill.BorderSizePixel  = 0
        DividerFill.Parent           = DividerTrack

        local ContentLabel = Instance.new("TextLabel")
        ContentLabel.Size             = UDim2.new(1, -(CR + ES(16)), 0, ES(30))
        ContentLabel.Position         = UDim2.new(0, ES(10), 0, ES(36))
        ContentLabel.BackgroundTransparency = 1
        ContentLabel.Text             = Text
        ContentLabel.TextColor3       = T.TextDark
        ContentLabel.Font             = Enum.Font.Gotham
        ContentLabel.TextSize         = FS(13)   -- increased
        ContentLabel.TextWrapped      = true
        ContentLabel.TextXAlignment   = Enum.TextXAlignment.Right
        ContentLabel.Parent           = NotifFrame

        local openTween = TweenService:Create(NotifFrame, TI_04Q_O, {
            Size = UDim2.new(1, CR, 0, OPEN_H)
        })
        openTween:Play()
        openTween.Completed:Connect(function()
            TweenService:Create(DividerFill,
                TweenInfo.new(Duration, Enum.EasingStyle.Linear),
                { Size = UDim2.new(0, 0, 1, 0) }
            ):Play()
        end)

        task.delay(Duration, function()
            local Tween = TweenService:Create(NotifFrame, TI_04Q_I, {
                Size                   = UDim2.new(1, CR, 0, 0),
                BackgroundTransparency = 1,
            })
            Tween:Play()
            Tween.Completed:Connect(function() NotifFrame:Destroy() end)
        end)
    end

    local dragging, dragStart, startPos = false, nil, nil
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        end
    end)
    MainFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging and not _G.DynxeMenuClamped then
            local d = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)

    -- ── CREATE TAB ───────────────────────────────────────────
    function Window:CreateTab(TabName)
        local Tab = {}
        tabIndex = tabIndex + 1
        local thisTabIndex = tabIndex

        local TabBtn = Instance.new("ImageButton")
        TabBtn.Name              = TabName
        TabBtn.Size = UDim2.new(0, ES(34), 0, ES(34))
        TabBtn.Parent            = TabContainer
        TabBtn.BackgroundColor3  = T.Accent
        TabBtn.BackgroundTransparency = 1
        Corner(TabBtn, UDim.new(0, 8))

        local FallbackText = Instance.new("TextLabel", TabBtn)
        FallbackText.Size              = UDim2.new(1, 0, 1, 0)
        FallbackText.BackgroundTransparency = 1
        FallbackText.Text              = string.sub(TabName, 1, 1):upper()
        FallbackText.TextColor3        = T.TextSecondary
        FallbackText.Font              = Enum.Font.GothamBold
        FallbackText.TextSize          = FS(14)
        FallbackText.Name              = "TabIconText"

        local folderName = "Dynxe"
        local fileName   = TabName .. ".png"
        local filePath   = folderName .. "/" .. fileName

        local TabIcon = Instance.new("ImageLabel")
        TabIcon.Size     = UDim2.new(0, ES(20), 0, ES(20))
        TabIcon.Position = UDim2.new(0.5, -ES(10), 0.5, -ES(10))
        TabIcon.BackgroundTransparency = 1
        TabIcon.Image              = ""
        TabIcon.ImageColor3        = T.TextWhite
        TabIcon.ScaleType          = Enum.ScaleType.Fit
        TabIcon.Name               = "TabIcon"
        TabIcon.Parent             = TabBtn

        task.spawn(function()
            local iconUrl = string.format("%s/Icons/%s.png", BaseURL, TabName)
            task.wait(thisTabIndex * 0.08)
            
            for attempt = 1, 3 do
                local ok, imgData = pcall(function() return game:HttpGet(iconUrl) end)
                if ok and type(imgData) == "string" and #imgData > 100 and not imgData:match("404: Not Found") then
                    -- Try to write to disk for caching, but don't depend on it
                    if isfolder and makefolder and writefile and getcustomasset then
                        if not isfolder(folderName) then pcall(makefolder, folderName) end
                        local writeOk = pcall(writefile, filePath, imgData)
                        if writeOk then
                            task.wait(0.05)
                            local asset = pcall(getcustomasset, filePath) and getcustomasset(filePath)
                            if asset and asset ~= "" then
                                TabIcon.Image = asset
                                FallbackText.Visible = false
                                return
                            end
                        end
                    end
                    local tempPath = folderName .. "/_tmp_" .. TabName .. ".png"
                    pcall(makefolder, folderName)
                    local writeOk = pcall(writefile, tempPath, imgData)
                    if writeOk then
                        task.wait(0.05)
                        local ok2, asset = pcall(getcustomasset, tempPath)
                        if ok2 and asset and asset ~= "" then
                            TabIcon.Image = asset
                            FallbackText.Visible = false
                            return
                        end
                    end
                end
                task.wait(0.3 * attempt)
            end
        end)

        local TweenIn  = TweenService:Create(TabBtn, TI_03, {BackgroundTransparency = 0.85})
        local TweenOut = TweenService:Create(TabBtn, TI_03, {BackgroundTransparency = 1})

        TabBtn.MouseEnter:Connect(function()
            if CurrentTab and CurrentTab.Btn == TabBtn then return end
            TweenService:Create(TabBtn,  TI_015, {BackgroundTransparency = 0.92}):Play()
            TweenService:Create(TabIcon, TI_015, {ImageColor3 = T.Accent}):Play()
            FallbackText.TextColor3 = T.Accent
        end)

        TabBtn.MouseLeave:Connect(function()
            if CurrentTab and CurrentTab.Btn == TabBtn then return end
            TweenService:Create(TabBtn,  TI_015, {BackgroundTransparency = 1}):Play()
            TweenService:Create(TabIcon, TI_015, {ImageColor3 = T.TextWhite}):Play()
            FallbackText.TextColor3 = T.TextSecondary
        end)

        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Size               = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.ScrollBarThickness = 0
        TabPage.BorderSizePixel    = 0
        TabPage.Visible            = false
        TabPage.ClipsDescendants   = true
        TabPage.Parent             = ContentContainer
        Tab.Container              = TabPage

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Parent   = TabPage
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding  = UDim.new(0, ES(6))

        local PagePadding = Instance.new("UIPadding")
        PagePadding.Parent        = TabPage
        PagePadding.PaddingLeft   = UDim.new(0, 2)
        PagePadding.PaddingRight  = UDim.new(0, 4)
        PagePadding.PaddingTop    = UDim.new(0, 2)
        PagePadding.PaddingBottom = UDim.new(0, ES(20))

        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabPage.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 25)
        end)

        local function ActivateTab()
            if CurrentTab then
                CurrentTab.TweenOut:Play()
                CurrentTab.Btn.TabIconText.TextColor3 = T.TextSecondary
                local prev = CurrentTab.Btn:FindFirstChild("TabIcon")
                if prev then
                    TweenService:Create(prev, TI_03, {ImageColor3 = T.TextWhite}):Play()
                end
                CurrentTab.Page.Visible = false
            end
            TweenIn:Play()
            FallbackText.TextColor3 = T.Accent
            TweenService:Create(TabIcon, TI_03, {ImageColor3 = T.Accent}):Play()
            TabPage.Visible         = true
            ActiveTabLabel.Text     = TabName:upper()
            CurrentTab = {Btn = TabBtn, TweenOut = TweenOut, Page = TabPage}
        end

        TabBtn.MouseButton1Click:Connect(ActivateTab)
        if not CurrentTab then ActivateTab() end

        -- ── ROW ───────────────────────────────────────────────
        function Tab:CreateRow()
            local Row = setmetatable({}, {__index = self})
            local RowFrame = Instance.new("Frame")
            RowFrame.Size              = UDim2.new(1, 0, 0, ES(28))
            RowFrame.BackgroundTransparency = 1
            RowFrame.Parent            = self.Container
            local RowLayout = Instance.new("UIListLayout")
            RowLayout.Parent          = RowFrame
            RowLayout.FillDirection   = Enum.FillDirection.Horizontal
            RowLayout.SortOrder       = Enum.SortOrder.LayoutOrder
            RowLayout.Padding         = UDim.new(0, ES(6))
            RowLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                RowFrame.Size = UDim2.new(1, 0, 0, RowLayout.AbsoluteContentSize.Y)
            end)
            RowFrame.ChildAdded:Connect(function()
                task.defer(function()
                    local elements = {}
                    for _, v in pairs(RowFrame:GetChildren()) do
                        if v:IsA("GuiObject") and not v:IsA("UIListLayout") then
                            table.insert(elements, v)
                        end
                    end
                    local count = #elements
                    if count > 0 then
                        local totalPadding = (count - 1) * ES(6)
                        for _, v in pairs(elements) do
                            v.Size = UDim2.new(1/count, -totalPadding/count, 0, v.Size.Y.Offset)
                        end
                    end
                end)
            end)
            Row.Container = RowFrame
            return Row
        end
        
        -- ── SECTION ───────────────────────────────────────────
        function Tab:CreateSection(Name)
            local collapsed = false

            local Holder = Instance.new("Frame")
            Holder.Name = "_SectionHolder"
            Holder.Size                   = UDim2.new(1, 0, 0, ES(20))
            Holder.BackgroundTransparency = 1
            Holder.Parent                 = self.Container

            local HitBtn = Instance.new("TextButton")
            HitBtn.Size                   = UDim2.new(1, 0, 1, 0)
            HitBtn.BackgroundTransparency = 1
            HitBtn.Text                   = ""
            HitBtn.ZIndex                 = 3
            HitBtn.Parent                 = Holder

            local Arrow = Instance.new("TextLabel")
            Arrow.Size                   = UDim2.new(0, ES(16), 1, 0)
            Arrow.Position               = UDim2.new(0, 0, 0, 0)
            Arrow.BackgroundTransparency = 1
            Arrow.Text                   = "▼"
            Arrow.TextColor3             = T.Accent
            Arrow.Font                   = Enum.Font.GothamBold
            Arrow.TextSize               = FS(16)
            Arrow.TextXAlignment         = Enum.TextXAlignment.Left
            Arrow.Parent                 = Holder

            local SectionLabel = Instance.new("TextLabel")
            SectionLabel.AutomaticSize        = Enum.AutomaticSize.X
            SectionLabel.Size                 = UDim2.new(0, 0, 1, 0)
            SectionLabel.Position             = UDim2.new(0, ES(14), 0, 0)
            SectionLabel.BackgroundTransparency = 1
            SectionLabel.Text                 = Name:upper()
            SectionLabel.TextColor3           = T.Accent
            SectionLabel.Font                 = Enum.Font.GothamBold
            SectionLabel.TextSize             = FS(11)
            SectionLabel.TextXAlignment       = Enum.TextXAlignment.Left
            SectionLabel.Parent               = Holder

            local Gap = ES(6)

            local Line = Instance.new("Frame")
            Line.AnchorPoint            = Vector2.new(1, 0.5)
            Line.Position               = UDim2.new(1, 0, 0.5, 0)
            Line.BackgroundColor3       = T.Accent
            Line.BackgroundTransparency = 0.6
            Line.BorderSizePixel        = 0
            Line.Parent                 = Holder

            local function UpdateLine()
                local textWidth   = SectionLabel.AbsoluteSize.X + ES(14)
                local holderWidth = Holder.AbsoluteSize.X
                if holderWidth > 0 and textWidth > 0 then
                    Line.Size = UDim2.new(0, holderWidth - textWidth - Gap, 0, ES(1))
                end
            end

            task.defer(UpdateLine)
            Holder:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateLine)
            SectionLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateLine)

            local function GetSectionChildren()
                local container = self.Container
                local children = {}
                local foundSelf = false
                for _, child in ipairs(container:GetChildren()) do
                    if child:IsA("UIListLayout") or child:IsA("UIPadding") then continue end
                    if child == Holder then
                        foundSelf = true
                        continue
                    end
                    if foundSelf then
                        if child.Name == "_SectionHolder" then break end
                        table.insert(children, child)
                    end
                end
                return children
            end

            HitBtn.MouseButton1Click:Connect(function()
                collapsed = not collapsed
                Arrow.Text = collapsed and "▶" or "▼"
                for _, child in ipairs(GetSectionChildren()) do
                    child.Visible = not collapsed
                end
            end)
        end

        -- ── ACTION ────────────────────────────────────────────
        function Tab:CreateAction(Title, ButtonText, Callback, Secure)
            local Element     = {}
            Element.Disabled  = false

            local RowHeight   = ES(28)
            local BtnHeight   = ES(20)
            local BtnWidth    = ES(70)

            local ActionFrame = Instance.new("Frame")
            ActionFrame.Size             = UDim2.new(1, 0, 0, RowHeight)
            ActionFrame.BackgroundColor3 = T.Surface
            ActionFrame.Parent           = self.Container
            Corner(ActionFrame)
            AddDepthStroke(ActionFrame)

            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Size            = UDim2.new(0.65, 0, 1, 0)
            TitleLabel.Position        = UDim2.new(0, ES(10), 0, 0)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Text            = Title
            TitleLabel.TextColor3      = T.TextPrimary
            TitleLabel.Font            = Enum.Font.GothamMedium
            TitleLabel.TextSize        = FS(12)
            TitleLabel.TextXAlignment  = Enum.TextXAlignment.Left
            TitleLabel.Parent          = ActionFrame

            if Secure then
                local SecureAccent = Color3.fromRGB(220, 60, 60)
                TitleLabel.TextColor3 = SecureAccent
            end

            local ActionBtn = Instance.new("TextButton")
            ActionBtn.Size             = UDim2.new(0, BtnWidth, 0, BtnHeight)
            ActionBtn.AnchorPoint      = Vector2.new(1, 0.5)
            ActionBtn.Position         = UDim2.new(1, -ES(8), 0.5, 0)
            ActionBtn.BackgroundColor3 = T.SurfaceDeep
            ActionBtn.Text             = ButtonText
            ActionBtn.TextColor3       = T.TextWhite
            ActionBtn.Font             = Enum.Font.GothamBold
            ActionBtn.TextSize         = FS(11)
            ActionBtn.Parent           = ActionFrame
            Corner(ActionBtn, UDim.new(0, 4))
            AddDepthStroke(ActionBtn)

            local awaitingConfirm = false
            local resetThread     = nil

            local function resetBtn()
                awaitingConfirm = false
                TweenService:Create(ActionBtn, TI_025, {
                    BackgroundColor3 = Element.Disabled and T.Surface or T.SurfaceDeep,
                    TextTransparency = Element.Disabled and 0.5 or 0
                }):Play()
                ActionBtn.Text      = ButtonText
                ActionBtn.TextColor3 = T.TextWhite
            end

            function Element:SetText(NewText)
                ButtonText = NewText
                if not awaitingConfirm then
                    ActionBtn.Text = NewText
                end
            end

            function Element:SetDisabled(State)
                Element.Disabled = State
                ActionBtn.Active = not State
                TweenService:Create(ActionBtn, TI_02, {
                    BackgroundTransparency = State and 0.5 or 0,
                    TextTransparency = State and 0.5 or 0,
                    BackgroundColor3 = State and T.Surface or T.SurfaceDeep
                }):Play()
                if State and awaitingConfirm then
                    if resetThread then task.cancel(resetThread) end
                    resetBtn()
                end
            end

            ActionBtn.MouseButton1Click:Connect(function()
                if Element.Disabled then return end
                if Secure then
                    if not awaitingConfirm then
                        awaitingConfirm = true
                        TweenService:Create(ActionBtn, TI_02, {BackgroundColor3 = Color3.fromRGB(160, 40, 40)}):Play()
                        ActionBtn.Text      = "Confirm?"
                        ActionBtn.TextColor3 = Color3.fromRGB(255, 160, 160)
                        if resetThread then task.cancel(resetThread) end
                        resetThread = task.delay(3, resetBtn)
                    else
                        if resetThread then task.cancel(resetThread) end
                        awaitingConfirm = false
                        TweenService:Create(ActionBtn, TI_015, {BackgroundColor3 = T.Success}):Play()
                        ActionBtn.Text      = "✓ Done"
                        ActionBtn.TextColor3 = Color3.fromRGB(200, 255, 210)
                        Callback()
                        task.delay(1.2, resetBtn)
                    end
                else
                    Callback()
                end
            end)

            return AttachTooltip(TitleLabel, Element)
        end

        -- ── TOGGLE ────────────────────────────────────────────────────────────
        function Tab:CreateToggle(Title, Default, Callback)
            local Element        = {}
            local Toggled        = Default
            local toggleDisabled = false
            local RowHeight      = ES(28)

            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size             = UDim2.new(1, 0, 0, RowHeight)
            ToggleFrame.BackgroundColor3 = T.Surface
            ToggleFrame.Parent           = self.Container
            Corner(ToggleFrame)
            AddDepthStroke(ToggleFrame)

            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Size            = UDim2.new(0.65, 0, 1, 0)
            TitleLabel.Position        = UDim2.new(0, ES(10), 0, 0)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Text            = Title
            TitleLabel.TextColor3      = T.TextPrimary
            TitleLabel.Font            = Enum.Font.GothamMedium
            TitleLabel.TextSize        = FS(12)
            TitleLabel.TextXAlignment  = Enum.TextXAlignment.Left
            TitleLabel.Parent          = ToggleFrame

            local ToggleBG = Instance.new("TextButton")
            ToggleBG.Size             = UDim2.new(0, ES(34), 0, ES(18))
            ToggleBG.AnchorPoint      = Vector2.new(1, 0.5)
            ToggleBG.Position         = UDim2.new(1, -ES(8), 0.5, 0)
            ToggleBG.BackgroundColor3 = Toggled and T.Accent or T.SurfaceDeep
            ToggleBG.Text             = ""
            ToggleBG.Parent           = ToggleFrame
            Corner(ToggleBG, UDim.new(1, 0))
            AddDepthStroke(ToggleBG)

            local dotOff = ES(3)
            local dotOn  = ES(34) - ES(15)
            local dotSz  = ES(12)
            local ToggleDot = Instance.new("Frame")
            ToggleDot.Size             = UDim2.new(0, dotSz, 0, dotSz)
            ToggleDot.Position         = Toggled and UDim2.new(0, dotOn, 0.5, -dotSz/2) or UDim2.new(0, dotOff, 0.5, -dotSz/2)
            ToggleDot.BackgroundColor3 = T.TextWhite
            ToggleDot.Parent           = ToggleBG
            Corner(ToggleDot, UDim.new(1, 0))

            local function ApplyVisual(state)
                local targetPos = state and UDim2.new(0, dotOn, 0.5, -dotSz/2) or UDim2.new(0, dotOff, 0.5, -dotSz/2)
                local targetCol = state and T.Accent or T.SurfaceDeep
                TweenService:Create(ToggleDot, TI_02, {Position = targetPos}):Play()
                TweenService:Create(ToggleBG,  TI_02, {BackgroundColor3 = targetCol}):Play()
            end

            ToggleBG.MouseButton1Click:Connect(function()
                if toggleDisabled then return end
                Toggled = not Toggled
                ApplyVisual(Toggled)
                Callback(Toggled)
            end)

            function Element:SetState(state)
                if state == Toggled then return end
                Toggled = state
                ApplyVisual(Toggled)
            end

            function Element:SetDisabled(state)
                toggleDisabled = state
                ToggleBG.Active = not state
                TweenService:Create(ToggleBG, TI_02, {
                    BackgroundTransparency = state and 0.5 or 0,
                    BackgroundColor3       = state and T.Surface or (Toggled and T.Accent or T.SurfaceDeep),
                }):Play()
                TweenService:Create(ToggleDot, TI_02, {
                    BackgroundTransparency = state and 0.5 or 0,
                }):Play()
                TitleLabel.TextColor3 = state and T.TextSecondary or T.TextPrimary
            end

            return AttachTooltip(TitleLabel, Element)
        end

        -- ── IMAGE ─────────────────────────────────────────────────────────
        function Tab:CreateImage(FileName, Height)
            local Element = {}
            local CardH   = ES(Height or 80)

            local ImageFrame = Instance.new("ImageLabel")
            ImageFrame.Size             = UDim2.new(1, 0, 0, CardH)
            ImageFrame.BackgroundColor3 = T.Surface
            ImageFrame.Image            = ""
            ImageFrame.ScaleType        = Enum.ScaleType.Stretch
            ImageFrame.ImageColor3      = Color3.new(1, 1, 1)
            ImageFrame.Parent           = self.Container
            Corner(ImageFrame)

            local StrokeFrame = Instance.new("Frame")
            StrokeFrame.Size                   = UDim2.new(1, 0, 1, 0)
            StrokeFrame.BackgroundTransparency = 1
            StrokeFrame.ZIndex                 = 10
            StrokeFrame.Parent                 = ImageFrame
            Corner(StrokeFrame)
            local Stroke = Instance.new("UIStroke", StrokeFrame)
            Stroke.Color           = T.Stroke
            Stroke.Thickness       = 1
            Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

            local function LoadImage(fileName)
                if not fileName or fileName == "" then return end
                task.spawn(function()
                    local localPath = "Dynxe/Images/" .. fileName
                    local asset

                    if isfile and getcustomasset and isfile(localPath) then
                        asset = getcustomasset(localPath)
                    else
                        local url = string.format("%s/Images/%s", BaseURL, fileName)
                        local ok, content = pcall(function() return game:HttpGet(url) end)
                        if ok and content
                        and not content:find("404: Not Found")
                        and #content > 100 then
                            if isfolder and makefolder and writefile and getcustomasset then
                                if not isfolder("Dynxe")        then makefolder("Dynxe")        end
                                if not isfolder("Dynxe/Images") then makefolder("Dynxe/Images") end
                                writefile(localPath, content)
                                asset = getcustomasset(localPath)
                            end
                        else
                            warn("[CreateImage] Asset missing: " .. fileName)
                        end
                    end

                    if asset then ImageFrame.Image = asset end
                end)
            end

            LoadImage(FileName)

            function Element:SetImage(fileName)   LoadImage(fileName)                                    end
            function Element:SetHeight(pts)       ImageFrame.Size = UDim2.new(1, 0, 0, ES(pts))         end
            function Element:SetImageColor(color) ImageFrame.ImageColor3 = color                        end
            function Element:SetTransparency(v)   ImageFrame.ImageTransparency = math.clamp(v, 0, 1)   end
            function Element:SetVisible(state)    ImageFrame.Visible = state                            end

            return Element
        end
            
        -- ── INPUT ─────────────────────────────────────────────
        function Tab:CreateInput(Title, Placeholder, Callback)
            local Element   = {}
            local RowHeight = ES(28)
            local BoxWidth  = ES(70)
            local BoxHeight = ES(20)
        
            local InputFrame = Instance.new("Frame")
            InputFrame.Size             = UDim2.new(1, 0, 0, RowHeight)
            InputFrame.BackgroundColor3 = T.Surface
            InputFrame.Parent           = self.Container
            Corner(InputFrame)
            AddDepthStroke(InputFrame)
        
            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Size            = UDim2.new(0.6, 0, 1, 0)
            TitleLabel.Position        = UDim2.new(0, ES(10), 0, 0)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Text            = Title
            TitleLabel.TextColor3      = T.TextPrimary
            TitleLabel.Font            = Enum.Font.GothamMedium
            TitleLabel.TextSize        = FS(12)
            TitleLabel.TextXAlignment  = Enum.TextXAlignment.Left
            TitleLabel.Parent          = InputFrame
        
            local InputBox = Instance.new("TextBox")
            InputBox.Name              = "InputBox"
            InputBox.Size              = UDim2.new(0, BoxWidth, 0, BoxHeight)
            InputBox.AnchorPoint       = Vector2.new(1, 0.5)
            InputBox.Position          = UDim2.new(1, -ES(8), 0.5, 0)
            InputBox.BackgroundTransparency = 1
            InputBox.BorderSizePixel   = 0
            InputBox.Text              = ""
            InputBox.PlaceholderText   = Placeholder
            InputBox.PlaceholderColor3 = T.TextSecondary
            InputBox.TextColor3        = T.TextWhite
            InputBox.Font              = Enum.Font.GothamMedium
            InputBox.TextSize          = FS(12)
            InputBox.TextXAlignment    = Enum.TextXAlignment.Right
            InputBox.ClipsDescendants  = true
            InputBox.ClearTextOnFocus  = false
            InputBox.Parent            = InputFrame
        
            local UnderTrack = Instance.new("Frame")
            UnderTrack.Size             = UDim2.new(0, BoxWidth, 0, 1)
            UnderTrack.AnchorPoint      = Vector2.new(1, 0)
            UnderTrack.Position         = UDim2.new(1, -ES(8), 0.5, ES(11))
            UnderTrack.BackgroundColor3 = T.Stroke
            UnderTrack.BorderSizePixel  = 0
            UnderTrack.Parent           = InputFrame
        
            local UnderFill = Instance.new("Frame")
            UnderFill.Size             = UDim2.new(0, 0, 1, 0)
            UnderFill.AnchorPoint      = Vector2.new(0.5, 0)
            UnderFill.Position         = UDim2.new(0.5, 0, 0, 0)
            UnderFill.BackgroundColor3 = T.Accent
            UnderFill.BorderSizePixel  = 0
            UnderFill.Parent           = UnderTrack
    
            local MIN_W = BoxWidth
            local MAX_W = ES(200)
            local PAD   = ES(10)
            
            local function RefreshWidth()
                local w = MIN_W
                if InputBox.Text ~= "" then
                    w = math.clamp(
                        TextService:GetTextSize(
                            InputBox.Text,
                            FS(11),
                            Enum.Font.GothamMedium,
                            Vector2.new(9999, 9999)
                        ).X + PAD,
                        MIN_W,
                        MAX_W
                    )
                end
                TweenService:Create(InputBox,   TI_025Q, { Size = UDim2.new(0, w, 0, BoxHeight) }):Play()
                TweenService:Create(UnderTrack, TI_025Q, { Size = UDim2.new(0, w, 0, 1)        }):Play()
            end
            
            InputBox:GetPropertyChangedSignal("Text"):Connect(RefreshWidth)
        
            InputBox.Focused:Connect(function()
                TweenService:Create(UnderFill, TI_025Q, { Size = UDim2.new(1, 0, 1, 0) }):Play()
            end)
        
            InputBox.FocusLost:Connect(function()
                Callback(InputBox.Text)
                TweenService:Create(UnderFill, TI_025Q, { Size = UDim2.new(0, 0, 1, 0) }):Play()
            end)
        
            function Element:SetText(val)
                InputBox.Text = tostring(val)
            end
        
            function Element:GetText()
                return InputBox.Text
            end
        
            return AttachTooltip(TitleLabel, Element)
        end

        function Tab:CreateScriptBox(Title, Placeholder, Callback)
            local Element = {}
            local MIN_H  = ES(80)
            local MAX_H  = ES(220)
            local LINE_W = ES(32)
            local HDR_H  = ES(26)
            local DIV_H  = 2
        
            local function TotalH(contentH)
                return HDR_H + DIV_H + contentH
            end
        
            local Outer = Instance.new("Frame")
            Outer.Size             = UDim2.new(1, 0, 0, TotalH(MIN_H))
            Outer.BackgroundColor3 = T.Surface
            Outer.ClipsDescendants = false
            Outer.Parent           = self.Container
            Corner(Outer)
            AddDepthStroke(Outer)
        
            local Header = Instance.new("Frame")
            Header.Size               = UDim2.new(1, 0, 0, HDR_H)
            Header.Position           = UDim2.new(0, 0, 0, 0)
            Header.BackgroundTransparency = 1
            Header.Parent             = Outer
        
            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Size                   = UDim2.new(1, -ES(10), 1, 0)
            TitleLabel.Position               = UDim2.new(0, ES(10), 0, 0)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Text                   = Title
            TitleLabel.TextColor3             = T.TextPrimary
            TitleLabel.Font                   = Enum.Font.GothamMedium
            TitleLabel.TextSize               = FS(12)
            TitleLabel.TextXAlignment         = Enum.TextXAlignment.Left
            TitleLabel.Parent                 = Header
        
            local UnderTrack = Instance.new("Frame")
            UnderTrack.Size             = UDim2.new(1, 0, 0, DIV_H)
            UnderTrack.Position         = UDim2.new(0, 0, 0, HDR_H)
            UnderTrack.BackgroundColor3 = T.Stroke
            UnderTrack.BackgroundTransparency = 0.4
            UnderTrack.BorderSizePixel  = 0
            UnderTrack.ClipsDescendants = true
            UnderTrack.Parent           = Outer
        
            local UnderFill = Instance.new("Frame")
            UnderFill.Size             = UDim2.new(0, 0, 1, 0)
            UnderFill.AnchorPoint      = Vector2.new(0.5, 0)
            UnderFill.Position         = UDim2.new(0.5, 0, 0, 0)
            UnderFill.BackgroundColor3 = T.Accent
            UnderFill.BorderSizePixel  = 0
            UnderFill.Parent           = UnderTrack
        
            local LineScroll = Instance.new("ScrollingFrame")
            LineScroll.Size                     = UDim2.new(0, LINE_W, 0, MIN_H)
            LineScroll.Position                 = UDim2.new(0, 0, 0, HDR_H + DIV_H)
            LineScroll.BackgroundColor3         = T.SurfaceDeep
            LineScroll.BackgroundTransparency   = 0
            LineScroll.BorderSizePixel          = 0
            LineScroll.ScrollBarThickness       = 0
            LineScroll.CanvasSize               = UDim2.new(0, 0, 0, MIN_H)
            LineScroll.ScrollingDirection       = Enum.ScrollingDirection.Y
            LineScroll.ScrollingEnabled         = false
            LineScroll.ClipsDescendants         = true
            LineScroll.Parent                   = Outer
        
            local LineNums = Instance.new("TextLabel")
            LineNums.Size                   = UDim2.new(1, -ES(6), 0, MIN_H)
            LineNums.Position               = UDim2.new(0, 0, 0, ES(5))
            LineNums.BackgroundTransparency = 1
            LineNums.Text                   = "1"
            LineNums.TextColor3             = T.TextSecondary
            LineNums.Font                   = Enum.Font.GothamMedium
            LineNums.TextSize               = FS(12)
            LineNums.TextXAlignment         = Enum.TextXAlignment.Right
            LineNums.TextYAlignment         = Enum.TextYAlignment.Top
            LineNums.TextWrapped            = false
            LineNums.Parent                 = LineScroll
        
            local LineRule = Instance.new("Frame")
            LineRule.Size             = UDim2.new(0, 1, 0, MIN_H)
            LineRule.Position         = UDim2.new(0, LINE_W, 0, HDR_H + DIV_H)
            LineRule.BackgroundColor3 = T.Stroke
            LineRule.BackgroundTransparency = 0.4
            LineRule.BorderSizePixel  = 0
            LineRule.Parent           = Outer
        
            local ContentScroll = Instance.new("ScrollingFrame")
            ContentScroll.Size                     = UDim2.new(1, -LINE_W, 0, MIN_H)
            ContentScroll.Position                 = UDim2.new(0, LINE_W, 0, HDR_H + DIV_H)
            ContentScroll.BackgroundColor3         = T.SurfaceDeep
            ContentScroll.BackgroundTransparency   = 0
            ContentScroll.BorderSizePixel          = 0
            ContentScroll.ScrollBarThickness       = 3
            ContentScroll.ScrollBarImageColor3     = T.Accent
            ContentScroll.ScrollBarImageTransparency = 0.4
            ContentScroll.CanvasSize               = UDim2.new(0, 0, 0, MIN_H)
            ContentScroll.ScrollingDirection       = Enum.ScrollingDirection.XY
            ContentScroll.ClipsDescendants         = true
            ContentScroll.Parent                   = Outer
        
            local InputBox = Instance.new("TextBox")
            InputBox.Size                   = UDim2.new(0, 500, 0, MIN_H - ES(10))
            InputBox.Position               = UDim2.new(0, ES(4), 0, ES(5))
            InputBox.BackgroundTransparency = 1
            InputBox.AutomaticSize          = Enum.AutomaticSize.Y
            InputBox.MultiLine              = true
            InputBox.TextWrapped            = false
            InputBox.ClearTextOnFocus       = false
            InputBox.PlaceholderText        = Placeholder
            InputBox.PlaceholderColor3      = T.TextSecondary
            InputBox.TextColor3             = T.TextWhite
            InputBox.Font                   = Enum.Font.GothamMedium
            InputBox.TextSize               = FS(12)
            InputBox.TextXAlignment         = Enum.TextXAlignment.Left
            InputBox.TextYAlignment         = Enum.TextYAlignment.Top
            InputBox.Parent                 = ContentScroll
        
            ContentScroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
                LineScroll.CanvasPosition = Vector2.new(0, ContentScroll.CanvasPosition.Y)
            end)
        
            local updateScheduled = false
            local lastText        = ""
            local function UpdateAll()
                if updateScheduled then return end
                updateScheduled = true
                task.delay(0.05, function()
                    updateScheduled = false
    
                    local text = InputBox.Text
                    if text == lastText then return end
                    lastText = text
    
                    local count = 1
                    for _ in text:gmatch("\n") do count = count + 1 end
                    local nums = table.create(count)
                    for i = 1, count do nums[i] = tostring(i) end
                    local lineNumText = table.concat(nums, "\n")
                    LineNums.Text = lineNumText
    
                    local inputH = count * 20 + ES(10)
                    local numH   = inputH
    
                    local longestLine = ""
                    for line in (text .. "\n"):gmatch("([^\n]*)\n") do
                        if #line > #longestLine then
                            longestLine = line
                        end
                    end
                    local maxLineW = TextService:GetTextSize(
                        longestLine ~= "" and longestLine or " ",
                        FS(12),
                        Enum.Font.GothamMedium,
                        Vector2.new(math.huge, math.huge)
                    ).X
    
                    local scrollW  = math.max(ContentScroll.AbsoluteSize.X, 60)
                    local contentH = math.max(inputH + ES(5), MIN_H)
                    local clampedH = math.min(contentH, MAX_H)
                    local canvasW  = math.max(maxLineW + ES(16), scrollW)
    
                    InputBox.Size            = UDim2.new(0, canvasW, 0, inputH)
                    LineNums.Size            = UDim2.new(1, -ES(6), 0, inputH)
    
                    ContentScroll.CanvasSize = UDim2.new(0, canvasW, 0, contentH)
                    ContentScroll.Size       = UDim2.new(1, -LINE_W, 0, clampedH)
    
                    LineScroll.CanvasSize    = UDim2.new(0, 0, 0, contentH)
                    LineScroll.Size          = UDim2.new(0, LINE_W, 0, clampedH)
    
                    LineRule.Size            = UDim2.new(0, 1, 0, clampedH)
    
                    Outer.Size               = UDim2.new(1, 0, 0, TotalH(clampedH))
    
                    Callback(text)
                end)
            end
            
            InputBox:GetPropertyChangedSignal("Text"):Connect(UpdateAll)
        
            InputBox.Focused:Connect(function()
                TweenService:Create(UnderFill, TI_025Q, {Size = UDim2.new(1, 0, 1, 0)}):Play()
            end)
            InputBox.FocusLost:Connect(function()
                Callback(InputBox.Text)
                TweenService:Create(UnderFill, TI_025Q, {Size = UDim2.new(0, 0, 1, 0)}):Play()
            end)
        
            function Element:SetText(val) InputBox.Text = tostring(val) end
            function Element:GetText()    return InputBox.Text          end
        
            return AttachTooltip(TitleLabel, Element)
        end
                
        -- ── SLIDER ────────────────────────────────────────────────────
        function Tab:CreateSlider(Title, Min, Max, Default, Callback, Decimals)
            Decimals = Decimals or 0

            local Element        = {}
            local sliderDisabled = false
            local RowHeight      = ES(38)

            local function RoundValue(v)
                if Decimals == 0 then
                    return math.floor(v)
                end
                local factor = 10 ^ Decimals
                return math.floor(v * factor + 0.5) / factor
            end

            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size             = UDim2.new(1, 0, 0, RowHeight)
            SliderFrame.BackgroundColor3 = T.Surface
            SliderFrame.Parent           = self.Container
            Corner(SliderFrame)
            AddDepthStroke(SliderFrame)

            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Size            = UDim2.new(1, -ES(70), 0, ES(20))
            TitleLabel.Position        = UDim2.new(0, ES(10), 0, ES(4))
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Text            = Title
            TitleLabel.TextColor3      = T.TextPrimary
            TitleLabel.Font            = Enum.Font.GothamMedium
            TitleLabel.TextSize        = FS(12)
            TitleLabel.TextXAlignment  = Enum.TextXAlignment.Left
            TitleLabel.Parent          = SliderFrame

            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Size            = UDim2.new(0, ES(55), 0, ES(20))
            ValueLabel.AnchorPoint     = Vector2.new(1, 0)
            ValueLabel.Position        = UDim2.new(1, -ES(8), 0, ES(4))
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Text            = tostring(RoundValue(Default))
            ValueLabel.TextColor3      = T.Accent
            ValueLabel.Font            = Enum.Font.GothamBold
            ValueLabel.TextSize        = FS(12)
            ValueLabel.TextXAlignment  = Enum.TextXAlignment.Right
            ValueLabel.Parent          = SliderFrame

            local trackY = ES(28)
            local SliderBG = Instance.new("Frame")
            SliderBG.Size             = UDim2.new(1, -ES(20), 0, ES(4))
            SliderBG.Position         = UDim2.new(0, ES(10), 0, trackY)
            SliderBG.BackgroundColor3 = T.SurfaceDeep
            SliderBG.Parent           = SliderFrame
            Corner(SliderBG)

            local SliderFill = Instance.new("Frame")
            SliderFill.Size             = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
            SliderFill.BackgroundColor3 = T.Accent
            SliderFill.BorderSizePixel  = 0
            SliderFill.Parent           = SliderBG
            Corner(SliderFill)

            local SliderBtn = Instance.new("TextButton")
            SliderBtn.Size               = UDim2.new(1, 0, 1, 0)
            SliderBtn.BackgroundTransparency = 1
            SliderBtn.Text               = ""
            SliderBtn.ZIndex             = SliderFrame.ZIndex + 5
            SliderBtn.Parent             = SliderFrame

            local function UpdateSlider()
                local mousePos = UserInputService:GetMouseLocation().X
                local barPos   = SliderBG.AbsolutePosition.X
                local barWidth = SliderBG.AbsoluteSize.X
                local pct      = math.clamp((mousePos - barPos) / barWidth, 0, 1)
                local value    = RoundValue(Min + (Max - Min) * pct)
                SliderFill.Size = UDim2.new(pct, 0, 1, 0)
                ValueLabel.Text = tostring(value)
                Callback(value)
            end

            function Element:SetValue(value)
                value = math.clamp(RoundValue(value), Min, Max)
                local pct = (value - Min) / (Max - Min)
                SliderFill.Size = UDim2.new(pct, 0, 1, 0)
                ValueLabel.Text = tostring(value)
            end

            function Element:SetDisabled(state)
                sliderDisabled = state
                TweenService:Create(SliderFill, TI_02, {
                    BackgroundColor3 = state and T.TextSecondary or T.Accent
                }):Play()
                TweenService:Create(SliderBG, TI_02, {
                    BackgroundTransparency = state and 0.5 or 0
                }):Play()
                ValueLabel.TextColor3 = state and T.TextSecondary or T.Accent
                TitleLabel.TextColor3 = state and T.TextSecondary or T.TextPrimary
                SliderBtn.Active      = not state
            end

            local sliding = false
            SliderBtn.InputBegan:Connect(function(input)
                if sliderDisabled then return end
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliding = true
                    UpdateSlider()
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliding = false
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if sliding and not sliderDisabled and input.UserInputType == Enum.UserInputType.MouseMovement then
                    UpdateSlider()
                end
            end)

            return AttachTooltip(TitleLabel, Element)
        end

        -- ── RANGE SLIDER ──────────────────────────────────────────────
        function Tab:CreateRangeSlider(Title, Min, Max, DefaultLow, DefaultHigh, Callback, Decimals)
            Decimals = Decimals or 0

            local Element        = {}
            local sliderDisabled = false
            local RowHeight      = ES(38)

            local currentLow  = math.clamp(DefaultLow,  Min, Max)
            local currentHigh = math.clamp(DefaultHigh, Min, Max)
            if currentLow > currentHigh then
                currentLow, currentHigh = currentHigh, currentLow
            end

            local function RoundValue(v)
                if Decimals == 0 then
                    return math.floor(v)
                end
                local factor = 10 ^ Decimals
                return math.floor(v * factor + 0.5) / factor
            end

            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size             = UDim2.new(1, 0, 0, RowHeight)
            SliderFrame.BackgroundColor3 = T.Surface
            SliderFrame.Parent           = self.Container
            Corner(SliderFrame)
            AddDepthStroke(SliderFrame)

            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Size                   = UDim2.new(1, -ES(110), 0, ES(20))
            TitleLabel.Position               = UDim2.new(0, ES(10), 0, ES(4))
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Text                   = Title
            TitleLabel.TextColor3             = T.TextPrimary
            TitleLabel.Font                   = Enum.Font.GothamMedium
            TitleLabel.TextSize               = FS(12)
            TitleLabel.TextXAlignment         = Enum.TextXAlignment.Left
            TitleLabel.Parent                 = SliderFrame

            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Size                   = UDim2.new(0, ES(100), 0, ES(20))
            ValueLabel.AnchorPoint            = Vector2.new(1, 0)
            ValueLabel.Position               = UDim2.new(1, -ES(8), 0, ES(4))
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.TextColor3             = T.Accent
            ValueLabel.Font                   = Enum.Font.GothamBold
            ValueLabel.TextSize               = FS(12)
            ValueLabel.TextXAlignment         = Enum.TextXAlignment.Right
            ValueLabel.Parent                 = SliderFrame

            local trackY  = ES(28)
            local SliderBG = Instance.new("Frame")
            SliderBG.Size             = UDim2.new(1, -ES(20), 0, ES(4))
            SliderBG.Position         = UDim2.new(0, ES(10), 0, trackY)
            SliderBG.BackgroundColor3 = T.SurfaceDeep
            SliderBG.ClipsDescendants = false
            SliderBG.Parent           = SliderFrame
            Corner(SliderBG)

            local SliderFill = Instance.new("Frame")
            SliderFill.BackgroundColor3 = T.Accent
            SliderFill.BorderSizePixel  = 0
            SliderFill.ZIndex           = SliderBG.ZIndex + 1
            SliderFill.Parent           = SliderBG
            Corner(SliderFill)

            local KNOB_SIZE = ES(8)

            local function MakeKnob(zIndex)
                local k = Instance.new("Frame")
                k.Size             = UDim2.new(0, KNOB_SIZE, 0, KNOB_SIZE)
                k.AnchorPoint      = Vector2.new(0.5, 0.5)
                k.Position         = UDim2.new(0, 0, 0.5, 0)
                k.BackgroundColor3 = T.Accent
                k.BorderSizePixel  = 0
                k.ZIndex           = zIndex
                k.Parent           = SliderBG
                Corner(k)
                return k
            end

            local KnobLow  = MakeKnob(SliderBG.ZIndex + 3)
            local KnobHigh = MakeKnob(SliderBG.ZIndex + 3)

            local SliderBtn = Instance.new("TextButton")
            SliderBtn.Size               = UDim2.new(1, 0, 1, 0)
            SliderBtn.BackgroundTransparency = 1
            SliderBtn.Text               = ""
            SliderBtn.ZIndex             = SliderFrame.ZIndex + 5
            SliderBtn.Parent             = SliderFrame

            local function UpdateVisuals()
                local lowPct  = (currentLow  - Min) / (Max - Min)
                local highPct = (currentHigh - Min) / (Max - Min)

                -- Fill between the two handles
                SliderFill.Position = UDim2.new(lowPct,  0, 0, 0)
                SliderFill.Size     = UDim2.new(highPct - lowPct, 0, 1, 0)

                -- Knobs sit at the ends of the fill
                KnobLow.Position  = UDim2.new(lowPct,  0, 0.5, 0)
                KnobHigh.Position = UDim2.new(highPct, 0, 0.5, 0)

                -- Value readout
                ValueLabel.Text = tostring(RoundValue(currentLow))
                    .. " — "
                    .. tostring(RoundValue(currentHigh))
            end

            UpdateVisuals()

            local dragging = nil

            local function PctFromMouse()
                local mx       = UserInputService:GetMouseLocation().X
                local barLeft  = SliderBG.AbsolutePosition.X
                local barWidth = SliderBG.AbsoluteSize.X
                return math.clamp((mx - barLeft) / barWidth, 0, 1)
            end

            SliderBtn.InputBegan:Connect(function(input)
                if sliderDisabled then return end
                if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

                local pct     = PctFromMouse()
                local lowPct  = (currentLow  - Min) / (Max - Min)
                local highPct = (currentHigh - Min) / (Max - Min)

                -- Grab whichever handle is closer to the click
                if math.abs(pct - lowPct) <= math.abs(pct - highPct) then
                    dragging = "low"
                else
                    dragging = "high"
                end

                -- Apply immediately so a click without drag still works
                local value = RoundValue(Min + (Max - Min) * pct)
                if dragging == "low" then
                    currentLow = math.min(value, currentHigh)
                else
                    currentHigh = math.max(value, currentLow)
                end
                UpdateVisuals()
                Callback(currentLow, currentHigh)
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = nil
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if not dragging or sliderDisabled then return end
                if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end

                local value = RoundValue(Min + (Max - Min) * PctFromMouse())

                if dragging == "low" then
                    -- Low handle cannot cross above the high handle
                    currentLow = math.clamp(value, Min, currentHigh)
                else
                    -- High handle cannot cross below the low handle
                    currentHigh = math.clamp(value, currentLow, Max)
                end
                UpdateVisuals()
                Callback(currentLow, currentHigh)
            end)

            function Element:SetValue(low, high)
                currentLow  = math.clamp(RoundValue(low),  Min, Max)
                currentHigh = math.clamp(RoundValue(high), Min, Max)
                if currentLow > currentHigh then
                    currentLow, currentHigh = currentHigh, currentLow
                end
                UpdateVisuals()
            end

            function Element:SetDisabled(state)
                sliderDisabled = state

                local fillColor = state and T.TextSecondary or T.Accent
                TweenService:Create(SliderFill, TI_02, { BackgroundColor3 = fillColor }):Play()
                TweenService:Create(KnobLow,   TI_02, { BackgroundColor3 = fillColor }):Play()
                TweenService:Create(KnobHigh,  TI_02, { BackgroundColor3 = fillColor }):Play()
                TweenService:Create(SliderBG,  TI_02, {
                    BackgroundTransparency = state and 0.5 or 0
                }):Play()

                ValueLabel.TextColor3 = state and T.TextSecondary or T.Accent
                TitleLabel.TextColor3 = state and T.TextSecondary or T.TextPrimary
                SliderBtn.Active      = not state
            end

            return AttachTooltip(TitleLabel, Element)
        end
        
        -- ── KEYBIND ───────────────────────────────────────────
        function Tab:CreateKeybind(Title, Default, Callback)
            local Element   = {}
            local KeyName   = (typeof(Default) == "EnumItem") and Default.Name or Default.UserInputType.Name
            local RowHeight = ES(28)

            local KeybindFrame = Instance.new("Frame")
            KeybindFrame.Size             = UDim2.new(1, 0, 0, RowHeight)
            KeybindFrame.BackgroundColor3 = T.Surface
            KeybindFrame.Parent           = self.Container
            Corner(KeybindFrame)
            AddDepthStroke(KeybindFrame)

            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Size            = UDim2.new(0.65, 0, 1, 0)
            TitleLabel.Position        = UDim2.new(0, ES(10), 0, 0)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Text            = Title
            TitleLabel.TextColor3      = T.TextPrimary
            TitleLabel.Font            = Enum.Font.GothamMedium
            TitleLabel.TextSize        = FS(12)
            TitleLabel.TextXAlignment  = Enum.TextXAlignment.Left
            TitleLabel.Parent          = KeybindFrame

            local BindBtn = Instance.new("TextButton")
            BindBtn.Size             = UDim2.new(0, ES(70), 0, ES(20))
            BindBtn.AnchorPoint      = Vector2.new(1, 0.5)
            BindBtn.Position         = UDim2.new(1, -ES(8), 0.5, 0)
            BindBtn.BackgroundColor3 = T.SurfaceDeep
            BindBtn.Text             = KeyName
            BindBtn.TextColor3       = T.TextWhite
            BindBtn.Font             = Enum.Font.GothamBold
            BindBtn.TextSize         = FS(11)
            BindBtn.Parent           = KeybindFrame
            Corner(BindBtn, UDim.new(0, 4))
            AddDepthStroke(BindBtn)

            BindBtn.MouseButton1Click:Connect(function()
                BindBtn.Text = "..."
                local conn
                conn = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        KeyName = input.KeyCode.Name; BindBtn.Text = KeyName; conn:Disconnect()
                    elseif input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3 then
                        KeyName = input.UserInputType.Name; BindBtn.Text = KeyName; conn:Disconnect()
                    end
                end)
            end)
            UserInputService.InputBegan:Connect(function(input, processed)
                if not processed then
                    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == KeyName then
                        Callback()
                    elseif input.UserInputType.Name == KeyName then
                        Callback()
                    end
                end
            end)

            return AttachTooltip(TitleLabel, Element)
        end

        -- ── INFO BOX (v2) ─────────────────────────────────────────────
        function Tab:CreateInfoBox()
            local InfoBox    = {}
            local layoutOrder = 0

            local Card = Instance.new("Frame")
            Card.Name             = "InfoBox"
            Card.Size             = UDim2.new(1, 0, 0, 0)
            Card.AutomaticSize    = Enum.AutomaticSize.Y
            Card.BackgroundColor3 = T.Surface
            Card.BorderSizePixel  = 0
            Card.ClipsDescendants = false
            Card.Parent           = self.Container
            Corner(Card)
            AddDepthStroke(Card)

            local Inner = Instance.new("Frame")
            Inner.Name                = "Inner"
            Inner.Size                = UDim2.new(1, 0, 0, 0)
            Inner.AutomaticSize       = Enum.AutomaticSize.Y
            Inner.BackgroundTransparency = 1
            Inner.Parent              = Card

            local InnerPad = Instance.new("UIPadding", Inner)
            InnerPad.PaddingLeft   = UDim.new(0, ES(10))
            InnerPad.PaddingRight  = UDim.new(0, ES(10))
            InnerPad.PaddingTop    = UDim.new(0, ES(6))
            InnerPad.PaddingBottom = UDim.new(0, ES(6))

            local InnerLayout = Instance.new("UIListLayout", Inner)
            InnerLayout.SortOrder     = Enum.SortOrder.LayoutOrder
            InnerLayout.FillDirection = Enum.FillDirection.Vertical
            InnerLayout.Padding       = UDim.new(0, ES(3))

            function InfoBox:AddText(content, opts)
                opts = opts or {}
                layoutOrder = layoutOrder + 1

                local resolvedFont = opts.Font or Enum.Font.Gotham
                if opts.Bold then resolvedFont = Enum.Font.GothamBold end

                local resolvedContent = tostring(content or "")
                local useRichText     = opts.RichText or false
                if opts.Italic then
                    resolvedContent = "<i>" .. resolvedContent .. "</i>"
                    useRichText     = true
                end

                local useTruncate = opts.Truncate or Enum.TextTruncate.None
                local useWrap     = (opts.Wrap ~= false)
                if useTruncate ~= Enum.TextTruncate.None then
                    useWrap = false
                end

                local Label = Instance.new("TextLabel")
                Label.Name                = "InfoText_" .. layoutOrder
                Label.LayoutOrder         = layoutOrder
                Label.Size                = UDim2.new(1, 0, 0, 0)
                Label.AutomaticSize       = Enum.AutomaticSize.Y
                Label.BackgroundTransparency = 1
                Label.Text                = resolvedContent
                Label.Font                = resolvedFont
                Label.TextSize            = FS(opts.Size or 12)
                Label.TextColor3          = opts.Color or T.TextPrimary
                Label.TextXAlignment      = opts.XAlignment or Enum.TextXAlignment.Left
                Label.TextYAlignment      = opts.YAlignment or Enum.TextYAlignment.Center
                Label.TextWrapped         = useWrap
                Label.TextTruncate        = useTruncate
                Label.RichText            = useRichText
                Label.Rotation            = opts.Rotation or 0
                Label.TextTransparency    = opts.Opacity ~= nil and (1 - opts.Opacity) or 0
                Label.Parent              = Inner

                if opts.PaddingTop or opts.PaddingBottom or opts.PaddingLeft or opts.PaddingRight then
                    local Pad = Instance.new("UIPadding", Label)
                    Pad.PaddingTop    = UDim.new(0, ES(opts.PaddingTop    or 0))
                    Pad.PaddingBottom = UDim.new(0, ES(opts.PaddingBottom or 0))
                    Pad.PaddingLeft   = UDim.new(0, ES(opts.PaddingLeft   or 0))
                    Pad.PaddingRight  = UDim.new(0, ES(opts.PaddingRight  or 0))
                end

                local Handle = {}

                function Handle:Set(text)
                    local str = tostring(text)
                    if opts.Italic then str = "<i>" .. str .. "</i>" end
                    Label.Text = str
                end

                function Handle:SetColor(color)    Label.TextColor3     = color                            end
                function Handle:SetSize(pts)        Label.TextSize       = FS(pts)                         end
                function Handle:SetFont(font)       Label.Font           = font                            end
                function Handle:SetRotation(deg)    Label.Rotation       = deg                             end
                function Handle:SetOpacity(value)   Label.TextTransparency = 1 - math.clamp(value, 0, 1)  end
                function Handle:SetXAlignment(a)    Label.TextXAlignment = a                               end
                function Handle:SetYAlignment(a)    Label.TextYAlignment = a                               end
                function Handle:SetWrap(state)      Label.TextWrapped    = state                           end
                function Handle:SetRichText(state)  Label.RichText       = state                           end
                function Handle:SetVisible(state)   Label.Visible        = state                           end
                function Handle:Destroy()           Label:Destroy()                                        end

                function Handle:SetTruncate(mode)
                    Label.TextTruncate = mode
                    if mode ~= Enum.TextTruncate.None then
                        Label.TextWrapped = false
                    end
                end

                function Handle:SetPadding(top, bottom, left, right)
                    local pad = Label:FindFirstChildOfClass("UIPadding")
                    if not pad then pad = Instance.new("UIPadding", Label) end
                    pad.PaddingTop    = UDim.new(0, ES(top    or 0))
                    pad.PaddingBottom = UDim.new(0, ES(bottom or 0))
                    pad.PaddingLeft   = UDim.new(0, ES(left   or 0))
                    pad.PaddingRight  = UDim.new(0, ES(right  or 0))
                end

                function Handle:Tween(props, duration, style, direction)
                    TweenService:Create(
                        Label,
                        TweenInfo.new(
                            duration  or 0.25,
                            style     or Enum.EasingStyle.Quad,
                            direction or Enum.EasingDirection.Out
                        ),
                        props
                    ):Play()
                end

                return Handle
            end

            function InfoBox:AddDivider(color, thickness)
                layoutOrder = layoutOrder + 1
                local Line = Instance.new("Frame")
                Line.LayoutOrder        = layoutOrder
                Line.Size               = UDim2.new(1, 0, 0, math.max(1, thickness or 1))
                Line.BackgroundColor3   = color or T.Stroke
                Line.BorderSizePixel    = 0
                Line.Parent             = Inner
            end

            function InfoBox:AddSpacer(height)
                layoutOrder = layoutOrder + 1
                local Gap = Instance.new("Frame")
                Gap.LayoutOrder            = layoutOrder
                Gap.Size                   = UDim2.new(1, 0, 0, ES(height or 4))
                Gap.BackgroundTransparency = 1
                Gap.Parent                 = Inner
            end

            function InfoBox:SetPadding(top, bottom, left, right)
                InnerPad.PaddingTop    = UDim.new(0, ES(top    or 6))
                InnerPad.PaddingBottom = UDim.new(0, ES(bottom or 6))
                InnerPad.PaddingLeft   = UDim.new(0, ES(left   or 10))
                InnerPad.PaddingRight  = UDim.new(0, ES(right  or 10))
            end

            function InfoBox:SetSpacing(pts)
                InnerLayout.Padding = UDim.new(0, ES(pts))
            end

            function InfoBox:SetBackground(color)
                Card.BackgroundColor3 = color
            end

            function InfoBox:SetStroke(color, thickness)
                local stroke = Card:FindFirstChildOfClass("UIStroke")
                if stroke then
                    stroke.Color     = color     or T.Stroke
                    stroke.Thickness = thickness or 1
                end
            end

            return InfoBox
        end

        -- ── IMAGE SELECTOR ────────────────────────────────────
        function Tab:CreateImageSelector(Title, Config2, Callback)
            local Element = {Selected = {}}
            Config2 = Config2 or {}
            Element._scroll = Scrol
            local Multi       = Config2.MultiSelect or false
            local SlotSize    = Config2.SlotSize or UDim2.new(0, ES(70), 0, ES(70))
            local VisibleRows = Config2.VisibleRows or 2

            local SCROLLBAR_W   = 4
            local FADE_H        = ES(16)
            local TopPadding    = ES(35)
            local BottomPadding = ES(10)
            local CellPaddingX  = ES(8)
            local CellPaddingY  = ES(8)
            local ScrollHeight  = (SlotSize.Y.Offset * VisibleRows)
                                + (CellPaddingY * (VisibleRows - 1))
                                + 6
            local TotalHeight   = TopPadding + ScrollHeight + BottomPadding

            local CLIP_WIDTH = SlotSize.X.Offset - ES(6)

            local SlotRegistry = {}

            local SelectorFrame = Instance.new("Frame")
            SelectorFrame.Name             = Title .. "_ImageSelector"
            SelectorFrame.Size             = UDim2.new(1, 0, 0, TotalHeight)
            SelectorFrame.BackgroundColor3 = T.Surface
            SelectorFrame.Parent           = self.Container
            Corner(SelectorFrame)

            local FrameStroke = Instance.new("UIStroke", SelectorFrame)
            FrameStroke.Color     = T.Stroke
            FrameStroke.Thickness = 1

            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Size                   = UDim2.new(0.5, 0, 0, ES(20))
            TitleLabel.Position               = UDim2.new(0, ES(10), 0, ES(8))
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Text                   = Title
            TitleLabel.TextColor3             = T.TextPrimary
            TitleLabel.Font                   = Enum.Font.GothamMedium
            TitleLabel.TextSize               = FS(13)
            TitleLabel.TextXAlignment         = Enum.TextXAlignment.Left
            TitleLabel.Parent                 = SelectorFrame
    
            local SearchBox = Instance.new("TextBox")
            SearchBox.Name              = "SearchBox"
            SearchBox.Size              = UDim2.new(0, ES(150), 0, ES(20))
            SearchBox.AnchorPoint       = Vector2.new(1, 0)
            SearchBox.Position          = UDim2.new(1, -ES(10), 0, ES(8))
            SearchBox.BackgroundTransparency = 1
            SearchBox.BorderSizePixel   = 0
            SearchBox.PlaceholderText   = "Search…"
            SearchBox.PlaceholderColor3 = T.TextSecondary
            SearchBox.Text              = ""
            SearchBox.TextColor3        = T.TextWhite
            SearchBox.TextXAlignment    = Enum.TextXAlignment.Right
            SearchBox.Font              = Enum.Font.Gotham
            SearchBox.TextSize          = FS(11)
            SearchBox.ClearTextOnFocus  = false
            SearchBox.ClipsDescendants  = true
            SearchBox.Parent            = SelectorFrame
            
            local SearchPad = Instance.new("UIPadding", SearchBox)
            SearchPad.PaddingLeft  = UDim.new(0, ES(6))
            SearchPad.PaddingRight = UDim.new(0, ES(6))
            
            local SearchUnderTrack = Instance.new("Frame")
            SearchUnderTrack.Size             = UDim2.new(0, ES(150), 0, 1)
            SearchUnderTrack.AnchorPoint      = Vector2.new(1, 0)
            SearchUnderTrack.Position         = UDim2.new(1, -ES(10), 0, ES(28))
            SearchUnderTrack.BackgroundColor3 = T.Stroke
            SearchUnderTrack.BorderSizePixel  = 0
            SearchUnderTrack.Parent           = SelectorFrame
            
            local SearchUnderFill = Instance.new("Frame")
            SearchUnderFill.Size             = UDim2.new(0, 0, 1, 0)
            SearchUnderFill.AnchorPoint      = Vector2.new(0.5, 0)
            SearchUnderFill.Position         = UDim2.new(0.5, 0, 0, 0)
            SearchUnderFill.BackgroundColor3 = T.Accent
            SearchUnderFill.BorderSizePixel  = 0
            SearchUnderFill.Parent           = SearchUnderTrack
            
            SearchBox.Focused:Connect(function()
                TweenService:Create(SearchUnderFill, TI_025Q, { Size = UDim2.new(1, 0, 1, 0) }):Play()
            end)
            SearchBox.FocusLost:Connect(function()
                TweenService:Create(SearchUnderFill, TI_025Q, { Size = UDim2.new(0, 0, 1, 0) }):Play()
            end)

            local Scroll = Instance.new("ScrollingFrame")
            Scroll.Size                       = UDim2.new(1, -ES(20), 0, ScrollHeight)
            Scroll.Position                   = UDim2.new(0, ES(10), 0, TopPadding)
            Scroll.BackgroundTransparency     = 1
            Scroll.BorderSizePixel            = 0
            Scroll.CanvasSize                 = UDim2.new(0, 0, 0, 0)
            Scroll.ScrollBarThickness         = SCROLLBAR_W
            Scroll.ScrollBarImageColor3       = T.Accent
            Scroll.ScrollBarImageTransparency = 0
            Scroll.ScrollingDirection         = Enum.ScrollingDirection.Y
            Scroll.ClipsDescendants           = true
            Scroll.Parent                     = SelectorFrame

            local Layout = Instance.new("UIGridLayout", Scroll)
            Layout.CellSize            = SlotSize
            Layout.CellPadding         = UDim2.new(0, CellPaddingX, 0, CellPaddingY)
            Layout.SortOrder           = Enum.SortOrder.LayoutOrder
            Layout.FillDirection       = Enum.FillDirection.Horizontal
            Layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
            Layout.VerticalAlignment   = Enum.VerticalAlignment.Top

            local Padding = Instance.new("UIPadding", Scroll)
            Padding.PaddingLeft   = UDim.new(0, 2)
            Padding.PaddingTop    = UDim.new(0, ES(3))
            Padding.PaddingBottom = UDim.new(0, ES(3))
            Padding.PaddingRight  = UDim.new(0, SCROLLBAR_W + 2)

            Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + ES(6))
            end)

            local FADE_W_OFFSET = -ES(20) - SCROLLBAR_W - 2
            
            local function MakeVerticalFade(isBottom)
                local Fade = Instance.new("Frame")
                Fade.Size                   = UDim2.new(1, FADE_W_OFFSET, 0, FADE_H)
                Fade.AnchorPoint            = Vector2.new(0, isBottom and 1 or 0)
                Fade.Position               = UDim2.new(0, ES(10), 0,
                    isBottom and (TopPadding + ScrollHeight) or TopPadding)
                Fade.BackgroundColor3       = T.Surface
                Fade.BackgroundTransparency = 0
                Fade.BorderSizePixel        = 0
                Fade.ZIndex                 = 5
                Fade.Parent                 = SelectorFrame
                local Grad = Instance.new("UIGradient", Fade)
                Grad.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1),
                })
                Grad.Rotation = isBottom and 270 or 90
            end

            MakeVerticalFade(false)
            MakeVerticalFade(true)

            local function ApplySearch(query)
                query = query:lower():gsub("^%s+", ""):gsub("%s+$", "")
                for _, entry in ipairs(SlotRegistry) do
                    entry.slot.Visible = query == ""
                        or entry.title:lower():find(query, 1, true) ~= nil
                end
                task.defer(function()
                    Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + ES(6))
                end)
            end

            SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                ApplySearch(SearchBox.Text)
            end)

            function Element:AddSlot(ID, SlotTitle, SlotSubText)
                local SlotObj = { _enabled = true }

                local Slot = Instance.new("TextButton")
                Slot.BackgroundColor3 = T.SurfaceDeep
                Slot.Text             = ""
                Slot.ZIndex           = 2
                Slot.Parent           = Scroll
                Corner(Slot)

                local Stroke = Instance.new("UIStroke", Slot)
                Stroke.Color           = T.Stroke
                Stroke.Thickness       = 1.2
                Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

                local DisabledOverlay = Instance.new("Frame")
                DisabledOverlay.Name                  = "DisabledOverlay"
                DisabledOverlay.Size                  = UDim2.new(1, 0, 1, 0)
                DisabledOverlay.BackgroundColor3      = Color3.fromRGB(0, 0, 0)
                DisabledOverlay.BackgroundTransparency = 0.6
                DisabledOverlay.BorderSizePixel        = 0
                DisabledOverlay.ZIndex                 = 10
                DisabledOverlay.Visible                = false
                DisabledOverlay.Parent                 = Slot
                Corner(DisabledOverlay)

                local Image = Instance.new("ImageLabel")
                Image.Size                   = UDim2.new(0.75, 0, 0.75, 0)
                Image.Position               = UDim2.new(0.5, 0, 0.5, 0)
                Image.AnchorPoint            = Vector2.new(0.5, 0.5)
                Image.BackgroundTransparency = 1
                Image.Image                  = ID
                Image.ZIndex                 = 2
                Image.Parent                 = Slot

                SlotObj.ImageLabel = Image

                if SlotTitle or SlotSubText then
                    Image.Position = UDim2.new(0.5, 0, 0.35, 0)
                    Image.Size     = UDim2.new(0.55, 0, 0.55, 0)
                end

                local TitleFades = {}

                if SlotTitle then
                    local TitleClip = Instance.new("Frame")
                    TitleClip.Size                   = UDim2.new(1, -ES(6), 0, FS(16))
                    TitleClip.Position               = UDim2.new(0, ES(3), 0.65, 0)
                    TitleClip.BackgroundTransparency = 1
                    TitleClip.ClipsDescendants       = true
                    TitleClip.ZIndex                 = 2
                    TitleClip.Parent                 = Slot

                    local textW = TextService:GetTextSize(
                        SlotTitle,
                        FS(12),
                        Enum.Font.GothamMedium,
                        Vector2.new(math.huge, math.huge)
                    ).X

                    if textW <= CLIP_WIDTH then
                        local Txt = Instance.new("TextLabel")
                        Txt.Size                   = UDim2.new(1, 0, 1, 0)
                        Txt.BackgroundTransparency = 1
                        Txt.Text                   = SlotTitle
                        Txt.TextColor3             = T.TextPrimary
                        Txt.Font                   = Enum.Font.GothamMedium
                        Txt.TextSize               = FS(12)
                        Txt.ZIndex                 = 2
                        Txt.Parent                 = TitleClip
                    else
                        local GAP    = ES(18)
                        local totalW = textW + GAP

                        local Scroller = Instance.new("Frame")
                        Scroller.Size                   = UDim2.new(0, totalW * 2, 1, 0)
                        Scroller.Position               = UDim2.new(0, 0, 0, 0)
                        Scroller.BackgroundTransparency = 1
                        Scroller.ZIndex                 = 2
                        Scroller.Parent                 = TitleClip

                        for i = 0, 1 do
                            local Lbl = Instance.new("TextLabel")
                            Lbl.Size                   = UDim2.new(0, textW, 1, 0)
                            Lbl.Position               = UDim2.new(0, i * totalW, 0, 0)
                            Lbl.BackgroundTransparency = 1
                            Lbl.Text                   = SlotTitle
                            Lbl.TextColor3             = T.TextPrimary
                            Lbl.Font                   = Enum.Font.GothamMedium
                            Lbl.TextSize               = FS(12)
                            Lbl.TextXAlignment         = Enum.TextXAlignment.Left
                            Lbl.ZIndex                 = 2
                            Lbl.Parent                 = Scroller
                        end

                        local TITLE_FADE_W = ES(10)
                        local function MakeTitleFade(anchorX, posX, rotated)
                            local F = Instance.new("Frame")
                            F.Size             = UDim2.new(0, TITLE_FADE_W, 1, 0)
                            F.AnchorPoint      = Vector2.new(anchorX, 0)
                            F.Position         = UDim2.new(posX, 0, 0, 0)
                            F.BackgroundColor3 = T.SurfaceDeep
                            F.BorderSizePixel  = 0
                            F.ZIndex           = 4
                            F.Parent           = TitleClip
                            local G = Instance.new("UIGradient", F)
                            G.Transparency = NumberSequence.new({
                                NumberSequenceKeypoint.new(0, 0),
                                NumberSequenceKeypoint.new(1, 1),
                            })
                            if rotated then G.Rotation = 180 end
                            table.insert(TitleFades, F)
                        end
                        MakeTitleFade(0, 0, false)
                        MakeTitleFade(1, 1, true)

                        local scrollDuration = totalW / 28
                        task.spawn(function()
                            task.wait(1.2)
                            while Slot.Parent do
                                local tween = TweenService:Create(
                                    Scroller,
                                    TweenInfo.new(scrollDuration, Enum.EasingStyle.Linear),
                                    { Position = UDim2.new(0, -totalW, 0, 0) }
                                )
                                tween:Play()
                                tween.Completed:Wait()
                                if not Slot.Parent then break end
                                Scroller.Position = UDim2.new(0, 0, 0, 0)
                            end
                        end)
                    end
                end

                if SlotSubText then
                    local SubTxt = Instance.new("TextLabel")
                    SubTxt.Size                   = UDim2.new(1, 0, 0, FS(12))
                    SubTxt.Position               = UDim2.new(0, 0, 0.82, 0)
                    SubTxt.BackgroundTransparency = 1
                    SubTxt.Text                   = SlotSubText
                    SubTxt.TextColor3             = T.Success
                    SubTxt.Font                   = Enum.Font.GothamBold
                    SubTxt.TextSize               = FS(11)
                    SubTxt.ZIndex                 = 2
                    SubTxt.Parent                 = Slot
                end

                local registryEntry = {
                    slot       = Slot,
                    title      = SlotTitle or "",
                    titleFades = TitleFades,
                }
                table.insert(SlotRegistry, registryEntry)

                Slot.MouseButton1Click:Connect(function()
                    if not SlotObj._enabled then return end

                    local isSelected = (Slot.BackgroundColor3 == T.Accent)

                    if not Multi then
                        for _, entry in ipairs(SlotRegistry) do
                            if entry.slot ~= Slot then
                                TweenService:Create(entry.slot, TI_02, {BackgroundColor3 = T.SurfaceDeep}):Play()
                                local s = entry.slot:FindFirstChildOfClass("UIStroke")
                                if s then s.Color = T.Stroke end
                                for _, fade in ipairs(entry.titleFades) do
                                    TweenService:Create(fade, TI_02, {BackgroundColor3 = T.SurfaceDeep}):Play()
                                end
                            end
                        end
                        Element.Selected = {SlotTitle or ID}
                    else
                        if isSelected then
                            for i, v in ipairs(Element.Selected) do
                                if v == (SlotTitle or ID) then
                                    table.remove(Element.Selected, i)
                                    break
                                end
                            end
                        else
                            table.insert(Element.Selected, SlotTitle or ID)
                        end
                    end

                    local targetColor = isSelected and T.SurfaceDeep or T.Accent
                    local strokeColor = isSelected and T.Stroke      or T.TextWhite

                    TweenService:Create(Slot, TI_02, {BackgroundColor3 = targetColor}):Play()
                    Stroke.Color = strokeColor

                    for _, fade in ipairs(TitleFades) do
                        TweenService:Create(fade, TI_02, {BackgroundColor3 = targetColor}):Play()
                    end

                    Callback(Multi and Element.Selected or Element.Selected[1])
                end)

                function SlotObj:SetEnabled(enabled)
                    self._enabled = enabled
                    DisabledOverlay.Visible = not enabled
                    if not enabled and Slot.BackgroundColor3 == T.Accent then
                        TweenService:Create(Slot, TI_02, {BackgroundColor3 = T.SurfaceDeep}):Play()
                        Stroke.Color = T.Stroke
                        for _, fade in ipairs(TitleFades) do
                            TweenService:Create(fade, TI_02, {BackgroundColor3 = T.SurfaceDeep}):Play()
                        end
                        for i, v in ipairs(Element.Selected) do
                            if v == (SlotTitle or ID) then
                                table.remove(Element.Selected, i)
                                break
                            end
                        end
                        Callback(Multi and Element.Selected or Element.Selected[1])
                    end
                end

                ApplySearch(SearchBox.Text)

                return SlotObj
            end

            return Element
        end

        -- ── DROPDOWN ──────────────────────────────────────────────────────
        function Tab:CreateDropdown(Title, Options, Default, Callback)
            local Element      = {}
            local dropDisabled    = false
            local disabledOptions = {}
            local optionOverlays  = {}
            local RowHeight    = ES(28)
            local OptHeight    = ES(22)

            local function IsColorMode(opts)
                if not opts or #opts == 0 then return false end
                local first = opts[1]
                return typeof(first) == "Color3"
                    or (type(first) == "table" and typeof(first.Color) == "Color3")
            end

            local colorMode = IsColorMode(Options)

            local function Normalise(opt)
                if not colorMode then return opt end
                if typeof(opt) == "Color3" then return { Name = "", Color = opt } end
                return opt
            end

            local Selected = Default and Normalise(Default) or (Options[1] and Normalise(Options[1]))

            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Size             = UDim2.new(1, 0, 0, RowHeight)
            DropdownFrame.BackgroundColor3 = T.Surface
            DropdownFrame.ClipsDescendants = true
            DropdownFrame.Parent           = self.Container
            Corner(DropdownFrame)
            AddDepthStroke(DropdownFrame)

            local Header = Instance.new("TextButton")
            Header.Size                   = UDim2.new(1, 0, 0, RowHeight)
            Header.BackgroundTransparency = 1
            Header.Text                   = ""
            Header.Parent                 = DropdownFrame

            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Size            = UDim2.new(0.6, 0, 1, 0)
            TitleLabel.Position        = UDim2.new(0, ES(10), 0, 0)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Text            = Title
            TitleLabel.TextColor3      = T.TextPrimary
            TitleLabel.Font            = Enum.Font.GothamMedium
            TitleLabel.TextSize        = FS(12)
            TitleLabel.TextXAlignment  = Enum.TextXAlignment.Left
            TitleLabel.Parent          = Header

            local SelectedLabel  = nil
            local SelectedSwatch = nil
            local SelectedName   = nil

            if colorMode then
                SelectedSwatch = Instance.new("Frame")
                SelectedSwatch.Size             = UDim2.new(0, ES(14), 0, ES(14))
                SelectedSwatch.AnchorPoint      = Vector2.new(1, 0.5)
                SelectedSwatch.Position         = UDim2.new(1, -ES(10), 0.5, 0)
                SelectedSwatch.BorderSizePixel  = 0
                SelectedSwatch.BackgroundColor3 = (Selected and Selected.Color) or Color3.new(1,1,1)
                SelectedSwatch.Parent           = Header
                Corner(SelectedSwatch, UDim.new(0, 3))
                local SwStroke = Instance.new("UIStroke", SelectedSwatch)
                SwStroke.Color = T.Stroke; SwStroke.Thickness = 1

                SelectedName = Instance.new("TextLabel")
                SelectedName.Size            = UDim2.new(0.35, 0, 1, 0)
                SelectedName.AnchorPoint     = Vector2.new(1, 0)
                SelectedName.Position        = UDim2.new(1, -ES(30), 0, 0)
                SelectedName.BackgroundTransparency = 1
                SelectedName.Text            = (Selected and Selected.Name) or ""
                SelectedName.TextColor3      = T.Accent
                SelectedName.Font            = Enum.Font.GothamBold
                SelectedName.TextSize        = FS(11)
                SelectedName.TextXAlignment  = Enum.TextXAlignment.Right
                SelectedName.TextTruncate    = Enum.TextTruncate.AtEnd
                SelectedName.Parent          = Header
            else
                SelectedLabel = Instance.new("TextLabel")
                SelectedLabel.Size            = UDim2.new(0.4, -25, 1, 0)
                SelectedLabel.Position        = UDim2.new(1, -10, 0, 0)
                SelectedLabel.AnchorPoint     = Vector2.new(1, 0)
                SelectedLabel.BackgroundTransparency = 1
                SelectedLabel.Text            = (type(Selected) == "string" and Selected) or "Select..."
                SelectedLabel.TextColor3      = T.Accent
                SelectedLabel.Font            = Enum.Font.GothamBold
                SelectedLabel.TextSize        = FS(11)
                SelectedLabel.TextXAlignment  = Enum.TextXAlignment.Right
                SelectedLabel.Parent          = Header
            end

            local OptionHolder = Instance.new("Frame")
            OptionHolder.Size             = UDim2.new(1, -ES(10), 0, 0)
            OptionHolder.Position         = UDim2.new(0, ES(5), 0, RowHeight + ES(4))
            OptionHolder.BackgroundTransparency = 1
            OptionHolder.Parent           = DropdownFrame

            local Layout = Instance.new("UIListLayout", OptionHolder)
            Layout.Padding   = UDim.new(0, ES(3))
            Layout.SortOrder = Enum.SortOrder.LayoutOrder

            local Dropdown = { Open = false }

            local function UpdateHeader(sel)
                Selected = sel
                if colorMode then
                    if SelectedSwatch then SelectedSwatch.BackgroundColor3 = sel and sel.Color or Color3.new(1,1,1) end
                    if SelectedName   then SelectedName.Text = (sel and sel.Name) or "" end
                else
                    if SelectedLabel  then SelectedLabel.Text = (type(sel) == "string" and sel) or "Select..." end
                end
            end

            local function GetOpenHeight()
                return RowHeight + ES(4) + Layout.AbsoluteContentSize.Y + ES(6)
            end

            local function Refresh()
                optionOverlays = {}
                for _, child in pairs(OptionHolder:GetChildren()) do
                    if child:IsA("TextButton") or child:IsA("Frame") then child:Destroy() end
                end
                colorMode = IsColorMode(Options)

                for i, rawOpt in ipairs(Options) do
                    local opt = Normalise(rawOpt)

                    if colorMode then
                        local OptBtn = Instance.new("TextButton")
                        OptBtn.LayoutOrder      = i
                        OptBtn.Size             = UDim2.new(1, 0, 0, OptHeight)
                        OptBtn.BackgroundColor3 = opt.Color
                        OptBtn.Text             = ""
                        OptBtn.BorderSizePixel  = 0
                        OptBtn.Parent           = OptionHolder
                        Corner(OptBtn, UDim.new(0, 4))

                        local RowStroke = Instance.new("UIStroke", OptBtn)
                        RowStroke.Thickness = 1.5
                        local isSel = Selected and typeof(Selected) == "table" and Selected.Color == opt.Color
                        RowStroke.Color        = isSel and T.TextWhite or Color3.fromRGB(0,0,0)
                        RowStroke.Transparency = isSel and 0 or 0.85

                        if opt.Name and opt.Name ~= "" then
                            local NameLbl = Instance.new("TextLabel")
                            NameLbl.Size                  = UDim2.new(1, -ES(10), 1, 0)
                            NameLbl.Position              = UDim2.new(0, ES(8), 0, 0)
                            NameLbl.BackgroundTransparency = 1
                            NameLbl.Text                  = opt.Name
                            NameLbl.Font                  = Enum.Font.GothamBold
                            NameLbl.TextSize              = FS(11)
                            NameLbl.TextColor3            = Color3.new(1, 1, 1)
                            NameLbl.TextTransparency      = 0.2
                            NameLbl.TextXAlignment        = Enum.TextXAlignment.Left
                            NameLbl.TextStrokeColor3      = Color3.new(0, 0, 0)
                            NameLbl.TextStrokeTransparency = 0.5
                            NameLbl.Parent                = OptBtn
                        end

                        local colorKey = (opt.Name ~= "" and opt.Name) or tostring(opt.Color)
                        local DisabledOverlay = Instance.new("Frame")
                        DisabledOverlay.Name                   = "DisabledOverlay"
                        DisabledOverlay.Size                   = UDim2.new(1, 0, 1, 0)
                        DisabledOverlay.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
                        DisabledOverlay.BackgroundTransparency = 0.6
                        DisabledOverlay.BorderSizePixel        = 0
                        DisabledOverlay.ZIndex                 = 10
                        DisabledOverlay.Visible                = disabledOptions[colorKey] == true
                        DisabledOverlay.Parent                 = OptBtn
                        Corner(DisabledOverlay, UDim.new(0, 4))
                        optionOverlays[colorKey] = DisabledOverlay

                        OptBtn.MouseButton1Click:Connect(function()
                            if dropDisabled or disabledOptions[colorKey] then return end
                            for _, child in pairs(OptionHolder:GetChildren()) do
                                local s = child:FindFirstChildOfClass("UIStroke")
                                if s then s.Color = Color3.fromRGB(0,0,0); s.Transparency = 0.85 end
                            end
                            RowStroke.Color        = T.TextWhite
                            RowStroke.Transparency = 0
                            UpdateHeader(opt)
                            Dropdown.Open = false
                            TweenService:Create(DropdownFrame, TI_02, {Size = UDim2.new(1, 0, 0, RowHeight)}):Play()
                            Callback(opt.Color, opt.Name)
                        end)

                    else
                        local OptBtn = Instance.new("TextButton")
                        OptBtn.LayoutOrder      = i
                        OptBtn.Size             = UDim2.new(1, 0, 0, OptHeight)
                        OptBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
                        OptBtn.Text             = opt
                        OptBtn.TextColor3       = T.TextDark
                        OptBtn.Font             = Enum.Font.Gotham
                        OptBtn.TextSize         = FS(11)
                        OptBtn.Parent           = OptionHolder
                        Corner(OptBtn, UDim.new(0, 4))

                        local DisabledOverlay = Instance.new("Frame")
                        DisabledOverlay.Name                   = "DisabledOverlay"
                        DisabledOverlay.Size                   = UDim2.new(1, 0, 1, 0)
                        DisabledOverlay.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
                        DisabledOverlay.BackgroundTransparency = 0.6
                        DisabledOverlay.BorderSizePixel        = 0
                        DisabledOverlay.ZIndex                 = 10
                        DisabledOverlay.Visible                = disabledOptions[opt] == true
                        DisabledOverlay.Parent                 = OptBtn
                        Corner(DisabledOverlay, UDim.new(0, 4))
                        optionOverlays[opt] = DisabledOverlay

                        OptBtn.MouseButton1Click:Connect(function()
                            if dropDisabled or disabledOptions[opt] then return end
                            UpdateHeader(opt)
                            Dropdown.Open = false
                            TweenService:Create(DropdownFrame, TI_02, {Size = UDim2.new(1, 0, 0, RowHeight)}):Play()
                            Callback(opt)
                        end)
                    end
                end
            end

            Header.MouseButton1Click:Connect(function()
                if dropDisabled then return end
                Dropdown.Open = not Dropdown.Open
                local targetH = Dropdown.Open and GetOpenHeight() or RowHeight
                TweenService:Create(DropdownFrame, TI_025Q, {Size = UDim2.new(1, 0, 0, targetH)}):Play()
            end)

            function Element:SetDisabled(state)
                dropDisabled  = state
                Header.Active = not state
                TweenService:Create(TitleLabel, TI_02, {TextColor3 = state and T.TextSecondary or T.TextPrimary}):Play()
                if SelectedLabel  then TweenService:Create(SelectedLabel,  TI_02, {TextTransparency       = state and 0.5 or 0}):Play() end
                if SelectedSwatch then TweenService:Create(SelectedSwatch, TI_02, {BackgroundTransparency = state and 0.5 or 0}):Play() end
                if SelectedName   then TweenService:Create(SelectedName,   TI_02, {TextTransparency       = state and 0.5 or 0}):Play() end
                if state and Dropdown.Open then
                    Dropdown.Open = false
                    TweenService:Create(DropdownFrame, TI_02, {Size = UDim2.new(1, 0, 0, RowHeight)}):Play()
                end
            end

            function Element:SetOptions(newOptions)
                Options  = newOptions
                Selected = newOptions[1] and Normalise(newOptions[1])
                UpdateHeader(Selected)
                Dropdown.Open = false
                TweenService:Create(DropdownFrame, TI_02, {Size = UDim2.new(1, 0, 0, RowHeight)}):Play()
                Refresh()
            end

            function Element:SetSelected(val)
                UpdateHeader(Normalise(val))
            end

            function Element:SetOptionDisabled(name, state)
                disabledOptions[name] = state == true
                local overlay = optionOverlays[name]
                if overlay then overlay.Visible = state == true end
            end

            Refresh()
            return AttachTooltip(TitleLabel, Element)
        end

        -- ── COLOR PICKER ──────────────────────────────────────────────────────────────
        function Tab:CreateColorPicker(Title, Default, Callback)
            local Element        = {}
            local pickerOpen     = false
            local pickerDisabled = false

            -- ── Working HSV state ────────────────────────────────────
            local hue, sat, val = Color3.toHSV(Default or Color3.fromRGB(74, 120, 255))

            local ROW_H    = ES(28)
            local PAD      = ES(10)   -- horizontal outer padding
            local IPAD     = ES(8)    -- inner top/bottom padding inside expanded area
            local GAP      = ES(5)    -- gap between strips
            local SV_H     = ES(130)
            local BAR_H    = ES(10)
            local CURSOR_D = ES(10)
            local BAR_CUR  = ES(3)

            local EXPANDED_H = ROW_H + IPAD
                + SV_H  + GAP
                + BAR_H + GAP
                + BAR_H + IPAD

            -- ── Outer frame ──────────────────────────────────────────
            local PickerFrame = Instance.new("Frame")
            PickerFrame.Size             = UDim2.new(1, 0, 0, ROW_H)
            PickerFrame.BackgroundColor3 = T.Surface
            PickerFrame.ClipsDescendants = true
            PickerFrame.Parent           = self.Container
            Corner(PickerFrame, UDim.new(0, 8))
            AddDepthStroke(PickerFrame)

            local Header = Instance.new("TextButton")
            Header.Size                   = UDim2.new(1, 0, 0, ROW_H)
            Header.BackgroundTransparency = 1
            Header.Text                   = ""
            Header.ZIndex                 = 3
            Header.Parent                 = PickerFrame

            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Size                   = UDim2.new(0.6, 0, 1, 0)
            TitleLabel.Position               = UDim2.new(0, PAD, 0, 0)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Text                   = Title
            TitleLabel.TextColor3             = T.TextPrimary
            TitleLabel.Font                   = Enum.Font.GothamMedium
            TitleLabel.TextSize               = FS(12)
            TitleLabel.TextXAlignment         = Enum.TextXAlignment.Left
            TitleLabel.Parent                 = Header

            local SwatchPill = Instance.new("Frame")
            SwatchPill.Size             = UDim2.new(0, ES(36), 0, ES(14))
            SwatchPill.AnchorPoint      = Vector2.new(1, 0.5)
            SwatchPill.Position         = UDim2.new(1, -PAD, 0.5, 0)
            SwatchPill.BackgroundColor3 = Color3.fromHSV(hue, sat, val)
            SwatchPill.BorderSizePixel  = 0
            SwatchPill.ZIndex           = 3
            SwatchPill.Parent           = Header
            Corner(SwatchPill, UDim.new(0, 4))
            local SwatchStroke = Instance.new("UIStroke", SwatchPill)
            SwatchStroke.Color = T.Stroke; SwatchStroke.Thickness = 1

            local Content = Instance.new("Frame")
            Content.Size                   = UDim2.new(1, -(PAD * 2), 0,
                EXPANDED_H - ROW_H - IPAD * 2)
            Content.Position               = UDim2.new(0, PAD, 0, ROW_H + IPAD)
            Content.BackgroundTransparency = 1
            Content.ClipsDescendants       = false
            Content.Parent                 = PickerFrame

            local function MakeStrip(yOffset, height, clipDescendants, whiteBase)
                local f = Instance.new("Frame")
                f.Size             = UDim2.new(1, 0, 0, height)
                f.Position         = UDim2.new(0, 0, 0, yOffset)
                f.BackgroundColor3 = whiteBase and Color3.new(1, 1, 1) or T.SurfaceDeep
                f.BorderSizePixel  = 0
                f.ClipsDescendants = clipDescendants or false
                f.Parent           = Content
                Corner(f, UDim.new(0, 6))
                return f
            end

            local svY = 0
            local SVClip = MakeStrip(svY, SV_H, true)
            Corner(SVClip, UDim.new(0, 6)) 

            local SVBase = Instance.new("Frame")
            SVBase.Size             = UDim2.new(1, 0, 1, 0)
            SVBase.BackgroundColor3 = Color3.fromHSV(1, 1, 1)
            SVBase.BorderSizePixel  = 0
            SVBase.Parent           = SVClip
            Corner(SVBase, UDim.new(0, 6))
            local SVBaseGrad = Instance.new("UIGradient", SVBase)
            SVBaseGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromHSV(hue, 1, 1)),
            })

            local SVDark = Instance.new("Frame")
            SVDark.Size             = UDim2.new(1, 0, 1, 0)
            SVDark.BackgroundColor3 = Color3.new(0, 0, 0)
            SVDark.BorderSizePixel  = 0
            SVDark.Parent           = SVClip
            Corner(SVDark, UDim.new(0, 6))
            local SVDarkGrad = Instance.new("UIGradient", SVDark)
            SVDarkGrad.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(1, 0),
            })
            SVDarkGrad.Rotation = 90

            local SVCursor = Instance.new("Frame")
            SVCursor.Size             = UDim2.new(0, CURSOR_D, 0, CURSOR_D)
            SVCursor.AnchorPoint      = Vector2.new(0.5, 0.5)
            SVCursor.Position         = UDim2.new(sat, 0, 1 - val, 0)
            SVCursor.BackgroundColor3 = Color3.new(1, 1, 1)
            SVCursor.BorderSizePixel  = 0
            SVCursor.ZIndex           = 6
            SVCursor.Parent           = SVClip
            Corner(SVCursor, UDim.new(1, 0))
            local SVCursorRing = Instance.new("UIStroke", SVCursor)
            SVCursorRing.Color     = Color3.new(0, 0, 0)
            SVCursorRing.Thickness = 1.5

            local SVHit = Instance.new("TextButton")
            SVHit.Size                   = UDim2.new(1, 0, 1, 0)
            SVHit.BackgroundTransparency = 1
            SVHit.Text                   = ""
            SVHit.ZIndex                 = 7
            SVHit.Parent                 = SVClip

            -- ── Hue strip ────────────────────────────────────────────
            local hueY = svY + SV_H + GAP
            local HueStrip = MakeStrip(hueY, BAR_H, true, true)
            local HueGrad = Instance.new("UIGradient", HueStrip)
            HueGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0/6, Color3.fromHSV(0/6, 1, 1)),
                ColorSequenceKeypoint.new(1/6, Color3.fromHSV(1/6, 1, 1)),
                ColorSequenceKeypoint.new(2/6, Color3.fromHSV(2/6, 1, 1)),
                ColorSequenceKeypoint.new(3/6, Color3.fromHSV(3/6, 1, 1)),
                ColorSequenceKeypoint.new(4/6, Color3.fromHSV(4/6, 1, 1)),
                ColorSequenceKeypoint.new(5/6, Color3.fromHSV(5/6, 1, 1)),
                ColorSequenceKeypoint.new(1,   Color3.fromHSV(0,   1, 1)),
            })

            local HueCursor = Instance.new("Frame")
            HueCursor.Size             = UDim2.new(0, BAR_CUR, 1, ES(4))
            HueCursor.AnchorPoint      = Vector2.new(0.5, 0.5)
            HueCursor.Position         = UDim2.new(hue, 0, 0.5, 0)
            HueCursor.BackgroundColor3 = Color3.new(1, 1, 1)
            HueCursor.BorderSizePixel  = 0
            HueCursor.ZIndex           = 5
            HueCursor.Parent           = HueStrip
            Corner(HueCursor, UDim.new(0, 2))
            Instance.new("UIStroke", HueCursor).Color = Color3.new(0, 0, 0)

            local HueHit = Instance.new("TextButton")
            HueHit.Size                   = UDim2.new(1, 0, 1, 0)
            HueHit.BackgroundTransparency = 1
            HueHit.Text                   = ""
            HueHit.ZIndex                 = 6
            HueHit.Parent                 = HueStrip

            local valY = hueY + BAR_H + GAP
            local ValStrip = MakeStrip(valY, BAR_H, true, true)
            local ValGrad = Instance.new("UIGradient", ValStrip)

            local function UpdateValGrad()
                ValGrad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
                    ColorSequenceKeypoint.new(1, Color3.fromHSV(hue, sat, 1)),
                })
            end
            UpdateValGrad()

            local ValCursor = Instance.new("Frame")
            ValCursor.Size             = UDim2.new(0, BAR_CUR, 1, ES(4))
            ValCursor.AnchorPoint      = Vector2.new(0.5, 0.5)
            ValCursor.Position         = UDim2.new(val, 0, 0.5, 0)
            ValCursor.BackgroundColor3 = Color3.new(1, 1, 1)
            ValCursor.BorderSizePixel  = 0
            ValCursor.ZIndex           = 5
            ValCursor.Parent           = ValStrip
            Corner(ValCursor, UDim.new(0, 2))
            Instance.new("UIStroke", ValCursor).Color = Color3.new(0, 0, 0)

            local ValHit = Instance.new("TextButton")
            ValHit.Size                   = UDim2.new(1, 0, 1, 0)
            ValHit.BackgroundTransparency = 1
            ValHit.Text                   = ""
            ValHit.ZIndex                 = 6
            ValHit.Parent                 = ValStrip

            local function UpdateAll(fireCallback)
                local color = Color3.fromHSV(hue, sat, val)

                SVBase.BackgroundColor3 = Color3.new(1, 1, 1)
                SVBaseGrad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                    ColorSequenceKeypoint.new(1, Color3.fromHSV(hue, 1, 1)),
                })

                SVCursor.Position = UDim2.new(sat, 0, 1 - val, 0)

                local brightness = val * (1 - sat * 0.5)
                SVCursorRing.Color = brightness > 0.55 and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)

                HueCursor.Position = UDim2.new(hue, 0, 0.5, 0)

                UpdateValGrad()
                ValCursor.Position = UDim2.new(val, 0, 0.5, 0)

                SwatchPill.BackgroundColor3 = color

                if fireCallback then Callback(color) end
            end

            UpdateAll(false)

            -- ── Drag logic ────────────────────────────────────────────
            local draggingSV  = false
            local draggingHue = false
            local draggingVal = false

            local function SampleSV(pos)
                local abs = SVClip.AbsolutePosition
                local sz  = SVClip.AbsoluteSize
                sat = math.clamp((pos.X - abs.X) / sz.X, 0, 1)
                val = math.clamp(1 - (pos.Y - abs.Y) / sz.Y, 0, 1)
                UpdateAll(true)
            end

            local function SampleHue(pos)
                local abs = HueStrip.AbsolutePosition
                local sz  = HueStrip.AbsoluteSize
                hue = math.clamp((pos.X - abs.X) / sz.X, 0, 1)
                UpdateAll(true)
            end

            local function SampleVal(pos)
                local abs = ValStrip.AbsolutePosition
                local sz  = ValStrip.AbsoluteSize
                val = math.clamp((pos.X - abs.X) / sz.X, 0, 1)
                UpdateAll(true)
            end

            SVHit.InputBegan:Connect(function(i)
                if pickerDisabled then return end
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSV = true; SampleSV(i.Position)
                end
            end)
            HueHit.InputBegan:Connect(function(i)
                if pickerDisabled then return end
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingHue = true; SampleHue(i.Position)
                end
            end)
            ValHit.InputBegan:Connect(function(i)
                if pickerDisabled then return end
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingVal = true; SampleVal(i.Position)
                end
            end)

            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSV  = false
                    draggingHue = false
                    draggingVal = false
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
                if pickerDisabled then return end
                if draggingSV  then SampleSV(i.Position)  end
                if draggingHue then SampleHue(i.Position) end
                if draggingVal then SampleVal(i.Position) end
            end)

            Header.MouseButton1Click:Connect(function()
                if pickerDisabled then return end
                pickerOpen = not pickerOpen
                TweenService:Create(PickerFrame, TI_025Q, {
                    Size = UDim2.new(1, 0, 0, pickerOpen and EXPANDED_H or ROW_H)
                }):Play()
            end)

            function Element:SetColor(color)
                hue, sat, val = Color3.toHSV(color)
                UpdateAll(false)
            end

            function Element:GetColor()
                return Color3.fromHSV(hue, sat, val)
            end

            function Element:SetDisabled(state)
                pickerDisabled = state
                Header.Active  = not state
                TweenService:Create(TitleLabel, TI_02, {
                    TextColor3 = state and T.TextSecondary or T.TextPrimary
                }):Play()
                TweenService:Create(SwatchPill, TI_02, {
                    BackgroundTransparency = state and 0.5 or 0
                }):Play()
                if state and pickerOpen then
                    pickerOpen = false
                    TweenService:Create(PickerFrame, TI_025Q, {
                        Size = UDim2.new(1, 0, 0, ROW_H)
                    }):Play()
                end
            end

            return AttachTooltip(TitleLabel, Element)
        end

        return Tab
    end

    Window.Frame   = MainFrame
    Window.Sidebar = Sidebar
    return Window
end

-- ============================================================
-- WINDOW & TAB CREATION
-- ============================================================
local HubWindow = Library:CreateWindow()

local HomeTab        = HubWindow:CreateTab("Home")
local PlayerTab      = HubWindow:CreateTab("Player")
local WorldTab       = HubWindow:CreateTab("World")
local TeleportTab    = HubWindow:CreateTab("Teleport")
local PlotTab        = HubWindow:CreateTab("Plot")
local WoodTab        = HubWindow:CreateTab("Wood")
local ShopTab        = HubWindow:CreateTab("Shop")
local ToolTab        = HubWindow:CreateTab("Tool")
local BuildTab       = HubWindow:CreateTab("Build")
--local WireArtTab     = HubWindow:CreateTab("Wiring")
local DuplicationTab = HubWindow:CreateTab("Duplicate")
local VehicleTab     = HubWindow:CreateTab("Vehicle")
local SearchTab      = HubWindow:CreateTab("Search")
local ProtectionTab  = HubWindow:CreateTab("Protection")
--local HelpTab        = HubWindow:CreateTab("Help")
--local AddonsTab    = HubWindow:CreateTab("Addons")
local SettingsTab    = HubWindow:CreateTab("Settings")
--local TestingTab        = HubWindow:CreateTab("Testing")

-- ============================================================
-- LOAD SCREEN
-- ============================================================
local LoadGui = Instance.new("ScreenGui")
LoadGui.Name           = "DynxeLoadScreen"
LoadGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
LoadGui.DisplayOrder   = 9999
LoadGui.ResetOnSpawn   = false
LoadGui.IgnoreGuiInset = true
LoadGui.Parent         = CoreGui

local Overlay = Instance.new("Frame")
Overlay.Size                 = UDim2.new(1, 0, 1, 0)
Overlay.BackgroundColor3     = Color3.fromRGB(8, 10, 22)
Overlay.BackgroundTransparency = 0.12
Overlay.BorderSizePixel      = 0
Overlay.Active               = true
Overlay.Parent               = LoadGui

ContextActionService:BindAction(
    "DynxeLoadingFreeze",
    function() return Enum.ContextActionResult.Sink end,
    false,
    unpack(Enum.PlayerActions:GetEnumItems())
)

local Vignette = Instance.new("UIGradient", Overlay)
Vignette.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(10, 20, 60)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(8,  10, 22)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(10, 20, 60)),
})
Vignette.Rotation = 45

local Center = Instance.new("Frame")
Center.Size                   = UDim2.new(0, 320, 0, 140)
Center.AnchorPoint            = Vector2.new(0.5, 0.5)
Center.Position               = UDim2.new(0.5, 0, 0.5, 0)
Center.BackgroundTransparency = 1
Center.Parent                 = Overlay

local LoadingLabel = Instance.new("TextLabel")
LoadingLabel.Size               = UDim2.new(1, 0, 0, 20)
LoadingLabel.Position           = UDim2.new(0, 0, 0, 0)
LoadingLabel.BackgroundTransparency = 1
LoadingLabel.Text               = "Initializing..."
LoadingLabel.TextColor3         = Color3.fromRGB(100, 140, 255)
LoadingLabel.Font               = Enum.Font.Gotham
LoadingLabel.TextSize           = 16
LoadingLabel.TextXAlignment     = Enum.TextXAlignment.Center
LoadingLabel.Parent             = Center

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size               = UDim2.new(1, 0, 0, 36)
TitleLabel.Position           = UDim2.new(0, 0, 0, 24)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text               = "<b>Dynxe</b> <font color=\"#4a78ff\">LT2</font> <font color=\"#444466\">" .. Version .. "</font>"
TitleLabel.RichText           = true
TitleLabel.TextColor3         = Color3.fromRGB(220, 220, 230)
TitleLabel.Font               = Enum.Font.GothamMedium
TitleLabel.TextSize           = 28
TitleLabel.TextXAlignment     = Enum.TextXAlignment.Center
TitleLabel.Parent             = Center

local BarTrack = Instance.new("Frame")
BarTrack.Size             = UDim2.new(1, 0, 0, 4)
BarTrack.Position         = UDim2.new(0, 0, 0, 82)
BarTrack.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
BarTrack.BorderSizePixel  = 0
BarTrack.Parent           = Center
Corner(BarTrack, UDim.new(1, 0))

local BarFill = Instance.new("Frame")
BarFill.Size             = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Color3.fromRGB(74, 120, 255)
BarFill.BorderSizePixel  = 0
BarFill.Parent           = BarTrack
Corner(BarFill, UDim.new(1, 0))

local PctLabel = Instance.new("TextLabel")
PctLabel.Size                = UDim2.new(1, 0, 0, 16)
PctLabel.Position            = UDim2.new(0, 0, 0, 90)
PctLabel.BackgroundTransparency = 1
PctLabel.Text                = "0%"
PctLabel.TextColor3          = Color3.fromRGB(70, 90, 140)
PctLabel.Font                = Enum.Font.Gotham
PctLabel.TextSize            = 11
PctLabel.TextXAlignment      = Enum.TextXAlignment.Center
PctLabel.Parent              = Center

local WarningLabel = Instance.new("TextLabel")
WarningLabel.Size                = UDim2.new(1, 0, 0, 16)
WarningLabel.Position            = UDim2.new(0, 0, 0, 110)
WarningLabel.BackgroundTransparency = 1
WarningLabel.Text                = "MODULE STILL LOADING | DO NOT LEAVE"
WarningLabel.TextColor3          = Color3.fromRGB(255, 100, 80)
WarningLabel.Font                = Enum.Font.GothamBold
WarningLabel.TextSize            = 12
WarningLabel.Visible             = false
WarningLabel.TextXAlignment      = Enum.TextXAlignment.Center
WarningLabel.Parent              = Center

local FooterLabel = Instance.new("TextLabel")
FooterLabel.Size               = UDim2.new(1, 0, 0, 30)
FooterLabel.Position           = UDim2.new(0, 0, 1, -40)
FooterLabel.BackgroundTransparency = 1
FooterLabel.Text               = "Specific modules may take longer due to heavier functionality. Please be patient as we work foward to perfect this menu!"
FooterLabel.TextColor3         = Color3.fromRGB(255, 255, 255)
FooterLabel.Font               = Enum.Font.Gotham
FooterLabel.TextSize           = 12
FooterLabel.TextXAlignment     = Enum.TextXAlignment.Center
FooterLabel.Parent             = Overlay

local SkipButton = Instance.new("TextButton")
SkipButton.Size                = UDim2.new(1, 0, 0, 20)
SkipButton.Position            = UDim2.new(0, 0, 0, 130)
SkipButton.BackgroundTransparency = 1
SkipButton.Text                = "<u>Click to Skip Module (may cause issues)</u>"
SkipButton.TextColor3          = Color3.fromRGB(150, 150, 170)
SkipButton.Font                = Enum.Font.Gotham
SkipButton.TextSize            = 12
SkipButton.RichText            = true
SkipButton.Visible             = false
SkipButton.Parent              = Center

local function SetProgress(current, total, moduleName)
    local pct = (total > 0) and (current / total) or 1
    
    TweenService:Create(BarFill, TI_025Q, {
        Size = UDim2.new(pct, 0, 1, 0)
    }):Play()
    
    PctLabel.Text     = math.floor(pct * 100) .. "%"
    LoadingLabel.Text = moduleName and ("Loading " .. moduleName) or "Done"
    WarningLabel.Visible = false
    SkipButton.Visible   = false
end

local function DismissLoadScreen()
    ContextActionService:UnbindAction("DynxeLoadingFreeze")
    TweenService:Create(Overlay,       TweenInfo.new(0.6), {BackgroundTransparency = 1}):Play()
    TweenService:Create(TitleLabel,    TweenInfo.new(0.4), {TextTransparency = 1}):Play()
    TweenService:Create(LoadingLabel,  TweenInfo.new(0.4), {TextTransparency = 1}):Play()
    TweenService:Create(PctLabel,      TweenInfo.new(0.4), {TextTransparency = 1}):Play()
    TweenService:Create(WarningLabel,  TweenInfo.new(0.4), {TextTransparency = 1}):Play()
    TweenService:Create(FooterLabel,   TweenInfo.new(0.4), {TextTransparency = 1}):Play()
    TweenService:Create(BarFill,       TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
    TweenService:Create(BarTrack,      TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
    task.delay(0.7, function() LoadGui:Destroy() end)
end

-- ============================================================
-- MODULE LOADING
-- ============================================================

local LooseObjectTeleportModule = nil
local LooseObjectTeleportReady = false
local TreeReady = false
local Modules = {
    { name = "Theme", run = function(m) if m then _G.DynxeTheme = m end end },
    { name = "LT2ItemList", run = function(m) if m then _G.LT2ItemList = m end end },
    { name = "LT2Axes", run = function(m) _G.LT2Axes = m end },
    { name = "Logo",                run = function(m) if m and m.Init then m.Init(Version, Vector3.new(43.5, 18, 55.3), Vector3.new(0, -105, 0), 60, 20) end end },
    { name = "Home",                run = function(m) if m and m.Init then m.Init(HomeTab, Library) end end },
    { name = "Player",      run = function(m) if m and m.Init then m.Init(PlayerTab) end end },
    { name = "Teleport",            run = function(m) if m and m.Init then m.Init(TeleportTab) end end },
    { name = "World",               run = function(m) if m and m.Init then m.Init(WorldTab, Library) end end },
    { name = "Settings",            run = function(m) if m and m.Init then m.Init(SettingsTab, HubWindow, {User = User, Repo = Repo, Branch = Branch}, Config) end end },
    --{ name = "AntiFling",          run = function(m) if m and m.Init then m.Init(ProtectionTab) end end },
    --{ name = "AntiVoid",           run = function(m) if m and m.Init then m.Init(ProtectionTab) end end },
    { name = "AntiRagdoll",         run = function(m) if m and m.Init then m.Init(ProtectionTab) end end },
    { name = "AntiAFK",             run = function(m) if m and m.Init then m.Init(ProtectionTab) end end },
    { name = "AxeRecovery",         run = function(m) if m and m.Init then m.Init(ProtectionTab) end end },
    { name = "LooseObjectTeleport", run = function(m)
        LooseObjectTeleportModule = m
        LooseObjectTeleportReady = true
        if m and m.Init then m.Init(ToolTab, Library) end
    end },
    { name = "Vehicle",             run = function(m) if m and m.Init then m.Init(VehicleTab) end end },
    { name = "Plot",                run = function(m) if m and m.Init then m.Init(PlotTab, Library) end end },
    { name = "Tree", run = function(m)
        local deadline = tick() + 15
        repeat task.wait() until LooseObjectTeleportReady or tick() > deadline
        if m and m.Init then m.Init(WoodTab, LooseObjectTeleportModule) end
        TreeReady = true
    end },
    { name = "AxeDupe",         run = function(m) if m and m.Init then m.Init(DuplicationTab) end end },
    { name = "Duplication",         run = function(m) if m and m.Init then m.Init(DuplicationTab) end end },
    --{ name = "Build", run = function(m)
    --    local deadline = tick() + 15
    --    repeat task.wait() until LooseObjectTeleportReady or tick() > deadline
    --    if m and m.Init then m.Init(BuildTab, LooseObjectTeleportModule) end
    --end },
    { name = "Shop", run = function(m)
        local deadline = tick() + 15
        repeat task.wait() until LooseObjectTeleportReady or tick() > deadline
        task.wait(1)
        if m and m.Init then m.Init(ShopTab, LooseObjectTeleportModule) end
    end },
    { name = "ModTree", run = function(m)
        local deadline = tick() + 15
        repeat task.wait() until TreeReady or tick() > deadline
        if m and m.Init then m.Init(WoodTab, LooseObjectTeleportModule, Library) end
    end },
    { name = "TreeSearcher", run = function(m) if m and m.Init then m.Init(SearchTab, Library) end end },
    { name = "WireArt", run = function(m)
        local deadline = tick() + 15
        repeat task.wait() until LooseObjectTeleportReady or tick() > deadline
        if m and m.Init then m.Init(BuildTab, Library, LooseObjectTeleportModule) end
    end },
    --{ name = "Addons", run = function(m) if m and m.Init then m.Init(AddonsTab, Library) end end },
}

local total = #Modules
local loaded = 0

local threads = {}
for i, entry in ipairs(Modules) do
    table.insert(threads, task.spawn(function()
        local ok, err = pcall(function()
            local m = LoadModule(entry.name)
            entry.run(m)
        end)
        loaded = loaded + 1
        SetProgress(loaded, total, entry.name)
        if not ok then warn("[Loader] " .. entry.name .. " failed: " .. tostring(err)) end
    end))
end

repeat task.wait() until loaded >= total

SetProgress(total, total, nil)
task.wait(0.4)
DismissLoadScreen()
Library:Notify("Dynxe LT2", "All modules loaded!", 5)