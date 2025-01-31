#
# Cookbook:: osl-mysql
# Recipe:: client
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

if node['osl-mysql']['enable_percona_client']
  include_recipe 'percona::client'
else
  mysql_client 'default' do
    package_name %w(mariadb mariadb-devel)
  end
end
