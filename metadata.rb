name             'osl-mysql'
issues_url       'https://github.com/osuosl-cookbooks/osl-mysql/issues'
source_url       'https://github.com/osuosl-cookbooks/osl-mysql'
maintainer       'Oregon State University'
maintainer_email 'systems@osuosl.org'
license          'Apache-2.0'
chef_version     '>= 16.0'
description      'Installs/Configures osl-mysql'
version          '6.2.0'

depends          'git'
depends          'mariadb', '~> 5.2.1'
depends          'mysql', '~> 11.0.0'
depends          'osl-firewall'
depends          'osl-nrpe'
depends          'osl-postfix'
depends          'osl-selinux'
depends          'percona', '~> 3.1.1'

supports         'centos', '~> 7.0'
supports         'centos_stream', '~> 8.0'
