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
property :version, String
property :database_parameters, Hash, default: {}

# Install the mariadb package, set up the service, set up the user, then set up the given database
action :create do
  # Setup the port for mysql
  osl_firewall_port 'mysql' do
    osl_only false
  end
  # Setup the epel repo if we are installing from MariaDB as the MariaDB version depends on a package found in epel.
  include_recipe 'osl-repos::epel' if new_resource.version

  # Install the database packages, dependent on if the version property is set
  mariadb_server_install 'osl-mysql-test' do
    password new_resource.server_password
    version new_resource.version if new_resource.version
    setup_repo false unless new_resource.version
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
    host '%'
    action [:create, :grant]
  end

  template '/root/.my.cnf' do
    cookbook 'osl-mysql'
    source 'my.cnf.erb'
    mode '0640'
    sensitive true
    variables(password: new_resource.server_password)
  end
end
