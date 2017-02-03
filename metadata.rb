name             'osl-mysql'
issues_url       'https://github.com/osuosl-cookbooks/osl-mysql/issues'
source_url       'https://github.com/osuosl-cookbooks/osl-mysql'
maintainer       'Oregon State University'
maintainer_email 'systems@osuosl.org'
license          'Apache 2.0'
description      'Installs/Configures osl-mysql'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.6'

depends          'database'
depends          'firewall'
depends          'git'
depends          'mysql2_chef_gem'
depends          'osl-nrpe'
depends          'osl-munin'
depends          'percona'
depends          'sysctl'
depends          'yum'

supports         'centos', '~> 6.0'
supports         'centos', '~> 7.0'
