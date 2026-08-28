# Check mysql-innodb-log-waits


## Overview

Checks InnoDB redo log health in MySQL/MariaDB:

1. **Redo log pressure** - how far the redo log has filled up since the last checkpoint, in percent of the point at which InnoDB switches to synchronous flushing. From that point on InnoDB holds writing sessions back until the flush has caught up, so an undersized redo log turns into slow writes exactly when the server is busiest. A single reading above the threshold can be a bulk import; the same reading over consecutive checks means the redo log is too small for the workload.
2. **Log waits** (`Innodb_log_waits` / `Innodb_log_writes`) - how often InnoDB had to wait because the in-memory log buffer was full before its contents could be flushed to disk. Per the MariaDB InnoDB source this counter is the authoritative signal for an undersized log buffer ("Number of log waits due to small log buffer"). Anything above 0 means `innodb_log_buffer_size` was too small for the write workload at some point.
3. **Write log efficiency** (`(Innodb_log_write_requests - Innodb_log_writes) / Innodb_log_write_requests * 100`) - the share of in-memory log appends that were batched into a shared physical write. This ratio is governed by group commit and `innodb_flush_log_at_trx_commit`, not by buffer size, so the plugin reports it for trending only. It never alerts and never recommends resizing the buffer.

**What to do about a redo log pressure alert:**

* Raise the redo log: `innodb_log_file_size` on MariaDB, `innodb_redo_log_capacity` on MySQL 8.0.30 and newer. Raise it until the reading stays below the warning threshold under production load, and persist the value in the server configuration
* MariaDB 10.9 and newer, and MySQL 8.0.30 and newer, resize the redo log while the server runs (`SET GLOBAL`); older MariaDB releases need a restart
* A common target is a redo log that holds about one hour of writes. `mysql-innodb-buffer-pool-size` reports that target size for the current workload
* The price of a larger redo log is a longer crash recovery and more disk space, which is why the shipped default is small on some setups

**Deliberate deviation from MySQLTuner:**

The check logic is derived from MySQLTuner, which alerts and recommends increasing `innodb_log_buffer_size` whenever write log efficiency drops below 90%. The MariaDB InnoDB source does not support that link: only `Innodb_log_waits` reflects a too-small buffer, while the write efficiency ratio reflects commit/flush batching. This plugin therefore treats write log efficiency as informational only and alerts solely on log waits. MySQLTuner does not look at redo log pressure at all.

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-mysql/)
* If the InnoDB engine is not available or is disabled, the plugin reports OK with an info message instead of UNKNOWN
* Redo log pressure is a gauge, so it is worth combining with the retry settings of the monitoring server: a bulk import can push a healthy server past the threshold for a single check
* Redo log pressure is skipped on MySQL before 8.0.30, which reports neither the fill level nor the limit
* The Write Log efficiency line is silently skipped on MySQL versions that do not expose `Innodb_log_write_requests` (very old MySQL pre-5.0)
* When `Innodb_log_writes > Innodb_log_write_requests` (a physically impossible state that can briefly appear during counter resets), the plugin emits an info note instead of a value

**Data Collection:**

