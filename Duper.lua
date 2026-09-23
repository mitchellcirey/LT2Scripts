local Services = setmetatable({}, {
    __index = function(self, index)
        return game:GetService(index)
    end,
})

local Players           = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local Workspace         = Services.Workspace
local UserInputService  = Services.UserInputService

local Player            = Players.LocalPlayer
local ClientIsDragging  = ReplicatedStorage:WaitForChild("Interaction"):WaitForChild("ClientIsDragging")

local HOLD_BEFORE_RELEASE = 0.2
local PLACE_RETRIES = 3
local ARRIVE_SLOP = 8
local POST_OBJECT_DELAY = 0.04
local PILE_POST_DELAY = 0.04
local GUI_NAME = "LT2DuperUI"
local PLOT_INSET = 3
local PLOT_MIN = 25
local PLOT_MAX = 2000
local LOG_GAP = 2
local MIN_LOG_SPACING = 6
local PLANK_GAP = 0.85

local selected = {}
local keyIndex = {}
local allItems = {}

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
    return mn >= PLOT_MIN and mx <= PLOT_MAX
end

local function colorClose(a, b)
    local dr, dg, db = a.R - b.R, a.G - b.G, a.B - b.B
    return (dr * dr + dg * dg + db * db) < 0.04
end

local function looksLikeGrass(part)
    if not part:IsA("BasePart") then
        return false
    end
    if part.Material == Enum.Material.Grass then
        return true
    end
    local c = part.Color
    return c.G > c.R + 0.07 and c.G > c.B + 0.05
end

local function samePlotSurface(seed, part)
    if not (seed and part and part:IsA("BasePart")) then
        return false
    end
    if part == seed then
        return true
    end
    if not isLandPart(part) then
        return false
    end
    if looksLikeGrass(part) and not looksLikeGrass(seed) then
        return false
    end
    if seed.Material ~= part.Material and not colorClose(seed.Color, part.Color) then
        return false
    end
    return colorClose(seed.Color, part.Color)
end

local function partAabbXZ(part)
    local cf = part.CFrame
    local sx, sz = part.Size.X * 0.5, part.Size.Z * 0.5
    local minX, maxX = math.huge, -math.huge
    local minZ, maxZ = math.huge, -math.huge
    for _, ox in ipairs({ -sx, sx }) do
        for _, oz in ipairs({ -sz, sz }) do
            local w = cf:PointToWorldSpace(Vector3.new(ox, 0, oz))
            minX = math.min(minX, w.X)
            maxX = math.max(maxX, w.X)
            minZ = math.min(minZ, w.Z)
            maxZ = math.max(maxZ, w.Z)
        end
    end
    return minX, maxX, minZ, maxZ
end

local function aabbTouches(aMinX, aMaxX, aMinZ, aMaxZ, bMinX, bMaxX, bMinZ, bMaxZ, slop)
    return aMinX <= bMaxX + slop
        and aMaxX >= bMinX - slop
        and aMinZ <= bMaxZ + slop
        and aMaxZ >= bMinZ - slop
end

local function plotFromParts(parts, fromPos)
    if not parts or #parts == 0 then
        return nil
    end
    local minX, maxX = math.huge, -math.huge
    local minZ, maxZ = math.huge, -math.huge
    for _, part in ipairs(parts) do
        local x0, x1, z0, z1 = partAabbXZ(part)
        minX = math.min(minX, x0)
        maxX = math.max(maxX, x1)
        minZ = math.min(minZ, z0)
        maxZ = math.max(maxZ, z1)
    end
    return {
        cf = CFrame.new((minX + maxX) * 0.5, fromPos.Y, (minZ + maxZ) * 0.5),
        size = Vector3.new(math.max(1, maxX - minX), 20, math.max(1, maxZ - minZ)),
        part = parts[1],
        parts = parts,
        seed = parts[1],
    }
end

local function asPlot(part, fromPos)
    return plotFromParts({ part }, fromPos or part.Position)
