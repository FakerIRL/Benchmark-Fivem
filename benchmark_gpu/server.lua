-- mets le joueur dans un routing bucket pendant le benchmark

RegisterNetEvent('benchmark_gpu:enterInstance', function()
    SetPlayerRoutingBucket(source, 200)
end)

RegisterNetEvent('benchmark_gpu:leaveInstance', function()
    SetPlayerRoutingBucket(source, 0)
end)
