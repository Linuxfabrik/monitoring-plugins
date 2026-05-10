# Check mysql-connections


## Overview

Checks the connection usage rate, the rate of aborted connections, and whether name resolution is active for new connections on MySQL/MariaDB. Provides recommendations when thresholds are exceeded.

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-mysql/)
* A reverse name resolution is made for each new connection when `skip_name_resolve` is OFF, which can reduce performance. Configure your accounts with IP addresses or subnets only and set `skip-name-resolve=ON` to avoid this. The check is suppressed when `skip_networking=ON` (MySQL/MariaDB then accepts no TCP connections, so name resolution is moot) or when `skip_name_resolve` is not exposed at all (very old MySQL).
* `mysqltuner` alerts only on the lifetime peak (`Max_used_connections / max_connections`); this plugin alerts instead on the **current** usage (`Threads_connected / max_connections`) so spikes show up while they're happening, not just the historical high-water mark. The peak ratio is still emitted as `mysql_pct_max_connections_used` for trending.

**Data Collection:**

* Queries `SHOW GLOBAL VARIABLES` for `interactive_timeout`, `max_connections`, `skip_name_resolve`, `skip_networking`, and `wait_timeout`
* Queries `SHOW GLOBAL STATUS` for `Aborted_connects`, `Connections`, `Max_used_connections`, `Max_used_connections_time`, `Threads_connected`, and `Threads_running`
* Reports current, peak, and aborted connection statistics
* Logic is taken from [MySQLTuner](https://github.com/major/MySQLTuner-perl):mysql_stats() and has been verified in sync with MySQLTuner v2.8.41


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-connections> |
| Nagios/Icinga Check Name              | `check_mysql_connections` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: mysql-connections [-h] [-V] [--always-ok]
                         [--defaults-file DEFAULTS_FILE]
                         [--defaults-group DEFAULTS_GROUP]
                         [--ignore-name-resolution] [--timeout TIMEOUT]

Checks the connection usage rate and the rate of aborted connections in
MySQL/MariaDB. Also verifies whether name resolution is enabled for new
connections, which can impact performance. Alerts when connection usage or
abort rates exceed acceptable levels.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --defaults-file DEFAULTS_FILE
                        MySQL/MariaDB cnf file to read user, host and password
                        from (instead of specifying them on the command line).
                        Example: `/var/spool/icinga2/.my.cnf`. Default:
                        /var/spool/icinga2/.my.cnf
  --defaults-group DEFAULTS_GROUP
                        Group/section to read from in the cnf file. Default:
                        client
  --ignore-name-resolution
                        Suppress the warning about active name resolution.
                        Default: False
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
```


## Usage Examples

```bash
./mysql-connections --defaults-file=/var/spool/icinga2/.my.cnf
```

Output:

```text
0.0% aborted connections (0.0/3.1K); current 90% used (136/151, 5 threads running) [WARNING]; peak 93% used (140/151) at 2023-10-06 10:08:47; `interactive_timeout` = 8h, `wait_timeout` = 8h; Name resolution is active [WARNING]

Recommendations:
* Reduce or eliminate persistent connections to reduce connection usage (raise `max_connections` > 151, lower `wait_timeout` < 28800 and/or lower `interactive_timeout` < 28800).
* A reverse name resolution is made for each new connection and can reduce performance. Configure your accounts with ip or subnets only, then update your configuration with `skip-name-resolve=ON`.
```


## States

* WARN if the **current** number of connections (`Threads_connected`) exceeds 85% of `max_connections`. The lifetime **peak** (`Max_used_connections / max_connections`) is reported and graphed but does not trigger an alert.
* WARN if the lifetime aborted-connections ratio (`Aborted_connects / Connections`) exceeds 3%.
* WARN if name resolution is active (unless `--ignore-name-resolution` is used). Suppressed when `skip_networking=ON` or when the MySQL/MariaDB version does not expose `skip_name_resolve`.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mysql_aborted_connects_per_second | Number | Per-second rate of failed connection attempts (wrong password, missing privilege, malformed connect packet, exceeded `connect_timeout`). Only emitted from the second run onwards (the plugin keeps a small SQLite cache between runs to compute the delta in-plugin instead of using a continuous counter). |
| mysql_connections_per_second | Number | Per-second rate of new connection attempts (successful and failed). Only emitted from the second run onwards. |
| mysql_interactive_timeout | Seconds | Time in seconds that the server waits for an interactive connection to become active before closing it. |
| mysql_max_connections | Number | The maximum number of simultaneous client connections. |
| mysql_max_used_connections | Number | Maximum number of connections ever open at the same time (lifetime peak). |
| mysql_pct_connections_aborted | Percentage | Aborted_connects / Connections * 100, computed from the cumulative MySQL/MariaDB counters (lifetime ratio). |
| mysql_pct_connections_used | Percentage | Threads_connected / max_connections * 100 (current usage). |
| mysql_pct_max_connections_used | Percentage | Max_used_connections / max_connections * 100 (lifetime peak usage). |
| mysql_threads_connected | Number | Number of clients connected to the server. |
| mysql_threads_running | Number | Number of client connections that are actively running a command. |
| mysql_wait_timeout | Seconds | Time in seconds that the server waits for a connection to become active before closing it. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:
    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
