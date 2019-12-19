name             'osl-mysql'
issues_url       'https://github.com/osuosl-cookbooks/osl-mysql/issues'
source_url       'https://github.com/osuosl-cookbooks/osl-mysql'
maintainer       'Oregon State University'
maintainer_email 'systems@osuosl.org'
license          'Apache-2.0'
chef_version     '>= 14.0'
description      'Installs/Configures osl-mysql'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '2.2.3'

depends          'base'
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

supports         'centos', '~> 6.0'
supports         'centos', '~> 7.0'
