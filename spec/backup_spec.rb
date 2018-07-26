require 'spec_helper'

describe 'osl-mysql::backup' do
  ALLPLATFORMS.each do |pltfrm|
    context "on #{pltfrm[:platform]} #{pltfrm[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(pltfrm).converge(described_recipe)
      end
      it do
        expect { chef_run }.to_not raise_error
      end
      it do
        expect(chef_run).to include_recipe('osl-mysql::xtrabackuprb')
      end
      it do
        expect(chef_run).to create_directory('/data/backup')
      end
    end
  end
end
