lib.onCache('vehicle', function(currentVehicle)
    if currentVehicle and currentVehicle ~= 0 then
        SetVehRadioStation(currentVehicle, "OFF")
        SetUserRadioControlEnabled(false)
    end
end)