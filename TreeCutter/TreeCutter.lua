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
local CONFIG_FILE = CONFIG_DIR .. "/treecutter.json"

local TEXT = Color3.fromRGB(230, 230, 230)
local MUTED = Color3.fromRGB(160, 160, 160)
local RED = Color3.fromRGB(210, 70, 70)
local DARK = Color3.fromRGB(18, 18, 18)
local BUTTON = Color3.fromRGB(230, 230, 230)
local FIELD = Color3.fromRGB(58, 58, 58)
local HOVER = Color3.fromRGB(120, 120, 120)
local TRACK = Color3.fromRGB(40, 40, 40)
local GREEN = Color3.fromRGB(70, 190, 105)
local TOGGLE_W = 28
local TOGGLE_H = 14
local TOGGLE_KNOB = 10
local TOGGLE_PAD = 2

local QUANTITY_MIN = 1
local QUANTITY_MAX = 25

local FIRES_PER_SECTION = 100
local FIRE_DELAY = 0.01
local SWEEP_DELAY = 0.1
local SYNC_DELAY = 0.1
local RESPAWN_DELAY = 1
local LOG_DROP = 6
local SELL_POSITION = Vector3.new(315, 0, 88)
local PLANK_SELL_CF = CFrame.new(315, 0, 88) * CFrame.Angles(math.rad(90), 0, 0)
local PLANK_LOCK_TIME = 1

local CUT_FIRE_DELAY = 0
local CUT_TIMEOUT = 90
local CUT_MAX_UNITS = 100
local CUT_DETECT = 8
local CUT_MIN_LEFTOVER = 1
local CUT_COLOR = Color3.fromRGB(70, 200, 255)
local QUEUE_COLOR = Color3.fromRGB(255, 150, 20)
local SELL_COLOR = Color3.fromRGB(80, 255, 120)
local MOD_COLOR = Color3.fromRGB(190, 90, 255)
local MOD_TP_CF = CFrame.new(-1420, 380, 1400)
local DROP_ZONE_CF = CFrame.new(-360, 92, -100)
local MOD_DISAPPEAR = 60
local MOD_CHOP_TIMEOUT = 40
local MOD_FIRE_DELAY = 0.03
local MOD_BURN_TRIES = 5
local BLUEPRINT_NAME = "Wall2"
local TILE_END_OFFSET = CFrame.new(0, 5, -1.8)
local TILE_OFFSET_4L = CFrame.new(0, 8.5, -1.8)
local BLUEPRINT_MATCH = 1
local SAWMILL_NAMES = {
    Sawmill = true,
    Sawmill2 = true,
    Sawmill3 = true,
    Sawmill4 = true,
    Sawmill4L = true,
}

local PRIORITY = {
    "Generic", "Cherry", "Birch", "Oak", "Walnut", "Koa", "Pine", "Palm", "Fir",
    "Volcano", "Frost", "GreenSwampy", "GoldSwampy",
    "SnowGlow", "CaveCrawler", "LoneCave", "Spook", "Sinister",
}

local TREE_RATES = {
    Generic = 1.5, Cherry = 1.3, Birch = 2.25,
    Oak = 0.75, Walnut = 1.2, Koa = 2.8,
    Pine = 3.2, Palm = 2.9, Fir = 3.2,
    Volcano = 3.5, Frost = 9, GreenSwampy = 4.4,
    GoldSwampy = 5.7, SnowGlow = 1.5, CaveCrawler = 8,
    LoneCave = 150, BlueSpruce = 20, Spook = 19,
    SpookNeon = 25,
}

local PLANK_RATES = {
    Generic = 10, Cherry = 10.5, Birch = 15,
    Oak = 6, Walnut = 11, Koa = 26.4,
    Pine = 18, Palm = 32, Fir = 18,
    Volcano = 28, Frost = 106, GreenSwampy = 30,
    GoldSwampy = 36, SnowGlow = 10, CaveCrawler = 36,
    LoneCave = 420, BlueSpruce = 40, Spook = 54,
    SpookNeon = 90,
}

local AXE_DAMAGE = {
    ["Inverse Axe"] = function()
        return -1
    end,
    ["Refined Axe"] = function(treeClass)
        if treeClass == "Plank" then
            return 12
        end
        return 0
    end,
    ["Candy Cane Axe"] = function()
        return 0
    end,
    ["Basic Hatchet"] = function()
        return 0.2
    end,
    ["Plain Axe"] = function()
        return 0.55
    end,
    ["Rusty Axe"] = function()
        return 0.55
    end,
    ["Spearmint Axe"] = function()
        return 0.8
    end,
    ["CHICKEN AXE"] = function()
        return 0.9
    end,
    ["Steel Axe"] = function()
        return 0.93
    end,
    ["Hardened Axe"] = function()
        return 1.45
    end,
    ["Beta Axe of Bosses"] = function()
        return 1.45
    end,
    ["Beesaxe"] = function()
        return 1.4
    end,
    ["Alpha Axe of Testing"] = function()
        return 1.5
    end,
    ["Pig Axe"] = function()
        return 1.5
    end,
    ["Silver Axe"] = function()
        return 1.6
    end,
    ["Rukiryaxe"] = function()
        return 1.68
    end,
    ["Candy Corn Axe"] = function()
        return 1.75
    end,
    ["Amber Axe"] = function()
        return 3.39
    end,
    ["The Many Axe"] = function()
        return 10.2
    end,
    ["Pie Axe"] = function(treeClass)
        if treeClass == "Cherry" then
            return 1.9
        end
        return 0.95
    end,
    ["Fire Axe"] = function(treeClass)
        if treeClass == "Volcano" then
            return 6.35
        end
        return 0.6
    end,
    ["Cave Axe"] = function(treeClass)
        if treeClass == "CaveCrawler" then
            return 7.2
        end
        return 0.4
    end,
    ["Frost Axe"] = function(treeClass)
        if treeClass == "Frost" then
            return 6
        end
        return 0.36
    end,
    ["Bird Axe"] = function(treeClass)
        if treeClass == "CaveCrawler" then
            return 3.9
        elseif treeClass == "Volcano" then
            return 2.5
        end
        return 1.65
    end,
    ["Bluesteel Axe"] = function(treeClass)
        if treeClass == "BlueSpruce" then
            return 12.1
        end
        return 2.8
    end,
    ["OverGrown Axe"] = function(treeClass)
        if treeClass == "GreenSwampy" then
            return 7
        elseif treeClass == "GoldSwampy" then
            return 5.3
        end
        return 0.8
    end,
    ["Gingerbread Axe"] = function(treeClass)
        if treeClass == "Koa" then
            return 11
        elseif treeClass == "Walnut" then
            return 8.5
        end
        return 1.2
    end,
    ["End Times Axe"] = function(treeClass)
        if treeClass == "LoneCave" then
            return 1e7
        end
        return 1.58
    end,
}

local AXE_PRIORITY = {
    "The Many Axe", "Amber Axe", "Bluesteel Axe", "Johiro", "Candy Corn Axe",
    "Rukiryaxe", "Bird Axe", "Silver Axe", "End Times Axe", "Alpha Axe of Testing",
    "Pig Axe", "Hardened Axe", "Beta Axe of Bosses", "Beesaxe", "Gingerbread Axe",
    "Pie Axe", "Steel Axe", "CHICKEN AXE", "OverGrown Axe", "Spearmint Axe",
    "Fire Axe", "Plain Axe", "Rusty Axe", "Cave Axe", "Frost Axe",
    "Basic Hatchet", "Candy Cane Axe", "Refined Axe", "Inverse Axe",
}

local AXE_RANK = {}
for rank, name in ipairs(AXE_PRIORITY) do
    AXE_RANK[name] = rank
end

local selectedTree
local quantity = 1
local clickToSell = false
local cutterOn = false
local hoverOn = false
local modding = false
local modSawmill = false
local modGen = 0

local started = false
local mounted = false
local session = 0
local chopping = false
local chopSession = false
local chopLogs = false
local teleporting = false
local moveGen = 0
local moveMode

local preChopCFrame
local preChopCamera
local preChopLogs = {}
local lockConn
local diedConn

local options = {}
local disabled = {}

local root
local treeBtn
local treeCaption
local quantityLabel
local quantityFill
local quantitySlider
local getBtn
local chopBtn
local tpBtn
local sellBtn
local clickBtn
local cutterBtn
local hoverBtn
local modSawmillBtn
local modTreeBtn
local statusLabel
local menu
local backdrop
local menuOpen = false
local statusText = "Off"
local guiConns = {}
local watchConns = {}
local soundConns = {}

local sellGen = 0
local sellConns = {}
local sellOutline
local sellHover
local sellBusy = false

local cutterGen = 0
local cutterConns = {}
local cutterOutline
local cutterPlanes = {}
local cutterTracked
local cutterTarget
local cutterCutting = false
local cutterQueue = {}
local cutterMarks = {}
local cutterStatus
local cutterTimes = 0
local cutterTimeTotal = 0
local markFolder

local hoverConn
local hoverBillboard
local hoverModel
local modHome
local modLava
local modMarks = {}

local api = {}

local F = {}
function F.make(className, props, parent)
    local inst = Instance.new(className)
    for key, value in pairs(props) do
        inst[key] = value
    end
    inst.Parent = parent
    return inst
end

function F.track(bucket, conn)
    table.insert(bucket, conn)
    return conn
end

function F.clearBucket(bucket)
    for _, conn in ipairs(bucket) do
        conn:Disconnect()
    end
    table.clear(bucket)
end

function F.warnJell(message)
    warn("[Jell] TreeCutter " .. tostring(message))
end

function F.setStatus(text)
    statusText = text
    if statusLabel and statusLabel.Parent then
        statusLabel.Text = text
    end
end

function F.alive(token)
    return started and token == session
end

function F.currentRoot()
    local character = Player.Character
    if not character then
        return nil
    end
    return character:FindFirstChild("HumanoidRootPart")
end

function F.currentCamera()
    return Workspace.CurrentCamera
end

function F.axeDamage(axeName, treeClass)
    local fn = AXE_DAMAGE[axeName]
    if fn then
        return fn(treeClass)
    end
    return 1
end

function F.readAxeName(tool)
    if not tool then
        return nil
    end
    local tip = tool:FindFirstChild("ToolTip")
    if tip and tip:IsA("StringValue") then
        return tip.Value
    end
    return tool.ToolTip
end

function F.eachTool(callback)
    local character = Player.Character
    if character then
        local equipped = character:FindFirstChildOfClass("Tool")
        if equipped then
            callback(equipped)
        end
    end
    local backpack = Player:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            callback(tool)
        end
    end
end

function F.bestAxe(treeClass, forPlanks)
    local candidates = {}
    F.eachTool(function(tool)
        if not tool:IsA("Tool") or tool.Name == "BlueprintTool" then
            return
        end
        local axeName = F.readAxeName(tool)
        if not axeName then
            return
        end
        if forPlanks and treeClass == "LoneCave" and axeName ~= "End Times Axe" then
            return
        end
        local score
        if treeClass then
            score = F.axeDamage(axeName, treeClass)
        else
            score = 1 / (AXE_RANK[axeName] or 2 ^ 53)
        end
        table.insert(candidates, {
            tool = tool,
            name = axeName,
            score = score,
        })
    end)
    if #candidates == 0 then
        return nil, nil, 0
    end
    if forPlanks then
        for _, candidate in ipairs(candidates) do
            if candidate.name == "Refined Axe" then
                return candidate.tool, candidate.name, 12
            end
        end
    end
    table.sort(candidates, function(a, b)
        return a.score > b.score
    end)
    local best = candidates[1]
    return best.tool, best.name, best.score
