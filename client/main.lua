local QBCore = exports['qb-core']:GetCoreObject()

local function sendNotification(title, type)
    if Config.notify == "qb" then
        QBCore.Functions.Notify(title, type)
    elseif Config.notify == "ox" then
        lib.notify({
            title = title,
            type = type
        })
    end
end

Citizen.CreateThread(function()
    local blip = AddBlipForCoord(Config.GymBlip.coords.x, Config.GymBlip.coords.y, Config.GymBlip.coords.z)

    SetBlipSprite(blip, Config.GymBlip.sprite)  
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, Config.GymBlip.scale)  
    SetBlipColour(blip, Config.GymBlip.color)    
    SetBlipAsShortRange(blip, Config.GymBlip.shortRange)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.GymBlip.name) 
    EndTextCommandSetBlipName(blip)
end)

Citizen.CreateThread(function()
    RequestModel(GetHashKey(Config.GymPed.model))
    while not HasModelLoaded(GetHashKey(Config.GymPed.model)) do
        Wait(1)
    end

    local ped = CreatePed(4, GetHashKey(Config.GymPed.model), Config.GymPed.coords.x, Config.GymPed.coords.y, Config.GymPed.coords.z, Config.GymPed.coords.w, false, true)
    SetEntityAsMissionEntity(ped, true, true)
    SetPedDiesWhenInjured(ped, false)
    SetPedCanPlayAmbientAnims(ped, true)
    SetPedCanRagdollFromPlayerImpact(ped, false)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)


    if Config.MinPed == "target" then
        exports['qb-target']:AddTargetEntity(ped, {
            options = {
                {
                    type = "client",
                    event = "qb-gym:client:menu",
                    icon = "fa-solid fa-dumbbell",
                    label = "Interact With Gym Trainer",
                }
            },
            distance = 2.0
        })
    elseif Config.MinPed == "DrawText" then
        CreateThread(function()
            local displayed = false
    
            while true do
                local playerPed = PlayerPedId()
                local playerCoords = GetEntityCoords(playerPed)
                local distance = #(playerCoords - vector3(Config.GymPed.coords.x, Config.GymPed.coords.y, Config.GymPed.coords.z))
    
                if distance < 2.0 then
                    if not displayed then
                        if Config.DrawText == "qb" then
                            exports["qb-core"]:DrawText("[E] Interact With Gym Trainer", "left")
                        elseif Config.DrawText == "ox" then
                            lib.showTextUI("[E] Interact With Gym Trainer", { position = "left-center", icon = "fa-solid fa-dumbbell" })
                        end
                        displayed = true
                    end
    
                    if IsControlJustReleased(0, 38) then 
                        TriggerEvent("qb-gym:client:menu")
                    end
    
                    Wait(1) 
                else
                    if displayed then
                        if Config.DrawText == "qb" then
                            exports["qb-core"]:HideText()
                        elseif Config.DrawText == "ox" then
                            lib.hideTextUI()
                        end
                        displayed = false
                    end
                    Wait(500) 
                end
            end
        end)
    end    

    for _, zone in pairs(Config.GymZones) do
        exports['qb-target']:AddBoxZone(zone.name, zone.coords, zone.width, zone.height, {
            name = zone.name,
            heading = zone.heading,
            debugPoly = Config.debugPoly,
            minZ = zone.minZ,
            maxZ = zone.maxZ
        }, {
            options = {
                {
                    type = "client",
                    event = zone.event,
                    icon = zone.icon,
                    label = zone.label
                }
            },
            distance = 2.5
        })
    end
end)