end

local function partContainsXZ(part, pos, inset)
    inset = inset or 0
    local lp = part.CFrame:PointToObjectSpace(pos)
    local hx = math.max(0, part.Size.X * 0.5 - inset)
    local hz = math.max(0, part.Size.Z * 0.5 - inset)
    return math.abs(lp.X) <= hx and math.abs(lp.Z) <= hz
end

local function collectLandCandidates(seed)
    local seedY = seed.Position.Y
    local candidates = {}
    local seen = {}
    local playerModels = Workspace:FindFirstChild("PlayerModels")

    local function take(part)
        if part and part:IsA("BasePart") and not seen[part] and samePlotSurface(seed, part) then
            if math.abs(part.Position.Y - seedY) <= 24 then
                seen[part] = true
                table.insert(candidates, part)
            end
        end
    end

    local function addContainer(container, descendants)
        if not container then
            return
        end
        if container:IsA("BasePart") then
            take(container)
        end
        if descendants then
            for _, p in ipairs(container:GetDescendants()) do
                if p:IsA("BasePart") then
                    take(p)
                end
            end
        else
            for _, child in ipairs(container:GetChildren()) do
                if child:IsA("BasePart") then
                    take(child)
                end
            end
        end
    end

    take(seed)
    if seed.Parent and seed.Parent ~= Workspace then
        addContainer(seed.Parent, true)
    end
    addContainer(Workspace, false)

    for _, child in ipairs(Workspace:GetChildren()) do
        if child ~= playerModels then
            local owner = child:FindFirstChild("Owner")
            if owner and owner:IsA("ObjectValue") and owner.Value == Player then
                addContainer(child, true)
            end
        end
    end

    return candidates
end

local function connectedLandParts(seed)
    if not (seed and seed:IsA("BasePart")) then
        return {}
    end

    local cluster = { seed }
    local seen = { [seed] = true }
    local minX, maxX, minZ, maxZ = partAabbXZ(seed)
    local y = seed.Position.Y

    local overlapOk, nearby = pcall(function()
        local params = OverlapParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        local ignore = {}
        if Player.Character then
            table.insert(ignore, Player.Character)
        end
        local playerModels = Workspace:FindFirstChild("PlayerModels")
        if playerModels then
            table.insert(ignore, playerModels)
        end
        params.FilterDescendantsInstances = ignore
        local size = Vector3.new(math.max(40, maxX - minX) + 80, 40, math.max(40, maxZ - minZ) + 80)
        return Workspace:GetPartBoundsInBox(CFrame.new((minX + maxX) * 0.5, y, (minZ + maxZ) * 0.5), size, params)
    end)

    if overlapOk and nearby then
        for _, part in ipairs(nearby) do
            if not seen[part] and samePlotSurface(seed, part) and math.abs(part.Position.Y - y) <= 24 then
                local x0, x1, z0, z1 = partAabbXZ(part)
                if aabbTouches(minX, maxX, minZ, maxZ, x0, x1, z0, z1, 20) then
                    seen[part] = true
                    table.insert(cluster, part)
                    minX, maxX = math.min(minX, x0), math.max(maxX, x1)
                    minZ, maxZ = math.min(minZ, z0), math.max(maxZ, z1)
                    if #cluster >= 32 then
                        break
                    end
                end
            end
        end
        if #cluster > 1 then
            return cluster
        end
    end

    local candidates = collectLandCandidates(seed)
    local aabbs = {}
    for _, part in ipairs(candidates) do
        local x0, x1, z0, z1 = partAabbXZ(part)
        aabbs[part] = { x0, x1, z0, z1 }
    end

    local stack = { seed }
    cluster = {}
    seen = { [seed] = true }
    while #stack > 0 and #cluster < 32 do
        local cur = table.remove(stack)
        table.insert(cluster, cur)
        local a = aabbs[cur]
        if a then
            for _, other in ipairs(candidates) do
                if not seen[other] then
                    local b = aabbs[other]
                    if b and aabbTouches(a[1], a[2], a[3], a[4], b[1], b[2], b[3], b[4], 16) then
                        seen[other] = true
                        table.insert(stack, other)
                    end
                end
            end
        end
    end
    return cluster
