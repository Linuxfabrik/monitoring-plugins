# Check mysql-database-metrics


## Overview

Checks index sizes, fragmentation, and consistent engine and collation usage across all schemas in MySQL/MariaDB. Detects schemas where mixed storage engines, collations, charsets, or table engines are in use, which can indicate configuration drift or migration issues.

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-MYSQL.md)
* User account requires access to INFORMATION_SCHEMA (user with no privileges is sufficient) and SELECT privileges on all schemas and tables to provide accurate results
* [For most INFORMATION_SCHEMA tables, each MySQL user has the right to access them, but can see only the rows in the tables that correspond to objects for which the user has the proper access privileges.](https://dev.mysql.com/doc/refman/5.7/en/information-schema-introduction.html#information-schema-privileges) [So you can't grant permission to INFORMATION_SCHEMA directly, you have to grant SELECT permission to the tables on your own schemas, and as you do, those tables will start showing up in INFORMATION_SCHEMA queries.](https://stackoverflow.com/questions/60499772/cannot-grant-mysql-user-access-to-information-schema-database)

**Data Collection:**

* Queries `information_schema.schemata` for all non-system schemas
* For each schema, queries `information_schema.tables` for row counts, data/index sizes, storage engine counts, and collation counts
* Queries `information_schema.COLUMNS` for distinct character sets and collations per schema
* Logic is taken from [MySQLTuner script](https://github.com/major/MySQLTuner-perl):mysql_databases(), v1.9.8


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-database-metrics> |
| Nagios/Icinga Check Name              | `check_mysql_database_metrics` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: mysql-database-metrics [-h] [-V] [--always-ok]
                              [--defaults-file DEFAULTS_FILE]
                              [--defaults-group DEFAULTS_GROUP]
                              [--timeout TIMEOUT]

Checks index sizes, fragmentation, and consistent engine and collation usage
across all schemas in MySQL/MariaDB. Alerts on mixed storage engines or
collations within a single schema.

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
./mysql-database-metrics --defaults-file=/var/spool/icinga2/.my.cnf
```

Output:

```text
There are warnings.

* Index size is larger than data size: xca (11.4MiB / 5.4MiB)
* Multi storage engines (use one storage engine for all tables): appldb (2x)
* Multi collations (use one collation for all tables): accounting (2x), piwik (2x), wordpress-www (2x)
* Multi table engines (use one engine for all tables): appldb (2x)
* Multi charsets for text-like cols (use one charset for all cols if possible): accounting (2x), piwik (2x), django-mvc (2x), wordpress-www (2x), django-mvc-devel (2x)
* Multi collations for text-like cols (use one charset for all cols if possible): accounting (3), piwik (2x), django-mvc (2x), wordpress-www (2x), django-mvc-devel (2x)
```


## States

* WARN if the index size is larger than the data size (if at least one of them exceeds 10 MiB).
* WARN if more than one storage engine is used within a schema.
* WARN if more than one collation is used within a schema.
* WARN if more than one table engine is used within a schema.
* WARN if more than one charset for text-like columns is used within a schema.
* WARN if more than one collation for text-like columns is used within a schema.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:
    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
