# == Define: mongodb::mongos
#
# Used to configure mongoS instances. You can setup multiple mongodb proxy
# servers on the same node. See the setup examples.
#
# === Parameters
# [*mongos_configServers*]
#   String with comma seperated list of config servers (optional)
#
# [*mongos_instance*]
#   Despription of mongd service (shard1, config, etc)  (required)
#
# [*mongos_bind_ip*]
#   Default is '' (empty string). So listen in all.
#
# [*mongos_port*]
#   Listen port (defaul: 27017)
#
# [*mongos_enable*]
#   Enable/Disable service at boot (default: true)
#
# [*mongos_logappend*]
#   Enable/Disable log file appending (default: true)
#
# [*mongos_fork*]
#   Enable/Disable fork of mongod process (default: true)
#
# [*mongos_auth*]
#   Enable/Disable auth true/false (default: false)
#
# [*mongos_useauth*]
#   Keyfile contents. Your random string/false (default: false)
#
# [*mongos_add_options*]
#   Array. Each field is "key" or "key=value" for parameters for config file
#
# === Examples
#
#   mongodb::mongos { 'mongos_shardproxy':
#     mongos_instance      => 'mongoproxy',
#     mongos_port          => 27017,
#     mongos_configServers => 'mongo1.my.domain:27018,mongo2.my.domain:27018,mongo3.my.domain:27018'
#   }
#
define mongodb::mongos (
  $mongos_configServers,
  $mongos_instance = $name,
  $mongos_bind_ip = '',
  $mongos_port = 27017,
  $mongos_service_manage = true,
  $mongos_enable = true,
  $mongos_running = true,
  $mongos_logappend = true,
  $mongos_fork = true,
  $mongos_auth = false,
  $mongos_useauth = false,
  $mongos_add_options = []
) {
  file {
    "/etc/mongos_${mongos_instance}.conf":
        content => template('mongodb/mongos.conf.erb'),
        mode    => '0755',
        notify  => Service["mongos_${mongos_instance}"],
        require => Class['mongodb::install'];
    "/etc/init.d/mongos_${mongos_instance}":
        content => $::osfamily ? {
            debian => template('mongodb/debian_mongos-init.conf.erb'),
            redhat => template('mongodb/redhat_mongos-init.conf.erb'),
        },
        mode    => '0755',
        require => Class['mongodb::install'],
  }

  if ($mongos_useauth != false){
    file { "/etc/mongos_${mongos_instance}.key":
      content => template('mongodb/mongos.key.erb'),
      mode    => '0700',
      owner   => $mongodb::params::run_as_user,
      require => Class['mongodb::install'],
      notify  => Service["mongos_${mongos_instance}"],
    }
  }

  if ($mongos_service_manage == true){
    service { "mongos_${mongos_instance}":
      ensure     => $mongos_running,
      enable     => $mongos_enable,
      hasstatus  => true,
      hasrestart => true,
      require    => [
                      File["/etc/mongos_${mongos_instance}.conf", "/etc/init.d/mongos_${mongos_instance}"],
                      Service[$::mongodb::params::old_servicename]
                    ],
      before => Anchor['mongodb::end']
    }
  }
}
