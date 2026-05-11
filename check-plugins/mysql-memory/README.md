# Check mysql-memory


## Overview

Estimates MySQL/MariaDB memory consumption and compares it to the host's physical RAM. Reports the currently-reached usage (server-wide buffers + per-thread buffers * `Max_used_connections` + Performance Schema memory + Galera GCache if present) and the theoretical worst-case peak (same formula but with `max_connections`). Also surfaces RAM consumed by non-database processes so admins can see when MySQL plus the rest of the system would exceed physical memory.

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-mysql/)
* Must run locally on the MySQL/MariaDB server (uses `os.sysconf` for physical RAM and `psutil` to discover other-process memory).
* Run with `--lengthy` to see the per-buffer breakdown table when an alert needs investigation.

**Data Collection:**

* Queries `SHOW GLOBAL VARIABLES` for the relevant buffer size variables (`innodb_buffer_pool_size`, `key_buffer_size`, `sort_buffer_size`, `join_buffer_size`, `max_connections`, `wsrep_provider_options` for Galera, ...).
* Queries `SHOW GLOBAL STATUS` for `Max_used_connections`.
* Queries `SHOW ENGINE PERFORMANCE_SCHEMA STATUS` for the Performance Schema memory row when `performance_schema` is ON.
* Parses `wsrep_provider_options` for `gcache.size` when `wsrep_on` is ON.
* Uses `psutil` (if installed) to total RSS of processes whose `name` is not `mysqld` / `mariadbd`.
* Uses `os.sysconf` for total physical memory.
* Logic is taken from [MySQLTuner script](https://github.com/major/MySQLTuner-perl):mysql_stats() ("Memory usage" section), verified in sync with v2.8.41.


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-memory> |
| Nagios/Icinga Check Name              | `check_mysql_memory` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `psutil`, `pymysql` |


## Help

```text
usage: mysql-memory [-h] [-V] [--always-ok] [-c CRITICAL]
                    [--defaults-file DEFAULTS_FILE]
                    [--defaults-group DEFAULTS_GROUP] [--lengthy]
                    [--timeout TIMEOUT] [-w WARNING]

Estimates MySQL/MariaDB memory consumption and compares it to the host's
physical RAM. Reports the currently-reached usage (server-wide buffers + per-
thread buffers * `Max_used_connections` + Performance Schema memory + Galera
GCache if present) and the theoretical worst-case peak (same formula but with
`max_connections`). Also surfaces the RAM consumed by non-database processes
on the host so admins can see when MySQL plus the rest of the system would
exceed physical memory. Alerts when used or peak memory crosses the
`--warning` / `--critical` thresholds, when peak + other-process memory
exceeds physical RAM, and when MySQL would allocate more than 2 GiB on a
32-bit system.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRITICAL
                        CRIT threshold for the percentage of physical RAM
                        consumed by the reached MySQL memory footprint
                        (server_buffers + per_thread_buffers *
                        Max_used_connections + Performance Schema + Galera
                        GCache). Supports Nagios ranges. Default: 95
  --defaults-file DEFAULTS_FILE
                        MySQL/MariaDB cnf file to read user, host and password
                        from. Example: `--defaults-
                        file=/var/spool/icinga2/.my.cnf`. Default:
                        /var/spool/icinga2/.my.cnf
  --defaults-group DEFAULTS_GROUP
                        Group/section to read from in the cnf file. Default:
                        client
  --lengthy             Append a full memory breakdown table to the output
                        (each contributing buffer + the calculation that
                        produces server_buffers, per_thread_buffers,
                        max_used_memory and max_peak_memory). Useful when a
                        WARNING/CRITICAL fires and you need to see which
                        buffer dominates the footprint.
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -w, --warning WARNING
                        WARN threshold for the percentage of physical RAM
                        consumed by the reached MySQL memory footprint.
                        Supports Nagios ranges. Default: 85
```


## Usage Examples

```bash
./mysql-memory --defaults-file=/var/spool/icinga2/.my.cnf
```

Output (short, default):

```text
Max used memory: 67.6% (21.1GiB of 31.3GiB physical) [WARNING]. Peak possible: 99.5% (31.1GiB) [CRITICAL]. Other process memory: 5.2GiB [WARNING].

Recommendations:
* Reduce your overall MySQL memory footprint for system stability
* Dedicate this server to MySQL/MariaDB: peak MySQL memory plus other-process memory would exceed physical RAM
* Top contributors to peak memory (largest first):
  - `max_allowed_packet` (16.0MiB) * `max_connections` (676) = 10.6GiB
  - `innodb_buffer_pool_size` (8.0GiB)
  - `sort_buffer_size` (2.0MiB) * `max_connections` (676) = 1.3GiB
  - `aria_pagecache_buffer_size` (128.0MiB)
  - `key_buffer_size` (128.0MiB)
```

For per-thread buffers the line reads as `<var> (per-conn value) * max_connections (N) = total`; for server-wide buffers the value is shown inline in parens (no multiplier).

When state is OK there are no recommendations and no top-contributors hint - the output stays compact. The top-5 list always reflects this specific server's settings; the ranking changes depending on whether `max_connections` is large enough for the per-thread buffers to overtake `innodb_buffer_pool_size`.

Output (`--lengthy`, additionally):

```text
Memory breakdown (sorted by contribution to peak memory):

  `max_allowed_packet` (16.0MiB) * `max_connections` (676) = 10.6GiB
  `innodb_buffer_pool_size` (8.0GiB)
  `sort_buffer_size` (2.0MiB) * `max_connections` (676) = 1.3GiB
  `thread_stack` (292.0KiB) * `max_connections` (676) = 192.7MiB
  `aria_pagecache_buffer_size` (128.0MiB)
  `key_buffer_size` (128.0MiB)
  `read_rnd_buffer_size` (256.0KiB) * `max_connections` (676) = 169.0MiB
  `join_buffer_size` (256.0KiB) * `max_connections` (676) = 169.0MiB
  `read_buffer_size` (128.0KiB) * `max_connections` (676) = 84.5MiB
  Performance Schema memory (50.0MiB)
  `innodb_log_buffer_size` (16.0MiB)
  `max_tmp_table_size` (16.0MiB, min of `tmp_table_size` and `max_heap_table_size`)
  `query_cache_size` (1.0MiB)
  `innodb_additional_mem_pool_size`
  Galera GCache (`gcache.size`)
  ----------------------------------------------------------------------
  max_peak_memory = 31.1GiB
  max_used_memory (currently reached) = 21.1GiB
  Physical RAM (host) = 31.3GiB
  Other process memory (host) = 5.2GiB
```


## States

* WARN if reached memory footprint (`pct_max_used_memory`) crosses `--warning` (default 85%); CRIT at `--critical` (default 95%).
* WARN if theoretical peak (`pct_max_physical_memory`) crosses `--warning`; CRIT at `--critical`.
* WARN if MySQL would allocate > 2 GiB on a 32-bit binary (address space limit).
* WARN if peak MySQL memory + other-process memory exceeds physical RAM (dedicate-the-host hint).
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
| mysql_gcache_memory | Bytes | Galera GCache size from `wsrep_provider_options` (`gcache.size`); 0 when wsrep is off. |
| mysql_max_peak_memory | Bytes | `server_buffers + total_per_thread_buffers + pf_memory + gcache_memory` |
| mysql_max_tmp_table_size | Bytes | `min(tmp_table_size, max_heap_table_size)` |
| mysql_max_total_per_thread_buffers | Bytes | `per_thread_buffers * Max_used_connections` |
| mysql_max_used_connections | Number | Max number of connections ever open at the same time. |
| mysql_max_used_memory | Bytes | `server_buffers + max_total_per_thread_buffers + pf_memory + gcache_memory` |
| mysql_other_process_memory | Bytes | Total RSS of non-MySQL processes on this host. |
| mysql_pct_max_physical_memory | Percentage | `max_peak_memory / physical_memory * 100` |
| mysql_pct_max_used_memory | Percentage | `max_used_memory / physical_memory * 100` |
| mysql_per_thread_buffers | Bytes | Sum of all per-thread buffer sizes (read_buffer_size + read_rnd_buffer_size + sort_buffer_size + thread_stack + max_allowed_packet + join_buffer_size). |
| mysql_pf_memory | Bytes | Performance Schema memory (`SHOW ENGINE PERFORMANCE_SCHEMA STATUS` `memory` row); 0 when PFS is OFF. |
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
