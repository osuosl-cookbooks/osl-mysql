version = input('version')

control 'client-percona' do
  pkgs =
    case version
    when '8.0'
      %w(percona-server-client percona-server-devel)
    end
  pkgs.each do |p|
    describe package(p) do
      it { should be_installed }
    end
  end
end
