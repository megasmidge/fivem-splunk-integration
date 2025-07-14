local QBCore = exports['qb-core']:GetCoreObject()

-- Police arrests
RegisterNetEvent('police:server:JailPlayer', function(targetId, time, reason)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Target = QBCore.Functions.GetPlayer(targetId)
    if not Player or not Target then return end
    
    exports['splunk-logger']:LogPlayerEvent('police_arrest', src, {
        officer_citizenid = Player.PlayerData.citizenid,
        suspect_citizenid = Target.PlayerData.citizenid,
        jail_time = time,
        charges = reason,
        location = Player.PlayerData.position,
        officer_badge = Player.PlayerData.metadata.callsign or 'unknown',
        arrest_method = 'manual' -- Could be 'pursuit', 'warrant', 'manual'
    })
end)

-- Police fines/tickets
RegisterNetEvent('police:server:billPlayer', function(playerId, amount, reason)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Target = QBCore.Functions.GetPlayer(playerId)
    if not Player or not Target then return end
    
    exports['splunk-logger']:LogPlayerEvent('police_fine', src, {
        officer_citizenid = Player.PlayerData.citizenid,
        suspect_citizenid = Target.PlayerData.citizenid,
        fine_amount = amount,
        violation = reason,
        location = Player.PlayerData.position,
        payment_status = 'pending'
    })
end)

-- Drug sales/transactions
RegisterNetEvent('qb-drugs:server:sellDrugs', function(drugType, amount, price, buyerId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Buyer = QBCore.Functions.GetPlayer(buyerId)
    if not Player then return end
    
    exports['splunk-logger']:LogPlayerEvent('drug_transaction', src, {
        seller_citizenid = Player.PlayerData.citizenid,
        buyer_citizenid = Buyer and Buyer.PlayerData.citizenid or 'npc',
        drug_type = drugType,
        quantity = amount,
        unit_price = price / amount,
        total_price = price,
        location = Player.PlayerData.position,
        transaction_type = Buyer and 'player_to_player' or 'player_to_npc'
    })
end)

-- Robberies
RegisterNetEvent('qb-storerobbery:server:robberyStarted', function(storeId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    exports['splunk-logger']:LogPlayerEvent('robbery_started', src, {
        citizenid = Player.PlayerData.citizenid,
        store_id = storeId,
        location = Player.PlayerData.position,
        gang_affiliation = Player.PlayerData.gang.name,
        timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
    })
end)

RegisterNetEvent('qb-storerobbery:server:robberyComplete', function(storeId, success, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    exports['splunk-logger']:LogPlayerEvent('robbery_completed', src, {
        citizenid = Player.PlayerData.citizenid,
        store_id = storeId,
        success = success,
        amount_stolen = amount or 0,
        location = Player.PlayerData.position,
        duration = 300 -- Could track actual duration
    })
end)

-- Bank heists
RegisterNetEvent('qb-bankrobbery:server:startHeist', function(bankId, participants)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    exports['splunk-logger']:LogPlayerEvent('bank_heist_started', src, {
        leader_citizenid = Player.PlayerData.citizenid,
        bank_id = bankId,
        participant_count = #participants,
        participants = participants,
        location = Player.PlayerData.position,
        difficulty = 'high', -- Could determine based on bank
        timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
    })
end)

-- Weapon usage
RegisterNetEvent('qb-weapons:server:weaponFired', function(weaponHash, ammoType)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    exports['splunk-logger']:LogPlayerEvent('weapon_fired', src, {
        citizenid = Player.PlayerData.citizenid,
        weapon_hash = weaponHash,
        weapon_name = QBCore.Shared.Weapons[weaponHash] and QBCore.Shared.Weapons[weaponHash].name or 'unknown',
        ammo_type = ammoType,
        location = Player.PlayerData.position,
        job = Player.PlayerData.job.name,
        legal_weapon = Player.PlayerData.job.name == 'police' or Player.PlayerData.job.name == 'sheriff'
    })
end)

-- EMS/Medical events
RegisterNetEvent('ambulance:server:TreatWounds', function(targetId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Target = QBCore.Functions.GetPlayer(targetId)
    if not Player or not Target then return end
    
    exports['splunk-logger']:LogPlayerEvent('medical_treatment', src, {
        medic_citizenid = Player.PlayerData.citizenid,
        patient_citizenid = Target.PlayerData.citizenid,
        treatment_type = 'wound_treatment',
        location = Player.PlayerData.position,
        response_time = 120, -- Could track actual response time
        hospital_transport = false
    })
end)
