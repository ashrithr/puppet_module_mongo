# == Define: mongodb::mongod
#
# Used to configure mongoD instances. You can setup multiple mongodb servers on
# the same node.
#
# === Parameters
# [*mongod_instance*]
#   Despription of mongd service (shard1, config, etc)  (required)
#
# [*mongod_bind_ip*]
#   Default is '' (empty string). So listen in all.
#
# [*mongod_port*]
#   Listen port (defaul: 27017)
#
# [*mongod_replSet*]
#   Name of ReplSet (optional)
#
# [*mongod_enable*]
#   Enable/Disable service at boot (default: true)
#
# [*mongod_running*]
#   Start/Stop service (default: true)
#
# [*mongod_configsvr*]
#   Is config server true/false (default: false)
#
# [*mongod_shardsvr*]
#   Is shard server true/false (default: false)
#
# [*mongod_logappend*]
#   Enable/Disable log file appending (default: true)
#
# [*mongod_rest*]
#   Enable/Disable REST api (default: false)
#
# [*mongod_fork*]
#   Enable/Disable fork of mongod process (default: true)
#
# [*mongod_auth*]
#   Enable/Disable auth true/false (default: false)
#
# [*mongod_useauth*]
#   Keyfile contents. Your random string/false (default: false)
#
# [*mongod_monit*]
#   Use monit monitoring for mongod instances (default: false)
#
# [*mongod_add_options*]
#   Array. Each field is "key" or "key=value" for parameters for config file
#
# === Examples
#
#   mongodb::mongod {
#     'my_mongod_instanceX':
#       mongod_instance    => 'mongodb1',
#       mongod_replSet     => 'mongoShard1',
#       mongod_add_options => ['fastsync = true','slowms = 50']
#   }
#
define mongodb::mongod (
  $mongod_instance = $name,
  $mongod_bind_ip = '',
  $mongod_port = 27017,
  $mongod_replSet = '',
  $mongod_enable = true,
  $mongod_running = true,
  $mongod_configsvr = false,
  $mongod_shardsvr = false,
  $mongod_logappend = true,
  $mongod_rest = false,
  $mongod_fork = true,
  $mongod_auth = false,
  $mongod_useauth = false,
  $mongod_monit = false,
  $mongod_add_options = []
) {
  file {
    "/etc/mongod_${mongod_instance}.conf":
        content => template('mongodb/mongod.conf.erb'),
        mode    => '0755',
        # no auto restart of a db because of a config change
        notify  => Service["mongod_${mongod_instance}"],
        require => Class['mongodb::install'];

    "/etc/init.d/mongod_${mongod_instance}":
        content => $::osfamily ? {
            debian => template('mongodb/debian_mongod-init.conf.erb'),
            redhat => template('mongodb/redhat_mongod-init.conf.erb'),
        },
        mode    => '0755',
        require => Class['mongodb::install'],
  }

  if ($mongod_monit != false){
    class { 'mongodb::monit':
        instance_name => $mongod_instance,
        instance_port => $mongod_port,
        require       => Anchor['mongodb::install::end'],
        before        => Anchor['mongodb::end'],
    }
  }

  if ($mongod_useauth != false){
    file { "/etc/mongod_${mongod_instance}.key":
        content => template('mongodb/mongod.key.erb'),
        mode    => '0700',
        owner   => $mongodb::params::run_as_user,
        require => Class['mongodb::install'],
        notify  => Service["mongod_${mongod_instance}"],
    }
  }

  service { "mongod_${mongod_instance}":
    ensure     => $mongod_running,
    enable     => $mongod_enable,
    hasstatus  => true,
    hasrestart => true,
    require    => [
                    File["/etc/mongod_${mongod_instance}.conf", "/etc/init.d/mongod_${mongod_instance}"],
                    Service[$::mongodb::params::old_servicename]
                  ],
    before => Anchor['mongodb::end']
  }
}
