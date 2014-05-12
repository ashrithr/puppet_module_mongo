# == Class: mongodb
#
# This class installs mongodb packages and makes basic install configurations.
# It does not configure any mongo services. This is done by defined type
# `mongodb::mongod` and `mongodb::mongos`.
#
# Most global parameters are set in params.pp and should fit the most use cases.
# But you can also set them, when including class mongodb.
#
# === Parameters
#
# [*dbdir*]
#   path where mongodb will store its data files. Default is '/var/lib'.
#
# [*pidfilepath*]
#   path where mongodb daemons will store the pid information. Default is
#   `dbdir`.
#
# [*logdir*]
#   path where mongodb will store the log files. Default is `/var/log/mongodb`.
#
# [*logrotatenumber*]
#   Number of days to keep the logfiles. Default is `7`.
#
# [*logrotate_package_manage*]
#   Says if this module should manage logrotate or not. Default is `true`.
#
# [*package_ensure*]
#   Here you can choose the version to be installed. Default is `installed`.
#
# [*repo_manage*]
#   Choose if this module should manage the repos needed to install the mongodb
#   packages. Default is `true`.
#
# [*ulimit_nofiles*]
#   Number of allowed filehandles. Default is `64000`.
#
# [*ulimit_nproc*]
#   Number of allowed process by user. Default is `32000` (integer).
#
# [*run_as_user*]
#   The user the mongod is run with. Default is 'mongod'.
#
# [*run_as_group*]
#   The group the mongod is run with. Default is 'mongod'.
#
# [*old_servicename*]
#   Name of the origin mongodb package service. his will be deactivated.
#   Default is 'mongod'.
#
# === Variables
#
# None
#
# === Requires
# puppetlabs-stdlib
# puppetlabs-apt
#
# === Sample Usage
#
#   include mongodb
#
#   (or)
#
#   class { 'mongodb':
#     run_as_user  => mongod,
#     run_as_group => wheel,
#     logdir       => '/nfsshare/mymongologs/'
#   }
#
class mongodb (
  $dbdir                    = $mongodb::params::dbdir,
  $pidfilepath              = $mongodb::params::pidfilepath,
  $logdir                   = $mongodb::params::logdir,
  $logrotatenumber          = $mongodb::params::logrotatenumber,
  $logrotate_package_manage = $mongodb::params::logrotate_package_manage,
  $package_ensure           = $mongodb::params::package_ensure,
  $repo_manage              = $mongodb::params::repo_manage,
  $ulimit_nofiles           = $mongodb::params::ulimit_nofiles,
  $ulimit_nproc             = $mongodb::params::ulimit_nproc,
  $run_as_user              = $mongodb::params::run_as_user,
  $run_as_group             = $mongodb::params::run_as_group,
  $old_servicename          = $mongodb::params::old_servicename
) inherits mongodb::params {

  anchor{ 'mongodb::begin':
    before => Anchor['mongodb::install::begin'],
  }

  anchor { 'mongodb::end': }

  # manage log rotation for mongod service
  class { 'mongodb::logrotate':
    package_manage => $logrotate_package_manage,
    require        => Anchor['mongodb::install::end'],
    before         => Anchor['mongodb::end'],
  }

  case $::osfamily {
    /(?i)(Debian|RedHat)/: {
      class { 'mongodb::install':
        repo_manage => $repo_manage
      }
    }
    default: {
      fail "Unsupported OS ${::operatingsystem} in 'mongodb' module"
    }
  }

  # stop and disable default mongod service, as puppet will manage different
  # mongod and mongos processes as configured
  service { [$::mongodb::params::old_servicename]:
    ensure     => stopped,
    enable     => false,
    hasstatus  => true,
    hasrestart => true,
    subscribe  => Package['mongodb-org'],
    before     => Anchor['mongodb::end'],
  }

  # replace the original startup script, because it would kill all mongod
  # instances and not only the default mongod
  file { "/etc/init.d/${::mongodb::params::old_servicename}":
    ensure  => file,
    content => template("${module_name}/replacement_mongod-init.conf.erb"),
    require => Service[$::mongodb::params::old_servicename],
    mode    => '0755',
    before  => Anchor['mongodb::end'],
  }

  # manage soft/hard open files limit and processes limit for mongodb user
  mongodb::limits::conf {
    'mongod-nofile-soft':
      type  => soft,
      item  => nofile,
      value => $mongodb::params::ulimit_nofiles;
    'mongod-nofile-hard':
      type  => hard,
      item  => nofile,
      value => $mongodb::params::ulimit_nofiles;
    'mongod-nproc-soft':
      type  => soft,
      item  => nproc,
      value => $mongodb::params::ulimit_nproc;
    'mongod-nproc-hard':
      type  => hard,
      item  => nproc,
      value => $mongodb::params::ulimit_nproc;
  }
}
