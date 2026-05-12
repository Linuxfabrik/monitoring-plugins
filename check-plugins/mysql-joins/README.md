# Check mysql-joins


## Overview

Checks the rate of joins executed without indexes in MySQL/MariaDB (`Select_range_check + Select_full_join`). More than 250 such joins per day (matching MySQLTuner) indicates missing indexes that can severely impact query performance.

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-mysql/)
* The recommendation depends on the current `join_buffer_size`: below 4 MiB the plugin suggests raising it; above 4 MiB it stops doing so. The 4 MiB threshold is **MySQLTuner's heuristic**, hard-coded in their source as the cutoff for the "raise" recommendation. Neither MySQL nor MariaDB documentation describes a performance cliff at that point - the join-buffer sizing is a continuous diminishing-returns curve. We mirror the threshold for consistency with MySQLTuner output, not because of a documented technical sweet spot
* `join_buffer_size > 4 MiB` is independently flagged as WARN (deviation from MySQLTuner): `join_buffer_size` is allocated **per session**, so on a server with many `max_connections` an oversized buffer reserves a lot of memory (`size × max_connections`)

**Data Collection:**

* Queries `SHOW GLOBAL VARIABLES` for `join_buffer_size`
* Queries `SHOW GLOBAL STATUS` for `Select_full_join`, `Select_range_check`, and `Uptime`
* Uptime is clamped to a minimum of 1 second so the per-day rate is well-defined on a freshly booted server
* Logic is taken from [MySQLTuner](https://github.com/major/MySQLTuner-perl):mysql_stats() (Joins section) and has been verified in sync with MySQLTuner


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-joins> |
| Nagios/Icinga Check Name              | `check_mysql_joins` |
| Check Interval Recommendation         | Every hour |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: mysql-joins [-h] [-V] [--always-ok] [--defaults-file DEFAULTS_FILE]
                   [--defaults-group DEFAULTS_GROUP] [--timeout TIMEOUT]

Checks the rate of joins executed without indexes in MySQL/MariaDB
(`Select_range_check + Select_full_join`). A high rate (more than 250 such
joins per day, matching MySQLTuner) indicates missing indexes and can severely
impact query performance. Alerts when the rate exceeds the threshold.

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
./mysql-joins --defaults-file=/var/spool/icinga2/.my.cnf
```

Output:

```text
143.9K JOINs without indexes in 1W 6D of uptime (approx. 10.9K/day; `Select_range_check` = 0, `Select_full_join` = 143877) [WARNING].

Recommendations:
* Use JOINs with indexes wherever possible
* Otherwise raise `join_buffer_size` > 256.0KiB (currently below the 4.0MiB point above which raising it stops helping)
```

When the rate is below the threshold, the plugin still emits the count and breakdown so admins see what was measured:

```text
8.0 JOINs without indexes in 1W 6D of uptime (approx. 0.6/day; `Select_range_check` = 0, `Select_full_join` = 8).
```


## States

* WARN if more than 250 joins without indexes per day on a lifetime average (`Select_range_check + Select_full_join` divided by `Uptime / 86400`).
* WARN if `join_buffer_size > 4 MiB`. The buffer is allocated **per session**, so `max_connections × join_buffer_size` is real reserved memory. The 4 MiB threshold is MySQLTuner's heuristic cutoff (the point above which MySQLTuner stops recommending to raise the buffer); MySQLTuner itself does not alert oversized buffers, but the per-session memory cost is admin-visible.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mysql_join_buffer_size | Bytes | `join_buffer_size` - minimum size of the buffer used for queries that cannot use an index. |
| mysql_joins_without_indexes_per_day | Number | `(Select_range_check + Select_full_join) / (Uptime / 86400)` - lifetime average. |
| mysql_joins_without_indexes_per_second | Number | Per-second rate of `Select_range_check + Select_full_join`. Only emitted from the second run onwards (the plugin keeps a small SQLite cache between runs to compute the delta in-plugin instead of using a continuous counter). |
| mysql_select_full_join_per_second | Number | Per-second rate of `Select_full_join` (joins which did not use an index). Only emitted from the second run onwards. |
| mysql_select_range_check_per_second | Number | Per-second rate of `Select_range_check` (joins without keys that check for key usage after each row). Only emitted from the second run onwards. |
| mysql_uptime | Seconds | Number of seconds the server has been running. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:
    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