RegisterNetEvent("qb-gym:client:menu")
AddEventHandler("qb-gym:client:menu", function()
    local player = QBCore.Functions.GetPlayerData()

    QBCore.Functions.TriggerCallback("qb-gym:server:getGymData", function(funds, membership)
        if Config.menu == "qb" then
            local menuOptions = {
                {
                    header = "Gym Menu",
                    icon = "fa-solid fa-dumbbell",
                    isMenuHeader = true
                }
            }

            if membership then
                table.insert(menuOptions, {
                    header = "Membership Status",
                    txt = "Active until: " .. membership.expiryDate,
                    icon = "fa-solid fa-id-card",
                    isMenuHeader = true
                })

                table.insert(menuOptions, {
                    header = "Extend Membership",
                    txt = "Extend your membership for more months",
                    icon = "fa-solid fa-calendar-plus",
                    params = { event = "qb-gym:client:extendMembership", args = { expiry = membership.expiry } }
                })
            else
                table.insert(menuOptions, {
                    header = "Buy Membership",
                    txt = "Purchase a membership to access all equipment",
                    icon = "fa-solid fa-credit-card",
                    params = { event = "qb-gym:client:buyMembership" }
                })
            end

            table.insert(menuOptions, {
                header = "Open Shop",
                txt = "Buy supplements and workout gear",
                icon = "fa-solid fa-cart-shopping",
                params = { event = "qb-gym:client:OpenShop" }
            })

            if player.job.name == Config.ownerjob then
                table.insert(menuOptions, {
                    header = "Withdraw Gym Funds",
                    txt = "Available Balance: $" .. funds,
                    icon = "fa-solid fa-money-bill-wave",
                    params = { event = "qb-gym:client:withdrawFunds" }
                })
            end

            table.insert(menuOptions, { header = "Close", icon = "fa-solid fa-times-circle", params = { event = "qb-menu:closeMenu" } })

            exports['qb-menu']:openMenu(menuOptions)

        elseif Config.menu == "ox" then
            local menu = {
                {
                    title = "Gym Menu",
                    icon = "fa-solid fa-dumbbell"
                }
            }

            if membership then
                table.insert(menu, {
                    title = "Membership Status",
                    description = "Active until: " .. membership.expiryDate,
                    icon = "fa-solid fa-id-card",
                })

                table.insert(menu, {
                    title = "Extend Membership",
                    description = "Extend your membership for more months",
                    icon = "fa-solid fa-calendar-plus",
                    onSelect = function()
                        TriggerEvent("qb-gym:client:extendMembership", { expiry = membership.expiry })
                    end
                })
            else
                table.insert(menu, {
                    title = "Buy Membership",
                    description = "Purchase a membership to access all equipment",
                    icon = "fa-solid fa-credit-card",
                    onSelect = function()
                        TriggerEvent("qb-gym:client:buyMembership")
                    end
                })
            end

            table.insert(menu, {
                title = "Open Shop",
                description = "Buy supplements and workout gear",
                icon = "fa-solid fa-cart-shopping",
                onSelect = function()
                    TriggerEvent("qb-gym:client:OpenShop")
                end
            })

            if player.job.name == Config.ownerjob then
                table.insert(menu, {
                    title = "Withdraw Gym Funds",
                    description = "Available Balance: $" .. funds,
                    icon = "fa-solid fa-money-bill-wave",
                    onSelect = function()
                        TriggerEvent("qb-gym:client:withdrawFunds")
                    end
                })
            end

            lib.registerContext({
                id = 'gym_menu',
                title = "Gym Menu",
                options = menu
            })
            lib.showContext('gym_menu')
        end
    end)
end)

