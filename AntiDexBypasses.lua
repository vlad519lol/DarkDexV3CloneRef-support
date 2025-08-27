--[[  
    Universal Anti-Detection Patch (2025)
    🔥 Обновлённый набор обходов для самописных античитов Roblox
    🚫 Не защищает от Hyperion (Byfron), только от Lua-детектов в играх
--]]

task.spawn(function()
    repeat task.wait() until game:IsLoaded()

    local RunService = cloneref(game:GetService("RunService"))
    local Stats = cloneref(game:GetService("Stats"))
    local CoreGui = cloneref(game:GetService("CoreGui"))

    --// === 1. Обход debug.traceback / debug.info
    local oldTrace; oldTrace = hookfunction(debug.traceback, function(...)
        if not checkcaller() then
            return "" -- всегда пустая строка
        end
        return oldTrace(...)
    end)

    local oldInfo; oldInfo = hookfunction(debug.info, function(...)
        if not checkcaller() then
            return nil -- ломаем логику проверки
        end
        return oldInfo(...)
    end)

    --// === 2. Защита от проверок tostring/typeof
    local oldToString; oldToString = hookfunction(tostring, function(obj)
        if not checkcaller() then
            if type(obj) == "function" or type(obj) == "table" then
                return "function: 0x" .. string.format("%x", math.random(100000,999999))
            end
        end
        return oldToString(obj)
    end)

    local oldTypeof; oldTypeof = hookfunction(typeof, function(obj)
        if not checkcaller() then
            return type(obj)
        end
        return oldTypeof(obj)
    end)

    --// === 3. Защита от isexecutorclosure / iscclosure
    local oldExec; oldExec = hookfunction(getrenv().isexecutorclosure or getrenv().iscclosure, function(fn)
        if not checkcaller() then
            return false -- всегда говорим, что это обычная функция Roblox
        end
        return oldExec(fn)
    end)

    --// === 4. Скрытие UI от FindFirstChild / GetDescendants
    local HiddenUIs = {} -- сюда добавляй свои UI объекты

    local oldDesc; oldDesc = hookfunction(game.GetDescendants, function(self, ...)
        local results = oldDesc(self, ...)
        if not checkcaller() then
            for i,v in ipairs(HiddenUIs) do
                local idx = table.find(results, v)
                if idx then
                    table.remove(results, idx)
                end
            end
        end
        return results
    end)

    local oldFind; oldFind = hookfunction(game.FindFirstChild, function(self, name, recursive)
        local obj = oldFind(self, name, recursive)
        if not checkcaller() then
            if table.find(HiddenUIs, obj) then
                return nil
            end
        end
        return obj
    end)

    warn("[Bypass] Дополнительные обходы загружены (traceback, tostring, isexecutorclosure, UI)")
end)