end

function F.isTreeRegion(name)
    return string.lower(name):match("treeregion") ~= nil
end

function F.eachTreeRegion(callback)
    for _, folder in ipairs(Workspace:GetChildren()) do
        if F.isTreeRegion(folder.Name) then
            callback(folder)
        end
    end
end

function F.sectionCount(model, descendants)
    local count = 0
    local list = descendants and model:GetDescendants() or model:GetChildren()
    for _, part in ipairs(list) do
        if part.Name == "WoodSection" and (not descendants or part:IsA("BasePart")) then
            count = count + 1
        end
    end
    return count
end

function F.isOwned(model)
    local owner = model:FindFirstChild("Owner")
    if owner then
        if owner:IsA("ObjectValue") and owner.Value == Player then
            return true
        end
        if owner:IsA("StringValue") and owner.Value == Player.Name then
            return true
        end
        local nested = owner:FindFirstChild("OwnerString")
        if nested and nested:IsA("StringValue") and nested.Value == Player.Name then
            return true
        end
    end
    local ownerString = model:FindFirstChild("OwnerString")
    return ownerString and ownerString:IsA("StringValue") and ownerString.Value == Player.Name
end

function F.scanClasses()
    local enabled = {}
    local present = {}
    F.eachTreeRegion(function(folder)
        for _, model in ipairs(folder:GetChildren()) do
            if model:IsA("Model") then
                local treeClass = model:FindFirstChild("TreeClass")
                if treeClass and treeClass:IsA("StringValue") then
                    present[treeClass.Value] = true
                    if F.sectionCount(model, false) > 1 then
                        enabled[treeClass.Value] = true
                    end
                end
            end
        end
    end)
    return enabled, present
end

function F.buildOptions()
    local enabled, present = F.scanClasses()
    local list = {}
    local blocked = {}
    local seen = {}
    for _, name in ipairs(PRIORITY) do
        if enabled[name] then
            table.insert(list, name)
            seen[name] = true
        end
    end
    local extras = {}
    for name in pairs(enabled) do
        if not seen[name] then
            table.insert(extras, name)
        end
    end
    table.sort(extras)
    for _, name in ipairs(extras) do
        table.insert(list, name)
        seen[name] = true
    end
    for _, name in ipairs(PRIORITY) do
        if not enabled[name] and present[name] then
            table.insert(list, name)
            blocked[name] = true
            seen[name] = true
        end
    end
    for _, name in ipairs(PRIORITY) do
        if not seen[name] then
            table.insert(list, name)
            blocked[name] = true
        end
    end
    return list, blocked
end

function F.firstEnabled()
    for _, name in ipairs(options) do
        if not disabled[name] then
            return name
        end
    end
    return nil
end

function F.treeReady(name)
    if type(name) ~= "string" or name == "" then
        return false
    end
    for _, option in ipairs(options) do
        if option == name then
            return not disabled[name]
        end
    end
    return false
end

function F.findPriorityTree(treeClass)
    local best
    local most = -1
    F.eachTreeRegion(function(folder)
        for _, model in ipairs(folder:GetChildren()) do
            if model:IsA("Model") then
                local classValue = model:FindFirstChild("TreeClass")
                if classValue and classValue.Value == treeClass then
                    local count = F.sectionCount(model, false)
                    if not (treeClass == "Generic" and count < 12) and count > most then
                        most = count
                        best = model
                    end
                end
            end
        end
    end)
    return best
end

function F.sectionsBottomFirst(model)
    local sections = {}
    for _, part in ipairs(model:GetChildren()) do
        if part.Name == "WoodSection" then
            table.insert(sections, part)
        end
    end
    table.sort(sections, function(a, b)
        return a.Position.Y < b.Position.Y
    end)
    return sections
end

function F.baseSection(model)
    local sections = F.sectionsBottomFirst(model)
    local picked = sections[1]
    for _, section in ipairs(sections) do
        local id = section:FindFirstChild("ID")
        if id and id.Value == 1 then
            return section
        end
    end
    return picked
end

function F.snapshotLogs()
    preChopLogs = {}
    local folder = Workspace:FindFirstChild("LogModels")
    if not folder then
        return
    end
    for _, model in ipairs(folder:GetChildren()) do
        preChopLogs[model] = true
    end
end

function F.ownedInnerWood(singleSection)
    local results = {}
    local folder = Workspace:FindFirstChild("LogModels")
    if not folder then
        return results
    end
    for _, model in ipairs(folder:GetChildren()) do
        if model:IsA("Model") and F.isOwned(model) then
            if not singleSection or F.sectionCount(model, true) == 1 then
                local inner = model:FindFirstChild("InnerWood")
                if inner and inner:IsA("BasePart") then
                    table.insert(results, inner)
                end
            end
        end
    end
    return results
end

function F.newStumps(treeClass)
    local results = {}
    local folder = Workspace:FindFirstChild("LogModels")
    if not folder then
        return results
    end
    for _, model in ipairs(folder:GetChildren()) do
        if not preChopLogs[model] and model:IsA("Model") then
            local classValue = model:FindFirstChild("TreeClass")
            if classValue and classValue.Value == treeClass then
                local inner = model:FindFirstChild("InnerWood")
                if inner and inner:IsA("BasePart") then
                    table.insert(results, inner)
                end
            end
        end
    end
    return results
end

function F.treeHasFallen(treeClass)
    local folder = Workspace:FindFirstChild("LogModels")
    if not folder then
        return false
    end
    for _, model in ipairs(folder:GetChildren()) do
        if not preChopLogs[model] and model:IsA("Model") then
            local classValue = model:FindFirstChild("TreeClass")
            if classValue and classValue.Value == treeClass then
                return true
            end
        end
    end
    return false
end

function F.findRemote(folderName, remoteName)
    local folder = ReplicatedStorage:FindFirstChild(folderName)
    return folder and folder:FindFirstChild(remoteName)
end

function F.cutEventFor(section)
    local current = section
    while current and current ~= Workspace do
        local cutEvent = current:FindFirstChild("CutEvent")
        if cutEvent then
            return cutEvent
        end
        current = current.Parent
    end
    return nil
end

function F.fireCut(section, tool, axeName, treeClass, height, shouldStop, fireDelay)
    if not section or not section.Parent then
        return
    end
    local id = section:FindFirstChild("ID")
    local cutEvent = F.cutEventFor(section)
    local remote = F.findRemote("Interaction", "RemoteProxy")
    if not id or not cutEvent or not remote then
        return
    end
    local args = {
        sectionId = id.Value,
        faceVector = Vector3.new(0, 0, -1),
        height = height,
        hitPoints = F.axeDamage(axeName, treeClass),
        cooldown = 0,
        cuttingClass = "Axe",
        tool = tool,
    }
    for _ = 1, FIRES_PER_SECTION do
        if not section.Parent then
            break
        end
        if shouldStop and shouldStop() then
            break
        end
        remote:FireServer(cutEvent, args)
        task.wait(fireDelay or FIRE_DELAY)
    end
end

function F.cutHeightFrac(sizeY)
    return math.clamp(0.1 + (8 - sizeY) / 60, 0.1, 0.2)
end

function F.stopLock()
    if lockConn then
        lockConn:Disconnect()
        lockConn = nil
    end
end

function F.cleanupChop()
    chopping = false
    F.stopLock()
    if diedConn then
        diedConn:Disconnect()
        diedConn = nil
    end
    local rootPart = F.currentRoot()
    if rootPart and preChopCFrame then
        rootPart.CFrame = preChopCFrame
        rootPart.AssemblyLinearVelocity = Vector3.zero
    end
    Player.CameraMode = Enum.CameraMode.Classic
    local camera = F.currentCamera()
    if camera and preChopCamera then
        camera.CFrame = preChopCamera
    end
    preChopCFrame = nil
    preChopCamera = nil
end

function F.waitForRespawn(token)
    local character = Player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not character or not humanoid or humanoid.Health <= 0 then
        Player.CharacterAdded:Wait()
    end
    local deadline = os.clock() + 30
    repeat
        if not F.alive(token) then
            return false
        end
        task.wait(0.1)
        character = Player.Character
        humanoid = character and character:FindFirstChildOfClass("Humanoid")
    until (character and humanoid and humanoid.Health > 0 and character:FindFirstChild("HumanoidRootPart"))
        or os.clock() > deadline
    task.wait(RESPAWN_DELAY)
    return F.alive(token)
end

function F.lastInteraction(model)
    local owner = model:FindFirstChild("Owner")
    if owner then
        local value = owner:FindFirstChild("LastInteraction")
        if value then
            return value
        end
    end
    return model:FindFirstChild("LastInteraction")
end

