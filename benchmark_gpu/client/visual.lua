Visual = {}

local spawnedObjects  = {}
local spawnedVehicles = {}

-- Météo avec reset complet entre phases 
-- Cycle forcé EXTRASUNNY → target pour vider les flaques/traces au sol

function Visual.SetWeather(targetWeather)
    -- Forcer un ciel pur pour effacer l'état précédent (flaques, boue, givre)
    SetWeatherTypeNowPersist('EXTRASUNNY')
    SetWeatherTypeNow('EXTRASUNNY')
    Wait(600)
    -- Appliquer la météo cible
    SetWeatherTypePersist(targetWeather)
    SetWeatherTypeNow(targetWeather)
    SetWeatherTypeNowPersist(targetWeather)
end

function Visual.ClearWeather()
    SetWeatherTypeNowPersist('EXTRASUNNY')
    SetWeatherTypeNow('EXTRASUNNY')
    ClearOverrideWeather()
    ClearWeatherTypePersist()
end

-- ── Nettoyage complet de la zone (feu, fumée, particules) ─────────────────

function Visual.CleanArea(center, radius)
    -- Supprime toutes les particules dans le rayon
    RemoveParticleFxInRange(center.x, center.y, center.z, radius or 80.0)
    -- Éteint les feux proches (natifs GTA)
    StopFireInRange(center.x, center.y, center.z, radius or 80.0)
end

-- ── Props stress ──────────────────────────────────────────────────────────

function Visual.SpawnObjects(basePos)
    Visual.CleanupObjects()
    for _, o in ipairs(Config.stressObjects) do
        local model = GetHashKey(o.model)
        RequestModel(model)
        local t = 0
        while not HasModelLoaded(model) and t < 25 do Wait(100); t = t + 1 end
        if HasModelLoaded(model) then
            local obj = CreateObject(model,
                basePos.x + o.ox, basePos.y + o.oy, basePos.z,
                false, false, false)
            if obj ~= 0 then table.insert(spawnedObjects, obj) end
            SetModelAsNoLongerNeeded(model)
        end
    end
end

function Visual.CleanupObjects()
    for _, obj in ipairs(spawnedObjects) do
        if DoesEntityExist(obj) then DeleteObject(obj) end
    end
    spawnedObjects = {}
end

-- ── Explosions normales ───────────────────────────────────────────────────

function Visual.SpawnExplosions(positions)
    Citizen.CreateThread(function()
        Wait(3500)
        for _, pos in ipairs(positions) do
            AddExplosion(pos.x, pos.y, pos.z, 7, 0.0, true, false, 1.0)
            Wait(300)
        end
        Wait(1200)
        for _, pos in ipairs(positions) do
            AddExplosion(pos.x, pos.y, pos.z, 2, 0.0, true, false, 0.6)
            Wait(180)
        end
    end)
end

-- ── MEGA STRESS TEST ──────────────────────────────────────────────────────

function Visual.MegaStressTest(center)
    Citizen.CreateThread(function()
        local vehList = Config.megaVehicles
        local idx     = 1
        local cols    = 5
        local spacing = 6.0

        -- Grille 5x5 au sol
        for row = 0, 4 do
            for col = 0, 4 do
                if idx > #vehList then idx = 1 end
                local model = GetHashKey(vehList[idx])
                idx = idx + 1
                RequestModel(model)
                local t = 0
                while not HasModelLoaded(model) and t < 12 do Wait(60); t = t + 1 end
                if HasModelLoaded(model) then
                    local ox  = (col - cols/2) * spacing
                    local oy  = (row - cols/2) * spacing
                    local veh = CreateVehicle(model,
                        center.x + ox, center.y + oy, center.z,
                        math.random(0, 359), false, false)
                    if veh ~= 0 then table.insert(spawnedVehicles, veh) end
                    SetModelAsNoLongerNeeded(model)
                end
                Wait(50)
            end
        end

        -- 2e vague : tombent du ciel
        for i, name in ipairs(vehList) do
            local model = GetHashKey(name)
            RequestModel(model)
            local t = 0
            while not HasModelLoaded(model) and t < 10 do Wait(50); t = t + 1 end
            if HasModelLoaded(model) then
                local angle  = (i / #vehList) * math.pi * 2
                local radius = 8.0 + (i % 4) * 4.0
                local veh    = CreateVehicle(model,
                    center.x + math.cos(angle)*radius,
                    center.y + math.sin(angle)*radius,
                    center.z + 12.0 + (i % 3)*5.0,
                    math.random(0, 359), false, false)
                if veh ~= 0 then table.insert(spawnedVehicles, veh) end
                SetModelAsNoLongerNeeded(model)
            end
            Wait(80)
        end

        Wait(1500)

        -- 6 vagues d'explosions
        local types = {7, 5, 14, 2, 7, 5}
        for _, etype in ipairs(types) do
            for _ = 1, 10 do
                local angle = math.random() * math.pi * 2
                local r     = math.random(2, 22)
                AddExplosion(
                    center.x + math.cos(angle)*r,
                    center.y + math.sin(angle)*r,
                    center.z, etype, 0.0, true, false, 2.0)
                Wait(100)
            end
            Wait(500)
        end

        -- Grille finale 7x7
        Wait(400)
        for x = -3, 3 do
            for y = -3, 3 do
                AddExplosion(
                    center.x + x*5.5, center.y + y*5.5, center.z,
                    7, 0.0, true, false, 3.0)
                Wait(40)
            end
        end

        Wait(2500)
        Visual.CleanupVehicles()
    end)
end

function Visual.CleanupVehicles()
    for _, v in ipairs(spawnedVehicles) do
        if DoesEntityExist(v) then DeleteVehicle(v) end
    end
    spawnedVehicles = {}
end
