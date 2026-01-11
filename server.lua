local ESX = exports['es_extended']:getSharedObject()

-- /setvehiclespeed <0-Config.MaxMultiplier>
ESX.RegisterCommand('setvehiclespeed', 'admin', function(xPlayer, args, showError)
        local multiplier = tonumber(args.multiplier)

        -- Überprüft ob multiplier eine Zahl ist
        if not multiplier then
            showError('Bitte einen gültigen Zahlenwert angeben.')
            return
        end

        -- Überprüft ob die angegebene Zahl im Wertebereich liegt
        if multiplier < 0 or multiplier > Config.MaxMultiplier then
            showError(('Bitte einen Wert zwischen 0 und %s angeben.'):format(Config.MaxMultiplier))
            return
        end

        TriggerClientEvent('vehicleSpeed:applyMultiplier', xPlayer.source, multiplier) -- Trigger das Event um die Fahrzeuggeschwindigkeit zu ändern

    end, false,
    {
        help = ('Setzt die Fahrzeugbeschleunigung (0-%s)'):format(Config.MaxMultiplier),
        arguments = {
            {
                name = 'multiplier',
                help = 'Beschleunigungs-Multiplikator (0 = Reset)',
                type = 'number'
            }
        } -- Schlägt den Command im Chat vor und definiert die args
    }
)