function F.teleportPart(target, goal, token, returnToOrigin, moveToken, stillGoing)
    local function going()
        if stillGoing and not stillGoing() then
            return false
        end
        return F.alive(token) and (moveToken == nil or moveToken == moveGen)
    end
    if not target or not target.Parent or not going() then
        return
    end
    local drag = F.findRemote("Interaction", "ClientIsDragging")
    local rootPart = F.currentRoot()
    if not drag or not rootPart then
        return
    end
    local model = target:FindFirstAncestorOfClass("Model") or target.Parent
    local saved = rootPart.CFrame
    local function finish()
        if returnToOrigin and F.alive(token) then
            local back = F.currentRoot()
            if back then
                back.CFrame = saved
            end
        end
    end
    local flat = (rootPart.Position - target.Position) * Vector3.new(1, 0, 1)
    if flat.Magnitude > 10 then
        rootPart.CFrame = CFrame.new(target.Position + Vector3.new(0, 3, 0))
    end

    local owner = model:FindFirstChild("Owner")
    local ownerString = owner and owner:FindFirstChild("OwnerString")
    if ownerString and ownerString.Value ~= Player.Name then
        for attempt = 1, 5 do
            local deadline = os.clock() + (0.25 * attempt)
            while os.clock() < deadline do
                if not going() or not target.Parent then
                    finish()
                    return
                end
                pcall(function()
                    drag:FireServer(model)
                end)
                task.wait()
            end
            if not going() then
                finish()
                return
            end
            if target.Parent then
                target.CFrame = goal
            end
            task.wait(0.2)
            if target.Parent and (target.Position - goal.Position).Magnitude < 2 then
                break
            end
        end
        task.wait(0.1)
    else
        task.wait(0.05)
        if not going() then
            finish()
            return
        end
        local touched = F.lastInteraction(model)
        if touched then
            local thread = coroutine.running()
            local fired = false
            local conn = touched:GetPropertyChangedSignal("Value"):Connect(function()
                if not fired then
                    fired = true
                    task.spawn(thread)
                end
            end)
            local loop = task.spawn(function()
                local deadline = os.clock() + 1
                while not fired and os.clock() < deadline and going() do
                    pcall(function()
                        drag:FireServer(model)
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
            pcall(function()
                task.cancel(loop)
            end)
        else
            local deadline = os.clock() + 0.5
            while os.clock() < deadline and going() do
                pcall(function()
                    drag:FireServer(model)
                end)
                task.wait()
            end
        end
        if not going() then
            finish()
            return
        end
        if target.Parent then
            target.CFrame = goal
        end
        task.wait(0.1)
    end

    finish()
end

function F.teleportMany(parts, goalFor, token, gen)
    if gen ~= nil and gen ~= moveGen then
        return
    end
    teleporting = true
    local active = gen or moveGen
    for index, part in ipairs(parts) do
        if not F.alive(token) or active ~= moveGen then
            break
        end
        if part and part.Parent then
            F.teleportPart(part, goalFor(index, part), token, true, active)
        end
    end
    if active == moveGen then
        teleporting = false
    end
end

function F.waitForLogs(treeClass, token)
    local folder = Workspace:FindFirstChild("LogModels")
    if not folder then
        task.wait(1.5)
        return
    end
    local woods = {}
    for _, model in ipairs(folder:GetChildren()) do
        if not preChopLogs[model] and model:IsA("Model") then
            local classValue = model:FindFirstChild("TreeClass")
            if classValue and classValue.Value == treeClass then
                local inner = model:FindFirstChild("InnerWood")
                if inner and inner:IsA("BasePart") then
                    table.insert(woods, inner)
                end
            end
        end
    end
    if #woods == 0 then
        task.wait(1.5)
        return
    end
    local deadline = os.clock() + 10
    local stableFrom
    while os.clock() < deadline and F.alive(token) do
        local still = true
        for _, inner in ipairs(woods) do
            if inner.Parent and inner.AssemblyLinearVelocity.Magnitude > 0.5 then
                still = false
                break
            end
        end
        if still then
            if not stableFrom then
                stableFrom = os.clock()
            elseif os.clock() - stableFrom >= 0.3 then
                return
            end
        else
            stableFrom = nil
        end
        task.wait(0.05)
    end
end

function F.invokeDialog(remote, npcArg, action)
    local thread = coroutine.running()
    local done = false
    local worker = task.spawn(function()
        pcall(function()
            remote:InvokeServer(npcArg, action)
        end)
        if not done then
            done = true
            task.spawn(thread)
        end
    end)
    task.delay(7, function()
        if not done then
            done = true
            pcall(function()
                task.cancel(worker)
            end)
            task.spawn(thread)
        end
    end)
    coroutine.yield()
end

local bridgeId

function F.payBridgeToll(token)
    local bridge = Workspace:FindFirstChild("Bridge")
    local booth = bridge and bridge:FindFirstChild("TollBooth0")
    local seranok = booth and booth:FindFirstChild("Seranok")
    if not seranok then
        F.warnJell("Seranok not found")
        return
    end
    local rootPart = F.currentRoot()
    if not rootPart or not F.alive(token) then
        return
    end
    local npcRoot = seranok:FindFirstChild("HumanoidRootPart")
    if npcRoot then
        rootPart.CFrame = CFrame.new(npcRoot.Position + Vector3.new(3, 0, 0))
    else
        rootPart.CFrame = seranok:GetPivot() * CFrame.new(3, 0, 0)
    end
    rootPart.AssemblyLinearVelocity = Vector3.zero
    task.wait(0.1)
    if not seranok:FindFirstChild("Dialog") then
        Instance.new("Dialog", seranok)
    end
    local prompt = F.findRemote("NPCDialog", "PromptChat")
    local chat = F.findRemote("NPCDialog", "PlayerChatted")
    if not prompt or not chat then
        return
    end
    if not bridgeId then
        local lastData
        local conn = prompt.OnClientEvent:Connect(function(_, data)
            if data then
                lastData = data
            end
        end)
        pcall(function()
            prompt:FireServer(true, seranok, seranok.Dialog)
        end)
        local deadline = os.clock() + 5
        repeat
            task.wait(0.05)
        until lastData or os.clock() > deadline or not F.alive(token)
        conn:Disconnect()
        pcall(function()
            prompt:FireServer(false, seranok, seranok.Dialog)
        end)
        task.wait(0.1)
        if not lastData then
            F.warnJell("Failed to get Seranok id")
            return
        end
        bridgeId = lastData.ID
    end
    local npcArg = {
        ID = bridgeId,
        Character = seranok,
        Name = "Seranok",
        Dialog = seranok.Dialog,
    }
    F.invokeDialog(chat, npcArg, "Initiate")
    task.wait(0.05)
    F.invokeDialog(chat, npcArg, "ConfirmPurchase")
    task.wait(0.05)
    F.invokeDialog(chat, npcArg, "EndChat")
    task.wait(1.5)
end

function F.chopTree(treeClass, token)
    if not F.alive(token) or chopping then
        return
    end
    F.snapshotLogs()
    local model = F.findPriorityTree(treeClass)
    if not model then
        F.setStatus("No trees")
        return
    end
    local tool, axeName = F.bestAxe(treeClass, false)
    if not tool then
        F.setStatus("No axe")
        return
    end
    local rootPart = F.currentRoot()
    local camera = F.currentCamera()
    if not rootPart or not camera then
        return
    end
    preChopCFrame = rootPart.CFrame
    preChopCamera = camera.CFrame
    chopping = true
    F.setStatus("Chopping")

    if treeClass == "LoneCave" then
        F.payBridgeToll(token)
        if not F.alive(token) or not chopping then
            F.cleanupChop()
            return
        end
    end

    local target = F.baseSection(model)
    rootPart = F.currentRoot()
    if not target or not rootPart then
        F.cleanupChop()
        return
    end
    rootPart.CFrame = target.CFrame
    rootPart.AssemblyLinearVelocity = Vector3.zero

    local function startLock()
        F.stopLock()
        lockConn = RunService.Heartbeat:Connect(function()
            local part = F.currentRoot()
            if part and target and target.Parent and chopping then
                part.CFrame = target.CFrame
                part.AssemblyLinearVelocity = Vector3.zero
            end
        end)
    end

    local playerDied = false
    local function hookDied()
        if diedConn then
            diedConn:Disconnect()
            diedConn = nil
        end
        local humanoid = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if not humanoid then
            return
        end
        diedConn = humanoid.Died:Connect(function()
            playerDied = true
            F.stopLock()
        end)
    end

    hookDied()
    startLock()
    task.wait(SYNC_DELAY)

    while F.alive(token) and chopping and not F.treeHasFallen(treeClass) do
        if playerDied then
            F.stopLock()
            if not F.waitForRespawn(token) or not chopping or F.treeHasFallen(treeClass) then
                break
            end
            tool, axeName = F.bestAxe(treeClass, false)
            if not tool then
                F.setStatus("No axe")
                break
            end
            local resumed = F.currentRoot()
            if resumed and target and target.Parent then
                resumed.CFrame = target.CFrame
                resumed.AssemblyLinearVelocity = Vector3.zero
            end
            playerDied = false
            hookDied()
            startLock()
            task.wait(SYNC_DELAY)
        end
        if not target or not target.Parent then
            target = F.baseSection(model)
            if not target then
                break
            end
        end
        F.fireCut(target, tool, axeName, treeClass, target.Size.Y * F.cutHeightFrac(target.Size.Y), function()
            return F.treeHasFallen(treeClass) or playerDied or not F.alive(token) or not chopping
        end)
        task.wait(SWEEP_DELAY)
    end

    local finished = F.alive(token) and chopping
    F.cleanupChop()
    if not finished then
        return
    end
    task.wait(0.3)
    F.waitForLogs(treeClass, token)
    local stumps = F.newStumps(treeClass)
    local dropRoot = F.currentRoot()
    if #stumps > 0 and dropRoot and F.alive(token) then
        F.setStatus("Teleporting")
        F.teleportMany(stumps, function(index)
            return dropRoot.CFrame * CFrame.new((index - 1) * 5, 0, -LOG_DROP)
        end, token)
    end
end

function F.chopOwnedLogs(token)
    local folder = Workspace:FindFirstChild("LogModels")
    if not folder then
        F.setStatus("No logs")
        return
    end
    local queue = {}
    for _, model in ipairs(folder:GetChildren()) do
        if model:IsA("Model") and F.isOwned(model) then
            table.insert(queue, model)
        end
    end
    if #queue == 0 then
        F.setStatus("No logs")
        return
    end
    chopLogs = true
    F.setStatus("Chopping logs")

    local function countOf(model)
        return F.sectionCount(model, true)
    end

    local function stumpOf(model)
        local inner = model:FindFirstChild("InnerWood", true)
        if not inner then
            return nil
        end
        for _, desc in ipairs(model:GetDescendants()) do
            if desc:IsA("Weld") or desc:IsA("ManualWeld") then
                if desc.Part0 == inner and desc.Part1 and desc.Part1.Name == "WoodSection" then
                    return desc.Part1
                end
                if desc.Part1 == inner and desc.Part0 and desc.Part0.Name == "WoodSection" then
                    return desc.Part0
                end
            end
        end
        return nil
    end

    while #queue > 0 and chopLogs and F.alive(token) do
        local model = table.remove(queue, 1)
        if model and model.Parent then
            local classValue = model:FindFirstChild("TreeClass")
            local treeClass = classValue and classValue.Value or "Generic"
            local tool, axeName = F.bestAxe(treeClass, false)
            local stump = stumpOf(model)
            if tool then
                while model.Parent and countOf(model) > 1 and chopLogs and F.alive(token) do
                    local links = {}
                    for _, desc in ipairs(model:GetDescendants()) do
                        if (desc:IsA("Weld") or desc:IsA("ManualWeld")) and desc.Name == "Tree Weld" then
                            local part0 = desc.Part0
                            local part1 = desc.Part1
                            if part0 and part1 and part0.Name == "WoodSection" and part1.Name == "WoodSection" then
                                links[part0] = (links[part0] or 0) + 1
                                links[part1] = (links[part1] or 0) + 1
                            end
                        end
                    end
                    local tip
                    for section, count in pairs(links) do
                        if count == 1 and section ~= stump and section.Parent then
                            tip = section
                            break
                        end
                    end
                    if not tip then
                        break
                    end
                    local weld
                    local parent
                    for _, desc in ipairs(model:GetDescendants()) do
                        if (desc:IsA("Weld") or desc:IsA("ManualWeld")) and desc.Name == "Tree Weld" then
                            if desc.Part0 == tip and desc.Part1 and desc.Part1.Name == "WoodSection" then
                                weld = desc
                                parent = desc.Part1
                                break
                            end
                            if desc.Part1 == tip and desc.Part0 and desc.Part0.Name == "WoodSection" then
                                weld = desc
                                parent = desc.Part0
                                break
                            end
                        end
                    end
                    if not weld or not parent then
                        break
                    end
                    local cutSection = parent:FindFirstChild("ID") and parent or tip
                    local joint = (weld.Part0.CFrame * weld.C0).Position
                    local localY = (cutSection.CFrame:Inverse() * CFrame.new(joint)).Position.Y
                    local height = math.clamp(localY + cutSection.Size.Y / 2, 0.05, cutSection.Size.Y - 0.05)
                    local rootPart = F.currentRoot()
                    if rootPart then
                        rootPart.CFrame = CFrame.new(joint + cutSection.CFrame.RightVector * 4)
                        rootPart.AssemblyLinearVelocity = Vector3.zero
                        task.wait(0.1)
                    end
                    local before = {}
                    for _, child in ipairs(folder:GetChildren()) do
                        before[child] = true
                    end
                    F.fireCut(cutSection, tool, axeName, treeClass, height, function()
                        return not chopLogs or not F.alive(token)
                    end)
                    task.wait(0.1)
                    for _, child in ipairs(folder:GetChildren()) do
                        if not before[child] and child:IsA("Model") and F.isOwned(child) and countOf(child) > 1 then
                            table.insert(queue, child)
                        end
                    end
                end
            end
        end
    end
    chopLogs = false
end

function F.marksFolder()
    if markFolder and markFolder.Parent then
        return markFolder
    end
    local parent = Player:FindFirstChildOfClass("PlayerGui")
    if not parent then
        pcall(function()
            parent = Services.CoreGui
        end)
    end
    if not parent then
        return nil
    end
    local folder = Instance.new("Folder")
    folder.Name = "TreeCutterMarks"
    folder.Parent = parent
    markFolder = folder
    return folder
end

function F.makeMark(name, color, adornee)
    local mark = Instance.new("Highlight")
    mark.Name = name
    mark.FillColor = color
    mark.OutlineColor = color
    mark.FillTransparency = 0.35
    mark.OutlineTransparency = 0
    mark.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    mark.Enabled = false
    if adornee then
        mark.Adornee = adornee
        mark.Enabled = true
    end
    local folder = F.marksFolder()
    if folder then
        mark.Parent = folder
    end
    return mark
end

function F.bindMark(mark, adornee)
    if not mark then
        return
    end
    if adornee then
        mark.Adornee = adornee
        mark.Enabled = true
        return
    end
    mark.Enabled = false
    mark.Adornee = nil
end

function F.clearSellOutline()
    if sellOutline then
        sellOutline:Destroy()
        sellOutline = nil
    end
    sellHover = nil
end

function F.showSellOutline(model)
    if sellHover == model then
        return
    end
    F.clearSellOutline()
    sellHover = model
    sellOutline = F.makeMark("TreeCutterSell", SELL_COLOR, model)
end

function F.ownedPlank(part)
    if not part then
        return nil
    end
    local playerModels = Workspace:FindFirstChild("PlayerModels")
    if not playerModels then
        return nil
    end
    local current = part
    while current and current ~= Workspace do
        if current:IsA("Model") and current.Name == "Plank" and current.Parent == playerModels then
            if F.isOwned(current) then
                return current
            end
            return nil
        end
        current = current.Parent
    end
    return nil
end

function F.disableSell()
    sellGen = sellGen + 1
    sellBusy = false
    F.clearBucket(sellConns)
    F.clearSellOutline()
end

function F.enableSell()
    F.disableSell()
    local gen = sellGen
    local token = session
    F.track(sellConns, RunService.RenderStepped:Connect(function()
        if gen ~= sellGen or not clickToSell or modding or modSawmill then
            if modding or modSawmill then
                F.clearSellOutline()
            end
            return
        end
        if sellBusy then
            F.clearSellOutline()
            return
        end
        local plank = F.ownedPlank(Player:GetMouse().Target)
        if plank then
            F.showSellOutline(plank)
        else
            F.clearSellOutline()
        end
    end))
    F.track(sellConns, UserInputService.InputBegan:Connect(function(input, processed)
        if processed or gen ~= sellGen or sellBusy or not clickToSell or modding or modSawmill then
            return
        end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return
        end
        local plank = sellHover
        if not plank or not plank.Parent then
            return
        end
        F.clearSellOutline()
        sellBusy = true
        task.spawn(function()
            local target = plank.PrimaryPart
            if not target then
                for _, desc in ipairs(plank:GetDescendants()) do
                    if desc:IsA("BasePart") then
                        target = desc
                        break
                    end
                end
            end
            if target and F.alive(token) and gen == sellGen then
                F.teleportPart(target, PLANK_SELL_CF, token, true)
                local deadline = os.clock() + PLANK_LOCK_TIME
                while os.clock() < deadline and target.Parent and gen == sellGen and F.alive(token) do
                    target.CFrame = PLANK_SELL_CF
                    target.AssemblyLinearVelocity = Vector3.zero
                    target.AssemblyAngularVelocity = Vector3.zero
                    RunService.Heartbeat:Wait()
                end
            end
            if gen == sellGen then
                sellBusy = false
            end
        end)
    end))
end

function F.plankClass(model)
    local treeClass = model:FindFirstChild("TreeClass")
    if treeClass and treeClass:IsA("StringValue") then
        return treeClass.Value
    end
    for _, desc in ipairs(model:GetDescendants()) do
        if desc.Name == "TreeClass" and desc:IsA("StringValue") then
            return desc.Value
        end
    end
    return nil
end

function F.plankSection(model)
    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("BasePart") and desc:FindFirstChild("ID") then
            return desc
        end
    end
    return nil
end

function F.cutStep(section)
    return math.max(0.5, 1 / math.min(section.Size.X, section.Size.Z))
end

function F.cutHeights(section)
    local step = F.cutStep(section)
    local heights = {}
    local height = step
    while height <= section.Size.Y - CUT_MIN_LEFTOVER + 0.001 do
        table.insert(heights, height)
        height = height + step
    end
    return heights, step
end

function F.plankEligible(section, treeClass)
    if not section then
        return false
    end
    local heights = F.cutHeights(section)
    if #heights == 0 or #heights > CUT_MAX_UNITS then
        return false
    end
    if treeClass == "LoneCave" then
        local tool = F.bestAxe("LoneCave", true)
        if not tool then
            return false
        end
    end
    return true
end

function F.clearCutPlanes()
    for _, entry in ipairs(cutterPlanes) do
        entry.part:Destroy()
    end
    table.clear(cutterPlanes)
    cutterTracked = nil
end

function F.clearCutterMarks()
    for _, box in pairs(cutterMarks) do
        box:Destroy()
    end
    table.clear(cutterMarks)
end

function F.hideCutterStatus()
    if cutterStatus then
        cutterStatus:Destroy()
        cutterStatus = nil
    end
end

function F.disableCutter()
    cutterGen = cutterGen + 1
    cutterCutting = false
    cutterTarget = nil
    table.clear(cutterQueue)
    F.clearBucket(cutterConns)
    F.clearCutPlanes()
    F.clearCutterMarks()
    F.hideCutterStatus()
    if cutterOutline then
        cutterOutline:Destroy()
        cutterOutline = nil
    end
    cutterTimes = 0
    cutterTimeTotal = 0
end

function F.ensureCutterOutline()
    if cutterOutline and cutterOutline.Parent then
        return
    end
    cutterOutline = F.makeMark("TreeCutterOutline", CUT_COLOR)
end

function F.showCutterOutline(model)
    if not model then
        F.hideCutterOutline()
        return
    end
    F.ensureCutterOutline()
    F.bindMark(cutterOutline, model)
end

function F.hideCutterOutline()
    F.bindMark(cutterOutline, nil)
end

function F.rebuildPlanes(section)
    F.clearCutPlanes()
    if not section or not section.Parent then
        return
    end
    local heights = F.cutHeights(section)
    local sizeY = section.Size.Y
    for _, height in ipairs(heights) do
        local localCF = CFrame.new(0, -sizeY / 2 + height, 0)
        local part = Instance.new("Part")
        part.Name = "TreeCutterPlane"
        part.Anchored = true
        part.CanCollide = false
        part.CanTouch = false
        part.CanQuery = false
        part.CastShadow = false
        part.Size = Vector3.new(section.Size.X + 0.4, 0.12, section.Size.Z + 0.4)
        part.Color = CUT_COLOR
        part.Material = Enum.Material.Neon
        part.Transparency = 0.05
        part.CFrame = section.CFrame * localCF
        part.Parent = Workspace
        table.insert(cutterPlanes, {
            part = part,
            localCF = localCF,
        })
    end
    cutterTracked = section
end

function F.markQueued(plank)
    if not plank or cutterMarks[plank] then
        return
    end
    local box = F.makeMark("TreeCutterQueue", QUEUE_COLOR, plank)
    cutterMarks[plank] = box
end

function F.unmark(plank)
    local box = cutterMarks[plank]
    if box then
        box:Destroy()
        cutterMarks[plank] = nil
    end
end

function F.queuePlank(plank)
    if not plank or plank == cutterTarget then
        return
    end
    for _, queued in ipairs(cutterQueue) do
        if queued == plank then
            return
        end
    end
    table.insert(cutterQueue, plank)
    F.markQueued(plank)
end

function F.popQueued()
    while #cutterQueue > 0 do
        local plank = table.remove(cutterQueue, 1)
        F.unmark(plank)
        if plank and plank.Parent then
            local section = F.plankSection(plank)
            if section and F.plankEligible(section, F.plankClass(plank)) then
                return plank
            end
        end
    end
    return nil
end

function F.showCutterStatus(text)
    F.hideCutterStatus()
    local rootPart = F.currentRoot()
    if not rootPart then
        return nil
    end
    local board = Instance.new("BillboardGui")
    board.Name = "TreeCutterCutStatus"
    board.Size = UDim2.fromOffset(220, 36)
    board.StudsOffset = Vector3.new(0, 4, 0)
    board.AlwaysOnTop = true
    board.Adornee = rootPart
    board.Parent = rootPart
    local label = F.make("TextLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(18, 18, 18),
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Font = Enum.Font.SourceSans,
        Text = text,
        TextSize = 16,
        TextColor3 = TEXT,
    }, board)
    cutterStatus = board
    return label
end

function F.teleportAbove(section, cutHeight)
    local rootPart = F.currentRoot()
    if not rootPart or not section or not section.Parent then
        return
    end
    local world = (section.CFrame * CFrame.new(0, -section.Size.Y / 2 + (cutHeight or 0) + 3, 0)).Position
    if (rootPart.Position - world).Magnitude <= CUT_DETECT then
        return
    end
    rootPart.CFrame = CFrame.new(world)
    rootPart.AssemblyLinearVelocity = Vector3.zero
    rootPart.AssemblyAngularVelocity = Vector3.zero
end

function F.fireUntilSplit(section, tool, damage, height, gen)
    local id = section:FindFirstChild("ID")
    local cutEvent = F.cutEventFor(section)
    local remote = F.findRemote("Interaction", "RemoteProxy")
    if not id or not cutEvent or not remote then
        return nil
    end
    local playerModels = Workspace:FindFirstChild("PlayerModels")
    local snapshot = {}
    if playerModels then
        for _, model in ipairs(playerModels:GetChildren()) do
            snapshot[model] = true
        end
    end
    local args = {
        sectionId = id.Value,
        faceVector = Vector3.new(0, 0, -1),
        height = height,
        hitPoints = damage,
        cooldown = 0,
        cuttingClass = "Axe",
        tool = tool,
    }
    local lastPos = section.Position
    local originalY = section.Size.Y
    local deadline = os.clock() + CUT_TIMEOUT
    local function findNew()
        if not playerModels then
            return nil
        end
        for _, model in ipairs(playerModels:GetChildren()) do
            if not snapshot[model] and model:IsA("Model") and model.Name == "Plank" and F.isOwned(model) then
                local sectionPart = F.plankSection(model)
                if sectionPart and (sectionPart.Position - lastPos).Magnitude <= CUT_DETECT then
                    return sectionPart
                end
            end
        end
        return nil
    end
    local function awaitPiece()
        for _ = 1, 5 do
            local found = findNew()
            if found then
                return found
            end
            task.wait()
        end
        return findNew()
    end
    while os.clock() < deadline and gen == cutterGen and cutterOn do
        if section.Parent then
            lastPos = section.Position
        else
            return awaitPiece()
        end
        remote:FireServer(cutEvent, args)
        task.wait(CUT_FIRE_DELAY)
        if not section.Parent or section.Size.Y ~= originalY then
            return awaitPiece()
        end
    end
    return nil
end

function F.cutPlank(plank, gen)
    if gen ~= cutterGen or not cutterOn then
        return
    end
    cutterCutting = true
    cutterTarget = plank
    F.showCutterOutline(plank)
    local treeClass = F.plankClass(plank)
    local tool, _, damage = F.bestAxe(treeClass, true)
    local section = F.plankSection(plank)
    if not tool or not section then
        cutterCutting = false
        cutterTarget = nil
        F.hideCutterOutline()
        F.clearCutPlanes()
        return
    end
    local step = F.cutStep(section)
    local heights = F.cutHeights(section)
    local cutsNeeded = #heights
    local planksTotal = cutsNeeded + 1
    local statusLbl = F.showCutterStatus(planksTotal .. " planks")
    local cutsDone = 0
    F.teleportAbove(section, step)
    task.wait()
    local current = section
    while gen == cutterGen and cutterOn and current and current.Parent do
        if current.Size.Y - step < CUT_MIN_LEFTOVER - 0.001 then
            break
        end
        F.rebuildPlanes(current)
        cutterTarget = current.Parent
        F.showCutterOutline(cutterTarget)
        F.teleportAbove(current, step)
        local startedAt = os.clock()
        local newSection = F.fireUntilSplit(current, tool, damage, step, gen)
        local elapsed = os.clock() - startedAt
        cutsDone = cutsDone + 1
        cutterTimes = cutterTimes + 1
        cutterTimeTotal = cutterTimeTotal + elapsed
        F.clearCutPlanes()
        if statusLbl and statusLbl.Parent then
            local left = math.max(0, planksTotal - cutsDone - 1)
            local eta = "--"
            if cutterTimes > 0 and cutsNeeded - cutsDone > 0 then
                local secs = math.floor((cutterTimeTotal / cutterTimes) * (cutsNeeded - cutsDone))
                local mins = math.floor(secs / 60)
                secs = secs % 60
                eta = mins > 0 and string.format("%dm %ds", mins, secs) or string.format("%ds", secs)
            elseif cutsNeeded - cutsDone <= 0 then
                eta = "done"
            end
            local queued = #cutterQueue > 0 and ("  +" .. tostring(#cutterQueue)) or ""
            statusLbl.Text = left .. " planks  " .. eta .. queued
        end
        if not newSection then
            break
        end
        local nextPiece = current
        if not (current.Parent and current.Size.Y > newSection.Size.Y) then
            nextPiece = newSection
        end
        if nextPiece and nextPiece.Parent then
            current = nextPiece
            cutterTarget = nextPiece.Parent
            F.showCutterOutline(cutterTarget)
        end
    end
    cutterTimes = 0
    cutterTimeTotal = 0
    F.clearCutPlanes()
    F.hideCutterStatus()
    cutterCutting = false
    if gen == cutterGen and cutterOn then
        local nextPlank = F.popQueued()
        if nextPlank then
            task.spawn(F.cutPlank, nextPlank, gen)
        else
            cutterTarget = nil
            F.hideCutterOutline()
        end
    end
end

function F.enableCutter()
    F.disableCutter()
    local gen = cutterGen
    local lastSection
    F.track(cutterConns, RunService.Heartbeat:Connect(function()
        if gen ~= cutterGen or not cutterTracked or not cutterTracked.Parent then
            return
        end
        local cf = cutterTracked.CFrame
        for _, entry in ipairs(cutterPlanes) do
            if entry.part.Parent then
                entry.part.CFrame = cf * entry.localCF
            end
        end
    end))
    F.track(cutterConns, RunService.RenderStepped:Connect(function()
        if gen ~= cutterGen or cutterCutting or not cutterOn then
            return
        end
        local target = Player:GetMouse().Target
        local plank = F.ownedPlank(target)
        if plank then
            local section = F.plankSection(plank)
            local treeClass = F.plankClass(plank)
            if section and F.plankEligible(section, treeClass) then
                if cutterTarget ~= plank then
                    cutterTarget = plank
                    F.showCutterOutline(plank)
                end
                if section ~= lastSection then
                    lastSection = section
                    F.rebuildPlanes(section)
                end
                return
            end
        end
        local keep = cutterTarget and target and target:IsDescendantOf(cutterTarget)
        if not keep and cutterTarget then
            cutterTarget = nil
            F.hideCutterOutline()
            F.clearCutPlanes()
            lastSection = nil
        end
    end))
    F.track(cutterConns, Player:GetMouse().Button1Down:Connect(function()
        if gen ~= cutterGen or not cutterOn or modding or modSawmill then
            return
        end
        local window = root
        while window and window.Name ~= "Window" do
            window = window.Parent
        end
        if window then
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
            if x >= pos.X and x <= pos.X + size.X and y >= pos.Y and y <= pos.Y + size.Y then
                return
            end
        end
        local plank = F.ownedPlank(Player:GetMouse().Target)
        if not plank then
            return
        end
        local section = F.plankSection(plank)
        if not F.plankEligible(section, F.plankClass(plank)) then
            return
        end
        if cutterCutting then
            F.queuePlank(plank)
        else
            task.spawn(F.cutPlank, plank, gen)
        end
    end))
end

function F.woodVolume(model)
    local total = 0
    for _, part in ipairs(model:GetChildren()) do
        if part.Name == "WoodSection" and part:IsA("BasePart") then
            total = total + part.Size.X * part.Size.Y * part.Size.Z
        end
    end
    return total
end

function F.formatMoney(amount)
    local text = tostring(math.floor(amount + 0.5))
    local out = ""
    local len = #text
    for index = 1, len do
        if index > 1 and (len - index + 1) % 3 == 0 then
            out = out .. ","
        end
        out = out .. string.sub(text, index, index)
    end
    return "$" .. out
end

function F.hoverInfo(model)
    if not model or not model.Parent then
        return nil
    end
    local volume = F.woodVolume(model)
    if volume <= 0 then
        return nil
    end
    local classValue = model:FindFirstChild("TreeClass")
    local treeClass = classValue and classValue.Value or nil
    local parentName = model.Parent.Name
    if F.isTreeRegion(parentName) then
        return F.formatMoney(volume * (TREE_RATES[treeClass or ""] or 1)), (treeClass or "Unknown") .. " tree"
    end
    if parentName == "PlayerModels" then
        return F.formatMoney(volume * ((treeClass and PLANK_RATES[treeClass]) or 1)), (treeClass or "Unknown") .. " plank"
    end
    if parentName == "LogModels" then
        return F.formatMoney(volume * ((treeClass and TREE_RATES[treeClass]) or 1)), (treeClass or "Unknown") .. " log"
    end
    return nil
end

function F.destroyHover()
    if hoverBillboard then
        hoverBillboard:Destroy()
        hoverBillboard = nil
    end
end

function F.hideHover()
    F.destroyHover()
    hoverModel = nil
end

function F.showHover(valueText, labelText)
    F.destroyHover()
    local rootPart = F.currentRoot()
    if not rootPart then
        return
    end
    local board = Instance.new("BillboardGui")
    board.Name = "TreeCutterHover"
    board.Size = UDim2.fromOffset(180, 40)
    board.StudsOffset = Vector3.new(0, 4, 0)
    board.AlwaysOnTop = true
    board.MaxDistance = 800
    board.Adornee = rootPart
    board.Parent = rootPart
    local value = F.make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 22),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSansBold,
        Text = valueText,
        TextSize = 18,
        TextColor3 = TEXT,
    }, board)
    value.Name = "Value"
    F.make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.fromOffset(0, 22),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = labelText,
        TextSize = 14,
        TextColor3 = MUTED,
    }, board)
    hoverBillboard = board
