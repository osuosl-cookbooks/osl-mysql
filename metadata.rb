name             'osl-mysql'
issues_url       'https://github.com/osuosl-cookbooks/osl-mysql/issues'
source_url       'https://github.com/osuosl-cookbooks/osl-mysql'
maintainer       'Oregon State University'
maintainer_email 'systems@osuosl.org'
license          'Apache-2.0'
chef_version     '>= 16.0'
description      'Installs/Configures osl-mysql'
version          '5.1.0'

depends          'git'
depends          'mariadb', '~> 4.1'
depends          'mysql', '~> 8.5.1'
depends          'osl-firewall'
depends          'osl-nrpe'
depends          'osl-postfix'
depends          'osl-selinux'
depends          'percona', '~> 2.1.0'

supports         'centos', '~> 7.0'
supports         'centos', '~> 8.0'
