%w(Percona-Server-client-57 Percona-Server-devel-57).each do |p|
  describe package(p) do
    it { should be_installed }
  end
end
