lib.onCache('vehicle', function(value, oldValue)
    local isMotorcycle = GetVehicleClass(value) == 8
    if not isMotorcycle then return end

    SetPedHelmet(cache.ped, false)
    RemovePedHelmet(cache.ped, true)
end)