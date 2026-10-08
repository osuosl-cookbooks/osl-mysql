# osl\_mysql\_query\_guard

Runs Percona Toolkit's `pt-kill` as a systemd service for each guarded MySQL user. Each service kills any statement
from that user that has been running longer than its busy time, leaving the connection open. Use it to stop one tenant's
runaway queries from overloading a shared database server.

Only threads whose command is `Query` (a plain statement) or `Execute` (a server-side prepared statement) are matched.
Idle connections and other commands are left alone: without `--match-command`, pt-kill applies the busy time to `Query`
threads only and would kill every other thread of the user on sight. Replication threads are never matched.

Each rule becomes a unit named `pt-kill-<user>.service`. The resource owns every unit matching
`/etc/systemd/system/pt-kill-*.service`, so it stops, disables and deletes any such unit whose user is no longer in
`rules`. Don't hand-create units with that name.

The resource installs `percona-toolkit` from the `percona-tools` repository that `percona::package_repo` sets up, so
that recipe must already be in the run list; `osl-mysql::server` includes it. The percona cookbook does not configure
that repository on EL10, so the resource raises an error there and supports EL8 and EL9 only.

Declare it once per node. Every declaration owns all `pt-kill-*.service` units, so two would delete each other's units
on every run. To turn every guard off, set `rules` to `[]` rather than removing the resource, which would leave the
units running.

Each guard runs with `--no-version-check` and its own `--sentinel /run/pt-kill-<user>.sentinel`, and restarts five
seconds after `pt-kill` exits, which it does when `mysqld` restarts.

## Actions

- create - (default) install `percona-toolkit`, create and start one guard unit per rule, and remove guards for users no
  longer listed
- delete - stop, disable and delete every guard unit

## Properties

Name            | Types   | Description                                                              | Default         | Required?
--------------- | ------- | ------------------------------------------------------------------------ | --------------- | ---------
`rules`         | Array   | Hashes with a `user` and an optional `busy_time` in seconds; no other keys are allowed | `[]` | no
`busy_time`     | Integer | Seconds a statement may run before it is killed, for rules without their own; must be positive | `120` | no
`interval`      | Integer | Seconds between `pt-kill` checks; must be positive                        | `10`            | no
`defaults_file` | String  | MySQL option file `pt-kill` reads to connect                             | `/root/.my.cnf` | no

User names may contain only letters, digits, `_` and `-`, since they become systemd unit names and part of the
`--match-user` regex, and each user may appear once. A rule may only use the keys `user` and `busy_time`, so a misspelled
`busy_time` fails the Chef run instead of silently falling back to the default.

## The `osl-mysql::query_guard` recipe

The recipe reads the rules for a cluster from the unencrypted data bag item
`mysql_query_guard/<node['osl-mysql']['replication']['role']>`, so a guard can be added, changed or removed by editing the
item and uploading it with `knife data bag from file`. The next Chef run applies it; no cookbook release is needed. The
item must exist on every node that includes the recipe, or the Chef run fails. Create the bag once with
`knife data bag create mysql_query_guard`, then upload each cluster's item from the root of the data_bags checkout:
`knife data bag from file mysql_query_guard mysql_query_guard/vip_mysql2.json`. A cluster with nothing to guard gets
an item with `"rules": []`. Record the ticket that justified a guard in the data_bags commit message.

The recipe includes `osl-mysql::server`, so it is not for a node that runs `percona::server` directly; declare the
resource there instead, after `percona::package_repo`.

```json
{
  "id": "vip_mysql2",
  "rules": [
    {
      "user": "example_forum",
      "busy_time": 120
    }
  ]
}
```

## Examples

```ruby
osl_mysql_query_guard 'vip_mysql2' do
  rules [
    { 'user' => 'example_forum', 'busy_time' => 60 },
    { 'user' => 'example_wiki' },
  ]
end
```

To see what a guard is doing, run `systemctl status 'pt-kill-*'` and `journalctl -u pt-kill-example_forum`. With
`--print`, each kill is logged to the journal.
