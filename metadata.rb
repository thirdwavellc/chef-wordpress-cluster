name             'wordpress-cluster'
maintainer       'Adam Krone'
maintainer_email 'adam.krone@thirdwavellc.com'
license          'Apache v2.0'
description      'Installs/Configures a high availability wordpress cluster'
long_description 'Installs/Configures a high availability wordpress cluster'
version          '1.1.2'

depends 'apt'
depends 'yum'
depends 'git'
depends 'hg'
depends 'unzip'
depends 'ssh-import-id'
depends 'ssh-hardening'
depends 'capistrano-wordpress'
depends 'consul'
depends 'consul-cluster'
depends 'consul-services'
depends 'consul-template'
depends 'lsyncd'
depends 'csync2'
depends 'wp-cli'
depends 'mysql'
