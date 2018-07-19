require 'spec_helper'

describe 'osl-mysql::backup' do
  [CENTOS_7_OPTS, CENTOS_6_OPTS].each do |pltfrm|
    context "on #{pltfrm[:platform]} #{pltfrm[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(pltfrm).converge(described_recipe)
      end
      before do
        allow_any_instance_of(Chef::Recipe).to receive(:include_recipe).with('osl-mysql::xtrabackuprb')
      end
      it do
        expect { chef_run }.to_not raise_error
      end
      it do
        expect(chef_run).to create_directory('/data/backup')
      end
    end
  end
end
