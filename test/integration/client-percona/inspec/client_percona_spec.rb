if os.release.to_i < 8
  %w(Percona-Server-client-56 Percona-Server-devel-56).each do |p|
    describe package(p) do
      it { should be_installed }
    end
  end
else
  %w(Percona-Server-client-57 Percona-Server-devel-57).each do |p|
    describe package(p) do
      it { should be_installed }
    end
  end
end
