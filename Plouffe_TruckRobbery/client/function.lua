function SearchKey()
	for k,v in ipairs(TruckRobbery.Coords) do
		local ped = GetPlayerPed(-1) 
		local pedCoords = GetEntityCoords(ped)
		local dstCheck = GetDistanceBetweenCoords(pedCoords,v.coords,true)
		if dstCheck <= v.maxDst and v.issearched == false then
			SetEntityHeading(ped,v.heading)
			TaskStartScenarioInPlace(ped, "PROP_HUMAN_BUM_BIN", 0, true)
			TriggerEvent("mythic_progbar:client:progress", {
				name = "search_keys",
				duration = 20000,
				label = TruckRobbery.Txt.Search,
				useWhileDead = false,
				canCancel = true,
				controlDisables = {
					disableMovement = true,
					disableCarMovement = true,
					disableMouse = false,
					disableCombat = true,
				}
			}, function(status)
				if not status then
					local randi = math.random(0,10)
					v.issearched = true
					if randi >= TruckRobbery.KeyChances then
						TriggerServerEvent("Plouffe_TruckRobbery:GetKeys")
					else
						exports['mythic_notify']:SendAlert('inform', TruckRobbery.Txt.NothingFound, 10000, { ['background-color'] = ' #ff0000 ', ['color'] = '#fffcfc' })
					end
					ClearPedTasksImmediately(ped)
					StartSearchTimer(k)
				end
			end)
		end
	end
end

function StartSearchTimer(Zone)
	local seconds = 0 
	local stop = false
	
	repeat
		Wait(1000)
		seconds = seconds + 1
		if seconds >= TruckRobbery.SearchTimer then
			stop = true
			break
		end
	until stop == true

	for k,v in ipairs(TruckRobbery.Coords) do 
		if k == Zone then
			v.issearched = false
		end
	end
end

function ExplodeDoor()
	local ped = GetPlayerPed(-1)
	local pedCoords = GetEntityCoords(ped)
	local bankDoor = GetClosestObjectOfType(pedCoords,25.0,GetHashKey("v_ilev_gb_teldr"),false,false,false)
	local bankDoorbankDoorCoords = GetEntityCoords(bankDoor)
	local dstCheck = GetDistanceBetweenCoords(pedCoords,bankDoorbankDoorCoords,true)

	if dstCheck <= 1.5 then
		TriggerEvent("mythic_progbar:client:progress", {
			name = "blowingup_door",
			duration = TruckRobbery.TntInstalationTimer,
			label = TruckRobbery.Txt.InstallingTnt,
			useWhileDead = false,
			canCancel = true,
			controlDisables = {
				disableMovement = true,
				disableCarMovement = true,
				disableMouse = false,
				disableCombat = true,
			},
			animation = {
				animDict = "random@train_tracks",
				anim = "idle_e",
			},
		}, function(status)
			if not status then
				FreezeEntityPosition(bankDoor,false)
				exports['mythic_notify']:SendAlert('inform', TruckRobbery.Txt.TntInstalationDone, 10000, { ['background-color'] = ' #ff0000 ', ['color'] = '#fffcfc' })
				Wait(3500)
				AddExplosion(bankDoorbankDoorCoords,"EXPLOSION_SMOKEGRENADE",9,true,false,100.0,false)
				ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.2)
				SetEntityVelocity(bankDoor,pedCoords)
				pedCoords = GetEntityCoords(GetPlayerPed(-1))
				bankDoor = GetClosestObjectOfType(pedCoords,25.0,GetHashKey("v_ilev_gb_teldr"),false,false,false)
				bankDoorbankDoorCoords = GetEntityCoords(bankDoor)
				dstCheck = GetDistanceBetweenCoords(pedCoords,bankDoorbankDoorCoords,true)
				if dstCheck <= 3 then
					SetEntityHealth(ped,0.0)
				end
			end
		end)
	else
		exports['mythic_notify']:SendAlert('inform', TruckRobbery.Txt.TooFarFromDoor, 10000, { ['background-color'] = ' #ff0000 ', ['color'] = '#fffcfc' })
	end
end

function SpawnTruck()
	TriggerEvent("mythic_progbar:client:progress", {
		name = "search_keys",
		duration = TruckRobbery.SearchKeyTimer,
		label = TruckRobbery.Txt.CheckingKey,
		useWhileDead = false,
		canCancel = true,
		controlDisables = {
			disableMovement = true,
			disableCarMovement = true,
			disableMouse = false,
			disableCombat = true,
		},
		animation = {
			animDict = "missheistdockssetup1clipboard@base",
			anim = "base",
		}
	}, function(status)
		if not status then
			ESX.TriggerServerCallback("Plouffe_TruckRobbery:CheckItemAmount",function(amount)
				if amount >= 1 then
					ESX.Game.SpawnVehicle(TruckRobbery.SpawnTruckModel, TruckRobbery.SpawnTruckCoords,TruckRobbery.SapwnTruckHeading , function(vehicle)
						TriggerEvent('BckekwFuel:DmvRefuel', vehicle)
					end)
					exports['mythic_notify']:SendAlert('inform', TruckRobbery.Txt.GoodKey, 10000, { ['background-color'] = '#00ff3c', ['color'] = '#fffcfc' })
				else
					exports['mythic_notify']:SendAlert('inform', TruckRobbery.Txt.NoKey, 10000, { ['background-color'] = '#ff0000', ['color'] = '#fffcfc' })
				end
			end,"truckkey")
		end
	end)
