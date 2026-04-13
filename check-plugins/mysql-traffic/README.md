# Check mysql-traffic


## Overview

Reports MySQL/MariaDB traffic statistics including uptime, queries per second, connection rates, and bytes sent and received. Also calculates the read/write ratio based on SELECT, INSERT, UPDATE, DELETE, and REPLACE commands. Logic is taken from [MySQLTuner script](https://github.com/major/MySQLTuner-perl):mysql_stats(), v1.9.8.

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-mysql/)
* This plugin always returns OK and is purely informational

**Data Collection:**

* Queries `SHOW GLOBAL STATUS` for `Bytes_received`, `Bytes_sent`, `Com_delete`, `Com_insert`, `Com_replace`, `Com_select`, `Com_update`, `Connections`, `Questions`, and `Uptime`
* Calculates queries per second as `Questions / Uptime`
* Calculates the read/write ratio from SELECT (reads) and INSERT + UPDATE + DELETE + REPLACE (writes)


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-traffic> |
| Nagios/Icinga Check Name              | `check_mysql_traffic` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Requirements                          | User with no privileges, locked down to `127.0.0.1` - for example `monitoring\@127.0.0.1`. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions. |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: mysql-traffic [-h] [-V] [--defaults-file DEFAULTS_FILE]
                     [--defaults-group DEFAULTS_GROUP] [--timeout TIMEOUT]

Reports MySQL/MariaDB traffic statistics including uptime, queries per second,
connection rates, and bytes sent and received.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
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
./mysql-traffic
```

Output:

```text
Up 1W 3D (907.7K q [1.0 qps], 470.0 conn, TX: 560.2M, RX: 96.4M); Read/Write: 65.3%/34.7%
```


## States

* Always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mysql_bytes_received | Bytes | Total bytes received from all clients. |
| mysql_bytes_sent | Bytes | Total bytes sent to all clients. |
| mysql_com_delete | Continuous Counter | Number of DELETE commands executed. |
| mysql_com_insert | Continuous Counter | Number of INSERT commands executed. |
| mysql_com_replace | Continuous Counter | Number of REPLACE commands executed. |
| mysql_com_select | Continuous Counter | Number of SELECT commands executed. Also includes queries that make use of the query cache. |
| mysql_com_update | Continuous Counter | Number of UPDATE commands executed. |
| mysql_connections | Continuous Counter | Number of connection attempts (both successful and unsuccessful). |
| mysql_pct_reads | Percentage | total_reads / (total_reads + total_writes) \* 100 |
| mysql_pct_writes | Percentage | 100 - pct_reads |
| mysql_qps | Number | Queries per second. |
| mysql_questions | Continuous Counter | Number of statements executed by the server, excluding COM_PING, COM_STATISTICS, COM_STMT_PREPARE, COM_STMT_CLOSE, and COM_STMT_RESET statements. |
| mysql_uptime | Seconds | Number of seconds the server has been running. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:

    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
