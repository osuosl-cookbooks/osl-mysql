chef_path = inspec.file('/opt/chef/bin/chef-client').exist? ? 'chef' : 'cinc'

describe file('/usr/local/src/xtrabackup-rb') do
  it { should be_directory }
end

describe file("/opt/#{chef_path}/embedded/bin/xtrabackup-rb") do
  it { should be_executable }
end

describe file('/usr/local/sbin/xtrabackup-rb') do
  it { should be_linked_to "/opt/#{chef_path}/embedded/bin/xtrabackup-rb" }
end

describe command('/usr/local/sbin/xtrabackup-rb') do
  its(:exit_status) { should eq 0 }
end

if os.release.to_i < 8
  describe package('percona-xtrabackup') do
    it { should be_installed }
  end
else
  describe package('percona-xtrabackup-80') do
    it { should be_installed }
  end
end
