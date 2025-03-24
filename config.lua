Config = {}

-- Webhook Settings
Config.webhookURL = "" -- Your Discord webhook URL
Config.WebhookColor = 16742144 -- Color for webhook messages (Orange)

-- Database Settings
Config.ItemByName = "gym_membership" -- Item name in shared items

Config.notify = "ox" -- notification system: "qb" or "ox"
Config.menu = "ox" -- menu system: "qb" or "ox" 
Config.input = "ox" -- input system: "qb" or "ox"
Config.DrawText = "ox" -- text display: "qb" or "ox"
Config.progressbar = "ox" -- progressbar: "qb" or "ox"
Config.MinPed = "target" -- interaction type: "target" or "DrawText"
Config.PaymentMethod = "cash" -- payment method: "cash" or "bank"
Config.debugPoly = false

Config.ownerjob = "gym" -- Job name for gym owner/manager

Config.GymBlip = {
    coords = vector3(-1255.44, -354.85, 35.96), -- إحداثيات الجيم
    sprite = 311,   -- أيقونة الـ Blip
    scale = 0.6,    -- حجم الـ Blip
    color = 16,     -- لون الـ Blip
    name = "Gym",   -- اسم الجيم على الخريطة
    shortRange = true -- هل يظهر فقط عند الاقتراب؟
}

Config.GymPed = {
    model = "a_m_y_musclbeac_01", -- موديل الـ Ped
    coords = vector4(-1255.44, -354.85, 35.96, 297.62) -- إحداثيات الـ Ped
}

Config.MembershipOptions = {
    {months = 1, price = 50},
    {months = 3, price = 135},
    {months = 6, price = 240},
    {months = 12, price = 420}
}

Config.GymZones = {
    {
        name = "treadmill",
        coords = vector3(-35.73, -1662.48, 29.48),
        width = 1.4,
        height = 1.0,
        heading = 320,
        minZ = 28.48,
        maxZ = 30.48,
        event = "qb-gym:client:runTreadmill",
        icon = "fa-solid fa-person-running",
        label = "Use Treadmill"
    },
    {
        name = "yoga",
        coords = vector3(-38.12, -1664.22, 29.48),
        width = 1.4,
        height = 1.0,
        heading = 320,
        minZ = 28.48,
        maxZ = 30.48,
        event = "qb-gym:client:StartYoga",
        icon = "fa-solid fa-person-praying",
        label = "Do Yoga"
    },
    {
        name = "weights",
        coords = vector3(-31.51, -1667.84, 29.48),
        width = 1.4,
        height = 1.0,
        heading = 320,
        minZ = 28.48,
        maxZ = 30.48,
        event = "qb-gym:client:StartPum",
        icon = "fa-solid fa-dumbbell",
        label = "Lift Weights"
    },
    {
        name = "pullup", 
        coords = vector3(-29.85, -1669.15, 29.48),
        width = 1.4,
        height = 1.0,
        heading = 320,
        minZ = 28.48,
        maxZ = 30.48,
        event = "qb-gym:client:StartPullups",
        icon = "fa-solid fa-arrow-up",
        label = "Do Pull-ups"
    }
}

Config.Exercises = {
    treadmill = {
        duration = 30000,
        animation = {
            dict = "move_m@jog@",
            name = "run",
            flag = 49
        },
        buffs = {
            {type = "stamina", duration = 300000, value = 1.5}
        },
        messages = {
            start = "Running on Treadmill...",
            success = "You feel more energetic after running! 🏃‍♂️",
            cancel = "You stopped running before completing the workout."
        }
    },
    yoga = {
        duration = 30000,
        animation = {
            dict = "amb@world_human_yoga@male@base",
            name = "base_a",
            flag = 1
        },
        buffs = {
            {type = "stress", duration = 300000, value = 5},
            {type = "health", duration = 100000, value = 2}
        },
        messages = {
            start = "Doing Yoga...",
            success = "You feel relaxed and refreshed after yoga!",
            cancel = "You stopped before completing the yoga session."
        }
    },
    weights = {
        duration = 30000,
        prop = {
            model = "prop_barbell_02",
            bone = 57005,
            offset = {x = 0.15, y = 0.0, z = -0.02},
            rotation = {x = 0.0, y = 270.0, z = 0.0}
        },
        animation = {
            dict = "amb@world_human_muscle_free_weights@male@barbell@base",
            name = "base",
            flag = 1
        },
        buffs = {
            {type = "health", duration = 200000, value = 5},
            {type = "stress", duration = 100000, value = 2}
        },
        messages = {
            start = "Pumping Weights...",
            success = "You feel stronger after pumping weights!",
            cancel = "You stopped before completing your workout."
        }
    },
    pullups = {
        duration = 30000,
        prop = {
            model = "prop_barbell_02",
            bone = 57005,
            offset = {x = 0.15, y = 0.0, z = -0.02},
            rotation = {x = 0.0, y = 270.0, z = 0.0}
        },
        animation = {
            dict = "amb@world_human_muscle_free_weights@male@barbell@base",
            name = "base",
            flag = 49
        },
        buffs = {
            {type = "health", duration = 250000, value = 5},
            {type = "stamina", duration = 300000, value = 1.5}
        },
        messages = {
            start = "Doing Pull-ups...",
            success = "You feel stronger after doing pull-ups!",
            cancel = "You stopped before completing your workout."
        }
    }
}






