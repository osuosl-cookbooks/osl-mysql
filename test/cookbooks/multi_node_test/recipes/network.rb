# assume that interfaces are the same across the two nodes and use that one
node.default['osl-mysql']['replication']['source_interface'] = mysql_interface

osl_ifconfig mysql_interface do
  mask '255.255.255.0'
  network '10.1.0.0'
  ipv4addr "10.1.0.#{node['multi_node_test']['ip']}"
  ipv6init 'yes'
  ipv6addr "fc00::#{node['multi_node_test']['ip']}"
  notifies :reload, 'ohai[reload_network]'
end

append_if_no_line '/etc/hosts' do
  path '/etc/hosts'
  line '10.1.0.11 source.testing.osuosl.org'
end

append_if_no_line '/etc/hosts' do
  path '/etc/hosts'
  line '10.1.0.12 replica.testing.osuosl.org'
end

ohai 'reload_network' do
  plugin 'network'
  action :nothing
end
