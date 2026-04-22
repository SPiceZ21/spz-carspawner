-- client/main.lua

local isOpen = false

RegisterNetEvent("SPZ:carspawner:openMenu", function()
    if isOpen then return end
    
    -- Request vehicles from server
    TriggerServerEvent("SPZ:carspawner:requestVehicles")
end)

RegisterNetEvent("SPZ:carspawner:receiveVehicles", function(vehicles)
    isOpen = true
    SendNUIMessage({
        type = 'show',
        vehicles = vehicles
    })
    SetNuiFocus(true, true)
end)

RegisterNUICallback('spawnVehicle', function(data, cb)
    TriggerServerEvent("SPZ:carspawner:spawnVehicle", data.model)
    CloseMenu()
    cb('ok')
end)

RegisterNUICallback('close', function(data, cb)
    CloseMenu()
    cb('ok')
end)

function CloseMenu()
    isOpen = false
    SendNUIMessage({ type = 'hide' })
    SetNuiFocus(false, false)
end

-- Keybind to close (if focus fails)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isOpen then
            if IsControlJustReleased(0, 202) then -- ESC
                CloseMenu()
            end
        end
    end
end)
