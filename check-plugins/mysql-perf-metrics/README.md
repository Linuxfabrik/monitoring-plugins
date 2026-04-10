# Check mysql-perf-metrics


## Overview

Checks performance-related best practice configurations for MySQL/MariaDB, including whether InnoDB stats are updated during INFORMATION_SCHEMA queries, concurrent inserts are enabled, and InnoDB file-per-table is activated.

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-MYSQL.md)
* Requires MySQL/MariaDB v5.5+

**Data Collection:**

* Queries `SHOW GLOBAL VARIABLES` for `concurrent_insert`, `innodb_file_per_table`, and `innodb_stats_on_metadata`
* Checks the InnoDB storage engine availability
* Logic is taken from [MySQLTuner script](https://github.com/major/MySQLTuner-perl):check_metadata_perf(), v1.9.8

**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-perf-metrics> |
| Nagios/Icinga Check Name              | `check_mysql_perf_metrics` |
| Check Interval Recommendation         | Once a day |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: mysql-perf-metrics [-h] [-V] [--always-ok]
                          [--defaults-file DEFAULTS_FILE]
                          [--defaults-group DEFAULTS_GROUP]
                          [--timeout TIMEOUT]

Checks performance metrics and best practice configurations for MySQL/MariaDB,
including query cache efficiency, key buffer usage, and other tuning
indicators. Alerts on suboptimal configurations.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --defaults-file DEFAULTS_FILE
                        MySQL/MariaDB cnf file to read user, host and password
                        from. Example: `--defaults-
                        file=/var/spool/icinga2/.my.cnf`. Default:
                        /var/spool/icinga2/.my.cnf
  --defaults-group DEFAULTS_GROUP
                        Group/section to read from in the cnf file. Default:
                        client
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
```


## Usage Examples

```bash
./mysql-perf-metrics --defaults-file=/var/spool/icinga2/.my.cnf
```

Output:

```text
Stat are updated during querying INFORMATION_SCHEMA [WARNING]. Set innodb_stats_on_metadata to OFF. Concurrent INSERTs are off [WARNING]. Set concurrent_insert to AUTO or ALWAYS. InnoDB File per table is not activated [WARNING]. Set innodb_file_per_table to ON.
```


## States

* WARN if `concurrent_insert` is not set to AUTO or ALWAYS.
* WARN if `innodb_file_per_table` is not set to ON (when InnoDB is enabled).
* WARN if `innodb_stats_on_metadata` is not set to OFF.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:
    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
