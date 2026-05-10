# Check mysql-binlog-cache


## Overview

Checks the memory-access rate for the MySQL/MariaDB binary log cache. A low rate (below 90%) means many transactions had to spill from the in-memory binlog cache to a temporary disk file because they exceeded `binlog_cache_size`, and the variable should be increased.

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-mysql/)
* When binary logging is disabled (`log_bin = OFF`), the plugin reports OK with an info message - that is a legitimate configuration on standalone servers without replication, not an error
* When `Binlog_cache_use = 0` (binary logging is on, but no transaction has hit the binlog cache yet), the plugin reports OK with an info message instead of a misleading 0% memory-access rate
* When `Binlog_cache_use < 10`, the plugin still emits the rate but appends a note that the sample is too small to act on

**Data Collection:**

* Queries `SHOW GLOBAL VARIABLES` for `binlog_cache_size` and `log_bin`
* Queries `SHOW GLOBAL STATUS` for `Binlog_cache_disk_use` and `Binlog_cache_use`
* Calculates the percentage of transactions served from memory vs. disk
* Logic is taken from [MySQLTuner](https://github.com/major/MySQLTuner-perl):mysql_stats(), Binlog cache section, and has been verified in sync with MySQLTuner v2.8.41


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-binlog-cache> |
| Nagios/Icinga Check Name              | `check_mysql_binlog_cache` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: mysql-binlog-cache [-h] [-V] [--always-ok]
                          [--defaults-file DEFAULTS_FILE]
                          [--defaults-group DEFAULTS_GROUP]
                          [--timeout TIMEOUT]

Checks the memory-access rate for the MySQL/MariaDB binary log cache. A low
rate (below 90%) means many transactions had to spill from the in-memory
binlog cache to a temporary disk file because they exceeded
`binlog_cache_size`, and the variable should be increased. Alerts when the
memory-access rate drops below 90%.

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
99.7% binlog cache memory access (4.2K memory / 4.3K total).
```

When binary logging is off:

```text
Binary logging is disabled.
```

When binary logging is on but no transaction has hit the binlog cache yet:

```text
Binary logging is enabled, no binlog cache activity yet.
```


## States

* OK if the memory-access rate is 90% or higher.
* OK if binary logging is disabled (`log_bin = OFF`); the plugin reports the fact and exits.
* OK if binary logging is enabled but the binlog cache has not been used yet.
* WARN if the memory-access rate drops below 90% (i.e. more than 10% of cached transactions had to spill to disk).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mysql_binlog_cache_disk_use_per_second | Number | Per-second rate of transactions that had to spill to a temporary disk file because they exceeded `binlog_cache_size`. Only emitted from the second run onwards (the plugin keeps a small SQLite cache between runs to compute the delta in-plugin instead of using a continuous counter). |
| mysql_binlog_cache_size | Bytes | Size in bytes, per-connection, of the cache holding a record of binary log changes during a transaction. |
| mysql_binlog_cache_use_per_second | Number | Per-second rate of transactions that used the in-memory binlog cache. Only emitted from the second run onwards. |
| mysql_pct_binlog_cache | Percentage | (Binlog_cache_use - Binlog_cache_disk_use) / Binlog_cache_use * 100, computed from the cumulative MySQL/MariaDB counters. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:
    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
