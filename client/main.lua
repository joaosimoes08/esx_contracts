---Modified by Simoes---

ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)


RegisterNetEvent('esx_contract:getVehicle')
AddEventHandler('esx_contract:getVehicle', function()
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)
	local closestPlayer, playerDistance = ESX.Game.GetClosestPlayer()

	if closestPlayer ~= -1 and playerDistance <= 3.0 then
		local vehicle = ESX.Game.GetClosestVehicle(coords)
		local vehiclecoords = GetEntityCoords(vehicle)
		local vehDistance = GetDistanceBetweenCoords(coords, vehiclecoords, true)
		if DoesEntityExist(vehicle) and (vehDistance <= 3) then
			local vehProps = ESX.Game.GetVehicleProperties(vehicle)
			ESX.ShowNotification(_U('writingcontract', vehProps.plate))
			TriggerServerEvent('esx_clothes:sellVehicle', GetPlayerServerId(closestPlayer), vehProps.plate)
		else
			ESX.ShowNotification(_U('nonearby'))
		end
	else
		ESX.ShowNotification(_U('nonearbybuyer'))
	end
	
end)

RegisterNetEvent('esx_contract:showAnim')
AddEventHandler('esx_contract:showAnim', function(player)
	loadAnimDict('anim@amb@nightclub@peds@')
	TaskStartScenarioInPlace(PlayerPedId(), 'WORLD_HUMAN_CLIPBOARD', 0, false)	
	Citizen.Wait(20000)
	ClearPedTasks(PlayerPedId())
end)


function loadAnimDict(dict)
	while (not HasAnimDictLoaded(dict)) do
		RequestAnimDict(dict)
		Citizen.Wait(0)
	end
end

RegisterNetEvent("esx_carrosolx:contratocarro")
AddEventHandler("esx_carrosolx:contratocarro", function()
	local playerPed = PlayerPedId()
	local coords    = GetEntityCoords(playerPed)

	if IsPedInAnyVehicle(playerPed,  false) then
        vehicle = GetVehiclePedIsIn(playerPed, false)			
    else
        vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 7.0, 0, 70)
    end
	local cod = GetEntityCoords(vehicle)
	if GetDistanceBetweenCoords(coords.x, coords.y, coords.z, cod.x, cod.y, cod.z) >= 5 then 
		exports['mythic_notify']:SendAlert('error', 'Não estás perto de nenhum carro!', 1500)
	else
		contractocarros()
	end
end)

RegisterNetEvent("esx_carrosolx:Dar")
AddEventHandler("esx_carrosolx:Dar", function()
venderCarro()
end)


function giveCarKeys()
	ESX.UI.Menu.CloseAll()
	local playerPed = GetPlayerPed(-1)
	local coords    = GetEntityCoords(playerPed)

	if IsPedInAnyVehicle(playerPed,  false) then
        vehicle = GetVehiclePedIsIn(playerPed, false)			
    else
        vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 7.0, 0, 70)
    end


	local plate = GetVehicleNumberPlateText(vehicle)
	local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
	

	ESX.TriggerServerCallback('carros:dono', function(isOwnedVehicle)
		if not isOwnedVehicle then
			exports['mythic_notify']:SendAlert('error', 'Não possuis nenhum carro!', 1500)
		elseif isOwnedVehicle then
			local empresa = PlayerData.job.name
			local job = PlayerData.job.name
		


if PlayerData.job.grade_name ~= 'boss' then
  ESX.ShowNotification('Não és chefe da empresa')
else  	 
  exports['mythic_notify']:SendAlert('success', 'Colocaste o carro com a matrícula '..vehicleProps.plate..' na tua empresa!', 1500)
  
  TriggerServerEvent('esx_givecarkeys:setVehicleOwnedPlayerId', empresa, vehicleProps, job)
  --TriggerServerEvent('esx_givecarkeys:job')
end

		end
	end, GetVehicleNumberPlateText(vehicle))
end



function venderCarro()
	ESX.UI.Menu.CloseAll()
	local playerPed = GetPlayerPed(-1)
	local coords    = GetEntityCoords(playerPed)
	local vehicle
	if IsPedInAnyVehicle(playerPed,  false) then
		vehicle = GetVehiclePedIsIn(playerPed, false)
	else
		vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 7.0, 0, 70)
	end
	
	local plate = GetVehicleNumberPlateText(vehicle)
	local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
	
	ESX.TriggerServerCallback('carros:dono', function(isOwnedVehicle)
		if isOwnedVehicle then
			ESX.UI.Menu.Open(
				'dialog', GetCurrentResourceName(), 'valor_carro',
				{
				title = "Introduza o preço a que quer vender o carro:"
				  },
				  function(data2, menu2)
					local amount = tonumber(data2.value)
					if amount == nil or amount < 0 then
						ESX.ShowNotification("Quantia Inválida!")
					else
						menu2.close()
						local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
						if closestPlayer == -1 or closestDistance > 3.0 then
							exports['mythic_notify']:SendAlert('error', 'Ninguém por perto!', 1500)
						else
							TriggerServerEvent("esx_carrosolx:proposta",GetPlayerServerId(closestPlayer),vehicleProps.plate,amount)
						end
					end
				  end,
				function(data2, menu2)
					menu2.close()
				end
			)
		else
			exports['mythic_notify']:SendAlert('error', 'Este veículo não te pertence!', 1500)
		end
	end, vehicleProps.plate)
end


RegisterNetEvent("esx_carrosolx:aceitarproposta")
AddEventHandler("esx_carrosolx:aceitarproposta", function(vendedor,matricula,preco)
	local playerPed = GetPlayerPed(-1)
	local coords    = GetEntityCoords(playerPed)
	local vehicle
	if IsPedInAnyVehicle(playerPed,  false) then
		vehicle = GetVehiclePedIsIn(playerPed, false)
	else
		vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 7.0, 0, 70)
	end
	local plate = GetVehicleNumberPlateText(vehicle)
	dinheiro = matricula
	comprador = vendedor
	local elements = {}
	table.insert(elements, {label= "Aceitar Proposta", value = "sim"})
	table.insert(elements, {label= "Recusar Proposta", value = "nao"})
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'propsta', {
		title    = "Proposta de Compra do Veículo com a matrícula " .. plate .. " por " .. dinheiro .. "€ ?",
		align    = 'center',
		elements = elements
	}, function(data, menu)
		if data.current.value == "sim" then
			local comprador = ESX.Game.GetClosestPlayer()
			TriggerServerEvent("esx_carrosolx:respostas",GetPlayerServerId(comprador),plate,matricula)
		end
		if data.current.value == "nao" then
		end
		menu.close()
	end, function(data, menu)
		menu.close()
	end)
end)


function contractocarros()
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'sell_car', {
		title = 'Contrato de Venda',
		align = 'right',
		elements = {
			{label = 'Colocar carro na Empresa', value = 'empresa' },
			{label = 'Vender carro ao cidadão mais próximo', value = 'player' },
		}
	}, function(data, menu)
		if data.current.value =='empresa' then
			ESX.UI.Menu.CloseAll()
			menu.close()
			giveCarKeys()
		end
		if data.current.value == 'player' then
			venderCarro()
		end
	end, function(data, menu)
		menu.close()
	end)
end