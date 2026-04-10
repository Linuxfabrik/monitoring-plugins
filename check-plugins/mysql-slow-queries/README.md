# Check mysql-slow-queries

## Overview

Checks the rate of slow queries in MySQL/MariaDB. A high slow query rate indicates queries that may need optimization. Also verifies that the slow query log is enabled and that `long_query_time` is set to a reasonable value.

**Data Collection:**

* Queries `SHOW GLOBAL VARIABLES` for `long_query_time` and `slow_query_log`
* Queries `SHOW GLOBAL STATUS` for `Questions` and `Slow_queries`
* Calculates the percentage of slow queries relative to total queries
* Logic is taken from [MySQLTuner script](https://github.com/major/MySQLTuner-perl):mysql_stats(), v1.9.8

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-MYSQL.md)
* If the slow query rate triggers a warning, the check recommends enabling the slow query log (if disabled) to troubleshoot the offending queries
* If `long_query_time` is set higher than 10 seconds, the check recommends lowering it


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-slow-queries> |
| Nagios/Icinga Check Name              | `check_mysql_slow_queries` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: mysql-slow-queries [-h] [-V] [--always-ok]
                          [--defaults-file DEFAULTS_FILE]
                          [--defaults-group DEFAULTS_GROUP]
                          [--timeout TIMEOUT]

Checks the rate of slow queries in MySQL/MariaDB. A high slow query rate
indicates queries that may need optimization. Also verifies that the slow
query log is enabled. Alerts when the slow query rate is too high.

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
./mysql-slow-queries --defaults-file=/var/spool/icinga2/.my.cnf
```

Output:

```text
Slow queries: 7.0% (7.0 slow queries/100.0 questions) [WARNING]. Set long_query_time <= 10. Enable the slow_query_log to troubleshoot bad queries.
```


## States

* WARN if the number of slow queries exceeds 5% of all queries.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mysql_long_query_time | Seconds | If a query takes longer than this many seconds to execute, the `Slow_queries` status variable is incremented and, if enabled, the query is logged to the slow query log. |
| mysql_pct_slow_queries | Percentage | Slow_queries / Questions * 100 |
| mysql_questions | Continous Counter | Number of statements executed by the server, excluding COM_PING, COM_STATISTICS, COM_STMT_PREPARE, COM_STMT_CLOSE, and COM_STMT_RESET statements. |
| mysql_slow_queries | Continous Counter | Number of queries which took longer than `long_query_time` to run. The slow query log does not need to be active for this to be recorded. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:
    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
