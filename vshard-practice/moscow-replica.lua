vshard = require('vshard')

local topology = require('topology')
local schema = require('schema')

vshard.storage.cfg(
    {
        bucket_count = topology.bucket_count,
        sharding     = topology.sharding,

        memtx_dir  = "moscow-storage-replica",
        wal_dir    = "moscow-storage-replica",
        replication_connect_quorum = 1,
    },
    'aaaaaaaa-0000-4000-a000-000000000012'
)

schema.init()

require 'console'.start()
os.exit()