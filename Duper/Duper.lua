local Services = setmetatable({}, {
    __index = function(self, index)
        return game:GetService(index)
    end,
})

local Players           = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local Workspace         = Services.Workspace
local UserInputService  = Services.UserInputService
local ContextActionService = Services.ContextActionService
local RunService        = Services.RunService

local Player            = Players.LocalPlayer
local ClientIsDragging  = ReplicatedStorage:WaitForChild("Interaction"):WaitForChild("ClientIsDragging")

local HOLD_BEFORE_RELEASE = 0.2
local PLACE_RETRIES = 3
local ARRIVE_SLOP = 2.5
local LOG_GAP = 2
local PLANK_GAP = 0.85
local GRAB_RANGE = 22
local OWNER_TIMEOUT = 1
local MOVE_SPEED = 4000
local AMOUNT_MAX = 50
local PILE_GAP = 0.45
local PILE_MAX_HEIGHT = 28

local CLICK_SELECT_ACTION = "LT2DuperClickSelect"
local OUTLINE_COLOR = Color3.fromRGB(0, 255, 255)

local selected = {}
local keyIndex = {}
local allItems = {}
local logLimit = nil
local pileItems = false
local standVertical = true
local clickSelect = false
local outlineFolder
local outlines = {}
local outlineConns = {}
local outlineWatch

local started = false
local mounted = false
local dashWindow
local teardownUi = function() end
local bindClickSelect = function() end
local stopActiveRun = function() end
local guiCleanupHooked = false

local function prettyName(raw)
    return (tostring(raw):gsub("(%l)(%u)", "%1 %2"):gsub("_", " "))
end

local function displayLabel(entry)
    if entry.kind and entry.kind ~= "" then
        return entry.label .. " (" .. entry.kind .. ")"
    end
    return entry.label
end

local root
local busy = false
local abort = false
local setStatus
local cycleDone = {}
local rebuildList
local screenGui

local function isStopped()
    return (not started) or abort or not (screenGui and screenGui.Parent)
end

local function isLandPart(part)
    if not (part and part:IsA("BasePart")) then
        return false
    end
    if part.Size.Y > 48 then
        return false
    end
    local mn = math.min(part.Size.X, part.Size.Z)
    local mx = math.max(part.Size.X, part.Size.Z)
    return mn >= 25 and mx <= 2000
end

local function standingFootprint(part)
    local dims = { part.Size.X, part.Size.Y, part.Size.Z }
    table.sort(dims)
    return math.max(dims[1], dims[2])
end

local function dragTarget(model)
    if model:IsA("BasePart") then
        return model
    end
    return model:FindFirstChild("Main")
        or model:FindFirstChild("WoodSection")
        or model:FindFirstChildWhichIsA("BasePart")
        or model:FindFirstChildWhichIsA("BasePart", true)
end

local function restHeight(model)
    local part = dragTarget(model)
    if not (part and part:IsA("BasePart")) then
        return 0.8
    end
    return math.max(0.4, math.min(part.Size.X, part.Size.Y, part.Size.Z))
end

local function laidCFrame(target, destPos, yaw)
    local s = target.Size
    local axes = {
        { s.X, Vector3.xAxis },
        { s.Y, Vector3.yAxis },
        { s.Z, Vector3.zAxis },
    }
    table.sort(axes, function(a, b)
        if a[1] ~= b[1] then
            return a[1] < b[1]
        end
        return a[2].Y > b[2].Y
    end)
    local upLocal = axes[1][2]
    local alongLocal = axes[3][2]
    local rightLocal = upLocal:Cross(alongLocal)
    if rightLocal.Magnitude < 0.05 then
        alongLocal = axes[2][2]
        rightLocal = upLocal:Cross(alongLocal)
    end
    rightLocal = rightLocal.Unit
    local yawCF = CFrame.Angles(0, yaw, 0)
    local worldR = CFrame.fromMatrix(Vector3.zero, yawCF.RightVector, yawCF.UpVector)
    local localR = CFrame.fromMatrix(Vector3.zero, rightLocal, upLocal)
    return CFrame.new(destPos) * worldR * localR:Inverse()
end

local function uprightCFrame(target, destPos, yaw)
    local s = target.Size
    local axes = {
        { s.X, Vector3.xAxis },
        { s.Y, Vector3.yAxis },
        { s.Z, Vector3.zAxis },
    }
    table.sort(axes, function(a, b)
        return a[1] > b[1]
    end)
    local upLocal = axes[1][2]
    local sideLocal = axes[2][2]
    local rightLocal = upLocal:Cross(sideLocal)
    if rightLocal.Magnitude < 0.05 then
        sideLocal = axes[3][2]
        rightLocal = upLocal:Cross(sideLocal)
    end
    rightLocal = rightLocal.Unit
    local yawCF = CFrame.Angles(0, yaw, 0)
    local worldR = CFrame.fromMatrix(Vector3.zero, yawCF.RightVector, Vector3.yAxis)
    local localR = CFrame.fromMatrix(Vector3.zero, rightLocal, upLocal)
    return CFrame.new(destPos) * worldR * localR:Inverse(), axes[1][1]
end

local function isPlank(model)
    return model and model.Name == "Plank"
end

local PLANK_STAND_LENGTH = 5

local function plankLength(model)
    local part = model and (model:FindFirstChild("WoodSection") or dragTarget(model))
    if not (part and part:IsA("BasePart")) then
        return 0
    end
    return math.max(part.Size.X, part.Size.Y, part.Size.Z)
end

local function standsUp(model)
    return standVertical and isPlank(model)
end

local function itemSpacing(models)
    local spacing = 2
    for _, model in ipairs(models) do
        local target = dragTarget(model)
        if target then
            local gap = if isPlank(model) then PLANK_GAP else LOG_GAP
            spacing = math.max(spacing, standingFootprint(target) + gap)
        end
    end
    return spacing
end

local function flatYaw(cf)
    if not cf then
        return 0
    end
    local _, yaw = cf:ToEulerAnglesYXZ()
    return yaw
end

local function facingCF(cf)
    return CFrame.new(cf.Position) * CFrame.Angles(0, flatYaw(cf), 0)
end

local function buildGridSlots(originCF, count, spacing, xOffset)
    local slots = {}
    if count <= 0 then
        return slots
    end
    spacing = math.max(spacing or 2, 1)
    xOffset = xOffset or 0
    local columns = math.max(1, math.ceil(math.sqrt(count)))
    for i = 0, count - 1 do
        local col = i % columns
        local row = math.floor(i / columns)
        local localPos = Vector3.new(xOffset + (col - (columns - 1) * 0.5) * spacing, 0, -(6 + row * spacing))
        table.insert(slots, originCF:PointToWorldSpace(localPos))
    end
    return slots
end

local homeCF

local function settleModel(model)
    for _, inst in ipairs(model:GetDescendants()) do
        if inst:IsA("BasePart") then
            inst.AssemblyLinearVelocity = Vector3.zero
            inst.AssemblyAngularVelocity = Vector3.zero
            pcall(function()
                inst.Velocity = Vector3.zero
                inst.RotVelocity = Vector3.zero
            end)
        end
    end
end

local function groundYAt(pos, ignore)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = ignore
    local hit = Workspace:Raycast(Vector3.new(pos.X, pos.Y + 50, pos.Z), Vector3.new(0, -120, 0), params)
    if hit then
        return hit.Position.Y
    end
    return pos.Y
end

