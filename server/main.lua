-- server/main.lua

SPZ = SPZ or {}

--- Get the vehicle registry from spz-vehicles and return it as a list
local function GetVehicleList()
    local registry = exports["spz-vehicles"]:GetVehicleRegistry()
    local list = {}
    for name, data in pairs(registry) do
        table.insert(list, {
            model = name,
            label = data.label or name,
            class = data.class
        })
    end
    
    -- Sort by label
    table.sort(list, function(a, b)
        return a.label < b.label
    end)
    
    return list
end

--- Register NUI Callback to get vehicles
RegisterNetEvent("SPZ:carspawner:requestVehicles", function()
    local src = source
    local vehicles = GetVehicleList()
    TriggerClientEvent("SPZ:carspawner:receiveVehicles", src, vehicles)
end)

--- Callback for NUI spawn
RegisterNetEvent("SPZ:carspawner:spawnVehicle", function(model)
    local src = source
    -- We could use spz-vehicles:SpawnVehicle here, 
    -- but the user asked for a "separate car spawner script".
    -- However, using the existing framework ensures upgrades/customization work.
    -- If we want it truly separate, we'd trigger a client event to spawn.
    -- I'll use the existing one to ensure compatibility with the SPZ core systems.
    
    if exports["spz-vehicles"]:IsRegistered(model) then
        exports["spz-vehicles"]:SpawnVehicle(src, model, "freeroam")
    else
        print(("^1[spz-carspawner] Model %s is not registered!^7"):format(model))
    end
end)

--- Command to spawn via name
RegisterCommand("car", function(source, args)
    if source == 0 then return end
    
    if not args[1] then
        -- Open NUI
        TriggerClientEvent("SPZ:carspawner:openMenu", source)
    else
        local model = args[1]
        if exports["spz-vehicles"]:IsRegistered(model) then
            exports["spz-vehicles"]:SpawnVehicle(source, model, "freeroam")
        else
            TriggerClientEvent("spz-lib:Notify", source, "Invalid model: " .. model, "error")
        end
    end
end, false)

--- Command to delete vehicle
RegisterCommand("dv", function(source)
    if source == 0 then return end
    exports["spz-vehicles"]:DespawnVehicle(source)
end, false)
