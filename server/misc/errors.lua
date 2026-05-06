-- Sistema de logging de errores (limpiado y sin backdoors)
local errorCount = 0

RegisterNetEvent("phone:logError", function(message, stack, componentStack)
    -- Rate limiting: máximo 5 errores por minuto
    if errorCount >= 5 then
        return
    end
    
    errorCount = errorCount + 1
    
    SetTimeout(60000, function()
        errorCount = errorCount - 1
    end)
    
    -- Formatear el mensaje de error
    local formattedMessage = string.format(
        "**Message**: `%s`\n**Stack**:```%s```\n**Component Stack**:```%s```\n**Version**: `%s`",
        message or "Unknown error",
        (stack and stack:sub(1, 800)) or "No stack trace",
        (componentStack and componentStack:sub(1, 800)) or "No component stack",
        GetResourceMetadata(GetCurrentResourceName(), "version", 0) or "Unknown"
    )
    
    -- Solo log local, NO enviar a servidores externos
    print("^1[LB-PHONE ERROR]^7")
    print("^3Message:^7 " .. (message or "Unknown"))
    print("^3Stack:^7 " .. ((stack and stack:sub(1, 200)) or "No stack trace"))
    print("^3Component Stack:^7 " .. ((componentStack and componentStack:sub(1, 200)) or "No component stack"))
    print("^3Version:^7 " .. (GetResourceMetadata(GetCurrentResourceName(), "version", 0) or "Unknown"))
    
    -- Si el usuario quiere logging externo, debe configurarlo explícitamente en apiKeys.lua
    -- NO hay webhooks hardcodeados aquí
end)
