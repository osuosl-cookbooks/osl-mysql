pkg_name = os.release.to_i >= 7 ? 'mariadb' : 'mysql'

[pkg_name, "#{pkg_name}-devel"].each do |p|
  describe package(p) do
    it { should be_installed }
  end
end
