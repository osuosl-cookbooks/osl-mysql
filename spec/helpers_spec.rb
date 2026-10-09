require 'spec_helper'
require_relative '../libraries/helpers'

RSpec.describe OslMysql::Cookbook::Helpers do
  subject do
    Class.new do
      include Chef::Mixin::ShellOut
      include OslMysql::Cookbook::Helpers
    end.new
  end

  describe '#osl_mysql_global_variable_value' do
    let(:ping) { ['mysqladmin', '--defaults-file=/root/.my.cnf', 'ping'] }
    let(:select) { ['mysql', '--defaults-file=/root/.my.cnf', '-NBe', 'SELECT @@GLOBAL.connect_timeout'] }

    it 'returns the live value when mysqld answers' do
      allow(subject).to receive(:shell_out).with(*ping).and_return(double(exitstatus: 0))
      allow(subject).to receive(:shell_out!).with(*select).and_return(double(stdout: "28880\n"))
      expect(subject.osl_mysql_global_variable_value('connect_timeout', '/root/.my.cnf')).to eq('28880')
    end

    it 'returns nil when mysqld is down' do
      allow(subject).to receive(:shell_out).with(*ping).and_return(double(exitstatus: 1))
      expect(subject).to_not receive(:shell_out!)
      expect(subject.osl_mysql_global_variable_value('connect_timeout', '/root/.my.cnf')).to be_nil
    end

    it 'raises on an SQL error instead of skipping' do
      allow(subject).to receive(:shell_out).with(*ping).and_return(double(exitstatus: 0))
      allow(subject).to receive(:shell_out!).with(*select).and_raise(Mixlib::ShellOut::ShellCommandFailed)
      expect { subject.osl_mysql_global_variable_value('connect_timeout', '/root/.my.cnf') }.to raise_error(Mixlib::ShellOut::ShellCommandFailed)
    end
  end
end
