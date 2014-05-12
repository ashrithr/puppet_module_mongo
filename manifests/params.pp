# == Class: mongodb::params
#
# Global parameters for the module
#
class mongodb::params {
  $repo_class = $::osfamily ? {
    redhat => 'mongodb::repos::yum',
    debian => 'mongodb::repos::apt',
  }

  $mongodb_pkg_name = 'mongodb-org'

  $mongodb_add_pkgs = [
    'mongodb-org-mongos',
    'mongodb-org-server',
    'mongodb-org-shell',
    'mongodb-org-tools'
  ]

  $old_servicename = 'mongod'

  $run_as_user = 'mongod'

  $run_as_group 'mongod'

  # directorypath to store db directory in
  # subdirectories for each mongo instance will be created
  $dbdir = '/var/lib'

  # numbers of files (days) to keep by logrotate
  $logrotatenumber = 7

  # package version (2.6.1) / installed (installs latest version) / absent (removes package)
  $package_ensure = 'installed'

  # should this module manage the mongodb repository from upstream?
  $repo_manage = true

  # should this module manage the logrotate package?
  $logrotate_package_manage = true

  # directory for mongo logfiles
  $logdir = '/var/log/mongodb'

  # specify ulimit - nofile = 64000 and nproc = 64000 is recommended setting from
  # http://docs.mongodb.org/manual/reference/ulimit/#recommended-settings
  $ulimit_nofiles = 64000
  $ulimit_nproc   = 64000

  # specify pidfilepath
  $pidfilepath = $dbdir
}
