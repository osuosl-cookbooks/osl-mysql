require 'spec_helper'

describe 'osl-mysql::slave' do
  ALLPLATFORMS.each do |pltfrm|
    context 'SoloRunner' do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(pltfrm).converge(described_recipe)
      end
      it do
        expect { chef_run }.to raise_error.with_message('You should have one master node')
      end
    end

    context 'ServerRunner with master node' do
      cached(:chef_run) do
        master_node = stub_node('master_node', pltfrm) do |node|
          node.automatic['run_list'] = ['recipe[osl-mysql::master]', 'role[mysql-vip]']
        end
        ChefSpec::ServerRunner.new(pltfrm) do |node, server|
          server.create_node(master_node)
        end.converge(described_recipe)
      end
      it do
        expect { chef_run }.not_to raise_error
      end
    end

    context 'ServerRunner without master node' do
      cached(:chef_run) do
        slave_node = stub_node('slave', pltfrm) do |node|
          node.automatic['run_list'] = ["osl-mysql::slave"]
        end
        ChefSpec::ServerRunner.new(pltfrm) do |node, server|
          server.create_node(slave_node)
        end.converge(described_recipe)
      end
      it do
        expect { chef_run }.to raise_error.with_message('You should have one master node')
      end
    end

  end
end
