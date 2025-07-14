local QBCore = exports['qb-core']:GetCoreObject()

-- Money transactions
RegisterNetEvent('QBCore:Server:OnMoneyChange', function(src, moneyType, amount, reason)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    exports['splunk-logger']:LogPlayerEvent('money_change', src, {
        citizenid = Player.PlayerData.citizenid,
        money_type = moneyType, -- 'cash', 'bank', 'crypto'
        amount = amount,
        reason = reason,
        old_balance = Player.PlayerData.money[moneyType] - amount,
        new_balance = Player.PlayerData.money[moneyType],
        job = Player.PlayerData.job.name,
        transaction_id = math.random(100000, 999999) -- Simple transaction ID
    })
end)

-- Store purchases (qb-shops integration)
RegisterNetEvent('qb-shops:server:purchaseItem', function(shop, item, amount, price)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    exports['splunk-logger']:LogPlayerEvent('item_purchase', src, {
        citizenid = Player.PlayerData.citizenid,
        shop_name = shop,
        item_name = item,
        quantity = amount,
        unit_price = price / amount,
        total_price = price,
        payment_method = 'cash', -- Could detect payment method
        location = Player.PlayerData.position
    })
end)

-- Player-to-player transactions
RegisterNetEvent('qb-banking:server:TransferMoney', function(target, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local TargetPlayer = QBCore.Functions.GetPlayer(target)
    if not Player or not TargetPlayer then return end
    
    -- Log for sender
    exports['splunk-logger']:LogPlayerEvent('money_transfer_sent', src, {
        sender_citizenid = Player.PlayerData.citizenid,
        receiver_citizenid = TargetPlayer.PlayerData.citizenid,
        amount = amount,
        sender_balance_after = Player.PlayerData.money.bank,
        transfer_type = 'bank_transfer'
    })
    
    -- Log for receiver
    exports['splunk-logger']:LogPlayerEvent('money_transfer_received', target, {
        sender_citizenid = Player.PlayerData.citizenid,
        receiver_citizenid = TargetPlayer.PlayerData.citizenid,
        amount = amount,
        receiver_balance_after = TargetPlayer.PlayerData.money.bank,
        transfer_type = 'bank_transfer'
    })
end)

-- Vehicle purchases
RegisterNetEvent('qb-vehicleshop:server:buyVehicle', function(vehicleData, price)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    exports['splunk-logger']:LogPlayerEvent('vehicle_purchase', src, {
        citizenid = Player.PlayerData.citizenid,
        vehicle_model = vehicleData.model,
        vehicle_hash = vehicleData.hash,
        price = price,
        plate = vehicleData.plate,
        shop_type = vehicleData.shopType or 'unknown',
        payment_method = 'bank' -- Usually bank for vehicles
    })
end)

-- ATM withdrawals/deposits
RegisterNetEvent('qb-atms:server:withdraw', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    exports['splunk-logger']:LogPlayerEvent('atm_transaction', src, {
        citizenid = Player.PlayerData.citizenid,
        transaction_type = 'withdrawal',
        amount = amount,
        balance_after = Player.PlayerData.money.bank,
        location = Player.PlayerData.position
    })
end)

RegisterNetEvent('qb-atms:server:deposit', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    exports['splunk-logger']:LogPlayerEvent('atm_transaction', src, {
        citizenid = Player.PlayerData.citizenid,
        transaction_type = 'deposit',
        amount = amount,
        balance_after = Player.PlayerData.money.bank,
        location = Player.PlayerData.position
    })
end)
