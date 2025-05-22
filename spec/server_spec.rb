require 'spec_helper'

describe 'osl-mysql::server' do
  include_context 'common_stubs'
  ALLPLATFORMS.each do |pltfrm|
    context "on #{pltfrm[:platform]} #{pltfrm[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(pltfrm) do |node|
          node.normal['percona']['version'] = '5.7'
        end.converge(described_recipe)
      end

      it do
        expect { chef_run }.to_not raise_error
      end

      it { expect(chef_run).to manage_selinux_fcontext('/var/log/mysql(/.*)?').with(secontext: 'mysqld_log_t') }

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

      it { expect(chef_run).to install_package(%w(Percona-Server-client-57 Percona-Server-devel-57)) }
      it { expect(chef_run).to install_package 'Percona-Server-server-57' }

      it do
        expect(chef_run).to apply_sysctl('vm.min_free_kbytes').with(value: '10485')
      end

      context 'Percona Server 8.0' do
        cached(:chef_run) do
          ChefSpec::SoloRunner.new(pltfrm) do |node|
            node.normal['percona']['version'] = '8.0'
          end.converge(described_recipe)
        end
        it { expect(chef_run).to install_package(%w(percona-server-client percona-server-devel)) }
        it { expect(chef_run).to install_package 'percona-server-server' }
        [
          'auto_increment_increment = 3',
          'bind-address = 0.0.0.0',
          /binlog_format\s+= ROW/,
          /character_set_server\s+= utf8mb4/,
          /collation_server\s+= utf8mb4_0900_ai_ci/,
          /connect_timeout\s+= 28880/,
          'enforce_gtid_consistency = ON',
          'gtid_mode = ON',
          'innodb_buffer_pool_instances = 1',
          'innodb_buffer_pool_size = 512M',
          'innodb_default_row_format = DYNAMIC',
          'innodb_file_per_table',
          'innodb_file_per_table = ON',
          'innodb_flush_log_at_trx_commit = 2',
          'innodb_flush_method = O_DIRECT',
          'innodb_log_buffer_size = 64M',
          'innodb_purge_threads = 4',
          'innodb_read_io_threads = 4',
          'innodb_redo_log_capacity = ',
          'innodb_write_io_threads = 4',
          'join_buffer_size = 8M',
          'key_buffer_size = 32M',
          'log_bin_trust_function_creators = 1',
          'log_bin = /var/lib/mysql/mysql-bin',
          'log_slave_updates',
          'long_query_time = 3',
          'max_allowed_packet = 128M',
          'max_connect_errors = 1000000',
          'max_connections = 10000',
          'max_heap_table_size = 128M',
          'myisam-recover-options = FORCE,BACKUP',
          'net_read_timeout = 300',
          'net_write_timeout = 600',
          'open-files-limit = 65536',
          'performance_schema=ON',
          %r{pid-file\s+= /var/lib/mysql/mysql.pid},
          'slave_net_timeout = 60',
          'slave-skip-errors = 1062,1032',
          %r{slow_query_log_file\s+= /var/lib/mysql/mysql-slow.log},
          'sort_buffer_size = 4M',
          'sql-mode = ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION',
          'ssl_ca = ca.pem',
          'ssl_cert = server-cert.pem',
          'ssl_key = server-key.pem',
          'sync_binlog = 1',
          'sysdate_is_now = 1',
          /table_open_cache\s+= 10240/,
          /table_definition_cache\s+= 4096/,
          'thread_cache_size = 108',
          'tmp_table_size = 128M',
          'transaction_isolation = READ-COMMITTED',
          'userstat = true',
          /wait_timeout\s+= 900/,
        ].each do |line|
          it { expect(chef_run).to render_file('/etc/my.cnf').with_content(line) }
        end

        [
          'innodb_log_file_size = 128M',
          'log_warnings',
          'innodb_file_format = barracuda',
          'innodb_large_prefix = true',
          'query_cache_type = 0',
        ].each do |line|
          it { expect(chef_run).to_not render_file('/etc/my.cnf').with_content(line) }
        end
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

      [
        'auto_increment_increment = 3',
        'bind-address = 0.0.0.0',
        /binlog_format\s+= ROW/,
        /character_set_server\s+= utf8mb4/,
        /collation_server\s+= utf8mb4_general_ci/,
        /connect_timeout\s+= 28880/,
        'enforce_gtid_consistency = ON',
        'gtid_mode = ON',
        'innodb_buffer_pool_instances = 1',
        'innodb_buffer_pool_size = 512M',
        'innodb_default_row_format = DYNAMIC',
        'innodb_file_format = barracuda',
        'innodb_file_per_table',
        'innodb_file_per_table = ON',
        'innodb_flush_log_at_trx_commit = 2',
        'innodb_flush_method = O_DIRECT',
        'innodb_large_prefix = true',
        'innodb_log_buffer_size = 64M',
        'innodb_log_files_in_group = 2',
        'innodb_purge_threads = 4',
        'innodb_read_io_threads = 4',
        'innodb_write_io_threads = 4',
        'join_buffer_size = 8M',
        'key_buffer_size = 32M',
        'log_bin_trust_function_creators = 1',
        'log_bin = /var/lib/mysql/mysql-bin',
        'log_warnings',
        'log_slave_updates',
        'long_query_time = 3',
        'max_allowed_packet = 128M',
        'max_connect_errors = 1000000',
        'max_connections = 10000',
        'max_heap_table_size = 128M',
        'myisam-recover-options = FORCE,BACKUP',
        'net_read_timeout = 300',
        'net_write_timeout = 600',
        'open-files-limit = 65536',
        'performance_schema=ON',
        %r{pid-file\s+= /var/lib/mysql/mysql.pid},
        'query_cache_type = 0',
        'slave_net_timeout = 60',
        'slave-skip-errors = 1062,1032',
        %r{slow_query_log_file\s+= /var/lib/mysql/mysql-slow.log},
        'sort_buffer_size = 4M',
        'sql-mode = STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION',
        'ssl_ca = ca.pem',
        'ssl_cert = server-cert.pem',
        'ssl_key = server-key.pem',
        'sync_binlog = 1',
        'sysdate_is_now = 1',
        /table_open_cache\s+= 10240/,
        /table_definition_cache\s+= 4096/,
        'thread_cache_size = 108',
        'tmp_table_size = 128M',
        'transaction_isolation = READ-COMMITTED',
        'userstat = true',
        /wait_timeout\s+= 900/,
      ].each do |line|
        it { expect(chef_run).to render_file('/etc/my.cnf').with_content(line) }
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
