name             'osl-mysql'
issues_url       'https://github.com/osuosl-cookbooks/osl-mysql/issues'
source_url       'https://github.com/osuosl-cookbooks/osl-mysql'
maintainer       'Oregon State University'
maintainer_email 'systems@osuosl.org'
license          'Apache-2.0'
chef_version     '>= 16.0'
description      'Installs/Configures osl-mysql'
version          '6.10.0'

depends          'git'
depends          'mariadb', '~> 5.2.19'
depends          'mysql', '~> 11.0.5'
depends          'osl-firewall'
depends          'osl-nrpe'
depends          'osl-postfix'
depends          'osl-selinux'
depends          'percona', '~> 3.4.1'
depends          'yum-osuosl'

supports         'almalinux', '~> 8.0'
supports         'almalinux', '~> 9.0'
