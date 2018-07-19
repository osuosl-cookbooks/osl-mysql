require 'spec_helper'

describe 'osl-mysql::slave' do
  [CENTOS_7_OPTS, CENTOS_6_OPTS].each do |pltfrm|
    context "on #{pltfrm[:platform]} #{pltfrm[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(pltfrm).converge(described_recipe)
      end
      it do
        expect { chef_run }.to_not raise_error
      end
      it do
        expect(chef_run).to include_recipe('osl-mysql::server')
      end
    end

    context 'Chef Solo true' do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(pltfrm).converge(described_recipe)
      end

      before do
        Chef::Config.stub(:[]).with(:solo).and_return(true)
      end
      it do
        expect(Chef::Log).to receive(:warn).with('This recipe uses search which Chef Solo does not support')
      end
      it do
        expect(chef_run).to raise_error.with_message('You should have one master node')
      end
    end

    context 'Chef Solo false, no master node' do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(pltfrm).converge(described_recipe)
      end

      before do
        Chef::Config.stub(:[]).with(:solo).and_return(true)
        node.normal['osl-mysql']['replication'] = 'osl-mysql-replication'
        stub_search(:node, 'roles:osl-mysql-replication').and_return([
                                                                       { percona: { server: { role: 'slave' } } },
                                                                     ])
      end
      it do
        expect(chef_run).to raise_error.with_message('You should have one master node')
      end
    end
    context 'Chef Solo false, one master node' do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(pltfrm).converge(described_recipe)
      end

      before do
        Chef::Config.stub(:[]).with(:solo).and_return(true)
        node.normal['osl-mysql']['replication'] = 'osl-mysql-replication'
        stub_search(:node, 'roles:osl-mysql-replication').and_return([
                                                                       { percona: { server: { role: 'master' } } },
                                                                       { percona: { server: { role: 'slave1' } } },
                                                                       { percona: { server: { role: 'slave2' } } },
                                                                     ])
      end
      it do
        expect(chef_run).to_not raise_error
      end
    end
  end
end
