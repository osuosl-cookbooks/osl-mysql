require 'spec_helper'

describe 'osl_mysql_dev' do
  # Test the initalization of the sql service with a database
  # then add another database as well.

  recipe do
    osl_mysql_dev 'db-one' do
      username 'foo'
      password 'bar'
    end

    osl_mysql_dev 'db-two' do
      username 'foo'
      password 'bar'
    end
  end

  context 'centos' do
    platform 'centos'
    cached(:subject) { chef_run }
    step_into :mysql_test_db

    # mysql_temp create action.

    it do
      is_expected.to install_mariadb_server_install('default').with(
        encoding: 'utf8mb4',
        collation: 'utf8mb4_unicode_ci'
      )
    end
    it { is_expected.to create_mariadb_user('foo').with(password: 'bar') }
    it do
      is_expected.to create_mariadb_database('db-two').with(
        user: 'foo',
        password: 'bar'
      )
    end

    # mysql_test_db db_only action.

    it do
      is_expected.to create_mariadb_database('db-two').with(
        user: 'foo',
        password: 'bar'
      )
    end
  end
end
