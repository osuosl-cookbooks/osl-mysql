require 'spec_helper'

describe 'osl-mysql::slave' do
  include_context 'common_stubs'

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
        master = stub_node('master', pltfrm) do |node|
          node.normal['recipes'] = ['osl-mysql::master']
          node.normal['roles'] = ['mysql-vip']
          node.normal['percona']['server']['role'] = 'master'
        end
        ChefSpec::ServerRunner.new(pltfrm) do |_node, server|
          server.create_node(master)
        end.converge(described_recipe)
      end
      it do
        expect(chef_run).to include_recipe('osl-mysql::server')
      end
      it do
        expect { chef_run }.not_to raise_error
      end
    end

    context 'ServerRunner without master node' do
      cached(:chef_run) do
        slave = stub_node('slave', pltfrm) do |node|
          node.normal['recipes'] = ['osl-mysql::slave']
          node.normal['roles'] = ['mysql-vip']
          node.normal['percona']['server']['role'] = 'slave'
        end
        ChefSpec::ServerRunner.new(pltfrm) do |_node, server|
          server.create_node(slave)
        end.converge(described_recipe)
      end
      it do
        expect { chef_run }.to raise_error.with_message('You should have one master node')
      end
    end
  end
end
