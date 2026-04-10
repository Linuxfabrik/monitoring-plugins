# Check mysql-innodb-buffer-pool-instances

## Overview

Checks the InnoDB buffer pool instance configuration in MySQL/MariaDB. The number of buffer pool instances should follow best practices based on the total buffer pool size: 1 instance if the buffer pool is <= 1 GiB, otherwise 1 instance per GiB (up to a maximum of 64).

**Data Collection:**

* Queries `SHOW GLOBAL VARIABLES` for `innodb_buffer_pool_instances` and `innodb_buffer_pool_size`
* Checks the InnoDB storage engine availability before proceeding
* Logic is taken from [MySQLTuner script](https://github.com/major/MySQLTuner-perl):mysql_innodb(), v1.9.8

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-MYSQL.md)
* `innodb_buffer_pool_instances` was removed in MariaDB 10.6.0. If the variable is not present, the check reports "Everything is ok (although nothing checked)."



**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-innodb-buffer-pool-instances> |
| Nagios/Icinga Check Name              | `check_mysql_innodb_buffer_pool_instances` |
| Check Interval Recommendation         | Once a day |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: mysql-innodb-buffer-pool-instances [-h] [-V] [--always-ok]
                                          [--defaults-file DEFAULTS_FILE]
                                          [--defaults-group DEFAULTS_GROUP]
                                          [--timeout TIMEOUT]

Checks the InnoDB buffer pool instance configuration in MySQL/MariaDB. Alerts
if the configuration does not follow best practices for the given buffer pool
size.

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
./mysql-innodb-buffer-pool-instances --defaults-file=/var/spool/icinga2/.my.cnf
```

Output:

```text
8 InnoDB buffer pool instances. innodb_buffer_pool_size <= 1G and innodb_buffer_pool_instances !=1 [WARNING]. Set innodb_buffer_pool_instances to 1.
```


## States

* WARN if `innodb_buffer_pool_instances` > 64.
* WARN if `innodb_buffer_pool_size` > 1 GiB and `innodb_buffer_pool_instances` does not match `min(innodb_buffer_pool_size in GiB, 64)`.
* WARN if `innodb_buffer_pool_size` <= 1 GiB and `innodb_buffer_pool_instances` is not 1.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mysql_innodb_buffer_pool_instances | Number | Number of InnoDB buffer pool instances. Divides the buffer pool into this many separate regions to reduce contention. |
| mysql_innodb_buffer_pool_size | Bytes | InnoDB buffer pool size in bytes. The primary value to adjust on a database server with entirely/primarily InnoDB tables, can be set up to 80% of the total memory. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:
    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
