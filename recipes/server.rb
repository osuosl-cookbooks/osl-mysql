#
# Cookbook Name:: osl-mysql
# Recipe:: orvsd
#
# Copyright (C) 2013 OSU Open Source Lab
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

# OSL MySQL Default Configuration
node.default['mysql']['client']['packages'] = %w{Percona-Server-client-55 Percona-Server-shared-compat}
node.default['mysql']['server']['packages'] = %w{Percona-Server-shared-55 Percona-Server-server-55 percona-toolkit percona-xtrabackup}
node.default['mysql']['service_name'] = "mysql"
node.default['mysql']['pid_file'] = "#{node['mysql']['data_dir']}/#{node['hostname']}.pid"
node.default['mysql']['version'] = "5.5"
node.default['mysql']['bind_address'] = "0.0.0.0"
node.default['mysql']['old_passwords'] = "0"
node.default['mysql']['root_network_acl'] = "localhost"
node.default['mysql']['remove_anonymous_users'] = "true"

# OSL MySQL Default Tunables
node.default['mysql']['tunable']['binlog_format'] = "mixed"
node.default['mysql']['tunable']['myisam_recover'] = "FORCE,BACKUP"
node.default['mysql']['tunable']['max_connections'] = "500"
node.default['mysql']['tunable']['max_allowed_packet'] = "128M"
node.default['mysql']['tunable']['max_connect_errors'] = "100000"
node.default['mysql']['tunable']['connect_timeout'] = "28880"
node.default['mysql']['tunable']['open_files_limit'] = "65535"
node.default['mysql']['tunable']['log_bin'] = "/var/lib/mysql/mysql-bin"
node.default['mysql']['tunable']['expire_logs_days'] = '10'
node.default['mysql']['tunable']['sync_binlog'] = "0"
node.default['mysql']['tunable']['query_cache_type'] = "0"
node.default['mysql']['tunable']['query_cache_size'] = "0"
node.default['mysql']['tunable']['thread_cache_size'] = "50"
node.default['mysql']['tunable']['key_buffer_size'] = "32M"
node.default['mysql']['tunable']['table_definition_cache'] = "4096"
node.default['mysql']['tunable']['table_open_cache'] = "10240"
node.default['mysql']['tunable']['innodb_file_per_table'] = "1"
node.default['mysql']['tunable']['innodb_flush_method'] = "O_DIRECT"
node.default['mysql']['tunable']['innodb_log_files_in_group'] = "2"
node.default['mysql']['tunable']['innodb_flush_log_at_trx_commit'] = "2"

# Calculate the InnoDB buffer pool size and buffer pool instances
# Ohai reports node['memory']['total'] in kB, as in "921756kB"
total_memory = node['memory']['total']
mem = (total_memory.split("kB")[0].to_i / 1024) # in MB
node.default['mysql']['tunable']['innodb_buffer_pool_size'] = "#{(Integer(mem * 0.75))}M"
node.default['mysql']['tunable']['innodb_buffer_pool_instances'] = (mem * 0.75 * 0.2 / 1024).ceil

# Avoid swap with O_DIRECT
node.default['sysctl']['params']['vm']['swapiness'] = "0"

# Install the percona nagios plugins
node.default['nagios']['nrpe']['packages'] = "percona-nagios-plugins"

# Add and pin the mysql uid/gid
group "mysql" do
  action :create
  gid 400
end
user "mysql" do
  action :create
  uid 400
  gid "mysql"
  home "/var/lib/mysql"
  shell "/bin/bash"
end

# Remove these packages if they exist (and prefer Percona)
%w{mysql mysql-libs mysql55-libs}.each do |pkg|
  package pkg do
    action :remove
  end
end

# Enable Percona repo and install Percona MySQL Server
include_recipe "mysql::percona_repo"
include_recipe "mysql::server"

# Copy .my.cnf into place to ease MySQL administration
template "/root/.my.cnf" do
  source "dot.my.cnf.erb"
  mode "600"
  owner "root"
  group "root"
end

