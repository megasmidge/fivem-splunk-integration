-- Client-side event collection

-- Track player position periodically
if Config.Events.player_position_interval > 0 then
    CreateThread(function()
        while true do
            Wait(Config.Events.player_position_interval)
            
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            local heading = GetEntityHeading(playerPed)
            
            TriggerServerEvent('splunk-logger:playerPosition', {
                x = coords.x,
                y = coords.y,
                z = coords.z,
                heading = heading
            })
        end
    end)
end

-- Register server event for position updates
RegisterNetEvent('splunk-logger:playerPosition', function(positionData)
    exports['splunk-logger']:LogPlayerEvent(EventTypes.PLAYER_POSITION, source, positionData)
end)
