require 'spec_helper'

describe 'osl-mysql::server' do
  include_context 'common_stubs'
  ALLPLATFORMS.each do |pltfrm|
    context "on #{pltfrm[:platform]} #{pltfrm[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(pltfrm).converge(described_recipe)
      end
      before do
        stub_command('rpm -qa | grep Percona-Server-shared-56').and_return(true)
        stub_command("mysqladmin --user=root --password='' version").and_return(true)
      end
      it do
        expect { chef_run }.to_not raise_error
      end
      it do
        expect(chef_run).to include_recipe('yum-epel')
      end
      it do
        expect(chef_run).to install_package('libev')
      end
      it do
        expect(chef_run).to include_recipe('base::sysctl')
      end
      it do
        expect(chef_run).to include_recipe('percona::server')
      end
      it do
        expect(chef_run).to include_recipe('percona::toolkit')
      end
      it do
        expect(chef_run).to include_recipe('percona::backup')
      end
      it do
        expect(chef_run).to include_recipe('firewall::mysql')
      end

      it do
        expect(chef_run).to create_yum_repository('percona-noarch')
          .with(
            description: 'Percona noarch Packages',
            baseurl: "http://repo.percona.com/centos/#{pltfrm[:version].to_i}/os/noarch/"
          )
      end

      it do
        expect(chef_run).to apply_sysctl_param('vm.swappiness')
          .with(
            value: '0'
          )
      end

      it do
        expect(chef_run).to create_cookbook_file('/usr/local/libexec/mysql-accounting')
          .with(
            source: 'mysql-accounting',
            mode: '0755'
          )
      end

      it do
        expect(chef_run).to install_package('cronie')
      end

      it do
        expect(chef_run).to create_cron('mysql-accounting')
          .with(
            command: '/usr/local/libexec/mysql-accounting',
            time: :daily
          )
      end
    end
  end
end
