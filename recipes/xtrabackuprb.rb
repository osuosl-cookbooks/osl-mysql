include_recipe 'git'
include_recipe 'percona::package_repo'
include_recipe 'yum-epel'

package 'rubygems' do
end.run_action(:install)

package 'libev'
package 'percona-xtrabackup'

resources('git_client[default]').run_action(:install)
version = node['osl-mysql']['xtrabackuprb']['version']

git '/usr/local/src/xtrabackup-rb' do
  repository 'https://github.com/mmz-srf/xtrabackup-rb.git'
end.run_action(:sync)

execute 'gem build xtrabackup-rb.gemspec' do
  cwd '/usr/local/src/xtrabackup-rb'
  not_if { ::File.exist?('/opt/chef/embedded/bin/xtrabackup-rb') }
end.run_action(:run)

chef_gem 'xtrabackup-rb' do
  source "/usr/local/src/xtrabackup-rb/xtrabackup-rb-#{version}.gem"
  compile_time false
end

link '/usr/local/sbin/xtrabackup-rb' do
  to '/opt/chef/embedded/bin/xtrabackup-rb'
end
