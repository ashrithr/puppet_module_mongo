#mongodb puppet module

Puppet module to install and manage mongodb. This module only manages
repos/packages/services/configuration files for mongodb. This module does not
manage internal sharding and replica set configurations.

##Dependencies
* puppetlabs-stdlib (`puppet module install puppetlabs-stdlib`)
* puppetlabs-apt (`puppet module install puppetlabs-apt`)

##Code Examples

Look in `tests` directory for example invocations.
