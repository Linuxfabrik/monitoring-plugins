# Check mysql-binlog-cache


## Overview

Checks whether transactions in MySQL/MariaDB had to use a temporary disk cache because they exceeded the configured binary log cache size (`binlog_cache_size`). A high disk cache usage rate indicates that `binlog_cache_size` should be increased.

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-MYSQL.md)
* If `log_bin` is set to `OFF`, the check exits with UNKNOWN because binary logging is disabled and this check makes no sense
* Returns UNKNOWN if binary logging is disabled

**Data Collection:**

* Queries `SHOW GLOBAL VARIABLES` for `binlog_cache_size` and `log_bin`
* Queries `SHOW GLOBAL STATUS` for `Binlog_cache_disk_use` and `Binlog_cache_use`
* Calculates the percentage of transactions served from memory vs. disk
* Logic is taken from [MySQLTuner script](https://github.com/major/MySQLTuner-perl):mysql_stats(), v1.9.8

**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-binlog-cache> |
| Nagios/Icinga Check Name              | `check_mysql_binlog_cache` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: mysql-binlog-cache [-h] [-V] [--always-ok]
                          [--defaults-file DEFAULTS_FILE]
                          [--defaults-group DEFAULTS_GROUP]
                          [--timeout TIMEOUT]

Checks if transactions in MySQL/MariaDB had to use a temporary disk cache
because they exceeded the configured binary log cache size. A high disk cache
usage rate indicates that binlog_cache_size should be increased. Alerts when
the disk cache usage rate is too high.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --defaults-file DEFAULTS_FILE
                        MySQL/MariaDB cnf file to read user, host and password
                        from (instead of specifying them on the command line).
                        Example: `/var/spool/icinga2/.my.cnf`. Default:
                        /var/spool/icinga2/.my.cnf
  --defaults-group DEFAULTS_GROUP
                        Group/section to read from in the cnf file. Default:
                        client
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
```


## Usage Examples

```bash
./mysql-binlog-cache --defaults-file=/var/spool/icinga2/.my.cnf
```

Output:

```text
0% binlog cache memory access (0 memory / 0 total).
```


## States

* WARN if more than 10% of all transactions using the binary log cache are read from disk.
* UNKNOWN if binary logging is disabled (`log_bin = OFF`).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mysql_binlog_cache_disk_use | Continous Counter | Number of transactions which used a temporary disk cache because they could not fit in the regular binary log cache, being larger than `binlog_cache_size`. |
| mysql_binlog_cache_size | Bytes | Size in bytes, per-connection, of the cache holding a record of binary log changes during a transaction. |
| mysql_binlog_cache_use | Continous Counter | Number of transactions which used the regular binary log cache, being smaller than `binlog_cache_size`. |
| mysql_pct_binlog_cache | Percentage | (Binlog_cache_use - Binlog_cache_disk_use) / Binlog_cache_use * 100 |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:
    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
