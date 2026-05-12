# Check mysql-perf-metrics


## Overview

Checks MySQL/MariaDB best-practice knobs that do not have a dedicated plugin: `innodb_stats_on_metadata`, `concurrent_insert`, and any deprecated configuration variables that the admin has explicitly set. The OK output lists each verified value so admins immediately see what was checked.

* `innodb_stats_on_metadata`: when ON, InnoDB recalculates index statistics every time `information_schema` tables are queried. Most modern setups keep this OFF because applications and tooling query `information_schema` frequently.
* `concurrent_insert`: when set to `NEVER`/`0`, MyISAM tables can no longer serve SELECTs in parallel with INSERTs. The recommended value is `AUTO` (the modern default).
* Deprecated configuration variables: MariaDB keeps deprecated startup variables in `SHOW VARIABLES` as no-ops for the full LTS support window (5+ years) per its [feature deprecation policy](https://mariadb.com/docs/release-notes/community-server/about/feature-deprecation-policy). The plugin alerts only when such a variable was explicitly set via `my.cnf` or `SET GLOBAL` (`GLOBAL_VALUE_ORIGIN` in `INFORMATION_SCHEMA.SYSTEM_VARIABLES` not equal to `COMPILE-TIME`). Compile-time defaults stay silent. On MySQL, the plugin walks a list of known removed variables (ported from MySQLTuner v2.8.41) and filters them through `performance_schema.variables_info.VARIABLE_SOURCE` so only non-`COMPILED` values surface.

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-mysql/)

**Data Collection:**

* Reads all global variables once via `SHOW GLOBAL VARIABLES`.
* On MariaDB, queries `INFORMATION_SCHEMA.SYSTEM_VARIABLES` for entries whose `VARIABLE_COMMENT` contains "Deprecated" and `GLOBAL_VALUE_ORIGIN` is `CONFIG` or `SQL`.
* On MySQL 8.0+, queries `performance_schema.variables_info` to read `VARIABLE_SOURCE` and skip compile-time defaults from the static deprecated-variable list.
* Logic is taken from [MySQLTuner script](https://github.com/major/MySQLTuner-perl):check_metadata_perf(), the `concurrent_insert` check in `mysql_stats()` and `check_removed_innodb_variables()`, verified in sync with v2.8.41.


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

Checks MySQL/MariaDB best-practice knobs that do not have a dedicated plugin:
`innodb_stats_on_metadata`, `concurrent_insert`, and any deprecated
configuration variables that the admin has explicitly set via `my.cnf` or `SET
GLOBAL`. `innodb_stats_on_metadata`: when ON, InnoDB recalculates index
statistics every time `information_schema` tables are queried. Most modern
setups keep this OFF because applications and tooling query
`information_schema` frequently. `concurrent_insert`: when set to `NEVER`/`0`,
MyISAM tables can no longer serve SELECTs in parallel with INSERTs. The
recommended value is `AUTO` (the modern default). Deprecated variables:
MariaDB exposes its own deprecation flag at runtime
(`INFORMATION_SCHEMA.SYSTEM_VARIABLES.VARIABLE_COMMENT` +
`GLOBAL_VALUE_ORIGIN`); MySQL does not, so a static list ported from
MySQLTuner v2.8.41 is used and filtered through
`performance_schema.variables_info.VARIABLE_SOURCE` to skip compile-time
defaults. The check only fires when the variable's value did NOT come from
`COMPILE-TIME`, so a fresh installation stays quiet and only real `my.cnf`
leftovers and explicit `SET GLOBAL` changes are surfaced.

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
`innodb_stats_on_metadata` is `ON` [WARNING]. `concurrent_insert` is `NEVER` [WARNING]. 2 deprecated config variables explicitly set (`old_passwords`, `tx_isolation`) [WARNING].

Recommendations:
* Set `innodb_stats_on_metadata` = `OFF` so InnoDB stops refreshing index statistics on every `information_schema` query
* Set `concurrent_insert` = `AUTO` (or `ALWAYS`) so MyISAM tables can serve SELECTs in parallel with INSERTs
* Remove `old_passwords` from your `/etc/my.cnf.d/*.cnf` (source `CONFIG`; Deprecated parameter with no effect)
* Remove `tx_isolation` from your `/etc/my.cnf.d/*.cnf` (source `CONFIG`; This variable is deprecated and will be removed in a future release.)
```


## States

* WARN if `innodb_stats_on_metadata` is `ON`.
* WARN if `concurrent_insert` is `NEVER` / `0` / `OFF`.
* WARN if any deprecated configuration variable was explicitly set (via `my.cnf` or `SET GLOBAL`). Compile-time defaults stay silent.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

Both knobs are emitted as numeric perfdata so config drift is visible in Grafana and Icinga's perfdata thresholds light up the bad value automatically. Encoding:

| Name | Type | Description |
|----|----|----|
| mysql_concurrent_insert | Number | `0` = `NEVER` (warn), `1` = `AUTO`, `2` = `ALWAYS`. |
| mysql_deprecated_config_variables | Number | Count of deprecated configuration variables that were explicitly set via `my.cnf` or `SET GLOBAL`. Compile-time defaults are not counted. |
| mysql_innodb_stats_on_metadata | Number | `0` = `OFF`, `1` = `ON` (warn). |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:
    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
