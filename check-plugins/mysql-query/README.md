# Check mysql-query

## Overview

This check runs a warning and/or critical query against any MySQL/MariaDB schema. The result - the number of items found or a specific number, depending on the query - can be checked against a [range expression](https://github.com/Linuxfabrik/monitoring-plugins#threshold-and-ranges).

As an example, consider a simple table with a list of clients:

```text
hostname ! waitingupdates
---------+---------------
alice    ! 3
bob      ! 11
charlie  ! 5
david    ! 7
erin     ! 0
frank    ! 6
```

The use case: Issue a warning when the number of clients with 5 or more waiting updates is greater than 2. One possible SQL statement for getting the number of clients with 5 or more waiting updates is:

```text
select *
from data
where waitingupdates >= 5
```

In the above example, 4 *rows* are returned, so `mysql-query` checks the number of rows against the given threshold.

You also may count the number of clients directly, which just returns one row with a value of `4` in one column:

```text
select count(*) as cnt
from data
where waitingupdates >= 5
```

In this case, `mysql-query` checks the returned value `4` with the specified threshold.

The full command line call retrieving the data and applying the thresholds (which are [ranges](https://github.com/Linuxfabrik/monitoring-plugins#threshold-and-ranges)) is:

```bash
mysql-query \
    --warning-query='select * from data where waitingupdates >= 5' \
    --warning=2
```

Hints:

* See [additional notes for all mysql monitoring plugins](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-MYSQL.rst)


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-query> |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | No |
| Compiled for Windows                  | No |
| Requirements                          | User with no privileges, locked down to `127.0.0.1` - for example `monitoring\@127.0.0.1`. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions. |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: mysql-query [-h] [-V] [--always-ok] [-c CRIT]
                   [--critical-query CRITICAL_QUERY]
                   [--defaults-file DEFAULTS_FILE]
                   [--defaults-group DEFAULTS_GROUP] [--timeout TIMEOUT]
                   [-w WARN] [--warning-query WARNING_QUERY]

This check connects to a MySQL/MariaDB database and can then run a separate
warning and/or critical query against it. The result - the number of items
found or a specific number - can be checked against a range expression.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRIT   Set the CRIT threshold. Supports ranges.
  --critical-query CRITICAL_QUERY
                        `SELECT` statement. If its result contains more than
                        one column, the number of rows is checked against
                        `--critical`, otherwise the single value is used.
  --defaults-file DEFAULTS_FILE
                        Specifies a cnf file to read parameters like user,
                        host and password from (instead of specifying them on
                        the command line), for example
                        `/var/spool/icinga2/.my.cnf`. Default:
                        /var/spool/icinga2/.my.cnf
  --defaults-group DEFAULTS_GROUP
                        Group/section to read from in the cnf file. Default:
                        client
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -w, --warning WARN    Set the WARN threshold. Supports ranges.
  --warning-query WARNING_QUERY
                        `SELECT` statement. If its result contains more than
                        one column, the number of rows is checked against
                        `--warning`, otherwise the single value is used.
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
7 results from warning query `select * from data where network = "A" and waitingupdates > 3` [WARNING] and 3 results from critical query `select * from data where network <> "A" and waitingupdates > 4` [CRITICAL]

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

* WARN if number of rows or single value of `--warning-query` is outside `--warning` range
* CRIT if number of rows or single value of `--critical-query` is outside `--critical` range
* Otherwise OK


## Perfdata / Metrics

| Name     | Type   | Description                                          |
|----------|--------|------------------------------------------------------|
| cnt_warn | Number | Number of rows or single value of `--warning-query`  |
| cnt_crit | Number | Number of rows or single value of `--critical-query` |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
