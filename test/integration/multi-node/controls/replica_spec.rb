control 'replica' do
  describe mysql_session('root', 'jzYY0cQUnPAMcqvIxYaC').query('SHOW SLAVE STATUS\G') do
    its('stdout') { should match 'Slave_IO_State: Waiting for master to send event' }
    its('stdout') { should match 'Master_Host: source.testing.osuosl.org' }
    its('stdout') { should match 'Master_User: replication' }
    its('stdout') { should match 'Master_Port: 3306' }
    its('stdout') { should match 'Slave_IO_Running: Yes' }
    its('stdout') { should match 'Slave_SQL_Running: Yes' }
    its('stdout') { should match 'Seconds_Behind_Master: 0' }
  end
end
