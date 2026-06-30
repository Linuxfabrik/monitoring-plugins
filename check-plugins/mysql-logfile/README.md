# Check mysql-logfile


## Overview

Scans the MySQL/MariaDB error log for errors, warnings, startups and shutdowns. Works even when the database is down by reading the log file directly. Uses a cache to remember the log file location in case the database becomes unavailable.

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-mysql/)
* Severity is detected from MySQL/MariaDB's bracketed log tags (`[ERROR]`, `[Warning]`); lines that only mention the words "error" / "warning" elsewhere are not counted.
* When reading from an on-disk log file, the check usually needs root/sudo (typical log files are owned by `mysql:mysql`, mode `0640`). The `performance_schema.error_log` path needs only SELECT on that table.
* Depending on your site's policy, you may want to silence noisy patterns like `aborted connection` or `access denied for user` via `--ignore-pattern` / `--ignore-regex`.
* Both `--ignore-pattern` and `--ignore-regex` are matched against the lowercased log line, so write your patterns in lowercase (or use the `(?i)` flag in a regex).
* A common, harmless example is MySQL/MariaDB closing an idle connection after `wait_timeout` (default 8h); the client's connection pool simply reconnects. To silence only that case without hiding real connection errors, anchor the regex on the timeout reason rather than on `aborted connection` alone: `--ignore-regex='aborted connection.*got timeout reading communication packets'`. The variants `got an error reading communication packets` (client died, network glitch, oversized packet) stay visible.

**Data Collection:**

* On MySQL 8.0.22+, the plugin prefers `performance_schema.error_log` when the table exists and is visible to this user. Works over the network without shell access to the log file.
* Otherwise it determines the log file location automatically via `SHOW GLOBAL VARIABLES` (`log_error`, `hostname`, `datadir`), falling back to several well-known paths.
* Supports reading from a file path, `docker:CONTAINER`, `podman:CONTAINER`, `kubectl:CONTAINER`, or `systemd:UNITNAME`.
* Caches the on-disk log file location in a local SQLite database so the check can still work briefly when the database is down.
* Lines can be filtered out using `--ignore-pattern` (simple string match) or `--ignore-regex` (Python regular expression). Both are applied to the lowercased log line.
* Logic is taken from [MySQLTuner script](https://github.com/major/MySQLTuner-perl):log_file_recommendations(), verified in sync with v2.8.41.


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-logfile> |
| Nagios/Icinga Check Name              | `check_mysql_logfile` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | No |
| Runs on                               | Linux |
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

Scans the MySQL/MariaDB error log for errors, warnings, startups and
shutdowns. On MySQL 8.0.22+ the plugin prefers the
`performance_schema.error_log` table (reachable over the network, no shell
access to the log file needed). Otherwise it reads the on-disk log file, or
fetches recent log lines from a container (`docker:`/`podman:`/`kubectl:`) or
systemd unit (`systemd:`). The on-disk file path is taken from MySQL/MariaDB's
`log_error` variable, with common fallback locations probed when that variable
is empty. The discovered path is cached so the check still works briefly when
the database is down. Severity is detected from the bracketed log tags
(`[ERROR]`, `[Warning]`), which matches MySQL/MariaDB output and avoids false
positives on lines that merely mention "error" or "warning". Recommendations
are grouped under a single block at the end of the output. Reading the on-disk
log file usually requires root/sudo (typical mysql logs are owned by
`mysql:mysql` mode `0640`). The `performance_schema.error_log` path needs
SELECT on that table but no filesystem access.

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
                        Any line containing this pattern will be ignored. The
                        log line is lowercased before matching, so write the
                        pattern in lowercase. Can be specified multiple times.
  --ignore-regex IGNORE_REGEX
                        Any item matching this Python regex will be ignored.
                        Can be specified multiple times. Example:
                        `(?i)linuxfabrik` for a case-insensitive match. The
                        log line is lowercased before matching, so write the
                        pattern in lowercase (or use the `(?i)` flag).
  --port PORT           MySQL/MariaDB port number. Default: 3306
  --server-log SERVER_LOG
                        Log source to read from. Accepts a file path,
                        `docker:CONTAINER`, `podman:CONTAINER`,
                        `kubectl:CONTAINER` or `systemd:UNITNAME`. If omitted,
                        the check first probes `performance_schema.error_log`
                        (MySQL 8.0.22+) and then falls back to the file from
                        `log_error`.
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
```


## Usage Examples

```bash
./mysql-logfile --defaults-file=/var/spool/icinga2/.my.cnf --server-log=systemd:mariadb
./mysql-logfile --ignore-pattern='aborted connection' --ignore-pattern='access denied'
./mysql-logfile --server-log=docker:mariadb

# Silence only the harmless idle-connection timeout (server closes an idle connection
# after wait_timeout, the client's pool reconnects). Real connection errors like
# "got an error reading communication packets" stay visible.
./mysql-logfile --ignore-regex='aborted connection.*got timeout reading communication packets'
```

Output:

```text
Source: `/var/log/mariadb/mariadb.log` (size: 5.8KiB < 32.0MiB). 2 errors found [CRITICAL] (last: 220503 11:21:43 [ERROR] Aborting). 1 warning found [WARNING] (last: 220502 14:59:58 [Warning] Plugin 'FEEDBACK' is disabled.). 2 startups detected (last: 220503 11:24:54). 4 shutdowns detected (last: 220503 11:21:48).

Errors:
* 220503 11:21:43 [ERROR] /usr/libexec/mysqld: unknown variable 'myvar2=myvalue2'
* 220503 11:21:43 [ERROR] Aborting

Warnings:
* 220502 14:59:58 [Warning] Plugin 'FEEDBACK' is disabled.

Startups:
* 220503 11:07:38 [Note] /usr/libexec/mysqld: ready for connections.
* 220503 11:24:54 [Note] /usr/libexec/mysqld: ready for connections.

Shutdowns:
* 220503 11:07:07 [Note] /usr/libexec/mysqld: Shutdown complete
* 220503 11:07:12 [Note] /usr/libexec/mysqld: Shutdown complete
* 220503 11:21:42 [Note] /usr/libexec/mysqld: Shutdown complete
* 220503 11:21:48 [Note] /usr/libexec/mysqld: Shutdown complete

Recommendations:
* Check the errors in `/var/log/mariadb/mariadb.log`
* Check the warning in `/var/log/mariadb/mariadb.log`
```


## States

* CRIT if the log contains `[ERROR]`-tagged lines.
* WARN if the log contains `[Warning]`-tagged lines.
* WARN if a log file is configured but does not exist.
* WARN if an on-disk log file is `>= 32 MiB` (mysqltuner's cutoff; treat as a hint to set up log rotation).
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

### No log file found

`No log file set (set log_error in MySQL/MariaDB config or use the check's --server-log parameter).`

The check tried to get information from an error logfile, but was unable to do so. All possible error logfile locations were tried, but no logfile was found. You have to help by configuring the MySQL/MariaDB system variable `log_error` accordingly, or by providing the `--server-log` parameter to the check.

### `proxies_priv` entry ignored in `--skip-name-resolve` mode

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