end

local function considerPlotPart(part, fromPos, best, bestArea)
    if not isLandPart(part) or not partContainsXZ(part, fromPos, -8) then
        return best, bestArea
    end
    local area = part.Size.X * part.Size.Z
    if not best or area > bestArea then
        return part, area
    end
    return best, bestArea
end

local function plotFromModel(model, fromPos)
    if not model then
        return nil
    end
    local parts = {}
    local function take(part)
        if isLandPart(part) then
            table.insert(parts, part)
        end
    end
    if model:IsA("BasePart") then
        take(model)
    end
    for _, p in ipairs(model:GetDescendants()) do
        if p:IsA("BasePart") then
            take(p)
        end
    end
    if #parts > 0 then
        local origin = fromPos
        if not origin then
            origin = parts[1].Position
        end
        return plotFromParts(parts, origin)
    end
    if model:IsA("Model") then
        local cf, size = model:GetBoundingBox()
        if math.min(size.X, size.Z) >= 40 and math.max(size.X, size.Z) <= PLOT_MAX then
            return { cf = cf, size = size, part = model }
        end
    end
    return nil
end

local function raycastFloor(fromPos)
    local ignore = {}
    if Player.Character then
        table.insert(ignore, Player.Character)
    end
    local playerModels = Workspace:FindFirstChild("PlayerModels")
    if playerModels then
        table.insert(ignore, playerModels)
    end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = ignore
    return Workspace:Raycast(fromPos + Vector3.new(0, 8, 0), Vector3.new(0, -200, 0), params)
end

local function plotFromOwnedItems(fromPos)
    local models = Workspace:FindFirstChild("PlayerModels")
    if not models then
        return nil
    end

    local minX, maxX = fromPos.X, fromPos.X
    local minZ, maxZ = fromPos.Z, fromPos.Z
    local found = false

    for _, v in ipairs(models:GetChildren()) do
        local owner = v:FindFirstChild("Owner")
        if owner and owner.Value == Player then
            local part = v:FindFirstChild("Main") or v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
            if part then
                found = true
                minX = math.min(minX, part.Position.X)
                maxX = math.max(maxX, part.Position.X)
                minZ = math.min(minZ, part.Position.Z)
                maxZ = math.max(maxZ, part.Position.Z)
            end
        end
    end

    if not found then
        return nil
    end

    local pad = 20
    local sizeX = math.clamp(maxX - minX + pad * 2, 50, PLOT_MAX)
    local sizeZ = math.clamp(maxZ - minZ + pad * 2, 50, PLOT_MAX)
    return {
        cf = CFrame.new((minX + maxX) * 0.5, fromPos.Y, (minZ + maxZ) * 0.5),
        size = Vector3.new(sizeX, 20, sizeZ),
    }
end

