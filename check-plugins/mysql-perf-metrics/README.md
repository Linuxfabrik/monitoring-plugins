# Check mysql-perf-metrics


## Overview

Checks two MySQL/MariaDB best-practice knobs that do not have a dedicated plugin: `innodb_stats_on_metadata` and `concurrent_insert`. The OK output now lists both verified values so admins immediately see what was checked.

* `innodb_stats_on_metadata`: when ON, InnoDB recalculates index statistics every time `information_schema` tables are queried. Most modern setups keep this OFF because applications and tooling query `information_schema` frequently.
* `concurrent_insert`: when set to `NEVER`/`0`, MyISAM tables can no longer serve SELECTs in parallel with INSERTs. The recommended value is `AUTO` (the modern default).

The `innodb_file_per_table` knob is covered by the `mysql-innodb-buffer-pool-size` check; this plugin no longer duplicates it.

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-mysql/)

**Data Collection:**

* Queries `SHOW GLOBAL VARIABLES` for `innodb_stats_on_metadata` and `concurrent_insert`.
* Logic is taken from [MySQLTuner script](https://github.com/major/MySQLTuner-perl):check_metadata_perf() and the `concurrent_insert` check in `mysql_stats()`, verified in sync with v2.8.41.


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-perf-metrics> |
| Nagios/Icinga Check Name              | `check_mysql_perf_metrics` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: mysql-perf-metrics [-h] [-V] [--always-ok]
                          [--defaults-file DEFAULTS_FILE]
                          [--defaults-group DEFAULTS_GROUP]
                          [--timeout TIMEOUT]

Checks two MySQL/MariaDB best-practice knobs that do not have a dedicated
plugin: `innodb_stats_on_metadata` and `concurrent_insert`. Alerts when either
is set to a value that slows down typical workloads.
`innodb_stats_on_metadata`: when ON, InnoDB recalculates index statistics
every time `information_schema` tables are queried. Most modern setups keep
this OFF because applications and tooling query `information_schema`
frequently. `concurrent_insert`: when set to `NEVER`/`0`, MyISAM tables can no
longer serve SELECTs in parallel with INSERTs. The recommended value is `AUTO`
(the modern default). The `innodb_file_per_table` knob is covered by the
`mysql-innodb-buffer-pool-size` check; this plugin no longer duplicates it.

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
./mysql-perf-metrics --defaults-file=/var/spool/icinga2/.my.cnf
```

Output (OK):

```text
Everything is ok. `innodb_stats_on_metadata` is `OFF`. `concurrent_insert` is `AUTO`.
```

Output (WARN):

```text
`innodb_stats_on_metadata` is `ON` [WARNING]. `concurrent_insert` is `NEVER` [WARNING].

Recommendations:
* Set `innodb_stats_on_metadata` = `OFF` so InnoDB stops refreshing index statistics on every `information_schema` query
* Set `concurrent_insert` = `AUTO` (or `ALWAYS`) so MyISAM tables can serve SELECTs in parallel with INSERTs
```


## States

* WARN if `innodb_stats_on_metadata` is `ON`.
* WARN if `concurrent_insert` is `NEVER` / `0` / `OFF`.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

Both knobs are emitted as numeric perfdata so config drift is visible in Grafana and Icinga's perfdata thresholds light up the bad value automatically. Encoding:

| Name | Type | Description |
|----|----|----|
| mysql_concurrent_insert | Number | `0` = `NEVER` (warn), `1` = `AUTO`, `2` = `ALWAYS`. |
| mysql_innodb_stats_on_metadata | Number | `0` = `OFF`, `1` = `ON` (warn). |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:
    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
