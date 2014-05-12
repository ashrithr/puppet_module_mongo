# An example node configuration for mongodb module
#
# Configures 5 node cluster with 2 shards (2 replicas and 1 arbiter each),
# 1 config server and 1 router
#
node default {
  # Install mongodb packages
  class { 'mongodb':
    repo_manage => true,
    package_ensure => '2.6.1-2'
  }
}

# Shard server 1 - in replica set named 'mongoShard1' listening on port 27017
node 'ip-10-229-13-85.us-west-1.compute.internal' inherits default {
  mongodb::mongod { 'mongo_shard1':
    mongod_instance => 'Shard1',
    mongod_replSet  => 'mongoShard1',
    mongod_shardsvr => true,
    mongod_port     => 27018
  }
}

# Shard server 2 - in replica set 'mongoShard1'
node 'ip-10-199-65-50.us-west-1.compute.internal' inherits default {
  mongodb::mongod { 'mongo_shard2':
    mongod_instance => 'Shard2',
    mongod_replSet  => 'mongoShard1',
    mongod_shardsvr => true,
    mongod_port     => 27018
  }
}

# Shard server 1 - in replica set 'mongoShard2'
node 'ip-10-199-71-238.us-west-1.compute.internal' inherits default {
  mongodb::mongod { 'mongo_shard1':
    mongod_instance => 'Shard1',
    mongod_replSet  => 'mongoShard2',
    mongod_shardsvr => true,
    mongod_port     => 27018
  }
}

# Shard server 2 - in replica set 'mongoShard2'
node 'ip-10-229-12-112.us-west-1.compute.internal' inherits default {
  mongodb::mongod { 'mongo_shard2':
    mongod_instance => 'Shard2',
    mongod_replSet  => 'mongoShard2',
    mongod_shardsvr => true,
    mongod_port     => 27018
  }
}

# Config server
# arbiter node 1 - for replica set 'mongoShard1'
# arbiter node 2 - for replica set 'mongoShard2'
# Router
node 'ip-10-229-12-148.us-west-1.compute.internal' inherits default {
  mongodb::mongod { 'mongo_config1':
    mongod_instance  => 'mongoConfig1',
    mongod_configsvr => true,
    mongod_port      => 27019
  }

  ->

  mongodb::mongos { 'mongos':
    mongos_instance => 'mongoproxy',
    mongos_port     => 27017,
    mongos_configServers => 'ip-10-229-12-148.us-west-1.compute.internal:27018'
  }

  mongodb::mongod { 'mongo_arbiter1':
    mongod_instance    => 'mongoArbiter1',
    mongod_replSet     => 'mongoShard1',
    mongod_shardsvr    => true,
    mongod_port        => 30000,
    mongod_add_options => ['nojournal = true', 'smallfiles = true', 'noprealloc = true']
  }

  mongodb::mongod { 'mongo_arbiter2':
    mongod_instance    => 'mongoArbiter2',
    mongod_replSet     => 'mongoShard2',
    mongod_shardsvr    => true,
    mongod_port        => 30001,
    mongod_add_options => ['nojournal = true', 'smallfiles = true', 'noprealloc = true']
  }
}
