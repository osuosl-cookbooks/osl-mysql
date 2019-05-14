describe file('/data/backup') do
  it { should be_directory }
  its('mode') { should cmp 0700 }
  its('owner') { should eq 'root' }
  its('group') { should eq 'root' }
end
