-- Ensure QBCore is initialized
local QBCore = exports['qb-core']:GetCoreObject()

local function spawnPed(pedConfig)
    RequestModel(GetHashKey(pedConfig.model))
    while not HasModelLoaded(GetHashKey(pedConfig.model)) do
        Wait(500)
    end

    local ped = CreatePed(4, GetHashKey(pedConfig.model), pedConfig.coords.x, pedConfig.coords.y, pedConfig.coords.z - 1.0, pedConfig.coords.w, false, true)
    SetEntityHeading(ped, pedConfig.coords.w)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskStartScenarioInPlace(ped, pedConfig.scenario, 0, true)

    exports['qb-target']:AddTargetEntity(ped, {
        options = {
            {
                type = "client",
                event = "ronakks-sellshop:openMenu",
                icon = "fas fa-dollar-sign",
                label = "I have somthing to sell",
                pedConfig = pedConfig
            }
        },
        distance = 2.5
    })

    return ped
end

CreateThread(function()
    for _, pedConfig in pairs(Config.Peds) do
        spawnPed(pedConfig)
    end
end)

RegisterNetEvent('ronakks-sellshop:openMenu', function(data)
    local pedConfig = data.pedConfig

    local menuOptions = {
        {
            header = "Welcome to " .. pedConfig.shopName,
            txt = "",
            isMenuHeader = true
        }
    }

    for _, item in pairs(pedConfig.items) do
        table.insert(menuOptions, {
            header = item.label,
            txt = item.description .. " - $" .. item.price,
            params = {
                event = 'ronakks-sellshop:selectQuantity',
                args = {
                    item = item,
                    pedConfig = pedConfig
                }
            }
        })
    end

    -- Move the "Close" option to the end
    table.insert(menuOptions, {
        header = "Close",
        txt = "Close the menu",
        params = {
            event = "qb-menu:closeMenu"
        }
    })

    exports['qb-menu']:openMenu(menuOptions)
end)

RegisterNetEvent('ronakks-sellshop:selectQuantity', function(data)
    local item = data.item
    local pedConfig = data.pedConfig

    local quantityOptions = {
        {qty = 1, label = "1x"},
        {qty = 5, label = "5x"},
        {qty = 10, label = "10x"},
        {qty = 25, label = "25x"},
        {qty = 50, label = "50x"}
    }

    local menuOptions = {
        {
            header = "Select Quantity Of " .. item.label,
            txt = "",
            isMenuHeader = true
        }
    }

    for _, option in ipairs(quantityOptions) do
        local totalCost = item.price * option.qty
        table.insert(menuOptions, {
            header = option.label .. " - " .. item.label,
            txt = item.description .. " - Total: $" .. totalCost,
            params = {
                event = 'ronakks-sellshop:sellItem',
                args = {
                    item = item,
                    quantity = option.qty,
                    pedConfig = pedConfig
                }
            }
        })
    end

    -- Move the "Back" option to the end
    table.insert(menuOptions, {
        header = "Back",
        txt = "Go back to the item menu",
        params = {
            event = 'ronakks-sellshop:openMenu',
            args = {
                pedConfig = pedConfig
            }
        }
    })

    exports['qb-menu']:openMenu(menuOptions)
end)

RegisterNetEvent('ronakks-sellshop:sellItem', function(data)
    local item = data.item
    local quantity = data.quantity
    local pedConfig = data.pedConfig
    local totalCost = item.price * quantity

    if QBCore then
        local player = QBCore.Functions.GetPlayerData()
        local playerInventory = player.items
        local hasItem = false

        -- Check if the player has enough of the item
        for _, invItem in pairs(playerInventory) do
            if invItem.name == item.model and invItem.amount >= quantity then
                hasItem = true
                break
            end
        end

        if hasItem then
            -- Handle selling item logic (e.g., remove from inventory and give money to player)
            TriggerServerEvent('ronakks-sellshop:sellItemToServer', item.model, quantity, totalCost)

            -- Play animation for the ped
            local ped = GetClosestPed(pedConfig.coords.x, pedConfig.coords.y, pedConfig.coords.z)
            if ped then
                local animDict = "mp_common"
                local animName = "givetake1_a"
                RequestAnimDict(animDict)
                while not HasAnimDictLoaded(animDict) do
                    Wait(100)
                end
                TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, 2000, 49, 0, false, false, false)

                -- Play animation for the player
                animDict = "mp_common"
                animName = "givetake1_b"
                RequestAnimDict(animDict)
                while not HasAnimDictLoaded(animDict) do
                    Wait(100)
                end
                TaskPlayAnim(PlayerPedId(), animDict, animName, 8.0, -8.0, 2000, 49, 0, false, false, false)

                Wait(2000)

                QBCore.Functions.Notify("You sold " .. quantity .. "x " .. item.label .. " for $" .. totalCost, "success")

                ClearPedTasksImmediately(ped)
                TaskStartScenarioInPlace(ped, pedConfig.scenario, 0, true)
            else
                QBCore.Functions.Notify("Error: Ped not found", "error")
            end
        else
            QBCore.Functions.Notify("You don't have enough " .. item.label, "error")
        end
    else
        print("Error: QBCore is not initialized")
    end
end)

function GetClosestPed(x, y, z)
    local peds = GetGamePool('CPed')
    local closestPed = nil
    local minDistance = 999999

    for _, ped in ipairs(peds) do
        local pedCoords = GetEntityCoords(ped)
        local distance = Vdist(x, y, z, pedCoords.x, pedCoords.y, pedCoords.z)
        if distance < minDistance then
            minDistance = distance
            closestPed = ped
        end
    end

    return closestPed
end
