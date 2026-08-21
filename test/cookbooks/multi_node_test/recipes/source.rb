# node.default['percona']['server']['gtid_mode'] = 'ON'
# node.default['percona']['server']['enforce_gtid_consistency'] = 'ON'
# node.default['percona']['server']['log_slave_updates'] = true

include_recipe 'multi_node_test::network'
include_recipe 'osl-mysql::source'
include_recipe 'multi_node_test::certificate'

mysql_password = 'jzYY0cQUnPAMcqvIxYaC'

percona_mysql_database 'testdb-create' do
  database_name 'testdb'
  password mysql_password
  sql 'CREATE DATABASE IF NOT EXISTS testdb;'
  action :query
end

percona_mysql_database 'testdb-drop' do
  database_name 'testdb'
  password mysql_password
  sql 'USE testdb; DROP TABLE IF EXISTS example'
  action :query
end

percona_mysql_database 'testdb-create-table' do
  database_name 'testdb'
  password mysql_password
  sql 'USE testdb; CREATE TABLE IF NOT EXISTS example (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(32))'
  action :query
end

percona_mysql_database 'testdb-insert' do
  database_name 'testdb'
  password mysql_password
  sql 'USE testdb; INSERT INTO example (name) VALUES (\'hello\'), (\'world\')'
  action :query
end

# remote user so the replica-side inspec tests can write to the source
# (used to break replication on purpose for mysql-replication-skip)
percona_mysql_database 'skiptest-user' do
  database_name 'mysql'
  password mysql_password
  sql 'CREATE USER IF NOT EXISTS \'skiptest\'@\'10.1.0.%\' IDENTIFIED BY \'Sk1pT3st-Passw0rd\''
  action :query
end

percona_mysql_database 'skiptest-grant' do
  database_name 'mysql'
  password mysql_password
  sql 'GRANT ALL PRIVILEGES ON testdb.* TO \'skiptest\'@\'10.1.0.%\''
  action :query
end
