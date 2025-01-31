vagrant = inspec.file('/home/vagrant').exist?
docker = inspec.command('test -e /.dockerenv')

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
  its('mysqld.log_bin_trust_function_creators') { should eq '1' }
  its('mysqld.userstat') { should eq 'true' }
  its('mysqld.slave-skip-errors') { should eq '1062,1032' }
  its('content') { should match(/^innodb_file_per_table$/) }
  its('mysqld.innodb_buffer_pool_size') { should eq '2557M' } unless vagrant || docker
end

describe command "mysqladmin --user='root' --password='jzYY0cQUnPAMcqvIxYaC' variables" do
  its('stdout') { should match /max_connections\s+\| 1000/ }
  its('stdout') { should match /open_files_limit\s+\| 65535/ }
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
