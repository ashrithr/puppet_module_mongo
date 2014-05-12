# == Class: mongodb::repo::yum
#
# Manages yum repository of mongodb
#
class mongodb::repos::yum {
  yumrepo { 'mongodb_yum_repo':
    descr         => '10gen MongoDB Repo',
    baseurl       => 'http://downloads-distro.mongodb.org/repo/redhat/os/$basearch',
    enabled       => 1,
    gpgcheck      => 0;
  }
}