local function getPlotArea(fromPos)
    local playerModels = Workspace:FindFirstChild("PlayerModels")
    local hit = raycastFloor(fromPos)
    local floor = hit and hit.Instance

    local function expand(seed)
        if not (seed and seed:IsA("BasePart")) then
            return nil
        end
        local cluster = connectedLandParts(seed)
        if #cluster == 0 then
            cluster = { seed }
        end
        return plotFromParts(cluster, fromPos)
    end

    if floor and floor:IsA("BasePart") then
        local expanded = expand(floor)
        if expanded and math.min(expanded.size.X, expanded.size.Z) >= 20 then
            return expanded
        end
    end

    local best
    local bestArea = 0
    local inst = floor
    while inst and inst ~= Workspace do
        if inst:IsA("BasePart") then
            best, bestArea = considerPlotPart(inst, fromPos, best, bestArea)
        end
        inst = inst.Parent
    end
    if best then
        return expand(best) or asPlot(best, fromPos)
    end

    for _, child in ipairs(Workspace:GetChildren()) do
        if child ~= playerModels then
            local owner = child:FindFirstChild("Owner")
            if owner and owner:IsA("ObjectValue") and owner.Value == Player then
                local owned = plotFromModel(child, fromPos)
                if owned then
                    return owned
                end
            end
        end
    end

    best, bestArea = nil, 0
    for _, child in ipairs(Workspace:GetChildren()) do
        if child ~= playerModels and child:IsA("BasePart") then
            best, bestArea = considerPlotPart(child, fromPos, best, bestArea)
        end
    end
    if best then
        return expand(best) or asPlot(best, fromPos)
    end

    local fromItems = plotFromOwnedItems(fromPos)
    if fromItems then
        return fromItems
    end

    if floor and floor:IsA("BasePart") then
        return expand(floor) or asPlot(floor, fromPos)
    end

    return nil
end

local function plotInset(spacing)
    return math.max(6, (spacing or MIN_LOG_SPACING) * 0.5 + 2)
end

local function plotHalf(plot, spacing)
    local inset = plotInset(spacing)
    return math.max(0, plot.size.X * 0.5 - inset), math.max(0, plot.size.Z * 0.5 - inset)
end

local function positionOnPlotParts(pos, plot, spacing)
    if not (plot and plot.parts) then
        return false
    end
    local inset = plotInset(spacing)
    for _, part in ipairs(plot.parts) do
        if partContainsXZ(part, pos, inset) then
            return true
        end
    end
    return false
end

local function insidePlot(pos, plot, spacing)
    if not plot then
        return false
    end
    local inset = plotInset(spacing)

    if plot.parts and #plot.parts > 0 then
        if not positionOnPlotParts(pos, plot, spacing) then
            return false
        end
        local probeY = plot.parts[1].Position.Y + 4
        local hit = raycastFloor(Vector3.new(pos.X, probeY, pos.Z))
        local inst = hit and hit.Instance
        if inst then
            for _, part in ipairs(plot.parts) do
                if inst == part then
                    return true
                end
            end
            if plot.seed and samePlotSurface(plot.seed, inst) then
                return partContainsXZ(inst, pos, inset)
            end
            if plot.seed and looksLikeGrass(inst) and not looksLikeGrass(plot.seed) then
                return false
            end
        end
        return true
    end

    local overPart = false
    if plot.part and plot.part:IsA("BasePart") then
        overPart = partContainsXZ(plot.part, pos, inset)
    else
        local hx, hz = plotHalf(plot, spacing)
        local localPos = plot.cf:PointToObjectSpace(pos)
        overPart = math.abs(localPos.X) <= hx and math.abs(localPos.Z) <= hz
    end
    if not overPart then
        return false
    end

    local hit = raycastFloor(pos)
    local inst = hit and hit.Instance
    if not inst then
        return overPart
    end
    if plot.part and inst == plot.part then
        return true
    end
    if plot.seed and samePlotSurface(plot.seed, inst) then
        return partContainsXZ(inst, pos, inset)
    end
    if plot.seed and looksLikeGrass(inst) and not looksLikeGrass(plot.seed) then
        return false
    end
    return overPart
end

local function clampToPlot(pos, plot, spacing)
    if not plot then
        return pos
    end
    if insidePlot(pos, plot, spacing) then
        return pos
    end
    local hx, hz = plotHalf(plot, spacing)
    local localPos = plot.cf:PointToObjectSpace(pos)
    local clamped = Vector3.new(
        math.clamp(localPos.X, -hx, hx),
        localPos.Y,
        math.clamp(localPos.Z, -hz, hz)
    )
    local world = plot.cf:PointToWorldSpace(clamped)
    return Vector3.new(world.X, pos.Y, world.Z)
