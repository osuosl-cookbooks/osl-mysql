osl_ifconfig "192.168.60.#{node['multi_node_test']['ip']}" do
  onboot 'yes'
  mask '255.255.255.0'
  network '192.168.60.0'
  ipv6init 'yes'
  ipv6addr "fc00::#{node['multi_node_test']['ip']}"
  device 'eth1'
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
