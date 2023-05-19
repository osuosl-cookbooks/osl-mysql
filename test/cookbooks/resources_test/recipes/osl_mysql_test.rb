if platform?('centos') && Gem::Version.create(node['platform_version']) < Gem::Version.create(8)
  # Initialize the database service, and create a database
  osl_mysql_test 'foobar' do
    version '10.11'
    username 'foo'
    password 'foofoo'
  end
else
  # Initialize the database service, and create a database
  osl_mysql_test 'foobar' do
    username 'foo'
    password 'foofoo'
  end
end

# Add in an extra database to the same user
osl_mysql_test 'barfoo' do
  username 'foo'
  password 'foofoo'
end

# Make another user that owns another database, has a different encoding scheme
osl_mysql_test 'newuser_db' do
  username 'bar'
  password 'barbar'
  encoding 'latin1'
  collation 'latin1_swedish_ci'
end

# Set up a resource to fail to show off changing the root password
begin
  osl_mysql_test 'failing_db' do
    username 'baz'
    password 'bazbaz'
    root_password 'This Password Does Not Exist'
    ignore_failure :quiet
  end
rescue
  # Nothing
end
