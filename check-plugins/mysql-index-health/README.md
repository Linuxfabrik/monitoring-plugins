# Check mysql-index-health


## Overview

Reports the two index-housekeeping findings that [MySQLTuner](https://github.com/major/MySQLTuner-perl):mysql_pfs() flags: unused indexes (never read since the last server start, listed in `sys.schema_unused_indexes`) and redundant indexes (a narrower index fully covered by a wider one, listed in `sys.schema_redundant_indexes`). Both views are populated by the Performance Schema; the plugin reports STATE_UNKNOWN with a clear hint when `performance_schema = OFF` (the MariaDB default).

The check is meant as a trip-wire only: when it alerts, run `mysqltuner --pfstat` on the host for the full analysis with remediation hints and ready-to-run `ALTER TABLE ... DROP INDEX` statements. The plugin itself does not duplicate mysqltuner's deep diagnostic output; it is sized for a once-a-day Icinga check, not a 60-second one (the underlying counters are cumulative since server start, so sub-daily sampling would add nothing).

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-mysql/)
* The plugin needs the Performance Schema. On MariaDB it is OFF by default; enable it with `performance_schema = ON` in `my.cnf` and restart the server. MySQL ships it ON by default
* `sys.schema_unused_indexes` and `sys.schema_redundant_indexes` exist in MySQL 5.7+ and MariaDB 10.6+
* Counters are cumulative since the last server start. Restarting the server resets them, so a freshly booted host may take a few hours before unused-index numbers settle (the query pattern needs time to exercise all indexes)
* System schemas (`mysql`, `information_schema`, `performance_schema`, `sys`) are excluded, matching the WHERE clause used by mysqltuner
* Index housekeeping is never a wake-up-at-night finding, so the plugin only emits WARN (and the implicit OK), never CRIT
* Output ships a ready-to-paste `ALTER TABLE ... DROP INDEX` statement per finding. `--lengthy` shows the full statement; the default truncates after 80 characters so the table stays readable in IcingaWeb
* Redundant indexes are safe to drop because the dominant index already covers every query the redundant one served. Unused indexes need verification first: "unused since last server start" can miss weekly or monthly jobs, recently restarted servers, and indexes that back foreign-key constraints. Wait at least one full business cycle before dropping

**Data Collection:**

* `SHOW GLOBAL VARIABLES LIKE 'performance_schema'` to detect the prerequisite
* `SELECT ... FROM sys.schema_unused_indexes` excluding the four server-managed schemas
* `SELECT ... FROM sys.schema_redundant_indexes` (already excludes server schemas internally)


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-index-health> |
| Nagios/Icinga Check Name              | `check_mysql_index_health` |
| Check Interval Recommendation         | Once a day |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Requirements                          | User with `SELECT` privilege on `*.*` (the `sys` views inherit from `performance_schema`). Performance Schema enabled on the server (MySQL: default; MariaDB: requires `performance_schema = ON` in `my.cnf` plus a restart). |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: mysql-index-health [-h] [-V] [--always-ok]
                          [--defaults-file DEFAULTS_FILE]
                          [--defaults-group DEFAULTS_GROUP] [--lengthy]
                          [--min-uptime-hours MIN_UPTIME_HOURS]
                          [--timeout TIMEOUT]
                          [--warning-redundant WARN_REDUNDANT]
                          [--warning-unused WARN_UNUSED]

