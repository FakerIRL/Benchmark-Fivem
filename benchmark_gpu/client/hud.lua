HUD = {}

function HUD.Show(totalPhases)
    SendNUIMessage({ action = 'show', data = { totalPhases = totalPhases } })
end

function HUD.PhaseStart(index, label, progress)
    SendNUIMessage({
        action = 'phaseStart',
        data   = { index = index, label = label, progress = progress }
    })
end

function HUD.UpdateStats()
    SendNUIMessage({
        action = 'updateStats',
        data   = {
            fps     = BM.fps,
            frameMs = string.format('%.1f', BM.fps > 0 and 1000.0 / BM.fps or 0),
        }
    })
end

function HUD.UpdateProgress(progress)
    SendNUIMessage({ action = 'updateProgress', data = { progress = progress } })
end

-- Countdown avant le mega stress test
function HUD.ShowCountdown()
    SendNUIMessage({ action = 'countdown', data = { step = 'show' } })
    Wait(600)
    for i = 3, 1, -1 do
        SendNUIMessage({ action = 'countdown', data = { step = tostring(i) } })
        Wait(1000)
    end
    SendNUIMessage({ action = 'countdown', data = { step = 'go' } })
    Wait(800)
    SendNUIMessage({ action = 'countdown', data = { step = 'hide' } })
end

function HUD.ShowResults(data)
    SendNUIMessage({ action = 'showResults', data = data })
end

-- Thread envoi stats toutes les 200ms
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(200)
        if BM.active then HUD.UpdateStats() end
    end
end)