end

function StartTruckRobbery()
	local ped = GetPlayerPed(-1)
	local pedCoords = GetEntityCoords(ped)
	local currentCar = GetVehiclePedIsIn(ped,false)
	local currentModel = GetEntityModel(currentCar)
	local bag = 0 
	if currentModel == GetHashKey(TruckRobbery.SpawnTruckModel) then
		if TruckRobbery.UseBag == true then
			TriggerEvent('skinchanger:getSkin', function(skin)
				bag = skin['bags_1']
			end)
			if bag == 40 or bag == 41 or bag == 44 or bag == 45 then
				ESX.TriggerServerCallback("Plouffe_TruckRobbery:CheckCops", function(data)
					local policecount = 0
					local canrob = false
					local time = 0
				
					for i = 1, #data, 1 do
						policecount = data[i].policeamount
						canrob = data[i].canrob
						time = data[i].timer
					end
				
					if policecount >= TruckRobbery.MinCops then
						if canrob == true then
							TriggerServerEvent("Plouffe_TruckRobbery:Alert")
							StealTruck(currentCar)
							exports['mythic_notify']:SendAlert('inform', TruckRobbery.Txt.GoBehind, 6000, { ['background-color'] = ' #032cfc ', ['color'] = '#fffcfc' })
						else
							exports['mythic_notify']:SendAlert('inform', TruckRobbery.Txt.TimerWait..tostring(math.ceil(time/60))..TruckRobbery.Txt.TimerWaitMinutes, 10000, { ['background-color'] = ' #ff0000 ', ['color'] = '#fffcfc' })
						end
					else
						exports['mythic_notify']:SendAlert('inform', TruckRobbery.Txt.MoreCops, 10000, { ['background-color'] = ' #ff0000 ', ['color'] = '#fffcfc' })
					end
				end)
			else
				exports['mythic_notify']:SendAlert('inform', TruckRobbery.Txt.NeedBag, 10000, { ['background-color'] = ' #ff0000 ', ['color'] = '#fffcfc' })
			end
		else
			ESX.TriggerServerCallback("Plouffe_TruckRobbery:CheckCops", function(data)
				local policecount = 0
				local canrob = false
				local time = 0
			
				for i = 1, #data, 1 do
					policecount = data[i].policeamount
					canrob = data[i].canrob
					time = data[i].timer
				end
			
				if policecount >= TruckRobbery.MinCops then
					if canrob == true then
						TriggerServerEvent("Plouffe_TruckRobbery:Alert")
						StealTruck(currentCar)
						exports['mythic_notify']:SendAlert('inform', TruckRobbery.Txt.GoBehind, 6000, { ['background-color'] = ' #032cfc ', ['color'] = '#fffcfc' })
					else
						exports['mythic_notify']:SendAlert('inform', TruckRobbery.Txt.TimerWait..tostring(math.ceil(time/60))..TruckRobbery.Txt.TimerWaitMinutes, 10000, { ['background-color'] = ' #ff0000 ', ['color'] = '#fffcfc' })
					end
				else
					exports['mythic_notify']:SendAlert('inform', TruckRobbery.Txt.MoreCops, 10000, { ['background-color'] = ' #ff0000 ', ['color'] = '#fffcfc' })
				end
			end)
		end
	end
end

function IsBehindTruck(truck)
	local ped = GetPlayerPed(-1)
	local pedCoords = GetEntityCoords(ped)
	local carCoords = GetEntityCoords(truck)
	local truckHeading = GetEntityHeading(truck)
	local dstCheck = GetDistanceBetweenCoords(pedCoords,carCoords,true)
	if dstCheck >= 4.1 and dstCheck <= 4.3 then
		return true , dstCheck , truckHeading
	else
		return false , dstCheck , truckHeading
	end
end

