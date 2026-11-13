# Check mysql-temp-tables


## Overview

Reports the percentage of MySQL/MariaDB temporary tables that were created on disk (`Created_tmp_disk_tables` divided by `Created_tmp_tables`). A temporary table goes to disk when it outgrows the smaller of `tmp_table_size` and `max_heap_table_size`, but on MariaDB also at any size when it holds a `TEXT` or `BLOB` column, which includes many `information_schema` queries. The counters cannot tell the two apart, so the percentage is a tuning hint for databases whose queries the admin controls, not an operational state. Alerts only when `--warning` / `--critical` are given, and not during the first hour of uptime, because the percentage is a lifetime average over only a handful of queries then.

Logic taken from [MySQLTuner](https://github.com/major/MySQLTuner-perl):mysql_stats(). MySQLTuner's default alert above 25% and its advice to raise the limits toward 256 MiB are deliberately not taken over.

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-mysql/)
* The effective temp-table cap is `min(tmp_table_size, max_heap_table_size)`. Raising only one of the two has no effect; the recommendation always names both
* MariaDB puts a temp table with a `TEXT` or `BLOB` column on disk at any size, so an application that reads such columns keeps the percentage high, however large the limits are. `information_schema` queries count as well, among them those of monitoring checks and `mariadb-dump`. On a Nextcloud host they made up 85% of all disk temp tables. The recommendation therefore starts with two queries that name the statements and users behind the disk tables
* The percentage does not alert by default. Raising `tmp_table_size` and `max_heap_table_size` against it does not lower it for `TEXT`/`BLOB` temp tables, but every connection may hold a temp table up to that size, so the peak memory grows by the limit times `max_connections`. Set `--warning` / `--critical` for databases whose schema and queries you or your developers control
* If a server has not yet materialised a single temporary table (`Created_tmp_tables = 0`), the percentage is meaningless and the check skips with an info line (matches mysqltuner)

**Data Collection:**

* Queries `SHOW GLOBAL VARIABLES` for `max_heap_table_size` and `tmp_table_size`
* Queries `SHOW GLOBAL STATUS` for `Created_tmp_disk_tables` and `Created_tmp_tables`
* Calculates the disk temporary table percentage as `Created_tmp_disk_tables / Created_tmp_tables * 100`
* The percentage is a lifetime average, so during the first hour of uptime it is reported but not evaluated
* Cumulative counters are persisted in a local SQLite cache between runs so the dashboard can plot per-second rates instead of unbounded counters


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-temp-tables> |
| Nagios/Icinga Check Name              | `check_mysql_temp_tables` |
| Check Interval Recommendation         | Every 15 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| Requirements                          | User with no privileges, locked down to `127.0.0.1` - for example `monitoring@127.0.0.1`. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions. |
| 3rd Party Python modules              | `pymysql` |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-mysql-temp-tables.db` |


## Help

```text
usage: mysql-temp-tables [-h] [-V] [--always-ok] [-c CRIT]
                         [--defaults-file DEFAULTS_FILE]
                         [--defaults-group DEFAULTS_GROUP] [--no-perfdata]
                         [--timeout TIMEOUT] [-w WARN]