* Queries `SHOW GLOBAL VARIABLES` for `innodb_log_buffer_size`, `innodb_log_file_size`, `innodb_page_size` and `innodb_redo_log_capacity`
* Queries `SHOW GLOBAL STATUS` for `Innodb_checkpoint_age`, `Innodb_checkpoint_max_age`, `Innodb_log_waits`, `Innodb_log_writes`, `Innodb_log_write_requests` and `Innodb_redo_log_logical_size`
* MariaDB publishes both the fill level and the limit (`Innodb_checkpoint_age` / `Innodb_checkpoint_max_age`). MySQL 8.0.30+ publishes the fill level only (`Innodb_redo_log_logical_size`), so the plugin derives the limit from `innodb_redo_log_capacity` the same way InnoDB does internally
* The log waits and write log efficiency logic is derived from [MySQLTuner](https://github.com/major/MySQLTuner-perl):mysql_innodb() (sections "InnoDB Log Waits" and "InnoDB Write Log efficiency"), with the deliberate deviation described above. The redo log pressure check has no MySQLTuner counterpart and is derived from the MariaDB and MySQL InnoDB sources


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-innodb-log-waits> |
| Nagios/Icinga Check Name              | `check_mysql_innodb_log_waits` |
| Check Interval Recommendation         | Every hour |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| 3rd Party Python modules              | `pymysql` |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-mysql-innodb-log-waits.db` |


## Help

```text
usage: mysql-innodb-log-waits [-h] [-V] [--always-ok] [--critical CRIT]
                              [--defaults-file DEFAULTS_FILE]
                              [--defaults-group DEFAULTS_GROUP]
                              [--no-perfdata] [--timeout TIMEOUT]
                              [--warning WARN]

Checks InnoDB redo log health in MySQL/MariaDB. Check 1 - **Redo log
pressure**: how far the redo log has filled up since the last checkpoint,
expressed as a percentage of the point at which InnoDB starts to flush
synchronously. From that point on, writing sessions are held back until the
flush catches up, which is exactly what an undersized redo log looks like on a
busy server: the database is slow while the application is busiest. A short
spike during a bulk import is normal, sustained pressure is not, so the plugin
alerts and recommends a larger redo log. Check 2 - **Log waits**
(`Innodb_log_waits` / `Innodb_log_writes`): how often InnoDB had to wait
because the in-memory log buffer was full before its contents could be flushed
to disk. Per the MariaDB InnoDB source this counter is the authoritative
signal for an undersized log buffer ("Number of log waits due to small log
buffer"). Any value above 0 means `innodb_log_buffer_size` was too small for
the write workload at some point, so the plugin alerts and recommends a larger
buffer. Informational metric - **Write log efficiency**
((`Innodb_log_write_requests` - `Innodb_log_writes`) /
`Innodb_log_write_requests` * 100): the share of in-memory log appends that
were batched into a shared physical write. This ratio is governed by group
commit and `innodb_flush_log_at_trx_commit`, not by buffer size, so the plugin
reports it for trending but never alerts on it and never recommends resizing
the buffer based on it. Deliberate deviation from MySQLTuner: MySQLTuner
alerts and recommends increasing `innodb_log_buffer_size` whenever write log
efficiency drops below 90%. The MariaDB InnoDB source does not support that
link, so this plugin treats write log efficiency as informational only and
alerts solely on log waits. MySQLTuner does not look at redo log pressure at
all.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --critical CRIT       Threshold for redo log pressure, in percent of the
                        point where InnoDB starts to flush synchronously and
                        holds back writing sessions. Default: 100
  --defaults-file DEFAULTS_FILE
                        MySQL/MariaDB cnf file to read user, host and password
                        from (instead of specifying them on the command line).
                        Example: `/var/spool/icinga2/.my.cnf`. Default:
                        /var/spool/icinga2/.my.cnf
  --defaults-group DEFAULTS_GROUP
                        Group/section to read from in the cnf file. Default:
                        client
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  --warning WARN        Threshold for redo log pressure, in percent of the
                        point where InnoDB starts to flush synchronously and
                        holds back writing sessions. Default: 87.5

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-innodb-log-waits/
```


## Usage Examples

```bash
./mysql-innodb-log-waits --defaults-file=/var/spool/icinga2/.my.cnf
```

Output:

```text
InnoDB redo log pressure: 11.1% (8.5MiB of 77.1MiB written since the last checkpoint, `innodb_log_file_size` = 96.0MiB).

InnoDB log waits: 0.0% (0 waits / 867.6K writes).

InnoDB Write Log efficiency: 95.6% (12.5M batched / 13.1M log write requests).
```

When the redo log is too small for the write workload:

```text
InnoDB redo log pressure: 90.9% (22.9MiB of 25.2MiB written since the last checkpoint, `innodb_log_file_size` = 32.0MiB) [WARNING].

InnoDB log waits: 0.0% (0 waits / 867.6K writes).

InnoDB Write Log efficiency: 95.6% (12.5M batched / 13.1M log write requests).

Recommendations:
* Raise `innodb_log_file_size` above its current 32.0MiB until this stays below 87.5% under load, and persist the new value in the server configuration. A common target is a redo log that holds about one hour of writes. MariaDB 10.9 and newer apply a new size while the server runs (`SET GLOBAL innodb_log_file_size`), older releases need a restart. Tradeoff: a larger redo log means longer crash recovery and more disk space
```

When the log buffer is undersized (write log efficiency stays informational):

```text
InnoDB redo log pressure: 11.1% (8.5MiB of 77.1MiB written since the last checkpoint, `innodb_log_file_size` = 96.0MiB).

InnoDB log waits: 0.05% (450 waits / 867.6K writes) [WARNING].

InnoDB Write Log efficiency: 82.3% (5.2M batched / 6.3M log write requests).

Recommendations:
* Set `innodb_log_buffer_size` > 16.0MiB
```


## States

* WARN if redo log pressure reaches `--warning` (default 87.5%, the point at which InnoDB starts to flush ahead of the checkpoint).
* CRIT if redo log pressure reaches `--critical` (default 100%, the point at which InnoDB flushes synchronously and holds writing sessions back).
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
| mysql_innodb_redo_log_age | Bytes | How much redo the server has written since the last checkpoint. `Innodb_checkpoint_age` on MariaDB, `Innodb_redo_log_logical_size` on MySQL 8.0.30+. |
| mysql_innodb_redo_log_pressure_pct | Percentage | `mysql_innodb_redo_log_age` in percent of `mysql_innodb_redo_log_sync_flush_age`. Tops out slightly above 100% while InnoDB flushes synchronously. |
| mysql_innodb_redo_log_sync_flush_age | Bytes | The fill level at which InnoDB switches to synchronous flushing and holds writing sessions back. Follows the configured redo log size. |
| mysql_innodb_write_log_efficiency_pct | Percentage | `(Innodb_log_write_requests - Innodb_log_writes) / Innodb_log_write_requests * 100`. Only emitted when the server exposes `Innodb_log_write_requests` and the metrics are reliable. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:
    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
