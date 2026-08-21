# End-to-end test of mysql-replication-skip: break the applier with a real
# 1032 (delete a row directly on the replica, then delete the same row on the
# source), repair it with the script, and restore the original table state so
# the scenario can be re-run.
#
# Command strings are all unique on purpose: train caches command results by
# string, so a repeated identical command would return the cached output.
control 'replication-skip' do
  impact 1.0
  title 'mysql-replication-skip repairs a replica stopped on error 1032'

  describe file('/usr/local/sbin/mysql-replication-skip') do
    it { should be_file }
    it { should be_executable }
  end

  describe command('/usr/local/sbin/mysql-replication-skip --help') do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/--max-skips/) }
  end

  # healthy applier: refuses to do anything
  describe command('/usr/local/sbin/mysql-replication-skip') do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/nothing to do/) }
  end

  # create drift on the replica (row vanishes outside the binlog), then have
  # the source delete the same row so the applier fails with 1032
  break_replication = <<~EOS
    set -e
    mysql --defaults-extra-file=/root/.my.cnf -e 'SET sql_log_bin=0; DELETE FROM testdb.example WHERE id = 4'
    mysql -h source.testing.osuosl.org -u skiptest -p'Sk1pT3st-Passw0rd' -e 'DELETE FROM testdb.example WHERE id = 4' 2>/dev/null
    errno=''
    for _ in $(seq 1 30); do
      errno=$(mysql --defaults-extra-file=/root/.my.cnf -BN -e 'SELECT LAST_ERROR_NUMBER FROM performance_schema.replication_applier_status_by_worker WHERE LAST_ERROR_NUMBER <> 0 LIMIT 1')
      [ -n "$errno" ] && break
      sleep 2
    done
    echo "errno=$errno"
  EOS

  describe command(break_replication) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/errno=1032/) }
  end

  describe command('/usr/local/sbin/mysql-replication-skip --dry-run') do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/Would skip [0-9a-f-]+:[0-9]+ \(error 1032\)/) }
  end

  # dry-run must not have fixed anything
  describe command('mysql --defaults-extra-file=/root/.my.cnf -BN -e "SELECT SERVICE_STATE FROM performance_schema.replication_applier_status" | sort -u | head -1') do
    its('stdout') { should match(/OFF/) }
  end

  describe command('/usr/local/sbin/mysql-replication-skip --max-skips 10') do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/skipped [0-9a-f-]+:[0-9]+ \(error 1032\)/) }
    its('stdout') { should match(/after skipping 1 transaction/) }
    its('stdout') { should match(/pt-table-checksum/) }
  end

  describe mysql_session('root', 'jzYY0cQUnPAMcqvIxYaC').query('SHOW REPLICA STATUS\G') do
    its('stdout') { should match 'Replica_IO_Running: Yes' }
    its('stdout') { should match 'Replica_SQL_Running: Yes' }
  end

  describe file('/var/log/mysql-replication-skip.log') do
    it { should be_file }
    its('content') { should match(/skipped [0-9a-f-]+:[0-9]+ \(error 1032\)/) }
    its('content') { should match(/after skipping 1 transaction/) }
  end

  # put the row back via the source and confirm it replicates cleanly,
  # leaving the cluster in its original state
  restore_row = <<~EOS
    set -e
    mysql -h source.testing.osuosl.org -u skiptest -p'Sk1pT3st-Passw0rd' -e "INSERT INTO testdb.example (id, name) VALUES (4, 'world')" 2>/dev/null
    n=0
    for _ in $(seq 1 30); do
      n=$(mysql --defaults-extra-file=/root/.my.cnf -BN -e 'SELECT COUNT(*) FROM testdb.example WHERE id = 4')
      [ "$n" = 1 ] && break
      sleep 2
    done
    echo "restored=$n"
  EOS

  describe command(restore_row) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/restored=1/) }
  end

  # healthy again: a fresh run has nothing to skip
  describe command('/usr/local/sbin/mysql-replication-skip --wait 1') do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/nothing to do/) }
  end
end
