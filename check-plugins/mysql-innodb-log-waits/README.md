# Check mysql-innodb-log-waits


## Overview

Checks InnoDB redo log buffer health in MySQL/MariaDB:

1. **Log waits** (`Innodb_log_waits` / `Innodb_log_writes`) - how often InnoDB had to wait because the in-memory log buffer was full before its contents could be flushed to disk. Per the MariaDB InnoDB source this counter is the authoritative signal for an undersized log buffer ("Number of log waits due to small log buffer"). Anything above 0 means `innodb_log_buffer_size` was too small for the write workload at some point. This is the only metric the plugin alerts on.
2. **Write log efficiency** (`(Innodb_log_write_requests - Innodb_log_writes) / Innodb_log_write_requests * 100`) - the share of in-memory log appends that were batched into a shared physical write. This ratio is governed by group commit and `innodb_flush_log_at_trx_commit`, not by buffer size, so the plugin reports it for trending only. It never alerts and never recommends resizing the buffer.

**Deliberate deviation from MySQLTuner:**

The check logic is derived from MySQLTuner, which alerts and recommends increasing `innodb_log_buffer_size` whenever write log efficiency drops below 90%. The MariaDB InnoDB source does not support that link: only `Innodb_log_waits` reflects a too-small buffer, while the write efficiency ratio reflects commit/flush batching. This plugin therefore treats write log efficiency as informational only and alerts solely on log waits.

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-mysql/)
* If the InnoDB engine is not available or is disabled, the plugin reports OK with an info message instead of UNKNOWN
* The Write Log efficiency line is silently skipped on MySQL versions that do not expose `Innodb_log_write_requests` (very old MySQL pre-5.0)
* When `Innodb_log_writes > Innodb_log_write_requests` (a physically impossible state that can briefly appear during counter resets), the plugin emits an info note instead of a value

**Data Collection:**

* Queries `SHOW GLOBAL VARIABLES` for `innodb_log_buffer_size`
* Queries `SHOW GLOBAL STATUS` for `Innodb_log_waits`, `Innodb_log_writes` and `Innodb_log_write_requests`
* Logic is derived from [MySQLTuner](https://github.com/major/MySQLTuner-perl):mysql_innodb() (sections "InnoDB Log Waits" and "InnoDB Write Log efficiency"), with the deliberate deviation on write log efficiency described above


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

Checks InnoDB redo log buffer health in MySQL/MariaDB. Primary check - **Log
waits** (`Innodb_log_waits` / `Innodb_log_writes`): how often InnoDB had to
wait because the in-memory log buffer was full before its contents could be
flushed to disk. Per the MariaDB InnoDB source this counter is the
authoritative signal for an undersized log buffer ("Number of log waits due to
small log buffer"). Any value above 0 means `innodb_log_buffer_size` was too
small for the write workload at some point, so the plugin alerts and
recommends a larger buffer. Secondary informational metric - **Write log
efficiency** ((`Innodb_log_write_requests` - `Innodb_log_writes`) /
`Innodb_log_write_requests` * 100): the share of in-memory log appends that
were batched into a shared physical write. This ratio is governed by group
commit and `innodb_flush_log_at_trx_commit`, not by buffer size, so the plugin
reports it for trending but never alerts on it and never recommends resizing
the buffer based on it. Deliberate deviation from MySQLTuner: MySQLTuner
alerts and recommends increasing `innodb_log_buffer_size` whenever write log
efficiency drops below 90%. The MariaDB InnoDB source does not support that
link, so this plugin treats write log efficiency as informational only and
alerts solely on log waits.

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

InnoDB Write Log efficiency: 95.6% (12.5M batched / 13.1M log write requests).
```

When the buffer is undersized (only log waits trigger a WARNING; write log efficiency stays informational):

```text
InnoDB log waits: 0.05% (450.0 waits / 867.6K writes) [WARNING].

InnoDB Write Log efficiency: 82.3% (5.2M batched / 6.3M log write requests).

Recommendations:
* Set `innodb_log_buffer_size` > 16.0MiB
```


## States

* WARN if `Innodb_log_waits > 0` (any wait at all means the buffer was too small at some point).
* OK if the InnoDB engine is not available or is disabled.
* Write Log efficiency is informational only and never changes the state.
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
