control 'mon' do
  describe file('/etc/nagios/mysql.cnf') do
    its('mode') { should cmp 0600 }
    its('owner') { should eq 'nrpe' }
    its('group') { should eq 'nrpe' }
  end

  describe ini('/etc/nagios/mysql.cnf') do
    its('client.user') { should eq 'monitor' }
    its('client.password') { should eq 'ToJzwUyqQmyV4GgMVpz0' }
  end

  %w(
    innodb
    pidfile
    processlist
    replication-delay
  ).each do |p|
    describe file("/etc/nagios/nrpe.d/pmp-check-mysql-#{p}.cfg") do
      its('content') do
        should match(%r{command\[pmp-check-mysql-#{p}\]=\/usr/lib64/nagios/plugins/pmp-check-mysql-#{p}})
      end
    end
    describe command("/usr/lib64/nagios/plugins/pmp-check-mysql-#{p}") do
      its('stdout') { should match(/^OK/) }
      its('exit_status') { should eq 0 }
    end
  end

  describe command('/usr/local/libexec/mysql-accounting') do
    its('exit_status') { should eq 0 }
  end
end
