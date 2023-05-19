# osl\_mysql\_test

Installs and initializes a MariaDB service, alongside setting up a user and database. Multiple databases can be created on the same instance with multiple usages of this resource.

All databases created are encoded as `utf8mb4_unicode_ci` by default.

### CentOS 7 Warning

Due to the age of the version of MariaDB provided in the stock CentOS 7 repo, it is advised to use the `version` property to choose a newer release. By default, this resource will install version `10.11` if its on a CentOS 7 system.

## Actions

- create - (default) to install MariaDB, create a user, and create a database

## Properties

Name                 | Types    | Description                          | Default              | Required?
---------            | -------- | ----------------------------------   | ------------         | ---------
`database`           | String   | The name of the database to create   |                      | yes
`username`           | String   | The owner of the database created    |                      | yes
`password`           | String   | The password to give the user        |                      | yes
`server_password`    | String   | The root password                    | osl\_mysql\_test     | no
`encoding`           | String   | The string encoding for the database | utf8mb4              | no
`collation`          | String   | The collation for the database       | utf8mb4\_unicode\_ci | no
`version`            | String   | Enables the MariaDB repo and installs the requested version of the database | null | no
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

# Use a newer version of MariaDB, and change the root password
osl_mysql_test 'db_four' do
  username 'db_owner'
  password 'db_password'
  server_password 'foo on the bar with baz'
  version '10.11'
end
```
