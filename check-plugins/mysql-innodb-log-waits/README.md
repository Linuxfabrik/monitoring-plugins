# Check mysql-innodb-log-waits

## Overview

Checks how often InnoDB had to wait for log writes to be flushed because the log buffer was too small in MySQL/MariaDB. If waits occur, the `innodb_log_buffer_size` should be increased.

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-MYSQL.md)



**Data Collection:**

* Queries `SHOW GLOBAL VARIABLES` for `innodb_log_buffer_size`
* Queries `SHOW GLOBAL STATUS` for `Innodb_log_waits` and `Innodb_log_writes`
* Logic is taken from [MySQLTuner script](https://github.com/major/MySQLTuner-perl):mysql_innodb(), v1.8.3

**Compatibility:**

* Cross-platform



## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-innodb-log-waits> |
| Nagios/Icinga Check Name              | `check_mysql_innodb_log_waits` |
| Check Interval Recommendation         | Once an hour |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: mysql-innodb-log-waits [-h] [-V] [--always-ok]
                              [--defaults-file DEFAULTS_FILE]
                              [--defaults-group DEFAULTS_GROUP]
                              [--timeout TIMEOUT]

Checks how often InnoDB had to wait for log writes to be flushed because the
log buffer was too small in MySQL/MariaDB. Frequent waits indicate that
innodb_log_buffer_size should be increased. Alerts when log waits occur too
frequently.

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
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
```


## Usage Examples

```bash
./mysql-innodb-log-waits --defaults-file=/var/spool/icinga2/.my.cnf
```

Output:

```text
0.0 InnoDB log buffer waits / 867.6K writes.
```


## States

* WARN if `Innodb_log_waits` > 0.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mysql_innodb_log_buffer_size | Bytes | Size in bytes of the buffer for writing InnoDB redo log files to disk. Increasing this means larger transactions can run without needing to perform disk I/O before committing. |
| mysql_innodb_log_waits | Continous Counter | Number of times InnoDB was forced to wait for log writes to be flushed due to the log buffer being too small. |
| mysql_innodb_log_writes | Continous Counter | Number of writes to the InnoDB redo log. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:
    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