end

local function snapOntoPlot(pos, plot, spacing)
    if insidePlot(pos, plot, spacing) then
        return pos
    end

    local clamped = clampToPlot(pos, plot, spacing)
    if insidePlot(clamped, plot, spacing) then
        return clamped
    end

    if plot and plot.parts then
        local inset = plotInset(spacing)
        local best, bestDist
        for _, part in ipairs(plot.parts) do
            if part and part.Parent then
                local lp = part.CFrame:PointToObjectSpace(pos)
                local hx = math.max(0, part.Size.X * 0.5 - inset)
                local hz = math.max(0, part.Size.Z * 0.5 - inset)
                local localClamped = Vector3.new(math.clamp(lp.X, -hx, hx), 0, math.clamp(lp.Z, -hz, hz))
                local world = part.CFrame:PointToWorldSpace(localClamped)
                local candidate = Vector3.new(world.X, pos.Y, world.Z)
                local dist = (Vector3.new(candidate.X, 0, candidate.Z) - Vector3.new(pos.X, 0, pos.Z)).Magnitude
                if not best or dist < bestDist then
                    best = candidate
                    bestDist = dist
                end
            end
        end
        if best then
            return best
        end
    end

    return clamped
end

local function standingFootprint(part)
    local dims = { part.Size.X, part.Size.Y, part.Size.Z }
    table.sort(dims)
    return math.max(dims[1], dims[2])
end

local function dragTarget(model)
    return model:FindFirstChild("Main")
        or model:FindFirstChild("WoodSection")
        or model:FindFirstChildWhichIsA("BasePart")
        or model:FindFirstChildWhichIsA("BasePart", true)
end

local function isPlank(model)
    return model and model.Name == "Plank"
end

local function plankStandYaw(plot)
    local yaw = 0
    if plot and plot.cf then
        local _, y = plot.cf:ToEulerAnglesYXZ()
        yaw = y
    end
    return yaw + math.rad(90)
end

local function logSpacingFor(models)
    local planksOnly = #models > 0
    for _, model in ipairs(models) do
        if not isPlank(model) then
            planksOnly = false
            break
        end
    end

    local spacing = if planksOnly then 0 else MIN_LOG_SPACING
    local gap = if planksOnly then PLANK_GAP else LOG_GAP
    for _, model in ipairs(models) do
        local target = dragTarget(model)
        if target then
            local footprint = if planksOnly
                then math.max(target.Size.X, target.Size.Z)
                else standingFootprint(target)
            spacing = math.max(spacing, footprint + gap)
        end
    end
    if spacing <= 0 then
        spacing = if planksOnly then 2 else MIN_LOG_SPACING
    end
    return spacing
end

local function buildLogSlots(pressedCF, count, plot, spacing)
    local slots = {}
    if count <= 0 then
        return slots
    end
    spacing = math.max(spacing or MIN_LOG_SPACING, 1)
    if not plot then
        return slots
    end

    local hx, hz = plotHalf(plot, spacing)
    local nCol = math.max(1, math.floor((2 * hx) / spacing) + 1)
    local nRow = math.max(1, math.floor((2 * hz) / spacing) + 1)
    nCol = math.min(nCol, 60)
    nRow = math.min(nRow, 60)
    while nCol > 1 and ((nCol - 1) * spacing) * 0.5 > hx + 0.01 do
        nCol -= 1
    end
    while nRow > 1 and ((nRow - 1) * spacing) * 0.5 > hz + 0.01 do
        nRow -= 1
    end

    local x0 = -((nCol - 1) * spacing) * 0.5
    local z0 = -((nRow - 1) * spacing) * 0.5
    local candidates = {}
    for col = 0, nCol - 1 do
        for row = 0, nRow - 1 do
            local localPos = Vector3.new(x0 + col * spacing, 0, z0 + row * spacing)
            local world = plot.cf:PointToWorldSpace(localPos)
            local pos = Vector3.new(world.X, pressedCF.Position.Y, world.Z)
            if insidePlot(pos, plot, spacing) then
                table.insert(candidates, pos)
            end
        end
    end

    local px, pz = pressedCF.Position.X, pressedCF.Position.Z
    table.sort(candidates, function(a, b)
        local da = (a.X - px) * (a.X - px) + (a.Z - pz) * (a.Z - pz)
        local db = (b.X - px) * (b.X - px) + (b.Z - pz) * (b.Z - pz)
        return da < db
    end)

    for _, pos in ipairs(candidates) do
        table.insert(slots, pos)
        if #slots >= count then
            break
        end
    end

    return slots
