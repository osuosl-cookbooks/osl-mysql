require 'spec_helper'

describe 'osl_mysql_test' do
  # Test the initalization of the sql service with a database
  # then add another database as well.

  recipe do
    osl_mysql_test 'db-one' do
      username 'foo'
      password 'bar'
    end
  end

  context 'almalinux 8' do
    platform 'almalinux', '8'
    cached(:subject) { chef_run }
    step_into :osl_mysql_test

    it do
      is_expected.to install_mariadb_server_install('osl-mysql-test').with(
        password: 'osl_mysql_test',
        version: '10.11',
        setup_repo: false
      )
    end

    it { is_expected.to create_mariadb_server_install('osl-mysql-test') }
    it { is_expected.to_not include_recipe 'osl-repos::epel' }

    it do
      is_expected.to create_mariadb_database('db-one').with(
        collation: 'utf8mb4_unicode_ci',
        encoding: 'utf8mb4',
        password: 'osl_mysql_test'
      )
    end

    it do
      is_expected.to create_mariadb_user('foo').with(
        ctrl_password: 'osl_mysql_test',
        password: 'bar',
        database_name: 'db-one'
      )
    end

    it do
      is_expected.to grant_mariadb_user('foo').with(
        ctrl_password: 'osl_mysql_test',
        password: 'bar',
        database_name: 'db-one'
      )
    end

    it do
      is_expected.to create_template('/root/.my.cnf').with(
        cookbook: 'osl-mysql',
        source: 'my.cnf.erb',
        mode: '0640',
        sensitive: true,
        variables: { password: 'osl_mysql_test' }
      )
    end
  end
end