end

function F.disableHover()
    if hoverConn then
        hoverConn:Disconnect()
        hoverConn = nil
    end
    F.hideHover()
end

function F.enableHover()
    F.disableHover()
    hoverConn = RunService.RenderStepped:Connect(function()
        if not hoverOn then
            return
        end
        local target = Player:GetMouse().Target
        local model = target and target:FindFirstAncestorOfClass("Model")
        if model == hoverModel then
            return
        end
        hoverModel = model
        if not model then
            F.hideHover()
            return
        end
        local valueText, labelText = F.hoverInfo(model)
        if valueText then
            F.showHover(valueText, labelText)
        else
            F.destroyHover()
        end
    end)
end

function F.silenceSounds()
    F.clearBucket(soundConns)
    local function mute(parent)
        for _, child in ipairs(parent:GetChildren()) do
            if child.Name == "Alternate" and child:IsA("Sound") then
                child.Volume = 0
                pcall(function()
                    child:Stop()
                end)
            end
        end
        F.track(soundConns, parent.ChildAdded:Connect(function(child)
            if child.Name == "Alternate" and child:IsA("Sound") then
                child.Volume = 0
                pcall(function()
                    child:Stop()
                end)
            end
        end))
    end
    task.spawn(function()
        local playerGui = Player:FindFirstChild("PlayerGui") or Player:WaitForChild("PlayerGui", 10)
        local sounds = playerGui and playerGui:FindFirstChild("ClientSounds")
        if not sounds or not started then
            return
        end
        local function consider(child)
            if child.Name == "Region_Main" or child.Name == "Region_Mountain" then
                mute(child)
            end
        end
        for _, child in ipairs(sounds:GetChildren()) do
            consider(child)
        end
        F.track(soundConns, sounds.ChildAdded:Connect(consider))
    end)
