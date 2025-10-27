local config = lib.loadJson('qbx_afk.config')

local loggedInPlayers = {}
local checkUser = {}
local previousPos = {}
local time = {}
local timeMinutes = {
    [900] = 'minutos',
    [600] = 'minutos',
    [300] = 'minutos',
    [150] = 'minutos',
    [60] = 'minutos',
    [30] = 'segundos',
    [20] = 'segundos',
    [10] = 'segundos'
}

local function updateCheckUser(source)
    local permissions = exports.qbx_core:GetPermission(source)

    for k in pairs(permissions) do
        if config.ignoreGroupsForAFK[k] then
            checkUser[source] = false
            return
        end
    end

    checkUser[source] = true
end

RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    loggedInPlayers[source] = true
    updateCheckUser(source)
end)

AddEventHandler('QBCore:Server:OnPlayerUnload', function(source)
    loggedInPlayers[source] = false
    checkUser[source] = false
end)

AddEventHandler('QBCore:Server:OnPermissionUpdate', function(source)
    updateCheckUser(source)
end)

---@TODO determine if lib.cron is better for this
CreateThread(function()
    for _, v in pairs(GetPlayers()) do
        v = tonumber(v)
        loggedInPlayers[v] = Player(v).state.isLoggedIn
        checkUser[v] = true
        if loggedInPlayers[v] then
            updateCheckUser(v)
        end
    end
    while true do
        Wait(1000)
        for _, v in pairs(GetPlayers()) do
            -- Events make source a number, GetPlayers() returns it as a string
            v = tonumber(v) --[[@as number]]

            if loggedInPlayers[v] and checkUser[v] then
                local playerPed = GetPlayerPed(v)
                local currentPos = GetEntityCoords(playerPed)
                if not time[v] then
                    time[v] = config.timeUntilAFKKick
                end

                if previousPos[v] and currentPos == previousPos[v] then
                    if time[v] > 0 then
                        local _type = timeMinutes[time[v]]
                        if _type == 'minutos' then
                            exports.qbx_core:Notify(v, 'Estás AFK y serás expulsado en ' .. math.ceil(time[v] / 60) .. ' minuto(s).', 'error', 10000)
                        elseif _type == 'segundos' then
                            exports.qbx_core:Notify(v, 'Estás AFK y serás expulsado en ' .. time[v] .. ' segundos.', 'error', 10000)
                        end
                        time[v] -= 1
                    else
                        DropPlayer(v --[[@as string]], 'Te han expulsado por estar AFK.')
                    end
                else
                    time[v] = config.timeUntilAFKKick
                end

                previousPos[v] = currentPos
            end
        end
    end
end)
