node.default['percona']['server']['gtid_mode'] = 'ON'
node.default['percona']['server']['enforce_gtid_consistency'] = 'ON'
node.default['percona']['server']['log_slave_updates'] = true
node.default['osl-mysql']['replication']['source_ip'] = 'source.testing.osuosl.org'

include_recipe 'multi_node_test::network'
include_recipe 'osl-mysql::replica'
include_recipe 'multi_node_test::certificate'
