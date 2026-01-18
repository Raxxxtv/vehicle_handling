local ESX = exports['es_extended']:getSharedObject()

local speedChanged = false

-- Capping the possible Numbers
local function clamp(value, min, max)
    return math.max(min, math.min(value, max))
end

local speedThreadId = 0 -- Sets ThreadId

local function changeVehicleSpeed(vehicle, multiplier)
    if speedChanged then 
        if multiplier == 0 then
            speedThreadId = speedThreadId + 1

            if Config.EnableMaxSpeedLimit then
                ModifyVehicleTopSpeed(vehicle, 1) -- Resets the vehicle max speed
            end
            speedChanged = false

            ESX.ShowNotification('Fahrzeugbeschleunigung zurückgesetzt', 'success', 5000, 'Handlingystem')
        else
            ESX.ShowNotification('Das Fahrzeug ist bereits Modifiziert', 'success', 5000, 'Handlingystem')
        end
        return
    end
    speedChanged = true
    local myThreadId = speedThreadId -- Changes the current ThreadId to the global ThreadId
    local mult = multiplier * 1.0
    -- Checks if the vehicle exists
    if DoesEntityExist(vehicle) == 0 then
        speedChanged = false
        return
    end

    -- changes the MaxSpeed
    if Config.EnableMaxSpeedLimit then
        local maxSpeedMultiplier = multiplier * 0.04 + 1.0
        ModifyVehicleTopSpeed(vehicle, maxSpeedMultiplier) -- Multiplies the vehicle max speed
    end
    ESX.ShowNotification(('Fahrzeugbeschleunigung gesetzt: %sx'):format(multiplier), 'success', 5000, 'Handlingystem')

    CreateThread(function()
        while speedThreadId == myThreadId do -- Runs the Code while speedThreadId has the same value as myThreadId
            SetVehicleCheatPowerIncrease(vehicle, mult) -- Changes the handling of the vehicle
            Wait(0)
        end
        speedChanged = false
    end)
end


RegisterNetEvent('vehicleSpeed:applyMultiplier', function(multiplier)

    -- Checks if the player is logged in his char
    if not ESX.PlayerLoaded then return end
    local playerPed = ESX.PlayerData.ped

    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if DoesEntityExist(vehicle) == 0 then -- Checks if the player is in a Vehicle 
        ESX.ShowNotification('Du befindest dich in keinem Fahrzeug', 'error', 5000, 'Handlingystem')
        return
    end

    multiplier = clamp(multiplier, 0, Config.MaxMultiplier)
    -- Checks if the player is on the Driver Seat
    if ESX.PlayerData.ped ~= GetPedInVehicleSeat(vehicle, -1) then 
        ESX.ShowNotification('Du befindest dich nicht auf dem Fahrersitz', 'error', 5000, 'Handlingystem')
        return 
    end

    if multiplier == 0 and not speedChanged then -- Checks if the handling was already changed and if multiplier equals 0. If the handling wasnt changed and the multiplier equals 0 then the player becomes an error.
        ESX.ShowNotification('Dein Fahrzeug wurde nicht verändert', 'error', 5000, 'Handlingystem')
        return
    end

    changeVehicleSpeed(vehicle, multiplier)
end)

AddEventHandler('esx:enteredVehicle', function(vehicle, plate, seat, displayName, netId)
    speedChanged = false
    speedThreadId = speedThreadId + 1
    ModifyVehicleTopSpeed(vehicle, 1)
end)