RegisterNetEvent("qb-gym:client:extendMembership")
AddEventHandler("qb-gym:client:extendMembership", function(data)
    local currentExpiry = data.expiry
    
    if Config.menu == "qb" then
        local menuOptions = {
            {
                header = "Extend Membership",
                icon = "fa-solid fa-calendar-plus",
                isMenuHeader = true
            }
        }

        for _, option in ipairs(Config.MembershipOptions) do
            table.insert(menuOptions, {
                header = option.months .. " Months - $" .. option.price,
                txt = "Extend for " .. option.months .. " additional months",
                icon = "fa-solid fa-calendar-plus",
                params = {
                    event = "qb-gym:client:confirmExtension",
                    args = { months = option.months, price = option.price, expiry = currentExpiry }
                }
            })
        end

        table.insert(menuOptions, {
            header = "Cancel",
            icon = "fa-solid fa-times-circle",
            params = {
                event = "qb-menu:closeMenu"
            }
        })

        exports['qb-menu']:openMenu(menuOptions)
    
    elseif Config.menu == "ox" then
        local menu = {
            {
                title = "Extend Membership",
                icon = "fa-solid fa-calendar-plus"
            }
        }

        for _, option in ipairs(Config.MembershipOptions) do
            table.insert(menu, {
                title = option.months .. " Months - $" .. option.price,
                description = "Extend for " .. option.months .. " additional months",
                icon = "fa-solid fa-calendar-plus",
                onSelect = function()
                    TriggerEvent("qb-gym:client:confirmExtension", { months = option.months, price = option.price, expiry = currentExpiry })
                end
            })
        end

        table.insert(menu, {
            title = "Cancel",
            icon = "fa-solid fa-times-circle",
            onSelect = function()
                lib.hideContext()
            end
        })

        lib.registerContext({
            id = 'extend_membership_menu',
            title = "Extend Membership",
            options = menu
        })
        lib.showContext('extend_membership_menu')
    end
end)


RegisterNetEvent("qb-gym:client:confirmExtension")
AddEventHandler("qb-gym:client:confirmExtension", function(data)
    TriggerServerEvent("qb-gym:server:extendMembership", data.months, data.price, data.expiry)
end)


RegisterNetEvent("qb-gym:client:withdrawFunds")
AddEventHandler("qb-gym:client:withdrawFunds", function()
    if Config.input == "qb" then
        local amount = exports['qb-input']:ShowInput({
            header = "Withdraw Gym Funds",
            submitText = "Withdraw",
            inputs = {
                {
                    type = "number",
                    isRequired = true,
                    name = "amount",
                    text = "Enter Amount to Withdraw"
                }
            }
        })
    
        if amount then
            local withdrawAmount = tonumber(amount.amount)
            if withdrawAmount and withdrawAmount > 0 then
                TriggerServerEvent("qb-gym:server:withdrawFunds", withdrawAmount)
            else
                sendNotification("Invalid amount!", "error")
            end
        end
    elseif Config.input == "ox" then
        lib.inputDialog("Withdraw Gym Funds", {
            { type = "number", label = "Enter Amount to Withdraw", required = true }
        }, function(input)
            if input and input[1] then
                local withdrawAmount = tonumber(input[1])
                if withdrawAmount and withdrawAmount > 0 then
                    TriggerServerEvent("qb-gym:server:withdrawFunds", withdrawAmount)
                else
                    sendNotification("Invalid amount!", "error")
                end
            end
        end)
    end
end)


RegisterNetEvent("qb-gym:client:OpenShop", function()
    lib.callback('qb-gym:server:registerShop', false, function()
            exports.ox_inventory:openInventory('shop', { type = "GymShop" })
    end)
end)


RegisterNetEvent("qb-gym:client:buyMembership")
AddEventHandler("qb-gym:client:buyMembership", function()
    if Config.menu == "qb" then
        local menuOptions = {
            {
                header = "Select Membership Duration",
                icon = "fa-solid fa-calendar",
                isMenuHeader = true
            }
        }
        
        for _, option in ipairs(Config.MembershipOptions) do
            table.insert(menuOptions, {
                header = option.months .. " Months - $" .. option.price,
                txt = "Purchase a " .. option.months .. "-month membership",
                icon = "fa-solid fa-check",
                params = {
                    event = "qb-gym:client:confirmMembership",
                    args = { months = option.months, price = option.price }
                }
            })
        end
        
        table.insert(menuOptions, {
            header = "Cancel",
            icon = "fa-solid fa-ban",
            params = {
                event = "qb-menu:closeMenu"
            }
        })
        
        exports['qb-menu']:openMenu(menuOptions)
    
    elseif Config.menu == "ox" then
        local menu = {
            {
                title = "Select Membership Duration",
                icon = "fa-solid fa-calendar"
            }
        }

        for _, option in ipairs(Config.MembershipOptions) do
            table.insert(menu, {
                title = option.months .. " Months - $" .. option.price,
                description = "Purchase a " .. option.months .. "-month membership",
                icon = "fa-solid fa-check",
                onSelect = function()
                    TriggerEvent("qb-gym:client:confirmMembership", { months = option.months, price = option.price })
                end
            })
        end

        table.insert(menu, {
            title = "Cancel",
            icon = "fa-solid fa-ban",
            onSelect = function()
                lib.hideContext()
            end
        })

        lib.registerContext({
            id = 'buy_membership_menu',
            title = "Select Membership Duration",
            options = menu
        })
        lib.showContext('buy_membership_menu')
    end
end)


