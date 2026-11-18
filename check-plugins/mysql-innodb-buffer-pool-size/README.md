# Check mysql-innodb-buffer-pool-size


## Overview

Checks the InnoDB buffer pool and redo log sizing in MySQL/MariaDB. For the buffer pool it measures how many of the pages InnoDB requested since the last check had to be read from disk, which is what tells a buffer pool that is too small for its working set from one that is merely smaller than the database. It also reports how much of the pool is in use and warns if sessions found no free page in it. For the redo log it reports how far the checkpoint has run into it, which is what tells a redo log that is too small for its workload from one that is merely small. The knob that sizes the redo log on this server is `innodb_redo_log_capacity` on MySQL 8.0.30+, `innodb_log_file_size` (times `innodb_log_files_in_group`, where that variable still exists) on MariaDB and older MySQL.

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-mysql/)
* Always take care of both `innodb_buffer_pool_size` and `innodb_redo_log_capacity` (MySQL 8.0.30+) or `innodb_log_file_size` (older MySQL, MariaDB) when making adjustments
* **The buffer pool is judged by its misses, not by the size of the database.** InnoDB does not need the whole database in memory. A page read from disk enters the "old" end of the LRU list and only moves to the "new" end if it is accessed again after `innodb_old_blocks_time`, so a one-off scan or a rarely read archive table ages out without evicting the pages that are in use. A buffer pool far smaller than the data is fine as long as the working set fits. The InnoDB data and index size is therefore reported for reference only
* Pages InnoDB prefetches by read-ahead (`Innodb_buffer_pool_read_ahead`, `Innodb_buffer_pool_read_ahead_rnd`) are not counted as misses. Fewer than 10 misses per second never raise a state, because a handful of reads on a lightly used server would otherwise produce a high ratio that no storage notices
* A full table scan through a buffer pool smaller than the table still misses about 10% of its pages, and more RAM does not help a scan until the whole table fits. This is why `--warning-miss-ratio` defaults to 20 and not to the 10 that mysqltuner uses for its lifetime read efficiency
* How much of the pool is in use says nothing about whether it is too large or too small, see "How to read the buffer pool numbers" below. It is reported for orientation and never raises a state
* Waits for a free page warn on any movement of the counter. What a count means depends on the server, see below; where bulk loads are allowed to run into waits, raise `--warning-waits`
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

