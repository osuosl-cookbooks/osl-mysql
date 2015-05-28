require 'serverspec'

set :backend, :exec

describe file('/etc/nagios/mysql.cnf') do
  its(:content) { should match(/user = monitor/) }
  its(:content) { should match(/password = ToJzwUyqQmyV4GgMVpz0/) }
  it { should be_mode 600 }
  it { should be_owned_by 'nagios' }
  it { should be_grouped_into 'nagios' }
end

%w(
  innodb
  pidfile
  processlist
  replication-delay
).each do |p|
  describe file("/etc/nagios/nrpe.d/pmp-check-mysql-#{p}.cfg") do
    its(:content) do
      should match(%r{command\[pmp-check-mysql-#{p}\]=\
/usr/lib64/nagios/plugins/pmp-check-mysql-#{p}})
    end
  end
  describe command("/usr/lib64/nagios/plugins/pmp-check-mysql-#{p}") do
    its(:stdout) { should match(/^OK/) }
    its(:exit_status) { should eq 0 }
  end
end
