#node.default['percona']['server']['replication']['ssl_enabled'] = true

include_recipe 'multi_node_test::network'
include_recipe 'osl-mysql::slave'
