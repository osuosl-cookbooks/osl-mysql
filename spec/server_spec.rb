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
        osl-mysql
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
            baseurl: "http://repo.percona.com/centos/#{pltfrm[:version].to_i}/os/noarch/",
            gpgkey: 'https://raw.githubusercontent.com/percona/percona-repositories/master/rpm/PERCONA-PACKAGING-KEY http://www.percona.com/downloads/RPM-GPG-KEY-percona'
          )
      end

      it do
        expect(chef_run).to install_package('Percona-Server-devel-56')
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

      %w(mysql-accounting mysql-prometheus).each do |f|
        it do
          expect(chef_run).to create_cookbook_file("/usr/local/libexec/#{f}")
            .with(
              source: f,
              mode: '0755'
            )
        end
      end

      it do
        expect(chef_run).to create_cron('mysql-accounting')
          .with(
            command: '/usr/local/libexec/mysql-accounting',
            time: :daily
          )
      end

      it do
        expect(chef_run).to create_cron('mysql-prometheus')
          .with(
            command: '/usr/local/libexec/mysql-prometheus',
            minute: '*/30'
          )
      end
      case pltfrm
      when CENTOS_6_OPTS
        it do
          expect(chef_run).to include_recipe('yum-epel')
        end
      when CENTOS_7_OPTS
        it do
          expect(chef_run).to_not include_recipe('yum-epel')
        end
      end
    end
  end
end
