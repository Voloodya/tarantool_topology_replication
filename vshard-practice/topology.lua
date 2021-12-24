return {
    bucket_count = 16,
    -- 1-ый реплика-сет
    sharding = {
        ['aaaaaaaa-0000-4000-a000-000000000000'] = { -- uid replica set
            replicas = { -- узлы
                ['aaaaaaaa-0000-4000-a000-000000000011'] = { -- uid nodes
                    name = 'moscow-storage',
                    master=true,
                    uri="sharding:pass@127.0.0.1:30011"
                },
                -- Добавим доп ужел для репликации
                ['aaaaaaaa-0000-4000-a000-000000000012'] = { -- uid nodes (резервирование). Узел для репликации
                    name='moscow-storage-rep',
                    uri="sharding:pass@127.0.0.1:30012"
                }
            }
        },
         -- Добавляем shard. 2-ой реплика-сет
        ['bbbbbbbb-0000-4000-a000-000000000000'] = { -- uid replica set
            replicas = { -- узлы
            ['bbbbbbbb-0000-4000-a000-000000000021'] = { -- uid nodes
                name='spb-storage',
                master=true,
                uri="sharding:pass@127.0.0.1:30021"
            },
            -- Добавим доп ужел для репликации
            ['bbbbbbbb-0000-4000-a000-000000000022'] = { -- uid nodes (резервирование). Узел для репликации
                name='spb-storage-rep',
                uri="sharding:pass@127.0.0.1:30022"
            },
        },
            --
            weight = 1,
        },
    },   
}