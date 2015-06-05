require 'serverspec'

set :backend, :exec

describe file('/data/backup') do
  it { should be_directory }
  it { should be_mode 700 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end
