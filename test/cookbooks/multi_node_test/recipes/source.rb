node.default['percona']['server']['replication']['ssl_enabled'] = true

include_recipe 'multi_node_test::network'
include_recipe 'osl-mysql::source'

mysql_password = 'jzYY0cQUnPAMcqvIxYaC'

percona_mysql_database 'testdb' do
  password mysql_password
  sql 'CREATE DATABASE IF NOT EXISTS testdb;'
  action :query
end

percona_mysql_database 'testdb' do
  password mysql_password
  sql 'USE testdb; DROP TABLE IF EXISTS example'
  action :query
end

percona_mysql_database 'testdb' do
  password mysql_password
  sql 'USE testdb; CREATE TABLE IF NOT EXISTS example (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(32))'
  action :query
end

percona_mysql_database 'testdb' do
  password mysql_password
  sql 'USE testdb; INSERT INTO example (name) VALUES (\'hello\'), (\'world\')'
  action :query
end
