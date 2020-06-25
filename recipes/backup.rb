include_recipe 'osl-mysql::xtrabackuprb'

directory node['osl-mysql']['backup_dir'] do
  recursive true
  mode '700'
end
