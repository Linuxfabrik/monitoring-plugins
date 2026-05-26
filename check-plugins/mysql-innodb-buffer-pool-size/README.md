# Check mysql-innodb-buffer-pool-size


## Overview

Checks the InnoDB buffer pool size configuration in MySQL/MariaDB. Compares the configured `innodb_buffer_pool_size` against the actual data and index sizes of all InnoDB tables to determine if the buffer pool is large enough. On MySQL 8.0.30+ it additionally derives a workload-based recommendation for `innodb_redo_log_capacity` from the per-hour `Innodb_os_log_written` write rate and the host's RAM tier (rounding rules match mysqltuner).

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-mysql/)
* Always take care of both `innodb_buffer_pool_size` and `innodb_redo_log_capacity` (MySQL 8.0.30+) or `innodb_log_file_size` (older MySQL, MariaDB) when making adjustments
* If the InnoDB engine is not available or is disabled, the plugin reports OK with an info message instead of UNKNOWN
* On MariaDB 10.2.2+, `innodb_buffer_pool_size` [can be set dynamically.](https://mariadb.com/kb/en/setting-innodb-buffer-pool-size-dynamically/)
* On servers without `innodb_redo_log_capacity` (MariaDB, MySQL < 8.0.30), the workload-based redo-log sizing recommendation is skipped; the `innodb_log_file_size` is still emitted as perfdata for trending
* The workload-based redo-log check needs at least 1 hour of uptime so the hourly write rate is meaningful; on freshly booted servers it is deferred
* User account requires access to INFORMATION_SCHEMA (user with no privileges is sufficient) and SELECT privileges on all schemas and tables to provide accurate results
* [For most INFORMATION_SCHEMA tables, each MySQL user has the right to access them, but can see only the rows in the tables that correspond to objects for which the user has the proper access privileges.](https://dev.mysql.com/doc/refman/5.7/en/information-schema-introduction.html#information-schema-privileges) [So you can't grant permission to INFORMATION_SCHEMA directly, you have to grant SELECT permission to the tables on your own schemas, and as you do, those tables will start showing up in INFORMATION_SCHEMA queries.](https://stackoverflow.com/questions/60499772/cannot-grant-mysql-user-access-to-information-schema-database)

**Data Collection:**

* Queries `SHOW GLOBAL VARIABLES` for `innodb_buffer_pool_size`, `innodb_file_per_table`, `innodb_log_file_size`, and `innodb_redo_log_capacity`
* Queries `SHOW GLOBAL STATUS` for `Innodb_os_log_written` and `Uptime`
* Queries `information_schema.tables` to sum all InnoDB data and index sizes
* Reads the host's physical RAM via `sysconf(SC_PAGE_SIZE) * sysconf(SC_PHYS_PAGES)` to pick the right RAM tier for the rounding rule
* Logic taken from [MySQLTuner](https://github.com/major/MySQLTuner-perl):mysql_innodb() and verified in sync with MySQLTuner (architecture limits, buffer-pool-vs-data-size check, and the workload-based `innodb_redo_log_capacity` recommendation for MySQL 8.0.30+)


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-innodb-buffer-pool-size> |
| Nagios/Icinga Check Name              | `check_mysql_innodb_buffer_pool_size` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Requirements                          | User with `SELECT` privilege (typically `GRANT SELECT ON *.*`), locked down to `127.0.0.1` - for example `monitoring\@127.0.0.1`. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions. |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: mysql-innodb-buffer-pool-size [-h] [-V] [--always-ok]
                                     [--defaults-file DEFAULTS_FILE]
                                     [--defaults-group DEFAULTS_GROUP]
                                     [--timeout TIMEOUT]

Checks the InnoDB buffer pool size configuration in MySQL/MariaDB. Compares
the configured `innodb_buffer_pool_size` against the actual InnoDB data and
index sizes, and on MySQL 8.0.30+ derives a workload-based recommendation for
`innodb_redo_log_capacity` from the per-hour `Innodb_os_log_written` write
rate and the host's RAM tier (matches mysqltuner). Also flags
`innodb_file_per_table = OFF` and architecture-related buffer-pool size
limits. Alerts if the buffer pool is undersized relative to the data or if
`innodb_redo_log_capacity` is smaller than the workload-based target. On older
MySQL and on MariaDB (no `innodb_redo_log_capacity`), the redo-log size check
is skipped; the redo-log file size is still emitted as perfdata for trending.

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
./mysql-innodb-buffer-pool-size --defaults-file=/var/spool/icinga2/.my.cnf
```

Output on MySQL 8.0.30+:

```text
`innodb_buffer_pool_size` (4.0GiB) >= InnoDB data + index size (2.5GiB).

`innodb_redo_log_capacity` (1.0GiB) matches the workload-based target (1.0GiB for 380.0MiB/h on 16.0GiB RAM).
```

Output on MariaDB or MySQL < 8.0.30 (workload-based check skipped):

```text
`innodb_buffer_pool_size` (4.0GiB) >= InnoDB data + index size (2.5GiB).

`innodb_log_file_size` (1.0GiB); redo-log sizing check skipped on this server (no `innodb_redo_log_capacity`).
```

When the buffer pool is undersized and the redo log capacity is too small:

```text
`innodb_file_per_table` is `OFF` [WARNING].

`innodb_buffer_pool_size` (1.0GiB) is smaller than the InnoDB data + index size (2.5GiB) [WARNING].

`innodb_redo_log_capacity` (96.0MiB) is below the workload-based target of 1.0GiB (hourly InnoDB log write rate: 850.0MiB/h on a host with 16.0GiB RAM) [WARNING].

Recommendations:
* Set `innodb_file_per_table` = `ON` so each InnoDB table gets its own .ibd file (per-table maintenance is harder when everything lives in `ibdata1`)
* Set `innodb_buffer_pool_size` >= 2.5GiB so the working set fits in memory
* Raise `innodb_redo_log_capacity` to 1.0GiB or more. Tradeoff: higher capacity means longer crash recovery
```


## States

* WARN on 32-bit hosts when `innodb_buffer_pool_size > 4 GiB`.
* WARN on 64-bit hosts when `innodb_buffer_pool_size > 16 EiB` (the theoretical 64-bit address space ceiling).
* WARN if `innodb_file_per_table` is not `ON`.
* WARN if the InnoDB data + index size does not fit into `innodb_buffer_pool_size`.
* WARN on MySQL 8.0.30+ if `innodb_redo_log_capacity` is more than 10% below the workload-based target (derived from `Innodb_os_log_written / uptime` and the host's RAM tier).
* OK if the InnoDB engine is not available or is disabled.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mysql_innodb_buffer_pool_size | Bytes | `innodb_buffer_pool_size` in bytes. The primary value to adjust on a database server with entirely/primarily InnoDB tables, can be set up to 80% of the total memory. |
| mysql_innodb_data_size | Bytes | Sum of `DATA_LENGTH + INDEX_LENGTH` across all InnoDB tables in non-system schemas. |
| mysql_innodb_log_file_size | Bytes | Size of each InnoDB redo log file. Emitted on MariaDB and MySQL < 9.3.0; absent on MySQL >= 9.3.0, where `innodb_log_file_size` was removed in favour of `innodb_redo_log_capacity`. |
| mysql_innodb_os_log_written_per_hour | Bytes | Hourly InnoDB redo log write rate, derived as `Innodb_os_log_written / (Uptime / 3600)`. Only emitted on MySQL 8.0.30+ with at least 1 hour of uptime. |
| mysql_innodb_redo_log_capacity | Bytes | Configured `innodb_redo_log_capacity` (MySQL 8.0.30+ only). |
| mysql_innodb_redo_log_capacity_recommended | Bytes | Workload-based recommendation for `innodb_redo_log_capacity`, derived from the hourly write rate and rounded into the host's RAM tier (matches mysqltuner). Only emitted on MySQL 8.0.30+ with at least 1 hour of uptime. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:
    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