end

function F.unwatch()
    F.clearBucket(watchConns)
end

function F.paintTree()
    if treeCaption and treeCaption.Parent then
        treeCaption.Text = selectedTree or "Select"
        treeCaption.TextColor3 = F.treeReady(selectedTree) and TEXT or MUTED
    end
end

function F.paintQuantity()
    if quantityLabel and quantityLabel.Parent then
        quantityLabel.Text = "Quantity  " .. tostring(quantity)
    end
    if quantityFill and quantityFill.Parent then
        local span = QUANTITY_MAX - QUANTITY_MIN
        quantityFill.Size = UDim2.new((quantity - QUANTITY_MIN) / span, 0, 1, 0)
    end
end

function F.paintAction(button, active, idleText, activeText)
    if not (button and button.Parent) then
        return
    end
    if active then
        button.Text = activeText
        button.BackgroundColor3 = RED
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        button.Text = idleText
        button.BackgroundColor3 = BUTTON
        button.TextColor3 = DARK
    end
end

local toggleKnobs = {}

function F.paintToggle(button, on)
    local knob = button and toggleKnobs[button]
    if not (button and button.Parent and knob) then
        return
    end
    local knobX = on and (TOGGLE_W - TOGGLE_KNOB - TOGGLE_PAD) or TOGGLE_PAD
    knob.Position = UDim2.fromOffset(knobX, (TOGGLE_H - TOGGLE_KNOB) / 2)
    button.BackgroundColor3 = on and GREEN or FIELD
end

function F.paintAll()
    F.paintTree()
    F.paintQuantity()
    F.paintAction(getBtn, chopSession, "Start", "Stop")
    F.paintAction(chopBtn, chopLogs, "Start", "Stop")
    F.paintAction(tpBtn, moveMode == "tp", "TP", "Stop")
    F.paintAction(sellBtn, moveMode == "sell", "Sell", "Stop")
    F.paintAction(modSawmillBtn, modSawmill, "Sawmill", "Stop")
    F.paintAction(modTreeBtn, modding, "Tree", "Stop")
    F.paintToggle(clickBtn, clickToSell)
    F.paintToggle(cutterBtn, cutterOn)
    F.paintToggle(hoverBtn, hoverOn)
    F.setStatus(statusText)
end

