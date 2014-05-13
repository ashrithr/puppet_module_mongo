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

# Shard server 1 - in replica set named 'rs1' listening on port 27018
node 'ip-10-198-70-37.us-west-1.compute.internal' inherits default {
  mongodb::mongod { 'mongo_shard1':
    mongod_instance => 'Shard1',
    mongod_replSet  => 'rs1',
    mongod_shardsvr => true,
    mongod_port     => 27018
  }
}

# Shard server 2 - in replica set 'rs1'
node 'ip-10-226-6-5.us-west-1.compute.internal' inherits default {
  mongodb::mongod { 'mongo_shard2':
    mongod_instance => 'Shard2',
    mongod_replSet  => 'rs1',
    mongod_shardsvr => true,
    mongod_port     => 27018
  }
}

# Shard server 1 - in replica set 'rs2'
node 'ip-10-229-11-72.us-west-1.compute.internal' inherits default {
  mongodb::mongod { 'mongo_shard1':
    mongod_instance => 'Shard1',
    mongod_replSet  => 'rs2',
    mongod_shardsvr => true,
    mongod_port     => 27018
  }
}

# Shard server 2 - in replica set 'rs2'
node 'ip-10-198-66-161.us-west-1.compute.internal' inherits default {
  mongodb::mongod { 'mongo_shard2':
    mongod_instance => 'Shard2',
    mongod_replSet  => 'rs2',
    mongod_shardsvr => true,
    mongod_port     => 27018
  }
}

# Config server
# arbiter node 1 - for replica set 'rs1'
# arbiter node 2 - for replica set 'rs2'
# Router
node 'ip-10-229-11-76.us-west-1.compute.internal' inherits default {
  mongodb::mongod { 'mongo_config1':
    mongod_instance  => 'Config1',
    mongod_configsvr => true,
    mongod_port      => 27019
  }

  ->

  # Sleep for 10 seconds for config server to come up
  exec { "/bin/sleep 10": }

  ->

  mongodb::mongos { 'mongos':
    mongos_instance => 'mongoproxy',
    mongos_port     => 27017,
    mongos_configServers => 'ip-10-229-11-76.us-west-1.compute.internal:27019'
  }

  mongodb::mongod { 'mongo_arbiter1':
    mongod_instance    => 'Arbiter1',
    mongod_replSet     => 'rs1',
    mongod_shardsvr    => true,
    mongod_port        => 30000,
    mongod_add_options => ['nojournal = true', 'smallfiles = true', 'noprealloc = true']
  }

  mongodb::mongod { 'mongo_arbiter2':
    mongod_instance    => 'Arbiter2',
    mongod_replSet     => 'rs2',
    mongod_shardsvr    => true,
    mongod_port        => 30001,
    mongod_add_options => ['nojournal = true', 'smallfiles = true', 'noprealloc = true']
  }
}

# Initialize replica set 1 (mongoShard1)
# From replica set member (ip-10-198-70-37.us-west-1.compute.internal) connect to mongo
# $mongo --port 27018
# > config = {
# >   _id : "rs1",
# >   members : [
# >     { _id : 0, host: "ip-10-198-70-37.us-west-1.compute.internal:27018" },
# >     { _id : 1, host: "ip-10-226-6-5.us-west-1.compute.internal:27018" },
# >     { _id : 2, host: "ip-10-229-11-76.us-west-1.compute.internal:30000", arbiterOnly : true },
# >   ]
# > }
# > rs.initiate(config)
# > rs.status()

# TODO: Initialize replica set 2 (mongoShard2)
# From replica set member (ip-10-229-11-72.us-west-1.compute.internal) connect to mongo
# $mongo --port 27018
# > config = {
# >   _id : "rs2",
# >   members : [
# >     { _id : 0, host: "ip-10-229-11-72.us-west-1.compute.internal:27018" },
# >     { _id : 1, host: "ip-10-198-66-161.us-west-1.compute.internal:27018" },
# >     { _id : 2, host: "ip-10-229-11-76.us-west-1.compute.internal:30001", arbiterOnly : true },
# >   ]
# > }
# > rs.initiate(config)
# > rs.status()

# TODO: Add shards to the cluster
# From mongos instance connect to mongo shell
# $ mongo
# > sh.addShard("rs1/ip-10-198-70-37.us-west-1.compute.internal:27018")
# > sh.addShard("rs2/ip-10-229-11-72.us-west-1.compute.internal:27018")

# Enable sharding for a database
# From mongos instance connect to mongo shell
# $ mongo
# > sh.enableSharding("<database>")

# Enable sharding for a collection
# From mongos instance connect to mongo shell
# $ mongo
# > sh.shardCollection("<database>.<collection>", shard-key-pattern)

# Ex: Enable sharding for a collection 'logEvents' using hashed key 'record_id'
# $ mongo
# > use logs
# > db.logEvents.ensureIndex( { "record_id": "hashed" } )
# > sh.shardCollection("logs.logEvents", { "record_id": "hashed" } )

# Ex: Enable sharding for a collection 'records.people' using 'zipcode' & 'name'
# $ mogno
# > sh.shardCollection("records.people", { "zipcode": 1, "name": 1 })
# The above shard key distributes documents by the value of the zipcode field.
# If a number of documents have the same value for this field, then that chunk
# will be splittable by the values of the name field.
