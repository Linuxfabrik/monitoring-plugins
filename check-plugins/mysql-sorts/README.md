# Check mysql-sorts


## Overview

Checks sort operations in MySQL/MariaDB, including the rate of sort merge passes that required temporary disk files. A high rate of sort merge passes relative to total sorts indicates that `sort_buffer_size` and/or `read_rnd_buffer_size` may need to be increased.

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-MYSQL.md)

**Data Collection:**

* Queries `SHOW GLOBAL VARIABLES` for `read_rnd_buffer_size` and `sort_buffer_size`
* Queries `SHOW GLOBAL STATUS` for `Sort_merge_passes`, `Sort_range`, and `Sort_scan`
* Calculates the total number of sorts and the percentage that required temporary tables
* Logic is taken from [MySQLTuner script](https://github.com/major/MySQLTuner-perl):mysql_stats(), v1.9.8


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-sorts> |
| Nagios/Icinga Check Name              | `check_mysql_sorts` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: mysql-sorts [-h] [-V] [--always-ok] [--defaults-file DEFAULTS_FILE]
                   [--defaults-group DEFAULTS_GROUP] [--timeout TIMEOUT]

Checks sort operations in MySQL/MariaDB, including the rate of sort merge
passes that required temporary disk files. A high rate indicates that
sort_buffer_size may need to be increased. Alerts when the disk-based sort
rate is too high.

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
./mysql-sorts --defaults-file=/var/spool/icinga2/.my.cnf
```

Output:

```text
901.6K sorts used a full table scan. Sorts requiring temporary tables: 0% (0.0 temp sorts / 3.1M sorts).
```


## States

* WARN if more than 10% of sorts required temporary tables (sort merge passes).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mysql_pct_temp_sort_table | Percentage | sort_merge_passes / total_sorts * 100 |
| mysql_read_rnd_buffer_size | Bytes | Size in bytes of the buffer used when reading rows from a MyISAM table in sorted order after a key sort. |
| mysql_sort_buffer_size | Bytes | Each session performing a sort allocates a buffer with this amount of memory. Not specific to any storage engine. |
| mysql_sort_merge_passes | Continous Counter | Number of merge passes performed by the sort algorithm. |
| mysql_sort_range | Continous Counter | Number of sorts which used a range. |
| mysql_sort_scan | Continous Counter | Number of sorts which used a full table scan. |
| mysql_total_sorts | Continous Counter | sort_scan + sort_range |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:
    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
