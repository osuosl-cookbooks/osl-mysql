# osl\_mysql\_global\_variable

Sets a dynamic MySQL system variable on the running server with `SET GLOBAL`, when its live value differs from the
one given. `osl-mysql::server` no longer restarts an initialized mysqld when `my.cnf` changes, so this is how a new
value for a dynamic setting reaches servers that are already running. `osl-mysql::server` declares it for
`connect_timeout`, with the value taken from the same percona attribute that renders `my.cnf`.

- The variable must be dynamic. A read-only variable makes `SET GLOBAL` fail on every Chef run.
- The value must match what `my.cnf` holds, or the running server and the next restart disagree. Take it from the
  attribute that renders `my.cnf` rather than repeating the number.
- It uses `SET GLOBAL`, not `SET PERSIST`: `SET PERSIST` writes `mysqld-auto.cnf`, which MySQL reads after `my.cnf` and
  which would then override the cookbook after every restart.
- When mysqld does not answer `mysqladmin ping`, the resource does nothing; `my.cnf` applies on the next start. Any
  other error, such as an unknown variable or a bad password, fails the run.

## Actions

| Action | Description |
| ------ | ----------- |
| `:set` | Default. Runs `SET GLOBAL <variable> = <value>` when the live value differs. |

## Properties

| Name            | Type              | Default         | Description |
| --------------- | ----------------- | --------------- | ----------- |
| `variable`      | String            | name property   | System variable name, lowercase letters, digits and `_`. |
| `value`         | String or Integer | (required)      | Plain number, so it compares exactly with `@@GLOBAL` (no `128M`). |
| `defaults_file` | String            | `/root/.my.cnf` | Client defaults file with the credentials. |

## Example

```ruby
osl_mysql_global_variable 'connect_timeout' do
  value node['percona']['server']['connect_timeout']
end
```
