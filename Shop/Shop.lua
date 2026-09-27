local Services = setmetatable({}, {
    __index = function(_, index)
        return game:GetService(index)
    end,
})

local Players = Services.Players
local UserInputService = Services.UserInputService
local Workspace = Services.Workspace
local ReplicatedStorage = Services.ReplicatedStorage
local RunService = Services.RunService

local Player = Players.LocalPlayer

local CONFIG_DIR = "LT2Scripts"
local CONFIG_FILE = CONFIG_DIR .. "/shop.json"

local TEXT = Color3.fromRGB(230, 230, 230)
local MUTED = Color3.fromRGB(160, 160, 160)
local DARK = Color3.fromRGB(18, 18, 18)
local BUTTON = Color3.fromRGB(230, 230, 230)
local FIELD = Color3.fromRGB(58, 58, 58)
local LABEL = Color3.fromRGB(210, 210, 210)
local GREEN = Color3.fromRGB(70, 190, 105)
local STROKE = Color3.fromRGB(70, 70, 70)
local PICKED = Color3.fromRGB(230, 230, 230)
local BAND = Color3.fromRGB(32, 32, 32)

local ROW_H = 22
local BTN_W = 88
local SLOT = 73
local GRID_H = SLOT * 3 + 12

local CATALOG = {
    { BoxItemName = "BasicHatchet", Store = "WoodRUs" },
    { BoxItemName = "Axe1", Store = "WoodRUs" },
    { BoxItemName = "Axe2", Store = "WoodRUs" },
    { BoxItemName = "Axe3", Store = "WoodRUs" },
    { BoxItemName = "SilverAxe", Store = "WoodRUs" },
    { BoxItemName = "StraightConveyor", Store = "WoodRUs" },
    { BoxItemName = "TightTurnConveyor", Store = "WoodRUs" },
    { BoxItemName = "TiltConveyor", Store = "WoodRUs" },
    { BoxItemName = "ConveyorFunnel", Store = "WoodRUs" },
    { BoxItemName = "ConveyorSwitch", Store = "WoodRUs" },
    { BoxItemName = "StraightSwitchConveyorLeft", Store = "WoodRUs" },
    { BoxItemName = "StraightSwitchConveyorRight", Store = "WoodRUs" },
    { BoxItemName = "LogSweeper", Store = "WoodRUs" },
    { BoxItemName = "ConveyorSupports", Store = "WoodRUs" },
    { BoxItemName = "TightTurnConveyorSupports", Store = "WoodRUs" },
    { BoxItemName = "Sawmill", Store = "WoodRUs" },
    { BoxItemName = "Sawmill2", Store = "WoodRUs" },
    { BoxItemName = "Sawmill3", Store = "WoodRUs" },
    { BoxItemName = "Sawmill4", Store = "WoodRUs" },
    { BoxItemName = "Sawmill4L", Store = "WoodRUs" },
    { BoxItemName = "ChopSaw", Store = "WoodRUs" },
    { BoxItemName = "Wire", Store = "WoodRUs" },
    { BoxItemName = "IcicleWireMaple", Store = "FurnitureStore" },
    { BoxItemName = "IcicleWireCandy", Store = "FurnitureStore" },
    { BoxItemName = "IcicleWireHalloween", Store = "FurnitureStore" },
    { BoxItemName = "IcicleWireHalloweenGreen", Store = "FurnitureStore" },
    { BoxItemName = "IcicleWireAmber", Store = "FurnitureStore" },
    { BoxItemName = "IcicleWireBlue", Store = "FurnitureStore" },
    { BoxItemName = "IcicleWireGreen", Store = "FurnitureStore" },
    { BoxItemName = "IcicleWireRed", Store = "FurnitureStore" },
    { BoxItemName = "NeonWireWhite", Store = "LogicStore" },
    { BoxItemName = "NeonWireRed", Store = "LogicStore" },
    { BoxItemName = "NeonWireOrange", Store = "LogicStore" },
    { BoxItemName = "NeonWireYellow", Store = "LogicStore" },
    { BoxItemName = "NeonWireGreen", Store = "LogicStore" },
    { BoxItemName = "NeonWireCyan", Store = "LogicStore" },
    { BoxItemName = "NeonWireBlue", Store = "LogicStore" },
    { BoxItemName = "NeonWireViolet", Store = "LogicStore" },
    { BoxItemName = "Button0", Store = "WoodRUs" },
    { BoxItemName = "Lever0", Store = "WoodRUs" },
    { BoxItemName = "PressurePlate", Store = "WoodRUs" },
    { BoxItemName = "GateNOT", Store = "LogicStore" },
    { BoxItemName = "SignalSustain", Store = "LogicStore" },
    { BoxItemName = "SignalDelay", Store = "LogicStore" },
    { BoxItemName = "GateAND", Store = "LogicStore" },
    { BoxItemName = "GateOR", Store = "LogicStore" },
    { BoxItemName = "GateXOR", Store = "LogicStore" },
    { BoxItemName = "ClockSwitch", Store = "LogicStore" },
    { BoxItemName = "WoodChecker", Store = "LogicStore" },
    { BoxItemName = "Laser", Store = "LogicStore" },
    { BoxItemName = "LaserReceiver", Store = "LogicStore" },
    { BoxItemName = "Hatch", Store = "LogicStore" },
    { BoxItemName = "UtilityTruck", Store = "WoodRUs" },
    { BoxItemName = "UtilityTruck2", Store = "CarStore" },
    { BoxItemName = "Pickup1", Store = "CarStore" },
    { BoxItemName = "SmallTrailer", Store = "CarStore" },
    { BoxItemName = "Trailer2", Store = "CarStore" },
    { BoxItemName = "Seat_Armchair", Store = "FurnitureStore" },
    { BoxItemName = "Seat_Loveseat", Store = "FurnitureStore" },
    { BoxItemName = "Bed1", Store = "FurnitureStore" },
    { BoxItemName = "FloorLamp1", Store = "FurnitureStore" },
    { BoxItemName = "Lamp1", Store = "FurnitureStore" },
    { BoxItemName = "WallLight1", Store = "FurnitureStore" },
    { BoxItemName = "WallLight2", Store = "FurnitureStore" },
    { BoxItemName = "Refridgerator", Store = "FurnitureStore" },
    { BoxItemName = "Stove", Store = "FurnitureStore" },
    { BoxItemName = "Dishwasher", Store = "FurnitureStore" },
    { BoxItemName = "Toilet", Store = "FurnitureStore" },
    { BoxItemName = "FireworkLauncher", Store = "FurnitureStore" },
    { BoxItemName = "GlassDoor1", Store = "FurnitureStore" },
    { BoxItemName = "GlassPane4", Store = "FurnitureStore" },
    { BoxItemName = "GlassPane3", Store = "FurnitureStore" },
    { BoxItemName = "GlassPane2", Store = "FurnitureStore" },
    { BoxItemName = "GlassPane1", Store = "FurnitureStore" },
    { BoxItemName = "Painting3", Store = "FineArt" },
    { BoxItemName = "Painting2", Store = "FineArt" },
    { BoxItemName = "Painting1", Store = "FineArt" },
    { BoxItemName = "Painting7", Store = "FineArt" },
    { BoxItemName = "Painting6", Store = "FineArt" },
    { BoxItemName = "Painting9", Store = "FineArt" },
    { BoxItemName = "Painting8", Store = "FineArt" },
    { BoxItemName = "BagOfSand", Store = "WoodRUs" },
    { BoxItemName = "CanOfWorms", Store = "ShackShop" },
    { BoxItemName = "LightBulb", Store = "FurnitureStore" },
    { BoxItemName = "Dynamite", Store = "ShackShop" },
    { BoxItemName = "WorkLight", Store = "WoodRUs" },
    { BoxItemName = "Wall2Tall", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wall2", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wall2Short", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wall2TallThin", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wall2Thin", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wall2ShortThin", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wall2TallCorner", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wall2Corner", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wall2ShortCorner", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wall1Tall", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wall1", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wall1Short", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wall1TallThin", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wall1Thin", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wall1ShortThin", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wall1TallCorner", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wall1Corner", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wall1ShortCorner", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wall3Tall", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wall3", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wall3TallThin", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wall3Thin", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wall3TallCorner", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wall3Corner", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Floor1Large", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Floor1", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Floor1Small", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Floor1Tiny", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Floor2Large", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Floor2", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Floor2Small", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Floor2Tiny", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wedge1", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wedge1_Thin", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wedge2", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wedge2_Thin", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wedge3", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wedge3_Thin", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wedge4", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wedge4_Thin", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wedge5", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wedge5_Thin", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wedge6", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wedge6_Thin", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wedge7", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wedge7_Thin", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wedge8", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wedge8_Thin", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wedge9", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wedge9_Thin", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wedge10", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Wedge10_Thin", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Stair1", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Stair2", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Ladder1", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Post", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Door1", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Door2", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Door3", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Table1", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Table2", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Chair1", Store = "WoodRUs", IsBlueprint = true },
    { BoxItemName = "Cabinet1CornerWide", Store = "FurnitureStore", IsBlueprint = true },
    { BoxItemName = "Cabinet1", Store = "FurnitureStore", IsBlueprint = true },
    { BoxItemName = "Cabinet1Thin", Store = "FurnitureStore", IsBlueprint = true },
    { BoxItemName = "Cabinet1CornerTight", Store = "FurnitureStore", IsBlueprint = true },
    { BoxItemName = "CounterTop1", Store = "FurnitureStore", IsBlueprint = true },
    { BoxItemName = "CounterTop1Thin", Store = "FurnitureStore", IsBlueprint = true },
    { BoxItemName = "CounterTop1Sink", Store = "FurnitureStore", IsBlueprint = true },
}

local NPC_STORES = {
    Thom = "WoodRUs",
    Corey = "FurnitureStore",
    Jenny = "CarStore",
    Bob = "ShackShop",
    Timothy = "FineArt",
    Lincoln = "LogicStore",
}

local STORES = {
    WoodRUs = { npc = "Thom", buy = CFrame.new(262.1, 3.2, 64.8) },
    FurnitureStore = { npc = "Corey", buy = CFrame.new(481.4, 3.2, -1712.5) },
    CarStore = { npc = "Jenny", buy = CFrame.new(524.9, 3.2, -1466.6) },
    ShackShop = { npc = "Bob", buy = CFrame.new(256.7, 8.4, -2546.7) },
    FineArt = { npc = "Timothy", buy = CFrame.new(5232.4, -166, 737.3) },
    LogicStore = { npc = "Lincoln", buy = CFrame.new(4598.4, 7, -778.4) },
}

local RUKIRY = {
    { BoxItemName = "CanOfWorms", GoalCF = CFrame.new(317.3, 46, 1918.1) },
    { BoxItemName = "BagOfSand", GoalCF = CFrame.new(319.5, 46, 1914.9) },
    { BoxItemName = "LightBulb", GoalCF = CFrame.new(322.4, 43.6, 1916.4) },
}
local RUKIRY_PLAYER = CFrame.new(320.6, 45.8, 1919.2)
local RUKIRY_PRICE = 7400
local POE_PRICE = 10009000
local POE_CF = CFrame.new(1059.4, 17.2, 1130.3)

local INVOKE_TIMEOUT = 4
local POST_TIMEOUT_SETTLE = 0.6
local CLEANUP_ENDCHATS = 3
local CLEANUP_GAP = 0.3
local CLEANUP_CALL_BUDGET = 1.5
local SPAM_TIMEOUT = 30
local CYCLE_GAP = 0.1
local INNER_DEADLINE = 3
local NPC_FAIL_THRESHOLD = 3
local NPC_NUCLEAR_AFTER = 2
local OWNERSHIP_TIMEOUT = 1
local FALLBACK_WAIT = 0.5
local PRE_FIRE_WAIT = 0.05
local POST_OBJECT_DELAY = 0.1
local PROXIMITY = 10

local mounted = false
local root = nil
local connections = {}
local shopItems = nil
local slots = {}
local selectedId = nil
local quantity = 1
local funds = nil
local fundsToken = 0
local buying = false
local buyingBlueprints = false
local buyingRukiry = false
local quickPurchase = false
local allowNuclear = false
local moving = false
local npcIds = {}
local lastInvokeTimedOut = false
local npcFailStreak = {}
local npcResetStreak = {}
local counterCache = {}
local shopFolderCache = {}
local purchaseBtn = nil
local blueprintBtn = nil
local rukiryBtn = nil
local poeBtn = nil
local quantityValue = nil
local quantityFill = nil

local function saveConfig()
    if type(writefile) ~= "function" then
        return
    end
    if type(makefolder) == "function" and type(isfolder) == "function" and not isfolder(CONFIG_DIR) then
        pcall(makefolder, CONFIG_DIR)
    end
    local payload = {
        selectedId = selectedId,
        quantity = quantity,
        quickPurchase = quickPurchase,
        allowNuclear = allowNuclear,
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
    if type(data.selectedId) == "string" and data.selectedId ~= "" then
        selectedId = data.selectedId
    end
    local savedQuantity = tonumber(data.quantity)
    if savedQuantity then
        quantity = math.clamp(math.floor(savedQuantity + 0.5), 1, 100)
    end
    if type(data.quickPurchase) == "boolean" then
        quickPurchase = data.quickPurchase
    end
    if type(data.allowNuclear) == "boolean" then
        allowNuclear = data.allowNuclear
    end
end

applySaved(readSavedConfig())

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

local function money(amount)
    local digits = tostring(math.floor(amount))
    local rev = string.reverse(digits)
    rev = string.gsub(rev, "(%d%d%d)", "%1,")
    rev = string.reverse(rev)
    if string.sub(rev, 1, 1) == "," then
        rev = string.sub(rev, 2)
    end
    return "$" .. rev
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

local function child(parent, name)
    return parent and parent:FindFirstChild(name)
end

local function npcModel(name)
    local storeName = NPC_STORES[name]
    local stores = Workspace:FindFirstChild("Stores")
    local store = stores and storeName and stores:FindFirstChild(storeName)
    return store and store:FindFirstChild(name)
end

local function chatRemote()
    return child(child(ReplicatedStorage, "NPCDialog"), "PlayerChatted")
end

local function promptRemote()
    return child(child(ReplicatedStorage, "NPCDialog"), "PromptChat")
end

local function interactRemote()
    return child(child(ReplicatedStorage, "Interaction"), "ClientInteracted")
end

local function dragRemote()
    return child(child(ReplicatedStorage, "Interaction"), "ClientIsDragging")
end

local function findFundsRemote()
    for _, desc in ipairs(ReplicatedStorage:GetDescendants()) do
        if desc.Name == "GetFunds" and desc:IsA("RemoteFunction") then
            return desc
        end
    end
    return nil
end

local fundsRemote = nil

local function fetchFunds()
    if not fundsRemote then
        fundsRemote = findFundsRemote()
        if not fundsRemote then
            return nil
        end
    end
    local ok, result = pcall(function()
        return fundsRemote:InvokeServer()
    end)
    if ok and type(result) == "number" then
        return result
    end
    return nil
end

local function basePart(inst)
    if not inst then
        return nil
    end
    if inst:IsA("BasePart") then
        return inst
    end
    if inst:IsA("Model") then
        if inst.PrimaryPart then
            return inst.PrimaryPart
        end
        for _, desc in ipairs(inst:GetDescendants()) do
            if desc:IsA("BasePart") then
                return desc
            end
        end
    end
    return nil
end

local function counterPart(storeName)
    if counterCache[storeName] ~= nil then
        return counterCache[storeName] or nil
    end
    local config = STORES[storeName]
    local npc = config and npcModel(config.npc)
    local store = npc and npc.Parent
    local counter = store and store:FindFirstChild("Counter")
    local part = basePart(counter)
    counterCache[storeName] = part or false
    return part
end

local function dropCFrame(storeName, mainPart)
    local counter = counterPart(storeName)
    if not counter then
        return nil
    end
    local up = counter.CFrame.UpVector
    local surface = counter.Position + up * (counter.Size.Y / 2)
    local rise = mainPart and (mainPart.Size.Y / 2) or 0
    return CFrame.new(surface + up * (rise + 0.05))
end

local function ensureDialog(npc)
    local dialog = npc:FindFirstChild("Dialog")
    if dialog then
        return dialog
    end
    dialog = Instance.new("Dialog")
    dialog.Parent = npc
    return dialog
end

local function fetchNpcId(npcName)
    local npc = npcModel(npcName)
    local prompt = promptRemote()
    if not npc or not prompt then
        return nil
    end
    local dialog = ensureDialog(npc)
    local lastData = nil
    local conn = prompt.OnClientEvent:Connect(function(active, chatData)
        if active and chatData and chatData.Character == npc then
            lastData = chatData
        end
    end)
    pcall(function()
        prompt:FireServer(true, npc, dialog)
    end)
    local started = os.clock()
    repeat
        task.wait(0.05)
    until lastData or os.clock() - started > 5
    conn:Disconnect()
    pcall(function()
        prompt:FireServer(false, npc, dialog)
    end)
    task.wait(0.2)
    if lastData and lastData.Character == npc and lastData.ID then
        npcIds[npcName] = lastData.ID
        return lastData.ID
    end
    warn("[Jell] Shop: Failed to fetch NPC id for " .. npcName)
    return nil
end

local function ensureNpcId(npcName)
    if npcIds[npcName] then
        return npcIds[npcName]
    end
    return fetchNpcId(npcName)
end

local function fetchAllNpcIds()
    for name in pairs(NPC_STORES) do
        if not npcIds[name] then
            fetchNpcId(name)
            task.wait(0.15)
        end
    end
end

local function nearestCashier(mainPart)
    if not mainPart then
        return nil, nil
    end
    local bestNpc, bestName, bestDist = nil, nil, math.huge
    for name in pairs(NPC_STORES) do
        local npc = npcModel(name)
        local head = npc and npc:FindFirstChild("Head")
        if head then
            local dist = (head.Position - mainPart.Position).Magnitude
            if dist < bestDist then
                bestDist = dist
                bestNpc = npc
                bestName = name
            end
        end
    end
    return bestNpc, bestName
end

local function buildNpcArg(npcName, npc)
    if not npc then
        return nil
    end
    local dialog = ensureDialog(npc)
    local id = ensureNpcId(npcName)
    if not id then
        return nil
    end
    return {
        ID = id,
        Character = npc,
        Name = npcName,
        Dialog = dialog,
    }
end

local function npcArgForItem(storeName, mainPart)
    local config = STORES[storeName]
    if config then
        local npc = npcModel(config.npc)
        local arg = buildNpcArg(config.npc, npc)
        if arg then
            return arg, config.npc
        end
    end
    local proxNpc, proxName = nearestCashier(mainPart)
    if proxNpc and proxName then
        local arg = buildNpcArg(proxName, proxNpc)
        if arg then
            return arg, proxName
        end
    end
    return nil, nil
end

local function safeInvoke(npcArg, action)
    local remote = chatRemote()
    if not remote or not npcArg then
        return
    end
    local co = coroutine.running()
    local done = false
    local timedOut = false
    local fireThread = task.spawn(function()
        pcall(function()
            remote:InvokeServer(npcArg, action)
        end)
        if not done then
            done = true
            task.spawn(co)
        end
    end)
    task.delay(INVOKE_TIMEOUT, function()
        if not done then
            done = true
            timedOut = true
            pcall(task.cancel, fireThread)
            task.spawn(co)
        end
    end)
    coroutine.yield()
    lastInvokeTimedOut = timedOut
    if timedOut and action ~= "EndChat" then
        task.wait(POST_TIMEOUT_SETTLE)
        for _ = 1, CLEANUP_ENDCHATS do
            local cleanupDone = false
            local cleanupThread = task.spawn(function()
                pcall(function()
                    remote:InvokeServer(npcArg, "EndChat")
                end)
                cleanupDone = true
            end)
            local deadline = os.clock() + CLEANUP_CALL_BUDGET
            while not cleanupDone and os.clock() < deadline do
                task.wait(0.05)
            end
            if not cleanupDone then
                pcall(task.cancel, cleanupThread)
            end
            task.wait(CLEANUP_GAP)
        end
    end
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
    local avg = 1 / 20
    if #samples > 0 then
        local sum = 0
        for _, value in ipairs(samples) do
            sum += value
        end
        avg = sum / #samples
    end
    return math.clamp(avg * 20, 0.5, 1)
end

local function lastInteraction(model)
    local owner = model:FindFirstChild("Owner")
    local fromOwner = owner and owner:FindFirstChild("LastInteraction")
    return fromOwner or model:FindFirstChild("LastInteraction")
end

local function fireDrag(model)
    local remote = dragRemote()
    if not remote then
        return false
    end
    return pcall(remote.FireServer, remote, model)
end

local function teleportSingle(target, goalCF, hrp)
    if not target or not target.Parent then
        return
    end
    local model = target:FindFirstAncestorOfClass("Model") or target.Parent
    local lastInteracted = lastInteraction(model)
    local flat = (hrp.Position - target.Position) * Vector3.new(1, 0, 1)
    if flat.Magnitude > PROXIMITY then
        hrp.CFrame = CFrame.new(target.Position + Vector3.new(0, 3, 0))
    end
    local owner = model:FindFirstChild("Owner")
    local ownerString = owner and owner:FindFirstChild("OwnerString")
    if ownerString and ownerString.Value ~= Player.Name then
        local base = dynamicDelay()
        for attempt = 1, 5 do
            local deadline = os.clock() + (base * attempt)
            while os.clock() < deadline do
                fireDrag(model)
                task.wait()
            end
            if target.Parent then
                target.CFrame = goalCF
            end
            task.wait(0.2)
            if not target.Parent or (target.Position - goalCF.Position).Magnitude < 2 then
                break
            end
        end
        task.wait(POST_OBJECT_DELAY)
        return
    end
    task.wait(PRE_FIRE_WAIT)
    if lastInteracted then
        local co = coroutine.running()
        local fired = false
        local conn = lastInteracted:GetPropertyChangedSignal("Value"):Connect(function()
            if not fired then
                fired = true
                task.spawn(co)
            end
        end)
        local fireLoop = task.spawn(function()
            local deadline = os.clock() + OWNERSHIP_TIMEOUT
            while not fired and os.clock() < deadline do
                fireDrag(model)
                task.wait()
            end
            if not fired then
                fired = true
                task.spawn(co)
            end
        end)
        coroutine.yield()
        conn:Disconnect()
        pcall(task.cancel, fireLoop)
    else
        local deadline = os.clock() + FALLBACK_WAIT
        while os.clock() < deadline do
            fireDrag(model)
            task.wait()
        end
    end
    if target.Parent then
        target.CFrame = goalCF
    end
    task.wait(POST_OBJECT_DELAY)
end

local function moveParts(jobs)
    while moving do
        task.wait()
    end
    moving = true
    local hrp
    local saved
    local ok, err = pcall(function()
        local character = Player.Character
        hrp = character and character:FindFirstChild("HumanoidRootPart")
        if not hrp then
            error("no character")
        end
        saved = hrp.CFrame
        for _, job in ipairs(jobs) do
            if job.target and job.target.Parent and job.goalCF then
                teleportSingle(job.target, job.goalCF, hrp)
            end
        end
    end)
    if hrp and hrp.Parent and saved then
        hrp.CFrame = saved
    end
    moving = false
    if not ok then
        warn("[Jell] Shop: " .. tostring(err))
        return false
    end
    return true
end

local function shopFolder(storeName)
    if shopFolderCache[storeName] ~= nil then
        return shopFolderCache[storeName] or nil
    end
    local config = STORES[storeName]
    if not config then
        shopFolderCache[storeName] = false
        return nil
    end
    local anchor
    local counter = counterPart(storeName)
    if counter then
        anchor = counter.Position
    else
        local npc = npcModel(config.npc)
        local store = npc and npc.Parent
        if store and store:IsA("Model") then
            local pivoted, pos = pcall(function()
                return store:GetPivot().Position
            end)
            if pivoted then
                anchor = pos
            end
        end
    end
    local stores = Workspace:FindFirstChild("Stores")
    if not anchor or not stores then
        shopFolderCache[storeName] = false
        return nil
    end
    local best, bestDist = nil, math.huge
    for _, folder in ipairs(stores:GetChildren()) do
        if folder.Name == "ShopItems" then
            local sample
            for _, desc in ipairs(folder:GetDescendants()) do
                if desc:IsA("BasePart") then
                    sample = desc.Position
                    break
                end
            end
            if sample then
                local dist = (sample - anchor).Magnitude
                if dist < bestDist then
                    bestDist = dist
                    best = folder
                end
            end
        end
    end
    shopFolderCache[storeName] = best or false
    return best
end

local function resolveParts(item, limit)
    local stores = Workspace:FindFirstChild("Stores")
    if not stores then
        return {}
    end
    local results = {}
    local function search(folder)
        for _, box in ipairs(folder:GetChildren()) do
            if #results >= limit then
                break
            end
            if box:IsA("Model") and box.Name == "Box" then
                local nameVal = box:FindFirstChild("BoxItemName")
                if nameVal and nameVal:IsA("StringValue") and nameVal.Value == item.BoxItemName then
                    local main = box:FindFirstChild("Main")
                    if main and main:IsA("BasePart") and not main.Anchored then
                        table.insert(results, main)
                    end
                end
            end
        end
    end
    local folder = item.Store and shopFolder(item.Store)
    if folder then
        search(folder)
        return results
    end
    for _, childInst in ipairs(stores:GetChildren()) do
        if #results >= limit then
            break
        end
        if childInst.Name == "ShopItems" then
            search(childInst)
        end
    end
    return results
end

local function ownedParent(parent)
    if not parent then
        return false
    end
    if parent.Name == "PlayerModels" or parent == Player.Backpack or parent == Player.Character then
        return true
    end
    local current = parent
    while current do
        if current.Name == "PlayerModels" then
            return true
        end
        current = current.Parent
    end
    return false
end

local function itemState(mainPart)
    if not mainPart then
        return "gone"
    end
    local parent = mainPart.Parent
    if ownedParent(parent) then
        return "success"
    end
    if parent == nil then
        task.wait(0.12)
        local nextParent = mainPart.Parent
        if ownedParent(nextParent) then
            return "success"
        end
        if nextParent == nil then
            return "gone"
        end
    end
    return "pending"
end

local function spamPurchase(mainPart, npcArg, npcName)
    local started = os.clock()
    local deadline = started + SPAM_TIMEOUT
    while os.clock() < deadline do
        local state = itemState(mainPart)
        if state == "success" then
            return true, os.clock() - started
        end
        if state == "gone" then
            return false, os.clock() - started
        end
        safeInvoke(npcArg, "Initiate")
        if lastInvokeTimedOut then
            npcIds[npcName] = nil
            local newId = fetchNpcId(npcName)
            if newId then
                npcArg.ID = newId
            end
            task.wait(0.2)
            continue
        end
        state = itemState(mainPart)
        if state == "success" then
            safeInvoke(npcArg, "EndChat")
            return true, os.clock() - started
        end
        if state == "gone" then
            safeInvoke(npcArg, "EndChat")
            return false, os.clock() - started
        end
        local inner = os.clock() + INNER_DEADLINE
        while os.clock() < inner do
            state = itemState(mainPart)
            if state == "success" then
                safeInvoke(npcArg, "EndChat")
                return true, os.clock() - started
            end
            if state == "gone" then
                safeInvoke(npcArg, "EndChat")
                return false, os.clock() - started
            end
            safeInvoke(npcArg, "ConfirmPurchase")
            if lastInvokeTimedOut then
                break
            end
            task.wait(CYCLE_GAP)
        end
        safeInvoke(npcArg, "EndChat")
        task.wait(0.2)
    end
    safeInvoke(npcArg, "EndChat")
    return false, os.clock() - started
end

local function positionForPurchase(mainPart, item)
    local config = STORES[item.Store]
    if not config then
        return nil, nil
    end
    local drop = dropCFrame(item.Store, mainPart)
    if not drop then
        return nil, nil
    end
    if not moveParts({ { target = mainPart, goalCF = drop } }) then
        return nil, nil
    end
    local character = Player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        return nil, nil
    end
    hrp.CFrame = config.buy
    local npcArg, npcName = npcArgForItem(item.Store, mainPart)
    if not npcArg or not npcArg.ID then
        return nil, nil
    end
    return npcArg, npcName
end

local function doPurchase(mainPart, item, npcArg, npcName, pressedCF)
    local purchased, elapsed = spamPurchase(mainPart, npcArg, npcName)
    if purchased and mainPart and mainPart.Parent then
        if quickPurchase and elapsed < 1 then
            mainPart.CFrame = pressedCF
            mainPart.AssemblyLinearVelocity = Vector3.zero
            mainPart.AssemblyAngularVelocity = Vector3.zero
        else
            moveParts({ { target = mainPart, goalCF = pressedCF } })
        end
        local character = Player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = pressedCF * CFrame.new(0, 0, 3)
        end
    end
    return purchased
end

local function hardResetNpc(npcArg, npcName)
    warn("[Jell] Shop: Resetting " .. npcName)
    local character = Player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    local saved = hrp and hrp.CFrame
    if hrp then
        hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, 40)
        task.wait(1)
    end
    npcIds[npcName] = nil
    local newId = fetchNpcId(npcName)
    if newId then
        npcArg.ID = newId
    end
    local remote = chatRemote()
    for _ = 1, 5 do
        if remote then
            local done = false
            local thread = task.spawn(function()
                pcall(function()
                    remote:InvokeServer(npcArg, "EndChat")
                end)
                done = true
            end)
            local deadline = os.clock() + CLEANUP_CALL_BUDGET
            while not done and os.clock() < deadline do
                task.wait(0.05)
            end
            if not done then
                pcall(task.cancel, thread)
            end
        end
        task.wait(0.3)
    end
    local current = Player.Character
    local rootPart = current and current:FindFirstChild("HumanoidRootPart")
    if rootPart and saved then
        rootPart.CFrame = saved
        task.wait(0.3)
    end
end

local function nuclearReset()
    warn("[Jell] Shop: Respawning to free a stuck NPC")
    local humanoid = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.Health = 0
    end
    local deadline = os.clock() + 10
    repeat
        task.wait(0.2)
    until (Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")) or os.clock() > deadline
    task.wait(0.5)
end

local function runBuyLoop(item, totalQty, pressedCF, onDone)
    fetchAllNpcIds()
    local bought = 0
    local restock = 0
    while bought < totalQty and buying do
        local parts = resolveParts(item, totalQty - bought)
        if #parts == 0 then
            task.wait(0.5)
            restock += 0.5
            if restock >= 120 then
                break
            end
            continue
        end
        restock = 0
        for _, mainPart in ipairs(parts) do
            if not buying or bought >= totalQty then
                break
            end
            if not mainPart or not mainPart.Parent then
                continue
            end
            local npcArg, npcName = positionForPurchase(mainPart, item)
            if npcArg then
                local ok = false
                local giveUp = os.clock() + 90
                while not ok and buying and os.clock() < giveUp do
                    if not mainPart.Parent then
                        break
                    end
                    ok = doPurchase(mainPart, item, npcArg, npcName, pressedCF)
                    if ok then
                        npcFailStreak[npcName] = 0
                        npcResetStreak[npcName] = 0
                    else
                        npcFailStreak[npcName] = (npcFailStreak[npcName] or 0) + 1
                        if npcFailStreak[npcName] >= NPC_FAIL_THRESHOLD then
                            npcFailStreak[npcName] = 0
                            npcResetStreak[npcName] = (npcResetStreak[npcName] or 0) + 1
                            if allowNuclear and npcResetStreak[npcName] >= NPC_NUCLEAR_AFTER then
                                npcResetStreak[npcName] = 0
                                nuclearReset()
                                fetchAllNpcIds()
                                npcArg, npcName = positionForPurchase(mainPart, item)
                                if not npcArg then
                                    break
                                end
                            else
                                hardResetNpc(npcArg, npcName)
                                local character = Player.Character
                                local hrp = character and character:FindFirstChild("HumanoidRootPart")
                                local config = STORES[item.Store]
                                if hrp and config then
                                    hrp.CFrame = config.buy
                                    task.wait(0.15)
                                end
                            end
                        else
                            task.wait(0.3)
                        end
                    end
                end
                if ok then
                    bought += 1
                end
            end
        end
    end
    buying = false
    if onDone then
        onDone()
    end
end

local function purchaseBlueprintPart(mainPart, item)
    local npcArg, npcName = positionForPurchase(mainPart, item)
    if not npcArg then
        return false
    end
    local purchased = spamPurchase(mainPart, npcArg, npcName)
    return purchased
end

local function openBlueprintBox(boxItemName)
    local playerModels = Workspace:FindFirstChild("PlayerModels")
    if not playerModels then
        return false
    end
    local interact = interactRemote()
    if not interact then
        return false
    end
    local deadline = os.clock() + 10
    while os.clock() < deadline do
        for _, model in ipairs(playerModels:GetChildren()) do
            if model:IsA("Model") and string.find(model.Name, "Box Purchased by", 1, true) then
                local nameVal = model:FindFirstChild("PurchasedBoxItemName")
                if nameVal and nameVal.Value == boxItemName then
                    local head = Player.Character and Player.Character:FindFirstChild("Head")
                    if head then
                        interact:FireServer(model, "Open box", head.CFrame)
                        task.wait(0.5)
                        return true
                    end
                end
            end
        end
        task.wait(0.2)
    end
    warn("[Jell] Shop: Timed out waiting for " .. boxItemName)
    return false
end

local function blueprintsFolder()
    local playerBP = Player:FindFirstChild("PlayerBlueprints")
    return playerBP and playerBP:FindFirstChild("Blueprints")
end

local function runBlueprintLoop(onDone)
    fetchAllNpcIds()
    local character = Player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    local returnCF = hrp and hrp.CFrame
    for _, item in ipairs(shopItems or {}) do
        if not buyingBlueprints then
            break
        end
        if item.IsBlueprint then
            local parts = resolveParts(item, 1)
            local mainPart = parts[1]
            local folder = blueprintsFolder()
            local owned = folder and folder:FindFirstChild(item.BoxItemName)
            local pocket = fetchFunds()
            if mainPart and mainPart.Parent and not owned and pocket and pocket >= item.Price then
                if purchaseBlueprintPart(mainPart, item) then
                    openBlueprintBox(item.BoxItemName or item.Name)
                else
                    warn("[Jell] Shop: Failed to buy " .. item.Name)
                end
                task.wait(0.2)
            end
        end
    end
    local current = Player.Character
    local rootPart = current and current:FindFirstChild("HumanoidRootPart")
    if rootPart and returnCF then
        rootPart.CFrame = returnCF
    end
    buyingBlueprints = false
    if onDone then
        onDone()
    end
end

local function ownsPowerOfEase()
    local flag = Player:FindFirstChild("SuperBlueprint")
    return flag ~= nil and flag.Value == true
end

local function updatePowerOfEase()
    if not (poeBtn and poeBtn.Parent) then
        return
    end
    if ownsPowerOfEase() then
        poeBtn.Text = "Owned"
        setEnabled(poeBtn, false)
        return
    end
    poeBtn.Text = "Buy"
    setEnabled(poeBtn, true)
end

local function watchPowerOfEase()
    local function wire(flag)
        connect(flag:GetPropertyChangedSignal("Value"), function()
            if mounted then
                updatePowerOfEase()
            end
        end)
        updatePowerOfEase()
    end
    local flag = Player:FindFirstChild("SuperBlueprint")
    if flag then
        wire(flag)
        return
    end
    connect(Player.ChildAdded, function(child)
        if mounted and child.Name == "SuperBlueprint" then
            wire(child)
        end
    end)
end

local function purchasePowerOfEase()
    if ownsPowerOfEase() then
        updatePowerOfEase()
        return
    end
    local pocket = fetchFunds()
    if pocket == nil or pocket < POE_PRICE then
        warn("[Jell] Shop: Not enough money for Power of Ease")
        flash(poeBtn, "No funds", "Buy")
        return
    end
    fetchAllNpcIds()
    local character = Player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        return
    end
    local returnCF = hrp.CFrame
    hrp.CFrame = POE_CF
    task.wait(0.15)
    local bestNpc, bestName, bestDist = nil, nil, math.huge
    for name in pairs(NPC_STORES) do
        local npc = npcModel(name)
        local store = npc and npc.Parent
        local counter = store and basePart(store:FindFirstChild("Counter"))
        if counter then
            local dist = (counter.Position - hrp.Position).Magnitude
            if dist < bestDist then
                bestDist = dist
                bestNpc = npc
                bestName = name
            end
        end
    end
    if not bestNpc then
        hrp.CFrame = returnCF
        return
    end
    local npcArg = buildNpcArg(bestName, bestNpc)
    if not npcArg then
        hrp.CFrame = returnCF
        return
    end
    local deadline = os.clock() + 60
    while os.clock() < deadline do
        if ownsPowerOfEase() then
            break
        end
        safeInvoke(npcArg, "Initiate")
        safeInvoke(npcArg, "ConfirmPurchase")
        safeInvoke(npcArg, "EndChat")
        local now = fetchFunds()
        if now and now < pocket then
            break
        end
        task.wait(0.2)
    end
    task.wait(0.1)
    local current = Player.Character
    local rootPart = current and current:FindFirstChild("HumanoidRootPart")
    if rootPart then
        rootPart.CFrame = returnCF
    end
end

local function purchaseRukiryItem(mainPart, item, goalCF)
    local npcArg, npcName = positionForPurchase(mainPart, item)
    if not npcArg then
        return false
    end
    local purchased = spamPurchase(mainPart, npcArg, npcName)
    if not purchased then
        return false
    end
    task.wait(0.05)
    local playerModels = Workspace:FindFirstChild("PlayerModels")
    local existing = {}
    if playerModels then
        for _, model in ipairs(playerModels:GetChildren()) do
            existing[model] = true
        end
    end
    local interact = interactRemote()
    local boxModel = mainPart.Parent
    local head = Player.Character and Player.Character:FindFirstChild("Head")
    if interact and boxModel and boxModel:IsA("Model") and head then
        interact:FireServer(boxModel, "Open box", head.CFrame)
    end
    local spawned = nil
    local deadline = os.clock() + 5
    while os.clock() < deadline and not spawned do
        task.wait(0.1)
        if playerModels then
            for _, model in ipairs(playerModels:GetChildren()) do
                if not existing[model] and model:IsA("Model") then
                    local itemName = model:FindFirstChild("ItemName")
                    local owner = model:FindFirstChild("Owner")
                    local ownerString = owner and owner:FindFirstChild("OwnerString")
                    local main = model:FindFirstChild("Main")
                    if itemName and itemName.Value == item.BoxItemName
                        and ownerString and ownerString.Value == Player.Name
                        and main
                    then
                        spawned = main
                        break
                    end
                end
            end
        end
    end
    if spawned and spawned.Parent then
        moveParts({ { target = spawned, goalCF = goalCF } })
    else
        warn("[Jell] Shop: Could not find " .. item.Name .. " after opening the box")
    end
    return true
end

local function runRukiry()
    fetchAllNpcIds()
    local character = Player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    local returnCF = hrp and hrp.CFrame
    for _, entry in ipairs(RUKIRY) do
        if not buyingRukiry then
            break
        end
        local itemDef = nil
        for _, item in ipairs(shopItems or {}) do
            if item.BoxItemName == entry.BoxItemName then
                itemDef = item
                break
            end
        end
        if not itemDef then
            warn("[Jell] Shop: Missing Rukiry item " .. entry.BoxItemName)
            continue
        end
        local pocket = fetchFunds()
        local parts = resolveParts(itemDef, 1)
        local mainPart = parts[1]
        if pocket and pocket >= itemDef.Price and mainPart and mainPart.Parent then
            if not purchaseRukiryItem(mainPart, itemDef, entry.GoalCF) then
                warn("[Jell] Shop: Failed to buy " .. itemDef.Name)
            end
            task.wait(0.2)
        end
    end
    local placed = Player.Character
    local placedRoot = placed and placed:FindFirstChild("HumanoidRootPart")
    if placedRoot then
        placedRoot.CFrame = RUKIRY_PLAYER
    end
    local axe = nil
    local axeDeadline = os.clock() + 20
    while os.clock() < axeDeadline and not axe do
        task.wait(0.2)
        local playerModels = Workspace:FindFirstChild("PlayerModels")
        local current = Player.Character
        local rootPart = current and current:FindFirstChild("HumanoidRootPart")
        if playerModels then
            for _, model in ipairs(playerModels:GetChildren()) do
                if model:IsA("Model") and model.Name == "Model" then
                    local toolName = model:FindFirstChild("ToolName")
                    local owner = model:FindFirstChild("Owner")
                    local ownerString = owner and owner:FindFirstChild("OwnerString")
                    local last = owner and owner:FindFirstChild("LastInteraction")
                    if toolName and toolName.Value == "Rukiryaxe"
                        and ownerString and ownerString.Value == ""
                        and last and last.Value == 0
                    then
                        local handle = model:FindFirstChild("Handle") or model.PrimaryPart
                        if not rootPart or not handle or (handle.Position - rootPart.Position).Magnitude <= 50 then
                            axe = model
                            break
                        end
                    end
                end
            end
        end
    end
    if axe then
        local picked = false
        local deadline = os.clock() + 8
        local interact = interactRemote()
        while os.clock() < deadline and buyingRukiry and not picked do
            local handle = axe:FindFirstChild("Handle") or axe.PrimaryPart
            if not handle then
                break
            end
            local current = Player.Character
            local rootPart = current and current:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.CFrame = handle.CFrame + Vector3.new(0, 3, 0)
                rootPart.AssemblyLinearVelocity = Vector3.zero
            end
            task.wait(0.1)
            for _ = 1, 8 do
                fireDrag(axe)
                task.wait()
            end
            handle = axe:FindFirstChild("Handle") or axe.PrimaryPart
            if interact and handle then
                interact:FireServer(axe, "Pick up tool", handle.CFrame)
            end
            task.wait(0.3)
            if not axe.Parent or not axe:IsDescendantOf(Workspace) then
                picked = true
            end
        end
        if not picked then
            warn("[Jell] Shop: Could not pick up the Rukiry axe")
        end
        task.wait(0.1)
        local back = Player.Character
        local backRoot = back and back:FindFirstChild("HumanoidRootPart")
        if backRoot and returnCF then
            backRoot.CFrame = returnCF
        end
    else
        warn("[Jell] Shop: Rukiry axe did not spawn")
    end
    buyingRukiry = false
    if rukiryBtn and rukiryBtn.Parent and not buyingRukiry then
        rukiryBtn.Text = money(RUKIRY_PRICE)
        setEnabled(rukiryBtn, true)
    end
end

local function readPrice(value)
    if type(value) == "number" then
        return value
    end
    return tonumber(tostring(value):gsub("[^%d]", "")) or 0
end

local function loadItems()
    if shopItems and #shopItems > 0 then
        return shopItems
    end
    local info = ReplicatedStorage:FindFirstChild("ClientItemInfo")
    if not info then
        info = ReplicatedStorage:WaitForChild("ClientItemInfo", 5)
    end
    if not info then
        warn("[Jell] Shop: ClientItemInfo not found")
        return nil
    end
    local items = {}
    for _, entry in ipairs(CATALOG) do
        local folder = info:FindFirstChild(entry.BoxItemName)
        if folder then
            local nameVal = folder:FindFirstChild("ItemName")
            local imageVal = folder:FindFirstChild("ItemImage")
            local priceVal = folder:FindFirstChild("Price")
            if nameVal and imageVal and priceVal then
                table.insert(items, {
                    Name = nameVal.Value,
                    Image = imageVal.Value,
                    Price = readPrice(priceVal.Value),
                    BoxItemName = entry.BoxItemName,
                    Store = entry.Store,
                    IsBlueprint = entry.IsBlueprint == true,
                })
            end
        end
    end
    if #items == 0 then
        warn("[Jell] Shop: No shop items loaded")
        return nil
    end
    shopItems = items
    return items
end

local function selectedItem()
    if not shopItems or not selectedId then
        return nil
    end
    for _, item in ipairs(shopItems) do
        if item.BoxItemName == selectedId then
            return item
        end
    end
    return nil
end

local function paintQuantity()
    quantity = math.clamp(math.floor(quantity + 0.5), 1, 100)
    if quantityValue and quantityValue.Parent then
        quantityValue.Text = tostring(quantity)
    end
    if quantityFill and quantityFill.Parent then
        quantityFill.Size = UDim2.new((quantity - 1) / 99, 0, 1, 0)
    end
end

local function readQuantity()
    return quantity
end

local function updatePurchase()
    if not (purchaseBtn and purchaseBtn.Parent) then
        return
    end
    if buying then
        purchaseBtn.Text = "Stop"
        setEnabled(purchaseBtn, true)
        return
    end
    local item = selectedItem()
    if not item then
        purchaseBtn.Text = "Buy"
        setEnabled(purchaseBtn, false)
        return
    end
    local canAfford = funds ~= nil and funds >= item.Price
    purchaseBtn.Text = money(item.Price * quantity)
    setEnabled(purchaseBtn, canAfford)
end

local function blueprintItems()
    local list = {}
    for _, item in ipairs(shopItems or {}) do
        if item.IsBlueprint then
            table.insert(list, item)
        end
    end
    return list
end

local function blueprintCost()
    local folder = blueprintsFolder()
    local total = 0
    for _, item in ipairs(blueprintItems()) do
        if not (folder and folder:FindFirstChild(item.BoxItemName)) then
            total += item.Price
        end
    end
    return total
end

local function allBlueprintsOwned()
    local items = blueprintItems()
    if #items == 0 then
        return false
    end
    local folder = blueprintsFolder()
    if not folder then
        return false
    end
    for _, item in ipairs(items) do
        if not folder:FindFirstChild(item.BoxItemName) then
            return false
        end
    end
    return true
end

local function paintSlots()
    for id, slot in pairs(slots) do
        local picked = slot.enabled and id == selectedId
        slot.stroke.Color = picked and PICKED or STROKE
        slot.stroke.Thickness = picked and 2 or 1
    end
end

local function setSlotEnabled(id, enabled)
    local slot = slots[id]
    if not slot then
        return
    end
    slot.enabled = enabled
    slot.overlay.Visible = not enabled
    if not enabled and selectedId == id then
        selectedId = nil
        paintSlots()
        updatePurchase()
    end
end

local function updateBlueprintSlots()
    local folder = blueprintsFolder()
    for _, item in ipairs(blueprintItems()) do
        local owned = folder ~= nil and folder:FindFirstChild(item.BoxItemName) ~= nil
        setSlotEnabled(item.BoxItemName, not owned)
    end
end

local function updateBlueprintBtn()
    if not (blueprintBtn and blueprintBtn.Parent) then
        return
    end
    if buyingBlueprints then
        blueprintBtn.Text = "Stop"
        setEnabled(blueprintBtn, true)
        return
    end
    if allBlueprintsOwned() then
        blueprintBtn.Text = "Owned"
        setEnabled(blueprintBtn, false)
        return
    end
    local total = blueprintCost()
    blueprintBtn.Text = total > 0 and money(total) or "Buy"
    setEnabled(blueprintBtn, true)
end

local function refreshFunds()
    local pocket = fetchFunds()
    if pocket ~= nil then
        funds = pocket
    end
    if not buying then
        updatePurchase()
    end
end

local function pollFunds()
    fundsToken += 1
    local token = fundsToken
    task.spawn(function()
        while token == fundsToken and mounted do
            refreshFunds()
            task.wait(3)
        end
    end)
end

local function watchBlueprints()
    local function wire(folder)
        if not folder then
            return
        end
        connect(folder.ChildAdded, function()
            updateBlueprintSlots()
            updateBlueprintBtn()
        end)
        connect(folder.ChildRemoved, function()
            updateBlueprintSlots()
            updateBlueprintBtn()
        end)
    end
    local playerBP = Player:FindFirstChild("PlayerBlueprints")
    if not playerBP then
        connect(Player.ChildAdded, function(added)
            if not mounted or added.Name ~= "PlayerBlueprints" then
                return
            end
            local folder = added:FindFirstChild("Blueprints")
            if folder then
                wire(folder)
                updateBlueprintSlots()
                updateBlueprintBtn()
            else
                connect(added.ChildAdded, function(sub)
                    if mounted and sub.Name == "Blueprints" then
                        wire(sub)
                        updateBlueprintSlots()
                        updateBlueprintBtn()
                    end
                end)
            end
        end)
        return
    end
    local folder = playerBP:FindFirstChild("Blueprints")
    if folder then
        wire(folder)
    else
        connect(playerBP.ChildAdded, function(added)
            if mounted and added.Name == "Blueprints" then
                wire(added)
                updateBlueprintSlots()
                updateBlueprintBtn()
            end
        end)
    end
end

local function stripeList(list)
    local rows = {}
    for _, child in ipairs(list:GetChildren()) do
        if child:GetAttribute("Stripe") then
            table.insert(rows, child)
        end
    end
    table.sort(rows, function(a, b)
        return a.LayoutOrder < b.LayoutOrder
    end)
    for index, row in ipairs(rows) do
        row.BackgroundColor3 = BAND
        row.BackgroundTransparency = index % 2 == 0 and 0 or 1
        row.BorderSizePixel = 0
    end
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

local function actionRow(parent, labelText, buttonText, order)
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
        TextColor3 = LABEL,
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
    row:SetAttribute("Stripe", true)
    return button
end

local function switchRow(parent, labelText, order, getOn, setOn)
    local row = make("Frame", {
        Size = UDim2.new(1, 0, 0, ROW_H),
        BackgroundTransparency = 1,
        LayoutOrder = order,
    }, parent)
    row:SetAttribute("Stripe", true)
    make("TextLabel", {
        Size = UDim2.new(1, -40, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = labelText,
        TextSize = 15,
        TextColor3 = LABEL,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, row)
    local track = make("TextButton", {
        Size = UDim2.fromOffset(28, 14),
        Position = UDim2.new(1, -28, 0.5, -7),
        BackgroundColor3 = FIELD,
        Text = "",
        AutoButtonColor = false,
    }, row)
    make("UICorner", { CornerRadius = UDim.new(1, 0) }, track)
    local knob = make("Frame", {
        Size = UDim2.fromOffset(10, 10),
        Position = UDim2.fromOffset(2, 2),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
    }, track)
    make("UICorner", { CornerRadius = UDim.new(1, 0) }, knob)
    local function paint()
        local on = getOn()
        knob.Position = UDim2.fromOffset(on and 16 or 2, 2)
        track.BackgroundColor3 = on and GREEN or FIELD
    end
    track.MouseButton1Click:Connect(function()
        setOn(not getOn())
        paint()
    end)
    paint()
end

local function scrollingName(parent, text)
    local clip = make("Frame", {
        Size = UDim2.new(1, -4, 0, 14),
        Position = UDim2.new(0, 2, 1, -28),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 2,
    }, parent)
    local textW = Services.TextService:GetTextSize(
        text,
        13,
        Enum.Font.SourceSans,
        Vector2.new(10000, 100)
    ).X
    local clipW = SLOT - 4
    if textW <= clipW then
        make("TextLabel", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Font = Enum.Font.SourceSans,
            Text = text,
            TextSize = 13,
            TextColor3 = TEXT,
            ZIndex = 2,
        }, clip)
        return
    end
    local gap = 18
    local totalW = textW + gap
    local scroller = make("Frame", {
        Size = UDim2.new(0, totalW * 2, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 2,
    }, clip)
    for i = 0, 1 do
        make("TextLabel", {
            Size = UDim2.fromOffset(textW, 14),
            Position = UDim2.fromOffset(i * totalW, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.SourceSans,
            Text = text,
            TextSize = 13,
            TextColor3 = TEXT,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 2,
        }, scroller)
    end
    local function edgeFade(anchorX, posScale, rotation)
        local fade = make("Frame", {
            Size = UDim2.fromOffset(8, 14),
            AnchorPoint = Vector2.new(anchorX, 0),
            Position = UDim2.fromScale(posScale, 0),
            BackgroundColor3 = FIELD,
            BorderSizePixel = 0,
            ZIndex = 4,
        }, clip)
        make("UIGradient", {
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 1),
            }),
            Rotation = rotation,
        }, fade)
    end
    edgeFade(0, 0, 0)
    edgeFade(1, 1, 180)
    local duration = totalW / 28
    task.spawn(function()
        task.wait(1.2)
        while clip.Parent do
            local tween = Services.TweenService:Create(
                scroller,
                TweenInfo.new(duration, Enum.EasingStyle.Linear),
                { Position = UDim2.fromOffset(-totalW, 0) }
            )
            tween:Play()
            tween.Completed:Wait()
            if not clip.Parent then
                break
            end
            scroller.Position = UDim2.fromOffset(0, 0)
        end
    end)
end

local function addSlot(grid, item, order)
    local slot = make("TextButton", {
        BackgroundColor3 = FIELD,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = order,
    }, grid)
    local stroke = make("UIStroke", {
        Color = STROKE,
        Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, slot)
    local image = make("ImageLabel", {
        Size = UDim2.fromScale(0.62, 0.5),
        Position = UDim2.fromScale(0.5, 0.3),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        ScaleType = Enum.ScaleType.Fit,
        Image = item.Image or "",
    }, slot)
    scrollingName(slot, item.Name)
    make("TextLabel", {
        Size = UDim2.new(1, -4, 0, 12),
        Position = UDim2.new(0, 2, 1, -14),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = money(item.Price),
        TextSize = 12,
        TextColor3 = GREEN,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 2,
    }, slot)
    local overlay = make("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.45,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 5,
    }, slot)
    local record = {
        button = slot,
        stroke = stroke,
        image = image,
        overlay = overlay,
        enabled = true,
        item = item,
    }
    slots[item.BoxItemName] = record
    slot.MouseButton1Click:Connect(function()
        if not record.enabled then
            return
        end
        selectedId = item.BoxItemName
        paintSlots()
        updatePurchase()
        saveConfig()
    end)
end

local function applySearch(query)
    query = string.lower(query or "")
    for _, slot in pairs(slots) do
        local name = string.lower(slot.item.Name)
        slot.button.Visible = query == "" or string.find(name, query, 1, true) ~= nil
    end
end

local function startPurchase()
    if purchaseBtn and purchaseBtn.Text == "Stop" then
        buying = false
        return
    end
    if not isEnabled(purchaseBtn) then
        return
    end
    local item = selectedItem()
    if not item or not STORES[item.Store] then
        return
    end
    local pocket = fetchFunds()
    if pocket == nil or pocket < item.Price then
        funds = pocket
        updatePurchase()
        return
    end
    local qty = readQuantity()
    local total = item.Price * qty
    if pocket < total then
        qty = math.floor(pocket / item.Price)
    end
    if qty < 1 then
        return
    end
    local character = Player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    local pressed = hrp and hrp.CFrame
    if not pressed then
        return
    end
    buying = true
    updatePurchase()
    task.spawn(function()
        runBuyLoop(item, qty, pressed, function()
            updatePurchase()
            refreshFunds()
        end)
    end)
end

local function build(parent)
    slots = {}
    root = make("ScrollingFrame", {
        Name = "ShopRoot",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = STROKE,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
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
    make("UIPadding", {
        PaddingBottom = UDim.new(0, 12),
    }, list)

    heading(list, "Shop", 1)
    local items = loadItems()
    if not items then
        local missing = make("TextLabel", {
            Size = UDim2.new(1, 0, 0, ROW_H),
            BackgroundTransparency = 1,
            Font = Enum.Font.SourceSans,
            Text = "Shop unavailable",
            TextSize = 15,
            TextColor3 = MUTED,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 2,
        }, list)
        missing:SetAttribute("Stripe", true)
        stripeList(list)
        return
    end
    if not selectedId then
        selectedId = items[1].BoxItemName
    end

    local search = make("TextBox", {
        Size = UDim2.new(1, 0, 0, ROW_H),
        BackgroundColor3 = FIELD,
        BorderSizePixel = 0,
        ClearTextOnFocus = false,
        Font = Enum.Font.SourceSans,
        PlaceholderText = "Search",
        PlaceholderColor3 = MUTED,
        Text = "",
        TextSize = 15,
        TextColor3 = TEXT,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 2,
    }, list)
    make("UIPadding", {
        PaddingLeft = UDim.new(0, 6),
    }, search)

    local gridHolder = make("Frame", {
        Size = UDim2.new(1, 0, 0, GRID_H),
        BackgroundTransparency = 1,
        LayoutOrder = 3,
    }, list)
    local grid = make("ScrollingFrame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = STROKE,
        CanvasSize = UDim2.new(),
        ScrollingDirection = Enum.ScrollingDirection.Y,
    }, gridHolder)
    local gridLayout = make("UIGridLayout", {
        CellSize = UDim2.fromOffset(SLOT, SLOT),
        CellPadding = UDim2.fromOffset(6, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = Enum.FillDirection.Horizontal,
    }, grid)
    gridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        grid.CanvasSize = UDim2.fromOffset(0, gridLayout.AbsoluteContentSize.Y + 6)
    end)

    for index, item in ipairs(items) do
        addSlot(grid, item, index)
    end
    search:GetPropertyChangedSignal("Text"):Connect(function()
        applySearch(search.Text)
    end)
    paintSlots()

    local qtyRow = make("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        LayoutOrder = 4,
    }, list)
    qtyRow:SetAttribute("Stripe", true)
    make("TextLabel", {
        Size = UDim2.new(1, -40, 0, 16),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = "Quantity",
        TextSize = 15,
        TextColor3 = LABEL,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, qtyRow)
    quantityValue = make("TextLabel", {
        Size = UDim2.fromOffset(36, 16),
        Position = UDim2.new(1, -36, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = tostring(quantity),
        TextSize = 15,
        TextColor3 = TEXT,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, qtyRow)
    local sliderHit = make("TextButton", {
        Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.fromOffset(0, 18),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
    }, qtyRow)
    local sliderTrack = make("Frame", {
        Size = UDim2.new(1, 0, 0, 4),
        Position = UDim2.new(0, 0, 0.5, -2),
        BackgroundColor3 = FIELD,
        BorderSizePixel = 0,
    }, sliderHit)
    quantityFill = make("Frame", {
        Size = UDim2.new((quantity - 1) / 99, 0, 1, 0),
        BackgroundColor3 = BUTTON,
        BorderSizePixel = 0,
    }, sliderTrack)
    local sliding = false
    local function quantityFromMouse()
        local width = sliderTrack.AbsoluteSize.X
        if width <= 0 then
            return
        end
        local pct = math.clamp((UserInputService:GetMouseLocation().X - sliderTrack.AbsolutePosition.X) / width, 0, 1)
        quantity = 1 + math.floor(pct * 99 + 0.5)
        paintQuantity()
        updatePurchase()
    end
    sliderHit.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return
        end
        sliding = true
        quantityFromMouse()
    end)
    connect(UserInputService.InputChanged, function(input)
        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
            quantityFromMouse()
        end
    end)
    connect(UserInputService.InputEnded, function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 or not sliding then
            return
        end
        sliding = false
        saveConfig()
    end)

    purchaseBtn = actionRow(list, "Purchase", "Buy", 5)
    purchaseBtn.MouseButton1Click:Connect(startPurchase)

    heading(list, "Special", 6)
    poeBtn = actionRow(list, "Power of Ease (" .. money(POE_PRICE) .. ")", "Buy", 7)
    poeBtn.MouseButton1Click:Connect(function()
        if not isEnabled(poeBtn) then
            return
        end
        task.spawn(purchasePowerOfEase)
    end)
    blueprintBtn = actionRow(list, "Purchase all blueprints", "Buy", 8)
    blueprintBtn.MouseButton1Click:Connect(function()
        if blueprintBtn.Text == "Stop" then
            buyingBlueprints = false
            return
        end
        if not isEnabled(blueprintBtn) then
            return
        end
        buyingBlueprints = true
        updateBlueprintBtn()
        task.spawn(function()
            runBlueprintLoop(updateBlueprintBtn)
        end)
    end)
    rukiryBtn = actionRow(list, "Purchase Rukiry axe", money(RUKIRY_PRICE), 9)
    rukiryBtn.MouseButton1Click:Connect(function()
        if rukiryBtn.Text == "Stop" then
            buyingRukiry = false
            return
        end
        if not isEnabled(rukiryBtn) then
            return
        end
        buyingRukiry = true
        rukiryBtn.Text = "Stop"
        setEnabled(rukiryBtn, true)
        task.spawn(runRukiry)
    end)

    heading(list, "Settings", 10)
    switchRow(list, "Quick purchase", 11, function()
        return quickPurchase
    end, function(state)
        quickPurchase = state
        saveConfig()
    end)
    switchRow(list, "Force respawn on stuck NPC", 12, function()
        return allowNuclear
    end, function(state)
        allowNuclear = state
        saveConfig()
    end)

    updatePurchase()
    updateBlueprintSlots()
    updateBlueprintBtn()
    updatePowerOfEase()
    if buyingRukiry and rukiryBtn then
        rukiryBtn.Text = "Stop"
        setEnabled(rukiryBtn, true)
    end
    stripeList(list)
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
    watchPowerOfEase()
    if shopItems then
        watchBlueprints()
        pollFunds()
    end
end

function api.unmount()
    mounted = false
    fundsToken += 1
    disconnectAll()
    if root then
        root:Destroy()
        root = nil
    end
    slots = {}
    purchaseBtn = nil
    blueprintBtn = nil
    rukiryBtn = nil
    poeBtn = nil
    quantityValue = nil
    quantityFill = nil
end

return api
