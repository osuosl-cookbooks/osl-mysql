provides :mysql_test_db
resource_name :mysql_test_db
unified_mode true

default_action :create

property :database, String, name_property: true
property :username, String, required: true
property :password, String, required: true

# Install the mariadb package, set up the service, set up the user, then set up the given database
action :create do
  # Install the package, and set up the service
  mariadb_server_install 'MariaDB' do
    password 'iloveinsecurepasswords'
    action [:install, :create]
  end
  # Self-reference, creates the database and user
  mysql_test_db new_resource.database do
    retries 3
    retry_delay 10
    username new_resource.username
    password new_resource.password
    action :db_only
  end
end

# Create additional databases, owned by the given user.
action :db_only do
  # Create new database
  mariadb_database new_resource.database do
    password 'iloveinsecurepasswords'
    encoding 'utf8mb4'
    collation 'utf8mb4_unicode_ci'
  end
  # Grant privilages
  mariadb_user new_resource.username do
    ctrl_password 'iloveinsecurepasswords'
    password new_resource.password
    database_name new_resource.database
    action [:create, :grant]
  end
end
