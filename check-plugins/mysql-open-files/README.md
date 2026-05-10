# Check mysql-open-files


## Overview

Reports MySQL/MariaDB's current open-files count (`Open_files`, a server-wide status counter) as a percentage of `open_files_limit` (the per-process file-descriptor ceiling MySQL was started with). Alerts when the ratio crosses `--warning` / `--critical`. If the usage approaches the limit, the server may start refusing new connections or fail to open tables.

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-mysql/)

**Data Collection:**

* Queries `SHOW GLOBAL VARIABLES` for `open_files_limit`.
* Queries `SHOW GLOBAL STATUS` for `Open_files`.
* Calculates the percentage of open files relative to the limit.
* Logic is taken from [MySQLTuner script](https://github.com/major/MySQLTuner-perl):mysql_stats() ("Open files" section), verified in sync with v2.8.41.


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-open-files> |
| Nagios/Icinga Check Name              | `check_mysql_open_files` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: mysql-open-files [-h] [-V] [--always-ok] [-c CRITICAL]
                        [--defaults-file DEFAULTS_FILE]
                        [--defaults-group DEFAULTS_GROUP] [--timeout TIMEOUT]
                        [-w WARNING]

Reports MySQL/MariaDB's current open-files count as a percentage of
`open_files_limit` (the per-process file-descriptor ceiling MySQL was started
with; `Open_files` is a server-wide status counter, not a per-connection
metric). Alerts when the ratio crosses `--warning` / `--critical`.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRITICAL
                        Percentage of `open_files_limit` at which the open-
                        files ratio flips to CRITICAL. Default: 95
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
                        Percentage of `open_files_limit` at which the open-
                        files ratio flips to WARNING. Default: 85
```


## Usage Examples

```bash
./mysql-open-files --defaults-file=/var/spool/icinga2/.my.cnf
```

Output (OK):

```text
0.2% of `open_files_limit` used (80.0/32.8K).
```

Output (WARN / CRIT):

```text
92.0% of `open_files_limit` used (30.2K/32.8K) [WARNING].

Recommendations:
* Raise `open_files_limit` (currently 32.8K)
```


## States

* WARN when `Open_files` / `open_files_limit` reaches `--warning` (default 85%); CRIT at `--critical` (default 95%).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mysql_open_files | Number | Number of regular files currently opened by the server. Does not include sockets or pipes. |
| mysql_open_files_limit | Number | The number of file descriptors available to MySQL/MariaDB. |
| mysql_pct_files_open | Percentage | Open_files / open_files_limit * 100 |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:
    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
