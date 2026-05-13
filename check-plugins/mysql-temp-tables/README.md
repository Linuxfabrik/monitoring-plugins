# Check mysql-temp-tables


## Overview

Checks the percentage of MySQL/MariaDB temporary tables that had to spill to disk. A high percentage means queries are materialising temporary tables larger than the smaller of `tmp_table_size` and `max_heap_table_size`, and the server falls back to a disk-based temporary table. Logic taken from [MySQLTuner](https://github.com/major/MySQLTuner-perl):mysql_stats() and verified in sync with MySQLTuner.

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-mysql/)
* The effective temp-table cap is `min(tmp_table_size, max_heap_table_size)`. Raising only one of the two has no effect; the recommendation always names both
* Above mysqltuner's 256 MiB cut-off, raising the cap further does not help. The recommendation switches to "audit the queries" in that range (typically `SELECT DISTINCT` and `GROUP BY` without `LIMIT`)
* If a server has not yet materialised a single temporary table (`Created_tmp_tables = 0`), the percentage is meaningless and the check skips with an info line (matches mysqltuner)

**Data Collection:**

* Queries `SHOW GLOBAL VARIABLES` for `max_heap_table_size` and `tmp_table_size`
* Queries `SHOW GLOBAL STATUS` for `Created_tmp_disk_tables` and `Created_tmp_tables`
* Calculates the disk temporary table percentage as `Created_tmp_disk_tables / Created_tmp_tables * 100`
* Cumulative counters are persisted in a local SQLite cache between runs so the dashboard can plot per-second rates instead of unbounded counters


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-temp-tables> |
| Nagios/Icinga Check Name              | `check_mysql_temp_tables` |
| Check Interval Recommendation         | Every 15 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Requirements                          | User with no privileges, locked down to `127.0.0.1` - for example `monitoring\@127.0.0.1`. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions. |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: mysql-temp-tables [-h] [-V] [--always-ok] [-c CRIT]
                         [--defaults-file DEFAULTS_FILE]
                         [--defaults-group DEFAULTS_GROUP] [--timeout TIMEOUT]
                         [-w WARN]

Checks the percentage of MySQL/MariaDB temporary tables that had to spill to
disk (`Created_tmp_disk_tables` divided by `Created_tmp_tables`). A high
percentage means queries are materialising temporary tables larger than the
smaller of `tmp_table_size` and `max_heap_table_size`, and the server falls
back to a disk-based temporary table. Alerts when the percentage crosses
`--warning` / `--critical`. Recommendations depend on whether the effective
temp-table cap is already large (`>= 256 MiB`, mysqltuner's cut-off); in that
case raising the cap further does not help and the underlying queries
(typically `SELECT DISTINCT` without `LIMIT`) need attention.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRIT   CRIT threshold in percent. Supports Nagios ranges.
                        Default: 50
  --defaults-file DEFAULTS_FILE
                        MySQL/MariaDB cnf file to read user, host and password
                        from. Example: `--defaults-
                        file=/var/spool/icinga2/.my.cnf`. Default:
                        /var/spool/icinga2/.my.cnf
  --defaults-group DEFAULTS_GROUP
                        Group/section to read from in the cnf file. Default:
                        client
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -w, --warning WARN    WARN threshold in percent. Supports Nagios ranges.
                        Default: 25
```


## Usage Examples

```bash
./mysql-temp-tables --defaults-file=/var/spool/icinga2/.my.cnf
```

OK output:

```text
Everything is ok. Temporary tables created on disk: 8.4% (134 on disk / 1.6K total). `tmp_table_size` = 128.0MiB, `max_heap_table_size` = 128.0MiB.
```

WARN output:

```text
Temporary tables created on disk: 34.6% (540 on disk / 1.6K total) [WARNING]. `tmp_table_size` = 16.0MiB, `max_heap_table_size` = 16.0MiB.

Recommendations:
* Raise both `tmp_table_size` (currently 16.0MiB) and `max_heap_table_size` (currently 16.0MiB) toward 256.0MiB (mysqltuner cut-off); keep them equal because the effective per-table cap is the smaller of the two
* These limits apply per implicit temp table, not as a shared pool. Size them just above the largest single temp table your workload actually generates; going higher does not help. Plan RAM headroom for that limit multiplied by the number of concurrent sessions building temp tables, so the server does not run out of memory under load. Use the slow log or `sys.x$statements_with_temp_tables` in `performance_schema` to find typical temp-table sizes
* Audit `SELECT DISTINCT` and `GROUP BY` queries that run without a `LIMIT` clause; those are the classic source of oversized temporary tables
```


## States

* WARN if the percentage of temporary tables created on disk is outside `--warning` (default: `25`, alerts above 25%).
* CRIT if the percentage is outside `--critical` (default: `50`, alerts above 50%).
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
