--[[  
    🔧 Cloneref Fix Library  
    Этот скрипт добавляет поддержку cloneref для эксплойтов,
    где она отсутствует или реализована криво.
    
    ✅ Автоматически проверяет наличие getreg / debug.getregistry
    ✅ Находит InstanceList (список всех объектов Roblox)
    ✅ Создаёт кастомный cloneref
--]]

-- Проверяем, есть ли нормальный cloneref
if cloneref and type(cloneref) == "function" then
    warn("[Cloneref Fix] cloneref уже есть, патч не требуется")
    return
end

-- Создаём тестовый объект
local testPart = Instance.new("Part")

-- Получаем реестр
local registry = nil
if typeof(getreg) == "function" then
    registry = getreg()
elseif typeof(debug) == "table" and typeof(debug.getregistry) == "function" then
    registry = debug.getregistry()
end

-- Если реестра нет → значит эксплойт совсем кривой
if not registry then
    warn("[Cloneref Fix] Не удалось получить getreg/debug.getregistry")
    return
end

-- Ищем InstanceList
local InstanceList = nil
for _, tbl in pairs(registry) do
    if type(tbl) == "table" and #tbl > 0 then
        if rawget(tbl, "__mode") == "kvs" then
            for _, obj in pairs(tbl) do
                if obj == testPart then
                    InstanceList = tbl
                    break
                end
            end
        end
    end
    if InstanceList then break end
end

-- Если не нашли → выходим
if not InstanceList then
    warn("[Cloneref Fix] Не удалось найти InstanceList")
    return
end

-- Создаём кастомный cloneref
local function custom_cloneref(obj)
    if not obj then return nil end
    for k, v in pairs(InstanceList) do
        if v == obj then
            InstanceList[k] = nil
            return obj
        end
    end
    return obj
end

-- Записываем в глобалку
getgenv().cloneref = custom_cloneref

warn("[Cloneref Fix] cloneref успешно пропатчен!")
