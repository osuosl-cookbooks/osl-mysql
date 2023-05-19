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
property :version, [String, nil]
property :database_parameters, Hash, default: {}

# Install the mariadb package, set up the service, set up the user, then set up the given database
action :create do
  # Check to see if we are running on CentOS, we will be forcing a version if none was given.
  if platform?('centos') && Gem::Version.create(node['platform_version']) < Gem::Version.create(8) && !new_resource.version
    new_resource.version = '10.11'
  end
  # Decide if we should install from the MariaDB respository in the event the stock distro has an outdated version
  if new_resource.version || node['osl-mysql']['test_mariadb_repo']
    # Sometimes there is a package requirement not available in the stock repo.
    include_recipe 'osl-repos::epel'
    # Install the MariaDB package, and set up the service
    mariadb_server_install 'osl-mysql-test' do
      password new_resource.server_password
      version new_resource.version
      action [:install, :create]
    end
    node.force_override['osl-mysql']['test_mariadb_repo'] = true
  else
    # Install the stock package, and set up the service
    mariadb_server_install 'osl-mysql-test' do
      password new_resource.server_password
      setup_repo false
      action [:install, :create]
    end
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
end
