osl_ifconfig "192.168.60.#{node['multi_node_test']['ip']}" do
  onboot 'yes'
  mask '255.255.255.0'
  network '192.168.60.0'
  nm_controlled 'yes'
  ipv6init 'yes'
  ipv6addr "fc00::#{node['multi_node_test']['ip']}"
  device 'eth1'
  notifies :reload, 'ohai[reload_network]'
end

ohai 'reload_network' do
  plugin 'network'
  action :nothing
end
