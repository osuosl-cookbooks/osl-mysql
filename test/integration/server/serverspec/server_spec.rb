require 'serverspec'

set :backend, :exec

case os[:family].downcase
when 'redhat', 'centos', 'fedora'
  packages = [ 'Percona-Server-shared-56', 'Percona-Server-server-56',
               'percona-toolkit', 'percona-xtrabackup' ]
when 'debian', 'ubuntu'
  packages = [ 'percona-server-server-5.6', 'percona-server-common-5.6',
               'percona-server-client-5.6', 'percona-toolkit',
               'percona-xtrabackup' ]
end

packages.each do |p|
  describe package(p) do
    it { should be_installed }
  end
end

# Mysql packages should not be installed
%w[ mysql mysql-libs mysql55-libs ].each do |p|
  describe package(p) do
    it { should_not be_installed }
  end
end

%w[ mysqld_safe mysqld ].each do |p|
  describe process(p) do
    it { should be_running }
  end
end
describe port(3306) do
  it { should be_listening }
end

describe file('/root/.my.cnf') do
  it { should be_file }
  its(:content) { should match /jzYY0cQUnPAMcqvIxYaC/ }
end
