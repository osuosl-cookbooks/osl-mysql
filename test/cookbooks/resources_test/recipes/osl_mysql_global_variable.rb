include_recipe 'osl-mysql::server'

# Deliberately differs from my.cnf's 900: on a fresh VM nothing else exercises SET GLOBAL
osl_mysql_global_variable 'wait_timeout' do
  value 1000
end
