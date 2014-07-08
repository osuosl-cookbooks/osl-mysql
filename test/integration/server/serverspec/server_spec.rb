require 'serverspec'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

%w[ Percona-Server-shared-55
Percona-Server-server-55
percona-toolkit
percona-xtrabackup ].each do |p|
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
