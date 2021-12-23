--Запрос данных map/reduce
--vshard.router.routeall возвращает все репликасеты
--Функции роутера работают только на роутере
--replica:call* вызывает функцию на подходящей реплике

do
    -- Рассылка запросов по всем storage - реплика-сетам. Map
    local resultset = {}
    shards, err = vshard.router.routeall()
    if err ~= nil then
        print(err)
        return
    end
    ------------------------------------------------------------
    -- Сбор ответов в таблицу
    for uid, replica in pairs(shards) do
        local set = replica:callro('box.space.citizens:select')
        for _, citizen in ipairs(set) do
            table.insert(resultset, citizen)
        end
    end
    --------------------------------------------------------------
    -- Reduce
    table.sort(resultset, function(a, b) return a[1] < b[1] end)
    return resultset
end