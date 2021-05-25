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
        percona::server
        percona::toolkit
        percona::backup
      ).each do |recipe|
        it do
          expect(chef_run).to include_recipe(recipe)
        end
      end

      it { expect(chef_run).to accept_osl_firewall_port('mysql') }

      it do
        expect(chef_run).to apply_sysctl('vm.swappiness').with(value: '0')
      end

      if pltfrm[:version].to_i < 8
        it do
          expect(chef_run).to install_package(%w(Percona-Server-client-56 Percona-Server-devel-56))
        end
      else
        it do
          expect(chef_run).to install_package(%w(Percona-Server-client-57 Percona-Server-devel-57))
        end
      end

      it do
        expect(chef_run).to apply_sysctl('vm.min_free_kbytes').with(value: '10485')
      end
      context '256G RAM' do
        cached(:chef_run) do
          ChefSpec::SoloRunner.new(pltfrm) do |node|
            node.automatic['memory']['total'] = '268435456kB'
          end.converge(described_recipe)
        end
        it do
          expect(chef_run).to apply_sysctl('vm.min_free_kbytes').with(value: '2097152')
        end
      end
      it do
        expect(chef_run).to render_file('/etc/my.cnf').with_content('innodb_buffer_pool_size = 716M')
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
    end
  end
end
