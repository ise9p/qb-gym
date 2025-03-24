local QBCore = exports['qb-core']:GetCoreObject()
local webhookURL = Config.webhookURL 

-- Function to send webhook messages
local function SendWebhook(title, message, color)
    if Config.webhookURL == "" then return end
    
    local embed = {
        {
            ["title"] = title,
            ["description"] = message,
            ["color"] = color or Config.WebhookColor,
            ["footer"] = {
                ["text"] = "Gym System • " .. os.date("%x %X %p"),
            },
        }
    }
    
    PerformHttpRequest(Config.webhookURL, function(err, text, headers) end, 'POST', json.encode({username = "Gym Logs", embeds = embed}), { ['Content-Type'] = 'application/json' })
end

--## CreateThread

CreateThread(function()
    while true do
        Wait(60000) 

        MySQL.query("SELECT * FROM gym_memberships WHERE expiry <= ?", { os.time() }, function(result)
            if result and #result > 0 then
                for _, membership in ipairs(result) do
                    local citizenid = membership.citizenid
                    local Player = QBCore.Functions.GetPlayerByCitizenId(citizenid)

                    if Player then
                        Player.Functions.RemoveItem(Config.ItemByName, 1)
                        TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, "Your gym membership has expired!", "error")
                    end

                    MySQL.query("DELETE FROM gym_memberships WHERE citizenid = ?", { citizenid })

                    SendToDiscord("> ❌ Gym Membership Expired",
                        "**CitizenID:** " .. citizenid .. "\n" ..
                        "**Phone:** " .. (membership.phone or "N/A") .. "\n" ..
                        "**Expiry Date:** " .. os.date("%Y-%m-%d %H:%M:%S", membership.expiry) .. "\n" ..
                        "**Action:** Membership Expired & Removed"
                    )
                end
            end
        end)
    end
end)

lib.callback.register('qb-gym:server:registerShop', function(source)
    return exports.ox_inventory:RegisterShop("GymShop", {
        name = "Gym Shop",
        inventory = {
            { name = 'water', price = 10 },
        }
    })
end)



--## Callback

