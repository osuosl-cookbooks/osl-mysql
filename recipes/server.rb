node.default['mysql']['client']['packages'] = %w{Percona-Server-client-55 Percona-Server-shared-compat}
node.default['mysql']['server']['packages'] = %w{Percona-Server-shared-55 Percona-Server-server-55 percona-toolkit percona-xtrabackup}
node.default['mysql']['service_name'] = "mysql"
node.default['mysql']['pid_file'] = "#{node['mysql']['data_dir']}/#{node['hostname']}.pid"

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

include_recipe "mysql::percona_repo"
include_recipe "mysql::server"
