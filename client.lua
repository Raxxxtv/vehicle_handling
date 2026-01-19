local ESX = exports['es_extended']:getSharedObject()

-- Capping the possible Numbers
local function clamp(value, min, max)
    return math.max(min, math.min(value, max))
end

local speedThreadId = 0 -- Sets First ThreadId
local lastVehicle = 0

local function changeVehicleSpeed(vehicle, multiplier) -- When this function gets called, it changes the Vehicle speed and resets it if it is already changed. It changes the Torque. The MaxSpeed chages if its enabled in the Config.
    if SpeedChanged then 
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
    SpeedChanged = true
    if vehicle == 0 then
        SpeedChanged = false
        return
    end
    -- Checks if the Vehicle speed is already changed
    if multiplier == 0 then 
        ESX.ShowNotification('Dein Fahrzeug wurde nicht verändert', 'error', 5000, 'Handlingystem')
        SpeedChanged = false
        return
    end

    local myThreadId = speedThreadId -- Changes the current ThreadId to the global ThreadId
    local mult = multiplier * 1.0
    -- Checks if the vehicle exists

    if Config.EnableMaxSpeedLimit then
        local maxSpeedMultiplier = multiplier * 0.04 + 1.0
        ModifyVehicleTopSpeed(vehicle, maxSpeedMultiplier) 
    end
    ESX.ShowNotification(('Fahrzeugbeschleunigung gesetzt: %sx'):format(multiplier), 'success', 5000, 'Handlingystem')

    CreateThread(function() -- Runs while speedThreadId matches myThreadId, resets SpeedChanged after thread ends
        while speedThreadId == myThreadId do
            SetVehicleCheatPowerIncrease(vehicle, mult)
            Wait(0)
        end
        SpeedChanged = false
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

CreateThread(function()
    while true do
        local ped = ESX.PlayerData.ped
        local vehicle = GetVehiclePedIsIn(ped)
        
        if vehicle ~= 0 and vehicle ~= lastVehicle then
            speedThreadId = speedThreadId + 1
            ModifyVehicleTopSpeed(vehicle, 1.0)
            lastVehicle = vehicle
        end
        Wait(500)
    end
end)