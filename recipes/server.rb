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

include_recipe 'yum'

yum_repository "percona" do
  description "Percona"
  url "http://repo.percona.com/centos/#{node["platform_version"].split('.')[0]}/os/#{node["kernel"]["machine"]}/"
  gpgkey "http://www.percona.com/downloads/RPM-GPG-KEY-percona"
  action :add
end

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

node['mysql']['server']['packages'].each do |p|
  package p do
    action :upgrade
  end
end

service "mysql" do
  action :enable
end

template "/etc/my.cnf" do
  owner "mysql"
  group "mysql"
  mode 0600
  notifies :restart, "service[mysql]"
end

directory node['mysql']['server']['directories']['log_dir'] do
  action :create
  owner "mysql"
  group "mysql"
  mode 0755
end

# Copy .my.cnf into place to ease MySQL administration
template "/root/.my.cnf" do
  source "dot.my.cnf.erb"
  mode "600"
  owner "root"
  group "root"
end

