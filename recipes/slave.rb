#
# Cookbook Name:: osl-mysql
# Recipe:: slave
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

ip = Percona::ConfigHelper.bind_to(master_node.first,
                                   replication['master_interface'])

node.default['percona']['server']['role'] = 'slave'
node.default['percona']['server']['server_id'] = 2
node.default['percona']['server']['replication']['read_only'] = true
node.default['percona']['server']['replication']['host'] = ip
node.default['percona']['server']['replication']['username'] = 'replication'

replication = node['osl-mysql']['replication']

master_node = []
if Chef::Config[:solo]
  Chef::Log.warn('This recipe uses search which Chef Solo does not support')
else
  master_node = search(:node, "roles:#{replication['role']}").select do |n|
    n if n['percona']['server']['role'].include?('master')
  end
end

fail 'You should have one master node' unless master_node.length == 1

include_recipe 'osl-mysql::server'
