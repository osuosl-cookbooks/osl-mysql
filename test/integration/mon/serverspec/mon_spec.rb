require 'serverspec'

set :backend, :exec

describe file('/etc/nagios/mysql.cnf') do
  its(:content) { should match(/user = monitor/) }
  its(:content) { should match(/password = ToJzwUyqQmyV4GgMVpz0/) }
  it { should be_mode 600 }
  it { should be_owned_by 'nrpe' }
  it { should be_grouped_into 'nrpe' }
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

describe file('/etc/munin/plugin-conf.d/mysql') do
  its(:content) { should match(/env.mysqluser monitor/) }
  its(:content) { should match(/env.mysqlpassword ToJzwUyqQmyV4GgMVpz0/) }
  it { should be_mode 600 }
  it { should be_owned_by 'munin' }
  it { should be_grouped_into 'munin' }
end

%w(
  bin_relay_log
  commands
  connections
  innodb_bpool
  innodb_bpool_act
  innodb_semaphores
  qcache
  qcache_mem
  queries
  slow
  slowqueries
  table_locks
  threads
  tmp_tables
).each do |p|
  describe command("/usr/sbin/munin-run mysql_#{p}") do
    its(:exit_status) { should eq 0 }
  end
end
