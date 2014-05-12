# == Class: mongodb::install
#
# Manages mongo packages
#
class mongodb::install (
  $repo_manage     = true,
  $package_version = undef
) {
  anchor { 'mongodb::install::begin': }
  anchor { 'mongodb::install::end': }

  # manage 10gen repo or user does that for this module?
  if ($repo_manage == true) {
    include $::mongodb::params::repo_class
    $mongodb_10gen_package_require = [
      Anchor['mongodb::install::begin'],
      Class[$::mongodb::params::repo_class]
    ]
  } else {
    $mongodb_10gen_package_require = [
      Anchor['mongodb::install::begin']
    ]
  }

  if ($package_version == undef ) {
    $package_ensure = $::mongodb::package_ensure # default: installed
  } else {
    $package_ensure = "${package_version}"
  }

  package { 'mongodb-org':
    ensure  => $package_ensure,
    name    => $::mongodb::params::mongodb_pkg_name,
    require => $mongodb_10gen_package_require,
    before  => Anchor['mongodb::install::end']
  }
}
