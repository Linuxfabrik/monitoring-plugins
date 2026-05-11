# Check mysql-query


## Overview

Runs up to two admin-supplied `SELECT` statements against MySQL/MariaDB and checks each result against a Nagios range expression. One statement pairs with `--warning` and triggers WARN; the second with `--critical` and triggers CRIT.

A query returning one row with one column is checked as a single value (useful for `SELECT COUNT(*) ...`, `SELECT MAX(timestamp) ...`, etc.); any other shape is checked by its row count. Useful for custom application-level monitoring: queue depth, stale rows, replication lag tables, total user count, daily order count, failed-job count, inventory below threshold, expiring licences, anything an application stores in a table.

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-mysql/)
* At least one of `--warning-query` or `--critical-query` must be provided.
* Thresholds use [Nagios range expressions](https://linuxfabrik.github.io/monitoring-plugins/contributing/#threshold-and-ranges).

**Data Collection:**

* Connects to the MySQL/MariaDB server using the provided credentials.
* Executes the `SELECT` statement(s) provided via `--warning-query` and/or `--critical-query`.
* Result tables are shown in the output (truncated to the first 5 and last 5 rows if more than 10 rows are returned).
* Long queries are truncated to 80 characters with an ellipsis in the summary line; the full query still runs and is graded.


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-query> |
| Nagios/Icinga Check Name              | `check_mysql_query` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | No |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: mysql-query [-h] [-V] [--always-ok] [-c CRIT]
                   [--critical-query CRITICAL_QUERY]
                   [--defaults-file DEFAULTS_FILE]
                   [--defaults-group DEFAULTS_GROUP] [--timeout TIMEOUT]
                   [-w WARN] [--warning-query WARNING_QUERY]

Runs up to two admin-supplied SQL SELECT statements against MySQL/MariaDB and
checks each result against a Nagios range expression. One statement is paired
with `--warning` and triggers WARN; the second with `--critical` and triggers
CRIT. A query returning one row with one column is checked as a single value
(useful for `SELECT COUNT(*) ...`, `SELECT MAX(timestamp) ...`, etc.); any
other shape is checked by its row count. Useful for custom application-level
monitoring: queue depth, stale rows, replication lag tables, total user count,
daily order count, failed-job count, inventory below threshold, expiring
licences, anything an application stores in a table.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRIT   CRIT threshold as a Nagios range expression.
  --critical-query CRITICAL_QUERY
                        `SELECT` statement whose result is checked against
                        `--critical`. If the result contains more than one
                        column, the row count is used. Otherwise the single
                        returned value is used.
  --defaults-file DEFAULTS_FILE
                        MySQL/MariaDB cnf file to read user, host and password
                        from. Example: `--defaults-
                        file=/var/spool/icinga2/.my.cnf`. Default:
                        /var/spool/icinga2/.my.cnf
  --defaults-group DEFAULTS_GROUP
                        Group/section to read from in the cnf file. Default:
                        client
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -w, --warning WARN    WARN threshold as a Nagios range expression.
  --warning-query WARNING_QUERY
                        `SELECT` statement whose result is checked against
                        `--warning`. If the result contains more than one
                        column, the row count is used. Otherwise the single
                        returned value is used.
```


## Usage Examples

Table (example):

```text
date       ! network ! hostname ! waitingupdates
-----------+---------+----------+---------------
2023-01-01 ! A       ! alice    ! 0
2023-01-01 ! A       ! bob      ! 1
2023-01-01 ! A       ! charlie  ! 2
2023-01-01 ! A       ! david    ! 3
2023-01-01 ! A       ! erin     ! 4
2023-01-01 ! A       ! faythe   ! 5
2023-01-01 ! A       ! frank    ! 6
2023-01-01 ! A       ! grace    ! 7
2023-01-01 ! A       ! heidi    ! 8
2023-01-01 ! A       ! ivan     ! 9
2023-01-01 ! A       ! judy     ! 10
2023-01-01 ! B       ! mallory  ! 0
2023-01-01 ! B       ! michael  ! 1
2023-01-01 ! B       ! niaj     ! 2
2023-01-01 ! B       ! olivia   ! 3
2023-01-01 ! B       ! oscar    ! 4
2023-01-01 ! B       ! peggy    ! 5
2023-01-01 ! B       ! rupert   ! 6
2023-01-01 ! B       ! sybil    ! 7
2023-01-01 ! C       ! trent    ! 0
2023-01-01 ! C       ! trudy    ! 1
2023-01-01 ! C       ! victor   ! 2
2023-01-01 ! C       ! walter   ! 3
2023-01-01 ! C       ! wendy    ! 4
```

WARN if more than 6 hosts in network A have more than 3 waiting updates, and CRIT if more than 2 hosts in networks B and C have more than 4 waiting updates:

```bash
./mysql-query \
    --warning-query='select * from data where network = "A" and waitingupdates > 3' \
    --warning=6 \
    --critical-query='select * from data where network <> "A" and waitingupdates > 4' \
    --critical=2 \
```

Output:

```text
WARN query (`select * from data where network = "A" and waitingupdates > 3`) returned 7 [WARNING]. CRIT query (`select * from data where network <> "A" and waitingupdates > 4`) returned 3 [CRITICAL].

date       ! network ! hostname ! waitingupdates
-----------+---------+----------+----------------
2023-01-01 ! A       ! erin     ! 4
2023-01-01 ! A       ! faythe   ! 5
2023-01-01 ! A       ! frank    ! 6
2023-01-01 ! A       ! grace    ! 7
2023-01-01 ! A       ! heidi    ! 8
2023-01-01 ! A       ! ivan     ! 9
2023-01-01 ! A       ! judy     ! 10

date       ! network ! hostname ! waitingupdates
-----------+---------+----------+----------------
2023-01-01 ! B       ! peggy    ! 5
2023-01-01 ! B       ! rupert   ! 6
2023-01-01 ! B       ! sybil    ! 7
```


## States

* WARN if the number of rows or single value of `--warning-query` is outside the `--warning` range.
* CRIT if the number of rows or single value of `--critical-query` is outside the `--critical` range.
* Otherwise OK.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mysql_query_crit_value | Number | Number of rows or single value returned by `--critical-query`. |
| mysql_query_warn_value | Number | Number of rows or single value returned by `--warning-query`. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
