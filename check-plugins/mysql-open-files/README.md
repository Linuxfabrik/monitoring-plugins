# Check mysql-open-files

## Overview

Checks the open file usage in MySQL/MariaDB as a percentage of the configured `open_files_limit`. If the usage approaches the limit, the server may start refusing new connections or fail to open tables.

**Data Collection:**

* Queries `SHOW GLOBAL VARIABLES` for `open_files_limit`
* Queries `SHOW GLOBAL STATUS` for `Open_files`
* Calculates the percentage of open files relative to the limit
* Logic is taken from [MySQLTuner script](https://github.com/major/MySQLTuner-perl):mysql_stats(), v1.9.8

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-MYSQL.md)


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-open-files> |
| Nagios/Icinga Check Name              | `check_mysql_open_files` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: mysql-open-files [-h] [-V] [--always-ok]
                        [--defaults-file DEFAULTS_FILE]
                        [--defaults-group DEFAULTS_GROUP] [--timeout TIMEOUT]

Checks the open file usage in MySQL/MariaDB as a percentage of the configured
open_files_limit. Alerts when the usage rate approaches the limit.

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
./mysql-open-files --defaults-file=/var/spool/icinga2/.my.cnf
```

Output:

```text
0.2% of open_files_limit used (80.0/32.8K).
```


## States

* WARN if the number of open files exceeds 85% of `open_files_limit`.
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
