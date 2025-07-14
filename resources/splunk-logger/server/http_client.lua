local HttpClient = {}
local pendingRequests = {}

-- Send HTTP request to Splunk HEC
function HttpClient.SendToSplunk(events)
    if not events or #events == 0 then
        return false
    end
    
    local payload = ""
    for _, event in ipairs(events) do
        payload = payload .. json.encode(event) .. "\n"
    end
    
    local headers = {
        ['Content-Type'] = 'application/json',
        ['Authorization'] = 'Splunk ' .. Config.Splunk.token
    }
    
    local requestData = {
        url = Config.Splunk.hec_url,
        method = 'POST',
        data = payload,
        headers = headers,
        timeout = Config.Splunk.timeout
    }
    
    -- Track request for monitoring
    local requestId = #pendingRequests + 1
    pendingRequests[requestId] = {
        timestamp = GetGameTimer(),
        event_count = #events,
        status = 'pending'
    }
    
    PerformHttpRequest(requestData.url, function(statusCode, responseBody, responseHeaders)
        HttpClient.HandleResponse(requestId, statusCode, responseBody, events)
    end, requestData.method, requestData.data, requestData.headers)
    
    return true
end

-- Handle HTTP response
function HttpClient.HandleResponse(requestId, statusCode, responseBody, originalEvents)
    local request = pendingRequests[requestId]
    if not request then return end
    
    local success = statusCode >= 200 and statusCode < 300
    request.status = success and 'success' or 'failed'
    request.status_code = statusCode
    request.response_time = GetGameTimer() - request.timestamp
    
    if success then
        if Config.Events.enable_debug_logging then
            print(string.format('[SplunkLogger] Successfully sent %d events to Splunk', request.event_count))
        end
        
        -- Log success metric
        QueueManager.LogSystemEvent(EventTypes.DATABASE_QUERY, {
            operation = 'splunk_http_success',
            event_count = request.event_count,
            response_time = request.response_time,
            status_code = statusCode
        })
    else
        print(string.format('[SplunkLogger] Failed to send events to Splunk. Status: %d, Response: %s', 
              statusCode, responseBody))
        
        -- Log failure and potentially retry
        QueueManager.LogSystemEvent(EventTypes.ERROR_EVENT, {
            operation = 'splunk_http_failed',
            status_code = statusCode,
            response_body = responseBody,
            event_count = request.event_count
        })
        
        -- Retry logic handled by queue manager
        QueueManager.HandleFailedBatch(originalEvents)
    end
    
    -- Clean up request tracking
    pendingRequests[requestId] = nil
end

-- Get HTTP client statistics
function HttpClient.GetStats()
    local stats = {
        pending_requests = 0,
        total_requests = 0
    }
    
    for _ in pairs(pendingRequests) do
        stats.pending_requests = stats.pending_requests + 1
    end
    
    return stats
end

-- Export functions
_G.HttpClient = HttpClient
