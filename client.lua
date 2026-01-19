local ESX = exports['es_extended']:getSharedObject()

-- Capping the possible Numbers
local function clamp(value, min, max)
    return math.max(min, math.min(value, max))
end

local speedThreadId = 0 -- Sets First ThreadId

local function changeVehicleSpeed(vehicle, multiplier) -- When this function gets called, it changes the Vehicle speed and resets it if it is already changed. It changes the Torque. The MaxSpeed chages if its enabled in the Config.
    if speedChanged then 
        if multiplier == 0 then
            speedThreadId = speedThreadId + 1

            if Config.EnableMaxSpeedLimit then
                ModifyVehicleTopSpeed(vehicle, 1)
            end
            

            ESX.ShowNotification('Fahrzeugbeschleunigung zurückgesetzt', 'success', 5000, 'Handlingystem')
        else
            ESX.ShowNotification('Das Fahrzeug ist bereits Modifiziert', 'success', 5000, 'Handlingystem')
        end
        return
    end
    speedChanged = true
    -- Checks if the Vehicle speed is already changed
    if multiplier == 0 then 
        ESX.ShowNotification('Dein Fahrzeug wurde nicht verändert', 'error', 5000, 'Handlingystem')
        return
    end
    local myThreadId = speedThreadId -- Changes the current ThreadId to the global ThreadId
    local mult = multiplier * 1.0
    -- Checks if the vehicle exists
    if vehicle == 0 then
        speedChanged = false
        return
    end

    if Config.EnableMaxSpeedLimit then
        local maxSpeedMultiplier = multiplier * 0.04 + 1.0
        ModifyVehicleTopSpeed(vehicle, maxSpeedMultiplier) 
    end
    ESX.ShowNotification(('Fahrzeugbeschleunigung gesetzt: %sx'):format(multiplier), 'success', 5000, 'Handlingystem')

    CreateThread(function() -- Runs the Code while speedThreadId has the same value as myThreadId and if not it sets speedChaged to false
        while speedThreadId == myThreadId do
            SetVehicleCheatPowerIncrease(vehicle, mult)
            Wait(0)
        end
        speedChanged = false
    end)
end


RegisterNetEvent('vehicleSpeed:applyMultiplier', function(multiplier) -- The Event that gets called in the server.lua. Checks if the vehicle exists and is already Changed and is clamping the multiplier. After that it calls the function to Change the speed of the Vehicle
    if not ESX.PlayerLoaded then return end
    local playerPed = ESX.PlayerData.ped

    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle == 0 then
        ESX.ShowNotification('Du befindest dich in keinem Fahrzeug', 'error', 5000, 'Handlingystem')
        return
    end

    multiplier = clamp(multiplier, 0, Config.MaxMultiplier)
    -- Checks if the player is on the Driver Seat
    if ESX.PlayerData.ped ~= GetPedInVehicleSeat(vehicle, -1) then 
        ESX.ShowNotification('Du befindest dich nicht auf dem Fahrersitz', 'error', 5000, 'Handlingystem')
        return 
    end

    changeVehicleSpeed(vehicle, multiplier)
end)

AddEventHandler('esx:enteredVehicle', function(vehicle, plate, seat, displayName, netId) -- Resets the Vehicle Torque and MaxSpeed when you enter a Vehicle
    speedThreadId = speedThreadId + 1
    ModifyVehicleTopSpeed(vehicle, 1)
end)
