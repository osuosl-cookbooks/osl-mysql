require 'serverspec'

set :backend, :exec

describe file('/opt/chef/embedded/bin/xtrabackup-rb') do
  it { should be_executable }
end

describe file('/usr/local/sbin/xtrabackup-rb') do
  it { should be_linked_to '/opt/chef/embedded/bin/xtrabackup-rb' }
end

describe command('/usr/local/sbin/xtrabackup-rb') do
  its(:exit_status) { should eq 0 }
end
