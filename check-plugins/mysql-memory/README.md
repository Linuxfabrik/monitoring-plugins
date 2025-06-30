# Check mysql-memory

## Overview

Checks current and maximum possible memory usage specifically for MySQL/MariaDB. Logic is taken from [MySQLTuner script](https://github.com/major/MySQLTuner-perl):mysql_stats(), v1.9.8.

Hints:

* See [additional notes for all mysql monitoring plugins](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-MYSQL.md)
* Requires MySQL/MariaDB v4+.
* Must be running locally on the MySQL/MariaDB server to be able to check the system requirements.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-memory> |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Requirements                          | User with PROCESS privileges, locked down to `127.0.0.1` - for example `monitoring\@127.0.0.1`. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions. |
| 3rd Party Python modules              | `psutil`, `pymysql` |


## Help

```text
usage: mysql-memory [-h] [-V] [--always-ok] [--defaults-file DEFAULTS_FILE]
                    [--defaults-group DEFAULTS_GROUP] [--timeout TIMEOUT]

Checks memory metrics for MySQL/MariaDB.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --defaults-file DEFAULTS_FILE
                        Specifies a cnf file to read parameters like user,
                        host and password from (instead of specifying them on
                        the command line), for example
                        `/var/spool/icinga2/.my.cnf`. Default:
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
67.6% - total: 31.3GiB, used: 21.1GiB. Maximum possible memory usage is 99.5% (possible peak: 31.1GiB). Reduce your overall MySQL memory footprint for system stability. Overall possible memory usage with other processes will exceed memory . Dedicate this server to your database for highest performance.

Calculations:
* Memory usage according to Performance Schema: pfm = 0.0B
* Server Buffers: sb = 18.3GiB
* Max. Total per Thread Buffers: mtptb = 2.8GiB
* Total per Thread Buffers: tptb = 12.8GiB
* Max. Used Memory: mum = sb + mtptb + pfm = 18.3GiB + 2.8GiB + 0.0B = 21.1GiB
* Possible Peak Memory: ppm = sb + tptb + pfm = 18.3GiB + 12.8GiB + 0.0B = 31.1GiB
* Physical Memory: pm = 31.3GiB
* Max Used Memory %: mump = mum / pm * 100 = 21.1GiB / 31.3GiB * 100 = 67.6B%
* Max Possible Memory Usage %: mpmu = ppm / pm * 100 = 31.1GiB / 31.3GiB * 100 = 99.5B%
```


## States

* WARN if max_used_memory \> 2 GB on 32 bit systems.
* WARN if max_used_memory \> 85%.
* WARN if physical_memory \< max_peak_memory + memory usage by other processes (except some specific like MySQL/MariaDB or Systemd).


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mysql_aria_pagecache_buffer_size | Bytes | The size of the buffer used for index and data blocks for Aria tables. This can include explicit Aria tables, system tables, and temporary tables. |
| mysql_innodb_buffer_pool_size | Bytes | InnoDB buffer pool size in bytes. The primary value to adjust on a database server with entirely/primarily InnoDB tables, can be set up to 80% of the total memory in these environments. |
| mysql_innodb_log_buffer_size | Bytes | Size in bytes of the buffer for writing InnoDB redo log files to disk. Increasing this means larger transactions can run without needing to perform disk I/O before committing. |
| mysql_join_buffer_size | Bytes | Minimum size in bytes of the buffer used for queries that cannot use an index, and instead perform a full table scan. |
| mysql_key_buffer_size | Bytes | Size of the buffer for the index blocks used by MyISAM tables and shared for all threads. |
| mysql_max_allowed_packet | Bytes | Maximum size in bytes of a packet or a generated/intermediate string. The packet message buffer is initialized with the value from net_buffer_length, but can grow up to max_allowed_packet bytes. |
| mysql_max_connections | Number | The maximum number of simultaneous client connections. |
| mysql_max_heap_table_size | Bytes | Maximum size in bytes for user-created MEMORY tables. |
| mysql_max_peak_memory | Bytes | server_buffers + total_per_thread_buffers + performance schema usage |
| mysql_max_tmp_table_size | Bytes | max(max_heap_table_size, tmp_table_size) |
| mysql_max_total_per_thread_buffers | Bytes | per_thread_buffers \* max_used_connections |
| mysql_max_used_connections | Number | Max number of connections ever open at the same time. The global value can be flushed by FLUSH STATUS. |
| mysql_max_used_memory | Bytes | server_buffers + max_total_per_thread_buffers + performance schema usage |
| mysql_pct_max_physical_memory | Percentage | max_peak_memory / physical_memory \* 100 |
| mysql_pct_max_used_memory | Percentage | max_used_memory / physical_memory \* 100 |
| mysql_per_thread_buffers | Bytes | Have a look at the source code. |
| mysql_physical_memory | Bytes | Total physical memory (exclusive swap). |
| mysql_query_cache_size | Bytes | Size in bytes available to the query cache. About 40KB is needed for query cache structures, so setting a size lower than this will result in a warning. |
| mysql_read_buffer_size | Bytes | Each thread performing a sequential scan (for MyISAM, Aria and MERGE tables) allocates a buffer of this size in bytes for each table scanned. |
| mysql_read_rnd_buffer_size | Bytes | Size in bytes of the buffer used when reading rows from a MyISAM table in sorted order after a key sort. |
| mysql_server_buffers | Bytes | Have a look at the source code. |
| mysql_sort_buffer_size | Bytes | Each session performing a sort allocates a buffer with this amount of memory. Not specific to any storage engine. |
| mysql_thread_stack | Bytes | Stack size for each thread. |
| mysql_tmp_table_size | Bytes | The largest size for temporary tables in memory (not MEMORY tables) although if max_heap_table_size is smaller the lower limit will apply. |
| mysql_total_per_thread_buffers | Bytes | per_thread_buffers \* max_connections |


## Troubleshooting

Overall possible memory usage with other process will exceed memory \[WARNING\]. Dedicate this server to your database for highest performance.  
Decrease `max_connections`, tune buffer settings, stop other processes or increase memory.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)

* License: The Unlicense, see [LICENSE file](https://unlicense.org/).

* Credits:

    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
