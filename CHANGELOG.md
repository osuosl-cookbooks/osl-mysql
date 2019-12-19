osl-mysql CHANGELOG
===================
This file is used to list changes made in each version of the
osl-mysql cookbook.

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
