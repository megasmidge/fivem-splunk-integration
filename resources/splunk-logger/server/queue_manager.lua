local QueueManager = {}
local eventQueue = {}
local retryQueue = {}
local stats = {
    events_queued = 0,
    events_sent = 0,
    events_failed = 0,
    batches_sent = 0,
    last_flush = 0
}

-- Initialize queue manager
function QueueManager.Init()
    -- Start flush timer
    CreateThread(function()
        while true do
            Wait(Config.Batching.flush_interval)
            QueueManager.FlushQueue()
        end
    end)
    
    -- Start retry timer
    CreateThread(function()
        while true do
            Wait(Config.Batching.retry_delay)
            QueueManager.ProcessRetryQueue()
        end
    end)
    
    print('[SplunkLogger] Queue manager initialized')
end

-- Add event to queue
function QueueManager.QueueEvent(event)
    if #eventQueue >= Config.Batching.max_queue_size then
        print('[SplunkLogger] Queue is full, dropping event')
        stats.events_failed = stats.events_failed + 1
        return false
    end
    
    table.insert(eventQueue, event)
    stats.events_queued = stats.events_queued + 1
    
    -- Force flush if batch size reached
    if #eventQueue >= Config.Batching.max_batch_size then
        QueueManager.FlushQueue()
    end
    
    return true
end

-- Flush queue to Splunk
function QueueManager.FlushQueue()
    if #eventQueue == 0 then return end
    
    local batch = {}
    local batchSize = math.min(#eventQueue, Config.Batching.max_batch_size)
    
    for i = 1, batchSize do
        table.insert(batch, eventQueue[i])
    end
    
    -- Remove processed events from queue
    for i = batchSize, 1, -1 do
        table.remove(eventQueue, i)
    end
    
    if HttpClient.SendToSplunk(batch) then
        stats.events_sent = stats.events_sent + #batch
        stats.batches_sent = stats.batches_sent + 1
        stats.last_flush = GetGameTimer()
        
        if Config.Events.enable_debug_logging then
            print(string.format('[SplunkLogger] Flushed batch of %d events', #batch))
        end
    else
        -- Re-queue events on failure
        for _, event in ipairs(batch) do
            table.insert(eventQueue, 1, event)
        end
    end
end

-- Handle failed batch for retry
function QueueManager.HandleFailedBatch(events)
    for _, event in ipairs(events) do
        -- Add retry count and timestamp
        event._retry_count = (event._retry_count or 0) + 1
        event._retry_timestamp = GetGameTimer()
        
        if event._retry_count <= Config.Batching.retry_attempts then
            table.insert(retryQueue, event)
        else
            print('[SplunkLogger] Event exceeded retry limit, dropping')
            stats.events_failed = stats.events_failed + 1
        end
    end
end

-- Process retry queue
function QueueManager.ProcessRetryQueue()
    if #retryQueue == 0 then return end
    
    local now = GetGameTimer()
    local eventsToRetry = {}
    
    for i = #retryQueue, 1, -1 do
        local event = retryQueue[i]
        if now - event._retry_timestamp >= Config.Batching.retry_delay then
            table.insert(eventsToRetry, event)
            table.remove(retryQueue, i)
        end
    end
    
    -- Re-queue events for retry
    for _, event in ipairs(eventsToRetry) do
        -- Clean up retry metadata
        event._retry_timestamp = nil
        QueueManager.QueueEvent(event)
    end
end

-- Main logging function
function QueueManager.LogEvent(eventType, playerData, eventData)
    local event = Formatters.CreateBaseEvent(eventType, playerData, eventData)
    return QueueManager.QueueEvent(event)
end

-- Convenience function for player events
function QueueManager.LogPlayerEvent(eventType, source, eventData)
    local playerData = Formatters.FormatPlayerData(source)
    local sanitizedData = Formatters.SanitizeEventData(eventData)
    return QueueManager.LogEvent(eventType, playerData, sanitizedData)
end

-- Convenience function for system events
function QueueManager.LogSystemEvent(eventType, eventData)
    local sanitizedData = Formatters.SanitizeEventData(eventData)
    return QueueManager.LogEvent(eventType, nil, sanitizedData)
end

-- Get queue statistics
function QueueManager.GetStats()
    return {
        queue_size = #eventQueue,
        retry_queue_size = #retryQueue,
        events_queued = stats.events_queued,
        events_sent = stats.events_sent,
        events_failed = stats.events_failed,
        batches_sent = stats.batches_sent,
        last_flush = stats.last_flush,
        uptime = GetGameTimer()
    }
end

-- Export functions
_G.QueueManager = QueueManager
