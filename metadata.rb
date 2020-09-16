name             'osl-mysql'
issues_url       'https://github.com/osuosl-cookbooks/osl-mysql/issues'
source_url       'https://github.com/osuosl-cookbooks/osl-mysql'
maintainer       'Oregon State University'
maintainer_email 'systems@osuosl.org'
license          'Apache-2.0'
chef_version     '>= 15.0'
description      'Installs/Configures osl-mysql'
version          '2.7.0'

depends          'apache2', '< 8.2'
depends          'firewall'
depends          'git'
depends          'mariadb', '~> 4.1'
depends          'mysql', '~> 8.5.1'
depends          'osl-nrpe'
depends          'osl-munin'
depends          'osl-postfix'
depends          'percona', '~> 1.1.0'
depends          'yum-epel'

supports         'centos', '~> 6.0'
supports         'centos', '~> 7.0'
supports         'centos', '~> 8.0'
