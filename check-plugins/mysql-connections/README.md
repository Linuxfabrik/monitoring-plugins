# Check mysql-connections

## Overview

Checks the connection usage rate, the rate of aborted connections, and whether name resolution is active for new connections on MySQL/MariaDB. Provides recommendations when thresholds are exceeded.

**Data Collection:**

* Queries `SHOW GLOBAL VARIABLES` for `interactive_timeout`, `max_connections`, `skip_name_resolve`, and `wait_timeout`
* Queries `SHOW GLOBAL STATUS` for `Aborted_connects`, `Connections`, `Max_used_connections`, `Max_used_connections_time`, `Threads_connected`, and `Threads_running`
* Reports current, peak, and aborted connection statistics
* Logic is taken from [MySQLTuner script](https://github.com/major/MySQLTuner-perl):mysql_stats(), v1.9.8

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-MYSQL.md)
* A reverse name resolution is made for each new connection when `skip_name_resolve` is OFF, which can reduce performance. Configure your accounts with IP addresses or subnets only and set `skip-name-resolve=ON` to avoid this.


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-connections> |
| Nagios/Icinga Check Name              | `check_mysql_connections` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
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
0.0% aborted connections (0.0/3.1K); current 90% used (136/151, 5 threads running) [WARNING]; peak 93% used (140/151) at 2023-10-06 10:08:47; ; interactive_timeout = 1h, wait_timeout = 1; Name resolution is active [WARNING]

Recommendations:
* Reduce or eliminate unclosed connections and network issues.
* Reduce or eliminate persistent connections to reduce connection usage (set connections > 10, wait_timeout < 28800 and/or interactive_timeout < 28800).
* A reverse name resolution is made for each new connection and can reduce performance. Configure your accounts with ip or subnets only, then update your configuration with skip-name-resolve=ON.
```


## States

* WARN if the number of connections exceeds 85% of `max_connections`.
* WARN if the number of aborted connections exceeds 3% of all connections.
* WARN if name resolution is active (unless `--ignore-name-resolution` is used).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mysql_aborted_connects | Continous Counter | Number of failed server connection attempts. This can be due to a client using an incorrect password, a client not having privileges to connect to a database, a connection packet not containing the correct information, or if it takes more than `connect_timeout` seconds to get a connect packet. |
| mysql_connections | Continous Counter | Number of all connection attempts (both successful and unsuccessful). |
| mysql_interactive_timeout | Seconds | Time in seconds that the server waits for an interactive connection to become active before closing it. |
| mysql_max_connections | Number | The maximum number of simultaneous client connections. |
| mysql_max_used_connections | Number | Max number of connections ever open at the same time. |
| mysql_pct_connections_aborted | Percentage | Aborted_connects / Connections * 100 |
| mysql_pct_connections_used | Percentage | Threads_connected / max_connections * 100 |
| mysql_threads_connected | Number | Number of clients connected to the server. |
| mysql_threads_running | Number | Number of client connections that are actively running a command. |
| mysql_wait_timeout | Seconds | Time in seconds that the server waits for a connection to become active before closing it. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:
    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
