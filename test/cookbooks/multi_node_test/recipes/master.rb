include_recipe 'multi_node_test::network'
include_recipe 'osl-mysql::master'

mysql_connection_info = {
  host: '127.0.0.1',
  username: 'root',
  password: 'jzYY0cQUnPAMcqvIxYaC',
}

build_essential 'mysql'
package 'ruby-devel'

mysql2_chef_gem 'default' do
  provider Chef::Provider::Mysql2ChefGem::Percona
  action :install
end

mysql_database 'testdb' do
  connection mysql_connection_info
  action :create
end

mysql_database 'testdb' do
  connection mysql_connection_info
  sql 'DROP TABLE IF EXISTS example'
  action :query
end

mysql_database 'testdb' do
  connection mysql_connection_info
  sql 'CREATE TABLE IF NOT EXISTS example (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(32))'
  action :query
end

mysql_database 'testdb' do
  connection mysql_connection_info
  sql 'INSERT INTO example (name) VALUES (\'hello\'), (\'world\')'
  action :query
end
