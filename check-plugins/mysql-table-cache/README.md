# Check mysql-table-cache


## Overview

Checks the hit rate of the MySQL/MariaDB open table cache. A low hit rate means `table_open_cache` is too small for the workload and threads have to keep reopening tables. Logic taken from [MySQLTuner](https://github.com/major/MySQLTuner-perl):mysql_stats() and verified in sync with MySQLTuner.

**Important Notes:**

* Requires MySQL/MariaDB v5.1+
* See [additional notes for all mysql monitoring plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-mysql/)
* On a freshly booted server the hit rate is often near zero because the cache is empty and the first few accesses are all misses. Expect a transient WARN/CRIT immediately after a restart; the rate climbs as the workload reopens the same tables. Schedule restarts during quiet windows or use `--always-ok` for the first few minutes
* `Table_open_cache_overflows` is intentionally not tracked. The MySQL reference manual describes it as "the number of times, after a table is opened or closed, a cache instance has an unused entry and the size of the instance is larger than `table_open_cache / table_open_cache_instances`" ([MySQL Server Status Variables](https://docs.oracle.com/cd/E17952_01/mysql-5.7-en/server-status-variables.html)). In other words, it is a routine cache-housekeeping counter that increments whenever MySQL temporarily extends a per-instance cache bucket above its allocated share, so a non-zero value is not by itself a problem. A [MySQL 5.6 benchmark by Dimitri Kravtchuk](https://planet.mysql.com/entry/?id=34237) shows healthy servers running with non-zero overflows for hours. The hit-rate threshold already covers the "table_open_cache is too small" signal and matches the same heuristic MySQLTuner still uses. See [MariaDB KB: Optimizing table_open_cache](https://mariadb.com/kb/en/library/optimizing-table_open_cache/) for further tuning guidance

**Data Collection:**

* Queries `SHOW GLOBAL VARIABLES` for `open_files_limit` and `table_open_cache`
* Queries `SHOW GLOBAL STATUS` for `Open_tables`, `Opened_tables`, `Table_open_cache_hits`, and `Table_open_cache_misses`
* If `Table_open_cache_hits` is available (MySQL 5.6+ / MariaDB 5.3+) the hit rate is calculated as `Table_open_cache_hits / (Table_open_cache_hits + Table_open_cache_misses) * 100`. Otherwise the legacy `Open_tables / Opened_tables * 100` fallback is used (matches mysqltuner)
* Cumulative hit/miss counters are persisted in a local SQLite cache between runs so the dashboard can plot per-second rates instead of unbounded counters


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-table-cache> |
| Nagios/Icinga Check Name              | `check_mysql_table_cache` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Requirements                          | User with no privileges, locked down to `127.0.0.1` - for example `monitoring\@127.0.0.1`. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions. |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: mysql-table-cache [-h] [-V] [--always-ok] [-c CRITICAL]
                         [--defaults-file DEFAULTS_FILE]
                         [--defaults-group DEFAULTS_GROUP] [--timeout TIMEOUT]
                         [-w WARNING]

Checks the hit rate of the MySQL/MariaDB open table cache
(`Table_open_cache_hits` divided by (`Table_open_cache_hits` +
`Table_open_cache_misses`); on servers without `Table_open_cache_hits` it
falls back to `Open_tables` / `Opened_tables`). A low hit rate means
`table_open_cache` is too small for the workload and threads have to keep
reopening tables. Alerts when the rate drops below `--warning` / `--critical`.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRITICAL
                        CRIT threshold in percent. Supports Nagios ranges.
                        Default: 10:
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
                        Default: 20:
```


## Usage Examples

```bash
./mysql-table-cache --defaults-file=/var/spool/icinga2/.my.cnf
```

OK output:

```text
Everything is ok. Table cache hit rate: 98.3% (2.3M hits / 2.3M requests). `table_open_cache` = 4000, `open_files_limit` = 32000.
```

WARN output:

```text
Table cache hit rate: 12.0% (45 hits / 372 requests) [WARNING]. `table_open_cache` = 400, `open_files_limit` = 1024.

Recommendations:
* Raise `table_open_cache` (currently 400) gradually; verify that `open_files_limit` (1024) stays above it. On MyISAM-heavy workloads `table_open_cache` is the classic scalability bottleneck (`InnoDB` is not affected; see https://bugs.mysql.com/bug.php?id=49177, fixed in MySQL 5.7.9+)
```


## States

* WARN if the table cache hit rate is at or below `--warning` (default: 20%).
* CRIT if the table cache hit rate is at or below `--critical` (default: 10%).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mysql_open_files_limit | Number | The number of file descriptors available to MariaDB. |
| mysql_open_tables | Number | Number of currently opened tables, excluding temporary tables. |
| mysql_opened_tables | Number | Number of tables the server has opened. |
| mysql_table_cache_hit_rate | Percentage | Table cache hit rate. |
| mysql_table_open_cache | Number | Maximum number of open tables cached in one table cache instance. |
| mysql_table_open_cache_hits_per_second | Rate | Per-second rate of `Table_open_cache_hits` (cumulative counter delta against the local SQLite cache). Only emitted on servers exposing the counter (MySQL 5.6+ / MariaDB 5.3+) and from the second run onwards. |
| mysql_table_open_cache_misses_per_second | Rate | Per-second rate of `Table_open_cache_misses` (cumulative counter delta against the local SQLite cache). Only emitted on servers exposing the counter (MySQL 5.6+ / MariaDB 5.3+) and from the second run onwards. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:

    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
