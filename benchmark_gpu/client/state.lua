-- État global partagé entre tous les modules
BM = {
    active    = false,
    closing   = false,
    phaseIdx  = 0,
    fps       = 60,
    frameMs   = 0.0,
}

-- Thread mesure FPS (permanent)
Citizen.CreateThread(function()
    local last = GetGameTimer()
    while true do
        Citizen.Wait(0)
        local now = GetGameTimer()
        local dt  = now - last
        last = now
        if dt > 0 then
            BM.fps     = math.min(math.floor(1000.0 / dt), 300)
            BM.frameMs = math.floor(dt * 10) / 10
        end
    end
end)

-- Thread densité trafic + heure (actif uniquement pendant le benchmark)
Citizen.CreateThread(function()
    while true do
        if BM.active and BM.phaseIdx > 0 then
            Citizen.Wait(0)
            local p = Config.phases[BM.phaseIdx]
            if p then
                SetPedDensityMultiplierThisFrame(p.pedDensity)
                SetVehicleDensityMultiplierThisFrame(p.vehicleDensity)
                SetRandomVehicleDensityMultiplierThisFrame(p.vehicleDensity)
                SetParkedVehicleDensityMultiplierThisFrame(p.vehicleDensity)
                SetClockTime(p.hour, 0, 0)
            end
        else
            Citizen.Wait(500)
        end
    end
end)
