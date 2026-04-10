# Check mysql-logfile

## Overview

Scans the MySQL/MariaDB error log for warnings, errors, startup, and shutdown events. Works even when the database is down by reading the log file directly. Uses a cache to remember the log file location in case the database becomes unavailable.

**Data Collection:**

* Tries to determine the log file location automatically via `SHOW GLOBAL VARIABLES` (`log_error`, `hostname`, `datadir`), falling back to several well-known paths
* Supports reading from a file path, `docker:CONTAINER`, `podman:CONTAINER`, `kubectl:CONTAINER`, or `systemd:UNITNAME`
* Caches the log file location in a local SQLite database so the check can still work when the database is down
* Lines can be filtered out using `--ignore-pattern` (simple string match) or `--ignore-regex` (Python regular expression)
* Logic is taken from [MySQLTuner script](https://github.com/major/MySQLTuner-perl):log_file_recommendations(), v1.9.8

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-MYSQL.md)
* Must be running locally on the MySQL/MariaDB server to read the log file. Requires root or sudo.
* Depending on your site's policy, you could ignore lines matching patterns like "aborted connection" (happens frequently) or "access denied for user" (could be handled by Fail2ban)


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-logfile> |
| Nagios/Icinga Check Name              | `check_mysql_logfile` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | No |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `pymysql` |
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-monitoring-plugins-mysql-logfile.db` |


## Help

```text
usage: mysql-logfile [-h] [-V] [--always-ok] [--cache-expire CACHE_EXPIRE]
                     [--defaults-file DEFAULTS_FILE]
                     [--defaults-group DEFAULTS_GROUP] [-H HOSTNAME]
                     [--ignore-pattern IGNORE_PATTERN]
                     [--ignore-regex IGNORE_REGEX] [--port PORT]
                     [--server-log SERVER_LOG] [--timeout TIMEOUT]

Scans the MySQL/MariaDB error log for warnings and errors, similar to how
MySQLTuner analyzes the log. Works even when the database is down by reading
the log file directly. Uses a cache to avoid re-reading already processed
entries. Requires root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --cache-expire CACHE_EXPIRE
                        The amount of time after which the credential/data
                        cache expires, in minutes. Default: 7200
  --defaults-file DEFAULTS_FILE
                        MySQL/MariaDB cnf file to read user, host and password
                        from. Example: `--defaults-
                        file=/var/spool/icinga2/.my.cnf`. Default:
                        /var/spool/icinga2/.my.cnf
  --defaults-group DEFAULTS_GROUP
                        Group/section to read from in the cnf file. Default:
                        client
  -H, --hostname HOSTNAME
                        MySQL/MariaDB hostname or IP address. Default:
                        127.0.0.1
  --ignore-pattern IGNORE_PATTERN
                        Any line containing this pattern will be ignored. Must
                        be lowercase. Can be specified multiple times.
  --ignore-regex IGNORE_REGEX
                        Any item matching this Python regex will be ignored.
                        Can be specified multiple times. Example:
                        `(?i)linuxfabrik` for a case-insensitive match.
  --port PORT           MySQL/MariaDB port number. Default: 3306
  --server-log SERVER_LOG
                        Log source to read from. Accepts a file path,
                        `docker:CONTAINER`, `podman:CONTAINER`,
                        `kubectl:CONTAINER` or `systemd:UNITNAME`. If omitted,
                        the check tries to fetch the logfile location
                        automatically.
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
```


## Usage Examples

```bash
./mysql-logfile --defaults-file=/var/spool/icinga2/.my.cnf --server-log=systemd:mariadb
./mysql-logfile --ignore-pattern='aborted connection' --ignore-pattern='access denied'
./mysql-logfile --server-log=docker:mariadb
```

Output:

```text
Src: Log file /var/log/mariadb/mariadb.log (size: 5.8KiB), 2 errors [CRITICAL] (last: 220503 11:21:43 [ERROR] Aborting), 1 warning [WARNING] (last: 220502 14:59:58 [Warning] Plugin 'FEEDBACK' is disabled.), 2 starts (last: 220503 11:24:54), 4 shutdowns (last: 220503 11:21:48)
Errors:
* 220503 11:21:43 [ERROR] /usr/libexec/mysqld: unknown variable 'myvar2=myvalue2'
* 220503 11:21:43 [ERROR] Aborting
Warnings:
* 220502 14:59:58 [Warning] Plugin 'FEEDBACK' is disabled.
Starts:
* 220503 11:07:38 [Note] /usr/libexec/mysqld: ready for connections.
* 220503 11:24:54 [Note] /usr/libexec/mysqld: ready for connections.
Shutdowns:
* 220503 11:07:07 [Note] /usr/libexec/mysqld: Shutdown complete
* 220503 11:07:12 [Note] /usr/libexec/mysqld: Shutdown complete
* 220503 11:21:42 [Note] /usr/libexec/mysqld: Shutdown complete
* 220503 11:21:48 [Note] /usr/libexec/mysqld: Shutdown complete
```


## States

* CRIT if the log contains "error" lines.
* WARN if the log contains "warning" lines.
* WARN if a log file is configured but does not exist.
* WARN if the log file size is >= 32 MiB.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mysql_error_lines | Number | Number of error lines found in the log. |
| mysql_logfile_size | Bytes | Log file size. |
| mysql_shutdowns | Number | Number of shutdown events found in the log. |
| mysql_startups | Number | Number of startup events found in the log. |
| mysql_warning_lines | Number | Number of warning lines found in the log. |


## Troubleshooting

`No log file set (set log_error in MySQL/MariaDB config or use the check's --server-log parameter).`
The check tried to get information from an error logfile, but was unable to do so. All possible error logfile locations were tried, but no logfile was found. You have to help by configuring the MySQL/MariaDB system variable `log_error` accordingly, or by providing the `--server-log` parameter to the check.

`'proxies_priv' entry '@% root@mariadb-server' ignored in --skip-name-resolve mode.`
```text
select * from mysql.proxies_priv;
delete from `mysql`.`proxies_priv`
where (`host` = 'mariadb-server') and (`user` = 'root') and (`proxied_host` = '') and (`proxied_user` = '');
```


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:
    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
