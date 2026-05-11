# Check mysql-thread-cache


## Overview

Checks how effectively MySQL/MariaDB caches threads for re-use. A low hit rate means the server frequently creates new threads instead of reusing cached ones, which is expensive. Logic taken from [MySQLTuner](https://github.com/major/MySQLTuner-perl):mysql_stats() and verified in sync with MySQLTuner v2.8.41.

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-mysql/)
* When a thread pool is enabled (`have_threadpool = YES`), `thread_cache_size` is ignored and `Threads_cached` stays at 0. The hit-rate check is skipped in that case with an info line
* On freshly-booted servers (uptime < 1 hour) the hit-rate alert is suppressed: an empty cache routinely sits at 0% hit rate for the first minutes after a restart and produces false-positive alerts otherwise. mysqltuner does not skip this case; we do

**Data Collection:**

* Queries `SHOW GLOBAL VARIABLES` for `have_threadpool` and `thread_cache_size`
* Queries `SHOW GLOBAL STATUS` for `Connections`, `Threads_cached`, `Threads_created`, and `Uptime`
* Calculates the hit rate as `100 - (Threads_created / Connections * 100)`
* Cumulative counters are persisted in a local SQLite cache between runs so the dashboard can plot per-second rates instead of unbounded counters


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-thread-cache> |
| Nagios/Icinga Check Name              | `check_mysql_thread_cache` |
| Check Interval Recommendation         | Every hour |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Requirements                          | User with no privileges, locked down to `127.0.0.1` - for example `monitoring\@127.0.0.1`. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions. |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: mysql-thread-cache [-h] [-V] [--always-ok] [-c CRITICAL]
                          [--defaults-file DEFAULTS_FILE]
                          [--defaults-group DEFAULTS_GROUP]
                          [--timeout TIMEOUT] [-w WARNING]

Checks the MySQL/MariaDB thread cache hit rate (`100 - Threads_created /
Connections * 100`). A low rate means the server keeps creating new threads
instead of reusing cached ones, which is expensive. Alerts when the rate
crosses `--warning` / `--critical`. The check is skipped when the server is
running a thread pool (`have_threadpool = YES`); thread pools ignore
`thread_cache_size` entirely. On freshly-booted servers (uptime < 1 hour) the
hit-rate alert is suppressed because the cache has not had time to warm up.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRITICAL
                        CRIT threshold in percent. Supports Nagios ranges.
                        Default: 30:
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
                        Default: 50:
```


## Usage Examples

```bash
./mysql-thread-cache --defaults-file=/var/spool/icinga2/.my.cnf
```

OK output:

```text
Everything is ok. Thread cache hit rate: 99.9% (910 created / 8.7M connections). `thread_cache_size` = 256, `Threads_cached` = 12.
```

WARN output:

```text
Thread cache hit rate: 22.4% (1.2M created / 1.6M connections) [WARNING]. `thread_cache_size` = 8, `Threads_cached` = 8.

Recommendations:
* Raise `thread_cache_size` (currently 8); the server keeps creating new threads instead of reusing cached ones
```


## States

* WARN if `thread_cache_size` is `0` (the cache is disabled).
* WARN if the thread cache hit rate is at or below `--warning` (default: `50:`, alerts below 50%) after at least one hour of uptime.
* CRIT if the hit rate is at or below `--critical` (default: `30:`, alerts below 30%).
* OK if the thread pool is enabled (`have_threadpool = YES`); the check is informational only in that case.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mysql_connections_per_second | Rate | Per-second rate of `Connections` (cumulative counter delta against the local SQLite cache). Appears from the second run onwards. |
| mysql_thread_cache_hit_rate | Percentage | `100 - (Threads_created / Connections * 100)`. Higher is better. |
| mysql_thread_cache_size | Number | Number of threads the server should cache for re-use (`thread_cache_size`). Ignored when a thread pool is enabled. |
| mysql_threads_cached | Number | Threads currently in the cache (`Threads_cached`). Trends with cache utilisation. |
| mysql_threads_created_per_second | Rate | Per-second rate of `Threads_created` (cumulative counter delta against the local SQLite cache). Appears from the second run onwards. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:

    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
