# Ensure that the port is bound, and the service is running.

describe service('mysql.service') do
  it { should be_enabled }
  it { should be_running }
end

describe port(3306) do
  it { should be_listening }
  its('processes') { should cmp 'mysqld' }
end
