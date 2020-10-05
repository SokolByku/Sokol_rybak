ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


ESX.RegisterUsableItem('wedka', function(source)
    local _source = source
	TriggerClientEvent('sokol_sprawdz-lowienie', _source)
end)

RegisterServerEvent('sokol_usunwedke-lowienie')
AddEventHandler('sokol_usunwedke-lowienie',function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.removeInventoryItem('wedka', 1)
end)

RegisterServerEvent('sokol_dajrybe-lowienie')
AddEventHandler('sokol_dajrybe-lowienie',function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.GiveInventoryItem('ryba', 1)
end)

RegisterServerEvent('sokol_dajrybeMala-lowienie')
AddEventHandler('sokol_dajrybeMala-lowienie',function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.GiveInventoryItem('malaryba', 1)
end)

RegisterServerEvent('sokol_dajrybeDuza-lowienie')
AddEventHandler('sokol_dajrybeDuza-lowienie',function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.GiveInventoryItem('duzaryba', 1)
end)



