# osl\_mysql\_global\_variable

Sets a dynamic MySQL system variable on the running server with `SET GLOBAL`, when its live value differs from the
one given. `osl-mysql::server` no longer restarts an initialized mysqld when `my.cnf` changes, so this is how a new
value for a dynamic setting reaches servers that are already running. `osl-mysql::server` declares it for
`connect_timeout`, with the value taken from the same percona attribute that renders `my.cnf`.

- The variable must be dynamic. A read-only variable makes `SET GLOBAL` fail on every Chef run.
- The value must match what `my.cnf` holds, or the running server and the next restart disagree. Take it from the
  attribute that renders `my.cnf` rather than repeating the number.
- The value must also be exactly what `SELECT @@GLOBAL.<variable>` reports once set. MySQL rounds some variables to
  a block size: `max_allowed_packet` to a multiple of 1024, the join and sort buffers to their alignment, and
  `innodb_buffer_pool_size` up to whole chunks (mysql1 renders 89802M but runs at 92160M). A value MySQL rounds never
  compares equal, so `SET GLOBAL` runs on every converge, and for the buffer pool that is an online resize each time.
  Check `SELECT @@GLOBAL.<variable>` after setting the value by hand before declaring it.
- A missing or unreadable `defaults_file` fails the run rather than being taken for a stopped mysqld.
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
| `value`         | String or Integer | (required)      | Plain number (no `128M`); leading zeros are dropped. Must be the value `@@GLOBAL` reports. |
| `defaults_file` | String            | `/root/.my.cnf` | Client defaults file with the credentials. |

## Example

```ruby
osl_mysql_global_variable 'connect_timeout' do
  value node['percona']['server']['connect_timeout']
end
```
