local Formatters = {}

-- Create base event structure
function Formatters.CreateBaseEvent(eventType, playerData, eventData)
    local baseEvent = {
        timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z"),
        server_id = Config.Server.id,
        environment = Config.Server.environment,
        event_type = eventType,
        source_resource = GetInvokingResource() or 'splunk-logger',
        version = '1.0'
    }
    
    if playerData then
        baseEvent.player_data = playerData
    end
    
    if eventData then
        baseEvent.event_data = eventData
    end
    
    return baseEvent
end

-- Format player data consistently
function Formatters.FormatPlayerData(source)
    if not source then return nil end
    
    local playerData = {
        server_id = source,
        steam_id = nil,
        discord_id = nil,
        player_name = GetPlayerName(source)
    }
    
    -- Extract Steam ID
    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local id = GetPlayerIdentifier(source, i)
        if string.find(id, 'steam:') then
            playerData.steam_id = id
        elseif string.find(id, 'discord:') then
            playerData.discord_id = id
        end
    end
    
    return playerData
end

-- Sanitize sensitive data
function Formatters.SanitizeEventData(eventData)
    if not eventData then return nil end
    
    local sanitized = {}
    for k, v in pairs(eventData) do
        -- Remove sensitive fields
        if k ~= 'password' and k ~= 'token' and k ~= 'api_key' then
            sanitized[k] = v
        end
    end
    
    return sanitized
end

-- Export functions
_G.Formatters = Formatters