Reports the percentage of MySQL/MariaDB temporary tables that were created on
disk (`Created_tmp_disk_tables` divided by `Created_tmp_tables`). A temporary
table goes to disk when it outgrows the smaller of `tmp_table_size` and
`max_heap_table_size`, but on MariaDB also at any size when it holds a `TEXT`
or `BLOB` column, which includes many `information_schema` queries. The
counters cannot tell the two apart, so the percentage is a tuning hint for
databases whose queries the admin controls, not an operational state. Alerts
only when `--warning` / `--critical` are given, and not during the first hour
of uptime, because the percentage is a lifetime average over only a handful of
queries then.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRIT   CRIT threshold in percent. Supports Nagios ranges.
                        Example: `--critical=50`. Default: not evaluated, the
                        percentage is only reported.
  --defaults-file DEFAULTS_FILE
                        MySQL/MariaDB cnf file to read user, host and password
                        from. Example: `--defaults-
                        file=/var/spool/icinga2/.my.cnf`. Default:
                        /var/spool/icinga2/.my.cnf
  --defaults-group DEFAULTS_GROUP
                        Group/section to read from in the cnf file. Default:
                        client
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -w, --warning WARN    WARN threshold in percent. Supports Nagios ranges.
                        Example: `--warning=25`. Default: not evaluated, the
                        percentage is only reported.

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-temp-tables/
```


## Usage Examples

```bash
./mysql-temp-tables --defaults-file=/var/spool/icinga2/.my.cnf
```

OK output:

```text
Everything is ok. Temporary tables created on disk: 16.1% (12.7K on disk / 79.1K total). `tmp_table_size` = 256.0MiB, `max_heap_table_size` = 256.0MiB.
```

WARN output with `--warning=10`:

```text
Temporary tables created on disk: 16.1% (12.7K on disk / 79.1K total) [WARNING]. `tmp_table_size` = 256.0MiB, `max_heap_table_size` = 256.0MiB.

Recommendations:
* Find the queries behind this first: `SELECT DIGEST_TEXT, COUNT_STAR, SUM_CREATED_TMP_DISK_TABLES FROM performance_schema.events_statements_summary_by_digest ORDER BY SUM_CREATED_TMP_DISK_TABLES DESC LIMIT 10;`, and the users behind it: `SELECT USER, SUM(SUM_CREATED_TMP_DISK_TABLES) FROM performance_schema.events_statements_summary_by_user_by_event_name GROUP BY USER;`
* A query with as many disk tables as executions reads a `TEXT` or `BLOB` column or `information_schema`, including the queries of monitoring checks and backups. MariaDB puts such a temp table on disk at any size, so raising `tmp_table_size` and `max_heap_table_size` does not help there
* Raise `tmp_table_size` (currently 256.0MiB) and `max_heap_table_size` (currently 256.0MiB) only for queries with fewer disk tables than executions, both to the same value just above their largest temp table. Every connection may hold such a temp table, so the limit counts `max_connections` times in the peak memory (see the mysql-memory check)
* Audit `SELECT DISTINCT` and `GROUP BY` queries that run without a `LIMIT` clause; those are the classic source of oversized temporary tables
```


## States

* By default the percentage is only reported and never alerts.
* WARN if the percentage of temporary tables created on disk is outside `--warning` (for example `--warning=25` alerts above 25%), after at least one hour of uptime.
* CRIT if the percentage is outside `--critical` (for example `--critical=50` alerts above 50%), after at least one hour of uptime.
* Both `--warning` and `--critical` accept Nagios range expressions, see [THRESHOLDS.md](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/THRESHOLDS.md).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mysql_created_tmp_disk_tables_per_second | Rate | Per-second rate of `Created_tmp_disk_tables` (cumulative counter delta against the local SQLite cache). Appears from the second run onwards. |
| mysql_created_tmp_tables_per_second | Rate | Per-second rate of `Created_tmp_tables` (cumulative counter delta against the local SQLite cache). Appears from the second run onwards. |
| mysql_max_heap_table_size | Bytes | Maximum size of user-created MEMORY tables (`max_heap_table_size`). |
| mysql_max_tmp_table_size | Bytes | Effective per-table cap, `min(tmp_table_size, max_heap_table_size)`. Matches MySQL/MariaDB behaviour and mysqltuner's `max_tmp_table_size`. |
| mysql_pct_temp_disk | Percentage | `Created_tmp_disk_tables / Created_tmp_tables * 100`. Pinned to `0.0` when `Created_tmp_tables = 0`. |
| mysql_tmp_table_size | Bytes | Largest size for implicit temporary tables in memory; the lower of `tmp_table_size` and `max_heap_table_size` applies. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:

    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
