local ESX = exports['es_extended']:getSharedObject()

-- Event vom Server empfangen
RegisterNetEvent('vehicleSpeed:applyMultiplier', function(multiplier)
    local playerPed = PlayerPedId()

    -- Fehler, wenn der Spieler nicht im Fahrzeug ist
    if not IsPedInAnyVehicle(playerPed, false) then
        ESX.ShowNotification('Du befindest dich nicht in einem Fahrzeug', 'info', 5000, 'Handlingsystem')
        return
    end

    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if not DoesEntityExist(vehicle) then return end

    -- Passt die Motorleistung an
    SetVehicleEnginePowerMultiplier(vehicle, multiplier * 3.0)
    SetVehicleEngineTorqueMultiplier(vehicle, multiplier * 3.0)

    -- Handling an die Beschleunigung anpassen
    SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fInitialDriveForce', 0.35 + (multiplier * 0.02))
    SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fDriveInertia', 1.0 + (multiplier * 0.05))
    SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fTractionCurveMax', 2.5 + (multiplier * 0.1))
    SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fTractionCurveMin', 2.2 + (multiplier * 0.1))

    ESX.ShowNotification(('Fahrzeugbeschleunigung gesetzt auf: %s'):format(multiplier), 'info', 5000, 'Handlingsystem')
end)
