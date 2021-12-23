vshard = require('vshard')
-- Точка входа (инициализация storage). Вызвали у фрамеворка функцию конфигурирования передали конфигурацию узла

local topology = require('topology')
local schema = require('schema')

vshard.storage.cfg(
    {
        bucket_count = topology.bucket_count,
        sharding     = topology.sharding,

        memtx_dir  = "moscow-storage",
        wal_dir    = "moscow-storage",
        replication_connect_quorum = 1,
    },
    'aaaaaaaa-0000-4000-a000-000000000011' -- индификатор узла в топологии
)

-- Применение схемы
schema.init()

-- Создание и запуск роутера. На практике запускается отдельным Тарантулом. Мы запустим на том же узле
-- Буутстрапит buckets on storage. Маршрутизирует по бакетам
vshard.router.cfg(topology) -- options: bucket_count + sharding
---------------------------------

require 'console'.start()
os.exit()

--Бутстрап
--В консоли московского хранилища
-- vshard.router.bootstrap()
--Результат бутстрапа
--true
--The cluster is balanced ok в логах

-- Просмотр бакетов
-- box.space._bucket:fselect()

-- Вставка данных через router

--log = require 'log'
--actors = {
    --{name = "Sean Connery", film = "Dr. No", year = "1962"},
   -- {name = "George Lazenby", film = "On Her Majesty's Secret Service", year = "1969"},
    --{name = "Roger Moore", film = "Live and Let Die", year = "1973"},
    --{name = "Timothy Dalton", film = "The Living Daylights", year = "1987"},
   -- {name = "Pierce Brosnan", film = "GoldenEye", year = "1995"},
   -- {name = "Daniel Craig", film = "Casino Royale", year = "2006"},
   -- {name = "Ana de Armas", film = "No Time to Die", year = "2020"},
   -- {name = "Matt Damon", film = "Jason Bourne", year = "2016"},
   -- {name = "Tom Cruise", film = "Mission: Impossible", year = "1996"},
   -- {name = "Keanu Reeves", film = "Matrix", year = "1999"},
   -- {name = "Uma Thurman", film = "Kill Bill", year = "2003"},
   -- {name = "Jackie Chan", film = "Armour of God", year = "1986"},
   -- {name = "Brad Pitt", film = "Mr. & Mrs. Smith", year = "2005"},
   -- {name = "Arnold Schwarzenegger", film = "The Terminator", year = "1984"},
   -- {name = "Jonny Lee Miller", film = "Hackers", year = "1995"},
   -- {name = "Steven Frederic Seagal", film = "Above the Law", year = "1988"},
--}

--for i, actor in pairs(actors) do
    --local bucket = i % 16 + 1
    -- Использование роутера для вставки: callrw - вызови функцию для чтения или записи на storege, на котором есть данный бакет
    --local _, err = vshard.router.callrw(
      --  bucket,
      --  'box.space.citizens:insert',
       -- {{
       --     i+10, bucket, actor.name,
       --     {film=actor.film, year = actor.year}
       -- }}
    --)
   -- if err then log.info(err) end
--end

--Посмотреть на обоих инстансах статус
--vshard.storage.info()
--vshard.router.info() --Запускается на самом первом/младшем узле

