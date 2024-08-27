QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('ronakks-sellshop:sellItemToServer', function(itemName, quantity, totalCost)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    -- Check if player has enough items to sell
    local item = Player.Functions.GetItemByName(itemName)
    if item and item.amount >= quantity then
        -- Add money to player
        Player.Functions.AddMoney('cash', totalCost)

        -- Remove item from player inventory
        Player.Functions.RemoveItem(itemName, quantity)

        -- Notify player
        TriggerClientEvent('QBCore:Notify', src, "Sold " .. quantity .. "x " .. itemName .. " for $" .. totalCost, "success")
    else
        -- Notify player if they don't have enough items
        TriggerClientEvent('QBCore:Notify', src, "You don't have enough " .. itemName .. " to sell", "error")
    end
end)