end

local function fallbackDest(pressedCF, plot)
    if plot and plot.cf then
        return Vector3.new(plot.cf.Position.X, pressedCF.Position.Y, plot.cf.Position.Z)
    end
    return (pressedCF * CFrame.new(0, 0, 4)).Position
end

local activePlot
local activeSpacing = MIN_LOG_SPACING

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

        local yaw = 0
        if isPlank(model) then
            yaw = plankStandYaw(activePlot)
        elseif pressedCF then
            _, yaw = pressedCF:ToEulerAnglesYXZ()
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
    pcall(function()
        ClientIsDragging:FireServer(nil)
    end)
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
        if type(sethiddenproperty) ~= "function" then
            return
        end
        sethiddenproperty(Player, "MaximumSimulationRadius", 1000)
        sethiddenproperty(Player, "SimulationRadius", 1000)
    end)
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
    destPos = snapOntoPlot(destPos, activePlot, activeSpacing)
    local standUp = not pile

    if arrivedAt(v, target, destPos) then
        return true
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
            task.wait(0.08)
            if arrivedAt(v, target, destPos) then
                if not isStopped() then
                    task.wait(if pile then PILE_POST_DELAY else POST_OBJECT_DELAY)
                end
                return true
            end
        else
            releaseDrag()
        end
    end

    releaseDrag()
    return false
end

local function objectMatch(v)
    local tree = v:FindFirstChild("TreeClass")
    if tree then
        return "log", tree.Value
    end

    local box = v:FindFirstChild("PurchasedBoxItemName")
    if box then
        return "boxed", box.Value
    end

    local tool = v:FindFirstChild("ToolName")
    if tool then
        return "opened", tool.Value
    end

    local itemName = v:FindFirstChild("ItemName")
    if itemName then
        return "opened", itemName.Value
    end

    return nil
end

local cachedOwnedGroups = {}
local plotReady = false

local function ownsModel(model)
    local owner = model:FindFirstChild("Owner")
    if not owner then
        return false
    end
    local value = owner.Value
    if value == Player or value == Player.Name then
        return true
    end
    if typeof(value) == "Instance" then
        return value == Player or value.Name == Player.Name
    end
    return false
end

local function modelOnPlot(model, plot)
    local part = dragTarget(model)
    return part ~= nil and insidePlot(part.Position, plot, MIN_LOG_SPACING)
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

    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local plot = hrp and getPlotArea(hrp.Position)
    plotReady = plot ~= nil

    local counts = {}
    local unique = {}
    local models = Workspace:FindFirstChild("PlayerModels")
    if plot and models then
        for _, model in ipairs(models:GetChildren()) do
            if ownsModel(model) and modelOnPlot(model, plot) then
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
            end
        end
    end

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
    return plotReady
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

