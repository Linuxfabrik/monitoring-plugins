# Check mysql-innodb-buffer-pool-size


## Overview

Checks the InnoDB buffer pool size configuration in MySQL/MariaDB. Compares the configured `innodb_buffer_pool_size` against the actual data and index sizes of all InnoDB tables to determine if the buffer pool is large enough. Also checks the ratio of `innodb_log_file_size * innodb_log_files_in_group` to the buffer pool size, which should be in the range of 20-30%.

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-mysql/)
* Always take care of both `innodb_buffer_pool_size` and `innodb_log_file_size` (or `innodb_redo_log_capacity` on MySQL 8.0.30+) when making adjustments
* User account requires access to INFORMATION_SCHEMA (user with no privileges is sufficient) and SELECT privileges on all schemas and tables to provide accurate results
* [For most INFORMATION_SCHEMA tables, each MySQL user has the right to access them, but can see only the rows in the tables that correspond to objects for which the user has the proper access privileges.](https://dev.mysql.com/doc/refman/5.7/en/information-schema-introduction.html#information-schema-privileges) [So you can't grant permission to INFORMATION_SCHEMA directly, you have to grant SELECT permission to the tables on your own schemas, and as you do, those tables will start showing up in INFORMATION_SCHEMA queries.](https://stackoverflow.com/questions/60499772/cannot-grant-mysql-user-access-to-information-schema-database)
* On MariaDB 10.2.2+, `innodb_buffer_pool_size` [can be set dynamically.](https://mariadb.com/kb/en/setting-innodb-buffer-pool-size-dynamically/)
* `innodb_log_files_in_group` was removed in MariaDB 10.6.0; the check handles this gracefully by defaulting to 1
* On MySQL 8.0.30+, the log-size ratio uses `innodb_redo_log_capacity` (which replaced `innodb_log_file_size * innodb_log_files_in_group` as the single sizing knob)
* If the InnoDB engine is not available or is disabled, the plugin reports OK with an info message instead of UNKNOWN

**Data Collection:**

* Queries `SHOW GLOBAL VARIABLES` for `innodb_buffer_pool_size`, `innodb_file_per_table`, `innodb_log_file_size`, `innodb_log_files_in_group`, and `innodb_redo_log_capacity`
* Queries `information_schema.tables` to sum all InnoDB data and index sizes
* Calculates the log file to buffer pool size ratio
* Logic is taken from [MySQLTuner](https://github.com/major/MySQLTuner-perl):mysql_innodb() and has been verified in sync with MySQLTuner v2.8.41. Not implemented: the workload-based `innodb_redo_log_capacity` recommendation that mysqltuner v2.8.41 derives from `Innodb_os_log_written`/uptime + RAM tiers (would require additional status counters and a memory check)


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
index sizes, and the ratio of `innodb_log_file_size *
innodb_log_files_in_group` (or `innodb_redo_log_capacity` on MySQL 8.0.30+)
vs. `innodb_buffer_pool_size` against the recommended 25%. Also flags
`innodb_file_per_table = OFF` and architecture-related buffer-pool size
limits. Alerts if the buffer pool is undersized relative to the data, or if
the log-size ratio is outside the recommended 20-30% band.

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
./mysql-innodb-buffer-pool-size --defaults-file=/var/spool/icinga2/.my.cnf
```

Output:

```text
`innodb_buffer_pool_size` (4.0GiB) >= InnoDB data + index size (2.5GiB).

Log size ratio = `innodb_log_file_size` (1.0GiB) * `innodb_log_files_in_group` (1) / `innodb_buffer_pool_size` (4.0GiB) = 25.0% (target: 25%).
```

When the buffer pool is undersized:

```text
`innodb_file_per_table` is `OFF`; set it to `ON` so each InnoDB table gets its own .ibd file [WARNING].

`innodb_buffer_pool_size` (1.0GiB) is smaller than the InnoDB data + index size (2.5GiB); set `innodb_buffer_pool_size` >= 2.5GiB so the working set fits in memory [WARNING].

Log size ratio = `innodb_log_file_size` (256.0MiB) * `innodb_log_files_in_group` (2) / `innodb_buffer_pool_size` (1.0GiB) = 50.0% (target: 25%) [WARNING]. To reach 25%, set `innodb_log_file_size` = 128.0MiB.
```

On MySQL 8.0.30+ the log-size line uses `innodb_redo_log_capacity` instead of `innodb_log_file_size * innodb_log_files_in_group`.


## States

* WARN on 32-bit hosts when `innodb_buffer_pool_size > 4 GiB`.
* WARN on 64-bit hosts when `innodb_buffer_pool_size > 16 EiB` (the theoretical 64-bit address space ceiling).
* WARN if `innodb_file_per_table` is not `ON`.
* WARN if the InnoDB data + index size does not fit into `innodb_buffer_pool_size`.
* WARN if the log-size ratio (`innodb_log_file_size * innodb_log_files_in_group` or `innodb_redo_log_capacity` on MySQL 8.0.30+) divided by `innodb_buffer_pool_size` is outside the 20-30% band (target: 25%).
* OK if the InnoDB engine is not available or is disabled.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mysql_innodb_buffer_pool_size | Bytes | `innodb_buffer_pool_size` in bytes. The primary value to adjust on a database server with entirely/primarily InnoDB tables, can be set up to 80% of the total memory. |
| mysql_innodb_data_size | Bytes | Sum of `DATA_LENGTH + INDEX_LENGTH` across all InnoDB tables in non-system schemas. |
| mysql_innodb_log_file_size | Bytes | Size of each InnoDB redo log file in the log group. Larger values mean less disk I/O but slower crash recovery. |
| mysql_innodb_log_files_in_group | Number | Number of physical files in the InnoDB redo log. Deprecated and ignored from MariaDB 10.5.2. |
| mysql_innodb_redo_log_capacity | Bytes | MySQL 8.0.30+ replacement for `innodb_log_file_size * innodb_log_files_in_group`. Only emitted when the variable is exposed by the server. |
| mysql_innodb_log_size_pct | Percentage | Either `innodb_redo_log_capacity / innodb_buffer_pool_size * 100` (MySQL 8.0.30+) or `innodb_log_file_size * innodb_log_files_in_group / innodb_buffer_pool_size * 100` otherwise. Target: 25%. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:
    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
