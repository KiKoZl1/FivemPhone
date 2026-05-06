-- Sistema de notificaciones del teléfono
-- Código deobfuscado y limpiado

local disabledNotifications = Config.DisabledNotifications or {}

-- Función para enviar una notificación a un jugador o número de teléfono
function SendNotification(target, notification, cb)
    -- Verificar si las notificaciones están deshabilitadas para esta app
    if table.contains(disabledNotifications, notification.app) then
        if cb then
            cb(false)
        end
        debugprint("Notification are disabled for app", notification.app)
        return
    end
    
    -- Clonar la notificación para evitar modificaciones
    notification = table.clone(notification)
    
    -- Validar que la notificación tenga una app
    if type(notification) ~= "table" or not notification.app then
        if type(target) ~= "string" then
            if cb then
                cb(false)
            end
            debugprint("Invalid data or no app")
            return
        end
    end
    
    -- Validar longitud del contenido
    if notification.content and #notification.content > 500 then
        if cb then
            cb(false)
        end
        debugprint("Content too long")
        return
    end
    
    -- Determinar el source del jugador
    if type(target) == "number" then
        notification.source = target
    end
    
    -- Si el target es un número de teléfono, obtener el source
    if notification.app then
        if not notification.source then
            if type(target) == "string" then
                local source = GetSourceFromNumber(target)
                if source then
                    notification.source = source
                end
            end
        end
    end
    
    -- Si el target es un número de teléfono, guardar en la base de datos
    if notification.app and type(target) == "string" then
        -- Verificar límite de notificaciones
        if Config.MaxNotifications then
            local oldestId = MySQL.scalar.await(
                "SELECT id FROM phone_notifications WHERE phone_number = ? ORDER BY id DESC LIMIT ?, 1",
                { target, Config.MaxNotifications - 1 }
            )
            
            if oldestId then
                debugprint("Max notifications reached, deleting all older notifications", target, oldestId)
                MySQL.update.await(
                    "DELETE FROM phone_notifications WHERE phone_number = ? AND id <= ?",
                    { target, oldestId }
                )
            end
        end
        
        -- Insertar notificación en la base de datos
        local notificationId = MySQL.insert.await(
            "INSERT IGNORE INTO phone_notifications (phone_number, app, title, content, thumbnail, avatar, show_avatar, custom_data) VALUES (@phoneNumber, @app, @title, @content, @thumbnail, @avatar, @showAvatar, @data)",
            {
                ["@phoneNumber"] = target,
                ["@app"] = notification.app,
                ["@title"] = notification.title,
                ["@content"] = notification.content,
                ["@thumbnail"] = notification.thumbnail,
                ["@avatar"] = notification.avatar,
                ["@showAvatar"] = notification.showAvatar,
                ["@data"] = notification.customData and json.encode(notification.customData) or nil
            }
        )
        
        notification.id = notificationId
    end
    
    -- Enviar notificación al cliente si está online
    if notification.source then
        TriggerClientEvent("phone:sendNotification", notification.source, notification)
        debugprint("Sending notification to source: " .. notification.source)
    else
        debugprint("Couldn't find source, no notification printing")
    end
    
    if cb then
        cb(notification.id)
    end
end

exports("SendNotification", SendNotification)

-- Función para notificar a todos los jugadores (online o todos)
function NotifyEveryone(scope, notification)
    assert(scope == "all" or scope == "online", "Invalid notify")
    assert(type(notification.app) == "string", "Invalid app")
    assert(type(notification.title) == "string", "Invalid title")
    
    -- Verificar si las notificaciones están deshabilitadas
    if table.contains(disabledNotifications, notification.app) then
        debugprint("NotifyEveryone: Notification are disabled for app", notification.app)
        return
    end
    
    -- Si es "all", insertar en la base de datos para todos los teléfonos activos
    if scope == "all" then
        MySQL.insert(
            [[
                INSERT INTO phone_notifications
                    (phone_number, app, title, content, thumbnail, avatar, show_avatar)
                SELECT
                    phone_number, @app, @title, @content, @thumbnail, @avatar, @showAvatar
                FROM
                    phone_phones
                WHERE
                    last_seen > DATE_SUB(NOW(), INTERVAL 7 DAY)
            ]],
            {
                ["@app"] = notification.app,
                ["@title"] = notification.title,
                ["@content"] = notification.content,
                ["@thumbnail"] = notification.thumbnail,
                ["@avatar"] = notification.avatar,
                ["@showAvatar"] = notification.showAvatar
            }
        )
    end
    
    -- Enviar a todos los jugadores online
    TriggerClientEvent("phone:sendNotification", -1, notification)
end

exports("NotifyEveryone", NotifyEveryone)

-- Función para notificar a múltiples teléfonos basado en una query SQL
function NotifyPhones(query, whereClause, notification, params)
    -- Verificar si las notificaciones están deshabilitadas
    if table.contains(disabledNotifications, notification.app) then
        debugprint("NotifyPhones: Notification are disabled for app", notification.app)
        return
    end
    
    if not params then
        params = {}
    end
    
    if not whereClause then
        whereClause = ""
    end
    
    -- Preparar parámetros
    params["@app"] = notification.app
    params["@title"] = notification.title
    params["@content"] = notification.content
    params["@thumbnail"] = notification.thumbnail
    params["@avatar"] = notification.avatar
    params["@showAvatar"] = notification.showAvatar
    
    -- Construir query SQL
    local sql = string.format(
        [[
            INSERT INTO phone_notifications
                (phone_number, app, title, content, thumbnail, avatar, show_avatar)
            SELECT
                %sphone_number, @app, @title, @content, @thumbnail, @avatar, @showAvatar
            FROM
                %s
            RETURNING
                id, phone_number
        ]],
        whereClause,
        query
    )
    
    -- Ejecutar query y enviar notificaciones a jugadores online
    MySQL.query(sql, params, function(results)
        for i = 1, #results do
            local phoneNumber = results[i].phone_number
            local source = GetSourceFromNumber(phoneNumber)
            
            if source then
                notification.id = results[i].id
                TriggerClientEvent("phone:sendNotification", source, notification)
            end
        end
    end)
end

-- Función para enviar notificaciones de emergencia
function EmergencyNotification(source, data)
    assert(type(source) == "number", "Invalid source")
    assert(type(data) == "table", "Invalid data")
    
    SendNotification(source, {
        title = data.title or "Emergency Alert",
        content = data.content or "This is a test emergency alert.",
        icon = "./assets/img/icons/" .. (data.icon or "warning") .. ".png"
    })
end

exports("SendAmberAlert", EmergencyNotification)
exports("EmergencyNotification", EmergencyNotification)

-- Callback para obtener notificaciones
BaseCallback("getNotifications", function(source, phoneNumber, ...)
    return MySQL.query.await(
        "SELECT id, app, title, content, thumbnail, avatar, show_avatar AS showAvatar, custom_data, `timestamp` FROM phone_notifications WHERE phone_number=?",
        { phoneNumber }
    )
end, {})

-- Callback para eliminar una notificación
BaseCallback("deleteNotification", function(source, phoneNumber, notificationId)
    return MySQL.update.await(
        "DELETE FROM phone_notifications WHERE id=? AND phone_number=?",
        { notificationId, phoneNumber }
    ) > 0
end)

-- Callback para limpiar notificaciones de una app
BaseCallback("clearNotifications", function(source, phoneNumber, app)
    MySQL.update.await(
        "DELETE FROM phone_notifications WHERE phone_number=? AND app=?",
        { phoneNumber, app }
    )
    return true
end)
