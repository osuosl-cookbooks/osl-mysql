#
# Cookbook Name:: osl-mysql
# Recipe:: mon
#
# Copyright (C) 2014, Oregon State University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
node.default['percona']['plugins_version'] = nil
node.default['percona']['plugins_packages'] = %w(percona-nagios-plugins)
include_recipe 'osl-mysql::server'
include_recipe 'percona::monitoring'
include_recipe 'osl-nrpe'
include_recipe 'osl-munin::client'

passwords = Chef::EncryptedDataBagItem.load(
  node['percona']['encrypted_data_bag'],
  'mysql'
)

mysql2_chef_gem 'default' do
  provider Chef::Provider::Mysql2ChefGem::Percona
  action :install
end

# Create monitor mysql user
mysql_conn = {
  host: 'localhost',
  username: 'root',
  password: passwords['root']
}

mysql_database_user 'mysql_monitor_grant' do
  connection mysql_conn
  username node['osl-mysql']['monitor_user']
  password passwords['monitor']
  privileges [:super, :process, 'replication client']
  action [:create, :grant]
end

# select access is required for some munin plugins
mysql_database_user 'mysql_monitor_database' do
  connection mysql_conn
  username node['osl-mysql']['monitor_user']
  privileges [:select]
  database_name 'mysql'
  action [:grant]
end

# Add defaults file for mysql nagios checks
template "#{node['nrpe']['conf_dir']}/mysql.cnf" do
  source 'nagios/mysql.cnf.erb'
  mode 0600
  owner node['nrpe']['user']
  group node['nrpe']['group']
  variables(password: passwords['monitor'])
  sensitive true
end

%w(
  innodb
  pidfile
  processlist
  replication-delay
).each do |c|
  nrpe_check "pmp-check-mysql-#{c}" do
    command "#{node['nrpe']['plugin_dir']}/pmp-check-mysql-#{c}"
    action :add
  end
end

template "#{node['munin']['basedir']}/plugin-conf.d/mysql" do
  source 'munin/mysql.erb'
  owner 'munin'
  group 'munin'
  variables(password: passwords['monitor'])
  mode 0600
end

# Perl dep required for some munin plugins
package 'perl-Cache-Cache'

%w(
  mysql_queries
  mysql_slowqueries
  mysql_threads
).each do |p|
  munin_plugin p
end

%w(
  bin_relay_log
  commands
  connections
  innodb_bpool
  innodb_bpool_act
  innodb_semaphores
  qcache
  qcache_mem
  slow
  table_locks
  tmp_tables
).each do |p|
  munin_plugin 'mysql_' do
    plugin "mysql_#{p}"
  end
end
