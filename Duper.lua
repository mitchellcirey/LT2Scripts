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

local Player            = Players.LocalPlayer
local ClientIsDragging  = ReplicatedStorage:WaitForChild("Interaction"):WaitForChild("ClientIsDragging")

local HOLD_BEFORE_RELEASE = 0.2
local PLACE_RETRIES = 3
local ARRIVE_SLOP = 2.5
local GUI_NAME = "LT2DuperUI"
local LOG_GAP = 2
local PLANK_GAP = 0.85
local GRAB_RANGE = 22
local OWNER_TIMEOUT = 1
local STEP_STUDS = 75
local STEP_HOLD = 0.16
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
local clickSelect = false
local outlineFolder
local outlines = {}
local outlineConns = {}
local outlineWatch

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
    return abort or not (screenGui and screenGui.Parent)
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

local function isPlank(model)
    return model and model.Name == "Plank"
end

local function itemSpacing(models)
    local spacing = 2
    for _, model in ipairs(models) do
        local target = dragTarget(model)
        if target then
            local footprint = if isPlank(model)
                then math.max(target.Size.X, target.Size.Z)
                else standingFootprint(target)
            local gap = if isPlank(model) then PLANK_GAP else LOG_GAP
            spacing = math.max(spacing, footprint + gap)
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

local function buildGridSlots(originCF, count, spacing, skip)
    local slots = {}
    if count <= 0 then
        return slots
    end
    spacing = math.max(spacing or 2, 1)
    skip = skip or 0
    local columns = math.max(1, math.ceil(math.sqrt(count + skip)))
    local index = 0
    local made = 0
    while made < count and index < 8000 do
        local col = index % columns
        local row = math.floor(index / columns)
        index += 1
        if skip > 0 then
            skip -= 1
        else
            local localPos = Vector3.new((col - (columns - 1) * 0.5) * spacing, 0, -(6 + row * spacing))
            table.insert(slots, originCF:PointToWorldSpace(localPos))
            made += 1
        end
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
        destPos = Vector3.new(destPos.X, gy + target.Size.Y * 0.5 + 0.15, destPos.Z)

        local yaw = flatYaw(pressedCF)
        if isPlank(model) then
            yaw += math.rad(90)
        end
        local desiredMain = CFrame.new(destPos) * CFrame.Angles(0, yaw, 0)
        local pivotOffset = target.CFrame:ToObjectSpace(model:GetPivot())
        model:PivotTo(desiredMain * pivotOffset)
    else
        model:PivotTo(model:GetPivot() + (destPos - target.Position))
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
    local guard = 0
    while guard < 40 do
        guard += 1
        if isStopped() then
            return false
        end
        local hrp = playerRoot()
        if not hrp then
            return false
        end
        local delta = goal - hrp.Position
        if delta.Magnitude <= 3 then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            hrp.CFrame = CFrame.new(goal)
            return true
        end
        local step = if delta.Magnitude > STEP_STUDS then delta.Unit * STEP_STUDS else delta
        local nextPos = hrp.Position + step
        local untilT = tick() + STEP_HOLD
        while tick() < untilT do
            if isStopped() then
                return false
            end
            hrp = playerRoot()
            if not hrp then
                return false
            end
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            hrp.CFrame = CFrame.new(nextPos)
            task.wait()
        end
    end
    return false
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
    if delta.Magnitude <= GRAB_RANGE then
        return true
    end
    local flat = Vector3.new(delta.X, 0, delta.Z)
    local dir = if flat.Magnitude > 0.1 then flat.Unit else Vector3.new(0, 0, -1)
    local stand = target.Position - dir * 8 + Vector3.new(0, 3, 0)
    if (hrp.Position - stand).Magnitude <= 3 then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = CFrame.new(stand)
        return true
    end
    return nudgeRoot(stand)
end

local function claimDrag(model, target)
    local deadline = tick() + OWNER_TIMEOUT
    while true do
        if isStopped() or not (model.Parent and target.Parent) then
            return nil
        end
        standNear(target)
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
        if tick() >= deadline then
            if owned == nil then
                local hrp = playerRoot()
                if hrp and (target.Position - hrp.Position).Magnitude <= GRAB_RANGE + 2 then
                    return true
                end
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

        if arrivedAt(v, target, destPos) and weOwn(target) ~= false then
            releaseDrag()
            task.wait()
            if arrivedAt(v, target, destPos) then
                return true
            end
        else
            releaseDrag()
        end
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
        return value == Player or value.Name == Player.Name
    end
    if type(value) == "string" then
        return string.lower(value) == string.lower(Player.Name)
    end
    if type(value) == "number" then
        return value == Player.UserId
    end
    return false
