-- Автофарм San Diego для Xeno v45 (ИСПРАВЛЕННАЯ ВЕРСИЯ v67)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

local farming = false
local espFolder = nil
local contrabandAmount = 1

-- === КООРДИНАТЫ И МАРШРУТЫ ===
local exitCarPos         = Vector3.new(6848.5, 18.1, 29.7)
local contrabandPos      = Vector3.new(6807.6, 18.3, 23.2)
local carAfterContraband = Vector3.new(6848.5, 18.1, 29.7)
local buyerCarPos        = Vector3.new(-67.09, 50.18, 463.34)
local buyerExactPos      = Vector3.new(-69.88, 50.18, 442.83)
local moneyLaunderCarPos = Vector3.new(6850.26, 18.34, -21.64)
local moneyLaunderNPC    = Vector3.new(6808.89, 18.37, -36.05)

local stopPos            = Vector3.new(-139.16, 18.15, 481.49)

local noCollisionZones = {
    {pos = Vector3.new(2301.27, 18.15, 110.07), radius = 100},
    {pos = Vector3.new(-67.09, 50.18, 463.34), radius = 60},
}

local roadToStop = {
    Vector3.new(6848.5, 18.15, 29.7),
    Vector3.new(6856.00, 18.15, 98.42),
    Vector3.new(5500, 18.15, 100), Vector3.new(4000, 18.15, 102),
    Vector3.new(2833.06, 18.17, 104.08), Vector3.new(2936.15, 18.15, 103.31),
    Vector3.new(2500, 18.15, 103), Vector3.new(2301.27, 18.15, 110.07),
    Vector3.new(2000, 18.15, 103), Vector3.new(1000, 18.15, 103),
    Vector3.new(300, 18.15, 103),
    Vector3.new(-123.74, 18.15, 130.26),
    Vector3.new(-139.16, 18.15, 481.49),
}

local roadFromStopToLaunder = {
    Vector3.new(-139.16, 18.15, 481.49),
    Vector3.new(-123.74, 18.15, 130.26),
    Vector3.new(300, 18.15, 103),
    Vector3.new(1000, 18.15, 103), Vector3.new(2000, 18.15, 103),
    Vector3.new(2301.27, 18.15, 110.07), Vector3.new(2500, 18.15, 103),
    Vector3.new(2936.15, 18.15, 103.31), Vector3.new(2833.06, 18.17, 104.08),
    Vector3.new(4000, 18.15, 102), Vector3.new(5500, 18.15, 100),
    Vector3.new(6856.00, 18.15, 98.42),
    Vector3.new(6850.26, 18.34, -21.64),
}

local roadWaypointsBack = {
    Vector3.new(6850.26, 18.34, -21.64), Vector3.new(6848.5, 18.1, 29.7),
}

-- === УТИЛИТЫ ===
local function lerp(a, b, t) return a + (b - a) * t end

