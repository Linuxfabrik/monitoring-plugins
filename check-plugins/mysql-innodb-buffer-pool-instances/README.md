# Check mysql-innodb-buffer-pool-instances


## Overview

Checks the InnoDB buffer pool instance configuration in MySQL/MariaDB. The number of buffer pool instances should follow these rules: 1 instance if `innodb_buffer_pool_size <= 1 GiB`, otherwise 1 instance per GiB - capped by the number of logical CPU cores on the host running the plugin and by the hard upper bound of 64.

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-mysql/)
* `innodb_buffer_pool_instances` was deprecated in MariaDB 10.4 and removed entirely in MariaDB 10.6. The plugin reports OK with an info message and skips the check on MariaDB 10.4+.
* The CPU-core cap uses `os.cpu_count()` on the **host running the plugin**. Most Linuxfabrik MySQL plugins are invoked via the local Icinga agent on the DB host, in which case this matches the DB-host CPU count. On remote invocations the cap reflects the monitoring host instead.
* The InnoDB engine is the MariaDB default since 10.0; if it is genuinely not present or disabled, the plugin reports OK with an info message instead of UNKNOWN.

**Data Collection:**

* Queries `SHOW GLOBAL VARIABLES` for `innodb_buffer_pool_instances`, `innodb_buffer_pool_size`, `version` and `version_comment`
* Reads `os.cpu_count()` for the CPU-core cap
* Logic is taken from [MySQLTuner](https://github.com/major/MySQLTuner-perl):mysql_innodb() and has been verified in sync with MySQLTuner v2.8.41


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-innodb-buffer-pool-instances> |
| Nagios/Icinga Check Name              | `check_mysql_innodb_buffer_pool_instances` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: mysql-innodb-buffer-pool-instances [-h] [-V] [--always-ok]
                                          [--defaults-file DEFAULTS_FILE]
                                          [--defaults-group DEFAULTS_GROUP]
                                          [--timeout TIMEOUT]

Checks the InnoDB buffer pool instance configuration in MySQL/MariaDB. Alerts
if the configured `innodb_buffer_pool_instances` differs from the recommended
value (one instance per GiB of `innodb_buffer_pool_size`, capped by the number
of logical CPU cores and by the hard upper bound of 64). Skipped on MariaDB
10.4+ where the variable was deprecated and removed.

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
`innodb_buffer_pool_instances` = 8 (`innodb_buffer_pool_size` = 128.0MiB). Recommendation: set `innodb_buffer_pool_instances` = 1.
```

When the recommendation is capped by the CPU-core count (e.g. a 32 GiB buffer on a 4-core host):

```text
`innodb_buffer_pool_instances` = 8 (`innodb_buffer_pool_size` = 32.0GiB). Recommendation: set `innodb_buffer_pool_instances` = 4, capped at 4 logical CPU cores.
```

When the configuration matches the recommendation:

```text
innodb_buffer_pool_instances = 4 (innodb_buffer_pool_size = 4.0GiB). Matches the recommended value.
```

On MariaDB 10.4+:

```text
`innodb_buffer_pool_instances` is deprecated since MariaDB 10.4 and removed since MariaDB 10.6 (this server reports MariaDB 11.4); skipping.
```


## States

* WARN if `innodb_buffer_pool_instances` differs from the recommended value (`min(innodb_buffer_pool_size in GiB, logical CPU cores, 64)`, or 1 when the buffer pool is `<= 1 GiB`).
* OK on MariaDB 10.4+ (variable deprecated/removed).
* OK if InnoDB is not available or is disabled.
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
