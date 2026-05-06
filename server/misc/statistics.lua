-- Sistema de estadísticas (limpiado - tracking deshabilitado por defecto)
-- NOTA: Este archivo originalmente enviaba datos a track.lbscripts.com
-- Se ha deshabilitado el tracking automático por privacidad

local version = GetResourceMetadata(GetCurrentResourceName(), "version", 0) or "0.0.0"
local isCustomUI = GetResourceMetadata(GetCurrentResourceName(), "ui_page", 0) ~= "ui/dist/index.html"

-- Validar formato de versión
if not version:match("^%d+%.%d+%.%d+$") then
    version = "0.0.0"
end

-- Configuración de tracking (deshabilitado por defecto)
local TRACKING_ENABLED = false -- Cambiar a true solo si quieres habilitar tracking
local MAX_EVENTS_BATCH = 25
local VIDEO_EXTENSIONS = { "webm", "mp4", "mov" }

local eventCount = 0
local events = {}
local serverId = nil

-- Función para obtener el server ID (solo si tracking está habilitado)
local function GetServerId()
    if serverId then
        return serverId
    end
    
    if not TRACKING_ENABLED then
        return nil
    end
    
    local baseUrl = GetConvar("web_baseUrl", "")
    if baseUrl == "" then
        return nil
    end
    
    -- Extraer server ID del baseUrl
    local reversed = baseUrl:reverse()
    local dashPos = reversed:find("-")
    if not dashPos then
        dashPos = #baseUrl + 1
    end
    
    local startPos = #baseUrl - dashPos + 2
    local endPos = #baseUrl - #".users.cfx.re"
    
    serverId = string.sub(baseUrl, startPos, endPos)
    return serverId
end

-- Función para enviar eventos (solo si tracking está habilitado)
local function SendEvents(force)
    if not TRACKING_ENABLED then
        return
    end
    
    if not force and eventCount < MAX_EVENTS_BATCH then
        return
    end
    
    local sId = GetServerId()
    if not sId then
        return
    end
    
    local payload = json.encode({
        serverId = sId,
        version = version,
        events = events
    })
    
    eventCount = 0
    events = {}
    
    -- Solo enviar si está habilitado
    PerformHttpRequest("https://track.lbscripts.com/", function() end, "POST", payload, {
        ["Content-Type"] = "application/json"
    })
end

-- Función para trackear eventos simples
function TrackSimpleEvent(event)
    if isCustomUI or not TRACKING_ENABLED then
        return
    end
    
    eventCount = eventCount + 1
    events[eventCount] = {
        event = event
    }
    
    SendEvents()
end

-- Función para trackear posts de redes sociales
function TrackSocialMediaPost(app, files)
    if isCustomUI or not TRACKING_ENABLED then
        return
    end
    
    local videoCount = 0
    local photoCount = 0
    
    if files then
        for i = 1, #files do
            local ext = files[i]:match("%.([^.]+)$") or "webp"
            if table.contains(VIDEO_EXTENSIONS, ext) then
                videoCount = videoCount + 1
            else
                photoCount = photoCount + 1
            end
        end
    end
    
    eventCount = eventCount + 1
    events[eventCount] = {
        event = "social_media_post",
        app = app,
        amountVideos = videoCount,
        amountPhotos = photoCount
    }
    
    SendEvents()
end

-- Enviar eventos pendientes antes de reiniciar
AddEventHandler("txAdmin:events:scheduledRestart", function(data)
    if data.secondsRemaining == 60 then
        SendEvents(true)
    end
end)

AddEventHandler("txAdmin:events:serverShuttingDown", function()
    SendEvents(true)
end)

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        SendEvents(true)
    end
end)