* Queries `SHOW GLOBAL VARIABLES` for `innodb_buffer_pool_instances`, `innodb_buffer_pool_size`, `innodb_file_per_table`, `innodb_log_file_size`, `innodb_log_files_in_group`, `innodb_lru_scan_depth` and `innodb_redo_log_capacity`
* Queries `SHOW GLOBAL STATUS` for `Innodb_buffer_pool_bytes_data`, `Innodb_buffer_pool_pages_free`, `Innodb_buffer_pool_pages_total`, `Innodb_buffer_pool_read_ahead`, `Innodb_buffer_pool_read_ahead_rnd`, `Innodb_buffer_pool_read_requests`, `Innodb_buffer_pool_reads`, `Innodb_buffer_pool_wait_free`, `Innodb_checkpoint_age`, `Innodb_checkpoint_max_age`, `Innodb_os_log_written` and `Uptime`
* Queries `information_schema.tables` to sum all InnoDB data and index sizes
* Stores the buffer pool counters in a local SQLite database to compute their rates since the previous check, one baseline per `--defaults-file` and `--defaults-group`
* Reads the host's physical RAM via `sysconf(SC_PAGE_SIZE) * sysconf(SC_PHYS_PAGES)`, which is only used for the advice in the recommendations
* The architecture limits follow [MySQLTuner](https://github.com/major/MySQLTuner-perl):mysql_innodb(). The buffer pool and redo log checks do not: mysqltuner warns whenever the buffer pool is smaller than the data and sizes the redo log from a write rate against a RAM-tier floor, so the miss ratio and the checkpoint age the server itself publishes are used instead

**How to read the buffer pool numbers:**

* The buffer pool is InnoDB's cache for table and index pages (16 KiB each by default). A page a query needs is read from disk into the pool once and served from memory from then on. Changes are made to the page in the pool and written back to disk later.
* **The pool has to hold the pages the workload keeps using, not all the data.** Take a web shop with 100 GiB of data. Daily business touches the catalogue and the orders of the last few weeks, say 10 GiB. The orders of the past ten years are only read when someone looks one up. A 12 GiB pool serves that shop from memory, and a 100 GiB pool would not make it any faster.
* **"% in use" grows until the pool is full.** After a start the pool is almost empty and fills with every page that is read. As long as free pages remain, InnoDB evicts nothing, so the value shows what has been touched since the start, not what is needed. It can keep climbing for weeks as rarely used pages trickle in, and only drops when tables are dropped or truncated. A low value is no reason to shrink the pool and a rising one no reason to grow it.
* **After a restart the pool starts at about a quarter.** With `innodb_buffer_pool_dump_at_shutdown` and `innodb_buffer_pool_load_at_startup` (both `ON` by default) the server saves the list of its most recently used pages and reads them back in. `innodb_buffer_pool_dump_pct` (default 25) sets how many: 25% of the configured pool size on MariaDB, 25% of the pages in use on MySQL.
* **A full pool is the normal state of a server that has been up for a while.** InnoDB keeps a small reserve of free pages (`innodb_lru_scan_depth`: 1536 pages on MariaDB, 1024 per buffer pool instance on MySQL) and evicts the least recently used pages to refill it. The plugin calls the pool "full" once the free pages are down to that reserve. On a small pool the reserve is a visible share: a 64 MiB pool on MariaDB reads "full, 65.8% in use" and a 1 GiB pool on MySQL with 8 instances "full, 86.5% in use", while on a 50 GiB pool the reserve is 0.05% and the value ends up at 100. A pool smaller than about twice the reserve (48 MiB on MariaDB) settles anywhere below that and is not reliably recognised as full.
* **A miss ratio on a pool that is not full yet is the pool warming up.** The pages are read for the first time, not read back after an eviction, and a larger pool would not have avoided those reads.
* **"Sessions found no free page" means the reserve was used up.** A session needed a page and InnoDB had to write changed pages to disk first. It takes sessions that change pages faster than InnoDB frees them: a pool that is merely too small for its reads does not cause this on either server. What one count costs differs. MariaDB from 10.6.18, 10.11.8 and 11.4.2 counts a session that stood still for up to a second, and writes `InnoDB: Could not free any blocks in the buffer pool!` to the error log once a wait has lasted that full second. Older MariaDB releases and MySQL count every retry, of which the first ones cost no time, so their numbers are much higher for the same situation and move during a bulk load that nobody notices.
* **The pool takes its RAM as it fills.** A MariaDB started with a 2 GiB pool used 117 MiB of RAM, and 752 MiB once the pool held 594 MiB of data. A server with an oversized pool therefore runs fine for weeks and gets into memory pressure once the pool has filled up, without anyone having changed the configuration.
* **"InnoDB data + index size" is for orientation.** It is the upper end of what a larger pool can gain. It is an estimate from the table statistics and leaves out undo logs, the system tablespace and free space inside the data files. For compressed tables it is the compressed size, while the pool holds the pages uncompressed.

**Sizing the buffer pool:**

1. The upper limit is the RAM. Run [mysql-memory](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-memory/): the pool, the other buffers and the connections together have to stay clear of the physical memory, with room for the operating system and for other processes.
2. Not full yet: wait until the pool is full before drawing conclusions.
3. Full, low miss ratio, no waits: the pool is big enough. If `mysql-memory` complains, it can shrink; lower it in steps and watch the miss ratio.
4. Full and a miss ratio that stays high during normal work, or waits: raise it as far as the RAM allows. If the RAM does not allow it, the host needs more memory or the queries need to read less.

MariaDB 10.2.2+ and MySQL 5.7+ resize the pool while the server runs (`SET GLOBAL innodb_buffer_pool_size = ...`). MariaDB 10.11.12 to 10.11.16, 11.4.6 to 11.4.10 and 11.8.2 to 11.8.6 cannot grow it beyond its size at startup that way, unless `innodb_buffer_pool_size_max` is set in the configuration. The value also has to go into the configuration file, or the next restart brings back the old one.


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
                                     [--warning-waits WARN_WAITS]

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
limits. Also reports how much of the buffer pool is in use; a pool that is not
full yet is still filling up after a restart, and a low value is no reason to
shrink it. Alerts if the buffer pool miss ratio exceeds its threshold, if
sessions found no free page in the buffer pool more often than
`--warning-waits` allows (default: at all), or if the checkpoint runs closer
to the end of the redo log than the thresholds allow. The redo log size
mysqltuner would recommend for the host's RAM is reported as advice without
raising a state, because it is a floor for the RAM tier rather than a
measurement of this server. On freshly booted servers (less than one hour of
uptime) the write-rate comparison is deferred, because the rate is an average
since startup and not yet meaningful.

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
  --warning-waits WARN_WAITS
                        WARN threshold for the times per second a session
                        found no free page in the buffer pool. Raise it where
                        bulk loads are allowed to run into this. Supports
                        Nagios ranges. Example: `--warning-waits=5`. Default:
                        0

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

`innodb_buffer_pool_size` (128.0MiB, 24.1% in use), InnoDB data + index size (25.9MiB).

The redo log (innodb_log_file_size, 32.0MiB) is 0.2% through its checkpoint age (40.2KiB of 25.2MiB).

Recommendations:
* For reference, mysqltuner would size `innodb_log_file_size` at 100.0MiB or more on a host with 1.9GiB of RAM. That is a floor for the RAM tier, not a measurement of this workload
```

Output on a server whose buffer pool is ten times smaller than the data, serving a hot set that fits into it:

```text
Buffer pool miss ratio: 0.1% since the last check (305 of 303.1K page requests/s read from disk).

`innodb_buffer_pool_size` (64.0MiB, full, 65.8% in use), InnoDB data + index size (808.6MiB).

The redo log (innodb_log_file_size, 96.0MiB) is 0.0% through its checkpoint age (25.0B of 77.1MiB).
```

Output on the same server under random lookups across all of its data, and with a redo log that cannot keep up with what is being written to it:

```text
Buffer pool miss ratio: 32.8% since the last check (5.5K of 16.8K page requests/s read from disk) [WARNING].

`innodb_buffer_pool_size` (64.0MiB, full, 65.8% in use), InnoDB data + index size (808.6MiB).

The redo log (innodb_log_file_size, 4.0MiB) is 100.1% through its checkpoint age (2.6MiB of 2.6MiB) [CRITICAL].

Recommendations:
* Raise `innodb_buffer_pool_size` above 64.0MiB until the miss ratio stays below 20% under load, leaving enough of the host's 3.8GiB of RAM for the operating system and the other server buffers. The working set does not fit into the buffer pool, so InnoDB keeps reading pages back from disk that it had to evict
* Raise `innodb_log_file_size`: the checkpoint is running this close to the end of the redo log, so InnoDB is flushing pages ahead to keep up and stalls every write once it arrives. Tradeoff: a larger redo log means longer crash recovery
```

Output on MySQL, which publishes no checkpoint age, so the redo log is judged by how long it holds at the average write rate since startup:

```text
Buffer pool miss ratio: 0.4% since the last check (12.3 of 3.1K page requests/s read from disk).

`innodb_buffer_pool_size` (4.0GiB, 41.7% in use), InnoDB data + index size (2.5GiB).

The redo log (innodb_redo_log_capacity, 1.0GiB) holds 2h 41m of redo at the average write rate since startup (380.0MiB/h).
```


## States

* WARN on 32-bit hosts when `innodb_buffer_pool_size > 4 GiB`.
* WARN on 64-bit hosts when `innodb_buffer_pool_size > 16 EiB` (the theoretical 64-bit address space ceiling).
* WARN if `innodb_file_per_table` is not `ON`.
* WARN if at or more than `--warning-miss-ratio` percent (default: 20) of the pages InnoDB requested since the last check had to be read from disk, not counting read-ahead. Only evaluated from 10 misses per second.
* OK with "waiting for more data" on the first run after installation and after a server restart, since the miss ratio needs two runs to compare.
* OK with "not measurable" if more pages were read from disk than requested since the last check, which happens on MariaDB 11.4.9+ while long transactions are running.
* WARN if sessions found no free page in the buffer pool more often per second than `--warning-waits` allows (default: 0, so on any movement of `Innodb_buffer_pool_wait_free` since the last check).
* The InnoDB data + index size and the usage of the buffer pool never raise a state.
* WARN if the checkpoint has run at or past `--warning` percent (default: 87.5) of `Innodb_checkpoint_max_age`, which is where InnoDB starts flushing pages ahead to keep the checkpoint moving.
* CRIT if it has run at or past `--critical` percent (default: 99). From 100 InnoDB puts a synchronous wait into every write operation, and a redo log that is too small sits pinned at 100.0 to 100.1 for as long as the load runs, which is why the threshold is 99 and not 100.
* WARN on a server that publishes no checkpoint age (MySQL) if the average redo write rate since startup is at least as large as the redo log, meaning the workload writes through the whole log within an hour.
* The redo log size mysqltuner would recommend for the host's RAM never raises a state. It is a floor for the RAM tier rather than a measurement of this server: below 2 GiB of RAM it targets 100 MiB whatever the database does.
* OK if the InnoDB engine is not available or is disabled.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mysql_innodb_buffer_pool_bytes_data | Bytes | `Innodb_buffer_pool_bytes_data`: the bytes of table and index data the buffer pool holds, with `innodb_buffer_pool_size` as its maximum. While the pool is not full, this is what has been touched since the server started. |
| mysql_innodb_buffer_pool_miss_ratio | Percentage | Share of the page requests since the last check that had to be read from disk, not counting read-ahead. Absent when the interval is not measurable. |
| mysql_innodb_buffer_pool_misses_per_second | Number | Pages read from disk per second because they were not in the buffer pool, not counting read-ahead. |
| mysql_innodb_buffer_pool_pct_used | Percentage | Share of the buffer pool pages that are not free: `(Innodb_buffer_pool_pages_total - Innodb_buffer_pool_pages_free) / Innodb_buffer_pool_pages_total`. Does not reach 100 on a small pool, because InnoDB keeps `innodb_lru_scan_depth` pages free. |
| mysql_innodb_buffer_pool_read_requests_per_second | Number | Pages requested from the buffer pool per second. |
| mysql_innodb_buffer_pool_size | Bytes | `innodb_buffer_pool_size` in bytes. The value that decides most about the performance and the memory use of a server with InnoDB tables. |
| mysql_innodb_buffer_pool_wait_free_per_second | Number | Times per second a session found no free page in the buffer pool since the last check (`Innodb_buffer_pool_wait_free`). |
| mysql_innodb_checkpoint_age | Bytes | How far the checkpoint has run into the redo log, with `Innodb_checkpoint_max_age` as its maximum. Only emitted on a server that publishes both, which is MariaDB. |
| mysql_innodb_checkpoint_age_percent | Percentage | The same as a share of `Innodb_checkpoint_max_age`. This is the series that says whether the redo log is big enough for what the server does; the configured sizes cannot say that on their own. |
| mysql_innodb_data_size | Bytes | Sum of `DATA_LENGTH + INDEX_LENGTH` across all InnoDB tables in non-system schemas. For reference only. |
| mysql_innodb_log_file_size | Bytes | Size of each InnoDB redo log file. Emitted on MariaDB and MySQL < 9.3.0; absent on MySQL >= 9.3.0, where `innodb_log_file_size` was removed in favour of `innodb_redo_log_capacity`. |
| mysql_innodb_os_log_written_per_hour | Bytes | Hourly InnoDB redo log write rate, derived as `Innodb_os_log_written / (Uptime / 3600)`. Only emitted with at least 1 hour of uptime. |
| mysql_innodb_redo_log_capacity | Bytes | Configured `innodb_redo_log_capacity` (MySQL 8.0.30+ only). |
| mysql_innodb_redo_log_capacity_recommended | Bytes | The redo log size mysqltuner would recommend, derived from the hourly write rate and rounded into the host's RAM tier. Reported for reference only and never used for alerting. Only emitted with at least 1 hour of uptime. |


## Troubleshooting

### Sessions found no free page in the buffer pool

`Sessions found no free page in the buffer pool 1.35 times/s since the last check [WARNING].`

1. Check the error log for `InnoDB: Could not free any blocks in the buffer pool!` (MariaDB from 10.6.18, 10.11.8 and 11.4.2) or `Difficult to find free blocks in the buffer pool` (MySQL, older MariaDB). Where present, they carry the time of the stall, but the server does not log every wait.
2. Find out what was writing at that time: a bulk import, a large `UPDATE` or `DELETE`, an `ALTER TABLE`. Waits during such a job are the job's price and often acceptable; loading 75 MiB of rows into a 64 MiB pool is enough to cause them on MySQL. Raise `--warning-waits` above what the job causes, or accept the warning while it runs.
3. If it happens under the normal load and the RAM allows it according to `mysql-memory`, raise `innodb_buffer_pool_size`. With 24 sessions updating rows on MariaDB, a 64 MiB pool came to 107 to 217 waits in 40 seconds, a 256 MiB pool to none.

### The pool is far from full

Nothing to fix. The pool fills over days to weeks after a restart, see "How to read the buffer pool numbers" above. If the host is short on memory in the meantime, the pool can be lowered to a size `mysql-memory` is happy with; it will fill up and stay full, which is how it is meant to work.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:
    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
