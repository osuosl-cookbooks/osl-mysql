require 'serverspec'

set :backend, :exec

%w(
  Percona-Server-server-56
  Percona-Server-devel-56
  Percona-Server-shared-56
  percona-toolkit
  percona-xtrabackup
).each do |p|
  describe package(p) do
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

%w(mysqld_safe mysqld).each do |p|
  describe process(p) do
    it { should be_running }
  end
end
describe port(3306) do
  it { should be_listening }
end

describe file('/root/.my.cnf') do
  it { should be_file }
  its(:content) { should match(/jzYY0cQUnPAMcqvIxYaC/) }
end

describe command('sysctl vm.swappiness') do
  its(:stdout) { should match(/vm.swappiness = 0/) }
  its(:exit_status) { should eq 0 }
end

describe file('/etc/sysctl.d/99-chef-vm.swappiness.conf') do
  its(:content) { should match(/vm.swappiness = 0/) }
end

describe yumrepo('percona-noarch') do
  it { should be_enabled }
end

describe cron do
  it { should have_entry '@daily /usr/local/libexec/mysql-accounting' }
end

describe cron do
  it { should have_entry '*/30 * * * * /usr/local/libexec/mysql-prometheus' }
end

describe command('/usr/local/libexec/mysql-accounting') do
  its(:exit_status) { should eq 0 }
end

describe command('/usr/local/libexec/mysql-prometheus') do
  its(:exit_status) { should eq 0 }
end

describe file('/var/lib/node_exporter/mysql_db_size.prom') do
  [
    /^mysql_db_size_start_time [0-9].+$/,
    /^mysql_db_size\{name="information_schema"\} [0-9].+$/,
    /^mysql_db_size\{name="mysql"\} [0-9].+$/,
    /^mysql_db_size\{name="performance_schema"\} [0-9]+$/,
    /^mysql_db_size_completion_time [0-9].+$/,
  ].each do |line|
    its(:content) { should match(line) }
  end
end