function ThermalEffect(pedOffSet)
	local ped = GetPlayerPed(-1)
	local pedCoords = GetEntityCoords(ped)
	local heading = GetEntityHeading(ped)
	local doorOpen = false

	RequestNamedPtfxAsset("scr_ornate_heist")
	while not HasNamedPtfxAssetLoaded("scr_ornate_heist") do
		Wait(1)
	end
	SetPtfxAssetNextCall("scr_ornate_heist")
	local effect = StartParticleFxLoopedAtCoord("scr_heist_ornate_thermal_burn", pedOffSet, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
	TriggerEvent("mythic_progbar:client:progress", {
		name = "thermal_truck",
		duration = TruckRobbery.EffectTimer,
		label = TruckRobbery.Txt.UsingEffect,
		useWhileDead = false,
		canCancel = false,
		controlDisables = {
			disableMovement = false,
			disableCarMovement = false,
			disableMouse = false,
			disableCombat = false,
		},
	}, function(status)
		if not status then
			StopParticleFxLooped(effect, 0)
			doorOpen = true
		end
	end)

	while doorOpen == false do 
		Wait(100)
	end
end

function DrawText3D(x, y, z, text, scale)
	local onScreen, _x, _y = World3dToScreen2d(x, y, z)
	local pX, pY, pZ = table.unpack(GetGameplayCamCoords())
	SetTextScale(scale, scale)
	SetTextFont(4)
	SetTextProportional(1)
	SetTextEntry("STRING")
	SetTextCentre(1)
	SetTextColour(255, 255, 255, 255)
	SetTextOutline()
	AddTextComponentString(text)
	DrawText(_x, _y)
	local factor = (string.len(text)) / 270
	DrawRect(_x, _y + 0.015, 0.005 + factor, 0.03, 31, 31, 31, 155)
end

function StealTruck(currentCar)
	TruckRobbery.ActiveyRobbing = true
	local isDoorBreak = false
	local currentlyRobbing = false
	local robbedTime = 0
	local firstTruckCoords = GetEntityCoords(currentCar)

	Citizen.CreateThread(function()
		while TruckRobbery.ActiveyRobbing == true do 
			Wait(0)
			local ped = GetPlayerPed(-1)
			local pedCoords = GetEntityCoords(ped)
			local truckCoords = GetEntityCoords(currentCar)
			local behind, check , truckHeading = IsBehindTruck(currentCar)
			local dstCheck = GetDistanceBetweenCoords(pedCoords,firstTruckCoords,true)

			if behind == true and isDoorBreak == false then
				ESX.Game.Utils.DrawText3D(pedCoords,TruckRobbery.Txt.BackDoor,0.4)
				if IsControlJustReleased(0, 38) and behind == true then
					local truckHitCoords = RayCheck()
					TaskStartScenarioInPlace(ped, "PROP_HUMAN_BUM_BIN", 0, true)
					SetEntityHeading(ped,truckHeading)
					Wait(5000)
					ClearPedTasksImmediately(ped)
					ThermalEffect(truckHitCoords)
					SetVehicleDoorBroken(currentCar,2,false)
					SetVehicleDoorBroken(currentCar,3,false)
					isDoorBreak = true
				end
			elseif behind == true and isDoorBreak == true and not currentlyRobbing then
				ESX.Game.Utils.DrawText3D(pedCoords,TruckRobbery.Txt.NoBackDoor,0.4)
				if IsControlJustReleased(0, 38) and behind == true then
					currentlyRobbing = true
					SetEntityHeading(ped,truckHeading)

					if IsPedArmed(ped,7) then
						SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"), true)
						Wait(2700)
					end

					TriggerEvent("mythic_progbar:client:progress", {
						name = "robbing_truck",
						duration = TruckRobbery.RobTimer,
						label = TruckRobbery.Txt.RobbingTruck,
						useWhileDead = false,
						canCancel = true,
						controlDisables = {
							disableMovement = true,
							disableCarMovement = true,
							disableMouse = false,
							disableCombat = true,
						},
						animation = {
							animDict = "mp_missheist_ornatebank",
							anim = "stand_cash_in_bag_loop",
						},
					}, function(status)
						if not status then
							currentlyRobbing = false
							robbedTime = robbedTime + 1
							TriggerServerEvent("Plouffe_TruckRobbery:Reward")
						else
							currentlyRobbing = false
						end
					end)
				end
			end

			if robbedTime >= TruckRobbery.MaxRob then
				TruckRobbery.ActiveyRobbing = false
				exports['mythic_notify']:SendAlert('inform', TruckRobbery.Txt.Finish, 10000, { ['background-color'] = ' #ff0000 ', ['color'] = '#fffcfc' })
				break
			end

			if dstCheck >= TruckRobbery.MaxTruckDistance then
				TruckRobbery.ActiveyRobbing = false
				exports['mythic_notify']:SendAlert('inform', TruckRobbery.Txt.TooFar, 10000, { ['background-color'] = ' #ff0000 ', ['color'] = '#fffcfc' })
				break
			end
		end
	end)
end

function RayCheck()
	local playerPed    = PlayerPedId()
	local playerCoords = GetEntityCoords(playerPed)
	local inDirection  = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 5.0, 0.0)
	local rayHandle    = StartShapeTestRay(playerCoords, inDirection, 10, playerPed, 0)
	local numRayHandle, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)

	if hit == 1 and GetEntityType(entityHit) == 2 then
		return endCoords
	end

	return nil
end