RegisterNetEvent("qb-gym:client:confirmMembership")
AddEventHandler("qb-gym:client:confirmMembership", function(data)
    local playerData = QBCore.Functions.GetPlayerData()
    local months = data.months
    local price = data.price
    local paymentMethod = Config.PaymentMethod

    local hasMoney = false

    if paymentMethod == "cash" and playerData.money.cash >= price then
        hasMoney = true
    elseif paymentMethod == "bank" and playerData.money.bank >= price then
        hasMoney = true
    end

    if hasMoney then
        if Config.menu == "qb" then
            exports['qb-menu']:openMenu({
                {
                    header = "Confirm Membership Purchase",
                    icon = "fa-solid fa-question-circle",
                    isMenuHeader = true
                },
                {
                    header = "Confirm Purchase",
                    txt = "Do you want to buy a gym membership for " .. months .. " months?\nTotal Price: $" .. price .. "\nPayment Method: " .. paymentMethod,
                    icon = "fa-solid fa-check",
                    params = {
                        event = "qb-gym:client:finalizeMembership",
                        args = { months = months, price = price, paymentMethod = paymentMethod }
                    }
                },
                {
                    header = "Cancel",
                    icon = "fa-solid fa-ban",
                    params = {
                        event = "qb-menu:closeMenu"
                    }
                }
            })
        elseif Config.menu == "ox" then
            local menu = {
                {
                    title = "Confirm Membership Purchase",
                    icon = "fa-solid fa-question-circle"
                },
                {
                    title = "Confirm Purchase",
                    description = "Do you want to buy a gym membership for " .. months .. " months?\nTotal Price: $" .. price .. "\nPayment Method: " .. paymentMethod,
                    icon = "fa-solid fa-check",
                    onSelect = function()
                        TriggerEvent("qb-gym:client:finalizeMembership", { months = months, price = price, paymentMethod = paymentMethod })
                    end
                },
                {
                    title = "Cancel",
                    icon = "fa-solid fa-ban",
                    onSelect = function()
                        lib.hideContext()
                    end
                }
            }
            
            lib.registerContext({
                id = 'confirm_membership_menu',
                title = "Confirm Membership Purchase",
                options = menu
            })
            lib.showContext('confirm_membership_menu')
        end
    else
        sendNotification("You don't have enough money in your " .. paymentMethod .. "!", "error", 5000)
    end
end)



RegisterNetEvent("qb-gym:client:finalizeMembership")
AddEventHandler("qb-gym:client:finalizeMembership", function(data)
    local playerData = QBCore.Functions.GetPlayerData()
    local months = data.months
    local price = data.price

    TriggerServerEvent("qb-gym:server:buyMembership", playerData.charinfo.firstname .. " " .. playerData.charinfo.lastname, playerData.citizenid, playerData.charinfo.phone, months, price, Config.PaymentMethod)
end)

