#
# Cookbook:: osl-mysql
# Recipe:: mon
#
# Copyright:: 2014-2024, Oregon State University
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
include_recipe 'osl-mysql::server'
include_recipe 'osl-nrpe'

passwords = data_bag_item(
  node['percona']['encrypted_data_bag'],
  'mysql'
)

percona_mysql_user 'mysql_monitor_grant' do
  ctrl_password passwords['root']
  username node['osl-mysql']['monitor_user']
  password passwords['monitor']
  privileges [:super, :select, :process, 'replication client', 'replication slave']
  action [:create, :grant]
end

include_recipe 'yum-osuosl'

# Install nagios percona plugins
package 'percona-nagios-plugins'

# Add defaults file for mysql nagios checks
template "#{node['nrpe']['conf_dir']}/mysql.cnf" do
  source 'nagios/mysql.cnf.erb'
  mode '600'
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
