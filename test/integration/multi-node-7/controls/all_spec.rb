control 'all' do
  %w(11 12).each do |suff|
    describe host("192.168.60.#{suff}") do
      it { should be_reachable }
    end
  end

  describe host('192.168.60.13') do
    it { should_not be_reachable }
  end

  if os.release.to_i >= 8
    %w(
      Percona-Server-server-57
      Percona-Server-devel-57
      Percona-Server-shared-57
    ).each do |p|
      describe package(p) do
        it { should be_installed }
      end
    end
  else
    %w(
      Percona-Server-server-56
      Percona-Server-devel-56
      Percona-Server-shared-56
      percona-toolkit
      percona-xtrabackup
    ).each do |p|
      describe package(p) do
        it { should be_installed }
      end
    end
  end

  # Mysql packages should not be installed
  %w(
    mysql
    mysql-libs
    mysql55-libs
  ).each do |p|
    describe package(p) do
      it { should_not be_installed }
    end
  end

  if os.release.to_i < 8
    describe processes('mysqld_safe') do
      it { should exist }
    end
  end

  describe processes('mysqld') do
    it { should exist }
  end

  describe port(3306) do
    it { should be_listening }
  end

  describe file('/root/.my.cnf') do
    it { should be_file }
  end

  describe ini('/root/.my.cnf') do
    its('client.user') { should eq 'root' }
    its('client.password') { should eq '\'jzYY0cQUnPAMcqvIxYaC\'' }
    its('mysqladmin.user') { should eq 'root' }
    its('mysqladmin.password') { should eq '\'jzYY0cQUnPAMcqvIxYaC\'' }
    its('mysqldump.user') { should eq 'root' }
    its('mysqldump.password') { should eq '\'jzYY0cQUnPAMcqvIxYaC\'' }
  end

  describe mysql_conf('/etc/my.cnf') do
    its('mysqld.log_bin_trust_function_creators') { should eq '1' }
    its('mysqld.innodb_large_prefix') { should eq 'true' } if os.release.to_i < 8
    # percona cookbook adds a second mysqld section for the above settings
    # mysql_conf/ini inspec resource seems to only give you the second section
    its('content') { should match(/^innodb_file_format = barracuda$/) } if os.release.to_i < 8
    its('content') { should match(/^innodb_file_per_table$/) }
  end

  describe kernel_parameter('vm.swappiness') do
    its('value') { should eq 0 }
  end

  describe yum.repo('percona-noarch') do
    it { should be_enabled }
  end

  describe crontab do
    its('minutes') { should include '0' }
    its('hours') { should include '0' }
    its('days') { should include '*' }
    its('months') { should include '*' }
    its('weekdays') { should include '*' }
    its('commands') do
      should include '/usr/local/libexec/mysql-accounting'
    end
  end

  describe crontab do
    its('minutes') { should include '*/30' }
    its('hours') { should include '*' }
    its('days') { should include '*' }
    its('months') { should include '*' }
    its('weekdays') { should include '*' }
    its('commands') do
      should include '/usr/local/libexec/mysql-prometheus'
    end
  end

  describe command('/usr/local/libexec/mysql-accounting') do
    its('exit_status') { should eq 0 }
  end

  describe command('/usr/local/libexec/mysql-prometheus') do
    its(:exit_status) { should eq 0 }
  end

  describe file('/var/lib/node_exporter/mysql_db_size.prom') do
    [
      /^mysql_db_size_start_time [0-9].+$/,
      /^mysql_db_size\{name="information_schema"\} [0-9]+$/,
      /^mysql_db_size\{name="mysql"\} [0-9].+$/,
      /^mysql_db_size\{name="performance_schema"\} [0-9]+$/,
      /^mysql_db_size_completion_time [0-9].+$/,
    ].each do |line|
      its(:content) { should match(line) }
    end
  end

  sql = mysql_session('root', 'jzYY0cQUnPAMcqvIxYaC')
  describe sql.query('SHOW databases') do
    its('stdout') { should match 'testdb' }
  end

  describe sql.query('SHOW tables IN testdb') do
    its('stdout') { should match 'example' }
  end

  describe sql.query('SELECT * FROM testdb.example') do
    its('stdout') { should match "1\thello" }
    its('stdout') { should match "2\tworld" }
  end
end
