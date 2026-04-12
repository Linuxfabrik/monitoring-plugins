# Check mysql-innodb-buffer-pool-size


## Overview

Checks the InnoDB buffer pool size configuration in MySQL/MariaDB. Compares the configured `innodb_buffer_pool_size` against the actual data and index sizes of all InnoDB tables to determine if the buffer pool is large enough. Also checks the ratio of `innodb_log_file_size * innodb_log_files_in_group` to the buffer pool size, which should be in the range of 20-30%.

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-mysql/)
* Always take care of both `innodb_buffer_pool_size` and `innodb_log_file_size` when making adjustments
* User account requires access to INFORMATION_SCHEMA (user with no privileges is sufficient) and SELECT privileges on all schemas and tables to provide accurate results
* [For most INFORMATION_SCHEMA tables, each MySQL user has the right to access them, but can see only the rows in the tables that correspond to objects for which the user has the proper access privileges.](https://dev.mysql.com/doc/refman/5.7/en/information-schema-introduction.html#information-schema-privileges) [So you can't grant permission to INFORMATION_SCHEMA directly, you have to grant SELECT permission to the tables on your own schemas, and as you do, those tables will start showing up in INFORMATION_SCHEMA queries.](https://stackoverflow.com/questions/60499772/cannot-grant-mysql-user-access-to-information-schema-database)
* On MariaDB 10.2.2+, `innodb_buffer_pool_size` [can be set dynamically.](https://mariadb.com/kb/en/setting-innodb-buffer-pool-size-dynamically/)
* `innodb_log_files_in_group` was removed in MariaDB 10.6.0; the check handles this gracefully by defaulting to 1

**Data Collection:**

* Queries `SHOW GLOBAL VARIABLES` for `innodb_buffer_pool_size`, `innodb_log_file_size`, `innodb_log_files_in_group`, and `innodb_redo_log_capacity`
* Queries `information_schema.tables` to sum all InnoDB data and index sizes
* Calculates the log file to buffer pool size ratio
* Logic is taken from [MySQLTuner script](https://github.com/major/MySQLTuner-perl):mysql_innodb()


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-innodb-buffer-pool-size> |
| Nagios/Icinga Check Name              | `check_mysql_innodb_buffer_pool_size` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: mysql-innodb-buffer-pool-size [-h] [-V] [--always-ok]
                                     [--defaults-file DEFAULTS_FILE]
                                     [--defaults-group DEFAULTS_GROUP]
                                     [--timeout TIMEOUT]

Checks the InnoDB buffer pool size configuration in MySQL/MariaDB. Compares
the configured size against the recommended size based on actual data and
index sizes. Alerts if the buffer pool is significantly undersized.

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
Data size: 2.5GiB, innodb_buffer_pool_size: 4.0GiB
Ratio innodb_log_file_size (1.0GiB) * innodb_log_files_in_group (1) vs. innodb_buffer_pool_size (4.0GiB): 25%
```


## States

* WARN on 32-bit systems when InnoDB buffer pool size > 4 GiB.
* WARN on 64-bit systems when InnoDB buffer pool size > 16 EiB.
* WARN if the total InnoDB data size does not fit into the buffer pool.
* WARN if the InnoDB log file size ratio is not in the range of 20-30% of the buffer pool size.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mysql_innodb_buffer_pool_size | Bytes | InnoDB buffer pool size in bytes. The primary value to adjust on a database server with entirely/primarily InnoDB tables, can be set up to 80% of the total memory. |
| mysql_innodb_log_file_size | Bytes | Size in bytes of each InnoDB redo log file in the log group. The combined size can be no more than 512 GiB. Larger values mean less disk I/O due to less flushing checkpoint activity, but also slower recovery from a crash. |
| mysql_innodb_log_files_in_group | Number | Number of physical files in the InnoDB redo log. Deprecated and ignored from MariaDB 10.5.2. |
| mysql_innodb_log_size_pct | Percentage | innodb_log_file_size * innodb_log_files_in_group / innodb_buffer_pool_size * 100 |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:
    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