end

local function isOwnedLand(inst)
    if inst:IsA("BasePart") and isLandPart(inst) then
        return true
    end
    if not inst:IsA("Model") then
        return false
    end
    for _, part in ipairs(inst:GetDescendants()) do
        if part:IsA("BasePart") and isLandPart(part) then
            return true
        end
    end
    return false
end

local function forEachOwned(callback)
    local seen = {}
    local function ownedRoot(inst)
        local root = inst
        local parent = inst.Parent
        while parent and parent ~= Workspace do
            if parent.Name == "PlayerModels" then
                break
            end
            if ownsModel(parent) and not isOwnedLand(parent) then
                root = parent
            end
            parent = parent.Parent
        end
        return root
    end

    local function consider(inst)
        if not inst or seen[inst] or inst == Player or inst == Player.Character or inst == Workspace then
            return
        end
        if not ownsModel(inst) or isOwnedLand(inst) or not dragTarget(inst) then
            return
        end
        seen[inst] = true
        callback(inst)
    end

    local function scan(root)
        if not root then
            return
        end
        for _, desc in ipairs(root:GetDescendants()) do
            if desc.Name == "Owner" and desc.Parent then
                consider(ownedRoot(desc.Parent))
            end
        end
    end

    scan(Workspace)
end

local function ownedItemFromInstance(inst)
    local found = nil
    local current = inst
    while current and current ~= Workspace do
        if current.Name == "PlayerModels" then
            break
        end
        if ownsModel(current) and not isOwnedLand(current) and dragTarget(current) then
            found = current
        end
        current = current.Parent
    end
    return found
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

local function groupFor(kind)
    local name = string.lower(kind or "")
    if name == "log" then
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
    forEachOwned(function(model)
        local form, value = objectMatch(model)
        if form and value ~= nil and tostring(value) ~= "" then
            value = tostring(value)
            local id = form .. ":" .. value
            counts[id] = (counts[id] or 0) + 1
            if not unique[id] then
                unique[id] = {
                    id = id,
                    label = prettyName(value),
                    kind = kindFor(form, value),
                    form = form,
                    keys = { value },
                }
                selected[id] = keep[id] == true
                keyIndex[id] = unique[id]
                keyIndex[form .. ":" .. string.lower(value)] = unique[id]
                table.insert(allItems, unique[id])
            end
        end
    end)

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
    local form, value = objectMatch(model)
    if not form or value == nil or tostring(value) == "" then
        return false
    end
    value = tostring(value)
    local entry = keyIndex[form .. ":" .. value] or keyIndex[form .. ":" .. string.lower(value)]
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
    local form, value = objectMatch(model)
    if not form or value == nil or tostring(value) == "" then
        return nil
    end
    value = tostring(value)
    return {
        form = form,
        value = value,
        id = form .. ":" .. value,
    }
end

local function entryForMatch(match)
    if not match then
        return nil
    end
    return keyIndex[match.id] or keyIndex[match.form .. ":" .. string.lower(match.value)]
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
    return prettyName(match.value) .. " (" .. kindFor(match.form, match.value) .. ")"
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

