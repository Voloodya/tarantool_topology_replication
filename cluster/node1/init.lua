fiber = require 'fiber'
math.randomseed(fiber.time())

-- Тригер для разрешения конфликтов вставки данных с одинаковыми ключами при репликации
local my_space = 'test'
-- Функция детектирования конфликтов
local my_trigger = function(old, new, sp, op)
    -- old, new: data
    -- op:  operation ‘INSERT’, ‘DELETE’, ‘UPDATE’, or ‘REPLACE’
    if new == nil then
        print("No new during "..op, old)
        return -- deletes are ok
    end
    if old == nil then
        print("Insert new, no old", new)
        return new  -- insert without old value: ok
    end
    print(op.." duplicate", old, new)
    if op == 'INSERT' then
        -- Если есть старые и новые данные - конфликт
        if new[2] > old[2] then
             -- Creating new tuple will change op to REPLACE
            return box.tuple.new(new)
            -- -- or, custom afterwork:
            -- box.on_commit(function()
            --     print("Do something after")
            --     box.space[sp]:replace(new)
            -- end)
        end
        return old
    end
    if new[2] > old[2] then
        return new
    else
        return old
    end
    return
end

-- Встраивание функции в space
box.ctl.on_schema_init(function()
    box.space._space:on_replace(function(_, sp)
        if sp.name == my_space then
            box.on_commit(function()
                box.space[my_space]:before_replace(my_trigger)
            end)
        end
    end)
end)

-- box.cfg{ ... }
---------------------------------------------------------------------

box.cfg {
    listen = '127.0.0.1:3301', -- or 3302 for node2
    replication = {
        'rep:pwd@127.0.0.1:3301',
        'rep:pwd@127.0.0.1:3302',
    },
    -- Указываем количество реплик, которого достаточно для того, чтобы кластер считался норм функционирующим
    -- Здесь указываем чтобы он не ждал 2-го инстанса, т.к. там ещё может не успеть создаться пользователь
    replication_connect_quorum=1,
}

box.once("schema", function()
   box.schema.user.create('rep', { password = 'pwd' })
   box.schema.user.grant('rep', 'replication') -- grant replication role
   box.schema.space.create("test")
   box.space.test:create_index("primary")
   print('box.once executed')
end)

require('console').start() os.exit()

--Проверяем на обоих узлах, что репликация работает
--tarantool> box.info.vclock
--tarantool> box.info.replication

--Выполнить модифицирущую операцию на любом узле и убедиться, что данные реплицируются
-- fiber = require('fiber')
--box.space.test:insert({ os.time(), fiber.time(), "Hello, "..box.space.test:len(), math.random(1e9) })

--Мастер-мастер: конфликт
--Воспользуемся функцией, выравнивавющей время для имитации конфликтующих операций
--do
    --local now = fiber.time()
    --fiber.sleep( math.ceil( now / 10 ) * 10 - now )
    --return os.date("%H:%M:%S"), fiber.time()
--end
--do
    --local now = fiber.time()
    --fiber.sleep( math.ceil( now / 10 ) * 10 - now )
    --return os.date("%H:%M:%S"), fiber.time(),
        --box.space.test:insert({
            --math.floor(fiber.time()),
            --fiber.time(),
            --"Hello, "..box.space.test:len(),
           -- math.random(1e9)
        --})
--end

--Проверим, что репликация сломалась (box.info.replication -> status)
-- !!! Сломалась только репликация (она асинхронная), запись продолжается

--Перезапустим репликацию с автоматическим резолвингом конфликтов
--do
    --local r = box.cfg.replication;
    --box.cfg{ replication = {}; replication_skip_conflict = true; };
    --box.cfg{ replication = r }
--end

--box.space.test:select()

--Исправление вручную с помощью перезаписывающей операции replace
--box.space.test:put({1640171260, 1640171260.0004, 'Hello, 3', 363338097})

-- Триггер для решения конфликтов
-- Добавим на все инстансы перед вызовом box.cfg триггер для резолвинга конфликтов
-- Тригер для разрешения конфликтов вставки данных с одинаковыми ключами при репликации

--local my_space = 'test'
-- Функция детектирования конфликтов
--local my_trigger = function(old, new, sp, op)
   -- ...    
--end

-- Встраивание функции в space
--box.ctl.on_schema_init(function()
    -- ...
--end)

-- box.cfg{ ... }
---------------------------------------------------------------------

-- Перезапустим все инстансы и проверим, что конфликтующие операции не останавливают репликацию

--do
    --local now = fiber.time()
    --fiber.sleep( math.ceil( now / 10 ) * 10 - now )
    --return os.date("%H:%M:%S"), fiber.time(),
        --box.space.test:insert({
            --math.floor(fiber.time()),
            --fiber.time(),
            --"Hello, "..box.space.test:len(),
           -- math.random(1e9)
        --})
--end
