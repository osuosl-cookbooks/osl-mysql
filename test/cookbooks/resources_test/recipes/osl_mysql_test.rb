# Initialize the database service, and create a database
osl_mysql_test 'foobar' do
  username 'foo'
  password 'foofoo'
end

# Add in an extra database
osl_mysql_test 'barfoo' do
  username 'foo'
  password 'foofoo'
end
