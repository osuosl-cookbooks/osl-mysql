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
include_recipe 'nagios::client_package'
include_recipe 'nagios::client'

passwords = EncryptedPasswords.new(node, node['percona']['encrypted_data_bag'])

# Add defaults file for mysql nagios checks
template "#{node['nagios']['nrpe']['conf_dir']}/mysql.cnf" do
  source 'nagios/mysql.cnf.erb'
  mode 0600
  owner node['nagios']['user']
  group node['nagios']['group']
  variables(password: passwords.root_password)
  sensitive true
end

%w(
  innodb
  pidfile
  processlist
  replication-delay
).each do |c|
  nagios_nrpecheck "pmp-check-mysql-#{c}" do
    command "#{node['nagios']['plugin_dir']}/pmp-check-mysql-#{c}"
    action :add
  end
end
