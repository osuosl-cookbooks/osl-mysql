require 'spec_helper'

SET_CONNECT_TIMEOUT = 'SET GLOBAL connect_timeout = 10'.freeze

describe 'osl_mysql_global_variable' do
  step_into :osl_mysql_global_variable
  platform 'almalinux', '9'

  recipe do
    osl_mysql_global_variable 'connect_timeout' do
      value 10
    end
  end

  context 'live value differs' do
    before do
      allow_any_instance_of(OslMysql::Cookbook::Helpers).to receive(:osl_mysql_global_variable_value)
        .with('connect_timeout', '/root/.my.cnf').and_return('28880')
    end

    it do
      is_expected.to run_execute(SET_CONNECT_TIMEOUT).with(
        command: ['mysql', '--defaults-file=/root/.my.cnf', '-e', SET_CONNECT_TIMEOUT]
      )
    end
  end

  context 'live value already matches' do
    before do
      allow_any_instance_of(OslMysql::Cookbook::Helpers).to receive(:osl_mysql_global_variable_value).and_return('10')
    end

    it { is_expected.to_not run_execute(SET_CONNECT_TIMEOUT) }
  end

  context 'mysqld is down' do
    before do
      allow_any_instance_of(OslMysql::Cookbook::Helpers).to receive(:osl_mysql_global_variable_value).and_return(nil)
    end

    it { is_expected.to_not run_execute(SET_CONNECT_TIMEOUT) }
  end

  context 'a value with a leading zero' do
    recipe do
      osl_mysql_global_variable 'connect_timeout' do
        value '010'
      end
    end

    before do
      allow_any_instance_of(OslMysql::Cookbook::Helpers).to receive(:osl_mysql_global_variable_value).and_return('28880')
    end

    # @@GLOBAL reads back 10 for 010, so an uncoerced '010' would SET on every converge
    it { is_expected.to set_osl_mysql_global_variable('connect_timeout').with(value: '10') }
    it { is_expected.to run_execute(SET_CONNECT_TIMEOUT) }
  end

  context 'a value that is not a plain number' do
    recipe do
      osl_mysql_global_variable 'max_allowed_packet' do
        value '128M'
      end
    end

    it { expect { chef_run }.to raise_error(Chef::Exceptions::ValidationFailed) }
  end

  context 'a variable name that is not a plain identifier' do
    recipe do
      osl_mysql_global_variable 'connect_timeout; DROP' do
        value 10
      end
    end

    it { expect { chef_run }.to raise_error(Chef::Exceptions::ValidationFailed) }
  end
end
