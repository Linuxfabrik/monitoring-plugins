# Check mysql-aria


## Overview

Checks metrics of the Aria storage engine in MariaDB, including the page cache size relative to total Aria index size and the page cache hit rate. Aria is the crash-safe, non-transactional storage engine used for internal temporary tables in MariaDB. It is not shipped with MySQL or Percona Server.

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-mysql/)
* User account requires access to INFORMATION_SCHEMA (user with no privileges is sufficient) and SELECT privileges on all schemas and tables to provide accurate results
* [For most INFORMATION_SCHEMA tables, each MySQL user has the right to access them, but can see only the rows in the tables that correspond to objects for which the user has the proper access privileges.](https://dev.mysql.com/doc/refman/5.7/en/information-schema-introduction.html#information-schema-privileges) [So you can't grant permission to INFORMATION_SCHEMA directly, you have to grant SELECT permission to the tables on your own schemas, and as you do, those tables will start showing up in INFORMATION_SCHEMA queries.](https://stackoverflow.com/questions/60499772/cannot-grant-mysql-user-access-to-information-schema-database)
* "total Aria indexes: 0.0B" means that there are no Aria-based tables at all, or the user performing the check does not have SELECT privileges on them

**Data Collection:**

* Queries `SHOW GLOBAL VARIABLES` for `aria_pagecache_buffer_size`
* Queries `SHOW GLOBAL STATUS` for `Aria_pagecache_reads` and `Aria_pagecache_read_requests`
* Queries `information_schema.tables` to sum all Aria index sizes
* Logic is taken from [MySQLTuner](https://github.com/major/MySQLTuner-perl):mariadb_aria() and has been verified in sync with MySQLTuner v2.8.41


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-aria> |
| Nagios/Icinga Check Name              | `check_mysql_aria` |
| Check Interval Recommendation         | Every hour |
| Can be called without parameters      | No |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Requirements                          | User with `SELECT` privilege (typically `GRANT SELECT ON *.*`), locked down to `127.0.0.1` - for example `monitoring\@127.0.0.1`. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions. |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: mysql-aria [-h] [-V] [--always-ok] [--defaults-file DEFAULTS_FILE]
                  [--defaults-group DEFAULTS_GROUP] [--timeout TIMEOUT]

Checks metrics of the Aria storage engine in MySQL/MariaDB, including the
page-cache hit rate. Alerts when cache efficiency drops below optimal levels.

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

When the hit rate dips below 95% but `aria_pagecache_buffer_size` is already larger than the sum of all Aria index sizes (so growing it would not help), the plugin stays OK and explains why:

```text
Total Aria indexes: 352.0KiB, Aria pagecache size: 128.0MiB; 90.5% Aria pagecache hit rate (571.1K cached / 54.5K reads). Note: aria_pagecache_buffer_size (128.0MiB) already exceeds the sum of all Aria index sizes (352.0KiB), so growing aria_pagecache_buffer_size further would not help the sub-95% hit rate.
```


## States

* WARN if `aria_pagecache_buffer_size` < total Aria indexes **and** the page cache hit rate is below 95%. Either condition alone is informational. If the cache is already larger than the indexes, a sub-95% hit rate is not actionable (mysqltuner alerts on the standalone hit rate; we deliberately do not).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mysql_aria_pagecache_buffer_size | Bytes | The size of the buffer used for index and data blocks for Aria tables. |
| mysql_aria_pagecache_read_requests_per_second | Number | Per-second rate of read requests against the Aria page cache. Only emitted from the second run onwards (the plugin keeps a small SQLite cache between runs to compute the delta in-plugin instead of using a continuous counter). |
| mysql_aria_pagecache_reads_per_second | Number | Per-second rate of Aria page cache read requests that caused a physical disk read. Only emitted from the second run onwards. |
| mysql_pct_aria_keys_from_mem | Percentage | (1 - Aria_pagecache_reads / Aria_pagecache_read_requests) * 100, computed from the cumulative MySQL/MariaDB counters. |
| mysql_total_aria_indexes | Bytes | Sum of all Aria index sizes. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:
    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
