include_recipe 'git'
include_recipe 'osl-postfix'
include_recipe 'osl-mysql'
include_recipe 'yum-epel' if node['platform_version'].to_i == 6

node.default['percona']['skip_passwords'] = true
include_recipe 'percona::backup'

resources('git_client[default]').run_action(:install)
version = node['osl-mysql']['xtrabackuprb']['version']

git '/usr/local/src/xtrabackup-rb' do
  repository 'https://github.com/mmz-srf/xtrabackup-rb.git'
end

chef_path = node['chef_packages']['chef']['version'].to_i >= 15 ? 'cinc' : 'chef'

execute "/opt/#{chef_path}/embedded/bin/gem build xtrabackup-rb.gemspec" do
  cwd '/usr/local/src/xtrabackup-rb'
  not_if { ::File.exist?("/opt/#{chef_path}/embedded/bin/xtrabackup-rb") }
end

chef_gem 'xtrabackup-rb' do
  source "/usr/local/src/xtrabackup-rb/xtrabackup-rb-#{version}.gem"
  compile_time false
end

link '/usr/local/sbin/xtrabackup-rb' do
  to "/opt/#{chef_path}/embedded/bin/xtrabackup-rb"
end
