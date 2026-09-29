require 'spec_helper'

describe 'osl-mysql::source' do
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
        expect(chef_run).to include_recipe('osl-mysql::server')
      end
      it do
        expect(chef_run).to_not include_recipe('percona::ssl')
      end
      it do
        expect(chef_run).to_not render_file('/etc/mysql/replication.sql').with_content('REQUIRE SSL')
      end

      context 'with replication ssl enabled' do
        cached(:chef_run) do
          ChefSpec::SoloRunner.new(pltfrm) do |node|
            node.normal['percona']['server']['replication']['ssl_enabled'] = true
          end.converge(described_recipe)
        end
        it do
          expect(chef_run).to include_recipe('percona::ssl')
        end
        it do
          expect(chef_run).to render_file('/etc/mysql/replication.sql').with_content('REQUIRE SSL')
        end
      end
    end
  end
end
