name             'osl-mysql'
issues_url       'https://github.com/osuosl-cookbooks/osl-mysql/issues'
source_url       'https://github.com/osuosl-cookbooks/osl-mysql'
maintainer       'Oregon State University'
maintainer_email 'systems@osuosl.org'
license          'Apache-2.0'
chef_version     '>=12.18' if respond_to?(:chef_version)
description      'Installs/Configures osl-mysql'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '2.0.3'

depends          'base'
depends          'database'
depends          'firewall'
depends          'git'
depends          'mysql', '~> 8.5.1'
depends          'mysql2_chef_gem'
depends          'osl-nrpe'
depends          'osl-munin'
depends          'osl-postfix'
depends          'percona', '~> 0.16.1'
depends          'sysctl'
depends          'yum'
depends          'yum-epel'
depends          'osl-postgresql'

supports         'centos', '~> 6.0'
supports         'centos', '~> 7.0'
