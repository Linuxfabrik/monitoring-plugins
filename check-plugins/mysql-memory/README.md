# Check mysql-memory


## Overview

Measures the memory (RSS) of the MySQL/MariaDB server processes on the host and compares it to the physical RAM. Also calculates the worst case from the configured buffer sizes (server-wide buffers + per-connection buffers * `max_connections` + Performance Schema memory), in which every connection fills all its buffers at once. The server allocates none of these buffers in advance, a connection takes memory only while a query needs it, so the worst case is reported, but does not alert. Alerts when the measured memory crosses `--warning` / `--critical`, and when MySQL would allocate more than 2 GiB on a 32-bit system. Supports extended reporting via `--lengthy`.

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-mysql/)
* Must run locally on the MySQL/MariaDB server, since it measures the memory of the `mysqld` / `mariadbd` processes. Without such a process on the host, or when `/proc` is mounted with `hidepid` and hides it from the monitoring user, it returns UNKNOWN. Several server processes on one host are summed up
* The worst case assumes that every connection fills all its buffers and one in-memory temporary table at the same time. No server does that: a MEMORY temporary table, a sort buffer and a join buffer grow only as far as the query needs them. So the worst case may well exceed the RAM without any risk; it is reported and plotted, but does not alert. It shows which knob would weigh most if many connections did run large queries at once, usually `tmp_table_size` / `max_heap_table_size` times `max_connections`
* On MariaDB with `optimize_join_buffer_size=on` (the default since MariaDB 11.0), all join buffers of a query together are limited to `join_buffer_space_limit` (default 2 MiB), so a larger `join_buffer_size` has no effect there and is counted with `join_buffer_space_limit`. On older MariaDB versions and on MySQL every join buffer may reach `join_buffer_size`, and a query may use several
* `max_allowed_packet` is not counted: a connection's network buffer only grows to the largest packet the connection actually receives
* The Galera GCache is not counted: it is a memory-mapped file whose pages the kernel can write back and reclaim
* Reading the Performance Schema footprint needs the `PROCESS` privilege. Without it, the Performance Schema memory counts as 0

**Data Collection:**

* Uses `psutil` to sum up the RSS of the processes named `mysqld` / `mariadbd`, and of all other processes
* Uses `os.sysconf` for total physical memory
* Queries `SHOW GLOBAL VARIABLES` for the buffer sizes (`innodb_buffer_pool_size`, `key_buffer_size`, `sort_buffer_size`, `join_buffer_size`, `join_buffer_space_limit` and `optimizer_switch` on MariaDB, `binlog_cache_size` when `log_bin` is ON, `temptable_max_ram` on MySQL, `max_connections`, ...)
* Queries `SHOW GLOBAL STATUS` for `Max_used_connections`
* Queries `SHOW ENGINE PERFORMANCE_SCHEMA STATUS` for the `performance_schema.memory` row when `performance_schema` is ON
* The worst case is calculated like MySQLTuner's `calculations()`: per connection `read_buffer_size`, `read_rnd_buffer_size`, `sort_buffer_size`, `thread_stack`, `join_buffer_size`, `binlog_cache_size` and one in-memory temporary table of `min(tmp_table_size, max_heap_table_size)`. On MySQL with the TempTable engine, all temporary tables together are capped at `temptable_max_ram`. Unlike MySQLTuner, the worst case does not alert, and the join buffers follow `join_buffer_space_limit` on MariaDB


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-memory> |
| Nagios/Icinga Check Name              | `check_mysql_memory` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| 3rd Party Python modules              | `psutil`, `pymysql` |


## Help

