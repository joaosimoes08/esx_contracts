
---Modified by SImoes---

ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_clothes:sellVehicle')
AddEventHandler('esx_clothes:sellVehicle', function(target, plate)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local _target = target
	local tPlayer = ESX.GetPlayerFromId(_target)
	local result = MySQL.Sync.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @identifier AND plate = @plate', {
			['@identifier'] = xPlayer.identifier,
			['@plate'] = plate
		})
	if result[1] ~= nil then
		MySQL.Async.execute('UPDATE owned_vehicles SET owner = @target WHERE owner = @owner AND plate = @plate', {
			['@owner'] = xPlayer.identifier,
			['@plate'] = plate,
			['@target'] = tPlayer.identifier
		}, function (rowsChanged)
			if rowsChanged ~= 0 then
				TriggerClientEvent('esx_contract:showAnim', _source)
				Wait(22000)
				TriggerClientEvent('esx_contract:showAnim', _target)
				Wait(22000)
				TriggerClientEvent('esx:showNotification', _source, _U('soldvehicle', plate))
				TriggerClientEvent('esx:showNotification', _target, _U('boughtvehicle', plate))
				xPlayer.removeInventoryItem('contract', 1)
			end
		end)
	else
		TriggerClientEvent('esx:showNotification', _source, _U('notyourcar'))
	end
end)

RegisterServerEvent('print:loadout')
AddEventHandler('print:loadout', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	print(xPlayer.loadout)
end)

ESX.RegisterUsableItem('contract', function(source)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	TriggerClientEvent('esx_carrosolx:contratocarro', _source)
end)

ESX.RegisterServerCallback('esx_carrosolx:requestPlayerCars', function(source, cb, plate)

	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.fetchAll(
		'SELECT * FROM owned_vehicles WHERE owner = @identifier',
		{
			['@identifier'] = xPlayer.identifier
		},
		function(result)

			local found = false

			for i=1, #result, 1 do

				local vehicleProps = json.decode(result[i].vehicle)

				if trim(vehicleProps.plate) == trim(plate) then
					found = true
					break
				end

			end

			if found then
				cb(true)
			else
				cb(false)
			end

		end
	)
end)

ESX.RegisterServerCallback('eden_garage:getVehicles22', function(source, cb)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local vehicules = {}

    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner=@identifier AND type=@type', {
        ['@identifier'] = xPlayer.getIdentifier(),
        ['@type'] = 'car'
    }, function(data)
        for _, v in pairs(data) do
            local vehicle = json.decode(v.vehicle)

            table.insert(vehicules, {
                vehicle = vehicle,
                state = v.state,
                plate = v.plate
            })
        end

        cb(vehicules)
    end)
end)

ESX.RegisterServerCallback('carros:dono', function(source, cb, plate)

	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.fetchAll(
		'SELECT * FROM owned_vehicles WHERE owner = @identifier',
		{
			['@identifier'] = xPlayer.identifier
		},
		function(result)

			local found = false

			for i=1, #result, 1 do

				local vehicleProps = json.decode(result[i].vehicle)

				if trim(vehicleProps.plate) == trim(plate) then
					found = true
					break
				end

			end

			if found then
				cb(true)
			else
				cb(false)
			end

		end
	)
end)

function trim(s)
    if s ~= nil then
		return s:match("^%s*(.-)%s*$")
	else
		return nil
    end
end

RegisterServerEvent('esx_carrosolx:proposta')
AddEventHandler('esx_carrosolx:proposta', function(target, plate, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(target)
	local preco = tonumber(amount)
	local matricula = plate
	TriggerClientEvent('esx_carrosolx:aceitarproposta', xTarget.source,matricula,preco)
end)

RegisterServerEvent('esx_carrosolx:respostas')
AddEventHandler('esx_carrosolx:respostas', function(target, plate, preco)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local tPlayer = ESX.GetPlayerFromId(target)

	if xPlayer.getAccount('bank').money >= preco then
		xPlayer.removeAccountMoney('bank', tonumber(preco))
		tPlayer.addAccountMoney('bank', tonumber(preco))
	local result = MySQL.Sync.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @identifier AND plate = @plate', {
			['@identifier'] = tPlayer.identifier,
			['@plate'] = plate
		})
	if result[1] ~= nil then
		MySQL.Async.execute('UPDATE owned_vehicles SET owner = @target WHERE owner = @owner AND plate = @plate', {
			['@owner'] = tPlayer.identifier,
			['@plate'] = plate,
			['@target'] = xPlayer.identifier
		}, function (rowsChanged)
			--TriggerClientEvent('esx:showNotification', xPlayer.source, "Compraste o carro.")
			TriggerClientEvent('mythic_notify:client:SendAlert', xPlayer.source, { type = 'success', text = 'Compraste o carro.' })
			TriggerClientEvent('mythic_notify:client:SendAlert', tPlayer.source, { type = 'success', text = 'Vendeste o carro.' })
			tPlayer.removeInventoryItem('contract', 1)
			TriggerEvent("logs:contratocarro", GetPlayerName(target).. ' vendeu um carro com a matrícula ' .. plate .. ' a ' ..GetPlayerName(_source).. ' por ' ..preco.. '€')
		--TriggerClientEvent('esx:showNotification', tPlayer.source, "Vendeste o carro.")
		--print('CARRO VENDIDO')
		end)
	end
else
	--TriggerClientEvent('esx:showNotification', xPlayer.source, "Não tens dinheiro suficiente para comprar o carro.")
	TriggerClientEvent('mythic_notify:client:SendAlert', xPlayer.source, { type = 'error', text = 'Não tens dinheiro suficiente para comprar o carro.' })
	TriggerClientEvent('mythic_notify:client:SendAlert', tPlayer.source, { type = 'error', text = 'O comprador não tem dinheiro suficiente para comprar o teu carro.' })
	--TriggerClientEvent('esx:showNotification', tPlayer.source, "O comprador não tem dinheiro suficiente para comprar o teu carro.")
end
end)

---CARRO EMPRESA

RegisterServerEvent('esx_givecarkeys:setVehicleOwnedPlayerId')
AddEventHandler('esx_givecarkeys:setVehicleOwnedPlayerId', function (empresa, vehicleProps)
	--local empresa = "society:"..PlayerData.job.name
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.execute('UPDATE owned_vehicles SET owner=@owner WHERE plate=@plate',
	{
		['@owner'] = xPlayer.job.name,
		['@plate']   = vehicleProps.plate
	},

	function (rowsChanged)
	end)

	MySQL.Async.execute('UPDATE owned_vehicles SET job=@job WHERE plate=@plate',
	{
	  ['@job']   = xPlayer.job.name,
	  ['@plate']   = vehicleProps.plate
	})

	xPlayer.removeInventoryItem('contract', 1)

end)