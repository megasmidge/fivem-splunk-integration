-- Main server-side initialization and exports

-- Initialize components
CreateThread(function()
    QueueManager.Init()
    print('[SplunkLogger] Splunk Logger initialized successfully')
    
    -- Log server startup
    QueueManager.LogSystemEvent(EventTypes.RESOURCE_START, {
        resource_name = 'splunk-logger',
        server_id = Config.Server.id,
        environment = Config.Server.environment
    })
end)

-- Export functions for other resources
exports('LogEvent', function(eventType, playerData, eventData)
    return QueueManager.LogEvent(eventType, playerData, eventData)
end)

exports('LogPlayerEvent', function(eventType, source, eventData)
    return QueueManager.LogPlayerEvent(eventType, source, eventData)
end)

exports('LogSystemEvent', function(eventType, eventData)
    return QueueManager.LogSystemEvent(eventType, eventData)
end)

exports('GetQueueStats', function()
    return QueueManager.GetStats()
end)

-- Built-in player event handlers
RegisterNetEvent('playerConnecting', function(name, setKickReason, deferrals)
    local source = source
    Wait(1000) -- Wait for player to fully connect
    
    QueueManager.LogPlayerEvent(EventTypes.PLAYER_JOIN, source, {
        connect_time = os.date("!%Y-%m-%dT%H:%M:%S.000Z"),
        player_name = name,
        server_slot = source
    })
end)

RegisterNetEvent('playerDropped', function(reason)
    local source = source
    QueueManager.LogPlayerEvent(EventTypes.PLAYER_LEAVE, source, {
        disconnect_time = os.date("!%Y-%m-%dT%H:%M:%S.000Z"),
        reason = reason
    })
end)

-- Chat logging
RegisterNetEvent('chatMessage', function(source, name, message)
    if Config.Events.enable_chat_logging then
        QueueManager.LogPlayerEvent(EventTypes.PLAYER_CHAT, source, {
            message = message,
            message_length = string.len(message)
        })
    end
end)

-- Performance monitoring
if Config.Events.enable_performance_monitoring then
    CreateThread(function()
        while true do
            Wait(30000) -- Every 30 seconds
            
            local playerCount = GetNumPlayerIndices()
            local uptime = GetGameTimer()
            
            QueueManager.LogSystemEvent(EventTypes.SERVER_PERFORMANCE, {
                player_count = playerCount,
                uptime_ms = uptime,
                timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
            })
        end
    end)
end

-- Resource cleanup
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        QueueManager.LogSystemEvent(EventTypes.RESOURCE_STOP, {
            resource_name = resourceName,
            final_stats = QueueManager.GetStats()
        })
        
        -- Flush remaining events
        QueueManager.FlushQueue()
    end
end)

-- Admin command to check logger status
RegisterCommand('splunk-status', function(source, args, rawCommand)
    if source ~= 0 then -- Only console can run this
        return
    end
    
    local queueStats = QueueManager.GetStats()
    local httpStats = HttpClient.GetStats()
    
    print('=== Splunk Logger Status ===')
    print(string.format('Queue Size: %d', queueStats.queue_size))
    print(string.format('Retry Queue: %d', queueStats.retry_queue_size))
    print(string.format('Events Sent: %d', queueStats.events_sent))
    print(string.format('Events Failed: %d', queueStats.events_failed))
    print(string.format('Batches Sent: %d', queueStats.batches_sent))
    print(string.format('Pending Requests: %d', httpStats.pending_requests))
    print(string.format('Last Flush: %d ms ago', GetGameTimer() - queueStats.last_flush))
end, true)
