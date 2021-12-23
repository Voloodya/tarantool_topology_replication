return {
    bucket_count = 16,
    -- 1-ый реплика-сет
    sharding = {
        ['aaaaaaaa-0000-4000-a000-000000000000'] = { -- uid nodes
            replicas = { -- узел
                ['aaaaaaaa-0000-4000-a000-000000000011'] = { -- uid replicas
                    name = 'moscow-storage',
                    master=true,
                    uri="sharding:pass@127.0.0.1:30011"
                },
            }
        },
         -- Добавляем shard. 2-ой реплика-сет
        ['bbbbbbbb-0000-4000-a000-000000000000'] = { -- uid nodes
            replicas = { -- узел
            ['bbbbbbbb-0000-4000-a000-000000000021'] = { -- uid replicas
                name='spb-storage',
                master=true,
                uri="sharding:pass@127.0.0.1:30021"
            },
        },
            --
            weight = 1,
        },
    },   
}