local function shouldGrid(model)
    return model:FindFirstChild("TreeClass") ~= nil or model:FindFirstChild("TreeClass", true) ~= nil
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
        local size = boundsSize(model)
        local height = math.max(size.Y, 0.8)
        local width = math.max(size.X, size.Z, 1)
        if used > 0 and used + height > PILE_MAX_HEIGHT then
            x += columnWidth
            used = 0
            columnWidth = 0
        end
        columnWidth = math.max(columnWidth, width + PILE_GAP)
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
                isLog = shouldGrid(v),
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

    local placedModels = {}
    for _, job in ipairs(pending) do
        table.insert(placedModels, job.model)
    end
    local spacing = if pileItems then 2 else itemSpacing(placedModels)
    local gridSlots = buildGridSlots(originCF, if pileItems then 0 else #pending, spacing)
    local pileSlots = buildPileSlots(originCF, if pileItems then placedModels else {})

    local queue = {}
    local gridI = 1
    local pileI = 1
    for _, job in ipairs(pending) do
        local dest
        local pile = pileItems or not job.isLog
        if pileItems then
            dest = pileSlots[pileI]
            pileI += 1
        else
            dest = gridSlots[gridI]
            gridI += 1
            if not job.isLog and dest then
                local size = boundsSize(job.model)
                local ignore = { job.model }
                if Player.Character then
                    table.insert(ignore, Player.Character)
                end
                local gy = groundYAt(dest, ignore)
                dest = Vector3.new(dest.X, gy + size.Y * 0.5 + 0.2, dest.Z)
            end
        end
        if dest then
            table.insert(queue, {
                job = job,
                dest = dest,
                pile = pile,
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

local function buildInterface()
    local function getUiParent()
        local ok, hui = pcall(function()
            return gethui()
        end)
        if ok and hui then
            return hui
        end
        local coreOk, coreGui = pcall(function()
            return Services.CoreGui
        end)
        if coreOk and coreGui then
            return coreGui
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

    local uiParent = getUiParent()
    local existing = uiParent:FindFirstChild(GUI_NAME)
    if existing then
        existing:Destroy()
    end

    screenGui = make("ScreenGui", {
        Name = GUI_NAME,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999,
    }, uiParent)

    table.clear(outlines)
    for model, conn in pairs(outlineConns) do
        outlineConns[model] = nil
        conn:Disconnect()
    end
    outlineFolder = make("Folder", {
        Name = "Outlines",
    }, screenGui)

    if outlineWatch then
        outlineWatch:Disconnect()
        outlineWatch = nil
    end
    do
        local queued = false
        outlineWatch = Workspace.DescendantAdded:Connect(function(desc)
            if desc.Name ~= "Owner" or queued then
                return
            end
            queued = true
            task.delay(0.15, function()
                queued = false
                syncOutlines()
            end)
        end)
    end

    screenGui.Destroying:Connect(function()
        if outlineWatch then
            outlineWatch:Disconnect()
            outlineWatch = nil
        end
        ContextActionService:UnbindAction(CLICK_SELECT_ACTION)
        table.clear(outlines)
        for model, conn in pairs(outlineConns) do
            outlineConns[model] = nil
            conn:Disconnect()
        end
        outlineFolder = nil
    end)

    local toggleKey = Enum.KeyCode.T
    local listeningForKey = false
    local CONFIG_DIR = "LT2Scripts"
    local CONFIG_FILE = CONFIG_DIR .. "/settings.json"
    local window

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
        if type(writefile) ~= "function" or not (window and window.Parent) then
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
        local pos = window.Position
        local payload = {
            toggleKey = toggleKey.Name,
            selected = picked,
            position = {
                xScale = pos.X.Scale,
                xOffset = pos.X.Offset,
                yScale = pos.Y.Scale,
                yOffset = pos.Y.Offset,
            },
            amount = logLimit or "unlimited",
            pile = pileItems,
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
    local windowPos = UDim2.new(0, 16, 0.5, -180)
    if savedConfig then
        if type(savedConfig.toggleKey) == "string" then
            local keyOk, key = pcall(function()
                return Enum.KeyCode[savedConfig.toggleKey]
            end)
            if keyOk and key and key ~= Enum.KeyCode.Unknown then
                toggleKey = key
            end
        end
        local pos = savedConfig.position
        if type(pos) == "table"
            and type(pos.xScale) == "number"
            and type(pos.xOffset) == "number"
            and type(pos.yScale) == "number"
            and type(pos.yOffset) == "number"
        then
            windowPos = UDim2.new(pos.xScale, pos.xOffset, pos.yScale, pos.yOffset)
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
        if type(savedConfig.clickSelect) == "boolean" then
            clickSelect = savedConfig.clickSelect
        end
    end

    window = make("Frame", {
        Name = "Window",
        Size = UDim2.fromOffset(280, 420),
        Position = windowPos,
        BackgroundColor3 = Color3.fromRGB(18, 18, 18),
        BackgroundTransparency = 0.22,
        BorderSizePixel = 0,
        Active = true,
    }, screenGui)

    local titleBar = make("Frame", {
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
    }, window)

    make("Frame", {
        Size = UDim2.new(1, -16, 0, 1),
        Position = UDim2.new(0, 8, 1, -1),
        BackgroundColor3 = Color3.fromRGB(48, 48, 48),
        BorderSizePixel = 0,
    }, titleBar)

    local titleLabel = make("TextLabel", {
        Size = UDim2.fromOffset(98, 28),
        Position = UDim2.fromOffset(10, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = "Jell's Duper",
        TextSize = 16,
        TextColor3 = Color3.fromRGB(230, 230, 230),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, titleBar)

    local timerLabel = make("TextLabel", {
        Size = UDim2.fromOffset(48, 28),
        Position = UDim2.fromOffset(116, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = "0:00",
        TextSize = 16,
        TextColor3 = Color3.fromRGB(140, 140, 140),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, titleBar)

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

    local closeBtn = make("TextButton", {
        Size = UDim2.fromOffset(28, 28),
        Position = UDim2.new(1, -28, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = "x",
        TextSize = 16,
        TextColor3 = Color3.fromRGB(140, 140, 140),
        AutoButtonColor = false,
    }, titleBar)

    local plotTab = make("TextButton", {
        Size = UDim2.new(0.5, -1, 0, 22),
        Position = UDim2.fromOffset(0, 32),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSansBold,
        Text = "On Plot",
        TextSize = 15,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        AutoButtonColor = false,
    }, window)

    local settingsTab = make("TextButton", {
        Size = UDim2.new(0.5, -1, 0, 22),
        Position = UDim2.new(0.5, 1, 0, 32),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = "Settings",
        TextSize = 15,
        TextColor3 = Color3.fromRGB(175, 175, 175),
        AutoButtonColor = false,
    }, window)

    local plotPage = make("Frame", {
        Size = UDim2.new(1, -16, 1, -62),
        Position = UDim2.fromOffset(8, 58),
        BackgroundTransparency = 1,
    }, window)

    local settingsPage = make("Frame", {
        Size = UDim2.new(1, -16, 1, -62),
        Position = UDim2.fromOffset(8, 58),
        BackgroundTransparency = 1,
        Visible = false,
    }, window)

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
        Text = "Click select",
        TextSize = 14,
        TextColor3 = Color3.fromRGB(160, 160, 160),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, settingsPage)

    local clickBtn = make("TextButton", {
        Size = UDim2.fromOffset(120, 22),
        Position = UDim2.fromOffset(0, 176),
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

    local function updateHoverHint()
        if not (clickSelect and hoverHint and hoverHint.Parent) then
            return
        end
        local target = Player:GetMouse().Target
        local label = if target then labelForHit(target) else nil
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

    screenGui.Destroying:Connect(function()
        if hoverConn then
            hoverConn:Disconnect()
            hoverConn = nil
        end
    end)

    local function onClickSelect(_, state)
        if state ~= Enum.UserInputState.Begin or not clickSelect then
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
        clickBtn.Text = if clickSelect then "On" else "Off"
        ContextActionService:UnbindAction(CLICK_SELECT_ACTION)
        setHoverTracking(clickSelect)
        if not clickSelect then
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
        titleLabel.Text = plotOn and "Jell's Duper" or "Settings"
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
    end

    local function refreshPlot()
        refreshOwnedSnapshot()
        rebuildList()
        syncOutlines()
        setStatus("Idle")
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

    local function stopScript(closeUi)
        abort = true
        stopRunTimer()
        if closeUi then
            saveConfig()
            if screenGui then
                screenGui:Destroy()
            end
            return
        end
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
        local ok, err = pcall(RunPass)
        stopRunTimer()
        parkAtHome()
        if isStopped() then
            setStatus("Stopped")
        elseif not ok then
            setStatus("Error")
            warn("[LOT] " .. tostring(err))
        end
        busy = false
        if runBtn and runBtn.Parent then
            runBtn.Text = "Run"
        end
    end

    runBtn.MouseButton1Click:Connect(function()
        if busy then
            return
        end
        if isStopped() then
            abort = false
        end
        task.spawn(runOnce)
    end)

    stopBtn.MouseButton1Click:Connect(function()
        stopScript(false)
    end)

    closeBtn.MouseButton1Click:Connect(function()
        stopScript(true)
    end)

    local function refreshKeyButton()
        if listeningForKey then
            keyBtn.Text = "Press a key"
            keyBtn.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
            keyBtn.TextColor3 = Color3.fromRGB(18, 18, 18)
        else
            keyBtn.Text = toggleKey.Name
            keyBtn.BackgroundColor3 = Color3.fromRGB(58, 58, 58)
            keyBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
        end
    end

    keyBtn.MouseButton1Click:Connect(function()
        listeningForKey = not listeningForKey
        refreshKeyButton()
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.UserInputType ~= Enum.UserInputType.Keyboard then
            return
        end
        if listeningForKey then
            if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Unknown then
                listeningForKey = false
                refreshKeyButton()
                return
            end
            toggleKey = input.KeyCode
            listeningForKey = false
            refreshKeyButton()
            saveConfig()
            return
        end
        if gameProcessed or UserInputService:GetFocusedTextBox() then
            return
        end
        if input.KeyCode == toggleKey and window and window.Parent then
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
                saveConfig()
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

    refreshPlot()
end

buildInterface()
