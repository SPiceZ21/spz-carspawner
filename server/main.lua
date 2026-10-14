-- server/main.lua

SPZ = SPZ or {}

-- ── Race gate ─────────────────────────────────────────────────────────────────
--
-- Spawning or deleting a car mid-race puts the racer in a vehicle the race
-- engine never issued: the field desyncs, the old car is orphaned in the race
-- bucket, and the new one carries none of the race's handling or damage state.
--
-- The radial menu already hides these options while a route is running, but
-- hiding a button is presentation, not enforcement — /car and /dv are still
-- typeable, and the net event behind the menu is still callable by anything on
-- the client. The check has to live here, where the server can be sure.

local function RaceBlocked(src)
    local state = Player(src).state

    if state.inRace then return "You cannot do that during a race." end
    if state.inQueue then return "You cannot do that while queued for a race." end
    if state.inPursuit then return "You cannot do that during Hot Pursuit." end

    if GetResourceState('spz-races') == 'started' then
        local ok, inTrial = pcall(function()
            return exports['spz-races']:IsInTimeTrial(src)
        end)
        if ok and inTrial then return "You cannot do that during a time trial." end
    end

    return nil
end

local function Deny(src, reason)
    TriggerClientEvent('ox_lib:notify', src, {
        description = reason,
        type        = "error",
        position    = "center-left",
    })
end

--- Spawn vehicle request from client menu or command
RegisterNetEvent("SPZ:carspawner:spawnVehicle", function(model)
    local src = source
    if not model or type(model) ~= "string" then return end

    local blocked = RaceBlocked(src)
    if blocked then return Deny(src, blocked) end

    local modelLower = model:lower():gsub("%s+", "")
    if exports["spz-vehicles"]:IsRegistered(modelLower) then
        exports["spz-vehicles"]:SpawnVehicle(src, modelLower, "freeroam")
    else
        TriggerClientEvent('ox_lib:notify', src, { description = "Invalid model: " .. tostring(model), type = "error", position = "center-left" })
    end
end)

--- Command to open menu or spawn directly by model name (/car or /car <model>)
RegisterCommand("car", function(source, args)
    if source == 0 then return end

    local blocked = RaceBlocked(source)
    if blocked then return Deny(source, blocked) end

    if not args[1] then
        TriggerClientEvent("SPZ:carspawner:openMenu", source)
    else
        local model = tostring(args[1]):lower():gsub("%s+", "")
        if exports["spz-vehicles"]:IsRegistered(model) then
            exports["spz-vehicles"]:SpawnVehicle(source, model, "freeroam")
        else
            TriggerClientEvent('ox_lib:notify', source, { description = "Invalid model: " .. model, type = "error", position = "center-left" })
        end
    end
end, false)

--- Command to delete current vehicle (/dv)
RegisterCommand("dv", function(source)
    if source == 0 then return end

    local blocked = RaceBlocked(source)
    if blocked then return Deny(source, blocked) end

    exports["spz-vehicles"]:DespawnVehicle(source)
end, false)

-- ── Car photos ────────────────────────────────────────────────────────────────
-- Two sources, mapped automatically by model name (case-insensitive):
--   1. ui/img/<model>.png|webp|jpg  — drop files in, no list to maintain
--   2. uz_AutoShot shots/vehicles/<model>.<fmt> — in-game captures
-- Files whose name matches no car in the list are simply never used, and a car
-- with neither gets no image (the UI draws a placeholder).

local RES        = GetCurrentResourceName()
local SHOTS_RES  = 'uz_AutoShot'
local CACHE_MS   = 60 * 1000
local IMG_EXT    = { png = true, webp = true, jpg = true, jpeg = true }

local function listDir(dir)
    local cmd = package.config:sub(1, 1) == '\'
        and ('dir /b "%s" 2>nul'):format(dir:gsub('/', '\'))
        or  ('ls -1 "%s" 2>/dev/null'):format(dir)
    local out = {}
    local ok, p = pcall(io.popen, cmd)
    if not ok or not p then return out end
    for line in p:lines() do out[#out + 1] = line end
    p:close()
    return out
end

-- [lowercase model] = file name as it is on disk (Linux is case-sensitive)
local function scanFolder(dir)
    local map = {}
    for _, file in ipairs(listDir(dir)) do
        local base, ext = file:match('^(.+)%.([%w]+)$')
        if base and IMG_EXT[ext:lower()] then
            local key = base:lower()
            -- prefer png/webp over jpg if a model has several
            if not map[key] or ext:lower() ~= 'jpg' then map[key] = file end
        end
    end
    return map
end

local cache = { at = -CACHE_MS, own = {}, shots = {} }

local function imageMaps()
    local now = GetGameTimer()
    if now - cache.at < CACHE_MS then return cache end
    cache.at = now
    cache.own = scanFolder(GetResourcePath(RES) .. '/ui/img')
    cache.shots = {}
    if GetResourceState(SHOTS_RES) == 'started' then
        local path = GetResourcePath(SHOTS_RES)
        if path and path ~= '' then cache.shots = scanFolder(path .. '/shots/vehicles') end
    end
    return cache
end

-- model list in -> { [model] = url } for the ones that have an image
lib.callback.register('SPZ:carspawner:images', function(_, models)
    if type(models) ~= 'table' then return {} end
    local maps = imageMaps()
    local out = {}
    for i = 1, math.min(#models, 4000) do
        local m = tostring(models[i]):lower()
        local own = maps.own[m]
        if own then
            out[m] = ('img/%s'):format(own)                         -- relative to the NUI page
        elseif maps.shots[m] then
            out[m] = ('https://cfx-nui-%s/shots/vehicles/%s'):format(SHOTS_RES, maps.shots[m])
        end
    end
    return out
end)
