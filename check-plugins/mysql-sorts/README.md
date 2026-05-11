# Check mysql-sorts


## Overview

Checks how often MySQL/MariaDB sorts have to spill from memory to a temporary merge-sort file (`Sort_merge_passes` / (`Sort_scan` + `Sort_range`)). A high ratio means `sort_buffer_size` and/or `read_rnd_buffer_size` are too small for the workload's typical sort.

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-mysql/)

**Data Collection:**

* Queries `SHOW GLOBAL VARIABLES` for `read_rnd_buffer_size` and `sort_buffer_size`.
* Queries `SHOW GLOBAL STATUS` for `Sort_merge_passes`, `Sort_range`, and `Sort_scan`.
* Calculates the total number of sorts and the percentage that spilled to a temporary merge-sort file.
* `Sort_scan`, `Sort_range` and `Sort_merge_passes` are written to a local SQLite cache so the plugin can compute per-second rates instead of emitting cumulative counters that force Grafana panels to do `non_negative_difference()` themselves.
* Logic is taken from [MySQLTuner script](https://github.com/major/MySQLTuner-perl):mysql_stats() (the "Sorting" section), verified in sync with v2.8.41.


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
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-monitoring-plugins-mysql-sorts.db` |


## Help

```text
usage: mysql-sorts [-h] [-V] [--always-ok] [-c CRITICAL]
                   [--defaults-file DEFAULTS_FILE]
                   [--defaults-group DEFAULTS_GROUP] [--timeout TIMEOUT]
                   [-w WARNING]

Checks how often MySQL/MariaDB sorts have to spill from memory to a temporary
merge-sort file (`Sort_merge_passes` / (`Sort_scan` + `Sort_range`)). A high
ratio means `sort_buffer_size` and/or `read_rnd_buffer_size` are too small for
the workload's typical sort. Alerts when the ratio crosses `--warning` /
`--critical`.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRITICAL
                        Percentage of sorts that spilled to a temporary merge-
                        sort file at which the ratio flips to CRITICAL.
                        Default: 20
  --defaults-file DEFAULTS_FILE
                        MySQL/MariaDB cnf file to read user, host and password
                        from. Example: `--defaults-
                        file=/var/spool/icinga2/.my.cnf`. Default:
                        /var/spool/icinga2/.my.cnf
  --defaults-group DEFAULTS_GROUP
                        Group/section to read from in the cnf file. Default:
                        client
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -w, --warning WARNING
                        Percentage of sorts that spilled to a temporary merge-
                        sort file at which the ratio flips to WARNING.
                        Default: 10
```


## Usage Examples

```bash
./mysql-sorts --defaults-file=/var/spool/icinga2/.my.cnf
```

Output (OK):

```text
Everything is ok. Sorts requiring a temporary merge-sort file: 0.5% (5.0 temp sorts / 1.0K sorts). Components: `Sort_scan` = 600.0, `Sort_range` = 400.0.
```

Output (WARN):

```text
Sorts requiring a temporary merge-sort file: 15.0% (15.0 temp sorts / 100.0 sorts) [WARNING]. Components: `Sort_scan` = 60.0, `Sort_range` = 40.0.

Recommendations:
* Raise `sort_buffer_size` > 256.0KiB and/or `read_rnd_buffer_size` > 256.0KiB so fewer sorts have to spill to a temporary merge-sort file
```


## States

* WARN when `Sort_merge_passes` / (`Sort_scan` + `Sort_range`) reaches `--warning` (default 10%); CRIT at `--critical` (default 20%).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

The three cumulative counters (`Sort_scan`, `Sort_range`, `Sort_merge_passes`) and the derived total are emitted as in-plugin-computed per-second rates instead of `uom='c'` continuous counters; the deltas appear from the second check run onwards (the first run needs a baseline in the local SQLite cache).

| Name | Type | Description |
|----|----|----|
| mysql_pct_temp_sort_table | Percentage | `Sort_merge_passes / (Sort_scan + Sort_range) * 100`. |
| mysql_read_rnd_buffer_size | Bytes | Size in bytes of the buffer used when reading rows from a MyISAM table in sorted order after a key sort. |
| mysql_sort_buffer_size | Bytes | Each session performing a sort allocates a buffer with this amount of memory. Not specific to any storage engine. |
| mysql_sort_merge_passes_per_second | Number | Per-second rate of `Sort_merge_passes` since the previous check run. |
| mysql_sort_range_per_second | Number | Per-second rate of `Sort_range` since the previous check run. |
| mysql_sort_scan_per_second | Number | Per-second rate of `Sort_scan` since the previous check run. |
| mysql_total_sorts_per_second | Number | Per-second rate of `Sort_scan` + `Sort_range` since the previous check run. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:
    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
