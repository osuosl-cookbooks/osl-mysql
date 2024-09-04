osl-mysql CHANGELOG
===================
This file is used to list changes made in each version of the
osl-mysql cookbook.

6.10.1 (2024-09-04)
-------------------
- Add AlmaLinux 9 support

6.10.0 (2024-07-05)
-------------------
- Remove support for CentOS 7

6.9.3 (2023-11-22)
------------------
- Add /root/.my.cnf when using osl_mysql_test

6.9.2 (2023-08-25)
------------------
- Add ignore_failure true to git resources

6.9.1 (2023-06-15)
------------------
- Fix open files configuration

6.9.0 (2023-06-14)
------------------
- Tweak mysqld config

6.8.4 (2023-06-12)
------------------
- Add firewall port rules for mysql in osl_mysql_test

6.8.3 (2023-05-30)
------------------
- Added in `version` attribute to `osl_mysql_test`

6.8.2 (2023-05-25)
------------------
- Add Alma 8 support to mon recipe

6.8.1 (2023-05-24)
------------------
- Allow setting replication source via attribute

6.8.0 (2023-04-21)
------------------
- [osl_mysql_test] Disabled setting up mariadb's own repository

6.7.0 (2023-03-21)
------------------
- Add initial AlmaLinux 8 support

6.6.0 (2023-02-20)
------------------
- Lightweight MySQL (MariaDB) test environment

6.5.0 (2022-08-23)
------------------
- Replace base with osl-resources

6.4.0 (2022-08-18)
------------------
- Migrate to default to using 5.7 and other updates

6.3.0 (2022-01-29)
------------------
- Update percona to Chef 17-compliant version

6.2.0 (2022-01-11)
------------------
- Update mysql to Chef 17-compliant version

6.1.0 (2022-01-04)
------------------
- Bump mariadb to Chef 17-compliant version

6.0.0 (2021-09-08)
------------------
- Terminology update

5.1.0 (2021-08-26)
------------------
- Enable Selinux Enforcing

5.0.1 (2021-08-04)
------------------
- Use search() stubbing in ChefSpec

5.0.0 (2021-05-25)
------------------
- Update to new osl-firewall resources

4.2.0 (2021-04-06)
------------------
- Update Chef dependency to >= 16

4.1.0 (2021-02-19)
------------------
- Remove munin

4.0.1 (2021-01-19)
------------------
- Update upstream percona to 2.1.0

4.0.0 (2021-01-19)
------------------
- Remove Centos 6 support

3.1.1 (2021-01-19)
------------------
- Cookstyle fixes

3.1.0 (2020-10-27)
------------------
- Move back to percona resources

3.0.2 (2020-10-07)
------------------
- Remove apache2 dep lock

3.0.1 (2020-10-07)
------------------
- Lock mysql version temporarily

3.0.0 (2020-09-16)
------------------
- Add CentOS 8 support

2.7.0 (2020-09-09)
------------------
- update to chef 16

2.6.0 (2020-08-21)
------------------
- Update percona cookbook to 1.1.0

2.5.0 (2020-08-07)
------------------
- Update Percona

2.4.1 (2020-07-01)
------------------
- Include hashed_password from resource_mysql_database_user

2.4.0 (2020-07-01)
------------------
- Chef 15 compatibility fixes

2.3.3 (2020-05-29)
------------------
- Fix depend lock for mariadb

2.3.2 (2020-05-29)
------------------
- version lock mariadb until chef15 migration

2.3.1 (2020-04-27)
------------------
- sysctl adjustments

2.3.0 (2020-01-14)
------------------
- Chef 14 post-migration fixes

2.2.4 (2019-12-19)
------------------
- Change innodb file format and set log_bin_trust_function_creators

2.2.3 (2019-11-18)
------------------
- Bump xtrabackup version

2.2.2 (2019-11-06)
------------------
- Delete the package[mysql-libs] resource

2.2.1 (2019-11-05)
------------------
- Fix monitor user

2.2.0 (2019-11-05)
------------------
- Import mysql resources from deprecated database cookbook

2.1.1 (2019-10-24)
------------------
- Install yum-epel if on CentOS 6 for server

2.1.0 (2019-09-18)
------------------
- Add support for installing Percona client in osl-mysql::client

2.0.6 (2019-03-13)
------------------
- Ensure we install Percona-Server-devel-56 when using Percona

2.0.5 (2019-03-13)
------------------
- Prometheus database size metrics

2.0.4 (2019-01-30)
------------------
- Include additional GPG key for RPMs for Percona

2.0.3 (2019-01-22)
------------------
- Set vm.swappiness via attribute instead

2.0.2 (2018-11-09)
------------------
- Remove postgresql version lock conflict

2.0.1 (2018-09-26)
------------------
- Bump max-connection to 1000

2.0.0 (2018-09-20)
------------------
- Chef 13 Compatibility Fix

1.0.7 (2017-04-19)
------------------
- Lock postgresql cookbook to a compatible version
- Minor fix in README.md

1.0.6 (2017-02-03)
------------------
- A trial fix to resolve #29222 on RT
- We started CHANGELOG
