docker = inspec.command('test -e /.dockerenv')

# Ensure that the port is bound, and the service is running.

describe service('mariadb.service') do
  it { should be_enabled }
  it { should be_running }
end

describe file '/root/.my.cnf' do
  its('owner') { should eq 'root' }
  its('group') { should eq'root' }
  its('mode') { should cmp '0640' }
  its('content') { should match /^password='osl_mysql_test'$/ }
end

describe port(3306) do
  it { should be_listening }
  its('processes') { should be_in %w(mysqld mariadbd) }
end

# Firewall rules should allow mysql
describe iptables do
  it { should have_rule('-A INPUT -j mysql') }
  it { should have_rule('-A mysql -p tcp -m tcp --dport 3306 -j ACCEPT') }
end unless docker

# Check to see if the datbases foobar and barfoo exist.
# Using the user foo, to also verify that user exists.
describe mysql_session('foo', 'foofoo').query('USE foobar; USE barfoo') do
  its('exit_status') { should eq 0 }
end

# Check to see if the user bar exists, who also owns newuser_db
describe mysql_session('bar', 'barbar').query('USE newuser_db; SELECT @@collation_database') do
  its('exit_status') { should eq 0 }
  its('output') { should match /latin1_swedish_ci/ }
end

# Check to ensure that the failed resource did not go through
describe mysql_session('root', 'osl_mysql_test').query('SHOW DATABASES LIKE \'failing_db\'') do
  its('output') { should eq '' }
end