local function placeLogStanding(model, target, destPos, standUp, pressedCF)
    if not (model and model.Parent and target and target.Parent) then
        return
    end

    settleModel(model)

    if standUp then
        local ignore = { model }
        if Player.Character then
            table.insert(ignore, Player.Character)
        end
        local playerModels = Workspace:FindFirstChild("PlayerModels")
        if playerModels then
            table.insert(ignore, playerModels)
        end
        local gy = groundYAt(destPos, ignore)
        local length = math.max(target.Size.X, target.Size.Y, target.Size.Z)
        destPos = Vector3.new(destPos.X, gy + length * 0.5 + 0.15, destPos.Z)
        local desiredMain = uprightCFrame(target, destPos, flatYaw(pressedCF))
        local pivotOffset = target.CFrame:ToObjectSpace(model:GetPivot())
        model:PivotTo(desiredMain * pivotOffset)
    else
        local yaw = flatYaw(pressedCF)
        local desiredMain = laidCFrame(target, destPos, yaw)
        local pivotOffset = target.CFrame:ToObjectSpace(model:GetPivot())
        model:PivotTo(desiredMain * pivotOffset)
    end

    settleModel(model)
end

local function releaseDrag()
    pcall(function()
        ClientIsDragging:FireServer(nil)
    end)
    task.wait()
end

local function arrivedAt(model, target, destPos)
    if not destPos then
        return false
    end
    local function close(pos)
        local delta = pos - destPos
        return (delta * Vector3.new(1, 0, 1)).Magnitude <= ARRIVE_SLOP
    end
    if target and target.Parent and close(target.Position) then
        return true
    end
    if model and model.Parent then
        return close(model:GetPivot().Position)
    end
    return false
end

local function widenSimulation()
    pcall(function()
        if type(setsimulationradius) == "function" then
            setsimulationradius(10000, 10000)
        end
    end)
    pcall(function()
        if type(sethiddenproperty) ~= "function" then
            return
        end
        sethiddenproperty(Player, "MaximumSimulationRadius", 10000)
        sethiddenproperty(Player, "SimulationRadius", 10000)
    end)
end

local function ownerToken(part)
    if type(gethiddenproperty) ~= "function" or not part then
        return nil
    end
    local ok, value = pcall(gethiddenproperty, part, "NetworkOwnerV3")
    if ok then
        return value
    end
    return nil
end

local function playerRoot()
    local char = Player.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function weOwn(part)
    local mine = ownerToken(playerRoot())
    local owner = ownerToken(part)
    if mine == nil or owner == nil then
        return nil
    end
    return owner == mine
end

local function nudgeRoot(goal)
    local char = Player.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    local savedStand = humanoid and humanoid.PlatformStand
    local savedCollide = {}
    if char then
        for _, inst in ipairs(char:GetDescendants()) do
            if inst:IsA("BasePart") then
                savedCollide[inst] = inst.CanCollide
                inst.CanCollide = false
            end
        end
    end
    if humanoid then
        humanoid.PlatformStand = true
    end

    local function restore()
        if humanoid and humanoid.Parent then
            humanoid.PlatformStand = savedStand or false
        end
        for part, collide in pairs(savedCollide) do
            if part.Parent then
                part.CanCollide = collide
            end
        end
    end

    local hrp = playerRoot()
    if not hrp then
        restore()
        return false
    end
    local deadline = tick() + math.max(0.15, (goal - hrp.Position).Magnitude / MOVE_SPEED + 0.08)
    local arrived = false
    while tick() < deadline do
        if isStopped() then
            break
        end
        hrp = playerRoot()
        if not hrp then
            break
        end
        local delta = goal - hrp.Position
        local yaw = flatYaw(hrp.CFrame)
        if delta.Magnitude <= 2 then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            hrp.CFrame = CFrame.new(goal) * CFrame.Angles(0, yaw, 0)
            arrived = true
            break
        end
        local dt = RunService.Heartbeat:Wait()
        hrp = playerRoot()
        if not hrp or isStopped() then
            break
        end
        delta = goal - hrp.Position
        if delta.Magnitude <= 2 then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            hrp.CFrame = CFrame.new(goal) * CFrame.Angles(0, flatYaw(hrp.CFrame), 0)
            arrived = true
            break
        end
        local step = math.min(delta.Magnitude, MOVE_SPEED * math.clamp(dt, 1 / 240, 1 / 20))
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = CFrame.new(hrp.Position + delta.Unit * step) * CFrame.Angles(0, flatYaw(hrp.CFrame), 0)
    end

    restore()
    return arrived
end

local function parkAtHome()
    local hrp = playerRoot()
    if hrp and homeCF and (hrp.Position - homeCF.Position).Magnitude > 3 then
        nudgeRoot(homeCF.Position)
    end
    hrp = playerRoot()
    if hrp and homeCF then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = homeCF
    end
end

local function standNear(target)
    local hrp = playerRoot()
    if not (hrp and target) then
        return false
    end
    local delta = target.Position - hrp.Position
    local flat = Vector3.new(delta.X, 0, delta.Z)
    local dir = if flat.Magnitude > 0.1 then flat.Unit else Vector3.new(0, 0, -1)
    local stand = target.Position - dir * 8 + Vector3.new(0, 3, 0)
    if (hrp.Position - stand).Magnitude <= 3 then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = CFrame.new(stand)
        return true
    end
    if delta.Magnitude <= 8 then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        return true
    end
    return nudgeRoot(stand)
end

local function claimDrag(model, target)
    if isStopped() or not (model.Parent and target.Parent) then
        return nil
    end
    if not standNear(target) then
        return false
    end
    local deadline = tick() + OWNER_TIMEOUT
    while true do
        if isStopped() or not (model.Parent and target.Parent) then
            return nil
        end
        local hrp = playerRoot()
        if hrp and (target.Position - hrp.Position).Magnitude > 12 then
            if not standNear(target) then
                return false
            end
        elseif hrp then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
        local ok, err = pcall(function()
            ClientIsDragging:FireServer(model)
        end)
        if not ok then
            warn(("[LOT] FireServer errored on '%s': %s"):format(model.Name, tostring(err)))
            return false
        end
        local owned = weOwn(target)
        if owned == true then
            return true
        end
        hrp = playerRoot()
        if tick() >= deadline then
            if hrp and (target.Position - hrp.Position).Magnitude <= GRAB_RANGE then
                return true
            end
            return false
        end
        task.wait()
    end
end

local function MoveObject(v, pressedCF, i, pile, destOverride)
    if isStopped() then
        return nil
    end

    local target = dragTarget(v)
    if not target then
        return false
    end

    local destPos = destOverride
    if not destPos then
        if pile then
            destPos = (pressedCF * CFrame.new(0, 0.08 * (i - 1), 3)).Position
        else
            return false
        end
    end
    local standUp = not pile

    local alreadyOwned = weOwn(target)
    if arrivedAt(v, target, destPos) and alreadyOwned ~= false then
        return true
    end

    local claimed = claimDrag(v, target)
    if claimed == nil then
        releaseDrag()
        return nil
    end
    if not claimed then
        releaseDrag()
        return false
    end

    for _ = 1, PLACE_RETRIES do
        if isStopped() then
            releaseDrag()
            return nil
        end
        if not (v.Parent and target.Parent) then
            releaseDrag()
            return false
        end

        local holdUntil = tick() + HOLD_BEFORE_RELEASE
        while tick() < holdUntil do
            if isStopped() or not (v.Parent and target.Parent) then
                releaseDrag()
                return nil
            end
            local ok, err = pcall(function()
                ClientIsDragging:FireServer(v)
            end)
            if not ok then
                releaseDrag()
                if not pile then
                    warn(("[LOT] FireServer errored on '%s': %s"):format(v.Name, tostring(err)))
                end
                return false
            end
            placeLogStanding(v, target, destPos, standUp, pressedCF)
            task.wait()
        end

        if arrivedAt(v, target, destPos) then
            releaseDrag()
            return true
        end
        releaseDrag()
    end

    releaseDrag()
    return false