local function shouldGrid(model)
    return model:FindFirstChild("TreeClass") ~= nil
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
    widenSimulation()
    activePlot = getPlotArea(pressedCF.Position)
    if not activePlot then
        setStatus("Stand on your plot")
        return
    end

    local models = Workspace:FindFirstChild("PlayerModels")
    if not models then
        setStatus("No matching items")
        return
    end

    local matches = {}
    for _, v in ipairs(models:GetChildren()) do
        if ownsModel(v) and modelOnPlot(v, activePlot) then
            local ok, label = objectIsSelected(v)
            if ok and dragTarget(v) then
                table.insert(matches, {
                    model = v,
                    label = label,
                    isLog = shouldGrid(v),
                })
            end
        end
    end

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

    local logModels = {}
    for _, job in ipairs(pending) do
        if job.isLog then
            table.insert(logModels, job.model)
        end
    end
    local spacing = logSpacingFor(logModels)
    activeSpacing = spacing
    local logSlots = buildLogSlots(pressedCF, #logModels, activePlot, spacing)

    local logI = 1
    local pileI = 1
    local moved = 0

    for index, job in ipairs(pending) do
        if isStopped() then
            releaseDrag()
            setStatus("Stopped")
            return
        end
        local dest
        local pile = false
        if job.isLog then
            dest = logSlots[logI] or fallbackDest(pressedCF, activePlot)
            logI += 1
        else
            dest = (pressedCF * CFrame.new(0, 0.08 * (pileI - 1), 3)).Position
            pile = true
            pileI += 1
        end
        dest = snapOntoPlot(dest, activePlot, activeSpacing)
        setStatus(("Moving %s (%d/%d)"):format(job.label, index, #pending))
        local placed = MoveObject(job.model, pressedCF, index, pile, dest)
        if placed == nil or isStopped() then
            releaseDrag()
            setStatus("Stopped")
            return
        end
        if placed then
            cycleDone[job.model] = true
            moved += 1
        end
    end

    releaseDrag()

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
    end

    window = make("Frame", {
        Name = "Window",
        Size = UDim2.fromOffset(280, 420),
        Position = windowPos,
        BackgroundColor3 = Color3.fromRGB(18, 18, 18),
        BorderSizePixel = 0,
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
        Size = UDim2.new(1, -36, 1, 0),
        Position = UDim2.fromOffset(10, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = "Duper",
        TextSize = 16,
        TextColor3 = Color3.fromRGB(230, 230, 230),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, titleBar)

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

    local list = make("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, -96),
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

            for _, entry in ipairs(group.items) do
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
                end)
                btn.TextColor3 = on and Color3.fromRGB(230, 230, 230) or Color3.fromRGB(140, 140, 140)
            end
        end

        if shown == 0 then
            make("TextLabel", {
                Size = UDim2.new(1, 0, 0, 18),
                BackgroundTransparency = 1,
                Font = Enum.Font.SourceSans,
                Text = "Nothing here",
                TextSize = 15,
                TextColor3 = Color3.fromRGB(110, 110, 110),
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = 1,
            }, listInner)
        end
        list.CanvasPosition = scroll
    end

    local function showPage(which)
        local plotOn = which == "plot"
        plotPage.Visible = plotOn
        settingsPage.Visible = not plotOn
        plotTab.Font = plotOn and Enum.Font.SourceSansBold or Enum.Font.SourceSans
        settingsTab.Font = plotOn and Enum.Font.SourceSans or Enum.Font.SourceSansBold
        plotTab.TextColor3 = plotOn and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(175, 175, 175)
        settingsTab.TextColor3 = plotOn and Color3.fromRGB(175, 175, 175) or Color3.fromRGB(255, 255, 255)
        titleLabel.Text = plotOn and "Duper" or "Settings"
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
        if not plotReady then
            setStatus("Stand on your plot")
        else
            setStatus("Idle")
        end
    end

    refreshBtn.MouseButton1Click:Connect(refreshPlot)

    allBtn.MouseButton1Click:Connect(function()
        for _, entry in ipairs(allItems) do
            selected[entry.id] = true
        end
        rebuildList()
    end)

    clearBtn.MouseButton1Click:Connect(function()
        for _, entry in ipairs(allItems) do
            selected[entry.id] = false
        end
        rebuildList()
    end)

    local function stopScript(closeUi)
        abort = true
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
        local ok, err = pcall(RunPass)
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
