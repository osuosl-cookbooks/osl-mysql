require 'spec_helper'

describe 'osl-mysql::client' do
  include_context 'common_stubs'
  ALLPLATFORMS.each do |pltfrm|
    context "on #{pltfrm[:platform]} #{pltfrm[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(pltfrm).converge(described_recipe)
      end
      it do
        expect { chef_run }.to_not raise_error
      end
      it do
        expect(chef_run).to include_recipe('osl-mysql')
      end
      it do
        expect(chef_run).to_not include_recipe('percona::client')
      end
      it do
        expect(chef_run).to create_mysql_client('default').with(package_name: %w(mariadb mariadb-devel))
      end
      context 'percona client' do
        cached(:chef_run) do
          ChefSpec::SoloRunner.new(pltfrm) do |node|
            node.normal['osl-mysql']['enable_percona_client'] = true
          end.converge(described_recipe)
        end
        it do
          expect(chef_run).to include_recipe('percona::client')
        end
      end
    end
  end
end
