control 'query guard' do
  describe package 'percona-toolkit' do
    it { should be_installed }
  end

  {
    'guarded_user' => 60,
    'other_user' => 120,
  }.each do |user, busy_time|
    describe file "/etc/systemd/system/pt-kill-#{user}.service" do
      its('content') do
        should match Regexp.new(
          Regexp.escape(
            "ExecStart=/usr/bin/pt-kill --defaults-file=/root/.my.cnf --match-user ^#{user}$$ " \
            '--match-command ^(Query|Execute)$$ --kill-busy-commands Query,Execute ' \
            "--busy-time #{busy_time} --victims all --kill-query --print --no-version-check " \
            "--sentinel /run/pt-kill-#{user}.sentinel --interval 10"
          ) + '$'
        )
      end
      its('content') { should match /^RestartSec=5$/ }
    end

    describe service "pt-kill-#{user}" do
      it { should be_enabled }
      it { should be_running }
    end
  end

  describe file '/etc/systemd/system/pt-kill-old_user.service' do
    it { should_not exist }
  end

  # pt-kill is silent until it kills something; it only logs when it cannot reach mysqld
  describe command 'journalctl -u pt-kill-guarded_user --no-pager' do
    its('stdout') { should_not match /Access denied|Can't connect|Lost connection/ }
  end
end
