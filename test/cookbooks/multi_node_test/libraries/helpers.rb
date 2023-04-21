module MultiNodeTest
  module Cookbook
    module Helpers
      # get the first interface that isn't localhost and isn't on the 10.1.100.* network
      def mysql_interface
        interfaces = node['network']['interfaces']
        interfaces.keys.find { |iface| interfaces[iface]['addresses'].keys.none? { |addr| addr.include? '10.1.100' } && iface != 'lo' }
      end
    end
  end
end

Chef::DSL::Recipe.include ::MultiNodeTest::Cookbook::Helpers
Chef::Resource.include ::MultiNodeTest::Cookbook::Helpers
