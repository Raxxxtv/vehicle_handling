local ESX = exports['es_extended']:getSharedObject()

local speedChanged = false
local monitoringExit = false
local leftVehicleThread = false

-- Capping the possible Numbers
local function clamp(value, min, max)
    return math.max(min, math.min(value, max))
end

local speedThreadId = 0 -- Sets ThreadId

local function changeVehicleSpeed(vehicle, multiplier)
    if speedChanged then return end
    speedChanged = true
    -- Checks if the vehicle exists
    if not DoesEntityExist(vehicle) then 
        speedChanged = false
        return 
    end
    speedThreadId = speedThreadId + 1
    local myThreadId = speedThreadId -- Changes the current ThreadId to the global ThreadId

    local powerValue = clamp(multiplier * Config.PowerValueScale, 1.0, 1.8) -- Sets value to 1 if the value is under one and to 1.8 if the value is over 1.8, if its in the range, then the value stays the same

    CreateThread(function()
        while speedThreadId == myThreadId do -- Runs the Code while speedThreadId has the same value as myThreadId
            SetVehicleCheatPowerIncrease(vehicle, powerValue) -- Changes the handling of the vehicle
            Wait(0)
        end
        speedChanged = false
    end)
end

-- Resets the handling of the vehicle
local function resetVehicle(vehicle)
    if not DoesEntityExist(vehicle) then return end

    SetVehicleCheatPowerIncrease(vehicle, 1)
    speedThreadId = speedThreadId + 1

    monitoringExit = false

    if Config.EnableMaxSpeedLimit and speedChanged then
        ModifyVehicleTopSpeed(vehicle, 1) -- Resets the vehicle max speed
    end
    speedChanged = false

    ESX.ShowNotification('Fahrzeugbeschleunigung zurückgesetzt', 'success', 5000, 'Handlingystem')
end
-- Checks if the player left the vehicle
local function leftVehicle()
    if leftVehicleThread then return end
    leftVehicleThread = true
    CreateThread(function()
        local wasInVehicle = false
        local wasDriver = false
        local lastVehicle = nil

        while monitoringExit do
            local ped = ESX.PlayerData.ped
            local isInVehicle = IsPedInAnyVehicle(ped)

            if isInVehicle then
                local vehicle = GetVehiclePedIsIn(ped)
                lastVehicle = vehicle
                wasDriver = (GetPedInVehicleSeat(vehicle, -1) == ped)
                wasInVehicle = true
            else
                if wasInVehicle and wasDriver then
                    resetVehicle(lastVehicle)
                end

                wasInVehicle = false
                wasDriver = false
                lastVehicle = nil
            end
            Wait(200)
        end
        leftVehicleThread = false
    end)
end

RegisterNetEvent('vehicleSpeed:applyMultiplier', function(multiplier)

    -- Checks if the player is logged in his char
    if not ESX.PlayerLoaded then return end
    -- Checks if the handling was already changed and if multiplier equals 0. If the handling wasnt changed and the multiplier equals 0 then the player becomes an error.
    if not speedChanged and multiplier == 0 then
        ESX.ShowNotification('Dein Fahrzeug wurde nicht verändert', 'error', 5000, 'Handlingystem')
        return
    end

    multiplier = clamp(multiplier, 0, Config.MaxMultiplier)

    local playerPed = ESX.PlayerData.ped

    if not IsPedInAnyVehicle(playerPed) then
        ESX.ShowNotification('Du befindest dich in keinem Fahrzeug', 'error', 5000, 'Handlingystem')
        return
    end

    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if not DoesEntityExist(vehicle) then return end
    -- Checks if the player is on the Driver Seat
    if ESX.PlayerData.ped ~= GetPedInVehicleSeat(vehicle, -1) then 
        ESX.ShowNotification('Du befindest dich nicht auf dem Fahrersitz', 'error', 5000, 'Handlingystem')
        return 
    end

    -- multiplier 0 = reset
    if multiplier == 0 then
        resetVehicle(vehicle)
        return
    end
    changeVehicleSpeed(vehicle, multiplier)
    monitoringExit = true
    leftVehicle()

    -- changes the MaxSpeed
    if Config.EnableMaxSpeedLimit then
        local maxSpeedMultiplier = multiplier * 0.04 + 1.0
        ModifyVehicleTopSpeed(vehicle, maxSpeedMultiplier) -- Multiplies the vehicle max speed
    end

    ESX.ShowNotification(('Fahrzeugbeschleunigung gesetzt: %sx'):format(multiplier), 'success', 5000, 'Handlingystem')
end)

-- Gets Triggered if the player dies
AddEventHandler('esx:onPlayerDeath', function()
    local ped = ESX.PlayerData.ped
    if IsPedInAnyVehicle(ped) then
        local vehicle = GetVehiclePedIsIn(ped)
        local isDriver = (GetPedInVehicleSeat(vehicle, -1) == ped)
        if speedChanged and isDriver then
            resetVehicle(GetPlayersLastVehicle())
        end
    end
end)
