# Check mysql-perf-metrics


## Overview

Checks MySQL/MariaDB best-practice knobs that do not have a dedicated plugin: `innodb_stats_on_metadata`, `concurrent_insert`, and any deprecated configuration variables that the admin has explicitly set. The OK output lists each verified value so admins immediately see what was checked.

* `innodb_stats_on_metadata`: when ON, InnoDB recalculates index statistics every time `information_schema` tables are queried. Most modern setups keep this OFF because applications and tooling query `information_schema` frequently.
* `concurrent_insert`: when set to `NEVER`/`0`, MyISAM tables can no longer serve SELECTs in parallel with INSERTs. `AUTO` is the modern default.
* Deprecated configuration variables: MariaDB keeps deprecated startup variables in `SHOW VARIABLES` as no-ops for the full LTS support window (5+ years) per its [feature deprecation policy](https://mariadb.com/docs/release-notes/community-server/about/feature-deprecation-policy). The plugin alerts only when such a variable was explicitly set via `my.cnf` or `SET GLOBAL` (`GLOBAL_VALUE_ORIGIN` in `INFORMATION_SCHEMA.SYSTEM_VARIABLES` not equal to `COMPILE-TIME`). Compile-time defaults stay silent. On MySQL, the plugin walks a list of known removed variables (ported from MySQLTuner) and filters them through `performance_schema.variables_info.VARIABLE_SOURCE` so only non-`COMPILED` values surface.

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
                          [--storage-type {auto,ssd,hdd,skip}]
                          [--timeout TIMEOUT]

Audits MySQL/MariaDB configuration knobs that have a measurable impact on
performance or correctness but no metric of their own. Highlights settings
that silently waste work on tooling-heavy hosts, drop a transaction-isolation
guarantee an admin probably expected, are tuned for the wrong storage class,
or hang on as no-op leftovers in `my.cnf` until the next major upgrade refuses
to start with them. What gets checked: - `innodb_stats_on_metadata`: when ON,
InnoDB refreshes index statistics on every `information_schema` query. Hosts
with frequent dashboard, backup and monitoring queries pay a noticeable CPU
cost for this. - `concurrent_insert`: when set to `NEVER` / `0`, MyISAM tables
can no longer serve SELECTs in parallel with INSERTs. `AUTO` is the modern
default. - `innodb_snapshot_isolation` (MariaDB only): under `REPEATABLE-
READ`, OFF lets a transaction see writes other transactions commit during its
lifetime, breaking the stable-snapshot guarantee the name `REPEATABLE-READ`
implies. ON makes the snapshot stable. Default flipped to ON in MariaDB 11.8;
before that, the admin had to opt in. Other isolation levels and non-MariaDB
servers skip this check. - `innodb_flush_neighbors`: HDD wins from grouping
seek-adjacent dirty-page flushes, SSD/NVMe pays in extra writes for no latency
benefit, so the right value depends on the storage class. -
`innodb_io_capacity`: caps InnoDB's background flushing rate and should be
sized to the disk's measured IOPS. Only checked when `--storage-type=ssd` is
passed explicitly: the storage auto-detection cannot be trusted on virtualised
or network-backed disks (Ceph, cloud volumes) where a slow device still
reports as non-rotational. - Deprecated configuration variables explicitly set
via `my.cnf` or `SET GLOBAL`. The server tolerates these as no-ops, so they
hide easily until the next major upgrade ships without them. Compile-time
defaults are silent. MariaDB exposes a runtime deprecation flag; on MySQL a
static list filtered through
`performance_schema.variables_info.VARIABLE_SOURCE` catches the same cases.
The storage-aware checks need to know the disk type. `innodb_flush_neighbors`
uses auto-detection (it reads `/sys/block/*/queue/rotational` on the host the
plugin runs on; `0` is the safe value on any non-seeking storage, so a misread
costs nothing). `innodb_io_capacity` is only checked when `--storage-type=ssd`
is passed explicitly, because the rotational flag reports `0` for virtio, RBD
and emulated-NVMe devices regardless of the real backing store: a database on
HDD-backed Ceph or a throttled cloud volume would be misread as fast local
storage and told to raise the value, which can swamp a low-IOPS device. Pass
`--storage-type=ssd` or `--storage-type=hdd` to override the auto-detection,
or `--storage-type=skip` to disable the storage-aware checks entirely.

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
  --storage-type {auto,ssd,hdd,skip}
                        Storage type of the MySQL data directory. Drives the
                        `innodb_flush_neighbors` and `innodb_io_capacity`
                        checks. `auto` reads `/sys/block/*/queue/rotational`
                        on the same host and feeds `innodb_flush_neighbors`
                        only; `ssd` or `hdd` overrides the detection (use when
                        running from a remote monitoring host via TCP, or on
                        virtualised/network-backed storage such as Ceph or
                        cloud volumes where the rotational flag is
                        unreliable); `skip` disables both storage-type checks
                        entirely. The `innodb_io_capacity` check only runs
                        when `ssd` is set explicitly. Example: `--storage-
                        type=ssd`. Default: auto
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
