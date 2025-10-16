# Check mysql-replica-status

## Overview

Checks the replication status of MySQL/MariaDB. Logic is taken from [MySQLTuner script](https://github.com/major/MySQLTuner-perl), v1.9.8.

Hints:

* See [additional notes for all mysql monitoring plugins](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-MYSQL.md)
* Can also be run against standalone servers.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-replica-status> |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Requirements                          | User with SUPER, REPLICATION CLIENT and REPLICATION SLAVE privileges, locked down to `127.0.0.1` - for example `monitoring\@127.0.0.1`. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions. |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: mysql-replica-status [-h] [-V] [--always-ok]
                            [--defaults-file DEFAULTS_FILE]
                            [--defaults-group DEFAULTS_GROUP]
                            [--severity {warn,crit}] [--timeout TIMEOUT]

Checks the replication status of MySQL/MariaDB.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --defaults-file DEFAULTS_FILE
                        Specifies a cnf file to read parameters like user,
                        host and password from (instead of specifying them on
                        the command line), for example
                        `/var/spool/icinga2/.my.cnf`. Default:
                        /var/spool/icinga2/.my.cnf
  --defaults-group DEFAULTS_GROUP
                        Group/section to read from in the cnf file. Default:
                        client
  --severity {warn,crit}
                        Severity for alerts that do not depend on thresholds.
                        One of "warn" or "crit". Default: warn
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
```


## Usage Examples

```bash
./mysql-replica-status --defaults-file=/var/spool/icinga2/.my.cnf
```

Output:

```text
Galera Synchronous replication: NO. Binlog format: ROW, XA support enabled: ON. Semi synchronous Primary: Not Activated. Semi synchronous Replica: Not Activated. This Replica is not running but seems to be configured [WARNING].
```


## States

Alert with the given severity, if the replica (aka slave)...

* is not running but seems to be configured
* is running with the read_only option disabled
* is lagging behind Primary


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)

* License: The Unlicense, see [LICENSE file](https://unlicense.org/).

* Credits:

    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