QBCore.Functions.CreateCallback("qb-gym:server:getGymData", function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(0, nil) end

    local citizenid = Player.PlayerData.citizenid

    MySQL.query("SELECT amount FROM gym_funds WHERE id = 1", {}, function(fundsResult)
        local funds = (fundsResult and #fundsResult > 0) and fundsResult[1].amount or 0

        MySQL.query("SELECT * FROM gym_memberships WHERE citizenid = ? AND expiry > ?", { citizenid, os.time() }, function(membershipResult)
            local membership = nil

            if membershipResult and #membershipResult > 0 then
                membership = membershipResult[1]
                membership.expiryDate = os.date("%Y-%m-%d %H:%M:%S", membership.expiry) 
            end

            cb(funds, membership)
        end)
    end)
end)



--## Event

RegisterNetEvent("qb-gym:server:buyMembership", function(name, citizenid, phone, months, price, paymentMethod)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then return end

    if paymentMethod ~= "cash" and paymentMethod ~= "bank" then
        TriggerClientEvent('QBCore:Notify', src, "Invalid payment method!", "error")
        return
    end

    MySQL.query("SELECT * FROM gym_memberships WHERE citizenid = ? AND expiry > ?", { citizenid, os.time() }, function(result)
        if result and #result > 0 then
            TriggerClientEvent('QBCore:Notify', src, "You already have an active gym membership!", "error")
            return
        end

        local playerMoney = Player.Functions.GetMoney(paymentMethod)
        if playerMoney < price then
            TriggerClientEvent('QBCore:Notify', src, "You don't have enough money in your " .. paymentMethod .. "!", "error")
            return
        end

        local success = Player.Functions.RemoveMoney(paymentMethod, price, "gym-membership")
        
        if success then
            local expiryTime = os.time() + (months * 30 * 24 * 60 * 60)

            MySQL.insert("INSERT INTO gym_memberships (citizenid, phone, months, price, expiry) VALUES (?, ?, ?, ?, ?)", {
                citizenid,
                phone or "N/A",
                months,
                price,
                expiryTime
            }, function(insertId)
                if insertId then
                    Player.Functions.AddItem(Config.ItemByName, 1, nil, {
                        owner = name,
                        months = months,
                        expiry = expiryTime
                    })

                    MySQL.query("UPDATE gym_funds SET amount = amount + ? WHERE id = 1", { price })

                    SendToDiscord("> 🏋️ Gym Membership Purchase", 
                        "**Player:** " .. name .. "\n" ..
                        "**CitizenID:** " .. citizenid .. "\n" ..
                        "**Phone:** " .. phone .. "\n" ..
                        "**Months:** " .. months .. "\n" ..
                        "**Price:** $" .. price .. "\n" ..
                        "**Payment Method:** " .. paymentMethod .. "\n" ..
                        "**Expiry Date:** " .. os.date("%Y-%m-%d %H:%M:%S", expiryTime) .. "\n" ..
                        "**Gym Balance Updated!** 💰"
                    )

                    TriggerClientEvent('QBCore:Notify', src, "You purchased a " .. months .. "-month gym membership!", "success")
                else
                    TriggerClientEvent('QBCore:Notify', src, "Database error: Could not insert membership!", "error")
                    --print("^1[ERROR] Failed to insert gym membership for " .. citizenid .. "^0")
                end
            end)
        else
            TriggerClientEvent('QBCore:Notify', src, "Transaction failed. Try again!", "error")
        end
    end)
end)

RegisterNetEvent("qb-gym:server:extendMembership", function(months, price, currentExpiry)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then return end

    local citizenid = Player.PlayerData.citizenid
    local paymentMethod = Config.PaymentMethod 

    local playerMoney = Player.Functions.GetMoney(paymentMethod)
    if playerMoney < price then
        TriggerClientEvent('QBCore:Notify', src, "You don't have enough money in your " .. paymentMethod .. "!", "error")
        return
    end

    Player.Functions.RemoveMoney(paymentMethod, price, "gym-membership-extension")

    local newExpiry = currentExpiry + (months * 30 * 24 * 60 * 60)

    MySQL.query("UPDATE gym_memberships SET expiry = ? WHERE citizenid = ?", { newExpiry, citizenid })

    MySQL.query("UPDATE gym_funds SET amount = amount + ? WHERE id = 1", { price })

    TriggerClientEvent('QBCore:Notify', src, "Your membership has been extended for " .. months .. " months!", "success")

    SendToDiscord("> 🔄 Gym Membership Extended",
        "**Player:** " .. Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname .. "\n" ..
        "**CitizenID:** " .. citizenid .. "\n" ..
        "**Months Added:** " .. months .. "\n" ..
        "**New Expiry Date:** " .. os.date("%Y-%m-%d %H:%M:%S", newExpiry) .. "\n" ..
        "**Price Paid:** $" .. price .. "\n" ..
        "**Payment Method:** " .. paymentMethod .. "\n" ..
        "**Gym Balance Updated!** 💰"
    )
end)




RegisterNetEvent("qb-gym:server:withdrawFunds", function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then return end

    if Player.PlayerData.job.name ~= Config.ownerjob then
        TriggerClientEvent('QBCore:Notify', src, "You are not authorized to withdraw gym funds!", "error")
        return
    end

    MySQL.query("SELECT amount FROM gym_funds WHERE id = 1", {}, function(result)
        if result and #result > 0 then
            local funds = result[1].amount
            local withdrawAmount = tonumber(amount)

            if withdrawAmount and withdrawAmount > 0 and withdrawAmount <= funds then
                MySQL.query("UPDATE gym_funds SET amount = amount - ? WHERE id = 1", { withdrawAmount })

                Player.Functions.AddMoney("bank", withdrawAmount, "gym-fund-withdraw")

                TriggerClientEvent('QBCore:Notify', src, "You have withdrawn $" .. withdrawAmount .. " from the gym funds!", "success")

                SendToDiscord("> 💸 Gym Funds Withdrawal", 
                    "**Gym Owner:** " .. Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname .. "\n" ..
                    "**CitizenID:** " .. Player.PlayerData.citizenid .. "\n" ..
                    "**Amount Withdrawn:** $" .. withdrawAmount .. "\n" ..
                    "**Remaining Balance:** $" .. (funds - withdrawAmount)
                )
            else
                TriggerClientEvent('QBCore:Notify', src, "Invalid amount or insufficient funds!", "error")
            end
        else
            TriggerClientEvent('QBCore:Notify', src, "Error fetching gym funds. Contact an admin!", "error")
        end
    end)
end)


--## Logs Discord msg

function SendToDiscord(title, message)
    if not webhookURL or webhookURL == "" then
        --print("^1[ERROR] Discord Webhook URL is missing in Config!^0")
        return
    end

    local embedData = {
        {
            ["color"] = Config.WebhookColor or 16753920, 
            ["title"] = title,
            ["description"] = message,
            ["footer"] = {
                ["text"] = "Gym Membership System",
                ["icon_url"] = "https://i.imgur.com/your-icon.png" 
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }

    PerformHttpRequest(webhookURL, function(err, text, headers) 
        if err ~= 200 then
            -- print("^1[ERROR] Failed to send log to Discord. HTTP Error: " .. err .. "^0")
        end
    end, "POST", json.encode({ username = "Gym Logs", embeds = embedData }), { ["Content-Type"] = "application/json" })
end


--## start run

QBCore.Functions.CreateCallback("qb-gym:server:checkMembership", function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(false) end

    local citizenid = Player.PlayerData.citizenid

    MySQL.query("SELECT * FROM gym_memberships WHERE citizenid = ? AND expiry > ?", { citizenid, os.time() }, function(result)
        if result and #result > 0 then
            cb(true)
        else
            cb(false)
        end
    end)
end)