function F.closeMenu()
    menuOpen = false
    if menu then
        menu:Destroy()
        menu = nil
    end
    if backdrop then
        backdrop:Destroy()
        backdrop = nil
    end
end


function F.rescan(keepBlocked)
    local previous = selectedTree
    options, disabled = F.buildOptions()
    if not keepBlocked and previous and disabled[previous] then
        selectedTree = F.firstEnabled() or previous
    end
    if selectedTree == nil then
        selectedTree = F.firstEnabled()
    end
    F.paintTree()
    if selectedTree ~= previous then
        F.saveConfig()
    end
    if menuOpen then
        F.closeMenu()
    end
end

function F.watchTrees()
    F.unwatch()
    local function watchFolder(folder)
        F.track(watchConns, folder.ChildAdded:Connect(function()
            task.delay(0.5, function()
                if started then
                    F.rescan(false)
                end
            end)
        end))
        F.track(watchConns, folder.ChildRemoved:Connect(function()
            task.delay(0.5, function()
                if started then
                    F.rescan(false)
                end
            end)
        end))
    end
    F.eachTreeRegion(watchFolder)
    F.track(watchConns, Workspace.ChildAdded:Connect(function(child)
        if F.isTreeRegion(child.Name) then
            watchFolder(child)
            task.delay(0.5, function()
                if started then
                    F.rescan(false)
                end
            end)
        end
    end))
end

function F.saveConfig()
    if type(writefile) ~= "function" then
        return
    end
    if type(makefolder) == "function" and type(isfolder) == "function" and not isfolder(CONFIG_DIR) then
        pcall(makefolder, CONFIG_DIR)
    end
    local payload = {
        tree = selectedTree,
        quantity = quantity,
        clickToSell = clickToSell,
        cutter = cutterOn,
        hoverValue = hoverOn,
    }
    local encodedOk, encoded = pcall(function()
        return Services.HttpService:JSONEncode(payload)
    end)
    if encodedOk then
        pcall(writefile, CONFIG_FILE, encoded)
    end
end

function F.readSavedConfig()
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

function F.applySaved(data)
    if type(data) ~= "table" then
        return
    end
    if type(data.tree) == "string" and data.tree ~= "" then
        selectedTree = data.tree
    end
    local savedQuantity = tonumber(data.quantity)
    if savedQuantity then
        quantity = math.clamp(math.floor(savedQuantity + 0.5), QUANTITY_MIN, QUANTITY_MAX)
    end
    if type(data.clickToSell) == "boolean" then
        clickToSell = data.clickToSell
    end
    if type(data.cutter) == "boolean" then
        cutterOn = data.cutter
    end
    if type(data.hoverValue) == "boolean" then
        hoverOn = data.hoverValue
    end
end

F.applySaved(F.readSavedConfig())

function F.applyLiveToggles()
    if clickToSell then
        F.enableSell()
    else
        F.disableSell()
    end
    if cutterOn then
        F.enableCutter()
    else
        F.disableCutter()
    end
    if hoverOn then
        F.enableHover()
    else
        F.disableHover()
    end
end

