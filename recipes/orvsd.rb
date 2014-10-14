#
# Cookbook Name:: osl-mysql
# Recipe:: orvsd
#
# Copyright (C) 2013 Oregon State University
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

# ORVSD Specific configuration
node.override['percona']['server']['innodb_log_file_size'] = "512M"
node.override['percona']['server']['pidfile'] = "/var/run/mysql/mysql.pid"
node.override['percona']['conf']['mysqld']['log_queries_not_using_index'] = false

directory "/var/run/mysql" do
  action :create
  owner "mysql"
  group "mysql"
  recursive true
end

include_recipe "osl-mysql::server"
