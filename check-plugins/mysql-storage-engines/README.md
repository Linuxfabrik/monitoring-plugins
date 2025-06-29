# Check mysql-storage-engines

## Overview

Checks storage engines, fragmented tables and autoindex usage in MySQL/MariaDB. Logic is taken from [MySQLTuner script](https://github.com/major/MySQLTuner-perl).

User account requires:

* Access to INFORMATION_SCHEMA (user with no privileges is sufficient).
* SELECT privileges on all schemas and tables to provide accurate results.

Hints:

* See [additional notes for all mysql monitoring plugins](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-MYSQL.rst)
* [For most INFORMATION_SCHEMA tables, each MySQL user has the right to access them, but can see only the rows in the tables that correspond to objects for which the user has the proper access privileges.](https://dev.mysql.com/doc/refman/5.7/en/information-schema-introduction.html#information-schema-privileges). [So you can't grant permission to INFORMATION_SCHEMA directly, you have to grant SELECT permission to the tables on your own schemas, and as you do, those tables will start showing up in INFORMATION_SCHEMA queries](https://stackoverflow.com/questions/60499772/cannot-grant-mysql-user-access-to-information-schema-database). Then this check provide correct results.
* Requires MySQL/MariaDB v5.5+.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-storage-engines> |
| Check Interval Recommendation         | Once a day |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: mysql-storage-engines [-h] [-V] [--always-ok]
                             [--defaults-file DEFAULTS_FILE]
                             [--defaults-group DEFAULTS_GROUP]
                             [--timeout TIMEOUT]

Checks storage engines, fragmented tables and autoindex usage in
MySQL/MariaDB.

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
./mysql-storage-engines --defaults-file=/var/spool/icinga2/.my.cnf
```

Output:

```text
There are warnings.

* 1 fragmented table
* OPTIMIZE TABLE `backup20190815`.`docs`; -- can free 2.6GiB
* Total freed space after all OPTIMIZE TABLEs: 2.6GiB
* accounting.contact has an autoincrement value near max capacity (97.0%)
```


## States

* WARN if InnoDB is enabled but isn't being used
* WARN if BDB is enabled but isn't being used
* WARN if MYISAM is enabled but isn't being used
* WARN if fragmented tables are found
* WARN if a table's autoincrement value is \>= 75% max capacity


## Perfdata / Metrics

There is no perfdata.


## Troubleshooting

InnoDB is enabled but isn't being used. Add skip-innodb to MySQL configuration to disable InnoDB  
But InnoDB is enabled? You must use a user with the sufficiently high permissions to access the MySQL/MariaDB internals for this check to work properly.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)

* License: The Unlicense, see [LICENSE file](https://unlicense.org/).

* Credits:

    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
