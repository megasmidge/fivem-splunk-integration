local QBCore = exports['qb-core']:GetCoreObject()

-- Job changes
RegisterNetEvent('QBCore:Server:OnJobUpdate', function(src, job)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    exports['splunk-logger']:LogPlayerEvent('job_change', src, {
        citizenid = Player.PlayerData.citizenid,
        old_job = Player.PlayerData.job.name,
        old_grade = Player.PlayerData.job.grade.level,
        new_job = job.name,
        new_grade = job.grade.level,
        salary_change = job.grade.payment - Player.PlayerData.job.grade.payment,
        change_reason = 'manual' -- Could be 'hire', 'fire', 'promotion', 'demotion'
    })
end)

-- Paycheck system
RegisterNetEvent('qb-bossmenu:server:addPaycheck', function(amount, reason)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    exports['splunk-logger']:LogPlayerEvent('job_payment', src, {
        citizenid = Player.PlayerData.citizenid,
        job = Player.PlayerData.job.name,
        job_grade = Player.PlayerData.job.grade.level,
        amount = amount,
        payment_type = reason or 'salary',
        hours_worked = 1, -- Could track actual hours
        performance_bonus = 0 -- Could add performance tracking
    })
end)

-- Clock in/out system
RegisterNetEvent('qb-bossmenu:server:ToggleDuty', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local onDuty = Player.PlayerData.job.onduty
    
    exports['splunk-logger']:LogPlayerEvent('duty_change', src, {
        citizenid = Player.PlayerData.citizenid,
        job = Player.PlayerData.job.name,
        job_grade = Player.PlayerData.job.grade.level,
        action = onDuty and 'clock_in' or 'clock_out',
        location = Player.PlayerData.position,
        timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
    })
end)
