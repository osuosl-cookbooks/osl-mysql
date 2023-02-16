# Ensure that the port is bound, and the service is running.

describe service('mysql.service') do
  it { should be_enabled }
  it { should be_running }
end

describe port(3306) do
  it { should be_listening }
  its('processes') { should cmp 'mysqld' }
end

# Check to see if the datbases foobar and barfoo exist.
# Using the user foo, to also verify that user exists.

describe mysql_session('foo', 'foofoo').query('USE foobar; USE barfoo') do
  its('exit_status') { should eq(0) }
end
