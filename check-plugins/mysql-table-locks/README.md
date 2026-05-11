# Check mysql-table-locks


## Overview

Checks the percentage of MySQL/MariaDB table locks that were acquired immediately. A low percentage means concurrent queries are blocking each other on the same MyISAM/Aria/MEMORY table; `InnoDB` row-level locks do not contribute to these counters. Logic taken from [MySQLTuner](https://github.com/major/MySQLTuner-perl):mysql_stats() and verified in sync with MySQLTuner v2.8.41.

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-mysql/)
* `Table_locks_waited` only counts table-level locks. Modern workloads built on `InnoDB` never bump this counter; if every table in a database is `InnoDB`, the percentage stays at 100% indefinitely. The check is informative on servers still running MyISAM or Aria tables (typical: legacy schemas, `mysql.*` system tables on older MariaDB, full-text-indexed Aria tables on MariaDB)
* If a server has not yet taken a single table lock (`Table_locks_immediate = 0`) the percentage is meaningless; the check skips with an info line in that case (matches mysqltuner)

**Data Collection:**

* Queries `SHOW GLOBAL STATUS` for `Table_locks_immediate` and `Table_locks_waited`
* Calculates the immediate-lock percentage as `Table_locks_immediate / (Table_locks_immediate + Table_locks_waited) * 100`
* Cumulative counters are persisted in a local SQLite cache between runs so the dashboard can plot per-second rates instead of unbounded counters


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-table-locks> |
| Nagios/Icinga Check Name              | `check_mysql_table_locks` |
| Check Interval Recommendation         | Every hour |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Requirements                          | User with no privileges, locked down to `127.0.0.1` - for example `monitoring\@127.0.0.1`. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions. |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: mysql-table-locks [-h] [-V] [--always-ok] [-c CRITICAL]
                         [--defaults-file DEFAULTS_FILE]
                         [--defaults-group DEFAULTS_GROUP] [--timeout TIMEOUT]
                         [-w WARNING]

Checks the percentage of MySQL/MariaDB table locks that were acquired
immediately (`Table_locks_immediate` divided by (`Table_locks_immediate` +
`Table_locks_waited`)). A low percentage means concurrent queries are blocking
each other on the same MyISAM/Aria/MEMORY table; InnoDB row-level locks do not
contribute to these counters. Alerts when the percentage drops below
`--warning` / `--critical`.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRITICAL
                        CRIT threshold in percent. Supports Nagios ranges.
                        Default: 85:
  --defaults-file DEFAULTS_FILE
                        MySQL/MariaDB cnf file to read user, host and password
                        from. Example: `--defaults-
                        file=/var/spool/icinga2/.my.cnf`. Default:
                        /var/spool/icinga2/.my.cnf
  --defaults-group DEFAULTS_GROUP
                        Group/section to read from in the cnf file. Default:
                        client
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -w, --warning WARNING
                        WARN threshold in percent. Supports Nagios ranges.
                        Default: 95:
```


## Usage Examples

```bash
./mysql-table-locks --defaults-file=/var/spool/icinga2/.my.cnf
```

OK output:

```text
Everything is ok. Table locks acquired immediately: 100.0% (2.6K immediate / 2.6K locks).
```

WARN output:

```text
Table locks acquired immediately: 87.4% (87K immediate / 100K locks) [WARNING].

Recommendations:
* Optimize queries and/or migrate the affected tables to `InnoDB` to reduce lock wait. `InnoDB` uses row-level locks and does not contribute to `Table_locks_waited`. The classic culprits are MyISAM/Aria tables with long-running SELECTs blocking INSERTs (table-level read/write lock contention)
```


## States

* WARN if the percentage of immediately acquired table locks is at or below `--warning` (default: 95%).
* CRIT if the percentage is at or below `--critical` (default: 85%).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mysql_pct_table_locks_immediate | Percentage | `Table_locks_immediate / (Table_locks_immediate + Table_locks_waited) * 100`. Pinned to `100.0` when `Table_locks_waited = 0` (no contention) so the metric stays meaningful on contention-free workloads. |
| mysql_table_locks_immediate_per_second | Rate | Per-second rate of `Table_locks_immediate` (cumulative counter delta against the local SQLite cache). Appears from the second run onwards. |
| mysql_table_locks_waited_per_second | Rate | Per-second rate of `Table_locks_waited` (cumulative counter delta against the local SQLite cache). Appears from the second run onwards. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:

    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
