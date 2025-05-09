#
# Cookbook:: osl-mysql
# Recipe:: server
#
# Copyright:: 2013-2025, Oregon State University
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
include_recipe 'osl-mysql'

osl_mysql_conf

sysctl 'vm.swappiness' do
  value 0
end

sysctl 'vm.min_free_kbytes' do
  value osl_min_free_kbytes
end

selinux_fcontext '/var/log/mysql(/.*)?' do
  secontext 'mysqld_log_t'
end

include_recipe 'percona::server'
include_recipe 'percona::toolkit'
include_recipe 'percona::backup'

osl_firewall_port 'mysql'

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
