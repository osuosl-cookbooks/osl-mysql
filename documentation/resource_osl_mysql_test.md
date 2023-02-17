# osl\_mysql\_test

Installs and initializes a MariaDB service, alongside setting up a user and database. Multiple databases can be created on the same instance with multiple usages of this resource.

All databases created are encoded as `utf8mb4_unicode_ci` by default.

## Actions

- create - (default) to install MariaDB, create a user, and create a database

## Properties

Name                 | Types    | Description                          | Default              | Required?
---------            | -------- | ----------------------------------   | ------------         | ---------
`Database`           | String   | The name of the database to create   |                      | yes
`Username`           | String   | The owner of the database created    |                      | yes
`Password`           | String   | The password to give the user        |                      | yes
`server_password`    | String   | The root password                    | osl\_mysql\_test     | no
`encoding`           | String   | The string encoding for the database | utf8mb4              | no
`collation`          | String   | The collation for the database       | utf8mb4\_unicode\_ci | no
`database_parameters`| Hash     | Extra database arguments to pass through, see [mariadb\_database](https://github.com/sous-chefs/mariadb/blob/main/documentation/resource_mariadb_database.md) |  | no

### Examples

We are tasked to set up two different databases, each owned by a unique user.

```ruby
# Create a database, will also initalize the service
osl_mysql_test 'db_one' do
  username 'db_owner'
  password 'db_password'
end

# Create another database, owned by a different user
osl_mysql_test 'db_two' do
  username 'other_owner'
  password 'other_password'
end

# Use the default MariaDB encoding
osl_mysql_test 'db_three' do
  username 'db_owner'
  password 'db_password'
  encoding 'latin1'
  collation 'latin1_swedish_ci'
end
```
