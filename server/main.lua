-- server/main.lua

SPZ = SPZ or {}

--- Spawn vehicle request from client menu or command
RegisterNetEvent("SPZ:carspawner:spawnVehicle", function(model)
    local src = source
    if not model or type(model) ~= "string" then return end
    
    local modelLower = model:lower():gsub("%s+", "")
    if exports["spz-vehicles"]:IsRegistered(modelLower) then
        exports["spz-vehicles"]:SpawnVehicle(src, modelLower, "freeroam")
    else
        TriggerClientEvent('ox_lib:notify', src, { description = "Invalid model: " .. tostring(model), type = "error" })
    end
end)

--- Command to open menu or spawn directly by model name (/car or /car <model>)
RegisterCommand("car", function(source, args)
    if source == 0 then return end
    
    if not args[1] then
        TriggerClientEvent("SPZ:carspawner:openMenu", source)
    else
        local model = tostring(args[1]):lower():gsub("%s+", "")
        if exports["spz-vehicles"]:IsRegistered(model) then
            exports["spz-vehicles"]:SpawnVehicle(source, model, "freeroam")
        else
            TriggerClientEvent('ox_lib:notify', source, { description = "Invalid model: " .. model, type = "error" })
        end
    end
end, false)

--- Command to delete current vehicle (/dv)
RegisterCommand("dv", function(source)
    if source == 0 then return end
    exports["spz-vehicles"]:DespawnVehicle(source)
end, false)
