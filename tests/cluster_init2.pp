# And here is a more complex example of building a mongo sharding cluster
# 4 nodes (3 of them config server) with 4 shards in replication.
node mongo_sharding_default {
  # Install MongoDB
  include mongodb

  # Install the MongoDB shard server
  mongodb::mongod { 'mongod_Shard1':
    mongod_instance => 'Shard1',
    mongod_port     => 27019,
    mongod_replSet  => 'Shard1',
    mongod_shardsvr => 'true'
  }

  mongodb::mongod { 'mongod_Shard2':
    mongod_instance => 'Shard2',
    mongod_port     => 27020,
    mongod_replSet  => 'Shard2',
    mongod_shardsvr => 'true'
  }

  mongodb::mongod { 'mongod_Shard3':
    mongod_instance => 'Shard3',
    mongod_port     => 27021,
    mongod_replSet  => 'Shard3',
    mongod_shardsvr => 'true'
  }

  mongodb::mongod { 'mongod_Shard4':
    mongod_instance => 'Shard4',
    mongod_port     => 27022,
    mongod_replSet  => 'Shard4',
    mongod_shardsvr => 'true'
  }

  # Install the MongoDB Loadbalancer server
  mongodb::mongos { 'mongos_shardproxy':
    mongos_instance      => 'mongoproxy',
    mongos_port          => 27017,
    mongos_configServers => 'mongo1.my.domain:27018,mongo2.my.domain:27018,mongo3.my.domain:27018'
  }
}

# This three nodes are shard members and run a mongoS
node 'mongo1.my.domain',
     'mongo2.my.domain',
     'mongo3.my.domain' inherits mongo_sharding_default {

  # Install the MongoDB config server
  include mongodb

  mongodb::mongod { 'mongod_config':
    mongod_instance  => 'shardproxy',
    mongod_port      => 27018,
    mongod_replSet   => '',
    mongod_configsvr => 'true'
  }
}

# This node is just a shard member
node 'mongo4.my.domain' inherits mongo_sharding_default { }
