provides :osl_mysql_test
resource_name :osl_mysql_test
unified_mode true

default_action :create

property :database, String, name_property: true
property :username, String, required: true
property :password, String, required: true
property :server_password, String, default: 'osl_mysql_test'
property :encoding, String, default: 'utf8mb4'
property :collation, String, default: 'utf8mb4_unicode_ci'
property :database_parameters, Hash, default: {}

# Install the mariadb package, set up the service, set up the user, then set up the given database
action :create do
  # Install the package, and set up the service
  mariadb_server_install 'osl-mysql-test' do
    password new_resource.server_password
    setup_repo false
    action [:install, :create]
  end
  # Create new database
  mariadb_database new_resource.database do
    password new_resource.server_password
    encoding new_resource.encoding
    collation new_resource.collation
    new_resource.database_parameters.each do |key, value|
      send(key.to_sym, value)
    end
  end
  # Grant privilages
  mariadb_user new_resource.username do
    ctrl_password new_resource.server_password
    password new_resource.password
    database_name new_resource.database
    action [:create, :grant]
  end
  # Ensure that large prefix size is enabled on centos 7
  mariadb_database 'Increase prefix size' do
    sql 'SET GLOBAL innodb_large_prefix = 1; SET GLOBAL innodb_default_for_format = dynamic;'
    password new_resource.server_password
    action [:query]
    only_if { platform?('centos') && node['platform_version'] == "7.9.2009" }
  end
end
