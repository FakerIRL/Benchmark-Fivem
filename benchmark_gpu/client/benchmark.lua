Benchmark = {}

local fpsCurve = {}

local function collectFPS(duration, phaseIndex, phaseLabel)
    local samples = {}
    local start   = GetGameTimer()
    while GetGameTimer() - start < duration do
        local fps = BM.fps
        table.insert(samples, fps)
        table.insert(fpsCurve, { p = phaseLabel, v = fps })
        HUD.UpdateProgress(
            ((phaseIndex - 1) + (GetGameTimer() - start) / duration)
            / #Config.phases * 100)
        Wait(200)
    end
    return samples
end

local function calcPhaseStats(samples)
    local sum, minFPS = 0, 999
    for _, v in ipairs(samples) do
        sum = sum + v
        if v < minFPS then minFPS = v end
    end
    return
        #samples > 0 and math.floor(sum / #samples) or 0,
        minFPS == 999 and 0 or minFPS
end

local function calcScore(avgFPS)
    local score = math.min(100, math.floor((avgFPS / 100) * 100))
    local rating, recommendation
    if     avgFPS >= Config.scoreThresholds.ultra  then rating='ULTRA';  recommendation='Ultra'
    elseif avgFPS >= Config.scoreThresholds.high   then rating='HIGH';   recommendation='Haute'
    elseif avgFPS >= Config.scoreThresholds.medium then rating='MEDIUM'; recommendation='Moyenne'
    else                                                rating='LOW';    recommendation='Basse'
    end
    return score, rating, recommendation
end

function Benchmark.Run()
    BM.active   = true
    BM.closing  = false
    BM.phaseIdx = 0
    fpsCurve    = {}

    local ped   = PlayerPedId()
    local origC = GetEntityCoords(ped)
    local origH = GetEntityHeading(ped)

    -- Instance privée (routing bucket 200)
    TriggerServerEvent('benchmark_gpu:enterInstance')
    FreezeEntityPosition(ped, true)
    SetEntityVisible(ped, false, false)
    DisplayHud(false)
    DisplayRadar(false)
    SetNuiFocus(false, false)

    HUD.Show(#Config.phases)

    local history = {}

    for i, phase in ipairs(Config.phases) do
        BM.phaseIdx = i

        if phase.isMegaStress then HUD.ShowCountdown() end

        DoScreenFadeOut(Config.fadeDuration)
        Wait(Config.fadeDuration + 150)

        -- ── Reset de la zone précédente ──────────────────────────────────
        Camera.Destroy()
        Visual.CleanupObjects()
        Visual.CleanupVehicles()
        -- Nettoyer feu/fumée de l'ancienne position
        local prevPhase = Config.phases[i - 1]
        if prevPhase then
            Visual.CleanArea(prevPhase.cam1.pos, 100.0)
        end

        -- Téléportation + reset météo complet (efface les flaques ou essaye de les faire disparaître)
        SetEntityCoords(ped, phase.cam1.pos.x, phase.cam1.pos.y, phase.cam1.pos.z, false, false, false, false)
        Visual.SetWeather(phase.weather)   -- reset EXTRASUNNY → target
        Wait(350)

        if phase.spawnObjects then Visual.SpawnObjects(phase.cam1.pos) end

        Camera.Create(phase.cam1, phase.cam2)
        Camera.Activate()
        HUD.PhaseStart(i, phase.label, (i - 1) / #Config.phases * 100)

        DoScreenFadeIn(Config.fadeDuration)
        Wait(Config.fadeDuration + 150)

        local motionDur = phase.duration - Config.fadeDuration * 2 - 300
        Camera.StartMotion(motionDur)

        if phase.isMegaStress then
            Visual.MegaStressTest(phase.megaCenter)
        elseif phase.explosions then
            Visual.SpawnExplosions(phase.explosions)
        end

        local samples     = collectFPS(motionDur, i, phase.label)
        local avg, minFPS = calcPhaseStats(samples)

        local p = Config.phases[i]
        table.insert(history, {
            label      = phase.label,
            zone       = p.zone or '',
            conditions = p.conditions or '',
            avg        = avg,
            min        = minFPS,
        })
    end

    -- Score global
    local totalAvg, globalMin = 0, 999
    for _, d in ipairs(history) do
        totalAvg = totalAvg + d.avg
        if d.min < globalMin then globalMin = d.min end
    end
    totalAvg  = #history > 0 and math.floor(totalAvg / #history) or 0
    globalMin = globalMin == 999 and 0 or globalMin

    local score, rating, recommendation = calcScore(totalAvg)

    -- ── Restaurer + nettoyage global ─────────────────────────────────────
    DoScreenFadeOut(Config.fadeDuration)
    Wait(Config.fadeDuration + 150)

    Camera.Restore()
    Visual.CleanupObjects()
    Visual.CleanupVehicles()
    -- Nettoyer la dernière zone
    local lastPhase = Config.phases[#Config.phases]
    if lastPhase then Visual.CleanArea(lastPhase.cam1.pos, 150.0) end

    SetEntityCoords(ped, origC.x, origC.y, origC.z, false, false, false, false)
    SetEntityHeading(ped, origH)
    SetEntityVisible(ped, true, false)
    FreezeEntityPosition(ped, false)
    Visual.ClearWeather()

    -- Retour bucket 0 → plus de trace, le joueur est de retour dans le monde normal
    TriggerServerEvent('benchmark_gpu:leaveInstance')

    DoScreenFadeIn(Config.fadeDuration)
    Wait(Config.fadeDuration + 150)

    SetNuiFocus(true, true)
    HUD.ShowResults({
        score          = score,
        avgFPS         = totalAvg,
        minFPS         = globalMin,
        rating         = rating,
        recommendation = recommendation,
        phases         = history,
        curve          = fpsCurve,
    })

    while not BM.closing do Wait(200) end
    BM.active  = false
    BM.closing = false
end
