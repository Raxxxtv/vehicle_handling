local ESX = exports['es_extended']:getSharedObject()

local maxSpeed = {} -- Variable für die originale Maximal Geschwindigkeit definieren

-- Event vom Server empfangen
RegisterNetEvent('vehicleSpeed:applyMultiplier', function(multiplier)
    local playerPed = PlayerPedId()
    if not ESX.IsPlayerLoaded() then return end -- überprüfen ob der Spieler im Char eingeloggt ist
    -- Fehler, wenn der Spieler nicht im Fahrzeug ist
    if not IsPedInAnyVehicle(playerPed, false) then
        ESX.ShowNotification('Du befindest dich nicht in einem Fahrzeug', 'info', 5000, 'Handlingsystem')
        return
    end

    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if not DoesEntityExist(vehicle) then return end

    -- Passt die Motorleistung an
    if multiplier ~= 0 then
        if not maxSpeed[vehicle] then -- falls maxSpeed für das Fahrzeug noch nicht gesetzt wurde, wird es gesetzt
            maxSpeed[vehicle] = GetVehicleEstimatedMaxSpeed(vehicle)
        end
        SetVehicleCheatPowerIncrease(vehicle, multiplier)
        local newMaxSpeed = maxSpeed[vehicle] * (1.0 + multiplier * 0.2)
        SetVehicleMaxSpeed(vehicle, newMaxSpeed)
        SetVehicleEnginePowerMultiplier(vehicle, multiplier * 3.0)
        SetVehicleEngineTorqueMultiplier(vehicle, multiplier * 3.0)
    else -- Geschwindigkeit zurücksetzen
        if not maxSpeed[vehicle] then
            maxSpeed[vehicle] = GetVehicleEstimatedMaxSpeed(vehicle)
        end
        SetVehicleCheatPowerIncrease(vehicle, multiplier)
        SetVehicleMaxSpeed(vehicle, maxSpeed[vehicle])
        SetVehicleEnginePowerMultiplier(vehicle, multiplier)
        SetVehicleEngineTorqueMultiplier(vehicle, multiplier)
        maxSpeed[vehicle] = nil
    end
    ESX.ShowNotification(('Fahrzeugbeschleunigung gesetzt auf: %s'):format(multiplier), 'info', 5000, 'Handlingsystem')
end)
