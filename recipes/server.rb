#
# Cookbook Name:: osl-mysql
# Recipe:: server
#
# Copyright (C) 2013-2015 Oregon State University
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
node.default['percona']['server']['debian_username'] = 'root'
node.default['percona']['skip_passwords'] = false
node.default['percona']['server']['bind_address'] = '0.0.0.0'

# Tunables
node.default['percona']['server']['binlog_format'] = 'mixed'
node.default['percona']['server']['myisam_recover'] = 'FORCE,BACKUP'
node.default['percona']['server']['max_connections'] = 500
node.default['percona']['server']['max_allowed_packet'] = '128M'
node.default['percona']['server']['max_connect_errors'] = 100_000
node.default['percona']['server']['connect_timeout'] = 28_880
node.default['percona']['server']['open_files_limit'] = 65_535
node.default['percona']['server']['log_bin'] = '/var/lib/mysql/mysql-bin'
node.default['percona']['server']['expire_logs_days'] = '10'
node.default['percona']['server']['sync_binlog'] = 0
node.default['percona']['server']['query_cache_size'] = 0
node.default['percona']['server']['thread_cache_size'] = 50
node.default['percona']['server']['key_buffer'] = '32M'
node.default['percona']['server']['table_cache'] = 4_096
node.default['percona']['server']['innodb_file_per_table'] = true
node.default['percona']['server']['innodb_flush_method'] = 'O_DIRECT'
node.default['percona']['server']['innodb_log_files_in_group'] = 2
node.default['percona']['server']['innodb_flush_log_at_trx_commit'] = 2

# Calculate the InnoDB buffer pool size and instances
# Ohai reports memory in kB
mem = (node['memory']['total'].split('kB')[0].to_i / 1024) # in MB
node.default['percona']['server']['innodb_buffer_pool_size'] =
  "#{Integer(mem * 0.75)}M"

include_recipe 'yum-epel'
package 'libev'

include_recipe 'base::sysctl'
include_recipe 'percona::server'
include_recipe 'percona::toolkit'
include_recipe 'percona::backup'
include_recipe 'firewall::mysql'

# XXX: temporary add this until its fixed upstream
yum_repository 'percona-noarch' do
  description 'Percona noarch Packages'
  baseurl 'http://repo.percona.com/centos/' \
    "#{node['platform_version'].to_i}/os/noarch/"
  gpgkey node['percona']['yum']['gpgkey']
  gpgcheck node['percona']['yum']['gpgcheck']
  sslverify node['percona']['yum']['sslverify']
  only_if { platform_family?('rhel') }
end

sysctl_param 'vm.swappiness' do
  value 0
end

cookbook_file '/usr/local/libexec/mysql-accounting' do
  source 'mysql-accounting'
  mode '0755'
end

package 'cronie'

cron 'mysql-accounting' do
  command '/usr/local/libexec/mysql-accounting'
  time :daily
end
