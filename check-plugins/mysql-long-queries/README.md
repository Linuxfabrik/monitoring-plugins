# Check mysql-long-queries


## Overview

Checks for in-flight MySQL/MariaDB queries that have been running longer than `--warning` / `--critical` seconds. Unlike `mysql-slow-queries` (which trends the historical ratio of finished slow queries), this plugin shows queries that are *currently* executing right now, with their session ID, user, database, runtime and a truncated copy of the statement so the admin can `KILL <id>` directly. Sleeping sessions and replication threads are ignored. Logic taken from [MySQLTuner](https://github.com/major/MySQLTuner-perl):mysql_pfs(), but the data source is `information_schema.processlist` so the check works on every MySQL/MariaDB release without requiring Performance Schema to be enabled.

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-mysql/)
* The plugin requires the `PROCESS` privilege on `*.*` so it sees other sessions' queries. Without `PROCESS`, the monitoring user would only see its own connection and silently miss long-running queries from application users; the plugin therefore enforces the grant via `check_privileges()` and exits UNKNOWN with a clear missing-privilege message rather than reporting a false "all clear"
* The statement preview is truncated to 120 characters by default; `--lengthy` shows the full statement so an admin investigating a culprit query gets the whole text without re-running the plugin
* `mysql-slow-queries` and `mysql-long-queries` are complementary: the former tracks the historical ratio of finished slow queries (good for trending and capacity planning), the latter alerts on a single query that is currently misbehaving (good for "kill it now")

**Data Collection:**

* Queries `information_schema.processlist` for sessions where `COMMAND` is not `Sleep`, `Binlog Dump` or `Daemon` and `INFO` is non-null
* Each row's runtime (`TIME` column, seconds) is evaluated against `--warning` / `--critical` (Nagios ranges)


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-long-queries> |
| Nagios/Icinga Check Name              | `check_mysql_long_queries` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Requirements                          | User with `PROCESS` privilege on `*.*` (e.g. `monitoring@127.0.0.1`). Without `PROCESS`, the plugin only sees its own connection. |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: mysql-long-queries [-h] [-V] [--always-ok] [-c CRIT]
                          [--defaults-file DEFAULTS_FILE]
                          [--defaults-group DEFAULTS_GROUP] [--ignore IGNORE]
                          [--lengthy] [--timeout TIMEOUT] [-w WARN]

Checks for in-flight MySQL/MariaDB queries that have been running longer than
`--warning` / `--critical` seconds. Unlike `mysql-slow-queries` (which trends
the historical ratio of finished slow queries), this plugin shows queries that
are *currently* executing right now, with their session ID, user, database,
runtime and a truncated copy of the statement so the admin can `KILL <id>`
directly. Sleeping sessions and replication threads are ignored. Logic taken
from MySQLTuner v2.8.41 `mysql_pfs()`, but the data source is
`information_schema.processlist` so the check works on every MySQL/MariaDB
release without requiring Performance Schema to be enabled. Without `PROCESS`
privilege, the monitoring user only sees its own sessions; grant `PROCESS` on
`*.*` to see queries across all sessions.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRIT   Query runtime in seconds that triggers CRIT. Supports
                        Nagios ranges. Example: `--critical=60`. Default: 300
  --defaults-file DEFAULTS_FILE
                        MySQL/MariaDB cnf file to read user, host and password
                        from. Example: `--defaults-
                        file=/var/spool/icinga2/.my.cnf`. Default:
                        /var/spool/icinga2/.my.cnf
  --defaults-group DEFAULTS_GROUP
                        Group/section to read from in the cnf file. Default:
                        client
  --ignore IGNORE       Regex applied to the running statement. Matching
                        queries are ignored (e.g. `--ignore=^mysqldump` to
                        exclude backup runs). Repeat the flag for multiple
                        patterns. Example: `--ignore=ANALYZE
                        --ignore=^mysqldump`
  --lengthy             Extended reporting.
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -w, --warning WARN    Query runtime in seconds that triggers WARN. Supports
                        Nagios ranges. Example: `--warning=15`. Default: 30
```


## Usage Examples

```bash
./mysql-long-queries --defaults-file=/var/spool/icinga2/.my.cnf
```

OK output:

```text
Everything is ok. 0 queries over threshold (of 0 in-flight queries), longest 0s.
```

WARN output:

```text
1 query over threshold (of 2 in-flight queries), longest 47s.

! ID    ! User ! DB      ! Runtime         ! Statement                                                                                                                  !
! ----- ! ---- ! ------- ! --------------- ! -------------------------------------------------------------------------------------------------------------------------- !
! 12345 ! app  ! orders  ! 47s [WARNING]   ! SELECT o.* FROM orders o JOIN customers c ON o.cust_id=c.id WHERE c.region='EU' AND o.created_at > '2026-01-01' ORDER ...   !
! 12346 ! app  ! orders  ! 2s              ! SELECT COUNT(*) FROM orders WHERE status='pending'                                                                          !
```


## States

* OK if no in-flight query is over the warning threshold.
* WARN if one or more queries are in the `--warning` band but not in the `--critical` band.
* CRIT if one or more queries are in the `--critical` band.
* `--ignore` regex suppresses individual queries (e.g. known long-running backup jobs).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mysql_long_queries_max_runtime_seconds | Seconds | Runtime of the longest in-flight query. Useful for the "how long was the worst query in this minute?" Grafana trend. |
| mysql_long_queries_over_warn | Number | Count of in-flight queries whose runtime is in the warning or critical band. |
| mysql_long_queries_total | Number | Total count of in-flight non-sleeping queries with a statement attached, regardless of runtime. Useful to baseline the normal in-flight load. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:

    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
