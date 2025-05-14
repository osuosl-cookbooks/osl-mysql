certificate_manage 'wildcard' do
  cert_path node['percona']['server']['datadir']
  create_subfolders false
  cert_file node['percona']['conf']['mysqld']['ssl_cert']
  key_file  node['percona']['conf']['mysqld']['ssl_key']
  chain_file node['percona']['conf']['mysqld']['ssl_ca']
  owner node['percona']['server']['username']
  group node['percona']['server']['username']
  notifies :restart, 'service[mysql]'
end
