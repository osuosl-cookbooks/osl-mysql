require 'serverspec'

set :backend, :exec

describe command('sysctl vm.swappiness') do
  its(:stdout) { should match(/vm.swappiness = 0/) }
  its(:exit_status) { should eq 0 }
end
