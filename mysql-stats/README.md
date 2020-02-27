# Overview

This check is more or less a port of the MySQLTuner script. The check _allows you to review a MySQL installation quickly and make adjustments to increase performance and stability. The current configuration variables and status data is retrieved and presented in a brief format along with some basic performance suggestions_.

This check needs a user with at least "PROCESS" (= Role "MonitorAdmin") privileges, locked down to "127.0.0.1" - for example a user "mariadb-monitor@127.0.0.1". It also needs the Python library `mysql-connector` to access a MySQL/MariaDB server.

If you compare the output from MySQLTuner with this check keep in mind that this check uses less connections then MySQLTuner does (in fact this check uses one connection per call only).

If you just want to check if MySQL or MariaDB is listening on its port, use the `network-port-tcp` check.

We recommend to run this check every 5 minutes.


# Installation and Usage

Requirements:
* Python2 module `mysql.connector`

Using an empty password is done with `--password=''` (although this is of course not recommended).

```bash
./mysql-stats --username mariadb-monitor --password mypassword
./mysql-stats --help
```


# States and Perfdata

* CRIT: if MySQL's / MariaDB's maximum memory usage is dangerously high
* WARN: if any recommendation regarding system ressources is found


# Known Issues and Limitations

* compared to MySQLTuner only performance checks are ported
* compared to check_mysql / MySQLTuner:
  - connections via sockets are not supported
  - only login with username / password (not via SSL/TLS) implemented
  - no option file support
  - currently no slave check via "show slave status"


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
* Credits:
  - heavily inspired by MySQLTuner (https://github.com/major/MySQLTuner-perl)
  - check_mysql from monitoring-plugins.org.
