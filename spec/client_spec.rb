require 'spec_helper'

describe 'osl-mysql::client' do
  ALLPLATFORMS.each do |pltfrm|
    context "on #{pltfrm[:platform]} #{pltfrm[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(pltfrm).converge(described_recipe)
      end
      it do
        expect { chef_run }.to_not raise_error
      end
      case pltfrm
      when CENTOS_7_OPTS
        it do
          expect(chef_run).to install_package('mariadb')
        end
      when CENTOS_6_OPTS
        it do
          expect(chef_run).to create_mysql_client('default')
        end
      end
    end
  end
end
