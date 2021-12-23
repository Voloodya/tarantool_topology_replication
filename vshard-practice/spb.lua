-- Точка входа. Вызвали фрамеворк передали конфигурацию
vshard = require('vshard')

-- Точка входа (инициализация storage). Вызвали у фрамеворка функцию конфигурирования передали конфигурацию узла
local topology = require('topology')
local schema = require('schema')

vshard.storage.cfg(
    {
        bucket_count = topology.bucket_count,
        sharding     = topology.sharding,

        memtx_dir  = "spb-storage",
        wal_dir    = "spb-storage",
        replication_connect_quorum = 1,
    },
    'bbbbbbbb-0000-4000-a000-000000000021' -- индификатор узла в топологии
)

-- Применение схемы
schema.init()

require 'console'.start()
os.exit()

--Посмотреть на обоих инстансах статус
--vshard.storage.info()

--Проверить, что таблица на питерском наполнилась

-- box.space.citizens:select()
--- непустой результат