control 'replica' do
  # MySQL 8.4 removed SHOW SLAVE STATUS and the Slave_*/Master_* field names.
  # SHOW REPLICA STATUS and the Replica_*/Source_* names work on 8.0.22+ and 8.4.
  describe mysql_session('root', 'jzYY0cQUnPAMcqvIxYaC').query('SHOW REPLICA STATUS\G') do
    its('stdout') { should match(/Replica_IO_State: Waiting for (master|source) to send event/) }
    its('stdout') { should match 'Source_Host: source.testing.osuosl.org' }
    its('stdout') { should match 'Source_User: replication' }
    its('stdout') { should match 'Source_Port: 3306' }
    its('stdout') { should match 'Replica_IO_Running: Yes' }
    its('stdout') { should match 'Replica_SQL_Running: Yes' }
    its('stdout') { should match 'Seconds_Behind_Source: 0' }
  end
end
