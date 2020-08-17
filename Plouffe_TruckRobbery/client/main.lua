local HasAlreadyEnteredZone = false
local LastZone = nil
local canOpenMenu = false
local zoneMenu = nil

Citizen.CreateThread(function ()
	while true do
		Citizen.Wait(0)
		local ped = GetPlayerPed(-1)
		local pedCoords = GetEntityCoords(ped)
		local letSleep = true
		local isInZone  = false
		local currentZone = nil
		local menu = nil

		for k,v in ipairs(TruckRobbery.Coords) do 
			local dstCheck = #(pedCoords - v.coords)
			if dstCheck <= 15 then
				letSleep = false
				if dstCheck <= v.maxDst then
					if v.issearched ~= nil and v.issearched == false then
						ESX.Game.Utils.DrawText3D(pedCoords,v.txt,v.txtSize)
						isInZone  = true
						currentZone = k
						menu = v.type
					elseif v.issearched == nil and v.car == nil then
						ESX.Game.Utils.DrawText3D(pedCoords,v.txt,v.txtSize)
						isInZone  = true
						currentZone = k
						menu = v.type
					elseif v.car ~= nil then
						local ped = GetPlayerPed(-1)
						local pedCoords = GetEntityCoords(ped)
						local currentCar = GetVehiclePedIsIn(ped,false)
						local currentModel = GetEntityModel(currentCar)
						local driver = GetPedInVehicleSeat(currentCar,-1)
						if currentModel == GetHashKey(TruckRobbery.SpawnTruckModel) and driver == ped and TruckRobbery.ActiveyRobbing == false then
							ESX.Game.Utils.DrawText3D(pedCoords,v.txt,v.txtSize)
							isInZone  = true
							currentZone = k
							menu = v.type
						end
					end
				end
			end
		end

		if (isInZone and not HasAlreadyEnteredZone) or (isInZone and LastZone ~= currentZone) then
			HasAlreadyEnteredZone = true
			LastZone                = currentZone
			TriggerEvent('Plouffe_TruckRobbery:InZone', currentZone,menu)
		end

		if not isInZone and HasAlreadyEnteredZone then
			HasAlreadyEnteredZone = false
			TriggerEvent('Plouffe_TruckRobbery:OuOfZone', LastZone)
		end

		if letSleep == true then
			Wait(5000)
		end
	end
end)

Citizen.CreateThread(function()
	while true do 
		Wait(0)
		if zoneMenu ~= nil and canOpenMenu == true then
			if IsControlJustReleased(0, 38) then
				if zoneMenu == "search" then
					SearchKey()
					Wait(5000)
				elseif zoneMenu == "spawntruck" then
					SpawnTruck()
					Wait(10000)
				elseif zoneMenu == "robbery" then
					StartTruckRobbery()
					Wait(10000)
				end
			end
		else
			Wait(1000)
		end
	end
end)

RegisterNetEvent("Plouffe_TruckRobbery:InZone")
AddEventHandler("Plouffe_TruckRobbery:InZone",function(zone,menu)
	zoneMenu = menu
	canOpenMenu = true
    ESX.UI.Menu.CloseAll()
end)

RegisterNetEvent("Plouffe_TruckRobbery:OuOfZone")
AddEventHandler("Plouffe_TruckRobbery:OuOfZone",function(zone)
	zoneMenu = nil
	canOpenMenu = false
    ESX.UI.Menu.CloseAll()
end)