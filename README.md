# osl-mysql cookbook
OSL's MySQL tuning defaults.

This Cookbook sets up MySQL configuration defaults, enables the Percona yum repository, configures and pins the mysql uid/gid, sets sysctl vm.swappiness to 0, and installs /root/.my.cnf with the default MySQL root user and password.

# Requirements
Cookbooks:: yum, nagios, sysctl, mysql

Tested on CentOS 6.x and 7.x

# Usage
include_recipe "osl-mysql::server" and run Chef.  It should take care of the rest.

# Attributes

# Recipes
server.rb:: OSL default MySQL server configuration.  Sets defaults, pins 'mysql' uid/gid to 400, and installs Percona MySQL Server.

default.rb:: Does nothing of importance.

# Author

Author:: Oregon State University (<systems@osuosl.org>)
