# An example node configuration for mongodb module
#
# Configures 5 node cluster with 2 shards (2 replicas and 1 arbiter each),
# 1 config server and 1 router
#
node default {
  # Install mongodb packages
  class { 'mongodb':
    repo_manage => true,
    package_ensure => '2.6.1'
  }
}

# Shard server 1 - in replica set named 'mongoShard1' listening on port 27017
node 'node1' inherits default {
  mongodb::mongod { 'mongo_shard1':
    mongod_instance => 'Shard1',
    mongod_replSet  => 'mongoShard1',
    mongod_shardsvr => true,
    mongod_port     => 27017
  }
}

# Shard server 2 - in replica set 'mongoShard1'
node 'node2' inherits default {
  mongodb::mongod { 'mongo_shard2':
    mongod_instance => 'Shard2',
    mongod_replSet  => 'mongoShard1',
    mongod_shardsvr => true,
    mongod_port     => 27017
  }
}

# Shard server 1 - in replica set 'mongoShard2'
node 'node3' inherits default {
  mongodb::mongod { 'mongo_shard1':
    mongod_instance => 'Shard1',
    mongod_replSet  => 'mongoShard2',
    mongod_shardsvr => true,
    mongod_port     => 27017
  }
}

# Shard server 2 - in replica set 'mongoShard2'
node 'node4' inherits default {
  mongodb::mongod { 'mongo_shard2':
    mongod_instance => 'Shard2',
    mongod_replSet  => 'mongoShard2',
    mongod_shardsvr => true,
    mongod_port     => 27017
  }
}

# Config server
# arbiter node 1 - for replica set 'mongoShard1'
# arbiter node 2 - for replica set 'mongoShard2'
node 'node5' inherits default {
  mongodb::mongod { 'mongo_config1':
    mongod_instance  => 'mongoConfig1',
    mongod_configsvr => true,
    mongod_port      => 27018
  }

  mongodb::mongod { 'mongo_arbiter1':
    mongod_instance    => 'mongoArbiter1',
    mongod_replSet     => 'mongoShard1',
    mongod_shardsvr    => true,
    mongod_port        => 30000,
    mongod_add_options => ['journal.enabled = false', 'smallFiles = true', 'preallocDataFiles = false']
  }

  mongodb::mongod { 'mongo_arbiter2':
    mongod_instance    => 'mongoArbiter2',
    mongod_replSet     => 'mongoShard2',
    mongod_shardsvr    => true,
    mongod_port        => 30001,
    mongod_add_options => ['journal.enabled = false', 'smallFiles = true', 'preallocDataFiles = false']
  }
}

# Mongo Router
node 'node6' inherits default {
  mongodb::mongos { 'mongos':
    mongos_instance => 'mongoproxy',
    mongos_port     => 27017,
    mongos_configServers => 'node1:'
  }
}
