# Check mysql-innodb-buffer-pool-size


## Overview

Checks the InnoDB buffer pool and redo log sizing in MySQL/MariaDB. For the buffer pool it measures how many of the pages InnoDB requested since the last check had to be read from disk, which is what tells a buffer pool that is too small for its working set from one that is merely smaller than the database. For the redo log it reports how far the checkpoint has run into it, which is what tells a redo log that is too small for its workload from one that is merely small. The knob that sizes the redo log on this server is `innodb_redo_log_capacity` on MySQL 8.0.30+, `innodb_log_file_size` (times `innodb_log_files_in_group`, where that variable still exists) on MariaDB and older MySQL.

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-mysql/)
* Always take care of both `innodb_buffer_pool_size` and `innodb_redo_log_capacity` (MySQL 8.0.30+) or `innodb_log_file_size` (older MySQL, MariaDB) when making adjustments
* **The buffer pool is judged by its misses, not by the size of the database.** InnoDB does not need the whole database in memory. A page read from disk enters the "old" end of the LRU list and only moves to the "new" end if it is accessed again after `innodb_old_blocks_time`, so a one-off scan or a rarely read archive table ages out without evicting the pages that are in use. A buffer pool far smaller than the data is fine as long as the working set fits. The InnoDB data and index size is therefore reported for reference only
* Pages InnoDB prefetches by read-ahead (`Innodb_buffer_pool_read_ahead`, `Innodb_buffer_pool_read_ahead_rnd`) are not counted as misses. Fewer than 10 misses per second never raise a state, because a handful of reads on a lightly used server would otherwise produce a high ratio that no storage notices
* A full table scan through a buffer pool smaller than the table still misses about 10% of its pages, and more RAM does not help a scan until the whole table fits. This is why `--warning-miss-ratio` defaults to 20 and not to the 10 that mysqltuner uses for its lifetime read efficiency
* The miss ratio covers the interval since the previous check, so the first run after installation and the first run after a server restart only record a baseline
* MariaDB 11.4.9 and newer only count the page requests of a transaction once it ends, while its disk reads count right away. While long transactions are running, the miss ratio of a single check can read too high, or cannot be computed at all when more pages were read from disk than requested. The plugin then reports the interval as not measurable instead of alerting
* If the InnoDB engine is not available or is disabled, the plugin reports OK with an info message instead of UNKNOWN
* On MariaDB 10.2.2+, `innodb_buffer_pool_size` [can be set dynamically.](https://mariadb.com/kb/en/setting-innodb-buffer-pool-size-dynamically/)
* **The redo log is judged by the checkpoint, not by a rule of thumb.** MariaDB publishes `Innodb_checkpoint_age` and `Innodb_checkpoint_max_age`; the latter is derived from the redo log size by InnoDB itself. A checkpoint age close to it is what "the redo log is too small for this workload" actually looks like. MySQL publishes neither, so there the average redo write rate since startup is compared against the redo log size instead, which needs at least 1 hour of uptime to mean anything and is deferred on freshly booted servers
* Under a sustained write load a redo log that is too small does not drift up through the thresholds. It jumps to the limit and stays pinned at 100.0 to 100.1 percent, because from `Innodb_checkpoint_max_age` on InnoDB puts a synchronous wait into every write operation and that is what holds it there. This is why `--critical` defaults to 99 rather than 100
* The redo log size mysqltuner would recommend for the host's RAM is reported as advice and never raises a state. It is a floor for the RAM tier: below 2 GiB of RAM it targets 100 MiB whatever the database does, so on an idle server it fires while the redo log is nowhere near full. mysqltuner itself never reaches that code on MariaDB, because it gates it on `mysql_version_ge(8, 0, 30)` and on `innodb_redo_log_capacity` being defined
* Whether writing sessions had to wait for the redo log *buffer* is a different question and a different knob (`innodb_log_buffer_size`); `mysql-innodb-log-waits` reports that one
* MariaDB 10.9 and newer, and MySQL 8.0.30 and newer, resize the redo log while the server runs (`SET GLOBAL`); older MariaDB releases need a restart. The price of a larger redo log is a longer crash recovery and more disk space
* User account requires access to INFORMATION_SCHEMA (user with no privileges is sufficient) and SELECT privileges on all schemas and tables to provide accurate results
* [For most INFORMATION_SCHEMA tables, each MySQL user has the right to access them, but can see only the rows in the tables that correspond to objects for which the user has the proper access privileges.](https://dev.mysql.com/doc/refman/5.7/en/information-schema-introduction.html#information-schema-privileges) [So you can't grant permission to INFORMATION_SCHEMA directly, you have to grant SELECT permission to the tables on your own schemas, and as you do, those tables will start showing up in INFORMATION_SCHEMA queries.](https://stackoverflow.com/questions/60499772/cannot-grant-mysql-user-access-to-information-schema-database)

**Data Collection:**

* Queries `SHOW GLOBAL VARIABLES` for `innodb_buffer_pool_size`, `innodb_file_per_table`, `innodb_log_file_size`, `innodb_log_files_in_group`, and `innodb_redo_log_capacity`
* Queries `SHOW GLOBAL STATUS` for `Innodb_buffer_pool_read_ahead`, `Innodb_buffer_pool_read_ahead_rnd`, `Innodb_buffer_pool_read_requests`, `Innodb_buffer_pool_reads`, `Innodb_buffer_pool_wait_free`, `Innodb_checkpoint_age`, `Innodb_checkpoint_max_age`, `Innodb_os_log_written` and `Uptime`
* Queries `information_schema.tables` to sum all InnoDB data and index sizes
* Stores the buffer pool counters in a local SQLite database to compute their rates since the previous check, one baseline per `--defaults-file` and `--defaults-group`
* Reads the host's physical RAM via `sysconf(SC_PAGE_SIZE) * sysconf(SC_PHYS_PAGES)`, which is only used for the advice in the recommendations
* The architecture limits follow [MySQLTuner](https://github.com/major/MySQLTuner-perl):mysql_innodb(). The buffer pool and redo log checks do not: mysqltuner warns whenever the buffer pool is smaller than the data and sizes the redo log from a write rate against a RAM-tier floor, so the miss ratio and the checkpoint age the server itself publishes are used instead


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-innodb-buffer-pool-size> |
| Nagios/Icinga Check Name              | `check_mysql_innodb_buffer_pool_size` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| Requirements                          | User with `SELECT` privilege (typically `GRANT SELECT ON *.*`), locked down to `127.0.0.1` - for example `monitoring@127.0.0.1`. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions. |
| 3rd Party Python modules              | `pymysql` |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-mysql-innodb-buffer-pool-size.db` |


## Help

```text
usage: mysql-innodb-buffer-pool-size [-h] [-V] [--always-ok] [-c CRIT]
                                     [--defaults-file DEFAULTS_FILE]
                                     [--defaults-group DEFAULTS_GROUP]
                                     [--no-perfdata] [--timeout TIMEOUT]
                                     [-w WARN]
                                     [--warning-miss-ratio WARN_MISS_RATIO]

Checks the InnoDB buffer pool and redo log sizing in MySQL/MariaDB. Measures
how many of the pages InnoDB requested since the last check had to be read
from disk because they were not in the buffer pool, and reports how far the
checkpoint has run through the redo log, which is what tells a redo log that
is too small for its workload from one that is merely small. The buffer pool
does not have to hold the whole database: InnoDB keeps the pages that are read
again and lets pages from a one-off scan age out first, so a pool far smaller
than the data is fine as long as the working set fits. The InnoDB data and
index size is therefore reported for reference only and never raises a state.
Pages InnoDB prefetches by read-ahead are not counted as misses, and fewer
than 10 misses per second are not worth an alert on any storage. On MariaDB
11.4.9 and newer the page requests of a transaction are only counted once it
ends, so while long transactions run, the miss ratio of a single check can
read too high, or cannot be computed at all when more pages were read than
requested. On a server that publishes `Innodb_checkpoint_age` and
`Innodb_checkpoint_max_age` those decide the state; on one that publishes
neither, the average redo write rate since startup is compared against the
redo log size instead, and a workload that writes through the whole log within
an hour is reported. The redo log knob is `innodb_redo_log_capacity` on MySQL
8.0.30+ and `innodb_log_file_size` (times `innodb_log_files_in_group`, where
that variable still exists) on MariaDB and older MySQL. Also flags
`innodb_file_per_table = OFF` and architecture-related buffer-pool size
limits. Alerts if the buffer pool miss ratio exceeds its threshold, or if the
checkpoint runs closer to the end of the redo log than the thresholds allow.
The redo log size mysqltuner would recommend for the host's RAM is reported as
advice without raising a state, because it is a floor for the RAM tier rather
than a measurement of this server. On freshly booted servers (less than one
hour of uptime) the write-rate comparison is deferred, because the rate is an
average since startup and not yet meaningful.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRIT   CRIT threshold for how far the checkpoint has run
                        through the redo log, in percent of
                        `Innodb_checkpoint_max_age`. From 100 InnoDB puts a
                        synchronous wait into every write operation, and a
                        redo log that is too small sits pinned there under
                        load. Only evaluated on a server that publishes its
                        checkpoint age. Supports Nagios ranges. Default: 99
  --defaults-file DEFAULTS_FILE
                        MySQL/MariaDB cnf file to read user, host and password
                        from. Example: `--defaults-
                        file=/var/spool/icinga2/.my.cnf`. Default:
                        /var/spool/icinga2/.my.cnf
  --defaults-group DEFAULTS_GROUP
                        Group/section to read from in the cnf file. Default:
                        client
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -w, --warning WARN    WARN threshold for how far the checkpoint has run
                        through the redo log, in percent of
                        `Innodb_checkpoint_max_age`. At 87.5 InnoDB starts
                        flushing pages ahead to keep the checkpoint moving.
                        Only evaluated on a server that publishes its
                        checkpoint age. Supports Nagios ranges. Default: 87.5
  --warning-miss-ratio WARN_MISS_RATIO
                        WARN threshold for the buffer pool miss ratio, in
                        percent of the pages InnoDB requested since the last
                        check that had to be read from disk. Pages prefetched
                        by read-ahead do not count as misses. Only evaluated
                        from 10 misses per second. Supports Nagios ranges.
                        Default: 20

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-innodb-buffer-pool-size/
```


## Usage Examples

```bash
./mysql-innodb-buffer-pool-size --defaults-file=/var/spool/icinga2/.my.cnf
```

Output on a server whose redo log is comfortably ahead of its workload:

```text
Buffer pool miss ratio: 0.0% since the last check (0 of 1.5K page requests/s read from disk).

`innodb_buffer_pool_size` (128.0MiB), InnoDB data + index size (25.9MiB).

The redo log (innodb_log_file_size, 32.0MiB) is 0.2% through its checkpoint age (40.2KiB of 25.2MiB).

Recommendations:
* For reference, mysqltuner would size `innodb_log_file_size` at 100.0MiB or more on a host with 1.9GiB of RAM. That is a floor for the RAM tier, not a measurement of this workload
```

Output on a server whose buffer pool is ten times smaller than the data, serving a hot set that fits into it:

```text
Buffer pool miss ratio: 0.1% since the last check (305 of 303.1K page requests/s read from disk).

`innodb_buffer_pool_size` (64.0MiB), InnoDB data + index size (808.6MiB).

The redo log (innodb_log_file_size, 96.0MiB) is 0.0% through its checkpoint age (25.0B of 77.1MiB).
```

Output on the same server under random lookups across all of its data, and with a redo log that cannot keep up with what is being written to it:

```text
Buffer pool miss ratio: 32.8% since the last check (5.5K of 16.8K page requests/s read from disk) [WARNING].

`innodb_buffer_pool_size` (64.0MiB), InnoDB data + index size (808.6MiB).

The redo log (innodb_log_file_size, 4.0MiB) is 100.1% through its checkpoint age (2.6MiB of 2.6MiB) [CRITICAL].

Recommendations:
* Raise `innodb_buffer_pool_size` above 64.0MiB until the miss ratio stays below 20% under load, leaving enough of the host's 3.8GiB of RAM for the operating system and the other server buffers. The working set does not fit into the buffer pool, so InnoDB keeps reading pages back from disk that it had to evict
* Raise `innodb_log_file_size`: the checkpoint is running this close to the end of the redo log, so InnoDB is flushing pages ahead to keep up and stalls every write once it arrives. Tradeoff: a larger redo log means longer crash recovery
```

Output on MySQL, which publishes no checkpoint age, so the redo log is judged by how long it holds at the average write rate since startup:

```text
Buffer pool miss ratio: 0.4% since the last check (12.3 of 3.1K page requests/s read from disk).

`innodb_buffer_pool_size` (4.0GiB), InnoDB data + index size (2.5GiB).

The redo log (innodb_redo_log_capacity, 1.0GiB) holds 2h 41m of redo at the average write rate since startup (380.0MiB/h).
```


## States

* WARN on 32-bit hosts when `innodb_buffer_pool_size > 4 GiB`.
* WARN on 64-bit hosts when `innodb_buffer_pool_size > 16 EiB` (the theoretical 64-bit address space ceiling).
* WARN if `innodb_file_per_table` is not `ON`.
* WARN if at or more than `--warning-miss-ratio` percent (default: 20) of the pages InnoDB requested since the last check had to be read from disk, not counting read-ahead. Only evaluated from 10 misses per second.
* OK with "waiting for more data" on the first run after installation and after a server restart, since the miss ratio needs two runs to compare.
* OK with "not measurable" if more pages were read from disk than requested since the last check, which happens on MariaDB 11.4.9+ while long transactions are running.
* The InnoDB data + index size never raises a state.
* WARN if the checkpoint has run at or past `--warning` percent (default: 87.5) of `Innodb_checkpoint_max_age`, which is where InnoDB starts flushing pages ahead to keep the checkpoint moving.
* CRIT if it has run at or past `--critical` percent (default: 99). From 100 InnoDB puts a synchronous wait into every write operation, and a redo log that is too small sits pinned at 100.0 to 100.1 for as long as the load runs, which is why the threshold is 99 and not 100.
* WARN on a server that publishes no checkpoint age (MySQL) if the average redo write rate since startup is at least as large as the redo log, meaning the workload writes through the whole log within an hour.
* The redo log size mysqltuner would recommend for the host's RAM never raises a state. It is a floor for the RAM tier rather than a measurement of this server: below 2 GiB of RAM it targets 100 MiB whatever the database does.
* OK if the InnoDB engine is not available or is disabled.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mysql_innodb_buffer_pool_miss_ratio | Percentage | Share of the page requests since the last check that had to be read from disk, not counting read-ahead. Absent when the interval is not measurable. |
| mysql_innodb_buffer_pool_misses_per_second | Number | Pages read from disk per second because they were not in the buffer pool, not counting read-ahead. |
| mysql_innodb_buffer_pool_read_requests_per_second | Number | Pages requested from the buffer pool per second. |
| mysql_innodb_buffer_pool_size | Bytes | `innodb_buffer_pool_size` in bytes. The primary value to adjust on a database server with entirely/primarily InnoDB tables, can be set up to 80% of the total memory. |
| mysql_innodb_buffer_pool_wait_free_per_second | Number | How often per second InnoDB had to wait for a free page in the buffer pool (`Innodb_buffer_pool_wait_free`). |
| mysql_innodb_checkpoint_age | Bytes | How far the checkpoint has run into the redo log, with `Innodb_checkpoint_max_age` as its maximum. Only emitted on a server that publishes both, which is MariaDB. |
| mysql_innodb_checkpoint_age_percent | Percentage | The same as a share of `Innodb_checkpoint_max_age`. This is the series that says whether the redo log is big enough for what the server does; the configured sizes cannot say that on their own. |
| mysql_innodb_data_size | Bytes | Sum of `DATA_LENGTH + INDEX_LENGTH` across all InnoDB tables in non-system schemas. For reference only. |
| mysql_innodb_log_file_size | Bytes | Size of each InnoDB redo log file. Emitted on MariaDB and MySQL < 9.3.0; absent on MySQL >= 9.3.0, where `innodb_log_file_size` was removed in favour of `innodb_redo_log_capacity`. |
| mysql_innodb_os_log_written_per_hour | Bytes | Hourly InnoDB redo log write rate, derived as `Innodb_os_log_written / (Uptime / 3600)`. Only emitted with at least 1 hour of uptime. |
| mysql_innodb_redo_log_capacity | Bytes | Configured `innodb_redo_log_capacity` (MySQL 8.0.30+ only). |
| mysql_innodb_redo_log_capacity_recommended | Bytes | The redo log size mysqltuner would recommend, derived from the hourly write rate and rounded into the host's RAM tier. Reported for reference only and never used for alerting. Only emitted with at least 1 hour of uptime. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:
    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
