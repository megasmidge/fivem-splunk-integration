local QBCore = exports['qb-core']:GetCoreObject()

-- Player lifecycle events
RegisterNetEvent('QBCore:Server:PlayerLoaded', function(Player)
    local src = source
    
    exports['splunk-logger']:LogPlayerEvent('player_join', src, {
        citizenid = Player.PlayerData.citizenid,
        first_join = Player.PlayerData.charinfo.firstname == nil,
        character_name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
        job = Player.PlayerData.job.name,
        job_grade = Player.PlayerData.job.grade.level,
        gang = Player.PlayerData.gang.name,
        money = {
            cash = Player.PlayerData.money.cash,
            bank = Player.PlayerData.money.bank,
            crypto = Player.PlayerData.money.crypto or 0
        },
        phone_number = Player.PlayerData.charinfo.phone,
        last_location = Player.PlayerData.position
    })
end)

RegisterNetEvent('QBCore:Server:OnPlayerUnload', function(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    exports['splunk-logger']:LogPlayerEvent('player_leave', src, {
        citizenid = Player.PlayerData.citizenid,
        session_duration = GetGameTimer(), -- Approximate session time
        final_money = {
            cash = Player.PlayerData.money.cash,
            bank = Player.PlayerData.money.bank,
            crypto = Player.PlayerData.money.crypto or 0
        },
        final_job = Player.PlayerData.job.name,
        final_position = Player.PlayerData.position
    })
end)

-- Character creation/selection
RegisterNetEvent('qb-multicharacter:server:createCharacter', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    exports['splunk-logger']:LogPlayerEvent('character_created', src, {
        character_name = data.firstname .. ' ' .. data.lastname,
        nationality = data.nationality,
        gender = data.gender,
        birthdate = data.birthdate,
        backstory = data.backstory
    })
end)

-- Player death events
RegisterNetEvent('hospital:server:SetDeathStatus', function(isDead)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    if isDead then
        exports['splunk-logger']:LogPlayerEvent('player_death', src, {
            citizenid = Player.PlayerData.citizenid,
            location = Player.PlayerData.position,
            job = Player.PlayerData.job.name,
            timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
        })
    end
end)

RegisterNetEvent('hospital:server:RevivePlayer', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    exports['splunk-logger']:LogPlayerEvent('player_revive', src, {
        citizenid = Player.PlayerData.citizenid,
        location = Player.PlayerData.position,
        revive_method = 'hospital', -- Could be 'ems', 'hospital', 'admin'
        timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
    })
end)
