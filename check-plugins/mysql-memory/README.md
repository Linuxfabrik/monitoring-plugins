# Check mysql-memory


## Overview

Checks current and maximum possible memory usage specifically for MySQL/MariaDB. Calculates the theoretical maximum memory consumption based on global buffers, per-thread buffers, max connections, and Performance Schema usage. Compares this against the physical memory of the server.

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-MYSQL.md)
* Requires MySQL/MariaDB v4+
* Must be running locally on the MySQL/MariaDB server to check system memory
* User account requires PROCESS privileges

**Data Collection:**

* Queries `SHOW GLOBAL VARIABLES` for all relevant buffer size variables (`innodb_buffer_pool_size`, `key_buffer_size`, `sort_buffer_size`, `join_buffer_size`, `max_connections`, etc.)
* Queries `SHOW GLOBAL STATUS` for `Max_used_connections`
* Queries Performance Schema for current memory usage (if enabled)
* Uses `psutil` (if available) to determine memory consumption of other running processes
* Uses `os.sysconf` to determine total physical memory
* Logic is taken from [MySQLTuner script](https://github.com/major/MySQLTuner-perl):mysql_stats(), v1.9.8

**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-memory> |
| Nagios/Icinga Check Name              | `check_mysql_memory` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `psutil`, `pymysql` |


## Help

```text
usage: mysql-memory [-h] [-V] [--always-ok] [--defaults-file DEFAULTS_FILE]
                    [--defaults-group DEFAULTS_GROUP] [--timeout TIMEOUT]

Checks memory allocation and usage metrics for MySQL/MariaDB, including global
buffers, per-thread buffers, and total potential memory consumption. Alerts if
the server's memory configuration could lead to excessive memory usage.

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
./mysql-memory --defaults-file=/var/spool/icinga2/.my.cnf
```

Output:

```text
67.6% - total: 31.3GiB, used: 21.1GiB. Maximum possible memory usage is 99.5% (possible peak: 31.1GiB). Overall possible memory usage (31.1GiB) with other processes (5.2GiB) will exceed physical memory (31.3GiB). [WARNING]

Calculations:
* Memory usage according to Performance Schema: pfm = 0.0B
* Server Buffers: sb = 18.3GiB
* Max. Total per Thread Buffers: mtptb = 2.8GiB
* Total per Thread Buffers: tptb = 12.8GiB
* Max. Used Memory: mum = sb + mtptb + pfm = 18.3GiB + 2.8GiB + 0.0B = 21.1GiB
* Possible Peak Memory: ppm = sb + tptb + pfm = 18.3GiB + 12.8GiB + 0.0B = 31.1GiB
* Physical Memory: pm = 31.3GiB
* Max Used Memory %: mump = mum / pm * 100 = 21.1GiB / 31.3GiB * 100 = 67.6%
* Max Possible Memory Usage %: mpmu = ppm / pm * 100 = 31.1GiB / 31.3GiB * 100 = 99.5%
```


## States

* WARN if max used memory > 2 GiB on 32-bit systems.
* WARN if max used memory > 95% of physical memory.
* WARN if physical memory < max peak memory + memory usage by other processes (excluding mysqld, mariadbd, and systemd).
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
| mysql_max_peak_memory | Bytes | server_buffers + total_per_thread_buffers + performance schema usage |
| mysql_max_tmp_table_size | Bytes | max(max_heap_table_size, tmp_table_size) |
| mysql_max_total_per_thread_buffers | Bytes | per_thread_buffers * max_used_connections |
| mysql_max_used_connections | Number | Max number of connections ever open at the same time. |
| mysql_max_used_memory | Bytes | server_buffers + max_total_per_thread_buffers + performance schema usage |
| mysql_pct_max_physical_memory | Percentage | max_peak_memory / physical_memory * 100 |
| mysql_pct_max_used_memory | Percentage | max_used_memory / physical_memory * 100 |
| mysql_per_thread_buffers | Bytes | Sum of all per-thread buffer sizes (read_buffer_size + read_rnd_buffer_size + sort_buffer_size + thread_stack + max_allowed_packet + join_buffer_size). |
| mysql_physical_memory | Bytes | Total physical memory (exclusive swap). |
| mysql_query_cache_size | Bytes | Size in bytes available to the query cache. |
| mysql_read_buffer_size | Bytes | Each thread performing a sequential scan allocates a buffer of this size in bytes for each table scanned. |
| mysql_read_rnd_buffer_size | Bytes | Size in bytes of the buffer used when reading rows from a MyISAM table in sorted order after a key sort. |
| mysql_server_buffers | Bytes | Sum of all global buffer sizes (key_buffer_size + max_tmp_table_size + innodb_buffer_pool_size + innodb_additional_mem_pool_size + innodb_log_buffer_size + query_cache_size + aria_pagecache_buffer_size). |
| mysql_sort_buffer_size | Bytes | Each session performing a sort allocates a buffer with this amount of memory. |
| mysql_thread_stack | Bytes | Stack size for each thread. |
| mysql_tmp_table_size | Bytes | The largest size for temporary tables in memory (not MEMORY tables). |
| mysql_total_per_thread_buffers | Bytes | per_thread_buffers * max_connections |


## Troubleshooting

`Overall possible memory usage with other process will exceed memory [WARNING]. Dedicate this server to your database for highest performance.`
Decrease `max_connections`, tune buffer settings, stop other processes, or increase memory.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:
    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
