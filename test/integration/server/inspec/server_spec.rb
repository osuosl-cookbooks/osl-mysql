%w(
  Percona-Server-server-57
  Percona-Server-devel-57
  Percona-Server-shared-57
).each do |p|
  describe package(p) do
    it { should be_installed }
  end
end

if os.release.to_i >= 8
  describe package('percona-xtrabackup-80') do
    it { should be_installed }
  end
else
  describe package('percona-xtrabackup') do
    it { should be_installed }
  end
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
  its('mysqld.innodb_large_prefix') { should eq 'true' } if os.release.to_i < 8 # Deprecated in mysql 5.7
  its('mysqld.userstat') { should eq 'true' }
  # percona cookbook adds a second mysqld section for the above settings
  # mysql_conf/ini inspec resource seems to only give you the second section
  its('content') { should match(/^innodb_file_format = barracuda$/) } if os.release.to_i < 8 # Deprecated in mysql 5.7
  its('content') { should match(/^innodb_file_per_table$/) }
  its('content') { should match(/^innodb_buffer_pool_size = 2652M$/) } if os.release.to_i < 8
  its('content') { should match(/^innodb_buffer_pool_size = 2746M$/) } if os.release.to_i >= 8 && os.name == 'almalinux'
end

describe kernel_parameter('vm.swappiness') do
  its('value') { should eq 0 }
end

describe kernel_parameter('vm.min_free_kbytes') do
  its('value') { should eq 38799 } if os.release.to_i < 8
  its('value') { should eq 40171 } if os.release.to_i >= 8 && os.name == 'almalinux'
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
