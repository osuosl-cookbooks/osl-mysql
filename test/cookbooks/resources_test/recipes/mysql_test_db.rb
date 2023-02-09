# Initialize the database service, and create a database
mysql_test_db 'foobar' do
  username 'foo'
  password 'foofoo'
end

# Add in an extra database
mysql_test_db 'barfoo' do
  username 'foo'
  password 'foofoo'
  action :db_only
end
