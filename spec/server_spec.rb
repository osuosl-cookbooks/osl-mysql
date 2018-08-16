require 'spec_helper'

describe 'osl-mysql::server' do
  include_context 'common_stubs'
  ALLPLATFORMS.each do |pltfrm|
    context "on #{pltfrm[:platform]} #{pltfrm[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(pltfrm).converge(described_recipe)
      end

      it do
        expect { chef_run }.to_not raise_error
      end

      %w(
        base::sysctl
        percona::server
        percona::toolkit
        percona::backup
        firewall::mysql
      ).each do |recipe|
        it do
          expect(chef_run).to include_recipe(recipe)
        end
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
        expect(chef_run).to create_directory('/var/lib/mysql-files')
          .with(
            owner: 'mysql',
            group: 'mysql'
          )
      end

      it do
        expect(chef_run).to create_directory('/var/lib/accounting/mysql')
          .with(
            recursive: true,
            mode: '0700'
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
        expect(chef_run).to create_cron('mysql-accounting')
          .with(
            command: '/usr/local/libexec/mysql-accounting',
            time: :daily
          )
      end
    end
  end
end
