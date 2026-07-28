-- client/main.lua — Dynamic Car Spawner (ox_lib context menu)

RegisterKeyMapping("car", "Open Car Spawner", "keyboard", "F5")

-- Race classes only — no civilian / service / utility / prop vehicles.
local CLASS_NAMES = {
    [3]  = "Coupes",
    [4]  = "Muscle",
    [5]  = "Sports Classics",
    [6]  = "Sports",
    [7]  = "Super",
    [22] = "Open Wheel",
}

-- Whitelist mirrors CLASS_NAMES: only these GTA vehicle classes are spawnable.
local RACE_CLASSES = {}
for classId in pairs(CLASS_NAMES) do RACE_CLASSES[classId] = true end

local function FormatModelLabel(model)
    local hash = GetHashKey(model)
    local makeGxt = GetMakeNameFromVehicleModel(hash)
    local makeText = (makeGxt and makeGxt ~= "") and GetLabelText(makeGxt) or ""
    if makeText == "NULL" or makeText == "" then makeText = nil end

    local nameGxt = GetDisplayNameFromVehicleModel(hash)
    local nameText = (nameGxt and nameGxt ~= "") and GetLabelText(nameGxt) or ""
    if nameText == "NULL" or nameText == "" then nameText = nil end

    if makeText and nameText then
        return makeText .. " " .. nameText
    elseif nameText then
        return nameText
    else
        return model:sub(1,1):upper() .. model:sub(2)
    end
end

local function BuildVehicleList()
    local models = GetAllVehicleModels()
    local registered = {}

    local ok, reg = pcall(function()
        return exports["spz-vehicles"]:GetVehicleRegistry()
    end)
    if ok and type(reg) == "table" then
        registered = reg
    end

    local list = {}
    local seen = {}

    for _, rawModel in ipairs(models) do
        local model = rawModel:lower()
        if not seen[model] then
            seen[model] = true
            local hash = GetHashKey(model)

            if IsModelInCdimage(hash) and IsModelAVehicle(hash)
               and RACE_CLASSES[GetVehicleClassFromName(hash)] then
                local classId = GetVehicleClassFromName(hash)
                local regData = registered[model]

                local label
                if regData and regData.label then
                    label = regData.label
                else
                    label = FormatModelLabel(model)
                end

                local nameGxt = GetDisplayNameFromVehicleModel(hash)
                local isAddon = (not regData) and (GetLabelText(nameGxt) == "NULL")

                table.insert(list, {
                    model     = model,
                    label     = label,
                    classId   = classId,
                    className = CLASS_NAMES[classId] or "Other",
                    isAddon   = isAddon
                })
            end
        end
    end

    table.sort(list, function(a, b) return a.label:lower() < b.label:lower() end)
    return list
end

local function OpenCarSpawnerMenu()
    local vehicles = BuildVehicleList()
    if #vehicles == 0 then
        lib.notify({ description = "No vehicles found on server", type = "error" })
        return
    end

    local byClass = {}
    local addonCars = {}
    local allOptions = {}

    for _, v in ipairs(vehicles) do
        -- Group by class name
        local cName = v.className
        byClass[cName] = byClass[cName] or {}
        table.insert(byClass[cName], v)

        -- Track addon/mod cars
        if v.isAddon then
            table.insert(addonCars, v)
        end

        -- Search All option list
        table.insert(allOptions, {
            title       = v.label,
            description = "Model: " .. v.model .. (v.isAddon and " | Custom Mod" or (" | " .. v.className)),
            icon        = (v.classId == 8 or v.classId == 13) and "motorcycle" or "car",
            onSelect    = function()
                TriggerServerEvent("SPZ:carspawner:spawnVehicle", v.model)
            end,
        })
    end

    -- Register "Search All Vehicles" sub-menu
    lib.registerContext({
        id      = "carspawner_search_all",
        title   = "All Vehicles (" .. #vehicles .. ")",
        menu    = "carspawner_main",
        search  = true,
        options = allOptions,
    })

    -- Register "Custom Mod Cars" sub-menu if any streamed mod cars exist
    if #addonCars > 0 then
        local addonOptions = {}
        for _, v in ipairs(addonCars) do
            table.insert(addonOptions, {
                title       = v.label,
                description = "Model: " .. v.model .. " | " .. v.className,
                icon        = "car-side",
                onSelect    = function()
                    TriggerServerEvent("SPZ:carspawner:spawnVehicle", v.model)
                end,
            })
        end

        lib.registerContext({
            id      = "carspawner_mod_cars",
            title   = "Custom Mod Cars (" .. #addonCars .. ")",
            menu    = "carspawner_main",
            search  = true,
            options = addonOptions,
        })
    end

    -- Register a sub-menu for each class
    local classMenus = {}
    for cName, list in pairs(byClass) do
        local options = {}
        for _, v in ipairs(list) do
            table.insert(options, {
                title       = v.label,
                description = "Model: " .. v.model .. (v.isAddon and " | Custom Mod" or ""),
                icon        = (v.classId == 8 or v.classId == 13) and "motorcycle" or "car",
                onSelect    = function()
                    TriggerServerEvent("SPZ:carspawner:spawnVehicle", v.model)
                end,
            })
        end

        local menuId = "carspawner_class_" .. cName:gsub("%s+", "_"):lower()
        lib.registerContext({
            id      = menuId,
            title   = cName .. " (" .. #list .. ")",
            menu    = "carspawner_main",
            search  = true,
            options = options,
        })

        table.insert(classMenus, {
            name    = cName,
            id      = menuId,
            count   = #list,
            classId = list[1] and list[1].classId or 99
        })
    end

    table.sort(classMenus, function(a, b) return a.classId < b.classId end)

    -- Main Menu Options
    local mainOptions = {
        {
            title       = "🔍 Search All Vehicles",
            description = "Search all " .. #vehicles .. " vanilla & custom mod vehicles",
            icon        = "magnifying-glass",
            arrow       = true,
            menu        = "carspawner_search_all",
        },
        {
            title       = "✍️ Spawn by Model Name",
            description = "Type exact vehicle model ID to spawn",
            icon        = "keyboard",
            onSelect    = function()
                local input = lib.inputDialog("Spawn Vehicle", {
                    { type = "input", label = "Model Name", placeholder = "e.g. sultan, zentorno, gtr", required = true }
                })
                if input and input[1] and input[1] ~= "" then
                    local model = input[1]:lower():gsub("%s+", "")
                    TriggerServerEvent("SPZ:carspawner:spawnVehicle", model)
                end
            end
        }
    }

    if #addonCars > 0 then
        table.insert(mainOptions, 2, {
            title       = "⭐ Custom Mod Cars",
            description = #addonCars .. " streaming addon vehicles",
            icon        = "star",
            arrow       = true,
            menu        = "carspawner_mod_cars",
        })
    end

    table.insert(mainOptions, {
        title       = "────── Categories ──────",
        disabled    = true
    })

    for _, cm in ipairs(classMenus) do
        table.insert(mainOptions, {
            title       = cm.name,
            description = cm.count .. (cm.count == 1 and " vehicle" or " vehicles"),
            icon        = "layer-group",
            arrow       = true,
            menu        = cm.id,
        })
    end

    lib.registerContext({
        id      = "carspawner_main",
        title   = "🚗 Vehicle Spawner",
        options = mainOptions,
    })

    lib.showContext("carspawner_main")
end

RegisterNetEvent("SPZ:carspawner:openMenu", function()
    OpenCarSpawnerMenu()
end)
