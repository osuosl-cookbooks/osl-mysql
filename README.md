# osl-mysql cookbook
OSL's MySQL tuning defaults.

This Cookbook sets up MySQL configuration defaults, enables the Percona yum repository, configures and pins the mysql uid/gid, sets sysctl vm.swappiness to 0, and installs /root/.my.cnf with the default MySQL root user and password.

# Requirements
Cookbooks:: yum, nagios, sysctl, mysql

## Supports

- AlmaLinux 8

# Usage
include_recipe "osl-mysql::server" and run Chef.  It should take care of the rest.

## Helper monitoring scripts

The `osl-mysql::server` recipe installs a set of small helper scripts under `/usr/local/sbin/` that are useful for
ad-hoc troubleshooting and monitoring of MySQL.

- `mysql-current-users-connections` — current simultaneous connections by user
- `mysql-top-users-queries` — top users by query count (windowed)
- `mysql-top-users-rows-sent` — top users by rows sent
- `mysql-top-users-exec-time` — top users by total execution time (windowed)
- `mysql-top-databases-queries-exec-time` — top databases by queries & exec time
- `mysql-top-databases-queries-exec-time-recent` — same as above but for a recent window (token: `recent`)
- `mysql-top-databases-rows-sent-examined` — rows sent / rows examined per database
- `mysql-top-databases-io-wait` — I/O wait time per database
- `mysql-top-users-writes` — counts modification (write) statements per user (uses token `writes` in the canonical
  name)
- `mysql-top-users-by-total-connections` — total cumulative connections per user

Common options
- Most helper scripts accept `--limit` (or `-n`) and a lookback window via `--hours`, `--minutes`, or `--seconds`
  (mutually exclusive). They translate long options to short ones and use `getopts` internally.
- Windowed scripts convert seconds to picoseconds for use with `performance_schema` timestamps (no action needed by
  users).

```bash
/usr/local/sbin/mysql-top-users-queries --limit 10 --minutes 30
```

Notes
- These scripts are simple diagnostic helpers — they rely on the MySQL client and server being available and the
  `performance_schema` consumers being enabled when required.

# Attributes

# Recipes
server.rb:: OSL default MySQL server configuration.  Sets defaults, pins 'mysql' uid/gid to 400, and installs Percona MySQL Server.

default.rb:: Does nothing of importance.

# Multi-host test integration

This cookbook utilizes [kitchen-terraform](https://github.com/newcontext-oss/kitchen-terraform) to test deploying
various parts of this cookbook in multiple nodes, similar to that in production.

## Prereqs

- Chef Workstation
- Terraform
- kitchen-terraform
- OpenStack cluster

Ensure you have the following in your ``.bashrc`` (or similar):

``` bash
export TF_VAR_ssh_key_name="$OS_SSH_KEYPAIR"
```

## Supported Deployments

- Chef-zero node acting as a Chef Server
- Source node
- Replica node

## Testing

First, generate some keys for chef-zero and then simply run the following suite.

``` console
# Only need to run this once
$ chef exec rake create_key
$ kitchen test multi-node
```

Be patient as this will take a while to converge all of the nodes (approximately 40 minutes).

## Access the nodes

Unfortunately, kitchen-terraform doesn't support using ``kitchen console`` so you will need to log into the nodes
manually. To see what their IP addresses are, just run ``terraform output`` which will output all of the IPs.

``` bash
# You can run the following commands to login to each node
$ ssh almalinux@$(terraform output source)
$ ssh almalinux@$(terraform output replica)

# Or you can look at the IPs for all for all of the nodes at once
$ terraform output
```

## Interacting with the chef-zero server

All of these nodes are configured using a Chef Server which is a container running chef-zero. You can interact with the
chef-zero server by doing the following:

``` bash
$ CHEF_SERVER="$(terraform output chef_zero)" knife node list -c test/chef-config/knife.rb
source
replica
$ CHEF_SERVER="$(terraform output chef_zero)" knife node edit -c test/chef-config/knife.rb
```

In addition, on any node that has been deployed, you can re-run ``chef-client`` like you normally would on a production
system. This should allow you to do development on your multi-node environment as needed. **Just make sure you include
the knife config otherwise you will be interacting with our production chef server!**

## Using Terraform directly

You do not need to use kitchen-terraform directly if you're just doing development. It's primarily useful for testing
the multi-node cluster using inspec. You can simply deploy the cluster using terraform directly by doing the following:

``` bash
# Sanity check
$ terraform plan
# Deploy the cluster
$ terraform apply
# Destroy the cluster
$ terraform destroy
```

## Cleanup

``` bash
# To remove all the nodes and start again, run the following test-kitchen command.
$ kitchen destroy multi-node

# To refresh all the cookbooks, use the following command.
$ CHEF_SERVER="$(terraform output chef_zero)" chef exec rake knife_upload
```

# Author

Author:: Oregon State University (<systems@osuosl.org>)