end

local GENERIC_NAME = {
    model = true,
    tool = true,
    part = true,
    mesh = true,
    meshpart = true,
    handle = true,
    folder = true,
    woodsection = true,
    main = true,
    item = true,
    looseitem = true,
    union = true,
}

local function valueText(inst)
    if not (inst and inst:IsA("ValueBase")) then
        return nil
    end
    local value = inst.Value
    if value == nil then
        return nil
    end
    local text = tostring(value)
    if text == "" then
        return nil
    end
    return text
end

local function usableName(name)
    return type(name) == "string" and name ~= "" and not GENERIC_NAME[string.lower(name)]
end

local function findValue(root, name)
    return root:FindFirstChild(name) or root:FindFirstChild(name, true)
end

local function objectMatch(v)
    local tree = findValue(v, "TreeClass")
    local treeText = valueText(tree)
    if treeText then
        return "log", treeText
    end

    local box = findValue(v, "PurchasedBoxItemName")
    local boxText = valueText(box)
    if boxText then
        return "boxed", boxText
    end

    for _, key in ipairs({ "ToolName", "ItemName", "PurchasedItemName" }) do
        local text = valueText(findValue(v, key))
        if text then
            return "opened", text
        end
    end

    if usableName(v.Name) then
        return "opened", v.Name
    end

    for _, child in ipairs(v:GetDescendants()) do
        if child:IsA("StringValue") and child.Name ~= "Owner" then
            local text = valueText(child)
            if text and usableName(text) and #text < 64 then
                return "opened", text
            end
        end
    end

    for _, child in ipairs(v:GetChildren()) do
        if usableName(child.Name) and not child:FindFirstChild("Owner") then
            return "opened", child.Name
        end
    end

    if v.Name ~= "" then
        return "opened", v.Name
    end
    return nil
end

local cachedOwnedGroups = {}

local function ownsModel(model)
    if not model or model == Player or model == Player.Character then
        return false
    end
    local owner = model:FindFirstChild("Owner")
    if not (owner and owner:IsA("ValueBase")) then
        return false
    end
    local value = owner.Value
    if value == Player or value == Player.Name or value == Player.UserId or value == tostring(Player.UserId) then
        return true
    end
    if typeof(value) == "Instance" then
        return value:IsA("Player") and value.UserId == Player.UserId
    end
    if type(value) == "string" then
        local lower = string.lower(value)
        return lower == string.lower(Player.Name) or lower == string.lower(Player.DisplayName)
    end
    if type(value) == "number" then
        return value == Player.UserId
    end
    return false
end

local function isOwnedLand(inst)
    if inst:IsA("BasePart") then
        return isLandPart(inst)
    end
    if not inst:IsA("Model") then
        return false
    end
    for _, child in ipairs(inst:GetChildren()) do
        if child:IsA("BasePart") and isLandPart(child) then
            return true
        end
    end
    return false
end

local function isPlotModel(inst)
    local properties = Workspace:FindFirstChild("Properties")
    return properties ~= nil and inst.Parent == properties
end

local cachedLands = {}
local landPlotCount = 0

local function log(message)
    print("[LOT] " .. tostring(message))
end

local function logError(where, err)
    warn("[LOT] " .. tostring(where) .. "\n" .. tostring(err))
end

local function updateLandCache()
    table.clear(cachedLands)
    landPlotCount = 0
    local properties = Workspace:FindFirstChild("Properties")
    if not properties then
        return
    end
    for _, child in ipairs(properties:GetChildren()) do
        if ownsModel(child) then
            landPlotCount += 1
            for _, part in ipairs(child:GetChildren()) do
                if part:IsA("BasePart") and isLandPart(part) then
                    table.insert(cachedLands, part)
                end
            end
        end
    end
end

local function positionOnLand(pos)
    for _, part in ipairs(cachedLands) do
        if part.Parent then
            local localPos = part.CFrame:PointToObjectSpace(pos)
            local half = part.Size * 0.5
            if math.abs(localPos.X) <= half.X + 3
                and math.abs(localPos.Z) <= half.Z + 3
                and localPos.Y >= -half.Y - 10
                and localPos.Y <= half.Y + 80
            then
                return true
            end
        end
    end
    return false
end

local function footprintOnLand(cf, size)
    if typeof(cf) ~= "CFrame" or typeof(size) ~= "Vector3" then
        return false
    end
    local half = size * 0.5
    for _, x in ipairs({ -half.X, 0, half.X }) do
        for _, y in ipairs({ -half.Y, 0, half.Y }) do
            for _, z in ipairs({ -half.Z, 0, half.Z }) do
                if positionOnLand(cf:PointToWorldSpace(Vector3.new(x, y, z))) then
                    return true
                end
            end
        end
    end
    return false
end

local function overlapsLand(inst)
    if inst:IsA("BasePart") then
        return footprintOnLand(inst.CFrame, inst.Size)
    end
    local target = dragTarget(inst)
    if target and footprintOnLand(target.CFrame, target.Size) then
        return true
    end
    if inst:IsA("Model") then
        local ok, cf, size = pcall(function()
            return inst:GetBoundingBox()
        end)
        if ok and footprintOnLand(cf, size) then
            return true
        end
    end
    return false
end

local function onPlayerPlot(inst)
    if not inst or inst == Player or inst == Player.Character or isPlotModel(inst) then
        return false
    end
    local properties = Workspace:FindFirstChild("Properties")
    if properties then
        local current = inst
        while current and current ~= properties and current ~= Workspace do
            if current.Parent == properties then
                return ownsModel(current)
            end
            current = current.Parent
        end
    end
    local target = dragTarget(inst)
    if not target then
        return false
    end
    return overlapsLand(inst)
end

local function forEachOwned(callback)
    local models = Workspace:FindFirstChild("PlayerModels")
    if not models then
        log("No PlayerModels")
        return
    end
    for _, model in ipairs(models:GetChildren()) do
        if ownsModel(model) and dragTarget(model) then
            callback(model)
        end
    end
end

local function ownedItemFromInstance(inst)
    local current = inst
    while current and current ~= Workspace do
        if current.Parent and current.Parent.Name == "PlayerModels" then
            if ownsModel(current) and dragTarget(current) then
                return current
            end
            return nil
        end
        current = current.Parent
    end
    return nil
end

local function kindFor(form, value)
    local name = string.lower(tostring(value))
    if form == "log" then
        return "Log"
    end
    if string.find(name, "gift", 1, true) or string.find(name, "present", 1, true) or string.find(name, "cgift", 1, true) then
        return if form == "boxed" then "Boxed Present" else "Present"
    end
    if string.find(name, "paint", 1, true) or string.find(name, "portrait", 1, true) then
        return if form == "boxed" then "Boxed Painting" else "Painting"
    end
    if string.find(name, "axe", 1, true) or string.find(name, "hatchet", 1, true) then
        return if form == "boxed" then "Boxed Axe" else "Axe"
    end
    return if form == "boxed" then "Boxed" else "Opened"
end

local function itemIdentity(model)
    local form, value = objectMatch(model)
    if not form or value == nil or tostring(value) == "" then
        return nil
    end
    value = tostring(value)
    local id = form .. ":" .. value
    local kind = kindFor(form, value)
    if isPlank(model) and plankLength(model) <= PLANK_STAND_LENGTH then
        id ..= ":short"
        kind = "Short"
    end
    return form, value, id, kind
end

