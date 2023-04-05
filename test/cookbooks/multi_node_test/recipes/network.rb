# get the first interface that isn't localhost and isn't on the 10.1.100.* network
interfaces = node['network']['interfaces']
mysql_interface = interfaces.keys.find { |iface| interfaces[iface]['addresses'].keys.none? { |addr| addr.include? '10.1.100' } && iface != 'lo' }

# a hack, but assume that interfaces are the same across the two nodes
node.default['osl-mysql']['replication']['source_interface'] = mysql_interface

osl_ifconfig "192.168.60.#{node['multi_node_test']['ip']}" do
  onboot 'yes'
  mask '255.255.255.0'
  network '192.168.60.0'
  ipv6init 'yes'
  ipv6addr "fc00::#{node['multi_node_test']['ip']}"
  device mysql_interface
  notifies :reload, 'ohai[reload_network]'
end

ohai 'reload_network' do
  plugin 'network'
  action :nothing
end

# osl_firewall mysql defaults to only allow osl subnets
# the terraform local subnet for the multi-node suite is not in that list
# thus, edit the resource in ::server to allow any ips
edit_resource(:osl_firewall_port, 'mysql') do
  osl_only false
end
