# Check mysql-aria

## Overview

Checks metrics of the Aria storage engine in MariaDB, including the page cache size relative to total Aria index size and the page cache hit rate. Aria is the crash-safe, non-transactional storage engine used for internal temporary tables in MariaDB. It is not shipped with MySQL or Percona Server.

**Data Collection:**

* Queries `SHOW GLOBAL VARIABLES` for `aria_pagecache_buffer_size`
* Queries `SHOW GLOBAL STATUS` for `Aria_pagecache_reads` and `Aria_pagecache_read_requests`
* Queries `information_schema.tables` to sum all Aria index sizes
* Logic is taken from [MySQLTuner script](https://github.com/major/MySQLTuner-perl):mariadb_aria()

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-MYSQL.md)
* User account requires access to INFORMATION_SCHEMA (user with no privileges is sufficient) and SELECT privileges on all schemas and tables to provide accurate results
* [For most INFORMATION_SCHEMA tables, each MySQL user has the right to access them, but can see only the rows in the tables that correspond to objects for which the user has the proper access privileges.](https://dev.mysql.com/doc/refman/5.7/en/information-schema-introduction.html#information-schema-privileges) [So you can't grant permission to INFORMATION_SCHEMA directly, you have to grant SELECT permission to the tables on your own schemas, and as you do, those tables will start showing up in INFORMATION_SCHEMA queries.](https://stackoverflow.com/questions/60499772/cannot-grant-mysql-user-access-to-information-schema-database)
* "total Aria indexes: 0.0B" means that there are no Aria-based tables at all, or the user performing the check does not have SELECT privileges on them



**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-aria> |
| Nagios/Icinga Check Name              | `check_mysql_aria` |
| Check Interval Recommendation         | Once an hour |
| Can be called without parameters      | No |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: mysql-aria [-h] [-V] [--always-ok] [--defaults-file DEFAULTS_FILE]
                  [--defaults-group DEFAULTS_GROUP] [--timeout TIMEOUT]

Checks metrics of the Aria storage engine in MySQL/MariaDB, including page
cache read and write hit rates. Alerts when cache efficiency drops below
optimal levels.

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
./mysql-aria --defaults-file=/var/spool/icinga2/.my.cnf
```

Output:

```text
Aria pagecache size / total Aria indexes: 128.0MiB/328.0KiB, 97.2% Aria pagecache hit rate (1.1K cached / 30.0 reads)
```


## States

* WARN if `aria_pagecache_buffer_size` < total Aria indexes and the page cache hit rate is below 95%.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mysql_aria_pagecache_buffer_size | Bytes | The size of the buffer used for index and data blocks for Aria tables. |
| mysql_aria_pagecache_read_requests | Continous Counter | The number of requests to read something from the Aria page cache. |
| mysql_aria_pagecache_reads | Continous Counter | The number of Aria page cache read requests that caused a block to be read from the disk. |
| mysql_pct_aria_keys_from_mem | Percentage | aria_pagecache_reads / aria_pagecache_read_requests * 100 |
| mysql_total_aria_indexes | Bytes | Sum of all Aria index sizes. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:
    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
