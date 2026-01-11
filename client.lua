local ESX = exports['es_extended']:getSharedObject()

-- Speichert originale MaxSpeed pro Fahrzeug
local originalMaxSpeed = {}

-- Mögliche Zahl begrenzen
local function clamp(value, min, max)
    return math.max(min, math.min(value, max))
end

local speedThreadId = 0 -- Setzt die ThreadId

local function changeVehicleSpeed(vehicle, multiplier)
    speedThreadId = speedThreadId + 1 -- Ändert die ThreadId um eins
    local myThreadId = speedThreadId -- Ändert die aktuelle ThreadId zur ThreadId die angegeben wurde (speedThreadId)

    local powerValue = clamp(multiplier * Config.PowerValueScale, 1.0, 1.8) -- Setzt Wert wenn unter 1 auf 1 und wenn über 1.8 auf 1.8, sonst bleibt er so wie er ist

    CreateThread(function()
        while speedThreadId == myThreadId do -- Führt den Code solange aus, wie speedThreadId die gleiche Zahl wie myThreadId hat
            SetVehicleCheatPowerIncrease(vehicle, powerValue) -- Ändert das Handling und die Geschwindigkeit des Fahrzeugs
            Wait(0)
        end
    end)
end

-- Vereinfachung für Notifys
local function notify(message, notifType, header)
    ESX.ShowNotification(message, notifType or 'info', 5000, header or 'System')
end

-- Funktion zum wiederherstellen vom Originalen Handling
local function resetVehicle(vehicle)
    if not DoesEntityExist(vehicle) then return end

    SetVehicleCheatPowerIncrease(vehicle, 1)
    speedThreadId = speedThreadId + 1

    if Config.EnableMaxSpeedLimit and originalMaxSpeed[vehicle] then
        SetVehicleMaxSpeed(vehicle, originalMaxSpeed[vehicle])
    end

    originalMaxSpeed[vehicle] = nil
end

RegisterNetEvent('vehicleSpeed:applyMultiplier', function(multiplier)

    -- Sicherstellen, dass der Spieler im Char ist
    if not ESX.IsPlayerLoaded() then return end

    multiplier = clamp(multiplier, 0, Config.MaxMultiplier)

    local playerPed = PlayerPedId()

    if not IsPedInAnyVehicle(playerPed, false) then
        notify('Du befindest dich in keinem Fahrzeug.', 'error', 'Handlingsystem')
        return
    end

    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if not DoesEntityExist(vehicle) then return end

    -- Originale MaxSpeed einmalig speichern
    if not originalMaxSpeed[vehicle] then
        originalMaxSpeed[vehicle] = GetVehicleEstimatedMaxSpeed(vehicle)
    end

    -- multiplier 0 = reset
    if multiplier == 0 then
        resetVehicle(vehicle)
        notify('Fahrzeugbeschleunigung zurückgesetzt.', 'success', 'Handlingsystem')
        return
    end
    changeVehicleSpeed(vehicle, multiplier)

    -- MaxSpeed-Anpassung
    if Config.EnableMaxSpeedLimit then
        local newMaxSpeed = originalMaxSpeed[vehicle] * (1.0 + multiplier * Config.MaxSpeedScale)
        SetVehicleMaxSpeed(vehicle, newMaxSpeed)
    end

    notify(('Fahrzeugbeschleunigung gesetzt: %sx'):format(multiplier), 'success', 'Handlingsystem')
end)

-- Beim Fahrzeugwechsel / Aussteigen
AddEventHandler('baseevents:leftVehicle', function(vehicle)
    resetVehicle(vehicle)
end)

-- Sicherheit: Reset bei Spieler-Tod
AddEventHandler('esx:onPlayerDeath', function()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        resetVehicle(GetVehiclePedIsIn(ped, false))
    end
end)
