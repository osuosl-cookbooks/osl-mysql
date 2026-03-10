control 'client-percona' do
  pkgs = %w(percona-server-client percona-server-devel)
  pkgs.each do |p|
    describe package(p) do
      it { should be_installed }
    end
  end
end
