# Check mysql-innodb-log-waits


## Overview

Checks two related InnoDB log buffer health metrics in MySQL/MariaDB:

1. **Log waits** (`Innodb_log_waits` / `Innodb_log_writes`) - how often InnoDB had to wait for log writes to be flushed because the log buffer was full. Anything above 0% indicates that `innodb_log_buffer_size` is too small for the write workload.
2. **Write log efficiency** (`(Innodb_log_write_requests - Innodb_log_writes) / Innodb_log_write_requests * 100`) - how many log write requests were absorbed by the buffer without needing a physical disk write. Below 90% indicates `innodb_log_buffer_size` is too small for the write workload.

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-mysql/)
* If the InnoDB engine is not available or is disabled, the plugin reports OK with an info message instead of UNKNOWN
* The Write Log efficiency check is silently skipped on MySQL versions that do not expose `Innodb_log_write_requests` (very old MySQL pre-5.0)
* When `Innodb_log_writes > Innodb_log_write_requests` (a physically impossible state that can briefly appear during counter resets), the plugin emits an info note instead of alerting

**Data Collection:**

* Queries `SHOW GLOBAL VARIABLES` for `innodb_log_buffer_size`
* Queries `SHOW GLOBAL STATUS` for `Innodb_log_waits`, `Innodb_log_writes` and `Innodb_log_write_requests`
* Logic is taken from [MySQLTuner](https://github.com/major/MySQLTuner-perl):mysql_innodb() (sections "InnoDB Log Waits" and "InnoDB Write Log efficiency") and has been verified in sync with MySQLTuner


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-innodb-log-waits> |
| Nagios/Icinga Check Name              | `check_mysql_innodb_log_waits` |
| Check Interval Recommendation         | Every hour |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: mysql-innodb-log-waits [-h] [-V] [--always-ok]
                              [--defaults-file DEFAULTS_FILE]
                              [--defaults-group DEFAULTS_GROUP]
                              [--timeout TIMEOUT]

Checks two related InnoDB log buffer metrics in MySQL/MariaDB: 1. **Log
waits** (`Innodb_log_waits` / `Innodb_log_writes`) - how often InnoDB had to
wait for log writes to be flushed because the log buffer was full. Anything
above 0% indicates that `innodb_log_buffer_size` is too small for the write
workload. 2. **Write log efficiency** ((`Innodb_log_write_requests` -
`Innodb_log_writes`) / `Innodb_log_write_requests` * 100) - how many log write
requests were absorbed by the buffer without needing a physical disk write.
Below 90% indicates `innodb_log_buffer_size` is too small for the write
workload. Alerts on either condition.

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
InnoDB log waits: 0.0% (0.0 waits / 867.6K writes).

InnoDB Write Log efficiency: 95.6% (12.5M log buffer hits / 13.1M total).
```

When the buffer is undersized:

```text
InnoDB log waits: 0.05% (450.0 waits / 867.6K writes) [WARNING]. Set `innodb_log_buffer_size` > 16.0MiB.

InnoDB Write Log efficiency: 82.3% (5.2M log buffer hits / 6.3M total) [WARNING]. Set `innodb_log_buffer_size` > 16.0MiB.
```


## States

* WARN if `Innodb_log_waits > 0` (any wait at all means the buffer was too small at some point).
* WARN if InnoDB Write Log efficiency is below 90%.
* OK if the InnoDB engine is not available or is disabled.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mysql_innodb_log_buffer_size | Bytes | `innodb_log_buffer_size` - size of the buffer for writing InnoDB redo log files to disk. Larger values let bigger transactions run without disk I/O before commit. |
| mysql_innodb_log_waits_per_second | Number | Per-second rate of `Innodb_log_waits`. Only emitted from the second run onwards (the plugin keeps a small SQLite cache between runs to compute the delta in-plugin instead of using a continuous counter). |
| mysql_innodb_log_writes_per_second | Number | Per-second rate of `Innodb_log_writes`. Only emitted from the second run onwards. |
| mysql_innodb_log_write_requests_per_second | Number | Per-second rate of `Innodb_log_write_requests`. Only emitted from the second run onwards and only when the server exposes the underlying status variable. |
| mysql_innodb_log_waits_pct | Percentage | `Innodb_log_waits / Innodb_log_writes * 100` (lifetime ratio). |
| mysql_innodb_write_log_efficiency_pct | Percentage | `(Innodb_log_write_requests - Innodb_log_writes) / Innodb_log_write_requests * 100`. Only emitted when the server exposes `Innodb_log_write_requests` and the metrics are reliable. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:
    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