function StartExercise(exerciseType)
    local playerPed = PlayerPedId()
    local exercise = Config.Exercises[exerciseType]

    if IsPedInAnyVehicle(playerPed, false) then
        sendNotification("You cannot exercise inside a vehicle!", "error")
        return
    end

    FreezeEntityPosition(playerPed, true)

    local prop = nil
    if exercise.prop then
        RequestModel(GetHashKey(exercise.prop.model))
        while not HasModelLoaded(GetHashKey(exercise.prop.model)) do
            Wait(100)
        end

        prop = CreateObject(GetHashKey(exercise.prop.model), GetEntityCoords(playerPed), true, true, false)
        AttachEntityToEntity(prop, playerPed, GetPedBoneIndex(playerPed, exercise.prop.bone), 
            exercise.prop.offset.x, exercise.prop.offset.y, exercise.prop.offset.z,
            exercise.prop.rotation.x, exercise.prop.rotation.y, exercise.prop.rotation.z,
            true, true, false, true, 1, true)
    end

    local function handleExerciseComplete(cancelled)
        ClearPedTasksImmediately(playerPed)
        FreezeEntityPosition(playerPed, false)

        if prop then DeleteEntity(prop) end

        if not cancelled then
            for _, buff in ipairs(exercise.buffs) do
                if buff.type == "stamina" then
                    exports['ps-buffs']:StaminaBuffEffect(buff.duration, buff.value)
                elseif buff.type == "stress" then
                    exports['ps-buffs']:AddStressBuff(buff.duration, buff.value)
                elseif buff.type == "health" then
                    exports['ps-buffs']:AddHealthBuff(buff.duration, buff.value)
                end
            end
            sendNotification(exercise.messages.success, "success")
        else
            sendNotification(exercise.messages.cancel, "error")
        end
    end

    if Config.progressbar == "qb" then
        exports['progressbar']:Progress({
            name = exerciseType .. "_exercise",
            duration = exercise.duration,
            label = exercise.messages.start,
            useWhileDead = false,
            canCancel = true,
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, handleExerciseComplete)
    elseif Config.progressbar == "ox" then
        if lib.progressBar({
            duration = exercise.duration,
            label = exercise.messages.start,
            useWhileDead = false,
            canCancel = true,
            disable = {
                move = true,
                car = true,
                mouse = false,
                combat = true
            },
            anim = {
                dict = exercise.animation.dict,
                clip = exercise.animation.name
            },
        }) then
            handleExerciseComplete(false)
        else
            handleExerciseComplete(true)
        end
        return -- ox progressbar handles the animation itself
    end

    RequestAnimDict(exercise.animation.dict)
    while not HasAnimDictLoaded(exercise.animation.dict) do
        Wait(100)
    end

    TaskPlayAnim(playerPed, exercise.animation.dict, exercise.animation.name, 8.0, -8, -1, exercise.animation.flag, 0, false, false, false)
end

RegisterNetEvent("qb-gym:client:runTreadmill")
AddEventHandler("qb-gym:client:runTreadmill", function()
    QBCore.Functions.TriggerCallback("qb-gym:server:checkMembership", function(hasMembership)
        if hasMembership then
            StartExercise("treadmill")
        else
            sendNotification("You need an active gym membership to use this equipment!", "error")
        end
    end)
end)

RegisterNetEvent("qb-gym:client:StartYoga")
AddEventHandler("qb-gym:client:StartYoga", function()
    QBCore.Functions.TriggerCallback("qb-gym:server:checkMembership", function(hasMembership)
        if hasMembership then
            StartExercise("yoga")
        else
            sendNotification("You need an active gym membership to do yoga!", "error")
        end
    end)
end)

RegisterNetEvent("qb-gym:client:StartPum")
AddEventHandler("qb-gym:client:StartPum", function()
    QBCore.Functions.TriggerCallback("qb-gym:server:checkMembership", function(hasMembership)
        if hasMembership then
            StartExercise("weights")
        else
            sendNotification("You need an active gym membership to use this equipment!", "error")
        end
    end)
end)

RegisterNetEvent("qb-gym:client:StartPullups")
AddEventHandler("qb-gym:client:StartPullups", function()
    QBCore.Functions.TriggerCallback("qb-gym:server:checkMembership", function(hasMembership)
        if hasMembership then
            StartExercise("pullups")
        else
            sendNotification("You need an active gym membership to do pull-ups!", "error")
        end
    end)
end)