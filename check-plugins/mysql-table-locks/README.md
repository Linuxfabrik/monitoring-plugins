# Check mysql-table-locks

## Overview

Checks the rate of table locks that had to wait in MySQL/MariaDB. A high wait rate indicates contention between concurrent queries. Logic is taken from [MySQLTuner script](https://github.com/major/MySQLTuner-perl):mysql_stats(), v1.9.8.

**Data Collection:**

* Queries `SHOW GLOBAL STATUS` for `Table_locks_immediate` and `Table_locks_waited`
* Calculates the immediate lock rate as `Table_locks_immediate / (Table_locks_waited + Table_locks_immediate) * 100`

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-MYSQL.md)



**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-table-locks> |
| Nagios/Icinga Check Name              | `check_mysql_table_locks` |
| Check Interval Recommendation         | Once an hour |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Requirements                          | User with no privileges, locked down to `127.0.0.1` - for example `monitoring\@127.0.0.1`. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions. |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: mysql-table-locks [-h] [-V] [--always-ok]
                         [--defaults-file DEFAULTS_FILE]
                         [--defaults-group DEFAULTS_GROUP] [--timeout TIMEOUT]

Checks the rate of table locks that had to wait in MySQL/MariaDB. A high wait
rate indicates contention between concurrent queries. Alerts when the lock
wait rate is too high.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --defaults-file DEFAULTS_FILE
                        MySQL/MariaDB cnf file to read parameters like user,
                        host and password from (instead of specifying them on
                        the command line). Example:
                        `/var/spool/icinga2/.my.cnf`. Default:
                        /var/spool/icinga2/.my.cnf
  --defaults-group DEFAULTS_GROUP
                        Group/section to read from in the cnf file. Default:
                        client
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
```


## Usage Examples

```bash
./mysql-table-locks --defaults-file=/var/spool/icinga2/.my.cnf
```

Output:

```text
100% table locks acquired immediately (2.6K immediate / 2.6K locks).
```


## States

* OK if 95% or more of table locks were acquired immediately.
* WARN if less than 95% of table locks were acquired immediately.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mysql_pct_table_locks_immediate | Percentage | Table_locks_immediate / (Table_locks_waited + Table_locks_immediate) \* 100 |
| mysql_table_locks_immediate | Continous Counter | Number of table locks which were completed immediately. |
| mysql_table_locks_waited | Continous Counter | Number of table locks which had to wait. Indicates table lock contention. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:

    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
