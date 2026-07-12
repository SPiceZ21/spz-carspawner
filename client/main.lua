-- client/main.lua — ox_lib menu car spawner

RegisterKeyMapping("car", "Open Car Spawner", "keyboard", "F5")

RegisterNetEvent("SPZ:carspawner:openMenu", function()
    TriggerServerEvent("SPZ:carspawner:requestVehicles")
end)

RegisterNetEvent("SPZ:carspawner:receiveVehicles", function(vehicles)
    if not vehicles or #vehicles == 0 then
        lib.notify({ description = "No vehicles available", type = "error" })
        return
    end

    -- Group vehicles by class
    local byClass = {}
    for _, v in ipairs(vehicles) do
        local c = tostring(v.class or "Other")
        byClass[c] = byClass[c] or {}
        table.insert(byClass[c], v)
    end

    -- Register a sub-context per class
    local classes = {}
    for c, list in pairs(byClass) do
        table.sort(list, function(a, b) return a.label < b.label end)

        local options = {}
        for _, v in ipairs(list) do
            options[#options + 1] = {
                title       = v.label,
                description = v.model,
                icon        = "car",
                onSelect    = function()
                    TriggerServerEvent("SPZ:carspawner:spawnVehicle", v.model)
                end,
            }
        end

        local id = "carspawner_class_" .. c
        lib.registerContext({
            id      = id,
            title   = "Class " .. c,
            menu    = "carspawner_main",   -- back button → main menu
            options = options,
        })
        classes[#classes + 1] = { class = c, id = id, count = #list }
    end

    table.sort(classes, function(a, b) return a.class < b.class end)

    -- Main menu: list of classes
    local mainOptions = {}
    for _, ci in ipairs(classes) do
        mainOptions[#mainOptions + 1] = {
            title       = "Class " .. ci.class,
            description = ci.count .. (ci.count == 1 and " vehicle" or " vehicles"),
            icon        = "layer-group",
            arrow       = true,
            menu        = ci.id,
        }
    end

    lib.registerContext({
        id      = "carspawner_main",
        title   = "Car Spawner",
        options = mainOptions,
    })

    lib.showContext("carspawner_main")
end)