Reports the two index-housekeeping findings that MySQLTuner v2.8.41 flags
inside its `mysql_pfs()` block: unused indexes (never read since the last
server start, listed in `sys.schema_unused_indexes`) and redundant indexes (a
narrower index fully covered by a wider one, listed in
`sys.schema_redundant_indexes`). Both views are populated by the Performance
Schema; the plugin reports STATE_UNKNOWN with a clear hint when
`performance_schema = OFF` (the MariaDB default). The check is meant as a
trip-wire only: when it alerts, run `mysqltuner --pfstat` on the host for the
full analysis with remediation hints and ready-to-run `ALTER TABLE ... DROP
INDEX` statements. System schemas (`mysql`, `information_schema`,
`performance_schema`, `sys`) are excluded. Counters are cumulative since
server start; restarting the server resets them, so the plugin stays silent
(STATE_OK with a wait hint) until server uptime crosses `--min-uptime-hours`
(default 24h). This avoids the false-clean signal right after a restart and
the false-positive "unused" signal that would fire before weekly or monthly
jobs have had a chance to touch their indexes. Index housekeeping is never a
wake-up-at-night finding, so the plugin only emits WARN (and the implicit OK),
never CRIT.

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
  --lengthy             Extended reporting.
  --min-uptime-hours MIN_UPTIME_HOURS
                        Minimum server uptime (in hours) before the plugin
                        starts evaluating findings. Performance Schema
                        counters reset on every server restart, so a freshly
                        booted server has no record of which indexes are read
                        or unused; alerting on that data would produce false
                        positives. Below the threshold the plugin reports OK
                        with an info hint. Example: `--min-uptime-hours=48`.
                        Default: 24
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  --warning-redundant WARN_REDUNDANT
                        WARN threshold for the number of matching items.
                        Applies to redundant indexes. Supports Nagios ranges.
                        Example: `--warning-redundant=10`. Default: 0
  --warning-unused WARN_UNUSED
                        WARN threshold for the number of matching items.
                        Applies to unused indexes. Supports Nagios ranges.
                        Example: `--warning-unused=10`. Default: 0
```


## Usage Examples

```bash
./mysql-index-health --defaults-file=/var/spool/icinga2/.my.cnf
```

OK output:

```text
Everything is ok. 0 unused indexes, 0 redundant indexes.
```

UNKNOWN output (Performance Schema off):

```text
Performance Schema is OFF, index-health views are unobservable. Enable with `performance_schema = ON` in `my.cnf` and restart the server, or set `--always-ok` if the host is intentionally left without Performance Schema.
```

WARN output:

```text
2 unused indexes [WARNING], 1 redundant index [WARNING].

67% of findings concentrate in schema `orders` (2 of 3); start the cleanup there.

Run `mysqltuner --pfstat` on the host for the full list with remediation hints.

Redundant indexes (safe to drop; the dominant index already covers the same query patterns):

! Schema  ! Table ! Redundant Index ! Dominant Index ! SQL Drop                                       !
! ------- ! ----- ! --------------- ! -------------- ! ---------------------------------------------- !
! orders  ! line  ! idx_a           ! idx_a_b        ! ALTER TABLE `orders`.`line` DROP INDEX `idx_a` !


Unused indexes (verify before dropping: "unused since last server start" can miss weekly or monthly jobs, recently restarted servers, and indexes that back foreign-key constraints; wait at least one full business cycle, then drop):

! Schema  ! Table   ! Index      ! SQL Drop                                            !
! ------- ! ------- ! ---------- ! --------------------------------------------------- !
! orders  ! line    ! idx_status ! ALTER TABLE `orders`.`line` DROP INDEX `idx_status` !
! reports ! summary ! idx_year   ! ALTER TABLE `reports`.`summary` DROP INDEX ...      !
```


## States

* OK if zero unused and zero redundant indexes (counter < threshold).
* WARN if the unused- or redundant-index count crosses `--warning-unused` / `--warning-redundant` (default: any > 0).
* No CRIT path: index housekeeping is never a wake-up-at-night finding.
* UNKNOWN if `performance_schema = OFF` on the server (the views cannot be populated).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mysql_redundant_indexes | Number | Count of indexes covered by a wider sibling on the same table. A non-zero value usually means a `CREATE INDEX` from a migration is redundant after a later, wider index was added. |
| mysql_unused_indexes | Number | Count of indexes that have not been read since the last server start. A non-zero value is a candidate-for-removal list, not a hard verdict: short-lived workloads need time to exercise all indexes. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:

    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
