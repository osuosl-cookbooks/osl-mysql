require 'serverspec'

set :backend, :exec

if os[:family] == 'redhat' && os[:release].to_i == 7
  describe package 'mariadb' do
    it { should be_installed }
  end
else
  describe package 'mysql' do
    it { should be_installed }
  end
end