local function generatePoints(p1, p2, count)
    local pts = {}
    for i = 1, count do
        local t = i / count
        pts[#pts + 1] = Vector3.new(lerp(p1.X, p2.X, t), lerp(p1.Y, p2.Y, t), lerp(p1.Z, p2.Z, t))
    end
    return pts
end

local function generateRouteFromWaypoints(waypoints, pointsPerSegment)
    local route = {}
    for i = 1, #waypoints - 1 do
        local p1, p2 = waypoints[i], waypoints[i + 1]
        local dist = (p2 - p1).Magnitude
        local count = math.max(pointsPerSegment, math.floor(dist / 30))
        for _, p in ipairs(generatePoints(p1, p2, count)) do
            route[#route + 1] = p
        end
    end
    return route
end

local driveToStop = generateRouteFromWaypoints(roadToStop, 5)
local driveFromStopToLaunder = generateRouteFromWaypoints(roadFromStopToLaunder, 5)
local driveBack = generateRouteFromWaypoints(roadWaypointsBack, 5)

-- === ESP ===
local espPoints = {}
for _, p in ipairs(generatePoints(exitCarPos, contrabandPos, 6)) do espPoints[#espPoints + 1] = p end
for _, p in ipairs(generatePoints(contrabandPos, carAfterContraband, 6)) do espPoints[#espPoints + 1] = p end
for _, p in ipairs(driveToStop) do espPoints[#espPoints + 1] = p end
espPoints[#espPoints + 1] = stopPos
espPoints[#espPoints + 1] = buyerExactPos
for _, p in ipairs(driveFromStopToLaunder) do espPoints[#espPoints + 1] = p end
for _, p in ipairs(generatePoints(moneyLaunderCarPos, moneyLaunderNPC, 4)) do espPoints[#espPoints + 1] = p end
for _, p in ipairs(generatePoints(moneyLaunderNPC, moneyLaunderCarPos, 4)) do espPoints[#espPoints + 1] = p end
for _, p in ipairs(driveBack) do espPoints[#espPoints + 1] = p end

local function createESP()
    if espFolder then espFolder:Destroy() end
    espFolder = Instance.new("Folder")
    espFolder.Name = "FarmRouteESP"
    espFolder.Parent = Workspace
    for i = 1, #espPoints - 1 do
        local p1, p2 = espPoints[i], espPoints[i + 1]
        local dist = (p2 - p1).Magnitude
        if dist > 0.5 then
            local line = Instance.new("Part")
            line.Anchored = true; line.CanCollide = false; line.CanQuery = false
            line.Material = Enum.Material.Neon; line.Color = Color3.fromRGB(0, 255, 100)
            line.Transparency = 0.3; line.Size = Vector3.new(0.5, 0.5, dist)
            line.CFrame = CFrame.new((p1 + p2) / 2, p2)
            line.Parent = espFolder
        end
    end
    local keyPoints = {
        {pos = exitCarPos, color = Color3.fromRGB(255, 255, 0)},
        {pos = contrabandPos, color = Color3.fromRGB(255, 100, 100)},
        {pos = stopPos, color = Color3.fromRGB(255, 165, 0)},
        {pos = buyerExactPos, color = Color3.fromRGB(100, 255, 100)},
        {pos = moneyLaunderNPC, color = Color3.fromRGB(100, 100, 255)},
    }
    for _, zone in ipairs(noCollisionZones) do table.insert(keyPoints, {pos = zone.pos, color = Color3.fromRGB(255, 165, 0)}) end
    for _, kp in ipairs(keyPoints) do
        local marker = Instance.new("Part")
        marker.Anchored = true; marker.CanCollide = false; marker.CanQuery = false
        marker.Material = Enum.Material.Neon; marker.Color = kp.color
        marker.Transparency = 0.2; marker.Size = Vector3.new(4, 4, 4)
        marker.CFrame = CFrame.new(kp.pos); marker.Shape = Enum.PartType.Ball
        marker.Parent = espFolder
    end
end

local function removeESP()
    if espFolder then espFolder:Destroy(); espFolder = nil end
end

-- === УПРАВЛЕНИЕ ВВОДОМ ===
local hexCodes = { E = 0x45, F = 0x46, Space = 0x20 }
local function rawPress(code) pcall(function() if keypress then keypress(code) end end) end
local function rawRelease(code) pcall(function() if keyrelease then keyrelease(code) end end) end
local function pressKey(letter, holdTime) rawPress(hexCodes[letter]) task.wait(holdTime or 0.1) rawRelease(hexCodes[letter]) end

-- === УТИЛИТЫ ПЕРСОНАЖА ===
local function getChar()
    local char = player.Character
    if not char then return nil, nil, nil end
    return char, char:FindFirstChild("HumanoidRootPart"), char:FindFirstChildOfClass("Humanoid")
end

local cachedSeat = nil
local function isInCar()
    local _, _, hum = getChar()
    if not hum then return false end
    if hum.SeatPart then cachedSeat = hum.SeatPart; return true end
    if cachedSeat and cachedSeat.Parent and cachedSeat.Occupant == hum then return true end
    return false
end

local function getCurrentSeat()
    local _, _, hum = getChar()
    if not hum then return nil end
    if hum.SeatPart then cachedSeat = hum.SeatPart; return hum.SeatPart end
    if cachedSeat and cachedSeat.Parent and cachedSeat.Occupant == hum then return cachedSeat end
    return nil
end

local function findNearestCar()
    local _, hrp = getChar()
    if not hrp then return nil end
    local closest, closestDist
    local vehicles = Workspace:FindFirstChild("Vehicles")
    local folders = vehicles and {vehicles} or {Workspace}
    for _, folder in ipairs(folders) do
        for _, v in ipairs(folder:GetDescendants()) do
            if v:IsA("VehicleSeat") and v.Occupant == nil then
                local dist = (v.Position - hrp.Position).Magnitude
                if not closestDist or dist < closestDist then
                    closest, closestDist = v, dist
                end
            end
        end
    end
    return closest
end

local function getCarModel()
    local seat = getCurrentSeat()
    if not seat or not seat.Parent then return nil, nil end
    local car = seat.Parent
    while car and car ~= Workspace do
        if car:IsA("Model") then break end
        car = car.Parent
    end
    if not car or car == Workspace then car = seat.Parent end
    local carPart = car:FindFirstChild("DriveSeat") or car:FindFirstChild("HumanoidRootPart") or car:FindFirstChild("Body") or car:FindFirstChild("Chassis") or car.PrimaryPart or seat
    return car, carPart
end

local function stopCar()
    local _, carPart = getCarModel()
    if carPart then
        pcall(function()
            carPart.AssemblyLinearVelocity = Vector3.new(0, carPart.AssemblyLinearVelocity.Y, 0)
            carPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end)
    end
    local seat = getCurrentSeat()
    if seat then pcall(function() seat.Throttle = 0; seat.Steer = 0 end) end
end

-- === КОЛЛИЗИЯ ===
local originalCollisions = {}
local cachedParts = {}
local collisionEnforcerActive = false

local function getAllParts(model)
    local parts = {}
    if not model then return parts end
    for _, item in ipairs(model:GetDescendants()) do
        if item:IsA("BasePart") then
            parts[#parts + 1] = item
        end
    end
    return parts
end

local function disableCollisionNow()
    cachedParts = {}
    local car, _ = getCarModel()
    if car then
        local parts = getAllParts(car)
        for _, part in ipairs(parts) do
            if originalCollisions[part] == nil then
                originalCollisions[part] = part.CanCollide
            end
            part.CanCollide = false
            cachedParts[#cachedParts + 1] = part
        end
    end
    local char = getChar()
    if char then
        local parts = getAllParts(char)
        for _, part in ipairs(parts) do
            if originalCollisions[part] == nil then
                originalCollisions[part] = part.CanCollide
            end
            part.CanCollide = false
            cachedParts[#cachedParts + 1] = part
        end
    end
end

local function reDisableCollision()
    for _, part in ipairs(cachedParts) do
        if part and part.Parent then
            part.CanCollide = false
        end
    end
end

local function enableAllCollision()
    for part, orig in pairs(originalCollisions) do
        if part and part.Parent then
            part.CanCollide = orig
        end
    end
    originalCollisions = {}
    cachedParts = {}
end

local function startCollisionEnforcer()
    collisionEnforcerActive = true
    disableCollisionNow()
    task.spawn(function()
        local rescanTimer = 0
        while farming and collisionEnforcerActive do
            rescanTimer = rescanTimer + 1
            if rescanTimer >= 16 then
                disableCollisionNow()
                rescanTimer = 0
            else
                reDisableCollision()
            end
            task.wait(0.03)
        end
        collisionEnforcerActive = false
    end)
end

local function stopCollisionEnforcer()
    collisionEnforcerActive = false
    enableAllCollision()
end

-- === ХОДЬБА И ВОЖДЕНИЕ ===
local function walkTo(targetPos, timeout)
    timeout = timeout or 30
    local startTime = tick()
    local dt = 0.03
    local speed = 16
    while tick() - startTime < timeout and farming do
        local char, hrp, hum = getChar()
        if not char or not hrp then break end
        local flatPos = Vector3.new(hrp.Position.X, 0, hrp.Position.Z)
        local flatTarget = Vector3.new(targetPos.X, 0, targetPos.Z)
        local dist = (flatPos - flatTarget).Magnitude
        if dist < 3 then break end
        local dir = (flatTarget - flatPos).Unit
        local step = speed * dt
        if step > dist then step = dist end
        local newPos = hrp.Position + Vector3.new(dir.X * step, 0, dir.Z * step)
        local lookAt = Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z)
        pcall(function() char:PivotTo(CFrame.new(newPos, lookAt)) end)
        if hum then pcall(function() hum:MoveTo(targetPos) end) end
        task.wait(dt)
    end
end

local function teleportTo(pos)
    local char, hrp = getChar()
    if not char or not hrp then return false end
    for attempt = 1, 3 do
        pcall(function() char:PivotTo(CFrame.new(pos)) end)
        task.wait(0.4)
        char, hrp = getChar()
        if char and hrp then
            local dist = (hrp.Position - pos).Magnitude
            if dist < 10 then
                print("[Автофарм] Телепорт успешен (попытка " .. attempt .. ")")
                return true
            end
        end
    end
    char, hrp = getChar()
    if char then
        pcall(function() char:PivotTo(CFrame.new(pos)) end)
    end
    task.wait(0.5)
    print("[Автофарм] Телепорт выполнен (без подтверждения)")
    return true
end

local function driveThroughPoints(points, timeoutPerPoint, noCollision)
    timeoutPerPoint = timeoutPerPoint or 30
    if not isInCar() then print("[Автофарм] Не в машине!") return end
    stopCar()
    task.wait(0.3)

    local dt = 0.03
    local maxSpeed = 100
    local boostSpeed = 110
    local boostDuration = 1.5
    local minSpeed = 15
    local arriveDist = 12
    local brakeDist = 60

    for i, targetPos in ipairs(points) do
        if not farming then break end
        local startTime = tick()
        local stuckTime = 0
        local lastPos = nil
        local stuckCount = 0
        local pointStartTime = tick()
        local boostActive = true

        while tick() - startTime < timeoutPerPoint and farming do
            local car, carPart = getCarModel()
            if not car or not carPart then break end
            local carPos = carPart.Position
            local flatPos = Vector3.new(carPos.X, 0, carPos.Z)
            local flatTarget = Vector3.new(targetPos.X, 0, targetPos.Z)
            local flatDist = (flatPos - flatTarget).Magnitude
            if flatDist < arriveDist then break end

            reDisableCollision()

            if lastPos then
                local moved = (carPos - lastPos).Magnitude
                if moved < 0.2 then stuckTime = stuckTime + dt else stuckTime = 0 end
            end
            lastPos = carPos

            local toTarget = (flatTarget - flatPos)
            if toTarget.Magnitude < 0.1 then break end
            toTarget = toTarget.Unit

            local speed = maxSpeed
            local timeSincePointStart = tick() - pointStartTime
            if boostActive and timeSincePointStart < boostDuration then
                speed = boostSpeed
            else
                boostActive = false
                if flatDist < brakeDist then
                    local t = math.clamp((flatDist - arriveDist) / (brakeDist - arriveDist), 0, 1)
                    speed = minSpeed + (maxSpeed - minSpeed) * t
                else
                    speed = maxSpeed
                end
            end

            local yDiff = targetPos.Y - carPos.Y
            local yVel = carPart.AssemblyLinearVelocity.Y
            if yDiff > 2 then yVel = math.clamp(yDiff * 2, 5, 30) end

            local lookVec = carPart.CFrame.LookVector
            lookVec = Vector3.new(lookVec.X, 0, lookVec.Z)
            if lookVec.Magnitude < 0.1 then lookVec = Vector3.new(0, 0, -1) end
            lookVec = lookVec.Unit
            local dot = lookVec:Dot(toTarget)
            local cross = lookVec:Cross(toTarget)
            local angleDiff = math.atan2(cross.Y, dot)

            if stuckTime > 1.2 then
                stuckCount = stuckCount + 1
                if stuckCount > 5 then print("[Автофарм] Точка " .. i .. " пропущена"); break end

                disableCollisionNow()

                pcall(function()
                    carPart.CFrame = carPart.CFrame + Vector3.new(0, 3, 0)
                    carPart.AssemblyLinearVelocity = Vector3.new(toTarget.X * 120, 10, toTarget.Z * 120)
                end)

                task.wait(0.4)
                stuckTime = 0; lastPos = nil
                pointStartTime = tick()
                boostActive = true
            elseif dot < -0.5 then
                pcall(function()
                    carPart.AssemblyLinearVelocity = Vector3.new(0, yVel, 0)
                    carPart.AssemblyAngularVelocity = Vector3.new(0, angleDiff > 0 and 4 or -4, 0)
                end)
            else
                local targetVelX = toTarget.X * speed
                local targetVelZ = toTarget.Z * speed
                local currentVel = carPart.AssemblyLinearVelocity
                local smoothFactor = 0.5
                local newVelX = currentVel.X + (targetVelX - currentVel.X) * smoothFactor
                local newVelZ = currentVel.Z + (targetVelZ - currentVel.Z) * smoothFactor
                pcall(function() carPart.AssemblyLinearVelocity = Vector3.new(newVelX, yVel, newVelZ) end)
                local turnSpeed = math.clamp(angleDiff * 4, -4, 4)
                pcall(function() carPart.AssemblyAngularVelocity = Vector3.new(0, turnSpeed, 0) end)
            end
            task.wait(dt)
        end
    end

    stopCar()
    task.wait(0.3)
end

local function enterCar()
    local char, hrp, hum = getChar()
    if not hrp or not hum then return false end
    if isInCar() then return true end
    local seat = findNearestCar()
    if not seat then print("[Автофарм] Машина не найдена!") return false end

    walkTo(seat.Position, 15)
    task.wait(0.5)
    if isInCar() then stopCar() return true end

    if seat.Occupant == nil then seat:Sit(hum) end
    task.wait(1.5)
    if isInCar() then stopCar() return true end

    if not isInCar() then pressKey("F", 0.5) task.wait(1.5) end
    if isInCar() then stopCar() return true end

    print("[Автофарм] Телепорт на сиденье (запасной вариант)")
    pcall(function() char:PivotTo(CFrame.new(seat.Position + Vector3.new(0, 3, 0))) end)
    task.wait(0.5)
    if seat.Occupant == nil then seat:Sit(hum) end
    task.wait(1.5)
    if not isInCar() then pressKey("F", 0.5) task.wait(1.5) end

    cachedSeat = getCurrentSeat()
    stopCar()
    return isInCar()
end

local function exitCar()
    local _, _, hum = getChar()
    if not hum then return false end
    if not isInCar() then return true end
    stopCar()
    if cachedSeat and cachedSeat.Parent and cachedSeat.Occupant == hum then pcall(function() cachedSeat:Sit(nil) end) end
    task.wait(1)
    if isInCar() then pressKey("F", 0.5) task.wait(1) end
    if isInCar() and cachedSeat and cachedSeat.Parent then pcall(function() cachedSeat:Sit(nil) end) task.wait(1) end
    cachedSeat = nil
    task.wait(2)
    return not isInCar()
end

local function findProximityPromptsNear(pos, maxDist)
    local prompts = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local parent = obj:FindFirstAncestorOfClass("BasePart") or obj:FindFirstAncestorOfClass("Model")
            if parent then
                local pPos = parent:GetPivot().Position
                local dist = (pPos - pos).Magnitude
                if dist < (maxDist or 20) then
                    table.insert(prompts, {prompt = obj, dist = dist})
                end
            end
        end
    end
    table.sort(prompts, function(a, b) return a.dist < b.dist end)
    return prompts
end

local function findClickDetectorsNear(pos, maxDist)
    local detectors = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ClickDetector") then
            local parent = obj:FindFirstAncestorOfClass("BasePart") or obj:FindFirstAncestorOfClass("Model")
            if parent then
                local pPos = parent:GetPivot().Position
                local dist = (pPos - pos).Magnitude
                if dist < (maxDist or 20) then
                    table.insert(detectors, {detector = obj, dist = dist})
                end
            end
        end
    end
    table.sort(detectors, function(a, b) return a.dist < b.dist end)
    return detectors
end

-- ИСПРАВЛЕНО v67: задержка между покупками 2 секунды (было 3)
local function interactNPC(pos, duration, repeats)
    duration = duration or 6
    repeats = repeats or 1
    local char, hrp = getChar()
    if not hrp then return end

    local currentDist = (hrp.Position - pos).Magnitude
    if currentDist > 5 then
        walkTo(pos, 15)
        task.wait(0.3)
    end

    teleportTo(pos)
    task.wait(0.5)

    for r = 1, repeats do
        if not farming then break end
        print("[Автофарм] === Покупка " .. r .. "/" .. repeats .. " ===")

        local prompts = findProximityPromptsNear(pos, 30)
        local detectors = findClickDetectorsNear(pos, 30)
        print("[Автофарм] Найдено промптов: " .. #prompts .. ", клик-детекторов: " .. #detectors)

        for _, p in ipairs(prompts) do
            pcall(function() fireproximityprompt(p.prompt) end)
            print("[Автофарм] fireproximityprompt -> " .. tostring(p.prompt))
            task.wait(0.1)
        end

        for _, d in ipairs(detectors) do
            pcall(function() fireclickdetector(d.detector) end)
            print("[Автофарм] fireclickdetector -> " .. tostring(d.detector))
            task.wait(0.1)
        end

        task.wait(0.5)
        pressKey("E", 0.1)
        task.wait(0.3)
        pressKey("E", 0.1)

        pcall(function()
            local VIM = game:GetService("VirtualInputManager")
            VIM:SendKeyEvent(true, Enum.KeyCode.E, false, nil)
            task.wait(0.1)
            VIM:SendKeyEvent(false, Enum.KeyCode.E, false, nil)
            print("[Автофарм] VirtualInputManager E отправлен")
        end)

        pcall(function()
            if mouse1click then mouse1click() print("[Автофарм] mouse1click") end
        end)

        -- ИСПРАВЛЕНО v67: задержка 2 секунды (было 3)
        task.wait(2)

        if r < repeats then
            char, hrp = getChar()
            if hrp and farming then
                print("[Автофарм] Возврат на точку для следующей покупки...")
                teleportTo(pos)
                task.wait(0.5)
            end
        end
    end
end

-- === ГЛАВНЫЙ ЦИКЛ ===
local function farmLoop()
    while farming do
        local ok, err = pcall(function()
            if isInCar() then driveThroughPoints({exitCarPos}, 90, true) task.wait(1) end
            exitCar() task.wait(1)

            print("[Автофарм] Телепортация к контрабанде...")
            teleportTo(contrabandPos)
            task.wait(0.5)

            interactNPC(contrabandPos, 3, contrabandAmount)

            task.wait(1)
            print("[Автофарм] Телепортация обратно к машине...")
            teleportTo(carAfterContraband)
            task.wait(1)

            enterCar() task.wait(1)
            stopCar() task.wait(0.5)

            if not isInCar() then
                print("[Автофарм] Не удалось сесть! Повтор...")
                teleportTo(carAfterContraband)
                task.wait(1)
                enterCar() task.wait(1)
                stopCar() task.wait(0.5)
            end

            if not isInCar() then
                print("[Автофарм] Пропуск цикла — не в машине")
                task.wait(3)
                return
            end

            print("[Автофарм] Едем к точке остановки перед скупщиком...")
            driveThroughPoints(driveToStop, 30, true) task.wait(1)

            -- ИСПРАВЛЕНО v67: пауза после выхода из машины 2.5 сек (было 1)
            exitCar() task.wait(2.5)

            print("[Автофарм] Телепорт к скупщику...")
            teleportTo(buyerExactPos)
            task.wait(0.5)

            interactNPC(buyerExactPos, 3, 1) task.wait(1)

            print("[Автофарм] Возврат к машине...")
            teleportTo(stopPos) task.wait(1)
            enterCar() task.wait(1)
            stopCar() task.wait(0.5)

            if not isInCar() then
                teleportTo(stopPos) task.wait(1)
                enterCar() task.wait(1)
                stopCar() task.wait(0.5)
            end

            if not isInCar() then print("[Автофарм] Пропуск цикла"); task.wait(3) return end

            print("[Автофарм] Едем к отмыву...")
            driveThroughPoints(driveFromStopToLaunder, 30, true) task.wait(1)

            -- ИСПРАВЛЕНО v67: пауза после выхода из машины 2.5 сек (было 1)
            exitCar() task.wait(2.5)

            interactNPC(moneyLaunderNPC, 3, 1) task.wait(1)
            teleportTo(moneyLaunderCarPos) task.wait(1)
            enterCar() task.wait(1)
            stopCar() task.wait(0.5)

            if not isInCar() then
                teleportTo(moneyLaunderCarPos) task.wait(1)
                enterCar() task.wait(1)
                stopCar() task.wait(0.5)
            end

            if not isInCar() then print("[Автофарм] Пропуск цикла"); task.wait(3) return end

            driveThroughPoints(driveBack, 30, true) task.wait(1)
        end)
        if not ok then
            print("[Автофарм] ОШИБКА: " .. tostring(err))
            stopCar()
            task.wait(3)
        end
    end
    stopCollisionEnforcer()
end

-- === GUI ===
local function createGUI()
    local playerGui = player:WaitForChild("PlayerGui", 10)
    if not playerGui then
        warn("[Автофарм] ОШИБКА: Не удалось найти PlayerGui в течение 10 секунд!")
        return false
    end

    local oldGui = playerGui:FindFirstChild("SanDiegoFarm")
    if oldGui then oldGui:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SanDiegoFarm"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 220, 0, 145)
    frame.Position = UDim2.new(0.1, 0, 0.25, 0)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(0, 10)
    fc.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -40, 0, 30)
    title.Position = UDim2.new(0, 10, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = "San Diego AutoFarm v67"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -28, 0, 8)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 12
    closeBtn.Parent = frame

    local cc = Instance.new("UICorner")
    cc.CornerRadius = UDim.new(0, 6)
    cc.Parent = closeBtn

    local amountLabel = Instance.new("TextLabel")
    amountLabel.Size = UDim2.new(0, 120, 0, 20)
    amountLabel.Position = UDim2.new(0, 10, 0, 35)
    amountLabel.BackgroundTransparency = 1
    amountLabel.Text = "Контрабанды:"
    amountLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    amountLabel.Font = Enum.Font.Gotham
    amountLabel.TextSize = 12
    amountLabel.TextXAlignment = Enum.TextXAlignment.Left
    amountLabel.Parent = frame

    local amountValue = Instance.new("TextLabel")
    amountValue.Size = UDim2.new(0, 30, 0, 20)
    amountValue.Position = UDim2.new(0, 95, 0, 35)
    amountValue.BackgroundTransparency = 1
    amountValue.Text = tostring(contrabandAmount)
    amountValue.TextColor3 = Color3.fromRGB(100, 255, 100)
    amountValue.Font = Enum.Font.GothamBold
    amountValue.TextSize = 14
    amountValue.TextXAlignment = Enum.TextXAlignment.Left
    amountValue.Parent = frame

    local minusBtn = Instance.new("TextButton")
    minusBtn.Size = UDim2.new(0, 24, 0, 24)
    minusBtn.Position = UDim2.new(0, 125, 0, 33)
    minusBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    minusBtn.Text = "-"
    minusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minusBtn.Font = Enum.Font.GothamBold
    minusBtn.TextSize = 14
    minusBtn.Parent = frame

    local mc = Instance.new("UICorner")
    mc.CornerRadius = UDim.new(0, 6)
    mc.Parent = minusBtn

    local plusBtn = Instance.new("TextButton")
    plusBtn.Size = UDim2.new(0, 24, 0, 24)
    plusBtn.Position = UDim2.new(0, 155, 0, 33)
    plusBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    plusBtn.Text = "+"
    plusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    plusBtn.Font = Enum.Font.GothamBold
    plusBtn.TextSize = 14
    plusBtn.Parent = frame

    local pc = Instance.new("UICorner")
    pc.CornerRadius = UDim.new(0, 6)
    pc.Parent = plusBtn

    minusBtn.MouseButton1Click:Connect(function()
        if contrabandAmount > 1 then
            contrabandAmount = contrabandAmount - 1
            amountValue.Text = tostring(contrabandAmount)
        end
    end)

    plusBtn.MouseButton1Click:Connect(function()
        if contrabandAmount < 10 then
            contrabandAmount = contrabandAmount + 1
            amountValue.Text = tostring(contrabandAmount)
        end
    end)

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -20, 0, 25)
    statusLabel.Position = UDim2.new(0, 10, 0, 65)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Статус: ОСТАНОВЛЕН"
    statusLabel.TextColor3 = Color3.fromRGB(200, 100, 100)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 13
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = frame

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, -20, 0, 35)
    toggleBtn.Position = UDim2.new(0, 10, 0, 95)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 160, 80)
    toggleBtn.Text = "НАЧАТЬ ФАРМ"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 14
    toggleBtn.Parent = frame

    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(0, 8)
    tc.Parent = toggleBtn

    local dragging = false
    local dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.RightShift then frame.Visible = not frame.Visible end
    end)

    toggleBtn.MouseButton1Click:Connect(function()
        if not farming then
            farming = true
            createESP()
            pcall(startCollisionEnforcer)
            statusLabel.Text = "Статус: РАБОТАЕТ"
            statusLabel.TextColor3 = Color3.fromRGB(100, 220, 100)
            toggleBtn.Text = "ОСТАНОВИТЬ"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
            task.spawn(farmLoop)
        else
            farming = false
            stopCar()
            stopCollisionEnforcer()
            statusLabel.Text = "Статус: ОСТАНОВЛЕН"
            statusLabel.TextColor3 = Color3.fromRGB(200, 100, 100)
            toggleBtn.Text = "НАЧАТЬ ФАРМ"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 160, 80)
        end
    end)

    closeBtn.MouseButton1Click:Connect(function()
        farming = false
        stopCar()
        stopCollisionEnforcer()
        removeESP()
        screenGui:Destroy()
    end)

    print("[Автофарм] GUI успешно создан!")
    return true
end

local guiOk = pcall(createGUI)
if not guiOk then
    warn("[Автофарм] КРИТИЧЕСКАЯ ОШИБКА: Не удалось создать GUI.")
else
    print("[Автофарм] Загружен v67. Нажми НАЧАТЬ ФАРМ")
end
