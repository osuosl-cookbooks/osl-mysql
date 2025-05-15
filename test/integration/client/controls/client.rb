control 'client' do
  %w(mariadb mariadb-devel).each do |p|
    describe package(p) do
      it { should be_installed }
    end
  end
end
