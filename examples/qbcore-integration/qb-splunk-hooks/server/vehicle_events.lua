local QBCore = exports['qb-core']:GetCoreObject()

-- Vehicle spawning
RegisterNetEvent('qb-garages:server:SpawnVehicle', function(vehicleInfo)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    exports['splunk-logger']:LogPlayerEvent('vehicle_spawn', src, {
        citizenid = Player.PlayerData.citizenid,
        vehicle_plate = vehicleInfo.plate,
        vehicle_model = vehicleInfo.vehicle,
        garage_name = vehicleInfo.garage,
        location = Player.PlayerData.position,
        spawn_type = 'garage'
    })
end)

-- Vehicle impounding
RegisterNetEvent('qb-police:server:Impound', function(plate, fullImpound, price, body, engine, fuel)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    exports['splunk-logger']:LogPlayerEvent('vehicle_impound', src, {
        officer_citizenid = Player.PlayerData.citizenid,
        vehicle_plate = plate,
        impound_type = fullImpound and 'full' or 'temporary',
        impound_price = price,
        vehicle_condition = {
            body = body,
            engine = engine,
            fuel = fuel
        },
        location = Player.PlayerData.position
    })
end)

-- Vehicle modifications
RegisterNetEvent('qb-customs:server:updateVehicle', function(vehicleData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    exports['splunk-logger']:LogPlayerEvent('vehicle_modification', src, {
        citizenid = Player.PlayerData.citizenid,
        vehicle_plate = vehicleData.plate,
        modifications = vehicleData.mods,
        total_cost = vehicleData.price or 0,
        shop_location = Player.PlayerData.position
    })
end)

-- Vehicle sales (player to player)
RegisterNetEvent('qb-vehiclesales:server:sellVehicle', function(targetId, vehicleData, price)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Target = QBCore.Functions.GetPlayer(targetId)
    if not Player or not Target then return end
    
    -- Log for seller
    exports['splunk-logger']:LogPlayerEvent('vehicle_sale', src, {
        seller_citizenid = Player.PlayerData.citizenid,
        buyer_citizenid = Target.PlayerData.citizenid,
        vehicle_plate = vehicleData.plate,
        vehicle_model = vehicleData.vehicle,
        sale_price = price,
        transaction_type = 'player_to_player'
    })
    
    -- Log for buyer
    exports['splunk-logger']:LogPlayerEvent('vehicle_purchase', targetId, {
        seller_citizenid = Player.PlayerData.citizenid,
        buyer_citizenid = Target.PlayerData.citizenid,
        vehicle_plate = vehicleData.plate,
        vehicle_model = vehicleData.vehicle,
        purchase_price = price,
        transaction_type = 'player_to_player'
    })
end)
