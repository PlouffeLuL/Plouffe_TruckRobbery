TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent("Plouffe_TruckRobbery:GetKeys")
AddEventHandler("Plouffe_TruckRobbery:GetKeys", function()
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addInventoryItem("truckkey",1)
    TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'success', text = TruckRobbery.Txt.FoundKey, length = 6000 })
end)

RegisterServerEvent("Plouffe_TruckRobbery:Reward")
AddEventHandler("Plouffe_TruckRobbery:Reward",function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local cashReward = math.random(TruckRobbery.MinCashReward,TruckRobbery.MaxCashReward)
    local jewelsReward = math.random(TruckRobbery.MinJewels,TruckRobbery.MaxJewels)

    if TruckRobbery.UseBlackMoney == true then
        xPlayer.addAccountMoney('black_money', cashReward)
    else
        xPlayer.addMoney(cashReward)
    end
    TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'success', text = TruckRobbery.Txt.CashReward..tostring(cashReward).. " $", length = 9000 })

    if TruckRobbery.UseJewels == true then
        xPlayer.addInventoryItem("jewels",jewelsReward)
        TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'success', text = TruckRobbery.Txt.CashReward..tostring(jewelsReward)..TruckRobbery.Txt.Jewels, length = 9000 })
    end
end)

RegisterServerEvent("Plouffe_TruckRobbery:Alert")
AddEventHandler("Plouffe_TruckRobbery:Alert",function()
    local xPlayers = ESX.GetPlayers()

    for i = 1, # xPlayers, 1 do 
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        if xPlayer then
            if xPlayer.job.name == "police" then
                TriggerClientEvent('mythic_notify:client:SendAlert', xPlayer, { type = 'error', text = TruckRobbery.Txt.PoliceAlertForTruck, length = 9000 })
            end
        end
    end
end)

ESX.RegisterServerCallback("Plouffe_TruckRobbery:CheckItemAmount",function(source,cb,item)
    local xPlayer = ESX.GetPlayerFromId(source)
    local amount = xPlayer.getInventoryItem(item).count
    if amount >= 1 then
        xPlayer.removeInventoryItem(item,1)
    end
    cb(amount)
end)

ESX.RegisterServerCallback("Plouffe_TruckRobbery:CheckCops",function(source,cb)
    local data = {}
    local xPlayers = ESX.GetPlayers()
    local police = 0
    local canrobb = false
    local elapseTime = os.time() - TruckRobbery.LastTruckRobbery
    local timeleft = TruckRobbery.TimerBeforeNewRob - elapseTime

    if elapseTime >= TruckRobbery.TimerBeforeNewRob then
        canrobb = true
        TruckRobbery.LastTruckRobbery = os.time()
    end

    for i = 1, # xPlayers, 1 do 
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        if xPlayer then
            if xPlayer.job.name == "police" then
                police = police + 1
            end
        end
    end

    table.insert(data, {policeamount = police, canrob = canrobb, timer = timeleft})
    cb(data)
end)
