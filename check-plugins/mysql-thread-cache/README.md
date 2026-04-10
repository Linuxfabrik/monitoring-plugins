# Check mysql-thread-cache

## Overview

Checks how effectively MySQL/MariaDB caches threads for re-use. A low cache hit rate means the server frequently creates new threads, which is expensive. Logic is taken from [MySQLTuner script](https://github.com/major/MySQLTuner-perl):mysql_stats(), v1.9.8.

**Alerting Logic:**

* WARN if `thread_cache_size` is 0 (thread cache disabled)
* WARN if thread cache hit rate is 50% or lower, but only after the server has been running for at least one hour (to let the cache warm up)
* No alert is raised when the thread pool is active, because `thread_cache_size` is ignored in that case

**Data Collection:**

* Queries `SHOW GLOBAL VARIABLES` for `have_threadpool` and `thread_cache_size`
* Queries `SHOW GLOBAL STATUS` for `Connections`, `Threads_created`, and `Uptime`
* Calculates the hit rate as `100 - (Threads_created / Connections * 100)`

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-MYSQL.md)
* When the thread pool is enabled (Percona or MariaDB), the value of `thread_cache_size` is ignored and `Threads_cached` shows 0


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-thread-cache> |
| Nagios/Icinga Check Name              | `check_mysql_thread_cache` |
| Check Interval Recommendation         | Once an hour |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Requirements                          | User with no privileges, locked down to `127.0.0.1` - for example `monitoring\@127.0.0.1`. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions. |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: mysql-thread-cache [-h] [-V] [--always-ok]
                          [--defaults-file DEFAULTS_FILE]
                          [--defaults-group DEFAULTS_GROUP]
                          [--timeout TIMEOUT]

Checks how effectively MySQL/MariaDB caches threads for re-use. A low cache
hit rate means the server frequently creates new threads, which is expensive.
Alerts when the cache hit rate is too low.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --defaults-file DEFAULTS_FILE
                        MySQL/MariaDB cnf file to read parameters like user,
                        host and password from (instead of specifying them on
                        the command line). Example:
                        `/var/spool/icinga2/.my.cnf`. Default:
                        /var/spool/icinga2/.my.cnf
  --defaults-group DEFAULTS_GROUP
                        Group/section to read from in the cnf file. Default:
                        client
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
```


## Usage Examples

```bash
./mysql-thread-cache --defaults-file=/var/spool/icinga2/.my.cnf
```

Output:

```text
100.0% thread cache hit rate (910.0 threads created / 8.7M connections).
```


## States

* OK if the thread cache hit rate is above 50% (after at least one hour of uptime) or if the thread pool is active.
* WARN if `thread_cache_size` is 0.
* WARN if thread cache hit rate is 50% or lower.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mysql_connections | Continous Counter | Number of connection attempts (both successful and unsuccessful). |
| mysql_thread_cache_hit_rate | Percentage | 100 - Threads_created / Connections \* 100 |
| mysql_thread_cache_size | Bytes | Number of threads server caches for re-use. |
| mysql_threads_created | Continous Counter | Number of threads created to respond to client connections. If too large, look at increasing thread_cache_size. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:

    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