```text
usage: mysql-memory [-h] [-V] [--always-ok] [-c CRITICAL]
                    [--defaults-file DEFAULTS_FILE]
                    [--defaults-group DEFAULTS_GROUP] [--lengthy]
                    [--no-perfdata] [--timeout TIMEOUT] [-w WARNING]

Measures the memory (RSS) of the MySQL/MariaDB server processes on the host
and compares it to the physical RAM. Also calculates the worst case from the
configured buffer sizes (server-wide buffers + per-connection buffers *
`max_connections` + Performance Schema memory), in which every connection
fills all its buffers at once. The server allocates none of these buffers in
advance, a connection takes memory only while a query needs it, so the worst
case is reported, but does not alert. Alerts when the measured memory crosses
`--warning` / `--critical`, and when MySQL would allocate more than 2 GiB on a
32-bit system. Supports extended reporting via --lengthy.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRITICAL
                        CRIT threshold for the percentage of physical RAM used
                        by the MySQL/MariaDB server processes (RSS). Supports
                        Nagios ranges. Default: 95
  --defaults-file DEFAULTS_FILE
                        MySQL/MariaDB cnf file to read user, host and password
                        from. Example: `--defaults-
                        file=/var/spool/icinga2/.my.cnf`. Default:
                        /var/spool/icinga2/.my.cnf
  --defaults-group DEFAULTS_GROUP
                        Group/section to read from in the cnf file. Default:
                        client
  --lengthy             Append the breakdown of the calculated worst case to
                        the output, every buffer with its share, largest
                        first.
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -w, --warning WARNING
                        WARN threshold for the percentage of physical RAM used
                        by the MySQL/MariaDB server processes (RSS). Supports
                        Nagios ranges. Default: 85

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-memory/
```


## Usage Examples

```bash
./mysql-memory --defaults-file=/var/spool/icinga2/.my.cnf
```

Output:

```text
MariaDB uses 208.3MiB (5.3% of 3.8GiB RAM). Other processes: 1003.0MiB.
Calculated worst case: 5.8GiB (151.8% of RAM) with all 20 connections filling all buffers at once, 2.5GiB with the 7 connections seen so far.
```

```bash
./mysql-memory --defaults-file=/var/spool/icinga2/.my.cnf --lengthy
```

Output:

```text
MariaDB uses 208.3MiB (5.3% of 3.8GiB RAM). Other processes: 1003.0MiB.
Calculated worst case: 5.8GiB (151.8% of RAM) with all 20 connections filling all buffers at once, 2.5GiB with the 7 connections seen so far.

Calculated worst case (largest first):

  256.0MiB * 20 =   5.0GiB  max_tmp_table_size * max_connections (min of tmp_table_size and max_heap_table_size)
                  360.0MiB  innodb_buffer_pool_size
                  128.0MiB  aria_pagecache_buffer_size
                  128.0MiB  key_buffer_size
                  106.9MiB  Performance Schema
    2.0MiB * 20 =  40.0MiB  join_buffer_space_limit * max_connections (caps join_buffer_size = 40.0MiB)
    2.0MiB * 20 =  40.0MiB  sort_buffer_size * max_connections
                   16.0MiB  innodb_log_buffer_size
  292.0KiB * 20 =   5.7MiB  thread_stack * max_connections
  256.0KiB * 20 =   5.0MiB  read_rnd_buffer_size * max_connections
  128.0KiB * 20 =   2.5MiB  read_buffer_size * max_connections
  =================================================
                    5.8GiB  Total (max_peak_memory)
```

The server above actually uses 208 MiB. Its worst case is 152% of the RAM, almost all of it from 256 MiB temporary tables times 20 connections, which this server never comes close to.


## States

