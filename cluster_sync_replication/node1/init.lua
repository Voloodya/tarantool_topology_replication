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

    -- Синхронная репликация
    replication_synchro_quorum = 2,
    replication_synchro_timeout = 3,
    -- мультиверсионный движок для хранения
    memtx_use_mvcc_engine = true,
    election_mode = 'off',
    election_timeout = 4,
}

box.once("schema", function()
   box.schema.user.create('rep', { password = 'pwd' })
   box.schema.user.grant('rep', 'replication') -- grant replication role
   box.schema.space.create("test")
   box.space.test:create_index("primary")
   print('box.once executed')
end)

box.schema.create_space('products', {is_sync= true})
box.space.products:create_index('pkey')

require('console').start()
os.exit()

-- box.space.products
-- box.space.products:put({1, 'one'})

-- error: The synchronous transaction queue doesn't belong to any instance

-- Признание инстанса Мастером
--box.ctl.promote()
---- box.space.products:put({1, 'one'})

--tarantool> box.space.products:put({2, 'one'})
---
--- error: Quorum collection for a synchronous transaction is timed out
--...
