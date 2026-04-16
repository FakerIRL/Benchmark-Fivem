-- Point d'entrée : commande joueur + callback NUI

RegisterCommand(Config.command, function()
    if BM.active then
        TriggerEvent('chat:addMessage', { args = { '[BENCHMARK]', 'Un test est déjà en cours.' } })
        return
    end
    Citizen.CreateThread(Benchmark.Run)
end, false)

RegisterNUICallback('closeBenchmark', function(_, cb)
    DisplayHud(true)
    DisplayRadar(true)
    SetNuiFocus(false, false)
    BM.closing = true
    cb({})
end)
