-- Sistema de seguridad del teléfono (PIN y Face ID)
-- Código deobfuscado y limpiado

RegisterLegacyCallback("security:getIdentifier", function(src, cb)
    cb(GetIdentifier(src))
end)

BaseCallback("security:setPin", function(source, phoneNumber, newPin, oldPin)
    -- Validar que el PIN sea un string de 4 caracteres
    if type(newPin) ~= "string" or #newPin ~= 4 then
        debugprint("Failed to set pin: invalid type or length")
        return false
    end
    
    -- Actualizar el PIN en la base de datos
    local affected = MySQL.update.await(
        "UPDATE phone_phones SET pin = ? WHERE phone_number = ? AND (pin = ? OR pin IS NULL)",
        { newPin, phoneNumber, oldPin or "" }
    ) > 0
    
    debugprint("phone:security:setPin", GetPlayerName(source), affected, phoneNumber, newPin, oldPin)
    
    return affected
end, false)

BaseCallback("security:removePin", function(source, phoneNumber, pin)
    -- Validar que el PIN sea un string de 4 caracteres
    if type(pin) ~= "string" or #pin ~= 4 then
        debugprint("Failed to remove pin: invalid type or length")
        return false
    end
    
    -- Eliminar el PIN de la base de datos
    local affected = MySQL.update.await(
        "UPDATE phone_phones SET pin = NULL, face_id = NULL WHERE phone_number = ? AND (pin = ? OR pin IS NULL)",
        { phoneNumber, pin }
    ) > 0
    
    return affected
end, false)

BaseCallback("security:verifyPin", function(source, phoneNumber, pin)
    -- Validar que el PIN sea un string de 4 caracteres
    if type(pin) ~= "string" or #pin ~= 4 then
        debugprint("Failed to verify pin: invalid type or length")
        return false
    end
    
    -- Obtener el PIN de la base de datos
    local storedPin = MySQL.scalar.await(
        "SELECT pin FROM phone_phones WHERE phone_number = ?",
        { phoneNumber }
    )
    
    local isValid = storedPin == nil or storedPin == pin
    
    debugprint("phone:security:verifyPin", GetPlayerName(source), isValid, storedPin, pin)
    
    return isValid
end, false)

BaseCallback("security:enableFaceUnlock", function(source, phoneNumber, pin)
    -- Validar que el PIN sea un string de 4 caracteres
    if type(pin) ~= "string" or #pin ~= 4 then
        debugprint("Failed to enable face unlock: invalid type or length")
        return false
    end
    
    local identifier = GetIdentifier(source)
    
    -- Habilitar Face ID usando el identifier del jugador
    local affected = MySQL.update.await(
        "UPDATE phone_phones SET face_id = ? WHERE phone_number = ? AND pin = ?",
        { identifier, phoneNumber, pin }
    ) > 0
    
    return affected
end, false)

BaseCallback("security:disableFaceUnlock", function(source, phoneNumber, pin)
    -- Validar que el PIN sea un string de 4 caracteres
    if type(pin) ~= "string" or #pin ~= 4 then
        debugprint("Failed to disable face unlock: invalid type or length")
        return false
    end
    
    -- Deshabilitar Face ID
    return MySQL.update.await(
        "UPDATE phone_phones SET face_id = NULL WHERE phone_number = ? AND (pin = ? OR pin IS NULL)",
        { phoneNumber, pin }
    ) > 0
end, false)

BaseCallback("security:verifyFace", function(source, phoneNumber)
    local identifier = GetIdentifier(source)
    
    -- Obtener el face_id almacenado
    local storedFaceId = MySQL.scalar.await(
        "SELECT face_id FROM phone_phones WHERE phone_number = ?",
        { phoneNumber }
    )
    
    debugprint("phone:security:verifyFace", GetPlayerName(source), storedFaceId, identifier)
    
    -- Verificar si el identifier coincide
    return storedFaceId == identifier
end, false)

-- Función para resetear la seguridad de un teléfono
function ResetSecurity(phoneNumber)
    assert(type(phoneNumber) == "string", "Invalid argument #1 to ResetSecurity, expected string, got " .. type(phoneNumber))
    
    -- Eliminar PIN y Face ID
    MySQL.update.await(
        "UPDATE phone_phones SET pin = NULL, face_id = NULL WHERE phone_number = ?",
        { phoneNumber }
    )
    
    -- Notificar al cliente si está online
    local ownerSrc = GetSourceFromNumber(phoneNumber)
    if ownerSrc then
        TriggerClientEvent("phone:security:reset", ownerSrc, phoneNumber)
    end
end

-- Export para obtener el PIN de un teléfono
exports("GetPin", function(phoneNumber)
    assert(type(phoneNumber) == "string", "Invalid argument #1 to GetPin, expected string, got " .. type(phoneNumber))
    
    return MySQL.scalar.await(
        "SELECT pin FROM phone_phones WHERE phone_number = ?",
        { phoneNumber }
    )
end)

exports("ResetSecurity", ResetSecurity)
