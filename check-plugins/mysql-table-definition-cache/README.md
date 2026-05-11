# Check mysql-table-definition-cache


## Overview

Checks the table definition cache size in MySQL/MariaDB against the current total number of tables in `information_schema.tables`. When `table_definition_cache` is smaller than the table count, definitions get evicted and re-read on each access, which costs `.frm` parses on disk-heavy workloads. Logic taken from [MySQLTuner](https://github.com/major/MySQLTuner-perl):mysql_stats() and verified in sync with MySQLTuner v2.8.41.

**Important Notes:**

* Requires MySQL/MariaDB v5.1+
* See [additional notes for all mysql monitoring plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-mysql/)
* On MySQL 5.6+ / MariaDB 10.0+ `table_definition_cache = -1` enables autosizing; the plugin reports that as state OK with an info message
* User account requires access to `INFORMATION_SCHEMA` (user with no privileges is sufficient) and SELECT privileges on all schemas and tables to provide accurate results
* [For most INFORMATION_SCHEMA tables, each MySQL user has the right to access them, but can see only the rows in the tables that correspond to objects for which the user has the proper access privileges.](https://dev.mysql.com/doc/refman/5.7/en/information-schema-introduction.html#information-schema-privileges) [So you can't grant permission to INFORMATION_SCHEMA directly, you have to grant SELECT permission to the tables on your own schemas, and as you do, those tables will start showing up in INFORMATION_SCHEMA queries.](https://stackoverflow.com/questions/60499772/cannot-grant-mysql-user-access-to-information-schema-database)

**Data Collection:**

* Queries `SHOW GLOBAL VARIABLES` for `table_definition_cache`
* Counts total tables via `SELECT COUNT(*) FROM information_schema.tables`


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-table-definition-cache> |
| Nagios/Icinga Check Name              | `check_mysql_table_definition_cache` |
| Check Interval Recommendation         | Every hour |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Requirements                          | User with `SELECT` privilege (typically `GRANT SELECT ON *.*`), locked down to `127.0.0.1` - for example `monitoring\@127.0.0.1`. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions. |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: mysql-table-definition-cache [-h] [-V] [--always-ok]
                                    [--defaults-file DEFAULTS_FILE]
                                    [--defaults-group DEFAULTS_GROUP]
                                    [--timeout TIMEOUT]

Checks the table definition cache size in MySQL/MariaDB against the current
total number of tables in `information_schema.tables`. When
`table_definition_cache` is smaller than the table count, definitions get
evicted and re-read on each access, which costs `.frm` parses on disk-heavy
workloads. Alerts when `table_definition_cache` is below the total table
count. On MySQL 5.6+ / MariaDB 10.0+ `table_definition_cache = -1` enables
autosizing; the plugin reports that as informational, state OK.

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
./mysql-table-definition-cache --defaults-file=/var/spool/icinga2/.my.cnf
```

OK output:

```text
Everything is ok. `table_definition_cache` (2000) is greater than the number of tables (516).
```

WARN output:

```text
`table_definition_cache` (400) is less than the number of tables (516) [WARNING].

Recommendations:
* Raise `table_definition_cache` above 516, or set it to `-1` to let the server autosize the cache (MySQL 5.6+ / MariaDB 10.0+)
```


## States

* WARN if `table_definition_cache` is below the total number of tables.
* OK if `table_definition_cache >= total_tables`, or if `table_definition_cache = -1` (autosizing).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mysql_table_definition_cache | Number | Number of table definitions that can be cached. `-1` (autosizing) is reported as `0` so the metric stays on a meaningful 0-based scale; the actual setting is in the plugin output. |
| mysql_total_tables | Number | Total number of tables. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:

    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
