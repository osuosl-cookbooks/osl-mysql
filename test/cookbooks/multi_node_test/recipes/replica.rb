node.default['percona']['server']['replication']['ssl_enabled'] = true if node['platform_version'].to_i >= 8

include_recipe 'multi_node_test::network'
include_recipe 'osl-mysql::replica'
