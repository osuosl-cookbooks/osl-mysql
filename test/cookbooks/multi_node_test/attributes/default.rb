default['multi_node_test']['ip'] = node['fqdn'].start_with?('master') ? 11 : 12
