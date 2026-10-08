require 'spec_helper'

def query_guard_exec(user, busy_time: 120, interval: 10, defaults_file: '/root/.my.cnf')
  "/usr/bin/pt-kill --defaults-file=#{defaults_file} --match-user ^#{user}$$ " \
    '--match-command ^(Query|Execute)$$ --kill-busy-commands Query,Execute ' \
    "--busy-time #{busy_time} --victims all --kill-query --print --no-version-check " \
    "--sentinel /run/pt-kill-#{user}.sentinel --interval #{interval}"
end

def stub_guard_units(*users)
  allow(Dir).to receive(:glob).and_call_original
  allow(Dir).to receive(:glob).with('/etc/systemd/system/pt-kill-*.service').and_return(
    users.map { |u| "/etc/systemd/system/pt-kill-#{u}.service" }
  )
end

describe 'osl_mysql_query_guard' do
  step_into :osl_mysql_query_guard

  [ALMA_8, ALMA_9].each do |p|
    context "on #{p[:platform]} #{p[:version]}" do
      platform p[:platform], p[:version]

      context 'two rules, one with its own busy time' do
        recipe do
          osl_mysql_query_guard 'test' do
            rules [{ 'user' => 'forum_user', 'busy_time' => 60 }, { 'user' => 'wiki_user' }]
          end
        end

        before { stub_guard_units }

        cached(:subject) { chef_run }

        it { is_expected.to install_package('percona-toolkit') }

        it do
          is_expected.to create_systemd_unit('pt-kill-forum_user.service').with(
            content: {
              Unit: {
                Description: 'pt-kill guard for MySQL user forum_user',
                After: 'mysqld.service',
              },
              Service: {
                ExecStart: query_guard_exec('forum_user', busy_time: 60),
                Restart: 'always',
                RestartSec: 5,
              },
              Install: {
                WantedBy: 'multi-user.target',
              },
            }
          )
        end

        it do
          expect(chef_run.systemd_unit('pt-kill-wiki_user.service').content[:Service][:ExecStart]).to eq \
            query_guard_exec('wiki_user')
        end

        %w(pt-kill-forum_user.service pt-kill-wiki_user.service).each do |unit|
          it { is_expected.to enable_service(unit) }
          it { is_expected.to start_service(unit) }
          it { expect(chef_run.service(unit)).to subscribe_to("systemd_unit[#{unit}]").on(:restart).delayed }
        end

        it { is_expected.to_not stop_service('pt-kill-forum_user.service') }
      end

      context 'a unit on disk for a user no longer in the rules' do
        recipe do
          osl_mysql_query_guard 'test' do
            rules [{ user: 'forum_user' }]
            busy_time 300
            interval 5
            defaults_file '/etc/guard.cnf'
          end
        end

        before { stub_guard_units('forum_user', 'old_user') }

        cached(:subject) { chef_run }

        it do
          expect(chef_run.systemd_unit('pt-kill-forum_user.service').content[:Service][:ExecStart]).to eq \
            query_guard_exec('forum_user', busy_time: 300, interval: 5, defaults_file: '/etc/guard.cnf')
        end

        it { is_expected.to start_service('pt-kill-forum_user.service') }
        it { is_expected.to_not delete_systemd_unit('pt-kill-forum_user.service') }
        it { is_expected.to stop_service('pt-kill-old_user.service') }
        it { is_expected.to disable_service('pt-kill-old_user.service') }
        it { is_expected.to delete_systemd_unit('pt-kill-old_user.service') }
      end

      context 'empty rules with units on disk' do
        recipe do
          osl_mysql_query_guard 'test'
        end

        before { stub_guard_units('forum_user', 'wiki_user') }

        cached(:subject) { chef_run }

        it { is_expected.to install_package('percona-toolkit') }

        %w(pt-kill-forum_user.service pt-kill-wiki_user.service).each do |unit|
          it { is_expected.to stop_service(unit) }
          it { is_expected.to disable_service(unit) }
          it { is_expected.to delete_systemd_unit(unit) }
        end
      end

      context 'delete action' do
        recipe do
          osl_mysql_query_guard 'test' do
            action :delete
          end
        end

        before { stub_guard_units('forum_user') }

        cached(:subject) { chef_run }

        it { is_expected.to_not install_package('percona-toolkit') }
        it { is_expected.to stop_service('pt-kill-forum_user.service') }
        it { is_expected.to disable_service('pt-kill-forum_user.service') }
        it { is_expected.to delete_systemd_unit('pt-kill-forum_user.service') }
      end

      {
        'a user name systemd would misread' => { rules: [{ 'user' => 'forum@user' }] },
        'a rule busy time that is not a positive Integer' => { rules: [{ 'user' => 'forum_user', 'busy_time' => '120' }] },
        'the same user twice' => { rules: [{ 'user' => 'forum_user' }, { 'user' => 'forum_user', 'busy_time' => 60 }] },
        'a misspelled key' => { rules: [{ 'user' => 'forum_user', 'busytime' => 60 }] },
        'a default busy time of 0' => { busy_time: 0 },
        'a negative interval' => { interval: -1 },
      }.each do |desc, props|
        context desc do
          recipe do
            osl_mysql_query_guard 'test' do
              props.each { |k, v| send(k, v) }
            end
          end

          it { expect { chef_run }.to raise_error(Chef::Exceptions::ValidationFailed) }
        end
      end
    end
  end

  context 'on almalinux 10' do
    platform 'almalinux', '10'

    recipe do
      osl_mysql_query_guard 'test' do
        rules [{ 'user' => 'forum_user' }]
      end
    end

    it { expect { chef_run }.to raise_error(RuntimeError, /EL8 and EL9 only/) }
  end
end