function F.openMenu()
    F.closeMenu()
    if not root or not treeBtn then
        return
    end
    menuOpen = true
    backdrop = F.make("TextButton", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 4,
    }, root)
    backdrop.MouseButton1Click:Connect(function()
        task.defer(F.closeMenu)
    end)
    local top = treeBtn.AbsolutePosition.Y - root.AbsolutePosition.Y + treeBtn.AbsoluteSize.Y + 2
    local height = math.min(#options * 22, 220)
    menu = F.make("ScrollingFrame", {
        Size = UDim2.new(1, -16, 0, height),
        Position = UDim2.fromOffset(8, top),
        BackgroundColor3 = Color3.fromRGB(32, 32, 32),
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Color3.fromRGB(70, 70, 70),
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Active = true,
        ZIndex = 5,
    }, root)
    F.make("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, menu)
    for index, name in ipairs(options) do
        local blocked = disabled[name] == true
        local picked = name == selectedTree
        local row = F.make("TextButton", {
            Size = UDim2.new(1, 0, 0, 22),
            BackgroundColor3 = FIELD,
            BackgroundTransparency = picked and 0 or 1,
            BorderSizePixel = 0,
            Font = Enum.Font.SourceSans,
            Text = name,
            TextSize = 15,
            TextColor3 = blocked and MUTED or TEXT,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false,
            LayoutOrder = index,
            Active = not blocked,
            ZIndex = 5,
        }, menu)
        F.make("UIPadding", {
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
            if blocked then
                return
            end
            selectedTree = name
            F.paintTree()
            F.saveConfig()
            task.defer(F.closeMenu)
        end)
    end
end

function F.fieldLabel(parent, text, y)
    return F.make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.fromOffset(0, y),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = text,
        TextSize = 14,
        TextColor3 = MUTED,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, parent)
end

function F.actionButton(parent, text, y)
    return F.make("TextButton", {
        Size = UDim2.fromOffset(72, 22),
        Position = UDim2.new(1, -72, 0, y),
        BackgroundColor3 = BUTTON,
        BorderSizePixel = 0,
        Font = Enum.Font.SourceSans,
        Text = text,
        TextSize = 15,
        TextColor3 = DARK,
        AutoButtonColor = false,
    }, parent)
end

function F.toggleButton(parent)
    local track = F.make("TextButton", {
        Size = UDim2.fromOffset(TOGGLE_W, TOGGLE_H),
        Position = UDim2.new(1, -TOGGLE_W, 0, 4),
        BackgroundColor3 = FIELD,
        Text = "",
        AutoButtonColor = false,
    }, parent)
    F.make("UICorner", {
        CornerRadius = UDim.new(1, 0),
    }, track)
    F.make("UIStroke", {
        Color = Color3.fromRGB(70, 70, 70),
        Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, track)
    local knob = F.make("Frame", {
        Size = UDim2.fromOffset(TOGGLE_KNOB, TOGGLE_KNOB),
        Position = UDim2.fromOffset(TOGGLE_PAD, (TOGGLE_H - TOGGLE_KNOB) / 2),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
    }, track)
    F.make("UICorner", {
        CornerRadius = UDim.new(1, 0),
    }, knob)
    toggleKnobs[track] = knob
    return track
end

function F.block(parent, height, order)
    return F.make("Frame", {
        Size = UDim2.new(1, 0, 0, height),
        BackgroundTransparency = 1,
        LayoutOrder = order,
    }, parent)
end

function F.quantityFromX(x)
    local width = quantitySlider.AbsoluteSize.X
    if width <= 0 then
        return quantity
    end
    local alpha = math.clamp((x - quantitySlider.AbsolutePosition.X) / width, 0, 1)
    local span = QUANTITY_MAX - QUANTITY_MIN
    return math.clamp(math.floor(alpha * span + QUANTITY_MIN + 0.5), QUANTITY_MIN, QUANTITY_MAX)
end

function F.requireStarted()
    if started then
        return true
    end
    F.setStatus("Off")
    return false
end

function F.modActive(gen)
    return started and gen == modGen
end

function F.modStatus(gen, text)
    if F.modActive(gen) then
        F.setStatus(text)
    end
end

function F.clearModMarks()
    for _, mark in ipairs(modMarks) do
        mark:Destroy()
    end
    table.clear(modMarks)
end

function F.markModTree(model)
    table.insert(modMarks, F.makeMark("TreeCutterMod", MOD_COLOR, model))
end

function F.restoreModLava()
    local saved = modLava
    if not saved then
        return
    end
    modLava = nil
    for index, part in ipairs(saved.parts) do
        pcall(function()
            if part and part.Parent then
                part.Size = saved.sizes[index]
                part.CFrame = saved.cframes[index]
            end
        end)
    end
end

function F.placePlayer(cf)
    if not cf then
        return
    end
    local rootPart = F.currentRoot()
    if not rootPart then
        return
    end
    pcall(function()
        rootPart.CFrame = cf
        rootPart.AssemblyLinearVelocity = Vector3.zero
    end)
end

function F.returnModPlayer()
    local cf = modHome
    modHome = nil
    F.placePlayer(cf)
end

function F.stopMod()
    modGen = modGen + 1
    modding = false
    modSawmill = false
    F.restoreModLava()
    F.clearModMarks()
    F.returnModPlayer()
end

function F.modSleep(gen, duration)
    local deadline = os.clock() + duration
    while os.clock() < deadline do
        if not F.modActive(gen) then
            return false
        end
        task.wait()
    end
    return F.modActive(gen)
end

function F.pointerOnWindow()
    local window = root
    while window and window.Name ~= "Window" do
        window = window.Parent
    end
    if not window then
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
    return x >= pos.X and x <= pos.X + size.X and y >= pos.Y and y <= pos.Y + size.Y
end

function F.modelUnder(instance, parent)
    local current = instance
    while current and current.Parent ~= parent do
        current = current.Parent
    end
    return current
end

function F.ancestorModel(instance)
    local current = instance
    while current and not current:IsA("Model") do
        current = current.Parent
    end
    return current
end

function F.validSawmill(model)
    if not model or not model:IsA("Model") then
        return false
    end
    local itemName = model:FindFirstChild("ItemName")
    return itemName and itemName:IsA("StringValue") and SAWMILL_NAMES[itemName.Value] == true
end

function F.validModTree(model)
    if not model or not model:IsA("Model") then
        return false
    end
    local logs = Workspace:FindFirstChild("LogModels")
    if not logs or model.Parent ~= logs then
        return false
    end
    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("BasePart") and desc:FindFirstChild("ID") then
            return true
        end
    end
    return false
end

function F.sawmillFromMouse()
    local target = Player:GetMouse().Target
    local playerModels = Workspace:FindFirstChild("PlayerModels")
    if not target or not playerModels then
        return nil
    end
    local model = F.modelUnder(target, playerModels)
    if F.validSawmill(model) then
        return model
    end
    return nil
end

function F.waitMouse(gen, onClick)
    local done = false
    local conn = Player:GetMouse().Button1Down:Connect(function()
        if done or not F.modActive(gen) or F.pointerOnWindow() then
            return
        end
        if onClick() then
            done = true
        end
    end)
    while not done and F.modActive(gen) do
        task.wait()
    end
    conn:Disconnect()
end

function F.waitForSawmill(gen)
    local picked
    F.waitMouse(gen, function()
        picked = F.sawmillFromMouse()
        return picked ~= nil
    end)
    return picked
end

function F.waitForModQueue(gen)
    local queue = {}
    local queued = {}
    local sawmill
    F.waitMouse(gen, function()
        local mill = F.sawmillFromMouse()
        if mill then
            sawmill = mill
            return true
        end
        local model = F.ancestorModel(Player:GetMouse().Target)
        if not F.validModTree(model) then
            return false
        end
        if queued[model] then
            F.modStatus(gen, "Already queued")
            return false
        end
        queued[model] = true
        table.insert(queue, model)
        F.markModTree(model)
        F.modStatus(gen, "Queued " .. tostring(#queue))
        return false
    end)
    return queue, sawmill
end

function F.blueprintOffset(sawmill)
    local itemName = sawmill:FindFirstChild("ItemName")
    if itemName and itemName.Value == "Sawmill4L" then
        return TILE_OFFSET_4L
    end
    return TILE_END_OFFSET
end

function F.sawmillCF(sawmill)
    local particles = sawmill:FindFirstChild("Particles", true)
    if particles and particles:IsA("BasePart") then
        return particles.CFrame
    end
    return select(1, sawmill:GetBoundingBox())
end

function F.findBlueprint(targetCF)
    local playerModels = Workspace:FindFirstChild("PlayerModels")
    if not playerModels then
        return nil
    end
    for _, model in ipairs(playerModels:GetChildren()) do
        local itemName = model:FindFirstChild("ItemName")
        if itemName and itemName.Value == BLUEPRINT_NAME and F.isOwned(model) then
            local main = model:FindFirstChild("MainCFrame")
            local cf = (main and main.Value)
                or (model.PrimaryPart and model.PrimaryPart.CFrame)
                or model:GetPivot()
            if (cf.Position - targetCF.Position).Magnitude <= BLUEPRINT_MATCH then
                return model
            end
        end
    end
    return nil
end

function F.placeBlueprint(sawmill)
    local finalCF = F.sawmillCF(sawmill) * F.blueprintOffset(sawmill) * CFrame.Angles(math.rad(90), 0, 0)
    if F.findBlueprint(finalCF) then
        return false
    end
    local remote = F.findRemote("PlaceStructure", "ClientPlacedBlueprint")
    if not remote then
        return nil
    end
    remote:FireServer(BLUEPRINT_NAME, finalCF, Player)
    return true
end

function F.analyzeModTree(treeModel)
    local entries = {}
    for _, part in ipairs(treeModel:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "Stump" then
            local idValue = part:FindFirstChild("ID")
            if idValue and (idValue:IsA("IntValue") or idValue:IsA("NumberValue")) then
                local childIDs = {}
                local childFolder = part:FindFirstChild("ChildIDs")
                if childFolder then
                    for _, child in ipairs(childFolder:GetChildren()) do
                        if child.Name == "Child" and (child:IsA("IntValue") or child:IsA("NumberValue")) then
                            table.insert(childIDs, child.Value)
                        end
                    end
                end
                table.insert(entries, {
                    part = part,
                    id = idValue.Value,
                    childIDs = childIDs,
                    hasChildren = #childIDs > 0,
                })
            end
        end
    end
    table.sort(entries, function(a, b)
        return a.id < b.id
    end)
    local targetEntry
    for index = #entries, 1, -1 do
        if entries[index].hasChildren then
            targetEntry = entries[index]
            break
        end
    end
    local tipID
    if targetEntry then
        for _, childId in ipairs(targetEntry.childIDs) do
            if not tipID or childId > tipID then
                tipID = childId
            end
        end
    end
    return {
        all = entries,
        stump = entries[1],
        target = targetEntry,
        tipID = tipID,
    }
end

function F.lavaTouchParts()
    local parts = {}
    local volcano = Workspace:FindFirstChild("Region_Volcano")
    if not volcano then
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

function F.findModSection(treeModel, analysis, beforeLogs, targetID)
    for _, entry in ipairs(analysis.all) do
        if entry.id == targetID and entry.part and entry.part.Parent then
            return entry.part
        end
    end
    local function scan(rootInst)
        for _, desc in ipairs(rootInst:GetDescendants()) do
            if desc:IsA("BasePart") then
                local idValue = desc:FindFirstChild("ID")
                if idValue and idValue.Value == targetID then
                    return desc
                end
            end
        end
        return nil
    end
    local found = scan(treeModel)
    if found then
        return found
    end
    local logModels = Workspace:FindFirstChild("LogModels")
    if logModels then
        for _, model in ipairs(logModels:GetChildren()) do
            if not beforeLogs[model] and model:IsA("Model") then
                found = scan(model)
                if found then
                    return found
                end
            end
        end
    end
    return nil
end

function F.runOneMod(gen, sawmillCF, treeModel, index, total)
    F.modStatus(gen, string.format("Modding %d/%d", index, total))
    local analysis = F.analyzeModTree(treeModel)
    if #analysis.all == 0 then
        F.modStatus(gen, "No wood")
        return false
    end
    if not analysis.target then
        F.modStatus(gen, "No weld")
        return false
    end
    local baseSection
    for _, entry in ipairs(analysis.all) do
        if entry.id == 1 then
            baseSection = entry.part
            break
        end
    end
    if not baseSection then
        baseSection = analysis.all[1].part
    end
    if not baseSection then
        F.modStatus(gen, "No wood")
        return false
    end

    local treeClassObj = treeModel:FindFirstChild("TreeClass")
    local treeClass = treeClassObj and treeClassObj.Value or nil
    local logModels = Workspace:FindFirstChild("LogModels")
    local beforeLogs = {}
    if logModels then
        for _, model in ipairs(logModels:GetChildren()) do
            beforeLogs[model] = true
        end
    end

    if not F.modActive(gen) then
        return false
    end
    local dragged = pcall(function()
        F.teleportPart(baseSection, DROP_ZONE_CF, session, true, nil, function()
            return F.modActive(gen)
        end)
    end)
    if not dragged then
        F.modStatus(gen, "Teleport failed")
        return false
    end
    if not F.modActive(gen) or not baseSection.Parent then
        return false
    end
    pcall(function()
        baseSection.CFrame = MOD_TP_CF
    end)

    local touchParts = F.lavaTouchParts()
    if #touchParts == 0 then
        F.modStatus(gen, "No lava")
        return false
    end
    local touchSizes = {}
    local touchCFs = {}
    for partIndex, part in ipairs(touchParts) do
        touchSizes[partIndex] = part.Size
        touchCFs[partIndex] = part.CFrame
        pcall(function()
            part.Size = Vector3.new(0.1, 0.1, 0.1)
        end)
    end
    modLava = {
        parts = touchParts,
        sizes = touchSizes,
        cframes = touchCFs,
    }

    local targetSection = analysis.target.part
    local burned = false
    for attempt = 1, MOD_BURN_TRIES do
        if not F.modActive(gen) then
            break
        end
        if attempt > 1 then
            pcall(function()
                baseSection.CFrame = MOD_TP_CF
            end)
            if not F.modSleep(gen, 0.1) then
                break
            end
        end
        local lock = RunService.Heartbeat:Connect(function()
            pcall(function()
                local targetCF = targetSection.CFrame
                for _, part in ipairs(touchParts) do
                    part.Size = Vector3.new(0.1, 0.1, 0.1)
                    part.CFrame = targetCF
                end
            end)
        end)
        local lockOk = F.modSleep(gen, 0.1)
        lock:Disconnect()
        for partIndex, part in ipairs(touchParts) do
            pcall(function()
                part.Size = touchSizes[partIndex]
                part.CFrame = touchCFs[partIndex]
            end)
        end
        if not lockOk or not F.modSleep(gen, 0.1) then
            break
        end
        if treeModel:FindFirstChild("Burning") then
            burned = true
            break
        end
    end
    F.restoreModLava()
    if not F.modActive(gen) then
        return false
    end
    if not burned then
        F.modStatus(gen, "Not burning")
        return false
    end

    local tipSection = F.findModSection(treeModel, analysis, beforeLogs, analysis.tipID)
    pcall(function()
        targetSection.CFrame = CFrame.new(1279, 52, 2328)
    end)
    pcall(function()
        baseSection.CFrame = DROP_ZONE_CF
    end)
    if tipSection and tipSection.Parent then
        pcall(function()
            tipSection.CFrame = sawmillCF
        end)
        if not F.modSleep(gen, 1) then
            return false
        end
    end

    local deadline = os.clock() + MOD_DISAPPEAR
    while os.clock() < deadline do
        if not F.modActive(gen) then
            return false
        end
        if not targetSection or not targetSection.Parent then
            break
        end
        task.wait(0.1)
    end
    if not F.modActive(gen) then
        return false
    end

    local stumpID = analysis.stump and analysis.stump.id or 1
    local stumpSection = F.findModSection(treeModel, analysis, beforeLogs, stumpID)
    local tool, axeName = F.bestAxe(treeClass, false)
    if not tool then
        F.modStatus(gen, "No axe")
        return F.modActive(gen)
    end

    local initialSize = stumpSection and stumpSection.Size or Vector3.new(math.huge, math.huge, math.huge)
    local function fallen()
        if not stumpSection or not stumpSection.Parent then
            return true
        end
        return stumpSection.Size.Y < initialSize.Y - 1
    end
    local chopDeadline = os.clock() + MOD_CHOP_TIMEOUT
    while os.clock() < chopDeadline and not fallen() do
        if not F.modActive(gen) then
            return false
        end
        if not stumpSection or not stumpSection.Parent then
            stumpSection = F.findModSection(treeModel, analysis, beforeLogs, stumpID)
            if stumpSection then
                initialSize = stumpSection.Size
            end
        end
        if not stumpSection or not stumpSection.Parent then
            break
        end
        local rootPart = F.currentRoot()
        if rootPart then
            rootPart.CFrame = CFrame.lookAt(
                stumpSection.Position + stumpSection.CFrame.RightVector * 4,
                stumpSection.Position
            )
            rootPart.AssemblyLinearVelocity = Vector3.zero
            if not F.modSleep(gen, 0.1) then
                return false
            end
        end
        if not stumpSection or not stumpSection.Parent then
            break
        end
        F.fireCut(
            stumpSection,
            tool,
            axeName,
            treeClass,
            stumpSection.Size.Y * F.cutHeightFrac(stumpSection.Size.Y),
            function()
                return not F.modActive(gen) or fallen()
            end,
            MOD_FIRE_DELAY
        )
    end
    return F.modActive(gen)
end

function F.runMod(gen)
    if not F.modActive(gen) then
        return
    end
    local rootPart = F.currentRoot()
    modHome = rootPart and rootPart.CFrame
    F.modStatus(gen, "Click trees, then sawmill")
    local queue, sawmill = F.waitForModQueue(gen)
    F.clearModMarks()
    if not F.modActive(gen) then
        return
    end
    if not sawmill or #queue == 0 then
        F.modStatus(gen, sawmill and "No trees" or "No sawmill")
        return
    end
    local goal = F.sawmillCF(sawmill)
    local success = 0
    local lastFailed = false
    for index, treeModel in ipairs(queue) do
        if not F.modActive(gen) then
            return
        end
        local ok = false
        if treeModel and treeModel.Parent then
            ok = F.runOneMod(gen, goal, treeModel, index, #queue)
        else
            F.modStatus(gen, "No wood")
        end
        if not F.modActive(gen) then
            return
        end
        if ok then
            success = success + 1
            lastFailed = false
        else
            lastFailed = true
        end
        if index < #queue and not F.modSleep(gen, 1) then
            return
        end
    end
    if not F.modActive(gen) then
        return
    end
    F.placePlayer(goal * CFrame.new(0, 8, 6))
    modHome = nil
    if not (lastFailed and #queue == 1) then
        F.modStatus(gen, string.format("Modded %d/%d", success, #queue))
    end
end

function F.runModSawmill(gen)
    F.modStatus(gen, "Click sawmill")
    local sawmill = F.waitForSawmill(gen)
    if not F.modActive(gen) then
        return
    end
    if not sawmill then
        F.modStatus(gen, "No sawmill")
        return
    end
    local ok, placed = pcall(F.placeBlueprint, sawmill)
    if not ok or placed == nil then
        F.modStatus(gen, "Place failed")
        return
    end
    F.modStatus(gen, placed and "Blueprint placed" or "Already placed")
end

function F.modOccupied()
    return modding or modSawmill or chopSession or chopLogs or chopping or teleporting
end

function F.beginMod(kind)
    if not F.requireStarted() then
        return nil
    end
    if F.modOccupied() then
        F.setStatus("Busy")
        return nil
    end
    modGen = modGen + 1
    if kind == "sawmill" then
        modSawmill = true
    else
        modding = true
    end
    F.paintAll()
    return modGen
end

function F.finishMod(gen, kind)
    if gen ~= modGen then
        return
    end
    if kind == "sawmill" then
        modSawmill = false
    else
        modding = false
    end
    if started then
        F.paintAll()
    end
end

function F.build(parent)
    root = F.make("Frame", {
        Name = "TreeCutterRoot",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
    }, parent)

    local scroll = F.make("ScrollingFrame", {
        Size = UDim2.new(1, -16, 1, -16),
        Position = UDim2.fromOffset(8, 8),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Color3.fromRGB(70, 70, 70),
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
    }, root)
    local list = F.make("Frame", {
        Size = UDim2.new(1, -8, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
    }, scroll)
    F.make("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
    }, list)

    local treeBlock = F.block(list, 42, 1)
    F.fieldLabel(treeBlock, "Target tree", 0)
    treeBtn = F.make("TextButton", {
        Size = UDim2.new(1, 0, 0, 22),
        Position = UDim2.fromOffset(0, 20),
        BackgroundColor3 = FIELD,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    }, treeBlock)
    treeCaption = F.make("TextLabel", {
        Size = UDim2.new(1, -22, 1, 0),
        Position = UDim2.fromOffset(6, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = "Select",
        TextSize = 15,
        TextColor3 = TEXT,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, treeBtn)
    F.make("TextLabel", {
        Size = UDim2.fromOffset(16, 22),
        Position = UDim2.new(1, -16, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = "v",
        TextSize = 14,
        TextColor3 = MUTED,
    }, treeBtn)

    local quantityBlock = F.block(list, 36, 2)
    quantityLabel = F.fieldLabel(quantityBlock, "Quantity  " .. tostring(quantity), 0)
    quantitySlider = F.make("TextButton", {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.fromOffset(0, 20),
        BackgroundColor3 = TRACK,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    }, quantityBlock)
    quantityFill = F.make("Frame", {
        Size = UDim2.new((quantity - QUANTITY_MIN) / (QUANTITY_MAX - QUANTITY_MIN), 0, 1, 0),
        BackgroundColor3 = BUTTON,
        BorderSizePixel = 0,
    }, quantitySlider)

    local function labeledAction(caption, order, idleText)
        local row = F.block(list, 22, order)
        F.fieldLabel(row, caption, 3).Size = UDim2.new(1, -80, 0, 16)
        return F.actionButton(row, idleText, 0)
    end

    getBtn = labeledAction("Get tree", 3, "Start")
    chopBtn = labeledAction("Chop all trees", 4, "Start")
    tpBtn = labeledAction("TP all logs", 5, "TP")
    sellBtn = labeledAction("Sell all logs", 6, "Sell")

    local function labeledToggle(caption, order)
        local row = F.block(list, 22, order)
        F.fieldLabel(row, caption, 3).Size = UDim2.new(1, -36, 0, 16)
        return F.toggleButton(row)
    end

    clickBtn = labeledToggle("Click to sell", 7)
    cutterBtn = labeledToggle("1x1 cutter", 8)
    hoverBtn = labeledToggle("Hover value", 9)
    modSawmillBtn = labeledAction("Mod sawmill", 10, "Sawmill")
    modTreeBtn = labeledAction("Mod tree", 11, "Tree")

    local statusBlock = F.block(list, 16, 12)
    statusLabel = F.make("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = statusText,
        TextSize = 14,
        TextColor3 = MUTED,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, statusBlock)

    treeBtn.MouseButton1Click:Connect(function()
        if menuOpen then
            F.closeMenu()
        else
            F.rescan(true)
            F.openMenu()
        end
    end)

    quantitySlider.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return
        end
        F.closeMenu()
        quantity = F.quantityFromX(input.Position.X)
        F.paintQuantity()
        local dragging = true
        local moveConn
        local endConn
        moveConn = UserInputService.InputChanged:Connect(function(changed)
            if dragging and changed.UserInputType == Enum.UserInputType.MouseMovement then
                quantity = F.quantityFromX(changed.Position.X)
                F.paintQuantity()
            end
        end)
        endConn = UserInputService.InputEnded:Connect(function(ended)
            if ended.UserInputType ~= Enum.UserInputType.MouseButton1 then
                return
            end
            dragging = false
            moveConn:Disconnect()
            endConn:Disconnect()
            F.saveConfig()
        end)
    end)

    getBtn.MouseButton1Click:Connect(function()
        F.closeMenu()
        if not F.requireStarted() then
            return
        end
        if chopSession then
            chopSession = false
            chopping = false
            F.cleanupChop()
            F.paintAction(getBtn, false, "Start", "Stop")
            if not chopLogs and not teleporting and not modding and not modSawmill then
                F.setStatus("Idle")
            end
            return
        end
        if modding or modSawmill then
            F.setStatus("Busy")
            return
        end
        if not F.treeReady(selectedTree) then
            F.setStatus("No trees")
            return
        end
        chopSession = true
        F.paintAction(getBtn, true, "Start", "Stop")
        local token = session
        task.spawn(function()
            local remaining = quantity
            while chopSession and F.alive(token) and remaining > 0 do
                remaining = remaining - 1
                local className = selectedTree
                if not F.treeReady(className) then
                    F.setStatus("No trees")
                    break
                end
                F.chopTree(className, token)
            end
            if token == session then
                chopSession = false
                F.paintAction(getBtn, false, "Start", "Stop")
                if started then
                    F.setStatus("Idle")
                end
            end
        end)
    end)

    chopBtn.MouseButton1Click:Connect(function()
        F.closeMenu()
        if not F.requireStarted() then
            return
        end
        if chopLogs then
            chopLogs = false
            F.paintAction(chopBtn, false, "Start", "Stop")
            if not chopSession and not teleporting and not modding and not modSawmill then
                F.setStatus("Idle")
            end
            return
        end
        if modding or modSawmill then
            F.setStatus("Busy")
            return
        end
        F.paintAction(chopBtn, true, "Start", "Stop")
        local token = session
        task.spawn(function()
            F.chopOwnedLogs(token)
            if token == session then
                F.paintAction(chopBtn, false, "Start", "Stop")
                if started and not chopSession then
                    F.setStatus("Idle")
                end
            end
        end)
    end)

    local function stopMove()
        moveGen = moveGen + 1
        teleporting = false
        moveMode = nil
        if started then
            F.setStatus("Idle")
            F.paintAll()
        end
    end

    local function moveLogs(singleSection, busyText)
        F.closeMenu()
        if not F.requireStarted() then
            return
        end
        local mode = singleSection and "sell" or "tp"
        if moveMode == mode then
            stopMove()
            return
        end
        if teleporting or chopping or chopLogs or chopSession or modding or modSawmill then
            F.setStatus("Busy")
            return
        end
        local parts = F.ownedInnerWood(singleSection)
        if #parts == 0 then
            F.setStatus(singleSection and "No sections" or "No logs")
            return
        end
        local token = session
        local gen = moveGen
        local rootPart = F.currentRoot()
        moveMode = mode
        teleporting = true
        F.setStatus(busyText)
        F.paintAll()
        task.spawn(function()
            F.teleportMany(parts, function()
                if singleSection then
                    return CFrame.new(SELL_POSITION)
                end
                local now = F.currentRoot() or rootPart
                if now then
                    return now.CFrame * CFrame.new(0, 0, -LOG_DROP)
                end
                return CFrame.new(SELL_POSITION)
            end, token, gen)
            if token ~= session or gen ~= moveGen then
                return
            end
            moveMode = nil
            teleporting = false
            if started then
                F.setStatus("Idle")
                F.paintAll()
            end
        end)
    end

    tpBtn.MouseButton1Click:Connect(function()
        moveLogs(false, "Teleporting")
    end)
    sellBtn.MouseButton1Click:Connect(function()
        moveLogs(true, "Selling")
    end)

    clickBtn.MouseButton1Click:Connect(function()
        F.closeMenu()
        clickToSell = not clickToSell
        F.paintToggle(clickBtn, clickToSell)
        F.saveConfig()
        if started then
            if clickToSell then
                F.enableSell()
            else
                F.disableSell()
            end
        end
    end)
    cutterBtn.MouseButton1Click:Connect(function()
        F.closeMenu()
        cutterOn = not cutterOn
        F.paintToggle(cutterBtn, cutterOn)
        F.saveConfig()
        if started then
            if cutterOn then
                F.enableCutter()
            else
                F.disableCutter()
            end
        end
    end)
    hoverBtn.MouseButton1Click:Connect(function()
        F.closeMenu()
        hoverOn = not hoverOn
        F.paintToggle(hoverBtn, hoverOn)
        F.saveConfig()
        if started then
            if hoverOn then
                F.enableHover()
            else
                F.disableHover()
            end
        end
    end)

    modSawmillBtn.MouseButton1Click:Connect(function()
        F.closeMenu()
        if modSawmill then
            F.stopMod()
            if started then
                F.setStatus("Idle")
                F.paintAll()
            end
            return
        end
        local gen = F.beginMod("sawmill")
        if not gen then
            return
        end
        task.spawn(function()
            local ok, err = pcall(F.runModSawmill, gen)
            if not ok then
                F.warnJell(err)
                if gen == modGen then
                    F.modStatus(gen, "Place failed")
                end
            end
            F.finishMod(gen, "sawmill")
        end)
    end)

    modTreeBtn.MouseButton1Click:Connect(function()
        F.closeMenu()
        if modding then
            F.stopMod()
            if started then
                F.setStatus("Idle")
                F.paintAll()
            end
            return
        end
        local gen = F.beginMod("tree")
        if not gen then
            return
        end
        task.spawn(function()
            local ok, err = pcall(F.runMod, gen)
            if not ok then
                F.warnJell(err)
                if gen == modGen then
                    F.restoreModLava()
                    F.clearModMarks()
                    F.returnModPlayer()
                    F.modStatus(gen, "Mod failed")
                end
            end
            F.finishMod(gen, "tree")
        end)
    end)
end

function api.start()
    if started then
        return
    end
    started = true
    session = session + 1
    F.rescan(true)
    F.watchTrees()
    F.silenceSounds()
    F.applyLiveToggles()
    F.setStatus("Idle")
    F.paintAll()
end

function api.stop()
    started = false
    session = session + 1
    chopSession = false
    chopLogs = false
    teleporting = false
    moveMode = nil
    F.cleanupChop()
    F.stopMod()
    F.unwatch()
    F.clearBucket(soundConns)
    F.disableSell()
    F.disableCutter()
    F.disableHover()
    if markFolder then
        markFolder:Destroy()
        markFolder = nil
    end
    F.closeMenu()
    F.setStatus("Off")
    F.paintAll()
end

function api.mount(parent)
    if mounted then
        api.unmount()
    end
    F.build(parent)
    mounted = true
    F.rescan(true)
    F.paintAll()
end

function api.unmount()
    mounted = false
    F.closeMenu()
    F.clearBucket(guiConns)
    if root then
        root:Destroy()
        root = nil
    end
    treeBtn = nil
    treeCaption = nil
    quantityLabel = nil
    quantityFill = nil
    quantitySlider = nil
    getBtn = nil
    chopBtn = nil
    tpBtn = nil
    sellBtn = nil
    clickBtn = nil
    cutterBtn = nil
    hoverBtn = nil
    modSawmillBtn = nil
    modTreeBtn = nil
    statusLabel = nil
end

return api
