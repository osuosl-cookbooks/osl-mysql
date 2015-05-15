require 'serverspec'

set :backend, :exec

%w(
  Percona-Server-server-56
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
