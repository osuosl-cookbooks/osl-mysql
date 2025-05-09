vagrant = inspec.file('/home/vagrant').exist?
docker = inspec.command('test -e /.dockerenv')
rel = os.release.to_i

%w(
  Percona-Server-server-57
  Percona-Server-devel-57
  Percona-Server-shared-57
).each do |p|
  describe package(p) do
    it { should be_installed }
  end
end

describe package('percona-xtrabackup-80') do
  it { should be_installed }
end

# Mysql packages should not be installed
%w(
  mysql
  mysql-libs
  mysql55-libs
).each do |p|
  describe package(p) do
    it { should_not be_installed }
  end
end

describe processes('mysqld') do
  it { should exist }
end

describe port(3306) do
  it { should be_listening }
end

describe file('/root/.my.cnf') do
  it { should be_file }
end

describe ini('/root/.my.cnf') do
  its('client.user') { should eq 'root' }
  its('client.password') { should eq '\'jzYY0cQUnPAMcqvIxYaC\'' }
  its('mysqladmin.user') { should eq 'root' }
  its('mysqladmin.password') { should eq '\'jzYY0cQUnPAMcqvIxYaC\'' }
  its('mysqldump.user') { should eq 'root' }
  its('mysqldump.password') { should eq '\'jzYY0cQUnPAMcqvIxYaC\'' }
end

describe mysql_conf('/etc/my.cnf') do
  its('content') { should match(/^innodb_file_per_table$/) }
  its('content') { should match(/^log_warnings$/) }
  its('mysqld.auto_increment_increment') { should eq '3' }
  its('mysqld.bind-address') { should eq '0.0.0.0' }
  its('mysqld.binlog_format') { should eq 'ROW' }
  its('mysqld.character_set_server') { should eq 'utf8mb4' }
  its('mysqld.collation_server') { should eq 'utf8mb4_general_ci' }
  its('mysqld.connect_timeout') { should eq '28880' }
  its('mysqld.innodb_buffer_pool_instances') { should eq '2' } unless vagrant || docker
  case rel
  when 9
    its('mysqld.innodb_buffer_pool_size') { should eq '1829M' } unless vagrant || docker
  when 8
    its('mysqld.innodb_buffer_pool_size') { should eq '1833M' } unless vagrant || docker
  end
  its('mysqld.innodb_default_row_format') { should eq 'DYNAMIC' }
  its('mysqld.innodb_file_format') { should eq 'barracuda' }
  its('mysqld.innodb_file_per_table') { should eq 'ON' }
  its('mysqld.innodb_flush_log_at_trx_commit') { should eq '2' }
  its('mysqld.innodb_flush_method') { should eq 'O_DIRECT' }
  its('mysqld.innodb_large_prefix') { should eq 'true' }
  its('mysqld.innodb_log_buffer_size') { should eq '64M' }
  its('mysqld.innodb_log_files_in_group') { should eq '2' }
  its('mysqld.innodb_log_file_size') { should eq '256M' } unless vagrant || docker
  its('mysqld.innodb_purge_threads') { should eq '4' }
  its('mysqld.innodb_read_io_threads') { should eq '4' }
  its('mysqld.innodb_write_io_threads') { should eq '4' }
  its('mysqld.join_buffer_size') { should eq '8M' }
  its('mysqld.key_buffer_size') { should eq '32M' }
  its('mysqld.log_bin') { should eq '/var/lib/mysql/mysql-bin' }
  its('mysqld.log_bin_trust_function_creators') { should eq '1' }
  its('mysqld.log_bin_trust_function_creators') { should eq '1' }
  its('mysqld.long_query_time') { should eq '3' }
  its('mysqld.max_allowed_packet') { should eq '128M' }
  its('mysqld.max_connect_errors') { should eq '1000000' }
  its('mysqld.max_connections') { should eq '10000' }
  its('mysqld.max_heap_table_size') { should eq '128M' }
  its('mysqld.myisam-recover-options') { should eq 'FORCE,BACKUP' }
  its('mysqld.net_read_timeout') { should eq '300' }
  its('mysqld.net_write_timeout') { should eq '600' }
  its('mysqld.performance_schema') { should eq 'ON' }
  its('mysqld.pid-file') { should eq '/var/lib/mysql/mysql.pid' }
  its('mysqld.query_cache_type') { should eq '0' }
  its('mysqld_safe.open-files-limit') { should eq '65536' }
  its('mysqld.slave_net_timeout') { should eq '60' }
  its('mysqld.slave-skip-errors') { should eq '1062,1032' }
  its('mysqld.slave-skip-errors') { should eq '1062,1032' }
  its('mysqld.slow_query_log_file') { should eq '/var/lib/mysql/mysql-slow.log' }
  its('mysqld.sort_buffer_size') { should eq '4M' }
  its('mysqld.sql-mode') { should eq 'STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' }
  its('mysqld.ssl_ca') { should eq 'ca.pem' }
  its('mysqld.ssl_cert') { should eq 'server-cert.pem' }
  its('mysqld.ssl_key') { should eq 'server-key.pem' }
  its('mysqld.sync_binlog') { should eq '1' }
  its('mysqld.sysdate_is_now') { should eq '1' }
  its('mysqld.table_definition_cache') { should eq '4096' }
  its('mysqld.table_open_cache') { should eq '10240' }
  its('mysqld.thread_cache_size') { should eq '108' }
  its('mysqld.tmp_table_size') { should eq '128M' }
  its('mysqld.transaction_isolation') { should eq 'READ-COMMITTED' }
  its('mysqld.userstat') { should eq 'true' }
  its('mysqld.userstat') { should eq 'true' }
  its('mysqld.wait_timeout') { should eq '900' }
end

describe command "mysqladmin --user='root' --password='jzYY0cQUnPAMcqvIxYaC' variables" do
  its('stdout') { should match /max_connections\s+\| 1000/ }
  its('stdout') { should match /open_files_limit\s+\| 65536/ }
  its('exit_status') { should eq 0 }
end

describe kernel_parameter('vm.swappiness') do
  its('value') { should eq 0 }
end

describe kernel_parameter('vm.min_free_kbytes') do
  its('value') { should eq 37406 } unless vagrant || docker
end

describe yum.repo('percona-noarch') do
  it { should be_enabled }
end

describe crontab do
  its('minutes') { should include '0' }
  its('hours') { should include '0' }
  its('days') { should include '*' }
  its('months') { should include '*' }
  its('weekdays') { should include '*' }
  its('commands') do
    should include '/usr/local/libexec/mysql-accounting'
  end
end

describe crontab do
  its('minutes') { should include '*/30' }
  its('hours') { should include '*' }
  its('days') { should include '*' }
  its('months') { should include '*' }
  its('weekdays') { should include '*' }
  its('commands') do
    should include '/usr/local/libexec/mysql-prometheus'
  end
end

describe command('/usr/local/libexec/mysql-accounting') do
  its('exit_status') { should eq 0 }
end

describe command('/usr/local/libexec/mysql-prometheus') do
  its(:exit_status) { should eq 0 }
end

describe file('/var/lib/node_exporter/mysql_db_size.prom') do
  [
    /^mysql_db_size_start_time [0-9].+$/,
    /^mysql_db_size\{name="information_schema"\} [0-9]+$/,
    /^mysql_db_size\{name="mysql"\} [0-9].+$/,
    /^mysql_db_size\{name="performance_schema"\} [0-9]+$/,
    /^mysql_db_size_completion_time [0-9].+$/,
  ].each do |line|
    its(:content) { should match(line) }
  end
end
