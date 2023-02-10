# osl\_mysql\_dev

Installs and initializes a MariaDB service, alongside setting up a user and database. Multiple databases can be created on the same instance with multiple usages of this resource.

All databases created are encoded as `utf8mb4\_unicode\_ci`.

## Actions

- create - (default) to install MariaDB, create a user, and create a database

## Properties

Name      | Types    | Description                        | Default      | Required?
--------- | -------- | ---------------------------------- | ------------ | ---------
`Database`| String   | The name of the database to create |              | yes
`Username`| String   | The owner of the database created  |              | yes
`Password`| String   | The password to give the user      |              | yes

### Examples

We are tasked to set up two different databases, each owned by a unique user.

```ruby
# Create a database, will also initalize the service
osl_mysql_dev 'db_one' do
	username 'db_owner'
	password 'db_password'
end

# Create another database, owned by a different user
osl_mysql_dev 'db_two' do
	username 'other_owner'
	password 'other_password'
end
```
