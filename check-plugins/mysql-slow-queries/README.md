# Check mysql-slow-queries


## Overview

Checks the rate of slow queries in MySQL/MariaDB (`Slow_queries` / `Questions`). A high ratio means many queries are exceeding `long_query_time` and likely need optimisation. Also verifies that the slow query log is enabled and that `long_query_time` is set to a reasonable value.

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-mysql/)
* `Slow_queries` is a status counter; it increments for every query slower than `long_query_time` regardless of whether `slow_query_log` is on. The log determines only whether the slow queries are persisted to a file for postmortem analysis - it does not affect the counter the plugin reads.
* When the ratio triggers a warning, the check recommends enabling the slow query log if disabled, so admins can investigate the offending queries.
* If `long_query_time` is set higher than 10 seconds, the check recommends lowering it (mysqltuner cut-off: queries slower than 10 s are practically useless to capture).

**Data Collection:**

* Queries `SHOW GLOBAL VARIABLES` for `long_query_time` and `slow_query_log`.
* Queries `SHOW GLOBAL STATUS` for `Questions` and `Slow_queries`.
* Calculates the percentage of slow queries relative to total queries.
* `Questions` and `Slow_queries` are written to a local SQLite cache so the plugin can compute per-second rates instead of emitting cumulative counters that force Grafana panels to do `non_negative_difference()` themselves.
* Logic is taken from [MySQLTuner script](https://github.com/major/MySQLTuner-perl):mysql_stats() (the "Slow queries" section), verified in sync with v2.8.41.


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-slow-queries> |
| Nagios/Icinga Check Name              | `check_mysql_slow_queries` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `pymysql` |
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-monitoring-plugins-mysql-slow-queries.db` |


## Help

```text
usage: mysql-slow-queries [-h] [-V] [--always-ok] [-c CRITICAL]
                          [--defaults-file DEFAULTS_FILE]
                          [--defaults-group DEFAULTS_GROUP]
                          [--timeout TIMEOUT] [-w WARNING]

Checks the rate of slow queries in MySQL/MariaDB (`Slow_queries` /
`Questions`). A high ratio means many queries are exceeding `long_query_time`
and likely need optimisation. Alerts when the ratio crosses `--warning` /
`--critical`. Also reports whether the slow query log is enabled and whether
`long_query_time` is set to a value > 10 seconds (mysqltuner's "queries slower
than 10 s are practically useless to capture" cut-off).

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRITICAL
                        Percentage of `Slow_queries` / `Questions` at which
                        the ratio flips to CRITICAL. Default: 10
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
                        Percentage of `Slow_queries` / `Questions` at which
                        the ratio flips to WARNING. Default: 5
```


## Usage Examples

```bash
./mysql-slow-queries --defaults-file=/var/spool/icinga2/.my.cnf
```

Output (OK):

```text
Everything is ok. Slow queries: 0.5% (5.0 slow / 1.0K total). `long_query_time` = 2.0s. `slow_query_log` is `ON`.
```

Output (WARN):

```text
Slow queries: 7.0% (7.0 slow / 100.0 total) [WARNING]. `long_query_time` = 12.0s. `slow_query_log` is `OFF`.

Recommendations:
* Investigate the slow query log and optimise the 7 slow queries (out of 100 total)
* Set `long_query_time` <= 10 (currently 12.0s); queries slower than 10s are practically useless to capture
* Enable `slow_query_log` to troubleshoot the slow queries
```


## States

* WARN when `Slow_queries` / `Questions` reaches `--warning` (default 5%); CRIT at `--critical` (default 10%).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

The two cumulative counters (`Questions`, `Slow_queries`) are emitted as in-plugin-computed per-second rates instead of `uom='c'` continuous counters; the deltas appear from the second check run onwards (the first run needs a baseline in the local SQLite cache).

| Name | Type | Description |
|----|----|----|
| mysql_long_query_time | Seconds | If a query takes longer than this many seconds to execute, the `Slow_queries` status variable is incremented and, if enabled, the query is logged to the slow query log. |
| mysql_pct_slow_queries | Percentage | `Slow_queries / Questions * 100`. |
| mysql_questions_per_second | Number | Per-second rate of `Questions` since the previous check run. |
| mysql_slow_queries_per_second | Number | Per-second rate of `Slow_queries` since the previous check run. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:
    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
