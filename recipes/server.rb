#
# Cookbook:: osl-mysql
# Recipe:: server
#
# Copyright:: 2013-2020, Oregon State University
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

# Loosen restrictions on type of functions users can create
node.default['percona']['conf']['mysqld']['log_bin_trust_function_creators'] = '1'

# utf8mb4 support
node.default['percona']['conf']['mysqld']['innodb_large_prefix'] = 'true'

# Tunables
node.default['percona']['server']['binlog_format'] = 'mixed'
node.default['percona']['server']['myisam_recover'] = 'FORCE,BACKUP'
node.default['percona']['server']['max_connections'] = 1_000
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
node.default['percona']['server']['innodb_file_format'] = 'barracuda'
node.default['percona']['server']['innodb_file_per_table'] = true
node.default['percona']['server']['innodb_flush_method'] = 'O_DIRECT'
node.default['percona']['server']['innodb_log_files_in_group'] = 2
node.default['percona']['server']['innodb_flush_log_at_trx_commit'] = 2

# Calculate the InnoDB buffer pool size and instances
# Ohai reports memory in kB
mem = (node['memory']['total'].split('kB')[0].to_i / 1024) # in MB
# Setinnodb_buffer_pool_size to 70% of total RAM of the machine
node.default['percona']['server']['innodb_buffer_pool_size'] = "#{Integer(mem * 0.70)}M"
# Set to 1% of total memory
# https://discuss.aerospike.com/t/how-to-tune-the-linux-kernel-for-memory-performance/4195
min_free_kbytes = Integer(mem * 1024 * 0.01)

sysctl 'vm.swappiness' do
  value 0
end

sysctl 'vm.min_free_kbytes' do
  # Don't set above 2GB
  if (min_free_kbytes / 1048576) >= 2
    value '2097152'
  else
    value min_free_kbytes
  end
end

include_recipe 'osl-mysql'
include_recipe 'yum-epel' if node['platform_version'].to_i == 6
include_recipe 'percona::server'
include_recipe 'percona::toolkit'
include_recipe 'percona::backup'
include_recipe 'firewall::mysql'

delete_resource(:package, 'mysql-libs')

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

directory '/var/lib/mysql-files' do
  owner 'mysql'
  group 'mysql'
end

directory '/var/lib/accounting/mysql' do
  recursive true
  mode '0700'
end

%w(mysql-accounting mysql-prometheus).each do |f|
  cookbook_file "/usr/local/libexec/#{f}" do
    source f
    mode '0755'
  end
end

cron 'mysql-accounting' do
  command '/usr/local/libexec/mysql-accounting'
  time :daily
end

cron 'mysql-prometheus' do
  command '/usr/local/libexec/mysql-prometheus'
  minute '*/30'
end
