require 'spec_helper'

describe 'mysql_test_db' do
  # Test the initalization of the sql service with a database
  # then add another database as well.

  recipe do
    mysql_test_db 'tracklist' do
      username 'randy'
      password 'dont-you-know'
      root_password 'play-with-fire'
    end

    mysql_test_db 'second-tracklist' do
      username 'randy'
      password 'dont-you-know'
      action :db_only
    end
  end

  context 'centos' do
    platform 'centos'
    cached(:subject) { chef_run }
    step_into :mysql_test_db

    # mysql_test_db create action.

    it { is_expected.to install_package('mysql') }
    it {
      is_expected.to create_mysql_service('default').with(
      initial_root_password: 'play-with-fire',
      charset: 'utf8mb4_unicode_ci'
    )
    }
    it { is_expected.to create_mysql_user('randy').with(password: 'dont-you-know') }
    it {
      is_expected.to create_mysql_database('tracklist').with(
      user: 'randy',
      password: 'dont-you-know'
    )
    }

    # mysql_test_db db_only action.

    it {
      is_expected.to mysql_database('second-tracklist').with(
      user: 'randy',
      password: 'dont-you-know'
    )
    }
  end
end
