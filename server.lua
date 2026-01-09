local ESX = exports['es_extended']:getSharedObject()

-- Command: /setvehiclespeed <0-10>
-- Hinweis: Ändert das Handling des Fahrzeuges dauerhaft (bis zum Despawn)
ESX.RegisterCommand('setvehiclespeed', 'admin', function(xPlayer, args, showError)
    local speedMultiplier = tonumber(args.multiplier)

    -- Prüfen ob wert kleiner als 0 oder größer als 10 ist
    if not speedMultiplier or speedMultiplier < 0 or speedMultiplier > 10 then
        showError('Bitte einen Wert zwischen 0 und 10 angeben.')
        return
    end

    -- Event aufrufen
    TriggerClientEvent('vehicleSpeed:applyMultiplier', xPlayer.source, speedMultiplier)
end, false, {
    help = 'Setzt die Fahrzeugbeschleunigung (0-10)',
    arguments = {
        { name = 'multiplier', help = 'Beschleunigungs-Multiplikator', type = 'number' }
    }
})