local function groupFor(kind)
    local name = string.lower(kind or "")
    if name == "log" or name == "short" then
        return "Logs"
    end
    if string.find(name, "axe", 1, true) then
        return "Axes"
    end
    if string.find(name, "present", 1, true) or string.find(name, "gift", 1, true) then
        return "Presents"
    end
    if string.find(name, "paint", 1, true) then
        return "Paintings"
    end
    return "Other"
end

local function refreshOwnedSnapshot()
    local keep = {}
    for id, on in pairs(selected) do
        if on then
            keep[id] = true
        end
    end
    table.clear(selected)
    table.clear(keyIndex)
    table.clear(allItems)

    local counts = {}
    local unique = {}
    local onPlot = 0
    forEachOwned(function(model)
        onPlot += 1
        local form, value, id, kind = itemIdentity(model)
        if form then
            counts[id] = (counts[id] or 0) + 1
            if not unique[id] then
                unique[id] = {
                    id = id,
                    label = prettyName(value),
                    kind = kind,
                    form = form,
                    keys = { value },
                }
                selected[id] = keep[id] == true
                keyIndex[id] = unique[id]
                table.insert(allItems, unique[id])
            end
        end
    end)
    log(("Owned items %d, types %d"):format(onPlot, #allItems))

    local buckets = {
        Logs = {},
        Axes = {},
        Presents = {},
        Paintings = {},
        Other = {},
    }
    for id, entry in pairs(unique) do
        entry.ownedCount = counts[id]
        table.insert(buckets[groupFor(entry.kind)], entry)
    end

    local groups = {}
    for _, name in ipairs({ "Logs", "Axes", "Presents", "Paintings", "Other" }) do
        local items = buckets[name]
        table.sort(items, function(a, b)
            return string.lower(a.label) < string.lower(b.label)
        end)
        if #items > 0 then
            table.insert(groups, { name = name .. "  (" .. #items .. ")", items = items })
        end
    end
    cachedOwnedGroups = groups
end

local function objectIsSelected(model)
    local form, value, id = itemIdentity(model)
    if not form then
        return false
    end
    local entry = keyIndex[id]
    if entry and selected[entry.id] then
        return true, displayLabel(entry)
    end
    return false
end

local function anySelected()
    for _, entry in ipairs(allItems) do
        if selected[entry.id] then
            return true
        end
    end
    return false
end

local function dropOutline(model)
    local hl = outlines[model]
    outlines[model] = nil
    if hl then
        hl:Destroy()
    end
    local conn = outlineConns[model]
    outlineConns[model] = nil
    if conn then
        conn:Disconnect()
    end
end

local function syncOutlines()
    if not started then
        local pending = {}
        for model in pairs(outlines) do
            table.insert(pending, model)
        end
        for _, model in ipairs(pending) do
            dropOutline(model)
        end
        return
    end
    if not (outlineFolder and outlineFolder.Parent) then
        return
    end
    local want = {}
    forEachOwned(function(model)
        if objectIsSelected(model) then
            want[model] = true
        end
    end)
    for model in pairs(outlines) do
        if not want[model] or not model.Parent then
            dropOutline(model)
        end
    end
    for model in pairs(want) do
        local hl = outlines[model]
        if hl and hl.Parent then
            hl.Adornee = model
        else
            local oldConn = outlineConns[model]
            if oldConn then
                outlineConns[model] = nil
                oldConn:Disconnect()
            end
            hl = Instance.new("Highlight")
            hl.Name = "DuperOutline"
            hl.Adornee = model
            hl.FillColor = OUTLINE_COLOR
            hl.OutlineColor = OUTLINE_COLOR
            hl.FillTransparency = 0.4
            hl.OutlineTransparency = 0
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = outlineFolder
            outlines[model] = hl
            outlineConns[model] = model.Destroying:Connect(function()
                dropOutline(model)
            end)
        end
    end
end

local function matchHit(inst)
    local model = ownedItemFromInstance(inst)
    if not model then
        return nil
    end
    local form, value, id, kind = itemIdentity(model)
    if not form then
        return nil
    end
    return {
        form = form,
        value = value,
        id = id,
        kind = kind,
    }
end

local function entryForMatch(match)
    if not match then
        return nil
    end
    return keyIndex[match.id]
end

local function labelForHit(inst)
    local match = matchHit(inst)
    if not match then
        return nil
    end
    local entry = entryForMatch(match)
    if entry then
        return displayLabel(entry)
    end
    return prettyName(match.value) .. " (" .. (match.kind or kindFor(match.form, match.value)) .. ")"
end

local function ownerDisplayName(owner)
    if not (owner and owner:IsA("ValueBase")) then
        return nil
    end
    local value = owner.Value
    if typeof(value) == "Instance" then
        if value:IsA("Player") then
            if value.DisplayName ~= "" then
                return value.DisplayName
            end
            return value.Name
        end
        return value.Name
    end
    if type(value) == "number" then
        local plr = Players:GetPlayerByUserId(value)
        if plr and plr.DisplayName ~= "" then
            return plr.DisplayName
        end
        return if plr then plr.Name else tostring(value)
    end
    if type(value) == "string" and value ~= "" then
        local asNumber = tonumber(value)
        if asNumber then
            local plr = Players:GetPlayerByUserId(asNumber)
            if plr then
                if plr.DisplayName ~= "" then
                    return plr.DisplayName
                end
                return plr.Name
            end
        end
        return value
    end
    return nil
end

local function hoverLines(inst)
    local label = labelForHit(inst)
    local ownerName
    local plank
    local current = inst
    while current and current ~= Workspace do
        if not plank and isPlank(current) then
            plank = current
        end
        if current.Name == "PlayerModels" or isPlotModel(current) then
            break
        end
        local owner = current:FindFirstChild("Owner")
        if owner and owner:IsA("ValueBase") and not ownerName then
            ownerName = ownerDisplayName(owner)
        end
        current = current.Parent
    end
    local lines = {}
    if label then
        table.insert(lines, label)
    end
    if ownerName then
        table.insert(lines, ownerName)
    end
    if plank then
        local part = plank:FindFirstChild("WoodSection") or dragTarget(plank)
        if part and part:IsA("BasePart") then
            local length = math.max(part.Size.X, part.Size.Y, part.Size.Z)
            table.insert(lines, string.format("%d studs", math.floor(length + 0.5)))
        end
    end
    if #lines == 0 then
        return nil
    end
    return table.concat(lines, "\n")
end

local function selectTypeFromHit(inst)
    local match = matchHit(inst)
    if not match then
        return false
    end
    local entry = entryForMatch(match)
    if not entry then
        refreshOwnedSnapshot()
        entry = entryForMatch(match)
    end
    if not entry then
        return false
    end
    selected[entry.id] = not selected[entry.id]
    return true
end

local function boundsSize(model)
    local ok, _, size = pcall(function()
        return model:GetBoundingBox()
    end)
    if ok and typeof(size) == "Vector3" then
        return size
    end
    local part = dragTarget(model)
    if part then
        return part.Size
    end
    return Vector3.new(2, 2, 2)
end

local function buildPileSlots(originCF, models)
    local slots = {}
    local x = 0
    local used = 0
    local columnWidth = 0
    local ignore = {}
    if Player.Character then
        table.insert(ignore, Player.Character)
    end
    local playerModels = Workspace:FindFirstChild("PlayerModels")
    if playerModels then
        table.insert(ignore, playerModels)
    end

    for _, model in ipairs(models) do
        local part = dragTarget(model)
        local height = restHeight(model)
        local width = if part then standingFootprint(part) + PILE_GAP else 2
        if used > 0 and used + height > PILE_MAX_HEIGHT then
            x += columnWidth
            used = 0
            columnWidth = 0
        end
        columnWidth = math.max(columnWidth, width)
        local world = originCF:PointToWorldSpace(Vector3.new(x, 0, -6))
        local ground = groundYAt(Vector3.new(world.X, originCF.Position.Y, world.Z), ignore)
        table.insert(slots, Vector3.new(world.X, ground + used + height * 0.5 + 0.2, world.Z))
        used += height + PILE_GAP
    end
    return slots
end

local function RunPass()
    local char = Player.Character
    root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then
        setStatus("No character")
        return
    end

    if not anySelected() then
        setStatus("Select an item")
        return
    end

    local pressedCF = root.CFrame
    homeCF = pressedCF
    widenSimulation()
    local originCF = facingCF(pressedCF)

    local matches = {}
    forEachOwned(function(v)
        local ok, label = objectIsSelected(v)
        if ok and dragTarget(v) then
            table.insert(matches, {
                model = v,
                label = label,
            })
        end
    end)

    local alive = {}
    for _, job in ipairs(matches) do
        alive[job.model] = true
    end
    for model in pairs(cycleDone) do
        if not alive[model] then
            cycleDone[model] = nil
        end
    end

    local pending = {}
    for _, job in ipairs(matches) do
        if not cycleDone[job.model] then
            table.insert(pending, job)
        end
    end
    if #pending == 0 and #matches > 0 then
        table.clear(cycleDone)
        pending = matches
    end

    if logLimit and #pending > logLimit then
        local trimmed = {}
        for i = 1, logLimit do
            trimmed[i] = pending[i]
        end
        pending = trimmed
    end

    local standModels = {}
    local nearModels = {}
    local pileModels = {}
    for _, job in ipairs(pending) do
        if isPlank(job.model) and not standVertical then
            table.insert(nearModels, job.model)
        elseif not pileItems and standsUp(job.model) then
            table.insert(standModels, job.model)
        else
            table.insert(pileModels, job.model)
        end
    end
    local standSlots = buildGridSlots(originCF, #standModels, itemSpacing(standModels), 0)
    local pileSlots = buildPileSlots(originCF, pileModels)
    local groundIgnore = {}
    if Player.Character then
        table.insert(groundIgnore, Player.Character)
    end
    local playerModels = Workspace:FindFirstChild("PlayerModels")
    if playerModels then
        table.insert(groundIgnore, playerModels)
    end
    local nearSlots = {}
    if #nearModels > 0 then
        local probe = originCF:PointToWorldSpace(Vector3.new(0, 0, -4))
        local gy = groundYAt(probe, groundIgnore)
        for i = 1, #nearModels do
            nearSlots[i] = Vector3.new(probe.X, gy + 0.5, probe.Z)
        end
    end

    local queue = {}
    local standI = 1
    local nearI = 1
    local pileI = 1
    for _, job in ipairs(pending) do
        local near = isPlank(job.model) and not standVertical
        local stand = not near and not pileItems and standsUp(job.model)
        local dest
        if near then
            dest = nearSlots[nearI]
            nearI += 1
        elseif stand then
            dest = standSlots[standI]
            standI += 1
        else
            dest = pileSlots[pileI]
            pileI += 1
        end
        if dest then
            table.insert(queue, {
                job = job,
                dest = dest,
                pile = not stand,
            })
        end
    end

    local moved = 0
    local total = #queue
    local index = 0
    while #queue > 0 do
        if isStopped() then
            releaseDrag()
            parkAtHome()
            setStatus("Stopped")
            return
        end
        local hrp = playerRoot()
        local fromPos = hrp and hrp.Position or pressedCF.Position
        local bestI = 1
        local bestD = math.huge
        for i, item in ipairs(queue) do
            local target = dragTarget(item.job.model)
            local pos = (target and target.Position) or item.job.model:GetPivot().Position
            local flat = Vector3.new(pos.X - fromPos.X, 0, pos.Z - fromPos.Z)
            if flat.Magnitude < bestD then
                bestD = flat.Magnitude
                bestI = i
            end
        end
        local item = table.remove(queue, bestI)
        index += 1
        setStatus(("Moving %s (%d/%d)"):format(item.job.label, index, total))
        local placed = MoveObject(item.job.model, pressedCF, index, item.pile, item.dest)
        if placed == nil or isStopped() then
            releaseDrag()
            parkAtHome()
            setStatus("Stopped")
            return
        end
        if placed then
            cycleDone[item.job.model] = true
            moved += 1
        end
    end

    releaseDrag()
    parkAtHome()

    local left = #pending - moved
    if moved == 0 then
        setStatus(if #pending == 0 then "No matching items" else "Couldn't grab")
    elseif left > 0 then
        setStatus(("Moved %d, %d left"):format(moved, left))
    else
        setStatus(("Moved %d item%s"):format(moved, if moved == 1 then "" else "s"))
    end
end

local function buildInterface(parent, ctx)
    local function make(className, props, parentInst)
        local inst = Instance.new(className)
        for key, value in pairs(props) do
            inst[key] = value
        end
        inst.Parent = parentInst
        return inst
    end

    dashWindow = ctx and ctx.window or dashWindow
    screenGui = ctx and ctx.screenGui or screenGui

    local pending = {}
    for model in pairs(outlines) do
        table.insert(pending, model)
    end
    for _, model in ipairs(pending) do
        dropOutline(model)
    end
    if outlineFolder then
        outlineFolder:Destroy()
        outlineFolder = nil
    end
    if outlineWatch then
        outlineWatch:Disconnect()
        outlineWatch = nil
    end
    outlineFolder = make("Folder", {
        Name = "DuperOutlines",
    }, screenGui)
    do
        local queued = false
        outlineWatch = Workspace.DescendantAdded:Connect(function(desc)
            if desc.Name ~= "Owner" or queued then
                return
            end
            queued = true
            task.delay(0.15, function()
                queued = false
                if started then
                    syncOutlines()
                end
            end)
        end)
    end

    if not guiCleanupHooked and screenGui then
        guiCleanupHooked = true
        screenGui.Destroying:Connect(function()
            started = false
            abort = true
            ContextActionService:UnbindAction(CLICK_SELECT_ACTION)
            teardownUi()
        end)
    end

    local toggleKey = Enum.KeyCode.Tab
    local listeningForKey = false
    local CONFIG_DIR = "LT2Scripts"
    local CONFIG_FILE = CONFIG_DIR .. "/settings.json"

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
        local picked = {}
        for id, on in pairs(selected) do
            if on then
                table.insert(picked, id)
            end
        end
        table.sort(picked)
        local payload = {
            toggleKey = toggleKey.Name,
            selected = picked,
            amount = logLimit or "unlimited",
            pile = pileItems,
            vertical = standVertical,
            clickSelect = clickSelect,
        }
        local encodedOk, encoded = pcall(function()
            return Services.HttpService:JSONEncode(payload)
        end)
        if encodedOk then
            pcall(writefile, CONFIG_FILE, encoded)
        end
    end

    local savedConfig = readSavedConfig()
    if savedConfig then
        if type(savedConfig.toggleKey) == "string" then
            local keyOk, key = pcall(function()
                return Enum.KeyCode[savedConfig.toggleKey]
            end)
            if keyOk and key and key ~= Enum.KeyCode.Unknown then
                toggleKey = key
                if ctx and ctx.setToggleKey then
                    ctx.setToggleKey(toggleKey)
                end
            end
        end
        if type(savedConfig.selected) == "table" then
            for _, id in ipairs(savedConfig.selected) do
                if type(id) == "string" then
                    selected[id] = true
                end
            end
        end
        if savedConfig.amount == "unlimited" then
            logLimit = nil
        elseif type(savedConfig.amount) == "number" then
            logLimit = math.clamp(math.floor(savedConfig.amount), 1, AMOUNT_MAX)
        end
        if type(savedConfig.pile) == "boolean" then
            pileItems = savedConfig.pile
        end
        if type(savedConfig.vertical) == "boolean" then
            standVertical = savedConfig.vertical
        end
        if type(savedConfig.clickSelect) == "boolean" then
            clickSelect = savedConfig.clickSelect
        end
    end

    local root = make("Frame", {
        Name = "DuperRoot",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
    }, parent)

    local timerLabel = make("TextLabel", {
        Size = UDim2.fromOffset(56, 22),
        Position = UDim2.new(1, -64, 0, 4),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = "0:00",
        TextSize = 16,
        TextColor3 = Color3.fromRGB(140, 140, 140),
        TextXAlignment = Enum.TextXAlignment.Right,
    }, root)

    local timerToken = 0
    local timerStart = 0
    local timerRunning = false

    local function setTimerDisplay(sec)
        if not (timerLabel and timerLabel.Parent) then
            return
        end
        sec = math.max(0, math.floor(sec + 0.0001))
        timerLabel.Text = string.format("%d:%02d", math.floor(sec / 60), sec % 60)
        timerLabel.TextColor3 = if sec >= 60 then Color3.fromRGB(210, 70, 70) else Color3.fromRGB(140, 140, 140)
    end

    local function stopRunTimer()
        if not timerRunning then
            return
        end
        timerRunning = false
        timerToken += 1
        setTimerDisplay(tick() - timerStart)
    end

    local function startRunTimer()
        timerToken += 1
        local token = timerToken
        timerStart = tick()
        timerRunning = true
        setTimerDisplay(0)
        task.spawn(function()
            while token == timerToken and timerRunning and screenGui and screenGui.Parent do
                setTimerDisplay(tick() - timerStart)
                task.wait(0.15)
            end
        end)
    end

    local plotTab = make("TextButton", {
        Size = UDim2.new(0.5, -1, 0, 22),
        Position = UDim2.fromOffset(0, 32),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSansBold,
        Text = "On Plot",
        TextSize = 15,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        AutoButtonColor = false,
    }, root)

    local settingsTab = make("TextButton", {
        Size = UDim2.new(0.5, -1, 0, 22),
        Position = UDim2.new(0.5, 1, 0, 32),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = "Settings",
        TextSize = 15,
        TextColor3 = Color3.fromRGB(175, 175, 175),
        AutoButtonColor = false,
    }, root)

    local plotPage = make("Frame", {
        Size = UDim2.new(1, -16, 1, -62),
        Position = UDim2.fromOffset(8, 58),
        BackgroundTransparency = 1,
    }, root)

    local settingsPage = make("Frame", {
        Size = UDim2.new(1, -16, 1, -62),
        Position = UDim2.fromOffset(8, 58),
        BackgroundTransparency = 1,
        Visible = false,
    }, root)

    make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = "Toggle UI",
        TextSize = 14,
        TextColor3 = Color3.fromRGB(160, 160, 160),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, settingsPage)

    local keyBtn = make("TextButton", {
        Size = UDim2.fromOffset(120, 22),
        Position = UDim2.fromOffset(0, 22),
        BackgroundColor3 = Color3.fromRGB(58, 58, 58),
        BorderSizePixel = 0,
        Font = Enum.Font.SourceSans,
        Text = toggleKey.Name,
        TextSize = 15,
        TextColor3 = Color3.fromRGB(230, 230, 230),
        AutoButtonColor = false,
    }, settingsPage)

    local function amountText()
        if logLimit == nil then
            return "Unlimited"
        end
        return tostring(logLimit)
    end

    local amountLabel = make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.fromOffset(0, 56),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = "Amount  " .. amountText(),
        TextSize = 14,
        TextColor3 = Color3.fromRGB(160, 160, 160),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, settingsPage)

    local amountSlider = make("TextButton", {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.fromOffset(0, 76),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    }, settingsPage)

    local amountFill = make("Frame", {
        Size = UDim2.new(if logLimit then logLimit / (AMOUNT_MAX + 1) else 1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(230, 230, 230),
        BorderSizePixel = 0,
    }, amountSlider)

    local function showAmount(limit)
        logLimit = limit
        amountLabel.Text = "Amount  " .. amountText()
        local alpha = if logLimit then logLimit / (AMOUNT_MAX + 1) else 1
        amountFill.Size = UDim2.new(alpha, 0, 1, 0)
    end

    local function amountFromX(x)
        local width = amountSlider.AbsoluteSize.X
        if width <= 0 then
            return nil
        end
        local alpha = math.clamp((x - amountSlider.AbsolutePosition.X) / width, 0, 1)
        if alpha >= 0.98 then
            return nil
        end
        return math.clamp(math.floor(alpha * AMOUNT_MAX + 0.5), 1, AMOUNT_MAX)
    end

    amountSlider.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return
        end
        showAmount(amountFromX(input.Position.X))
        local dragging = true
        local moveConn
        local endConn
        moveConn = UserInputService.InputChanged:Connect(function(changed)
            if dragging and changed.UserInputType == Enum.UserInputType.MouseMovement then
                showAmount(amountFromX(changed.Position.X))
            end
        end)
        endConn = UserInputService.InputEnded:Connect(function(ended)
            if ended.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
                moveConn:Disconnect()
                endConn:Disconnect()
                saveConfig()
            end
        end)
    end)

    make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.fromOffset(0, 102),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = "Pile",
        TextSize = 14,
        TextColor3 = Color3.fromRGB(160, 160, 160),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, settingsPage)

    local pileBtn = make("TextButton", {
        Size = UDim2.fromOffset(120, 22),
        Position = UDim2.fromOffset(0, 122),
        BackgroundColor3 = Color3.fromRGB(58, 58, 58),
        BorderSizePixel = 0,
        Font = Enum.Font.SourceSans,
        Text = if pileItems then "On" else "Off",
        TextSize = 15,
        TextColor3 = Color3.fromRGB(230, 230, 230),
        AutoButtonColor = false,
    }, settingsPage)

    pileBtn.MouseButton1Click:Connect(function()
        pileItems = not pileItems
        pileBtn.Text = if pileItems then "On" else "Off"
        saveConfig()
    end)

    make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.fromOffset(0, 156),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = "Vertical",
        TextSize = 14,
        TextColor3 = Color3.fromRGB(160, 160, 160),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, settingsPage)

    local verticalBtn = make("TextButton", {
        Size = UDim2.fromOffset(120, 22),
        Position = UDim2.fromOffset(0, 176),
        BackgroundColor3 = Color3.fromRGB(58, 58, 58),
        BorderSizePixel = 0,
        Font = Enum.Font.SourceSans,
        Text = if standVertical then "On" else "Off",
        TextSize = 15,
        TextColor3 = Color3.fromRGB(230, 230, 230),
        AutoButtonColor = false,
    }, settingsPage)

    verticalBtn.MouseButton1Click:Connect(function()
        standVertical = not standVertical
        verticalBtn.Text = if standVertical then "On" else "Off"
        saveConfig()
    end)

    make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.fromOffset(0, 210),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = "Click select",
        TextSize = 14,
        TextColor3 = Color3.fromRGB(160, 160, 160),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, settingsPage)

    local clickBtn = make("TextButton", {
        Size = UDim2.fromOffset(120, 22),
        Position = UDim2.fromOffset(0, 230),
        BackgroundColor3 = Color3.fromRGB(58, 58, 58),
        BorderSizePixel = 0,
        Font = Enum.Font.SourceSans,
        Text = if clickSelect then "On" else "Off",
        TextSize = 15,
        TextColor3 = Color3.fromRGB(230, 230, 230),
        AutoButtonColor = false,
    }, settingsPage)

    local hoverHint = make("TextLabel", {
        Name = "HoverHint",
        AutomaticSize = Enum.AutomaticSize.XY,
        Size = UDim2.fromOffset(0, 0),
        BackgroundColor3 = Color3.fromRGB(18, 18, 18),
        BackgroundTransparency = 0.12,
        BorderSizePixel = 0,
        Font = Enum.Font.SourceSans,
        Text = "",
        TextSize = 15,
        TextColor3 = Color3.fromRGB(230, 230, 230),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Visible = false,
        ZIndex = 20,
    }, screenGui)
    make("UIPadding", {
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
        PaddingTop = UDim.new(0, 3),
        PaddingBottom = UDim.new(0, 3),
    }, hoverHint)

    local hoverConn

    local function pointerOverWindow()
        if not (dashWindow and dashWindow.Visible and dashWindow.Parent) then
            return false
        end
        local mousePos = UserInputService:GetMouseLocation()
        local gui = dashWindow:FindFirstAncestorWhichIsA("ScreenGui")
        local x, y = mousePos.X, mousePos.Y
        if not (gui and gui.IgnoreGuiInset) then
            local inset = Services.GuiService:GetGuiInset()
            x -= inset.X
            y -= inset.Y
        end
        local pos = dashWindow.AbsolutePosition
        local size = dashWindow.AbsoluteSize
        return x >= pos.X and x <= pos.X + size.X
            and y >= pos.Y and y <= pos.Y + size.Y
    end

    local function updateHoverHint()
        if not (hoverHint and hoverHint.Parent) then
            return
        end
        local target = Player:GetMouse().Target
        local label = if target then hoverLines(target) else nil
        if not label or pointerOverWindow() or UserInputService:GetFocusedTextBox() then
            hoverHint.Visible = false
            return
        end
        hoverHint.Text = label
        local mousePos = UserInputService:GetMouseLocation()
        local gui = hoverHint:FindFirstAncestorWhichIsA("ScreenGui")
        local x, y = mousePos.X, mousePos.Y
        if not (gui and gui.IgnoreGuiInset) then
            local inset = Services.GuiService:GetGuiInset()
            x -= inset.X
            y -= inset.Y
        end
        local bounds = hoverHint.TextBounds
        local w = bounds.X + 12
        local h = bounds.Y + 6
        local view = screenGui.AbsoluteSize
        local px, py = x + 16, y + 18
        if px + w > view.X then
            px = math.max(0, x - 16 - w)
        end
        if py + h > view.Y then
            py = math.max(0, y - 12 - h)
        end
        hoverHint.Position = UDim2.fromOffset(px, py)
        hoverHint.Visible = true
    end

    local function setHoverTracking(on)
        if hoverConn then
            hoverConn:Disconnect()
            hoverConn = nil
        end
        hoverHint.Visible = false
        if not on then
            return
        end
        hoverConn = Services.RunService.RenderStepped:Connect(updateHoverHint)
    end

    local function onClickSelect(_, state)
        if state ~= Enum.UserInputState.Begin or not started or not clickSelect or not (dashWindow and dashWindow.Visible) then
            return Enum.ContextActionResult.Pass
        end
        if pointerOverWindow() or UserInputService:GetFocusedTextBox() then
            return Enum.ContextActionResult.Pass
        end
        local target = Player:GetMouse().Target
        if not target or not selectTypeFromHit(target) then
            return Enum.ContextActionResult.Pass
        end
        if rebuildList then
            rebuildList()
        end
        syncOutlines()
        return Enum.ContextActionResult.Sink
    end

    local function applyClickSelect()
        if clickBtn and clickBtn.Parent then
            clickBtn.Text = if clickSelect then "On" else "Off"
        end
        ContextActionService:UnbindAction(CLICK_SELECT_ACTION)
        if not (started and clickSelect) then
            return
        end
        ContextActionService:BindActionAtPriority(
            CLICK_SELECT_ACTION,
            onClickSelect,
            false,
            Enum.ContextActionPriority.High.Value,
            Enum.UserInputType.MouseButton1
        )
    end

    clickBtn.MouseButton1Click:Connect(function()
        clickSelect = not clickSelect
        applyClickSelect()
        saveConfig()
    end)
    setHoverTracking(true)
    applyClickSelect()

    local searchQuery = ""

    local searchBox = make("TextBox", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundColor3 = Color3.fromRGB(28, 28, 28),
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Font = Enum.Font.SourceSans,
        Text = "",
        PlaceholderText = "Search",
        PlaceholderColor3 = Color3.fromRGB(110, 110, 110),
        TextSize = 14,
        TextColor3 = Color3.fromRGB(230, 230, 230),
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        ClipsDescendants = true,
    }, plotPage)
    make("UIPadding", {
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
    }, searchBox)

    local function itemMatchesSearch(entry)
        if searchQuery == "" then
            return true
        end
        local hay = string.lower(table.concat({
            entry.label or "",
            entry.kind or "",
            entry.id or "",
            displayLabel(entry),
        }, " "))
        for word in string.gmatch(searchQuery, "%S+") do
            if not string.find(hay, word, 1, true) then
                return false
            end
        end
        return true
    end

    local list = make("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, -120),
        Position = UDim2.fromOffset(0, 24),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Color3.fromRGB(70, 70, 70),
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
    }, plotPage)

    local listInner = make("Frame", {
        Size = UDim2.new(1, -6, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
    }, list)

    make("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 1),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, listInner)

    local function rowText(entry, on)
        return (on and "[x]  " or "[ ]  ") .. displayLabel(entry) .. "  x" .. tostring(entry.ownedCount or 0)
    end

    rebuildList = function()
        if not (list and list.Parent) then
            return
        end
        local scroll = list.CanvasPosition
        for _, child in ipairs(listInner:GetChildren()) do
            if not child:IsA("UIListLayout") then
                child:Destroy()
            end
        end

        local order = 0
        local shown = 0
        for _, group in ipairs(cachedOwnedGroups) do
            local visible = {}
            for _, entry in ipairs(group.items) do
                if itemMatchesSearch(entry) then
                    table.insert(visible, entry)
                end
            end
            if #visible > 0 then
            order += 1
            make("TextLabel", {
                Size = UDim2.new(1, 0, 0, 16),
                BackgroundTransparency = 1,
                Font = Enum.Font.SourceSans,
                Text = group.name,
                TextSize = 14,
                TextColor3 = Color3.fromRGB(100, 100, 100),
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = order,
            }, listInner)

            for _, entry in ipairs(visible) do
                order += 1
                shown += 1
                local on = selected[entry.id] == true
                local btn = make("TextButton", {
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.SourceSans,
                    Text = rowText(entry, on),
                    TextSize = 15,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    AutoButtonColor = false,
                    LayoutOrder = order,
                }, listInner)
                local itemId = entry.id
                btn.MouseButton1Click:Connect(function()
                    selected[itemId] = not selected[itemId]
                    local now = selected[itemId] == true
                    btn.Text = rowText(entry, now)
                    btn.TextColor3 = now and Color3.fromRGB(230, 230, 230) or Color3.fromRGB(140, 140, 140)
                    syncOutlines()
                end)
                btn.TextColor3 = on and Color3.fromRGB(230, 230, 230) or Color3.fromRGB(140, 140, 140)
            end
            end
        end

        if shown == 0 then
            make("TextLabel", {
                Size = UDim2.new(1, 0, 0, 18),
                BackgroundTransparency = 1,
                Font = Enum.Font.SourceSans,
                Text = if searchQuery ~= "" then "No matches" else "Nothing here",
                TextSize = 15,
                TextColor3 = Color3.fromRGB(110, 110, 110),
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = 1,
            }, listInner)
        end
        list.CanvasPosition = scroll
    end

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        searchQuery = string.lower(searchBox.Text)
        rebuildList()
    end)

    local function showPage(which)
        local plotOn = which == "plot"
        plotPage.Visible = plotOn
        settingsPage.Visible = not plotOn
        plotTab.Font = plotOn and Enum.Font.SourceSansBold or Enum.Font.SourceSans
        settingsTab.Font = plotOn and Enum.Font.SourceSans or Enum.Font.SourceSansBold
        plotTab.TextColor3 = plotOn and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(175, 175, 175)
        settingsTab.TextColor3 = plotOn and Color3.fromRGB(175, 175, 175) or Color3.fromRGB(255, 255, 255)
    end

    plotTab.MouseButton1Click:Connect(function()
        showPage("plot")
    end)
    settingsTab.MouseButton1Click:Connect(function()
        showPage("settings")
    end)

    local refreshBtn = make("TextButton", {
        Size = UDim2.new(1, 0, 0, 22),
        Position = UDim2.new(0, 0, 1, -92),
        BackgroundColor3 = Color3.fromRGB(58, 58, 58),
        BorderSizePixel = 0,
        Font = Enum.Font.SourceSans,
        Text = "Refresh plot",
        TextSize = 15,
        TextColor3 = Color3.fromRGB(230, 230, 230),
        AutoButtonColor = false,
    }, plotPage)

    local allBtn = make("TextButton", {
        Size = UDim2.new(0.5, -2, 0, 18),
        Position = UDim2.new(0, 0, 1, -66),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = "All",
        TextSize = 14,
        TextColor3 = Color3.fromRGB(210, 210, 210),
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
    }, plotPage)

    local clearBtn = make("TextButton", {
        Size = UDim2.new(0.5, -2, 0, 18),
        Position = UDim2.new(0.5, 2, 1, -66),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = "Clear",
        TextSize = 14,
        TextColor3 = Color3.fromRGB(210, 210, 210),
        TextXAlignment = Enum.TextXAlignment.Right,
        AutoButtonColor = false,
    }, plotPage)

    local runBtn = make("TextButton", {
        Size = UDim2.new(0.5, -2, 0, 22),
        Position = UDim2.new(0, 0, 1, -40),
        BackgroundColor3 = Color3.fromRGB(230, 230, 230),
        BorderSizePixel = 0,
        Font = Enum.Font.SourceSans,
        Text = "Run",
        TextSize = 15,
        TextColor3 = Color3.fromRGB(18, 18, 18),
        AutoButtonColor = false,
    }, plotPage)

    local stopBtn = make("TextButton", {
        Size = UDim2.new(0.5, -2, 0, 22),
        Position = UDim2.new(0.5, 2, 1, -40),
        BackgroundColor3 = Color3.fromRGB(58, 58, 58),
        BorderSizePixel = 0,
        Font = Enum.Font.SourceSans,
        Text = "Stop",
        TextSize = 15,
        TextColor3 = Color3.fromRGB(235, 235, 235),
        AutoButtonColor = false,
    }, plotPage)

    local statusLabel = make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 1, -14),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = "Idle",
        TextSize = 14,
        TextColor3 = Color3.fromRGB(120, 120, 120),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, plotPage)

    setStatus = function(text)
        if statusLabel and statusLabel.Parent then
            statusLabel.Text = text
        end
        if type(text) == "string" and string.sub(text, 1, 7) ~= "Moving " then
            log(text)
        end
    end

    local function refreshPlot()
        local ok, err = xpcall(function()
            refreshOwnedSnapshot()
            rebuildList()
            syncOutlines()
            setStatus("Idle")
        end, debug.traceback)
        if not ok then
            logError("Refresh failed", err)
            setStatus("Error")
        end
    end

    refreshBtn.MouseButton1Click:Connect(refreshPlot)

    allBtn.MouseButton1Click:Connect(function()
        for _, entry in ipairs(allItems) do
            if itemMatchesSearch(entry) then
                selected[entry.id] = true
            end
        end
        rebuildList()
        syncOutlines()
    end)

    clearBtn.MouseButton1Click:Connect(function()
        for _, entry in ipairs(allItems) do
            if itemMatchesSearch(entry) then
                selected[entry.id] = false
            end
        end
        rebuildList()
        syncOutlines()
    end)

    local function stopScript()
        abort = true
        stopRunTimer()
        setStatus("Stopped")
        if runBtn and runBtn.Parent then
            runBtn.Text = "Run"
        end
    end

    local function runOnce()
        if busy or isStopped() then
            return
        end
        busy = true
        abort = false
        runBtn.Text = "..."
        startRunTimer()
        log("Run")
        local ok, err = xpcall(RunPass, debug.traceback)
        stopRunTimer()
        parkAtHome()
        if isStopped() then
            setStatus("Stopped")
        elseif not ok then
            setStatus("Error")
            logError("Run failed", err)
        end
        busy = false
        if runBtn and runBtn.Parent then
            runBtn.Text = "Run"
        end
    end

    runBtn.MouseButton1Click:Connect(function()
        if busy or not started then
            if not started then
                setStatus("Stopped")
            end
            return
        end
        abort = false
        task.spawn(runOnce)
    end)

    stopBtn.MouseButton1Click:Connect(function()
        stopScript()
    end)

    local function refreshKeyButton()
        keyBtn.Text = toggleKey.Name
        if listeningForKey then
            keyBtn.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
            keyBtn.TextColor3 = Color3.fromRGB(18, 18, 18)
        else
            keyBtn.BackgroundColor3 = Color3.fromRGB(58, 58, 58)
            keyBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
        end
    end

    local function setCapturing(on)
        listeningForKey = on
        if ctx and ctx.setCapturing then
            ctx.setCapturing(on)
        end
        refreshKeyButton()
    end

    keyBtn.MouseButton1Click:Connect(function()
        setCapturing(not listeningForKey)
    end)

    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.Keyboard or not listeningForKey then
            return
        end
        if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Unknown then
            setCapturing(false)
            return
        end
        toggleKey = input.KeyCode
        setCapturing(false)
        if ctx and ctx.setToggleKey then
            ctx.setToggleKey(toggleKey)
        end
        saveConfig()
    end)

    teardownUi = function()
        if hoverConn then
            hoverConn:Disconnect()
            hoverConn = nil
        end
        if hoverHint then
            hoverHint:Destroy()
            hoverHint = nil
        end
        if root and root.Parent then
            root:Destroy()
        end
    end
    bindClickSelect = applyClickSelect
    stopActiveRun = stopScript

    refreshPlot()
end

local api = {}

function api.start(ctx)
    if type(ctx) == "table" then
        if ctx.window then
            dashWindow = ctx.window
        end
        if ctx.screenGui then
            screenGui = ctx.screenGui
        end
    end
    started = true
    abort = false
    bindClickSelect()
    if mounted then
        syncOutlines()
    end
end

function api.stop()
    started = false
    abort = true
    ContextActionService:UnbindAction(CLICK_SELECT_ACTION)
    stopActiveRun()
    local pending = {}
    for model in pairs(outlines) do
        table.insert(pending, model)
    end
    for _, model in ipairs(pending) do
        dropOutline(model)
    end
end

function api.mount(parent, ctx)
    if mounted then
        api.unmount()
    end
    buildInterface(parent, ctx)
    mounted = true
    if started then
        bindClickSelect()
        syncOutlines()
    end
end

function api.unmount()
    teardownUi()
    mounted = false
end

return api