* WARN if the RSS of the server processes crosses `--warning` (default 85% of the physical RAM), CRIT at `--critical` (default 95%).
* WARN if MySQL would allocate > 2 GiB on a 32-bit binary (address space limit).
* UNKNOWN if no `mysqld` / `mariadbd` process runs on the host.
* The calculated worst case never alerts.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mysql_aria_pagecache_buffer_size | Bytes | The size of the buffer used for index and data blocks for Aria tables. |
| mysql_innodb_buffer_pool_size | Bytes | InnoDB buffer pool size in bytes. |
| mysql_innodb_log_buffer_size | Bytes | Size in bytes of the buffer for writing InnoDB redo log files to disk. |
| mysql_join_buffer_size | Bytes | Minimum size in bytes of the buffer used for queries that cannot use an index. |
| mysql_key_buffer_size | Bytes | Size of the buffer for the index blocks used by MyISAM tables and shared for all threads. |
| mysql_max_allowed_packet | Bytes | Maximum size in bytes of a packet or a generated/intermediate string. |
| mysql_max_connections | Number | The maximum number of simultaneous client connections. |
| mysql_max_heap_table_size | Bytes | Maximum size in bytes for user-created MEMORY tables. |
| mysql_max_peak_memory | Bytes | `server_buffers + total_per_thread_buffers + pf_memory` |
| mysql_max_tmp_table_size | Bytes | `min(tmp_table_size, max_heap_table_size)` |
| mysql_max_total_per_thread_buffers | Bytes | `per_thread_buffers * Max_used_connections` (calculated), temporary tables capped at `temptable_max_ram` on MySQL |
| mysql_max_used_connections | Number | Max number of connections ever open at the same time. |
| mysql_max_used_memory | Bytes | `server_buffers + max_total_per_thread_buffers + pf_memory` |
| mysql_other_process_memory | Bytes | Total RSS of non-MySQL processes on this host. |
| mysql_pct_max_physical_memory | Percentage | `max_peak_memory / physical_memory * 100` |
| mysql_pct_max_used_memory | Percentage | `max_used_memory / physical_memory * 100` |
| mysql_pct_rss | Percentage | `rss / physical_memory * 100` |
| mysql_per_thread_buffers | Bytes | Sum of all per-thread buffer sizes (read_buffer_size + read_rnd_buffer_size + sort_buffer_size + thread_stack + join_buffer_size (or join_buffer_space_limit, see above) + binlog_cache_size when `log_bin` is ON + max_tmp_table_size). |
| mysql_pf_memory | Bytes | Performance Schema memory (`SHOW ENGINE PERFORMANCE_SCHEMA STATUS` `performance_schema.memory` row); 0 when PFS is OFF or the `PROCESS` privilege is missing. |
| mysql_physical_memory | Bytes | Total physical memory (exclusive swap). |
| mysql_query_cache_size | Bytes | Size in bytes available to the query cache. |
| mysql_read_buffer_size | Bytes | Each thread performing a sequential scan allocates a buffer of this size in bytes for each table scanned. |
| mysql_read_rnd_buffer_size | Bytes | Size in bytes of the buffer used when reading rows from a MyISAM table in sorted order after a key sort. |
| mysql_rss | Bytes | Summed RSS of the `mysqld` / `mariadbd` processes on this host. |
| mysql_server_buffers | Bytes | Sum of all global buffer sizes (key_buffer_size + innodb_buffer_pool_size + innodb_additional_mem_pool_size + innodb_log_buffer_size + query_cache_size + aria_pagecache_buffer_size). |
| mysql_sort_buffer_size | Bytes | Each session performing a sort allocates a buffer with this amount of memory. |
| mysql_thread_stack | Bytes | Stack size for each thread. |
| mysql_tmp_table_size | Bytes | The largest size for temporary tables in memory (not MEMORY tables). |
| mysql_total_per_thread_buffers | Bytes | `per_thread_buffers * max_connections`, temporary tables capped at `temptable_max_ram` on MySQL |


## Troubleshooting

### No `mysqld` or `mariadbd` process found

The check measures the memory of the database server and has to run on the database host itself, usually through the Icinga agent. Run it there, not on the monitoring server against a remote database. If the server runs on this host, check whether `/proc` is mounted with `hidepid` (`findmnt /proc`) and hides other users' processes from the monitoring user.

### Server memory crossed `--warning` / `--critical`

1. Run the check with `--lengthy` and look at the server-wide buffers at the top of the breakdown, usually `innodb_buffer_pool_size`. They take their memory for good, while the per-connection buffers only grow while a query runs.
2. Compare the buffer pool with the data it caches (`mysql-innodb-buffer-pool-size`) and lower it where it is larger than needed.
3. If the server needs the memory, add RAM to the host.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:
    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
