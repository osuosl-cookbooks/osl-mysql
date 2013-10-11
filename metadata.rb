name             'osl-mysql'
maintainer       'OSU Open Source Lab'
maintainer_email 'systems@osuosl.org'
license          'Apache 2.0'
description      'Installs/Configures osl-mysql'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends          'yum'
depends          'nagios'
depends          'sysctl'
depends          'mysql', '~> 3.0.12'
