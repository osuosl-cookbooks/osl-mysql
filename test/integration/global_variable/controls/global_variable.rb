control 'global variable' do
  # SET GLOBAL changed the running server only; my.cnf keeps osl-mysql's value
  describe mysql_conf('/etc/my.cnf') do
    its('mysqld.wait_timeout') { should cmp '900' }
  end

  describe command("mysqladmin --user='root' --password='jzYY0cQUnPAMcqvIxYaC' variables") do
    its('stdout') { should match /\| wait_timeout\s+\| 1000\s+\|/ }
    its('exit_status') { should eq 0 }
  end
end
