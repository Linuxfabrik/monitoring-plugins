# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [Unreleased]

### Added

Monitoring Plugins:

* apache-httpd-version, apache-solr-version, apache-tomcat-version, composer-version, fedora-version, fortios-version, gitlab-version, grafana-version, graylog-version, icinga-version, keycloak-version, mastodon-version, matomo-version, mediawiki-version, moodle-version, mysql-version, nextcloud-version, openjdk-redhat-version, openvpn-version, php-version, postfix-version, postgresql-version, python-version, redis-version, rhel-version, rocketchat-version, valkey-version, wordpress-version: `--unreachable-severity` can alert instead of silently reporting OK when endoflife.date is unreachable and the bundled offline data is used (default stays OK) ([#750](https://github.com/Linuxfabrik/monitoring-plugins/issues/750))
* apache-tomcat-version: new check for an end-of-life or outdated Apache Tomcat, with an Icinga Director service set ([#126](https://github.com/Linuxfabrik/monitoring-plugins/issues/126))
* disk-io, disk-usage, fail2ban, network-errors, network-io, nextcloud-app-updates, sensors-temperatures, wildfly-non-xa-datasource-stats, wildfly-xa-datasource-stats: `--no-match-severity` can alert instead of silently reporting OK when the filters match nothing (default stays OK) ([#1308](https://github.com/Linuxfabrik/monitoring-plugins/issues/1308))
* disk-usage: per-mountpoint warning and critical thresholds via `--mount` ([#1286](https://github.com/Linuxfabrik/monitoring-plugins/issues/1286))
* docker-container, podman-container: new checks alerting on unhealthy, unexpected-state, frequently restarting or too-young containers; `podman-container --user` covers a rootless user
* docker-image, podman-image: new checks listing images and alerting on images older than a configurable age; `podman-image --user` covers a rootless user
* docker-service: new check alerting when a Docker Swarm service runs fewer tasks than expected
* docker-swarm: new check alerting on swarm membership, a down node, or lost manager quorum
* network-errors: new check alerting on interface receive and transmit errors ([#707](https://github.com/Linuxfabrik/monitoring-plugins/issues/707))
* nextcloud-app-updates: new check alerting when a Nextcloud app update has been pending longer than a grace period ([#62](https://github.com/Linuxfabrik/monitoring-plugins/issues/62))
* wildfly-version: new check alerting when WildFly is behind the latest stable release ([#123](https://github.com/Linuxfabrik/monitoring-plugins/issues/123))

### Changed

Build, CI/CD:

* Bump pinned `linuxfabrik-lib` to 5.1.0

Monitoring Plugins:

* about-me: recognizes an installed Apache Tomcat when guessing Icinga Director tags
* all plugins: the internal `--test` parameter is no longer shown in `--help`
* cpu-usage, disk-io, fs-xfs-stats, jitsi-videobridge-stats, network-io, nginx-status, nodebb-cache, nodebb-errors, procs, redis-status, starface-database-stats, valkey-status, wildfly-gc-status: cumulative counters are now reported as per-second rates (or plain values) instead of ever-growing totals, fixing Grafana graphs and aggregations; some performance-data metric names changed, so re-import the affected Grafana dashboards after updating ([#320](https://github.com/Linuxfabrik/monitoring-plugins/issues/320))
* disk-io: iowait is reported as saturated CPU cores instead of a percentage that could exceed 100% on multi-core hosts
* disk-usage: mountpoints are now filtered with `--match`/`--ignore`; the old `--include-*`/`--exclude-*` options keep working
* docker-stats, podman-stats: select or exclude containers by name with `--match`/`--ignore`, plus `--no-match-severity`
* mysql-innodb-log-waits: alerts only on real InnoDB log waits, no longer on a low write-log efficiency that raising `innodb_log_buffer_size` cannot fix
* mysql-logfile: documents case-insensitive ignore matching and how to silence harmless idle-connection-timeout warnings
* podman-info, podman-stats: `--user` reports on a specific rootless user's Podman
* snmp: `--device` also accepts an absolute path ([#1308](https://github.com/Linuxfabrik/monitoring-plugins/issues/1308))

### Fixed

Build, CI/CD:

* installer: `--source` on a host with too-old system Python now picks the newest installed Python and rebuilds cleanly

Monitoring Plugins:

* csv-values, json-values, strongswan-connections: non-UTF-8 input no longer crashes the check ([#256](https://github.com/Linuxfabrik/lib/issues/256))
* disk-usage: performance data carries the warning and critical thresholds again ([#1310](https://github.com/Linuxfabrik/monitoring-plugins/issues/1310))
* journald-query: a relative `--since` such as `-8h` from the Icinga Director works again ([#1264](https://github.com/Linuxfabrik/monitoring-plugins/issues/1264))
* lynis: audits produce a report on Debian, Ubuntu and other distributions that keep lynis outside `/usr/share` ([#1262](https://github.com/Linuxfabrik/monitoring-plugins/issues/1262))
* lynis: shows the underlying lynis error when an audit produces no report
* redfish-\*: the Redfish API URL is now a mandatory `--url`, dropping the misleading localhost default ([#1306](https://github.com/Linuxfabrik/monitoring-plugins/issues/1306))

### Security

Monitoring Plugins:

* logfile: closed a local privilege-escalation path in the legacy state-database migration, exploitable only with the non-default `fs.protected_symlinks=0`; the first run after updating re-scans the whole logfile once ([GHSA-w2gg-hx6w-24w3](https://github.com/Linuxfabrik/monitoring-plugins/security/advisories/GHSA-w2gg-hx6w-24w3))
* redfish-\*: a malicious controller can no longer redirect a check to another host (SSRF / auth-token leak) ([GHSA-96fx-pqc3-28xv](https://github.com/Linuxfabrik/monitoring-plugins/security/advisories/GHSA-96fx-pqc3-28xv))


## [v6.0.0] - 2026-06-14

### Breaking Changes

Monitoring Plugins:

* redfish-\*: plugins renamed to match their Redfish API endpoints (`redfish-drives` → `redfish-storage`, `redfish-sel` → `redfish-logservices`, `redfish-sensor` → `redfish-sensors`, `redfish-system` → `redfish-systems`); update any Icinga commands that reference the old names

### Added

Monitoring Plugins:

* csv-values: is shipped as a Windows build again
* disk-io: can also monitor raw, unmounted block devices such as multipath SAN or Oracle ASM disks (`--include-unmounted`)
* file-size: can report the mean or median file size as performance data (`--perfdata-mode`) ([#159](https://github.com/Linuxfabrik/monitoring-plugins/issues/159))
* lynis: new check that audits the security hardening of hosts across a subnet over SSH (hardening index, warnings, suggestions)
* redfish-ethernetinterfaces: new check for a server's Ethernet interface health
* redfish-firmwareinventory: new check for a server's firmware component versions and health
* redfish-managers: new check for a server's management controller health (BMC, e.g. iLO or iDRAC)
* redfish-memory: new check for a server's memory module health
* redfish-processors: new check for a server's processor health

Icinga Director:

* Redfish Service Set now also covers the memory, processor, Ethernet-interface, manager and firmware-inventory checks

Grafana:

* ipmi-sensor: now ships a Grafana dashboard that groups temperature, fan, voltage and power readings into separate panels ([#22](https://github.com/Linuxfabrik/monitoring-plugins/issues/22))
* the Redfish checks that emit performance data now ship Grafana dashboards

### Changed

Monitoring Plugins:

* by-ssh: the `--shell` option is deprecated and ignored; remote commands using pipes, globs or variables now always work
* cert: can scan a whole subnet for expiring or untrusted TLS certificates across many common ports, not just a single endpoint or local files (now the default when run without parameters)
* cert: warning/critical thresholds also accept a percentage of the lifetime or a duration, and the full certificate chain is checked, not just the leaf
* ipmi-sensor: performance data is grouped by sensor type, so temperatures, fan speeds, voltages and power show up in separate graphs (existing IPMI graph history resets once) ([#22](https://github.com/Linuxfabrik/monitoring-plugins/issues/22))
* nextcloud-security-scan: reports a fresh rating right after a Nextcloud update instead of a stale one (`--path`) ([#118](https://github.com/Linuxfabrik/monitoring-plugins/issues/118))
* php-status: also reports the active php.ini runtime settings and the largest OPcache scripts (`--top`), and flags PHP-FPM services a single check does not cover
* php-status: OPcache alerting is more tolerant (warns at 95% by default) and now flags cache thrashing, while a full interned strings buffer no longer warns
* php-status: when the monitoring.php helper cannot be read, the output names the actual cause instead of a generic "not found"
* php-status: the raw OPcache hits and misses counters are no longer emitted as performance data (the hit-rate percentage stays)
* redfish-\*: a `--brief` option lists only the components in WARN/CRIT state, to keep the output short on large systems
* redfish-\*: individual components can be included or excluded by regular expression, so noisy hardware no longer drives the check state (`--match`, `--ignore`)
* redfish-\*: frequent checks no longer flood a management controller's session table or audit log
* redfish-\*: can export the parsed hardware as a JSON inventory instead of running a health check (`--inventory`)
* redfish-\*: a slow or flaky management controller request is retried before the check fails (`--retries`)
* redfish-logservices: can also read the management controller event log (MEL), not just the System Event Log (`--log-type=sel|mel|both`)
* redfish-logservices: event log entries can be filtered by regular expression and aged out (`--match`, `--ignore`, `--max-age`)
* redfish-memory: reports memory size and module health correctly on Dell, HPE and Fujitsu controllers
* redfish-sensors: also reports chassis-wide power consumption, and reads fan speed whether reported in RPM or percent
* redfish-sensors: falls back to the legacy Thermal and Power endpoints when the modern Sensors collection is absent
* redfish-storage: now also checks volumes (logical drives), not just physical drives and controllers
* redfish-storage: now reports performance data for drive wear, temperature and component counts, ready for graphing
* swap-usage: a host without any swap is OK by default instead of UNKNOWN; set `--severity-no-swap` to alert on missing swap ([#1142](https://github.com/Linuxfabrik/monitoring-plugins/issues/1142))

Icinga Director:

* the Redfish baskets expose the new check options and raise the command timeout to 60 seconds

### Fixed

Build, CI/CD:

* installer: a source install (`--source`) cleans up a sudoers drop-in left under an earlier name, so sudo no longer warns about a duplicate `Cmnd_Alias`
* installer: a source install (`--source`) no longer prints Python `RuntimeWarning` messages about tarfile extraction on RHEL 9 family hosts

Monitoring Plugins:

* about-me: no longer crashes when detecting installed software on a host (it ran the service detection the wrong way after the move to argument lists)
* apache-httpd-version: adapted to the new endoflife.date URL ([PR #1224](https://github.com/Linuxfabrik/monitoring-plugins/pull/1224), thanks to [Salman Mohammadi](https://github.com/salmanxmoha))
* by-ssh: a failed connection no longer echoes the full command line (which can contain the `--password` value) in the plugin output
* on Windows, plugins that run system commands (for example `users`, `scheduled-task`, `ntp-w32tm`) show non-ASCII output such as umlauts in usernames correctly instead of garbled ([#681](https://github.com/Linuxfabrik/monitoring-plugins/issues/681))
* on Windows, multi-line plugin output is no longer shown with a blank line between every line in IcingaWeb
* redfish-sensors: no longer raises false warnings for sensors that report a placeholder min/max range ([#1211](https://github.com/Linuxfabrik/monitoring-plugins/issues/1211))
* several plugins that run system commands no longer report UNKNOWN when the command only writes a harmless warning to stderr; a genuine command failure is now reported as WARN. Affects deb-lastactivity, disk-smart, getent, journald-query, journald-usage, kubectl-get-pods, ntp-chronyd, ntp-ntpd, ntp-systemd-timesyncd, redis-status, restic-snapshots, restic-stats, rpm-lastactivity, safenet-hsm-state and valkey-status

Icinga Director:

* the shipped Service and Host templates no longer pin checks to the master zone, so checks deploy correctly in distributed setups; the agentless `-no-agent` checks still run from the master ([#721](https://github.com/Linuxfabrik/monitoring-plugins/issues/721))

### Security

Monitoring Plugins:

* every plugin that runs an external command now builds the command as an argument list instead of a shell command string, closing a local privilege escalation in which crafted plugin arguments could execute arbitrary commands. This is most serious on hosts where a plugin is allowed to run via sudo ([GHSA-798h-hpph-m24j](https://github.com/Linuxfabrik/monitoring-plugins/security/advisories/GHSA-798h-hpph-m24j))


## [v5.2.0] - 2026-06-02

### Added

Icinga Director:

* NUT Service Set now includes the `ups-nut` UPS check, not just the NUT systemd units

### Changed

Build, CI/CD:

* requirements: source-install lockfiles now pin every build dependency (including `setuptools`) with hashes, so `pip install --require-hashes` no longer relies on the build host having `setuptools` preinstalled ([#1138](https://github.com/Linuxfabrik/monitoring-plugins/issues/1138))

### Security

Monitoring Plugins:

* Plugins that cache trend data in the system temporary directory now keep their SQLite databases (and the `csv-values` staging file) in a private, per-user directory instead of directly in the shared, world-writable `/tmp`. This closes a local symlink attack on the predictable paths where an unprivileged user could redirect writes from a check running as root to arbitrary files ([GHSA-r35r-fpx2-jgr4](https://github.com/Linuxfabrik/monitoring-plugins/security/advisories/GHSA-r35r-fpx2-jgr4), thanks to [OoYo0uto](https://github.com/OoYo0uto))


## [v5.1.0] - 2026-05-30

### Added

Monitoring Plugins:

* [fail2ban](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/fail2ban/): `--ignore` (regex) and `--socket` options ([#140](https://github.com/Linuxfabrik/monitoring-plugins/issues/140))
* [mysql-database-metrics](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-database-metrics/): lists the largest tables by data plus index size to spot cleanup candidates before raising the InnoDB buffer pool; optional `--warning` / `--critical` size thresholds (e.g. `10G`) alert on oversized tables
* [mysql-long-queries](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-long-queries/): output now suggests `KILL <id>` to terminate a runaway query
* [snmp](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/snmp/): "Perfdata Alert Thresholds" accepts an optional min/max for the graph axis (`warn,crit,min,max`) ([PR #986](https://github.com/Linuxfabrik/monitoring-plugins/pull/986), thanks to [paasi6666](https://github.com/paasi6666))
* [swap-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/swap-usage/): `--severity-no-swap` alerts when a host has no swap configured at all, helping detect a swap partition that was inadvertently disabled ([#1142](https://github.com/Linuxfabrik/monitoring-plugins/issues/1142))

### Changed

Monitoring Plugins:

* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): `--tags` covers Jitsi, Needs Restarting, and Proxmox
* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): `--tags` emits all `MariaDB *` or `MySQL *` variant tags so all relevant service sets are offered
* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): `--tags` now detects Podman hosts
* [fail2ban](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/fail2ban/): per-jail breakdown is now a table; thresholds accept Nagios ranges ([#140](https://github.com/Linuxfabrik/monitoring-plugins/issues/140))
* `mysql-*`: tuning advice now appears only in the plugin output where a problem is flagged, no longer duplicated in the plugin description

### Fixed

Monitoring Plugins:

* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): `--tags` now correctly distinguishes MariaDB from MySQL
* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): `--tags` package-based detection now works on Debian, Ubuntu, SUSE, Arch, Alpine, and is fixed on Red Hat family
* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): "User-Installed Software" table (renamed from the misleading "Non-default Software") now lists every package instead of just the first one
* all plugins: importing `lib.url` on RHEL 8's default `python3` (3.6) no longer aborts with `AttributeError: module 'ssl' has no attribute 'TLSVersion'`. Plugins that don't use TLS version pinning keep working; calls that pin TLS get a clearer error. Officially supported minimum stays Python 3.9 (fix shipped via `linuxfabrik-lib` 4.0.2)
* [fail2ban](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/fail2ban/): a banned jail no longer mislabels the following jails with its state in the output
* `mysql-*`: queries against `mysql.user` and `mysql.global_priv` no longer abort with "Illegal mix of collations" when the server's connection-collation default differs from the system tables' column collations. Fix lives in `linuxfabrik-lib` 4.0.2, which now aligns the session collation with the `mysql` schema right after connect ([#1139](https://github.com/Linuxfabrik/monitoring-plugins/issues/1139))
* [mysql-innodb-buffer-pool-size](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-innodb-buffer-pool-size/): no longer aborts on MySQL 9.3 and newer. There `innodb_log_file_size` was removed, so the check now relies on `innodb_redo_log_capacity`
* [mysql-perf-metrics](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-perf-metrics/): no longer flags `innodb_log_file_size` and `innodb_log_files_in_group` as obsolete on MySQL 9.0 to 9.2, where they are still valid settings. They are reported only from MySQL 9.3 on, where they were actually removed
* [mysql-perf-metrics](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-perf-metrics/): the `innodb_io_capacity` check no longer raises false alarms on virtualised or network-backed storage (Ceph, cloud volumes), where the disk auto-detection misreads slow devices as fast local SSDs. It now runs only when `--storage-type=ssd` is set explicitly, and recommends sizing the value to the disk's measured IOPS instead of a fixed target
* [mysql-table-definition-cache](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-table-definition-cache/): dropped the incorrect advice to set `table_definition_cache = -1`. Assigning `-1` does not enable autosizing (MySQL clamps it to the 400 minimum and documents it as a do-not-assign value, MariaDB refuses to start); autosizing only happens when the variable is left unset. The recommendation now points to a concrete value above the table count
* [snmp](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/snmp/): a malformed "Perfdata Alert Thresholds" entry in a device CSV is now reported as UNKNOWN instead of being silently ignored, so a typo no longer just results in missing threshold lines without any feedback ([#768](https://github.com/Linuxfabrik/monitoring-plugins/discussions/768))

### Security

* Debian sudoers: the `apt-get` rule is now restricted to the exact command the `deb-updates` plugin runs, closing a local privilege escalation where the monitoring user could obtain a root shell by passing extra arguments to `apt-get` ([GHSA-8w6w-23mq-h8rg](https://github.com/Linuxfabrik/monitoring-plugins/security/advisories/GHSA-8w6w-23mq-h8rg), thanks to [OoYo0uto](https://github.com/OoYo0uto))


## [v5.0.0] - 2026-05-15

### Added

Monitoring Plugins:

* [cert](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/cert/): inspect X.509 certificates from a TLS endpoint or local PEM/DER files. Alerts on days until expiry
* [mysql-health](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-health/): single-number 0-100 health score for a MySQL/MariaDB server. Top-level Icinga alert and Grafana KPI
* [mysql-index-health](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-index-health/): trip-wire for unused and redundant indexes (`sys.schema_unused_indexes`, `sys.schema_redundant_indexes`). When it alerts, run `mysqltuner --pfstat` on the host for the full analysis with `ALTER TABLE ... DROP INDEX` statements. Performance Schema must be enabled; UNKNOWN when it is OFF (MariaDB default)
* [mysql-long-queries](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-long-queries/): alert on in-flight queries running longer than `--warning` / `--critical` seconds. Shows session ID, user, DB and statement so the admin can `KILL <id>` directly. New perfdata `mysql_active_transactions` from `information_schema.innodb_trx` trends background InnoDB transaction contention even when no single query is over the long-running threshold
* [mysql-tls](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-tls/): TLS/SSL posture (have_ssl, require_secure_transport, TLS versions, cert expiry, remote users without REQUIRE SSL). Finding text "Current connection ..." matches mysqltuner output verbatim
* [ups-nut](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/ups-nut/): monitor a UPS managed by Network UPS Tools (NUT). Battery, load, voltages, runtime, temperature and status


Build, CI/CD:

* requirements: one hash-pinned lockfile per supported Python LTS, each in its own `lockfiles/pyXX/` subdirectory (`py39` to `py314`). Replaces the single `requirements.txt`. Windows uses `lockfiles/py313-windows/requirements.txt`
* requirements: build scripts auto-detect the Python version and pick the matching file. urllib3 lands at 2.7.0 on Python 3.10+, closing two of the four Dependabot advisories
* requirements: `lockfiles/py39/` is excluded from both Dependabot version bumps and Dependabot security PRs. Most upstream packages dropped Python 3.9 over 2025/2026, so automated bumps would break `pip install --require-hashes` on RHEL 8 / Debian 11. The py39 lockfile is regenerated manually as needed
* INSTALL.md: documents how source-tarball installs on RHEL 8 can opt out of the frozen py39 lockfile by installing AppStream `python3.12` and running the plugins against `lockfiles/py312/requirements.txt`. RPM users on RHEL 8 stay on Python 3.9; Debian 11 has no comparable escape hatch


### Changed

Grafana:

* Panel lines stay continuous at zoom levels finer than the check interval (was disconnected dots)


Icinga Director:

* `mysql-binlog-cache` moved from **MySQL Replication Service Set** to baseline **MySQL Service Set**. Hosts activating only `mysql-replication` should now also activate `mysql`


Monitoring Plugins:

* `mysql-*` plugins: verify required privileges up front; exit UNKNOWN naming the missing privilege. See [PLUGINS-MYSQL.md](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-MYSQL.md)
* [mysql-aria](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-aria/): absent or disabled Aria engine no longer UNKNOWN (now OK with info). Breaking perfdata: cumulative counters replaced by per-second rates. Ships Grafana dashboard
* [mysql-binlog-cache](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-binlog-cache/): `log_bin = OFF` no longer UNKNOWN. Breaking perfdata: cumulative counters replaced by per-second rates. Ships Grafana dashboard
* [mysql-connections](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-connections/): name-resolution warning suppressed when `skip_networking=ON`. Breaking perfdata: cumulative counters replaced by per-second rates. New `mysql_pct_max_connections_used`
* [mysql-database-metrics](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-database-metrics/): new `--ignore-schemas REGEX` and `--lengthy`. Director Basket defaults `--lengthy=true`, pre-fills `--ignore-schemas=^icinga`
* [mysql-database-metrics](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-database-metrics/): excludes `percona` schema (was falsely flagged). Index-vs-data-size check fixed. New `--ignore-tables REGEX`. Now emits perfdata. Ships Grafana dashboard
* [mysql-innodb-buffer-pool-size](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-innodb-buffer-pool-size/)!: workload-based `innodb_redo_log_capacity` check on MySQL 8.0.30+. New `innodb_file_per_table` check. Breaking perfdata. Ships Grafana dashboard
* [mysql-innodb-log-waits](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-innodb-log-waits/): scope broadened to "Write Log efficiency" (alerts below 90%). Absent/disabled InnoDB no longer UNKNOWN. Breaking perfdata. Ships Grafana dashboard
* [mysql-joins](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-joins/): ship Grafana dashboard. Recommendation only suggests raising `join_buffer_size` below 4 MiB. Breaking perfdata
* [mysql-logfile](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-logfile/): prefers `performance_schema.error_log` on MySQL 8.0.22+ (works remote). Bug fix: docker/podman/kubectl sources read container logs. Severity matched via `[ERROR]`/`[Warning]` tags
* [mysql-logfile](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-logfile/): empty log file is now consistently STATE_OK regardless of whether `--server-log` was set (was STATE_UNKNOWN in auto-detect mode). Typical right after logrotate fires
* [mysql-memory](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-memory/): bug fix on `max_tmp_table_size`. Galera GCache counted on cluster nodes. New `--warning` (85%) / `--critical` (95%). `--lengthy` shows full breakdown. New perfdata
* mysql-memory and several other `mysql-*` plugins: thresholds now accept Nagios ranges. Boundary semantic shifts from `>=N` to `>N`
* [mysql-open-files](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-open-files/): new `--warning` (85%) / `--critical` (95%) replace the hardcoded 85% WARN-only
* mysql-open-files, mysql-slow-queries, mysql-sorts, mysql-table-cache, mysql-table-definition-cache, mysql-table-locks, mysql-temp-tables, mysql-thread-cache, mysql-traffic: ship Grafana dashboards
* [mysql-perf-metrics](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-perf-metrics/): duplicate `innodb_file_per_table` check removed (lives in `mysql-innodb-buffer-pool-size`). Now emits numeric perfdata. Ships Grafana dashboard
* [mysql-perf-metrics](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-perf-metrics/): warn when a deprecated config variable was explicitly set via `my.cnf` or `SET GLOBAL` (compile-time defaults stay silent). New perfdata `mysql_deprecated_config_variables`
* [mysql-perf-metrics](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-perf-metrics/): also check `innodb_snapshot_isolation` (MariaDB), and the two storage-type-aware InnoDB knobs `innodb_flush_neighbors` and `innodb_io_capacity`. New `--storage-type=auto|ssd|hdd|skip` parameter (auto reads `/sys/block` when the plugin runs on the database host)
* `mysql-*` plugins: container-test image matrix moved into per-plugin Containerfiles under `unit-test/containerfiles/`. Adding/retiring a MariaDB LTS is now a single-file change in each affected plugin
* `mysql-*` plugins: container tests now also cover MySQL 8.0 and 8.4 LTS upstream images (`mysql-v80`, `mysql-v84` Containerfiles per plugin)
* [mysql-query](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-query/)!: align with the other `mysql-*` plugins. Breaking perfdata: `cnt_warn`/`cnt_crit` renamed to `mysql_query_warn_value`/`mysql_query_crit_value`
* [mysql-replica-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-replica-status/)!: bug fix - lag detection fired on every server. Privilege narrowed to `SLAVE MONITOR` / `REPLICA MONITOR` on MariaDB 10.5+. New parameters and perfdata. Ships Grafana dashboard
* [mysql-slow-queries](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-slow-queries/): README clarifies that `Slow_queries` is a counter independent of `slow_query_log`, and that the `slow_query_log` / `long_query_time` findings only surface as recommendations alongside a slow-query-ratio WARN/CRIT (no standalone alert)
* [mysql-slow-queries](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-slow-queries/)!: bug fix - 5.x% never alerted (now float). New `--warning` (5%) / `--critical` (10%). Breaking perfdata: cumulative counters replaced by per-second rates
* [mysql-sorts](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-sorts/)!: new `--warning` (10%) / `--critical` (20%). Output reworded ("merge-sort file"). Breaking perfdata: cumulative counters replaced by per-second rates
* [mysql-storage-engines](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-storage-engines/)!: AUTO_INCREMENT check uses each column's own type ceiling (was always BIGINT UNSIGNED). New parameters. Now emits perfdata. Ships Grafana dashboard
* [mysql-system](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-system/): new WARN on `fs.nr_open < 1M`. Listening-port count limited to LISTEN state (was over-triggering). Breaking perfdata: `kernel.*` labels and `mysql_opened_ports` renamed
* [mysql-table-cache](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-table-cache/)!: new `--warning` (20%) / `--critical` (10%). Breaking perfdata: cumulative counters replaced by per-second rates
* [mysql-table-definition-cache](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-table-definition-cache/): OK output shows the verified value and table count. `-1` autosizing sentinel encoded as `0` in perfdata
* [mysql-table-indexes](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-table-indexes/)!: rewritten with two single-shot queries. New check: InnoDB base tables without a user-defined `PRIMARY KEY`. New parameters and perfdata. Ships Grafana dashboard
* [mysql-table-locks](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-table-locks/)!: new `--warning` (95%) / `--critical` (85%). Breaking perfdata: cumulative counters replaced by per-second rates
* [mysql-temp-tables](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-temp-tables/)!: new `--warning` / `--critical` (25/50). Bug fix: `KeyError` crash on idle servers. Bug fix: effective temp-table cap now correctly reported as the smaller of `tmp_table_size` and `max_heap_table_size` (was wrongly the larger), preventing a false "cap is already large enough" verdict on asymmetric configurations. Recommendation rewritten to explain per-table allocation, RAM impact under concurrency, and how to size from `performance_schema`. Breaking perfdata: cumulative counters replaced by per-second rates
* [mysql-thread-cache](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-thread-cache/)!: new `--warning` / `--critical` (50/30). Bug fix: `mysql_thread_cache_size` perfdata uom. Breaking perfdata
* [mysql-traffic](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-traffic/)!: bug fix - "100% writes" on idle servers. Breaking perfdata: cumulative counters replaced by per-second rates
* [mysql-user-security](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-user-security/): documented privilege broadened to `SELECT on mysql.*` (was `mysql.user`)
* [mysql-user-security](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-user-security/): skip username-as-password check when `validate_password` is active. MariaDB roles excluded. New perfdata. Basket `enable_perfdata = true`
* [mysql-user-security](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-user-security/): flag accounts on legacy `mysql_native_password` (and `sha256_password` on MySQL 8.0+). Version-aware recommendation. New perfdata: `mysql_users_on_legacy_auth_plugin`
* [mysql-user-security](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-user-security/): weak-password dictionary check (~110 common defaults from SecLists + MySQL/MariaDB-specific entries). Per-user finding names the matched password. Skipped on MySQL 8.0+ (`PASSWORD()` removed) and when the `validate_password` plugin is active. New perfdata: `mysql_users_with_weak_password`


### Fixed

Grafana:

* `schemaVersion` fixed to `42`; Grafana 12 was failing to import the date-encoded value


Monitoring Plugins:

* docker-stats, podman-stats: per-container CPU and memory perfdata restored. The previous release reported only aggregate values, breaking long-term trending of individual containers ([#1104](https://github.com/Linuxfabrik/monitoring-plugins/issues/1104))
* [veeam-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/veeam-status/): works again against Veeam Enterprise Manager v13, which serialises REST-API JSON keys in camelCase after its .NET migration ([#1001](https://github.com/Linuxfabrik/monitoring-plugins/issues/1001))


### Removed

Monitoring Plugins:

* hin-status: removed - the HIN support status page no longer exists
* mysql-innodb-buffer-pool-instances: removed - the underlying variable is gone on MariaDB 10.6+ and obsolete on modern MySQL. Also removed from both InnoDB Service Sets


## [v4.1.0] - 2026-05-08

### Added

Monitoring Plugins:

* [systemd-units-failed](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/systemd-units-failed/): in OK state, output now includes the last failed unit since the last reboot, its timestamp and how long ago


### Changed

Monitoring Plugins:

* [sap-open-concur-com](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/sap-open-concur-com/): default `--datacenter` is now `eu2` (the legacy `eu` endpoint returns HTTP 500). Setups passing `--datacenter` explicitly are unaffected
* [sap-open-concur-com](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/sap-open-concur-com/): longer default timeout so slow but healthy SAP API responses no longer flip to UNKNOWN


Icinga Director:

* `Apache apache2 Service Set (Debian 10-)` matches only `debian10` now; obsolete `debian8`/`debian9` removed from the filter
* `Apache apache2 Service Set (Ubuntu 18+)` now also matches `ubuntu24` and `ubuntu26`
* `Apache httpd Service Set` (Fedora / RHEL) now also matches `rhel10`
* `OS - RHEL 10 Basic Service Set` drops the `audit-rules.service` check (oneshot unit that stays inactive). Audit health stays covered by `auditd.service` and the `audit.log` file-size check
* OS host tag labels for `rhel7`/`rhel8`/`rhel9` get a leading double space (`OS - RHEL  7 (and compatible)`, etc.) so they sort before `rhel10` in the Director dropdown. Tag names unchanged


### Removed

Icinga Director:

* `all-the-rest.json`: 13 single-plugin Service Sets removed - each needed per-instance parameters. Service Templates remain, configure via Director Apply rules instead
* `all-the-rest.json`: obsolete `tarifpool-v2` host tag dropped (the Set itself was removed in v3)


### Fixed

Monitoring Plugins:

* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): Non-default Software, Non-default Users and systemctl list-timers tables now sort case-insensitive and natural (so `foo10` lands after `foo2`)
* [network-port-tcp](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/network-port-tcp/): fix plugin crashing on every invocation
* [php-fpm-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/php-fpm-status/): no more false CRIT on dynamic and ondemand pools when all current workers are momentarily busy
* Various plugins: declare `lib.*` imports explicitly to harden against future lib refactors. No behaviour change today


## [v4.0.0] - 2026-05-07

### Added

Icinga Director:

* Add `Needs Restarting Service Set` (host tag `needs-restarting`) for Linux servers patched but not yet rebooted. Tag only hosts where reboots are manual. Red Hat- and Debian-based distributions
* Add `OS - RHEL 10 Basic Service Set` for Rocky Linux 10 / RHEL 10 / AlmaLinux 10 hosts. Adds `audit-rules.service` over the RHEL 9 set
* Add `Postfix MTA Service Set (Multi-Instance)` for hosts running the MTA as `postfix@-.service` ([#535](https://github.com/Linuxfabrik/monitoring-plugins/issues/535))

Monitoring Plugins:

* [users](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/users/): cross-distro container-based test added, covering RHEL 10 SSH sessions without a PTY ([#989](https://github.com/Linuxfabrik/monitoring-plugins/issues/989))


### Changed

Build, CI/CD:

* Bump pinned `linuxfabrik-lib` dependency from 3.4.0 to 3.4.1, which fixes `librenms-alerts` silently reporting OK on alerts in LibreNMS states `WORSE`, `BETTER` or `CHANGED`

Icinga Director:

* Backfill `Disk I/O` and `Network I/O` checks on the older Debian OS Basic Service Sets where they were missing
* OS host tag labels now suffix `(and compatible)` so the derivative distribution coverage is explicit. Tag names unchanged
* Remove the hard-wired `rsyslog.service` check from every OS Basic Service Set. Tag hosts running rsyslog with `rsyslog` to activate the dedicated `rsyslog Service Set`

Monitoring Plugins:

* [dmesg](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/dmesg/): `--ignore` now takes a regex (was substring) and is repeatable. Specifying it replaces the bundled defaults (was extending). Defaults grew to cover SHPC PCI hot-plug noise
* [dmesg](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/dmesg/): `--severity` deprecated; the plugin always alerts as CRIT. Existing templates with `dmesg_severity = warn` keep working but no longer downgrade
* [dmesg](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/dmesg/): emit `errors` perfdata so the unfiltered error count can be trended in Grafana


### Removed

Icinga Director:

* Drop the `OS - Debian 8 Basic Service Set`. Debian 8 (Jessie) has been EOL since June 2020 and is not covered by the rest of the project anymore


## [v3.0.0] - 2026-05-05

### Security

* **ci**: scope `GITHUB_TOKEN` permissions in the dependabot-auto-merge workflow to the job level (addresses OpenSSF Scorecard `Token-Permissions`)

### Breaking Changes

Build, CI/CD:

* Drop the `flatdict` dependency; `statuspal` reworked accordingly. Unblocks builds on RHEL 10 and SLE 15/16 ([#1044](https://github.com/Linuxfabrik/monitoring-plugins/issues/1044))

Monitoring Plugins:

* [haproxy-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/haproxy-status/): replaced `--username` / `--password` with HTTP basic auth in `--url` (e.g. `https://user:pw@host/server-status`); old parameters now UNKNOWN with a migration hint
* [mailq](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mailq/): thresholds now take a duration (`1h`, `3D`) instead of a count. New `oldest_mail_age` perfdata. New `--mta` ([#781](https://github.com/Linuxfabrik/monitoring-plugins/issues/781))
* [php-fpm-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/php-fpm-status/): multi-pool via repeatable `--url`; HTTP basic auth in the URL. All perfdata labels renamed and prefixed `<pool>_` - update Grafana/InfluxDB queries
* [procs](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/procs/): `--argument`, `--command`, `--username` now regex instead of substring/startswith; use `^foo` for startswith, `^foo$` for exact match


### Added

Build, CI/CD:

* Documentation site at <https://linuxfabrik.github.io/monitoring-plugins/>
* Package support for SLE 15, SLE 16, Ubuntu 26.04 (incl. "OS - Ubuntu 26 Basic Service Set" template)


Monitoring Plugins:

* [by-ssh](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/by-ssh/): alert on single numeric values
* [by-winrm](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/by-winrm/): executes commands on remote Windows hosts via WinRM, with JEA support (incl. `--winrm-configuration-name`)
* [dhcp-scope-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/dhcp-scope-usage/): add `--brief` to hide scopes within thresholds ([#788](https://github.com/Linuxfabrik/monitoring-plugins/issues/788))
* [disk-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/disk-usage/): add `--brief` to hide filesystems within thresholds ([#782](https://github.com/Linuxfabrik/monitoring-plugins/issues/782))
* docker-info, podman-info: add `--ignore` to filter stderr warnings/errors by regex ([#834](https://github.com/Linuxfabrik/monitoring-plugins/issues/834))
* [gitlab-version](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/gitlab-version/): add `--check-security` to warn on security-relevant updates (default on) ([#688](https://github.com/Linuxfabrik/monitoring-plugins/issues/688))
* [haproxy-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/haproxy-status/): add `--ignore` to filter proxies/frontends/backends/servers by regex on `<proxy>/<svname>` ([#835](https://github.com/Linuxfabrik/monitoring-plugins/issues/835))
* [infomaniak-swiss-backup-devices](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/infomaniak-swiss-backup-devices/): add `--ignore-customer`, `--ignore-name`, `--ignore-tag`, `--ignore-user`
* [infomaniak-swiss-backup-products](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/infomaniak-swiss-backup-products/): add `--ignore-customer`, `--ignore-tag`
* [ipmi-sel](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/ipmi-sel/): add `--ignore` to filter SEL entries by regex ([#982](https://github.com/Linuxfabrik/monitoring-plugins/issues/982))
* [journald-query](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/journald-query/): add `--icinga-callback` so acknowledging the service in Icinga suppresses the matching events on following runs ([#649](https://github.com/Linuxfabrik/monitoring-plugins/issues/649))
* [json-values](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/json-values/): add `--token`/`--header` for HTTP auth; new `--warning-key`/`--critical-key` (dot-notation) for numeric alerts ([#1005](https://github.com/Linuxfabrik/monitoring-plugins/issues/1005))
* librenms-alerts, librenms-health: support device-type `management`
* [logfile](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/logfile/): `--filename` accepts time macros (`{today}`, `{%Y}`, ...) for date-stamped logs. Offset survives day rollovers ([#678](https://github.com/Linuxfabrik/monitoring-plugins/issues/678))
* [nextcloud-enterprise](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/nextcloud-enterprise/): reports Nextcloud Enterprise subscription information
* [podman-info](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/podman-info/): displays system-wide Podman information ([#1023](https://github.com/Linuxfabrik/monitoring-plugins/issues/1023))
* [podman-stats](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/podman-stats/): cpu and memory statistics for all running Podman containers ([#1023](https://github.com/Linuxfabrik/monitoring-plugins/issues/1023))
* [procs](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/procs/): add `--top N` to list the top N processes by CPU time and memory usage
* [procs](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/procs/): add `--lengthy` for extended `--top` table output
* [procs](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/procs/): add `--warning-cpu-percent` / `--critical-cpu-percent` for aggregated CPU usage of filtered processes
* [redfish-system](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/redfish-system/): checks overall system health from a Redfish-compatible server (split off from `redfish-drives`) ([#652](https://github.com/Linuxfabrik/monitoring-plugins/issues/652))
* [scanrootkit](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/scanrootkit/): add 41 signatures for modern Linux rootkits and implants (BPFDoor, Drovorub, Ebury, FontOnLake, Kaiji, Kobalos, perfctl, PUMAKIT, Reptile, Symbiote, Winnti, and more)
* [scanrootkit](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/scanrootkit/): add 11 further signatures for recent Linux threats (Auto-Color, Bootkitty, DslogdRAT, Hadooken, Koske, LinkPro, randkit, Snapekit, Sutekh, vmwfxs, WolfsBane)
* [scanrootkit](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/scanrootkit/): findings now show the year the rootkit was first publicly disclosed
* [scanrootkit](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/scanrootkit/): `rootkit_items` / `rootkit_possible` perfdata count distinct rootkits (was indicators); `max` field carries the signature-database size
* [sensors-temperatures](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/sensors-temperatures/): add `--ignore` to filter sensors by regex ([#965](https://github.com/Linuxfabrik/monitoring-plugins/issues/965))
* [strongswan-connections](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/strongswan-connections/): add `--match` and `--ignore` to filter VICI connections by regex ([#738](https://github.com/Linuxfabrik/monitoring-plugins/issues/738))
* [statuspal](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/statuspal/): also detect `emergency-maintenance` state
* [valkey-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/valkey-status/): support user and password credentials [PR #954](https://github.com/Linuxfabrik/monitoring-plugins/pull/954), thanks to [Claudio Kuenzler](https://github.com/Napsty)


Icinga Director:

* Add Debian 13 Service Set


### Changed

Assets:

* sudoers: disable PAM's session stack log lines when user icinga or nagios uses sudo


Build, CI/CD:

* Bump pinned `linuxfabrik-lib` dependency from 3.0.0 to 3.2.0
* Windows MSI no longer depends on an installed Icinga2 agent (install path unchanged: `ProgramFiles64Folder/ICINGA2/sbin/linuxfabrik`)


Grafana:

* All panels: do not connect across nulls


Icinga Director:

* Service Templates: "Notes URL" now points at the docs site instead of GitHub source; re-run `tools/build-basket --auto` to pick up the new URL


Monitoring Plugins:

* all plugins: ignore unknown arguments instead of erroring (helps when rolling out updated service definitions)
* all plugins: expanded `DESCRIPTION` in `--help`
* all plugins: drop incorrect "Supports Nagios ranges" mentions from `--help` where not implemented
* [atlassian-statuspage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/atlassian-statuspage/): report primary incident, affected services and maintenance windows. New `--service REGEX`. Perfdata renamed (`impact` → `cnt_warn`/`cnt_crit`)
* batch of plugins with `append` parameters: user values now replace the defaults (was extending) ([#540](https://github.com/Linuxfabrik/monitoring-plugins/issues/540))
* [cpu-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/cpu-usage/): remove `--top` (moved to `procs --top`)
* [disk-io](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/disk-io/): also monitor normalized iowait on Linux (100% = one fully I/O-saturated core)
* [file-count](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/file-count/): much faster on large directories (stops counting once thresholds are exceeded)
* [file-ownership](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/file-ownership/): `--filename` merges with the default file list; use `--no-default-files` to check only user-supplied files
* [file-ownership](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/file-ownership/): default file list extended with CIS benchmark-relevant files (login.defs, sudoers, sysctl, systemd, PAM, etc.)
* [logfile](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/logfile/): output names the scanned file and each configured pattern with per-pattern match count and severity label ([#547](https://github.com/Linuxfabrik/monitoring-plugins/issues/547))
* nextcloud-enterprise, nextcloud-version: `occ` no longer has to be executable; `php occ <cmd>` is invoked under the owner of `config/config.php`
* [php-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/php-status/): default to `http://localhost/monitoring.php`, tolerate its absence
* [redfish-sensor](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/redfish-sensor/): `--insecure` now defaults to `True` (BMCs usually serve self-signed certs). Pass `--insecure=false` explicitly if a trusted CA chain is installed
* [scanrootkit](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/scanrootkit/): exact per-symbol kernel symbol matching (fewer false positives)
* [service](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/service/): Windows services with a space in their technical name now match `--service` ([#921](https://github.com/Linuxfabrik/monitoring-plugins/issues/921))
* [systemd-units-failed](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/systemd-units-failed/): failed unit names appear in the first output line for dashboard/SMS readability ([#967](https://github.com/Linuxfabrik/monitoring-plugins/issues/967))


Tools:

* build-basket: `--auto` is now truly non-interactive; unknown datafields and objects get fresh uuids instead of prompting
* rename `tools/check2basket` → `tools/build-basket` and `tools/remove-uuids` → `tools/basket-remove-uuids`; update any wrappers or documentation


### Removed

Monitoring Plugins:

* [cpu-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/cpu-usage/): remove `--top` (moved to `procs --top`)
* [scanrootkit](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/scanrootkit/): remove the Suckit rootkit check and the `rootkit_extra` perfdata; update Grafana panels and alerts that rely on `rootkit_extra`


Tools:

* remove legacy `grafana-tool`


### Fixed

Build, CI/CD:

* RPM: no longer conflicts with other RPMs shipping ELF build-id symlinks (e.g. `azure-cli`) ([#979](https://github.com/Linuxfabrik/monitoring-plugins/issues/979))
* requirements.txt: add missing `setuptools` dependency


Tools:

* build-basket: strip argparse `%%` escaping in Icinga Director basket descriptions
* build-basket: write `[]` as default value for `append` parameters with `default=None`
* update-readmes: backslashes in a plugin's `--help` output (e.g. Windows example paths like `C:\logs\...`) no longer make README regeneration crash


Grafana:

* Icinga Dashboard: use a query for the service name so the dashboard works regardless of the configured service name

Monitoring Plugins:

* semantic bugfixes across a batch of plugins (keycloak-version, mysql-table-locks, valkey-status, wildfly-*, ...) ([#1070](https://github.com/Linuxfabrik/monitoring-plugins/issues/1070))
* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): perfdata error when `--dmidecode` is used and no HW information is available
* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): various `sys_dimensions` errors on some machines ([#1006](https://github.com/Linuxfabrik/monitoring-plugins/issues/1006))
* [by-ssh](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/by-ssh/): add missing `--verbose` parameter
* [cpu-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/cpu-usage/): false 100% readings on Windows with 64+ cores ([#626](https://github.com/Linuxfabrik/monitoring-plugins/issues/626))
* [deb-updates](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/deb-updates/): crash when reporting the number of available updates
* [docker-stats](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/docker-stats/): memory perfdata used CPU thresholds
* [docker-stats](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/docker-stats/): replace per-container perfdata with aggregate metrics (containers, cpu)
* [file-age](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/file-age/): handle race when files disappear on busy file systems
* [fs-ro](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/fs-ro/): ignore `/run/credentials`
* [keycloak-stats](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/keycloak-stats/): incorrect symlink for lib
* [librenms-alerts](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/librenms-alerts/): report `WORSE`/`BETTER`/`CHANGED` alerts too (was only `ACTIVE`); LibreNMS 25.2+ flips many to `CHANGED` ([#882](https://github.com/Linuxfabrik/monitoring-plugins/issues/882))
* [logfile](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/logfile/): `OverflowError` when inode exceeds SQLite INTEGER range on Windows/NTFS ([#1035](https://github.com/Linuxfabrik/monitoring-plugins/issues/1035))
* [logfile](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/logfile/): multiple services on the same logfile with different patterns no longer interfere with each other ([#698](https://github.com/Linuxfabrik/monitoring-plugins/issues/698))
* [logfile](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/logfile/): after the #698 state-DB rename, the read offset could reset on every run on hosts upgrading from an older DB schema, visible as a steadily climbing `scanned_lines` in Grafana
* [mysql-joins](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-joins/): crash on a server booted less than one second ago
* [mysql-memory](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-memory/): crash in "other process memory" on hosts with psutil older than 5.3.0
* [mysql-traffic](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-traffic/): crash from missing import and crash on a server booted less than one second ago
* [needs-restarting](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/needs-restarting/): show "Running Kernel X != Installed Kernel Y" on Debian-based systems when `needrestart` reports a pending kernel upgrade
* notify-host-mail, notify-service-mail: Icinga logo renders inline again on hosts with long FQDNs ([#790](https://github.com/Linuxfabrik/monitoring-plugins/issues/790))
* ntp-\*: prevent `TypeError` when comparing int and str
* [podman-stats](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/podman-stats/): precise numeric values; aggregate perfdata includes block and network I/O totals
* [redfish-drives](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/redfish-drives/): system-level warnings (e.g. inlet temp) no longer flip the check to WARN (covered by `redfish-system` now) ([#652](https://github.com/Linuxfabrik/monitoring-plugins/issues/652))
* [rocketchat-stats](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/rocketchat-stats/): crash when reporting the user count
* [scanrootkit](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/scanrootkit/): a single malformed signature file no longer crashes the whole check
* [scanrootkit](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/scanrootkit/): directory-only rootkit signatures (e.g. KBeast `/usr/_h4x_`, Kaiji `/usr/bin/lib`) are now actually evaluated
* [updates](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/updates/): crash on Python 3.9 when pending updates are reported
* [users](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/users/): incorrect TTY count when SSH clients connect via IPv6 ([#989](https://github.com/Linuxfabrik/monitoring-plugins/issues/989))
* [valkey-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/valkey-status/): TLS connection [PR #954](https://github.com/Linuxfabrik/monitoring-plugins/pull/954), thanks to [Claudio Kuenzler](https://github.com/Napsty)


## [v2.2.1] - 2025-09-22

### Fixed

Monitoring Plugins:

* ntp-chronyd, ntp-ntpd: SyntaxError: f-string: unmatched '(' on python 3.11 ([#952](https://github.com/Linuxfabrik/monitoring-plugins/issues/952))



## [v2.2.0] - 2025-09-19

### Added

Build, CI/CD:

* Add support for debian13 and rhel10 packages


Monitoring Plugins:

* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): add option to avoid dmidecode and sudo ([#948](https://github.com/Linuxfabrik/monitoring-plugins/issues/948))
* ntp-\*: add `--stratum` parameter and modernize code
* [spring-boot-actuator-health](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/spring-boot-actuator-health/): derived from [PR #940](https://github.com/Linuxfabrik/monitoring-plugins/pull/940), thanks to [Dominik Riva](https://github.com/slalomsk8er) - a monitoring plugin for the Spring Boot Actuator `/health` endpoint
* [virustotal-scan-url](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/virustotal-scan-url/): analyses URLs to detect malware and other breaches using VirusTotal


### Fixed

Assets:

* Linuxfabrik Monitoring Plugins [SELinux Type Enforcement Policies](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/assets/selinux/linuxfabrik-monitoring-plugins.te): allow D-Bus daemon IPC with unconfined services via FIFOs and UNIX sockets
* Linuxfabrik Monitoring Plugins [SELinux Type Enforcement Policies](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/assets/selinux/linuxfabrik-monitoring-plugins.te): add missing type enforcement requirements ([#918](https://github.com/Linuxfabrik/monitoring-plugins/issues/918))


Build, CI/CD:

* Build on Ubuntu 24.02 error on system_dbusd_t ([#918](https://github.com/Linuxfabrik/monitoring-plugins/issues/918))


Monitoring Plugins:

* [deb-updates](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/deb-updates/): apt-get returns with an error ([#904](https://github.com/Linuxfabrik/monitoring-plugins/issues/904))
* [deb-updates](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/deb-updates/): missing rights and still OK ([#937](https://github.com/Linuxfabrik/monitoring-plugins/issues/937))
* [icinga-topflap-services](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/icinga-topflap-services/): prevent stacktrace when required parameters are empty
* [openstack-swift-stat](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/openstack-swift-stat/): problem with python-keystoneclient, optimize requirements* ([#900](https://github.com/Linuxfabrik/monitoring-plugins/issues/900))
* [safenet-hsm-state](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/safenet-hsm-state/): set `use_agent` to false and enable perfdata in Icinga Director Basket
* [statuspal](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/statuspal/): handle incident_type "performance"
* [users](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/users/): "no one is logged in" on Ubuntu 24.04 LTS ([#919](https://github.com/Linuxfabrik/monitoring-plugins/issues/919))
* valkey-status|redis-status: improve `--ignore-thp` ([#898](https://github.com/Linuxfabrik/monitoring-plugins/issues/898))


### Changed

Assets:

* To make it easier to integrate with other tools, all RST files have been converted to GitHub-flavoured Markdown.


Build, CI/CD:

* Change to official, up-to-date Rocky Linux containers for building RPMs ([Motivation](https://hub.docker.com/_/rockylinux#important-note))


Icinga Director:

* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): change command timeout from 30 to 60
* [atlassian-statuspage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/atlassian-statuspage/): increase Icinga Director command timeout
* [disk-io](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/disk-io/): change command timeout from 10 to 30 for Windows
* [memory-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/memory-usage/): change command timeout from 10 to 30 for Windows
* [ntp-w32tm](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/ntp-w32tm/): change command timeout from 10 to 30 and check interval from 60 to 600
* [procs](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/procs/): change command timeout from 10 to 30 for Windows


Monitoring Plugins:

* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): report current cpu frequency and avoid dmidecode noise, new perfdata
* [cpu-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/cpu-usage/): non-blocking behaviour (interval=None + manual deltas via SQLite DB) so we get both accuracy and faster runtime
* [disk-io](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/disk-io/): modernize code
* [gitlab-health](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/gitlab-health/): increase timeout from 3 to 8 secs
* [gitlab-liveness](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/gitlab-liveness/): increase timeout from 3 to 8 secs
* [gitlab-readiness](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/gitlab-readiness/): increase timeout from 3 to 8 secs
* [infomaniak-events](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/infomaniak-events/): increase timeout from 8 to 28 secs
* [journald-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/journald-usage/): also print SystemMaxUse and SystemKeepFree
* [memory-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/memory-usage/): modernize code
* [pip-updates](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/pip-updates/): modernize code
* [procs](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/procs/): avoid token + PEB reads and repeated attribute calls per process, as this has an impact on busy Windows servers
* [rocketchat-stats](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/rocketchat-stats/): improve output and docs a little bit
* [statuspal](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/statuspal/): 'performance' degredation is now a WARN, not UNKNOWN



## [v2.1.1] - 2025-06-20

### Fixed

Icinga Director:

* Icinga2 Service Set



## [v2.1.0] - 2025-06-20

### Added

Icinga Director:

* Icinga2 Service Set


Monitoring Plugins:

* [icinga-version](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/icinga-version/): tracks if Icinga is EOL


### Fixed

Icinga Director:

* all-the-rest.json: correct nextcloud-app-update.timer unit states


Monitoring Plugins:

* [disk-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/disk-usage/): handle disk accessibility ([#792](https://github.com/Linuxfabrik/monitoring-plugins/issues/792))
* [updates](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/updates/): "The syntax of the command is incorrect."


### Changed

Icinga Director:

* [atlassian-statuspage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/atlassian-statuspage/): Increase timeout from 8 to 30 secs
* [uptimerobot](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/uptimerobot/): Increase timeout from 8 to 30 secs
* Path to notification plugins changed back to `/usr/lib64/nagios/plugins` 


Monitoring Plugins:

* [matomo-version](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/matomo-version/): use EOL library, parameter `--cache-expire` is deprecated



## [v2.0.0] - 2025-06-06

### Breaking Changes

Build, CI/CD:

* Windows: To save disk space, Windows plugins are only compiled if they are useful for testing local system resources. Plugins that check remote services should run on Linux. Currently we compile:

    * cpu-usage
    * dhcp-scope-usage
    * disk-io
    * disk-usage
    * dns
    * dummy
    * file-age
    * file-count
    * file-size
    * logfile
    * memory-usage
    * network-connections
    * network-io
    * network-port-tcp
    * ntp-w32tm
    * path-rw-test
    * procs
    * scheduled-task
    * service
    * swap-usage
    * updates
    * uptime
    * users

* Linux: To save disk space, we *no longer compile* to binaries. The .rpm and .deb packages now ship the source code and require Python 3.9+ to be installed on the target host. We also install a Python venv (virtual environment) in `/usr/lib64/linuxfabrik-monitoring-plugins/venv/` to manage all Python libraries with `pip`. Sorry for the back and forth.


Icinga Director:

* all-the-rest.json: drop legacy commands
* The Icinga Director configuration has been updated to remove plugins that are no longer compiled for Windows:

    * apache-solr-version
    * axenita-stats
    * composer-version
    * countdown
    * csv-values
    * dhcp-relayed
    * diacos
    * disk-smart
    * feed
    * fortios-cpu-usage
    * fortios-firewall-stats
    * fortios-ha-stats
    * fortios-memory-usage
    * fortios-network-io
    * fortios-sensor
    * fortios-version
    * githubstatus
    * grassfish-licenses
    * grassfish-players
    * grassfish-screens
    * haproxy-status
    * hin-status
    * huawei-dorado-backup-power
    * huawei-dorado-controller
    * huawei-dorado-disk
    * huawei-dorado-enclosure
    * huawei-dorado-fan
    * huawei-dorado-host
    * huawei-dorado-hypermetrodomain
    * huawei-dorado-hypermetropair
    * huawei-dorado-interface
    * huawei-dorado-power
    * huawei-dorado-system
    * icinga-topflap-services
    * infomaniak-events
    * infomaniak-swiss-backup-devices
    * infomaniak-swiss-backup-products
    * jitsi-videobridge-stats
    * jitsi-videobridge-status
    * json-values
    * kemp-services
    * keycloak-memory-usage
    * keycloak-stats
    * keycloak-version
    * librenms-alerts
    * librenms-health
    * librenms-version
    * matomo-reporting
    * matomo-version
    * mediawiki-version
    * metabase-stats
    * mod-qos-stats
    * moodle-version
    * mysql-aria
    * mysql-binlog-cache
    * mysql-connections
    * mysql-database-metrics
    * mysql-innodb-buffer-pool-instances
    * mysql-innodb-buffer-pool-size
    * mysql-innodb-log-waits
    * mysql-joins
    * mysql-logfile
    * mysql-memory
    * mysql-open-files
    * mysql-perf-metrics
    * mysql-query
    * mysql-replica-status
    * mysql-slow-queries
    * mysql-sorts
    * mysql-storage-engines
    * mysql-system
    * mysql-table-cache
    * mysql-table-definition-cache
    * mysql-table-indexes
    * mysql-table-locks
    * mysql-temp-tables
    * mysql-thread-cache
    * mysql-traffic
    * mysql-user-security
    * nextcloud-security-scan
    * nextcloud-stats
    * nextcloud-version
    * nginx-status
    * nodebb-cache
    * nodebb-database
    * nodebb-errors
    * nodebb-events
    * nodebb-groups
    * nodebb-info
    * nodebb-users
    * nodebb-version
    * onlyoffice-stats
    * openjdk-redhat-version
    * openvpn-version
    * php-fpm-ping
    * php-fpm-status
    * php-status
    * php-version
    * pip-updates
    * python-version
    * qts-cpu-usage
    * qts-disk-smart
    * qts-memory-usage
    * qts-temperatures
    * qts-uptime
    * qts-version
    * redfish-drives
    * redfish-sel
    * redfish-sensor
    * restic-check
    * restic-snapshots
    * restic-stats
    * rocketchat-stats
    * rocketchat-version
    * sap-open-concur-com
    * starface-account-stats
    * starface-backup-status
    * starface-channel-status
    * starface-database-stats
    * starface-java-memory-usage
    * starface-peer-stats
    * starface-status
    * statusiq
    * statuspal
    * uptimerobot
    * veeam-status
    * whmcs-status
    * wildfly-deployment-status
    * wildfly-gc-status
    * wildfly-memory-pool-usage
    * wildfly-memory-usage
    * wildfly-non-xa-datasource-stats
    * wildfly-server-status
    * wildfly-thread-usage
    * wildfly-uptime
    * wildfly-xa-datasource-stats
    * wordpress-version
    * xml


### Added

Monitoring Plugins:

* [atlassian-statuspage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/atlassian-statuspage/): receive alerts on incidents on a specific Atlassian Statuspage
* [deb-updates](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/deb-updates/): checks for software updates on systems that use package management systems based on the `apt-get` command
* [kubectl-get-pods](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/kubectl-get-pods/): checks the health and status of kubernetes pods by running `kubectl get pods` and parsing the results
* [rpm-updates](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/rpm-updates/): displays available updates, including a list of advisories about newer versions of installed packages
* [valkey-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/valkey-status/): returns information and statistics about a Valkey server
* [valkey-version](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/valkey-version/): tracks if Valkey is EOL


### Fixed

Build, CI/CD:

* compile-one.sh: provide Nuitka's no-deployment-flag ([#864](https://github.com/Linuxfabrik/monitoring-plugins/issues/864))


Monitoring Plugins:

* [by-ssh](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/by-ssh/): fix traceback on "permission denied"
* [icinga-topflap-services](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/icinga-topflap-services/): ignore events with "Waiting for Icinga DB to synchronize the config." to prevent UNKNOWNs
* [needs-restarting](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/needs-restarting/): add missung import of lib.disk
* [ping](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/ping/): '10 received' contains '0 received' ([#860](https://github.com/Linuxfabrik/monitoring-plugins/issues/860))
* [snmp](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/snmp/): Special characters not supported in options --v3-auth-prot-password and --v3-priv-prot-password ([#886](https://github.com/Linuxfabrik/monitoring-plugins/issues/886))


### Changed

Build, CI/CD:

* create-fpms.sh: fix OS detection for setting OS family
* change linux packaging workflow to use native tools (rpmbuild, debuild)


Assets:

* prefix sudoers command alias to avoid conflicts ([#880](https://github.com/Linuxfabrik/monitoring-plugins/issues/880))


Monitoring Plugins:

* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): add valkey detection
* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): reports type of display server (if any)
* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): switch from lib.version to lib.distro
* [csv-values](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/csv-values/): make use of ommitted --warning-query and --critical-query more robust
* [disk-io](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/disk-io/): improve help text
* [fail2ban](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/fail2ban/): be a bit more verbose in case everything is ok
* [fedora-version](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/fedora-version/): switch from lib.version to lib.distro
* [fs-inodes](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/fs-inodes/): improve code
* [grassfish-screens](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/grassfish-screens/): initialize screen statuses earlier
* [haproxy-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/haproxy-status/): add unix socket support as alternative to HTTP(S) ([#767](https://github.com/Linuxfabrik/monitoring-plugins/issues/767))
* [icinga-topflap-services](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/icinga-topflap-services/): increase default warning level from 5 to 7
* [load](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/load/): Use `os.getloadavg()` instead of `cat /proc/loadavg` ([#295](https://github.com/Linuxfabrik/monitoring-plugins/issues/295))
* [php-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/php-status/): bz2 and curl are no default modules
* [redfish-sel](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/redfish-sel/): add support for Supermicro ([#866](https://github.com/Linuxfabrik/monitoring-plugins/issues/866))
* [rhel-version](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/rhel-version/): switch from lib.version to lib.distro
* [snmp](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/snmp/): add column "skip output" to CSV definition for devices, add unit tests
* [snmp](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/snmp/): make table output suppressable, streamline output
* [systemd-unit](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/systemd-unit/): implement support for `systemctl --machine` and `--user`



## [v1.2.0.11] - 2025-03-13

### Breaking Changes

Build, CI/CD:

* Due to the new [conventional commits](https://www.conventionalcommits.org/en/v1.0.0/) and version string requirements in Windows MSI setup files, the project switches from [calendar versioning](https://calver.org/) to [semantic versioning](https://semver.org/). Project starts at `v1.0.0.0`.
* Re-implemented `/build` and `/.github` from scratch.


Assets:

* Move `/selinux` to `/assets/selinux`


Icinga Director:

* all-the-rest.json: Remove Tarifpool-v2 Service Set


Monitoring Plugins:

* Since some libraries such as pymysql or openssl have security vulnerabilities for Python 3.6, the project now requires Python 3.9+ to use the plugins in the source code variant.
* [jitsi-videobridge-stats](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/jitsi-videobridge-stats/): Remove deprecated values ([PR #780](https://github.com/Linuxfabrik/monitoring-plugins/pull/780), thanks to [SnejPro](https://github.com/SnejPro))
* [jitsi-videobridge-stats](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/jitsi-videobridge-stats/): Remove deprecated warning and critical parameters, always returns OK


Notification Plugins:

* notify-\*-rocketchat-telegram: Remove Telegram functionality, remove ``-telegram`` suffix


### Added

Build, CI/CD:

* Add support for ARM ([#702](https://github.com/Linuxfabrik/monitoring-plugins/issues/702))


Icinga Director:

* all-the-rest.json: Add Debian 12 (Cloud Image) Service Set
* all-the-rest.json: Add IcingaDB Service Set
* all-the-rest.json: Add Mastodon Service Set
* all-the-rest.json: Add Moodle Service Set
* all-the-rest.json: Add networking Service Set (mostly for Debian-based systems)
* all-the-rest.json: Add rsyslog Service Set
* all-the-rest.json: Add Ubuntu 24 Service Set
* all-the-rest.json: Add WHMCS Service Set


Monitoring Plugins:

* graylog-version
* hin-status
* icinga-topflap-services
* keycloak-memory-usage
* keycloak-stats
* mastodon-version
* moodle-version
* openvpn-version
* scanrootkit
* statusiq
* uptimerobot
* whmcs-status


### Fixed

Icinga Director:

* [crypto-policy](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/crypto-policy/): New defaults according to LFOps crypto_policy role
* [dhcp-relayed](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/dhcp-relayed/): Binding a socket to all network interfaces
* [disk-io](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/disk-io/): UnboundLocalError: cannot access local variable 'msg' where it is not associated with a value ([#777](https://github.com/Linuxfabrik/monitoring-plugins/issues/777))
* [docker-stats](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/docker-stats/): always-ok not referenced ([#839](https://github.com/Linuxfabrik/monitoring-plugins/issues/839))
* [fortios-network-io](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/fortios-network-io/): Fix reading from local SQLite database
* [mysql-query](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-query/): Fix director basket
* [needs-restarting](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/needs-restarting/): UnboundLocalError under nagios user ([#799](https://github.com/Linuxfabrik/monitoring-plugins/issues/799))
* [service](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/service/): Implement `--starttype`, as code was missing (parameter is now appending); implement unit-tests
* [snmp](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/snmp/): With some CSV files, user gets traceback `IndexError: list index out of range`. Add more unit-tests.
* [strongswan-connections](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/strongswan-connections/): check fails if using AES-GCM algorithm ([#806](https://github.com/Linuxfabrik/monitoring-plugins/issues/806))
* [swap-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/swap-usage/): Fix ProcessLookupError


Monitoring Plugins:

* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): expanded RAM isn't updating ([#757](https://github.com/Linuxfabrik/monitoring-plugins/issues/757))
* [apache-httpd-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/apache-httpd-status/): failure when mod_md is enabled ([#783](https://github.com/Linuxfabrik/monitoring-plugins/issues/783))
* [docker-stats](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/docker-stats/): ValueError: could not convert string to float: '0B' ([#776](https://github.com/Linuxfabrik/monitoring-plugins/issues/776))
* [redfish-sel](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/redfish-sel/): UnboundLocalError: local variable 'sel_path' referenced before assignment ([#779](https://github.com/Linuxfabrik/monitoring-plugins/issues/779))
* [whmcs-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/whmcs-status/): handle null correctly in whmcs api response ([#820](https://github.com/Linuxfabrik/monitoring-plugins/pull/820))


### Changed

Build, CI/CD:

* Create MSI package for Windows.
* Switch compilation for Linux from pyinstaller to Nuitka.
* Switch compilation for Windows from mingw/gcc to MSVC.
* Switch compilation platform for the .tar.gz/.zip distribution files from CentOS 7 to Ubuntu 20.04.
* Refactor CI/CD pipeline, move from self-hosted Github runners to runners at Github.
* Linuxfabrik/lib are now part of the requirements.txt, so no extra checkout needed any more.


Icinga Director:

* all-the-rest.json: Make all dmesg Service Sets use sudo
* all-the-rest.json: Check /var/log/syslog file size in all Debian Service Sets
* All plugins for Windows: Prepared for msi and changed default path from C:\ProgramData\icinga2\usr\lib64\nagios\plugins to c:\Program Files\icinga2\sbin\linuxfabrik
* Replace png with svg icons for all plugins


Monitoring Plugins:

* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): Determines date of birth of cloud VMs more accurately
* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): Add Mastodon detection
* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): Add Moodle detection
* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): Add WHMCS detection
* [dhcp-scope-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/dhcp-scope-usage/): Ignore PercentageInUse fractions
* [disk-io](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/disk-io/): Re-add support for Windows after last rewrite
* [disk-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/disk-usage/): Add `--list-fstypes` and `--fstype` for specifying the file system type
* [fail2ban](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/fail2ban/): More compact output (closes #141)
* [file-size](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/file-size/): fix help text
* [fs-inodes](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/fs-inodes/): Check inode usage on real and different disks. `--mount` parameter is deprecated.
* [infomaniak-events](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/infomaniak-events/): return CRIT in case of critical events
* [keycloak-version](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/keycloak-version/): Check Keycloak Version via REST API ([#748](https://github.com/Linuxfabrik/monitoring-plugins/issues/748))
* librenms-alerts, librenms-health: Compact output is the new default and shows non-OK only
* [mysql-thread-cache](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-thread-cache/): DB daemon must have been running for an hour before the cache hit rate is measured.
* [mysql-version](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-version/): handle `mysql: Deprecated program name`
* [nextcloud-security-scan](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/nextcloud-security-scan/): Handle error on https://scan.nextcloud.com/
* nodebb-stats: In "Last user", don't report the user you login with ([#536](https://github.com/Linuxfabrik/monitoring-plugins/issues/536))
* [openstack-nova-list](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/openstack-nova-list/): No more need for keystoneauth and keystoneclient
* [redis-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/redis-status/): Add `--tls` parameter
* [rhel-version](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/rhel-version/): `--extended-support` checks for "Extended Life Cycle Support" EOL ([#740](https://github.com/Linuxfabrik/monitoring-plugins/issues/740))
* [rocketchat-version](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/rocketchat-version/): use EOL library, parameter `--cache-expire` is deprecated
* [systemd-unit](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/systemd-unit/): Improve output
* [uptime](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/uptime/): Report downtime ([#191](https://github.com/Linuxfabrik/monitoring-plugins/issues/191))


### Removed

Build, CI/CD:

* Remove support for debian10, rhel7, ubuntu1804 packages (OS's are EOL)


Notification Plugins:

* notify-\*-rocketchat: remove telegram functionality



## [2024060401] - 2024-06-04

### Added

Monitoring Plugins:

* mysql-query

Build, CI/CD:

* Added Ubuntu 24.04


## [2024052901] - 2024-05-29

### Breaking Changes

Icinga Director:

* all-the-rest.json: Remove all predefined "Journald Query" definitions, as they were not as useful in practice as we thought. Single services are more useful.
* Lowered the criticality of many service templates and service set services to make the monitoring less noisy by default. Make sure to double check and increase the criticality for important services.

Monitoring Plugins:

* [disk-io](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/disk-io/): Nearly rewritten from scratch, old parameters have been replaced by new, better ones. Perfdata "throughput" has been renamed to "bandwidth". Filter disks which are really mounted, translate dm-* device names, wildcard support for ignore disks ([#709](https://github.com/Linuxfabrik/monitoring-plugins/issues/709), [#708](https://github.com/Linuxfabrik/monitoring-plugins/issues/708), [#676](https://github.com/Linuxfabrik/monitoring-plugins/issues/676))
* [file-size](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/file-size/): Note that the plugin now requires a size qualifier when specifying parameters, e.g. ``--warning=10K`` for 10 KiB (instead of ``--warning=10000`` as in previous versions).
* [journald-query](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/journald-query/): Pattern-matching is now always case-sensitive ([#745](https://github.com/Linuxfabrik/monitoring-plugins/issues/745))
* [librenms-alerts](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/librenms-alerts/): Rewritten from scratch to fetch from LibreNMS MySQL/MariaDB database (therefore the check comes with new parameters)
* [librenms-health](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/librenms-health/): Rewritten from scratch to fetch from LibreNMS MySQL/MariaDB database (therefore the check comes with new parameters)
* php-fpm: Remove parameters `--*-max-children` because php-fpm `max children reached` is either 0 or 1
* [snmp](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/snmp/): Improve Performance Data Handling ([#481](https://github.com/Linuxfabrik/monitoring-plugins/issues/481)) - update your CSV definition files and add two more columns according to the check's README
* [uptime](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/uptime/): Use the plugin to warn about recent reboots ([#722](https://github.com/Linuxfabrik/monitoring-plugins/issues/722)). Note that the plugin now requires a time qualifier when specifying parameters, e.g. ``--warning=180D`` for 180 days (instead of ``--warning=180`` as in previous versions).

Notification Plugins:

* All notification plugins are now installed in `/usr/lib64/nagios/plugins/notifications/` by default, because otherwise installing the notification and monitoring plugins package at the same time fails ([#726](https://github.com/Linuxfabrik/monitoring-plugins/issues/726))


### Added

Icinga Director:

* all-the-rest.json: New TuneD Service Set (therefore removed from all "OS - RHEL" service sets)

Monitoring Plugins:

* dhcp-relayed (a port of [check_dhcp_relayed](https://exchange.nagios.org/directory/Plugins/Network-Protocols/DHCP-and-BOOTP/check_dhcp_relayed/details))
* composer-version
* mediawiki-version


### Changed

Icinga Director:

* all-the-rest.json: Rename "Starface Java Status" to "Starface Java Memory Usage"
* all-the-rest.json: Ignore session-c*.scope in systemd-units-failed by default

Monitoring Plugins:

* \*-version: Add new parameters `--insecure` `--no-proxy` `--timeout`
* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): Add detection of non-default software, udp ports, hardware and much more
* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): Add new parameters `--insecure` `--no-proxy` `--timeout`
* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): Pipes ("|") within the plugin output lead to broken perfdata ([#741](https://github.com/Linuxfabrik/monitoring-plugins/issues/741))
* [apache-httpd-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/apache-httpd-status/): Add new parameters `--no-proxy` `--timeout`
* [axenita-stats](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/axenita-stats/): Add new parameters `--insecure` `--no-proxy`
* [cpu-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/cpu-usage/): Add `--top` parameter, showing 5 top processes by default
* [csv-values](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/csv-values/): Pipes in data are seen as delimiter between check output and performance data ([#727](https://github.com/Linuxfabrik/monitoring-plugins/issues/727))
* [deb-lastactivity](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/deb-lastactivity/): WARN if last modified timestamp is not found for one or more packages ([#743](https://github.com/Linuxfabrik/monitoring-plugins/issues/743))
* [diacos](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/diacos/): Add new parameter `--insecure`
* [feed](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/feed/): Make use of `--insecure` `--no-proxy` `--timeout`
* [file-descriptors](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/file-descriptors/): Add `--top` parameter, showing 5 top processes by default
* [file-size](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/file-size/): Support Nagios ranges for `--warning` and `--critical` ([PR #735](https://github.com/Linuxfabrik/monitoring-plugins/issues/735), thanks to [djmcd89](https://github.com/djmcd89))
* [fs-ro](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/fs-ro/): Add `/dev/loop` to default ignore list
* [fs-ro](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/fs-ro/): Make output better readable ([PR #729](https://github.com/Linuxfabrik/monitoring-plugins/issues/729), thanks to [Konrad Bucheli](https://github.com/kbucheli))
* [fs-ro](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/fs-ro/): Show mount point info on first line when there is only one hit ([PR #730](https://github.com/Linuxfabrik/monitoring-plugins/issues/730), thanks to [Konrad Bucheli](https://github.com/kbucheli))
* [githubstatus](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/githubstatus/): Add new parameters `--insecure` `--no-proxy` `--timeout`
* [gitlab-health](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/gitlab-health/): Add new parameters `--insecure` `--no-proxy`
* [gitlab-liveness](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/gitlab-liveness/): Add new parameters `--insecure` `--no-proxy`
* [gitlab-readiness](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/gitlab-readiness/): Add new parameters `--insecure` `--no-proxy`
* grassfish-\*: Add new parameters `--insecure` `--no-proxy` `--timeout`
* [haproxy-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/haproxy-status/): Add new parameters `--insecure` `--no-proxy`
* huawei-dorado-\*: Add new parameter `--insecure`
* infomaniak-\*: Add new parameters `--insecure` `--no-proxy` `--timeout`
* [infomaniak-events](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/infomaniak-events/): Add new parameter `--ignore-regex`
* [infomaniak-swiss-backup-products](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/infomaniak-swiss-backup-products/): Improve output
* jitsi-\*: Add new parameters `--insecure` `--no-proxy`
* [journald-query](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/journald-query/): Remove hard-coded `--boot` parameter from query
* [kvm-vm](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/kvm-vm/): Improve output
* [librenms-version](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/librenms-version/): Fetches info from local SQLite using new librenms library
* [logfile](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/logfile/): Add new parameters `--insecure` `--no-proxy` `--timeout`
* [memory-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/memory-usage/): Add `--top` parameter, showing 5 top processes by default
* [metabase-stats](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/metabase-stats/): Add new parameters `--insecure` `--no-proxy` `--timeout`
* [mod-qos-stats](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mod-qos-stats/): Add new parameters `--insecure` `--no-proxy` `--timeout`
* [mysql-memory](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-memory/): Enhance output, set threshold to 95%
* [nextcloud-security-scan](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/nextcloud-security-scan/): Add new parameters `--insecure` `--no-proxy`
* [nextcloud-stats](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/nextcloud-stats/): Add new parameter `--timeout`
* nodebb-\*: Add new parameter `--no-proxy`
* [nginx-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/nginx-status/): Add new parameters `--insecure` `--no-proxy` `--timeout`
* [ntp-chronyd](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/ntp-chronyd/): Provide config info if an ntp server is not being used
* onlyoffice-status: Add new parameters `--insecure` `--no-proxy`
* [php-fpm-ping](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/php-fpm-ping/): Add new parameters `--insecure` `--no-proxy` `--timeout`
* [php-fpm-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/php-fpm-status/): Add new parameters `--insecure` `--no-proxy` `--timeout`
* [php-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/php-status/): Add new parameters `--insecure` `--no-proxy` `--timeout`
* [redfish-drives](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/redfish-drives/): Add new parameters `--insecure` `--no-proxy` `--timeout`
* [redfish-sel](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/redfish-sel/): Add new parameters `--insecure` `--no-proxy` `--timeout`
* [redfish-sensor](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/redfish-sensor/): Add new parameters `--insecure` `--no-proxy` `--timeout`
* rocket-\*: Add new parameters `--insecure` `--no-proxy` `--timeout`
* sap-open-concur: Add new parameter `--insecure`
* [statuspal](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/statuspal/): Add new parameters `--insecure` `--no-proxy` `--timeout`
* [swap-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/swap-usage/): Report the top 3 processes causing the usage (Linux only)
* [swap-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/swap-usage/): Add `--top` parameter, showing 5 top processes by default
* [veeam-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/veeam-status/): Add new parameters `--insecure` `--no-proxy`
* wildfly-\*: Add new parameters `--insecure` `--no-proxy`
* [xml](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/xml/): Add new parameter `--insecure`


### Fixed

Icinga Director:

* all-the-rest.json: Fix "FreeIPA Server Service Set" definition

Monitoring Plugins:

* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): Throws exception for openvas ([#749](https://github.com/Linuxfabrik/monitoring-plugins/issues/749))
* [infomaniak-events](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/infomaniak-events/): Fix `UnboundLocalError: local variable 'keys' referenced before assignment`
* [nextcloud-stats](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/nextcloud-stats/): KeyError: apps ([#731](https://github.com/Linuxfabrik/monitoring-plugins/issues/731))
* [ntp-ntpd](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/ntp-ntpd/): Fixed unpacking of ntpq -p values ([PR #758](https://github.com/Linuxfabrik/monitoring-plugins/pull/758), thanks to [Leo Pempera](https://github.com/leo-pempera))
* [ntp-w32tm](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/ntp-w32tm/): Fix `UnboundLocalError: local variable 'clock_rate' referenced before assignment`


## [2023112901] - 2023-11-29

### Breaking Changes

Monitoring Plugins:

* Notifications Plugins now generate URLs for Icinga DB Web instead of the old IcingaWeb2 Monitoring Module ([#643](https://github.com/Linuxfabrik/monitoring-plugins/issues/643))


### Added

Grafana:

* [mysql-connections](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-connections/): Add Grafana dashboard
* [mysql-memory](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-memory/): Add Grafana dashboard

Icinga Director:

* all-the-rest.json: Add Debian 12 (Bookworm), add deb-lastactivity
* all-the-rest.json: Add Apache Solr Service Set
* all-the-rest.json: Increase file size warning for `/var/log/secure`

Monitoring Plugins:

* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): Add detection of Apache Solr
* apache-solr-version
* deb-lastactivity ([PR #710](https://github.com/Linuxfabrik/monitoring-plugins/issues/710), thanks to [Yannic Schüpbach](https://github.com/Dissiyt))
* gitlab-health ([#670](https://github.com/Linuxfabrik/monitoring-plugins/issues/670))
* gitlab-liveness ([#670](https://github.com/Linuxfabrik/monitoring-plugins/issues/670))
* gitlab-readiness ([#670](https://github.com/Linuxfabrik/monitoring-plugins/issues/670))
* gitlab-version
* ntp-w32tm ([#629](https://github.com/Linuxfabrik/monitoring-plugins/issues/629))
* openjdk-redhat-version
* openstack-nova-list
* postgresql-version
* python-version
* redis-version
* statuspal

Project:

* Add a `requirements.txt`


### Changed

Features:

* sudoers: Don't log command calls any longer.

Icinga Director:

* all-the-rest.json: Remove "Journald Query - aide-check.service" from the AIDE service set because it's not useful

Monitoring Plugins:

* All plugins: Consistently reporting errors using cu() instead of oao()
* \*-version: Add eol offset date, optional warn on new major/minor/patch
* \*-version: Curl from https://endoflife.date first, then use hardcoded version ([#680](https://github.com/Linuxfabrik/monitoring-plugins/issues/680))
* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): Add detection of ncdu
* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): Add detection of yarn
* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): Show systemd timers with next runtime
* [cpu-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/cpu-usage/): On Windows, exclude "System Idle Process" from the Top3 list
* [disk-smart](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/disk-smart/): Skip unsupported disks ([#672](https://github.com/Linuxfabrik/monitoring-plugins/issues/672))
* [disk-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/disk-usage/): Add a parameter to select performance data ([#697](https://github.com/Linuxfabrik/monitoring-plugins/issues/697))
* [fail2ban](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/fail2ban/): Improve output, add unit-test
* [fortios-firewall-stats](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/fortios-firewall-stats/): Allow the check to run even some FortiOS users use only IPv4 or IPv6 ([PR #719](https://github.com/Linuxfabrik/monitoring-plugins/issues/716), thanks to [Pierrot la menace](https://github.com/Pierrot-la-menace))
* [grafana-version](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/grafana-version/): Add Grafana v9.5
* [infomaniak-events](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/infomaniak-events/): Add filter for service categories
* [infomaniak-swiss-backup-devices](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/infomaniak-swiss-backup-devices/): Improve column ordering in output
* [journald-query](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/journald-query/): Improve output
* [mysql-aria](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-aria/): Remove WARN if `aria_pagecache_read_requests` > 0 and `pct_aria_keys_from_mem` < 95%
* [mysql-connections](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-connections/): Add perfdata mysql_max_used_connections
* [mysql-connections](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-connections/): Report and warn on current usage instead of peak usage, and improved output.
* [mysql-innodb-buffer-pool-size](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-innodb-buffer-pool-size/): Improve code and output
* [mysql-logfile](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-logfile/): Returns OK instead of UNKNOWN if logfile is found but empty
* [mysql-logfile](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-logfile/): State only UNKNOWN if the log is empty and wasn't set deliberately ([PR #716](https://github.com/Linuxfabrik/monitoring-plugins/issues/716), thanks to [Eric Esser](https://github.com/dorkmaneuver))
* [mysql-logfile](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-logfile/): Stop magic auto-configure if `--server-log` is given
* [openstack-nova-list](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/openstack-nova-list/): Make more robust in case of OpenStack errors
* [php-version](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/php-version/): Check multiple installed PHP versions ([#694](https://github.com/Linuxfabrik/monitoring-plugins/issues/694))
* [ping](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/ping/): Check plugin to fast states "error" ([#691](https://github.com/Linuxfabrik/monitoring-plugins/issues/691))
* qts-\*: 'Keyerror: func' while executing qts-plugins ([#692](https://github.com/Linuxfabrik/monitoring-plugins/issues/692))
* qts-\*: General code and README improvements, all tested against QuTScloud 4.5.6, 5.0.1 and 5.1
* qts-temperature: Is it correct to have one value for CPU and System Temperature Threshold? ([#313](https://github.com/Linuxfabrik/monitoring-plugins/issues/313))
* [qts-version](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/qts-version/): Shows up to date even when new firmware available ([#692](https://github.com/Linuxfabrik/monitoring-plugins/issues/692))
* [rocketchat-stats](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/rocketchat-stats/): There are new values available ([#151](https://github.com/Linuxfabrik/monitoring-plugins/issues/151))
* [systemd-unit](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/systemd-unit/): Encode unit-name to text before running systemd command
* [uptime](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/uptime/): Additionally report last reboot time ([#190](https://github.com/Linuxfabrik/monitoring-plugins/issues/190)
* [xca-cert](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/xca-cert/): refactor check, make better use of the new libraries ([#75](https://github.com/Linuxfabrik/monitoring-plugins/issues/75))


### Fixed

Monitoring Plugins:

* [csv-values](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/csv-values/): header included in data results despite setting "--skip-header" ([#706](https://github.com/Linuxfabrik/monitoring-plugins/issues/706))
* [journald-query](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/journald-query/): Rename perfdata from "sudo journald-query" to "journald-query"
* [path-rw-test](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/path-rw-test/): To avoid race conditions, use a unique filename ([#283](https://github.com/Linuxfabrik/monitoring-plugins/issues/283))
* [qts-disk-smart](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/qts-disk-smart/): Plugin not working since new update ([#696](https://github.com/Linuxfabrik/monitoring-plugins/issues/696))
* [swap-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/swap-usage/): Fix Traceback `PdhAddEnglishCounterW failed`



## [2023051201] - 2023-05-12

### Breaking Changes

Monitoring Plugins:

* [disk-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/disk-usage/): Add include mount points/fs ([#662](https://github.com/Linuxfabrik/monitoring-plugins/issues/662)) (so dropped `--ignore` parameter)
* keycloak-version3: Simplified, no longer cares about patch levels, no longer needs internet access (so dropped some parameters)
* php-version3: Simplified, no longer cares about patch levels, no longer needs internet access (so dropped some parameters)
* wordpress-version3: Simplified, no longer cares about patch levels, no longer needs internet access (so dropped some parameters)
* Implement a new and cleaner directory structure ([#350](https://github.com/Linuxfabrik/monitoring-plugins/issues/350))
* Remove all Python 2 based plugins and libraries from the project, and therefore remove the "3" suffix from all Python3-based plugins and libraries as well ([#589](https://github.com/Linuxfabrik/monitoring-plugins/issues/589))
* Simplify sudoers ([#651](https://github.com/Linuxfabrik/monitoring-plugins/issues/651))


### Added

Features:

* Question/Documentation: Are the tools to compile the download binary part of this repo? ([#660](https://github.com/Linuxfabrik/monitoring-plugins/issues/660))

Monitoring Plugins:

* apache-httpd-version
* by-ssh
* cometsystem ([PR #650](https://github.com/Linuxfabrik/monitoring-plugins/pull/650), thanks to [Dominik Riva](https://github.com/slalomsk8er))
* fedora-version
* githubstatus
* grafana-version
* mysql-version
* network-io ([#619](https://github.com/Linuxfabrik/monitoring-plugins/issues/619))
* openstack-swift-stat
* postfix-version
* rhel-version
* safenet-hsm-state ([PR #648](https://github.com/Linuxfabrik/monitoring-plugins/pull/648), thanks to [Dominik Riva](https://github.com/slalomsk8er))

Grafana:

* Add new panels, update existing ones
* Dashboards written in Jsonnet, to be maintained by [Grizzly](https://github.com/grafana/grizzly)
* Add a grafana dashboard for the inbuilt icinga command ([#577](https://github.com/Linuxfabrik/monitoring-plugins/issues/577))


### Changed

Monitoring Plugins:

* [apache-httpd-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/apache-httpd-status/): Remove `ReqPerSec`, `BytesPerSec`, `BytesPerReq`, `DurationPerReq` perfdata as they are wrong
* [disk-io](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/disk-io/): `--ignore` now ignores all disks "starting with" the given parameter value
* [disk-io](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/disk-io/): Move top3-processes-which-caused-the-most-io to here ([#285](https://github.com/Linuxfabrik/monitoring-plugins/issues/285))
* [disk-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/disk-usage/): Add include mount points/fs ([#662](https://github.com/Linuxfabrik/monitoring-plugins/issues/662))
* [disk-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/disk-usage/): allow passing absolute values for warn/crit ([#114](https://github.com/Linuxfabrik/monitoring-plugins/issues/114))
* [disk-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/disk-usage/): Also show "free" in table ([#482](https://github.com/Linuxfabrik/monitoring-plugins/issues/482))
* [disk-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/disk-usage/): Make plugin output more generic ([#664](https://github.com/Linuxfabrik/monitoring-plugins/issues/664))
* [fortios-version](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/fortios-version/): Simplified, returns version information in perfdata
* [journald-query](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/journald-query/): Lower default for `--since` from 24h to 8h
* [kemp-services](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/kemp-services/): Display the original status of every Virtual Service ([#654](https://github.com/Linuxfabrik/monitoring-plugins/issues/654))
* Move "test3" and "examples" folder into a new "unit-test" folder for each plugin ([#288](https://github.com/Linuxfabrik/monitoring-plugins/issues/288))
* [nextcloud-version](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/nextcloud-version/): Simplified, no longer cares about patch levels, no longer needs internet access
* [php-fpm-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/php-fpm-status/): Remove `req per sec` perfdata as it is meaningless
* [php-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/php-status/): Move monitoring.php
* [php-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/php-status/): Rename perfdata item from `php-opcache-memory_usage-current_wasted_percentage` to `php-opcache-memory_usage-current_wasted-percentage`
* [restic-snapshots](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/restic-snapshots/): Shorten output, add `--lengthy` parameter, change DEFAULT_GROUP_BY to 'host,paths'
* Unified most of the \*-version3 checks in behavior, also using data from https://endoflife.date (no need for internet access).


### Fixed

Monitoring Plugins:

* [kemp-services](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/kemp-services/): Credentials not converted correctly ([#653](https://github.com/Linuxfabrik/monitoring-plugins/issues/653))
* [disk-smart](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/disk-smart/): Getting error: "KeyError: 'serial_number'" ([#659](https://github.com/Linuxfabrik/monitoring-plugins/issues/659))
* [disk-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/disk-usage/): module 'psutil' has no attribute 'disk_partitions' ([#663](https://github.com/Linuxfabrik/monitoring-plugins/issues/663))
* [file-age](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/file-age/): Type object 'SMBDirEntry' has no attribute 'from_filename' ([#665](https://github.com/Linuxfabrik/monitoring-plugins/issues/665))


### Removed

Monitoring Plugins:

* top3-processes-which-caused-the-most-io (moved it into disk-io)


## [2023030801] - 2023-03-08

### Breaking Changes

Features:

* Move all CHANGELOG items for the "libs" [into its own file](https://github.com/Linuxfabrik/lib/blob/main/CHANGELOG.md) (since it is a [stand-alone project](https://github.com/Linuxfabrik/lib))

Monitoring Plugins:

* journald-query3: Removed `--grep` and `--case-sensitive` parameter which are a bit weird and only work on systemd v237+. Replaced by `--ignore-regex`.
* journald-query3: Implement filter (therefore the check comes with new parameters) ([#641](https://github.com/Linuxfabrik/monitoring-plugins/issues/641))
* journald-usage3: Switch `--warning` parameter from MiB to GiB
* mysql-\*3: Removed parameters `--hostname`, `--password`, `--port` and `--username` and switched to option-file authentication (therefore all checks come with new parameters)
* pip-updates3: Include- and exclude-property (therefore the check comes with new parameters) ([#646](https://github.com/Linuxfabrik/monitoring-plugins/issues/646))
* redis-status3: Add option to disable hit-ratio check (therefore the check comes with new parameters) ([#623](https://github.com/Linuxfabrik/monitoring-plugins/issues/623))
* service3: Check is rewritten and now able to check multiple Windows services on a host, supporting Python Regular expressions and threshold ranges (therefore the check comes with new parameters)
* veeam-status3: Add an option switch to "WarningVmLatestState" for an integer value of tolerated VM warnings (therefore the check comes with new parameters) ([#630](https://github.com/Linuxfabrik/monitoring-plugins/issues/630))

Icinga Director:

* Removed "OS - RHEL 7 Basic Service Set (Hardware)"
* Removed "oVirt Engine 4.2 Service Set"
* Removed "oVirt Engine 4.3 Service Set"
* Removed "oVirt Host Service Set"
* Removed "oVirt VM Service Set (RHEL 7)"
* Removed "oVirt VM Service Set (RHEL 8)"
* Removed "oVirt VM Service Set (Windows Python)"
* Removed "oVirt VM Service Set (Windows)"
* Removed "PostgreSQL 9.6 Service Set"
* Removed tags "redhat7" and "redhat8", because there are also "rhel7" and "rhel8"


### Added

Features:

* Linuxfabrik Monitoring Plugins [SELinux Type Enforcement Policies](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/assets/selinux/linuxfabrik-monitoring-plugins.te)
* Add new sudoers files for Alma 9, RHEL 9, Rocky 9, Fedora 37, Oracle 7, Oracle 8, Oracle 9 ([#627](https://github.com/Linuxfabrik/monitoring-plugins/issues/627) and more)

Monitoring Plugins:

* crypto-policy
* csv-values
* grassfish-licenses
* grassfish-players
* grassfish-screens
* infomaniak-events
* journald-query
* journald-usage
* ntp-chronyd (from "ntp-offset: Split it into three different ntp-checks ([#449](https://github.com/Linuxfabrik/monitoring-plugins/issues/449))")
* ntp-ntpd (from "ntp-offset: Split it into three different ntp-checks ([#449](https://github.com/Linuxfabrik/monitoring-plugins/issues/449))")
* ntp-systemd-timesyncd (from "ntp-offset: Split it into three different ntp-checks ([#449](https://github.com/Linuxfabrik/monitoring-plugins/issues/449))")
* restic-check
* restic-snapshots
* restic-stats
* systemd-timedate-status
* tuned-profile

Notification Plugins:

* notify-host-rocketchat-telegram
* notify-host-zoom
* notify-service-rocketchat-telegram

Icinga Director:

* AIDE Service Set
* All RHEL-based Basic Service Sets: Systemd Unit - debug-shell.service
* Apache Service Set for Debian 11 ([#534](https://github.com/Linuxfabrik/monitoring-plugins/issues/534))")
* Basic Service Set for Debian 11 ([#533](https://github.com/Linuxfabrik/monitoring-plugins/issues/533))")
* FreeIPA Server Service Set
* Grav Service Set
* Ubuntu 22 Service Set
* UPS Service Set (Network UPS Tools, nut)


### Changed

Features:

* Enhanced sudoers files

Monitoring Plugins:

* about-me3: Add detection of restic
* about-me3: Add detection of Snap
* about-me3: Add Maker and Model ([#637](https://github.com/Linuxfabrik/monitoring-plugins/issues/637))
* about-me3: Improve detection of coturn
* about-me3: Improve psutil error handling
* about-me3: Make external IP search configurable with 3rd party providers (and disabled by default) ([#645](https://github.com/Linuxfabrik/monitoring-plugins/issues/645)) 
* about-me3: Re-written from scratch, now also recommends tags for our Icinga Director Basket. New parameter `--tags`.
* about-me3: Remove unstable bonding detection
* [disk-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/disk-usage/): Move state output to usage column
* dmesg3: add additional message to ignorelist
* docker-info3: Report more info in case of failures
* docker-stats3: Report more info in case of failures
* [fs-ro](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/fs-ro/): Exclude squashfs filesystems ([#412](https://github.com/Linuxfabrik/monitoring-plugins/issues/412))
* [fs-ro](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/fs-ro/): Ignore ramfs ([#617](https://github.com/Linuxfabrik/monitoring-plugins/issues/617))
* infomaniak-swiss-backup-\*: Apply new API version
* [journald-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/journald-usage/): Increase DEFAULT_WARN to 6 GiB
* matomo-reporting3: Perfdata now is also aware of percentages
* [mysql-connections](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-connections/): add --ignore-name-resolution ([#631](https://github.com/Linuxfabrik/monitoring-plugins/issues/631))
* mysql-storage-engines3: Improve recognition of schema.table
* [mysql-user-security](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-user-security/): Ignore mysql.sys and mariadb.sys users
* [network-connections](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/network-connections/): Alert if there's more than a specified number of conns ([#621](https://github.com/Linuxfabrik/monitoring-plugins/issues/621))
* php-status3: Improve output in case of startup/config/module errors
* php-status3: URL to monitoring.php should be optional
* [php-version](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/php-version/): Add PHP 8.3
* qts-version3: Add support for firmware 5.0.1+
* [redis-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/redis-status/): Do not warn on "Peak memory"
* [rpm-lastactivity](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/rpm-lastactivity/): do | sort | tail -1 with Python Code ([#94](https://github.com/Linuxfabrik/monitoring-plugins/issues/94))
* service3: Now able to check multiple windows services at once ([#609](https://github.com/Linuxfabrik/monitoring-plugins/issues/609))

Icinga Director:

* Enhanced RHEL 7+ and Fedora-based Service Sets by TuneD Profile
* Enhanced RHEL 8+-based Service Sets by Crypto Policy
* Enhanced all Service Sets checking for a Systemd Service by an according Journald Query
* Enhanced all Service Sets checking for a Systemd Service by Systemd TimeDate Status
* Notifications are enabled only for critical hardware-related services (assuming you want to stay up at 2 a.m.)
* Split up the MariaDB/MySQL service sets into smaller sets:

    * MySQL/MariaDB InnoDB Service Set
    * MySQL/MariaDB Metrics Service Set
    * MySQL/MariaDB Replication Service Set
    * MySQL/MariaDB Schemas Service Set
    * MySQL/MariaDB Security Service Set
    * MySQL/MariaDB Service Set


### Fixed

Monitoring Plugins:

* [disk-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/disk-usage/): ignore type CDFS by default ([#632](https://github.com/Linuxfabrik/monitoring-plugins/issues/632))
* docker-stats missing shortening of containername in perfdata output ([#600](https://github.com/Linuxfabrik/monitoring-plugins/issues/600))
* [file-age](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/file-age/): critical reported for new files because modification time is negative or not set ([#618](https://github.com/Linuxfabrik/monitoring-plugins/issues/618))
* infomaniak-swiss-backup-devices3: Fix TypeError: unsupported operand type(s) for -: 'int' and 'NoneType'
* [librenms-version](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/librenms-version/): KeyError: 'mysql_ver' ([#602](https://github.com/Linuxfabrik/monitoring-plugins/issues/602))
* matomo-reporting3: --metric - Got more information back instead one metric ([#603](https://github.com/Linuxfabrik/monitoring-plugins/issues/603))
* [nextcloud-stats](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/nextcloud-stats/): Fix error non-existing ALWAYS_OK Attribute ([#640](https://github.com/Linuxfabrik/monitoring-plugins/pull/640))
* [ping](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/ping/): ping -t has to be int but its float ([#628](https://github.com/Linuxfabrik/monitoring-plugins/issues/628))
* [rpm-lastactivity](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/rpm-lastactivity/): ValueError: invalid literal for int() with base 10: '' ([#616](https://github.com/Linuxfabrik/monitoring-plugins/issues/616))
* [systemd-timedate-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/systemd-timedate-status/): UNKNOWN with "unknown operation show" on RHEL7 ([#605](https://github.com/Linuxfabrik/monitoring-plugins/issues/605))
* [updates](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/updates/): On Windows with closed firewall a PowerShell error is returned ([#633](https://github.com/Linuxfabrik/monitoring-plugins/issues/633))


### Removed

Features:

* All plugins: Remove code for self-handling Python virtual environments (venv). ([#543](https://github.com/Linuxfabrik/monitoring-plugins/issues/543))")

Monitoring Plugins:

* ntp-offset (due to "ntp-offset: Split it into three different ntp-checks ([#449](https://github.com/Linuxfabrik/monitoring-plugins/issues/449))")

Icinga Director:

* Remove DiagTrack from Windows Service Sets, since it's windows telemetry



## [2022072001] - 2022-07-20

### Breaking Changes

*  wildfly-memory-pool-usage: Flapping PS_Eden_Space reporting ([#563](https://github.com/Linuxfabrik/monitoring-plugins/issues/563)) - Removed `--warning` and `--critical` parameters (not needed anymore)


### Added

Features:

* This CHANGELOG.
* Add hidden `.windows` files as indication for automatic compilation on/for Windows systems.
* Add sudoers file for Fedora 35 and Fedora 36.

Monitoring Plugins:

* diacos ([PR #567](https://github.com/Linuxfabrik/monitoring-plugins/pull/567), thanks to [Dominik Riva](https://github.com/slalomsk8er))
* infomaniak-swiss-backup-devices
* infomaniak-swiss-backup-products
* mysql-aria
* mysql-binlog-cache
* mysql-connections
* mysql-database-metrics
* mysql-innodb-buffer-pool-instances
* mysql-innodb-buffer-pool-size
* mysql-innodb-log-waits
* mysql-joins
* mysql-logfile
* mysql-memory
* mysql-open-files
* mysql-perf-metrics
* mysql-replica-status
* mysql-slow-queries
* mysql-sorts
* mysql-storage-systems
* mysql-system
* mysql-table-cache
* mysql-table-definition-cache
* mysql-table-indexes
* mysql-temp-tables
* mysql-thread-cache
* mysql-traffic
* mysql-user-security
* nodebb-cache
* nodebb-database
* nodebb-errors
* nodebb-events
* nodebb-groups
* nodebb-info
* nodebb-users
* strongswan-connections
* xml (replacement for "wsdl" check from [PR #583](https://github.com/Linuxfabrik/monitoring-plugins/pull/583), thanks to [Dominik Riva](https://github.com/slalomsk8er))

Icinga Director:

* duplicity Service Set
* strongSwan Service Set


### Changed

Monitoring Plugins:

* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): Add AIDE ([#546](https://github.com/Linuxfabrik/monitoring-plugins/issues/546))
* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): Add Birthdate ([#554](https://github.com/Linuxfabrik/monitoring-plugins/issues/554))
* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): Add certbot and acme.sh ([#433](https://github.com/Linuxfabrik/monitoring-plugins/issues/433))
* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): Add gpg ([#511](https://github.com/Linuxfabrik/monitoring-plugins/issues/511))
* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): Add list of listening ports ([#538](https://github.com/Linuxfabrik/monitoring-plugins/issues/538))
* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): Add mod_security ([#496](https://github.com/Linuxfabrik/monitoring-plugins/issues/496))
* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): Add swanctl ([#575](https://github.com/Linuxfabrik/monitoring-plugins/issues/575))
* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): Print its own version ([#439](https://github.com/Linuxfabrik/monitoring-plugins/issues/439))
* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): Report active tuned-Profile in first line if tuned.service is found and running ([#374](https://github.com/Linuxfabrik/monitoring-plugins/issues/374))
* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): Report Boot Mode ([#562](https://github.com/Linuxfabrik/monitoring-plugins/issues/562)) 
* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): Show key features of the Machine ([#561](https://github.com/Linuxfabrik/monitoring-plugins/issues/561))
* All checks using SQLite databases: More unique sqlite db names ([#333](https://github.com/Linuxfabrik/monitoring-plugins/issues/333))
* [apache-httpd-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/apache-httpd-status/): New parameter `--insecure`
* [cpu-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/cpu-usage/): Subtract the "nice" percentage from thresholds ([#550](https://github.com/Linuxfabrik/monitoring-plugins/issues/550))
* [dhcp-scope-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/dhcp-scope-usage/): Parse PercentageInUse locale-aware ([PR #551](https://github.com/Linuxfabrik/monitoring-plugins/pull/551))
* [disk-io](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/disk-io/): Checks if psutil has a certain minimum version on systems with kernel 4.18+.
* [disk-smart](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/disk-smart/): Exclude zfs-volumes ([PR #539](https://github.com/Linuxfabrik/monitoring-plugins/pull/539))
* [disk-smart](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/disk-smart/): Now also runs on Windows ([PR #553](https://github.com/Linuxfabrik/monitoring-plugins/pull/553))
* [disk-smart](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/disk-smart/): Properly handle Power_On_Hours_and_Msec attribute perfdata parsing ([PR #549](https://github.com/Linuxfabrik/monitoring-plugins/pull/549))
* [disk-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/disk-usage/): Critical but first line of plugin output prints "OK" ([#545](https://github.com/Linuxfabrik/monitoring-plugins/issues/545))
* [docker-info](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/docker-info/): Raise CRIT on return code != 0 ([#569](https://github.com/Linuxfabrik/monitoring-plugins/issues/569))
* [docker-stats](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/docker-stats/): Improve handling of container names ([#586](https://github.com/Linuxfabrik/monitoring-plugins/issues/586)). New parameter `--full-name`.
* [file-age](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/file-age/): Improve perfdata labels
* [file-age](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/file-age/): Performance data aggregation on file_age check ([PR #544](https://github.com/Linuxfabrik/monitoring-plugins/pull/544))
* [file-age](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/file-age/): shorten the message ([#559](https://github.com/Linuxfabrik/monitoring-plugins/issues/559))
* infomaniak-swiss-backup-devices3: Increase default thresholds from 80/90% to 90/95%
* infomaniak-swiss-backup-devices3: Sort output table by "Tags" column
* infomaniak-swiss-backup-products3: Changed thresholds from 14/5 days to 6/3 days
* infomaniak-swiss-backup-products3: Sort output table by "Tags" column
* [ipmi-sel](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/ipmi-sel/): Change the order of events ([#558](https://github.com/Linuxfabrik/monitoring-plugins/issues/558))
* needs-restarting3: Debian Buster/bullseye command not found ([#572](https://github.com/Linuxfabrik/monitoring-plugins/issues/572))
* [php-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/php-status/): Add a "--dev" switch to not warn on display_errors=On and display_startup_errors=On ([#461](https://github.com/Linuxfabrik/monitoring-plugins/issues/461))
* [php-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/php-status/): Change behavior when handling default values ([#540](https://github.com/Linuxfabrik/monitoring-plugins/issues/540))
* qts-\*: Increase default connect timeout from 3 to 6 seconds
* Revert Python 3.6+ `f`-strings to use `.format()` to be more conservative
* [systemd-units-failed](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/systemd-units-failed/): Allow wildcards for the `--ignore` parameter ([#542](https://github.com/Linuxfabrik/monitoring-plugins/issues/542))

Icinga Director:

* Adjust windows director definitions to the new folder structure
* Increase windows service check intervals


### Fixed

Monitoring Plugins:

* disk-io3: Fix python3 lib calls
* file-count3: Traceback: KeyError: 'lib'  ([#591](https://github.com/Linuxfabrik/monitoring-plugins/issues/591))
* fortios-memory-usage3: Change urllib.quote to urllib.parse.quote ([PR #599](https://github.com/Linuxfabrik/monitoring-plugins/pull/599))
* logfile3: "Database locked" and "UNKNOWN" in case of massive usage on a host ([#578](https://github.com/Linuxfabrik/monitoring-plugins/issues/578))
* keycloak-version3: AttributeError: 'NoneType' object has no attribute 'group' ([#555](https://github.com/Linuxfabrik/monitoring-plugins/issues/555))
* xca-cert3: Checks expiry date again


### Removed

Monitoring Plugins:

* mysql-stats
* nodebb-stats
* nodebb-status

Icinga Director:

* Remove gpsvc on Windows



## [2022030201] - 2022-03-02

This is a "we migrated everything from GitLab to GitHub, but had to adjust many details afterwards" version. **In terms of source code, nothing has changed** compared to 2022022801, just a bunch of links in source code comments and READMEs.



## 2022022801 - 2022-02-28

### Breaking Changes

* This is the last release including bugfixes for the Python 2 variant of all checks.
* This project has moved from a public repo on our self-hosted GitLab server to a [public repo on GitHub](https://github.com/linuxfabrik/monitoring-plugins) to increase visibility and reach a larger community.
* The Git branches "master" and "develop" no longer exist - in the future we will only work with the "main" branch and create releases based on tags.
* Due to the removal of binaries (zip and png files), all commit hashes have changed.
* Removed all checks compiled for Windows from Git and moved them to our [download server](https://download.linuxfabrik.ch//monitoring-plugins/windows).


### Added

Monitoring Plugins:

* IPv4 scope usage for a Windows DHCP server service (running on Windows using PowerShell, or remotely on Linux or Windows using WinRM).
* Huawei OceanStor Dorado storage system: Status of backup power modules (Backup Battery Unit (BBU)), controller, disk basic status and performance data, enclosure information, plus basic information about fans, interfaces, power, attached hosts, the system itself, HyperMetro domain and pairing information.
* Redfish-based BMCs (instead of IPMI): drives, system event logs (SEL) and sensor data.

Notification Plugins:

* Notify via Zoom
* Notify via E-Mail

Icinga Director:

* Active Directory Certificate Services Service Set ([#472](https://github.com/Linuxfabrik/monitoring-plugins/issues/472))
* Active Directory Domain Services Service Set ([#468](https://github.com/Linuxfabrik/monitoring-plugins/issues/468))
* Active Directory Federation Services Service Set ([#471](https://github.com/Linuxfabrik/monitoring-plugins/issues/471))
* Active Directory Lightweight Directory Services Service Set ([#473](https://github.com/Linuxfabrik/monitoring-plugins/issues/473))
* acme.sh Service Set ([#447](https://github.com/Linuxfabrik/monitoring-plugins/issues/447))
* DHCP Server Service Set ([#466](https://github.com/Linuxfabrik/monitoring-plugins/issues/466))
* DHCP Server Failover Feature Service Set ([#467](https://github.com/Linuxfabrik/monitoring-plugins/issues/467))
* [dhcp-scope-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/dhcp-scope-usage/): add Icinga Director configuration
* DNS Server Service Set ([#470](https://github.com/Linuxfabrik/monitoring-plugins/issues/470))
* Duplicati Service Set
* Huawei Dorado Service Set
* Redfish Service Set
* Redfish no agent Service Set
* tpl-service-cert and tpl-service-cert-no-agent service templates
* Veeam Backup & Replication Service Set ([#464](https://github.com/Linuxfabrik/monitoring-plugins/issues/464))
* Web Server (IIS) Service Set ([#465](https://github.com/Linuxfabrik/monitoring-plugins/issues/465))
* Windows Basic Service Set extended Service Set
* Windows Defender Antivirus Service Service Set ([#469](https://github.com/Linuxfabrik/monitoring-plugins/issues/469))

Assets:

* Rocky 8 sudoers
* openSUSE Leap 15 sudoers


### Changed

Monitoring Plugins:

* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): add ownCloud and alternate Nextcloud Path ([#512](https://github.com/Linuxfabrik/monitoring-plugins/issues/512))
* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): report virtualisation ([#480](https://github.com/Linuxfabrik/monitoring-plugins/issues/480))
* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): run even if psutil is or cannot be installed ([#514](https://github.com/Linuxfabrik/monitoring-plugins/issues/514))
* all plugins: adapt to pylinted libraries ([#526](https://github.com/Linuxfabrik/monitoring-plugins/issues/526))
* all plugins: let the new txt3 library do all encoding and decoding ([#507](https://github.com/Linuxfabrik/monitoring-plugins/issues/507))
* all plugins: pylint all check plugins ([#529](https://github.com/Linuxfabrik/monitoring-plugins/issues/529))
* all plugins: use new library "human.py" ([#521](https://github.com/Linuxfabrik/monitoring-plugins/issues/521))
* all plugins: use new library "shell3.py" ([#525](https://github.com/Linuxfabrik/monitoring-plugins/issues/525))
* all plugins: use new library "time3.py" ([#524](https://github.com/Linuxfabrik/monitoring-plugins/issues/524))
* all plugins: use new library "txt3.py" ([#522](https://github.com/Linuxfabrik/monitoring-plugins/issues/522))
* [dhcp-scope-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/dhcp-scope-usage/): add WinRM capability ([#477](https://github.com/Linuxfabrik/monitoring-plugins/issues/477))
* [file-age](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/file-age/): recompiled for windows
* librenms checks: add more filtering parameters
* [librenms-alerts](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/librenms-alerts/): add `--device-group` parameter
* [librenms-health](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/librenms-health/): adjust check timeout
* [nginx-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/nginx-status/): print human readable total values ([#520](https://github.com/Linuxfabrik/monitoring-plugins/issues/520))
* [php-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/php-status/): hint when not running with sudo ([#459](https://github.com/Linuxfabrik/monitoring-plugins/issues/459))
* [redis-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/redis-status/): make more tolerant when it comes to Defragmentation ([#425](https://github.com/Linuxfabrik/monitoring-plugins/issues/425))
* [redis-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/redis-status/): support Redis 3.0 ([#510](https://github.com/Linuxfabrik/monitoring-plugins/issues/510))
* [redis-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/redis-status/): only warn if cache hit rate < 10% ([#490](https://github.com/Linuxfabrik/monitoring-plugins/issues/490))
* [redis-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/redis-status/): warn on bad OS configuration ([#428](https://github.com/Linuxfabrik/monitoring-plugins/issues/428))
* [rocketchat-stats](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/rocketchat-stats/): rename rocket.chat to rocketchat ([#335](https://github.com/Linuxfabrik/monitoring-plugins/issues/335))
* [swap-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/swap-usage/): don't display "swapped in" and "swapped out" on Windows ([#454](https://github.com/Linuxfabrik/monitoring-plugins/issues/454))
* [veeam-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/veeam-status/): make `--username` and `--password` mandatory ([#499](https://github.com/Linuxfabrik/monitoring-plugins/issues/499))
* [wildfly-deployment-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/wildfly-deployment-status/): allow to limit deployment by name ([#497](https://github.com/Linuxfabrik/monitoring-plugins/issues/497))

Icinga Director:

* all-the-rest.json: adjust loolwsd to coolwsd
* all-the-rest.json: adjust director baskets for the new Windows variants
* all-the-rest.json: adjust Huawei service names
* all-the-rest.json: enable notifications for Redfish checks
* all-the-rest.json: extend Windows Basic Service Set
* all-the-rest.json: ensure the no-agent and sudo variants are based on Linux
* all-the-rest.json: split up LibreNMS services by type in the Service Set
* [getent](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/getent/): increase Icinga timeout to 30 sec ([#455](https://github.com/Linuxfabrik/monitoring-plugins/issues/455))

Tools:

* check2basket: extend to support notification-plugins


### Fixed

Monitoring Plugins:

* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): Open Virtual Machine Tools Error: vmtoolsd must be run inside a virtual machine on a VMware hypervisor product ([#513](https://github.com/Linuxfabrik/monitoring-plugins/issues/513))
* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): Traceback "IndexError: list index out of range" ([#443](https://github.com/Linuxfabrik/monitoring-plugins/issues/443))
* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): Traceback 'ModuleWrapper' object has no attribute 'net_if_addrs' ([#438](https://github.com/Linuxfabrik/monitoring-plugins/issues/438))
* [apache-httpd-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/apache-httpd-status/): Traceback on Ubuntu Xenial (16.04) ([#436](https://github.com/Linuxfabrik/monitoring-plugins/issues/436))
* [borgbackup](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/borgbackup/): AttributeError: 'str' object has no attribute 'decode' ([#430](https://github.com/Linuxfabrik/monitoring-plugins/issues/430))
* [disk-smart](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/disk-smart/): disk names like sdda, sdab and so on were not checked ([#487](https://github.com/Linuxfabrik/monitoring-plugins/issues/487))
* [file-age](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/file-age/): new files or modifications after now result in files from the future ([#478](https://github.com/Linuxfabrik/monitoring-plugins/issues/478))
* [file-age](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/file-age/): Windows variant crashes if using a glob wildcard ([#494](https://github.com/Linuxfabrik/monitoring-plugins/issues/494))
* [fs-xfs-stats](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/fs-xfs-stats/): I/O error "No such file or directory" while opening or reading /proc/fs/xfs/stat ([#445](https://github.com/Linuxfabrik/monitoring-plugins/issues/445))
* jitsi-videobridge-status3: TypeError: string indices must be integers ([#527](https://github.com/Linuxfabrik/monitoring-plugins/issues/527))
* [librenms-health](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/librenms-health/): timeout on too many values ([#365](https://github.com/Linuxfabrik/monitoring-plugins/issues/365))
* mysql-stats: Traceback ([#170](https://github.com/Linuxfabrik/monitoring-plugins/issues/170))
* nextcloud-stats3: TypeError: a bytes-like object is required, not 'str' ([#517](https://github.com/Linuxfabrik/monitoring-plugins/issues/517))
* nextcloud-stats3: TypeError: string argument without an encoding ([#531](https://github.com/Linuxfabrik/monitoring-plugins/issues/531))
* [nextcloud-stats](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/nextcloud-stats/): DB size is reported using YiB ([#463](https://github.com/Linuxfabrik/monitoring-plugins/issues/463))
* nextcloud-version3: put get_owner() from base3 in here ([#523](https://github.com/Linuxfabrik/monitoring-plugins/issues/523))
* nginx-status3: ModuleNotFoundError: No module named 'lib.globals2' ([#515](https://github.com/Linuxfabrik/monitoring-plugins/issues/515))
* [nginx-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/nginx-status/): wrong perfdata ([#440](https://github.com/Linuxfabrik/monitoring-plugins/issues/440))
* ntp-offset: regular UNKNOWN when using with chrony ([#71](https://github.com/Linuxfabrik/monitoring-plugins/issues/71))
* php-status3: SyntaxError: invalid syntax ([#532](https://github.com/Linuxfabrik/monitoring-plugins/issues/532))
* [php-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/php-status/): On some machines, display_startup_errors is N/A ([#434](https://github.com/Linuxfabrik/monitoring-plugins/issues/434))
* [php-version](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/php-version/): Warns "PHP v7.4.25 is available (installed: v7.4.24)", but should not ([#435](https://github.com/Linuxfabrik/monitoring-plugins/issues/435))
* procs (Windows): Traceback "AttributeError: module object has no attribute STATUS_PARKED" ([#453](https://github.com/Linuxfabrik/monitoring-plugins/issues/453))
* procs3: on Windows, it always returns `oldest proc created 52Y 1M ago` ([#506](https://github.com/Linuxfabrik/monitoring-plugins/issues/506))
* [procs](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/procs/): when checking if a process exists, returns OK even if the process is missing ([#488](https://github.com/Linuxfabrik/monitoring-plugins/issues/488))
* [redfish-sensor](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/redfish-sensor/): returns 404 against ESXi ([#460](https://github.com/Linuxfabrik/monitoring-plugins/issues/460))
* redis-status3: AttributeError: module lib has no attribute "disk2" ([#498](https://github.com/Linuxfabrik/monitoring-plugins/issues/498))
* [redis-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/redis-status/): mistakenly reports "net.core.somaxconn is lower than net.ipv4.tcp_max_syn_backlog [WARNING]" ([#458](https://github.com/Linuxfabrik/monitoring-plugins/issues/458))
* [redis-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/redis-status/): Redis requires more memory than available and is forced to use swap ([#486](https://github.com/Linuxfabrik/monitoring-plugins/issues/486))
* [redis-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/redis-status/): warning when using a password on command line ([#450](https://github.com/Linuxfabrik/monitoring-plugins/issues/450))
* [swap-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/swap-usage/): recompiled for Windows ([#454](https://github.com/Linuxfabrik/monitoring-plugins/issues/454)), ([#456](https://github.com/Linuxfabrik/monitoring-plugins/issues/456))
* [swap-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/swap-usage/): UnboundLocalError: local variable msg_body referenced before assignment ([#456](https://github.com/Linuxfabrik/monitoring-plugins/issues/456))
* [systemd-unit](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/systemd-unit/): on Fedora, failed Units are printed with all columns shifted one to the right ([#328](https://github.com/Linuxfabrik/monitoring-plugins/issues/328))
* [systemd-unit](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/systemd-unit/): UnitFileState is "", but supposed to be "empty" ([#509](https://github.com/Linuxfabrik/monitoring-plugins/issues/509))
* [users](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/users/): on Windows: UnicodeDecodeError: 'utf-8' codec can't decode byte 0x81 in position 25: invalid start byte ([#451](https://github.com/Linuxfabrik/monitoring-plugins/issues/451))
* [users](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/users/): quote the output because of possible pipe symbol in "WHAT" column ([#17](https://github.com/Linuxfabrik/monitoring-plugins/issues/17))
* veeam.py: ValueError: need more than 2 values to unpack ([#45](https://github.com/Linuxfabrik/monitoring-plugins/issues/45))
* Windows-compiled plugins are shipped without required 3rd party Python modules ([#504](https://github.com/Linuxfabrik/monitoring-plugins/issues/504))

Icinga Director:

* all-the-rest.json: fix GUIDs

Grafana:

* [dns](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/dns/): Grafana Panels divide query time by 1000 ([#453](https://github.com/Linuxfabrik/monitoring-plugins/issues/453))
* [fail2ban](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/fail2ban/): Grafana Panels list "Banned IPs" twice ([#139](https://github.com/Linuxfabrik/monitoring-plugins/issues/139))
* [fortios-network-io](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/fortios-network-io/): fix Grafana dashboard name

Tools:

* basket-join: allow missing Datafield key
* basket-join: fix error on duplicate entries in JSON
* check2basket: abort on error with the `--auto` option
* check2basket: add workaround for notification-plugins
* check2basket: fix problem with notification-plugins


### Removed

Icinga Director:

* all-the-rest.json: delete SysMain from Windows Service Set ([#446](https://github.com/Linuxfabrik/monitoring-plugins/issues/446))
* all-the-rest.json: remove getent from the basic Service Sets
* all-the-rest.json: disable TimeBrokerSvc ([#427](https://github.com/Linuxfabrik/monitoring-plugins/issues/427))

Tools:

* check2basket: remove default states for notifications




## 2021101401 - 2021-10-14

### Added

Features:

* All of the checks are ported to Python 3 (suffixed by `3`).
* Most of the checks are also available on Windows (compiled with Nuitka and suffixed by `.zip`).
* At the same time the style of the source code of all plugins has been unified according to the example check plugin.
* All plugins run flawlessly on Rocky and Alma Linux (simply so that was said).

Monitoring Plugins:

* Jitsi Videobridge Statistics and Status
* NodeBB Statistics, Status and Version
* Redis
* SAP Open Concur (thanks to [Dominik Riva](https://github.com/slalomsk8er))
* Starface PBX: Account, Database and Peer Statistics; Overall, Backup and Channel Status; Java Memory Usage
* Veeam Status

Event Plugins:

* Cloudflare Security Level

Icinga Director:

* Four checks have been added to the Windows Basic ServiceSet (disk-io, dns, swap-usage, top3-processes-which-caused-the-most-io)


### Changed

Monitoring Plugins:

* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): Reports much much more inventory info. New sections are Interfaces (IPv4), systemd default target, systemd timers, systemd enabled units, systemd mounts, systemd automounts, non-default users and crontabs.
* [apache-httpd-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/apache-httpd-status/): Now calculates the average values ReqPerSec, BytesPerSec, BytesPerReq and DurationPerReq over Apache's uptime.
* php-\*: Report more (don't forget to install the new `monitoring.php` as well).
* [procs](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/procs/): Counting is more accurate.
* [ping](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/ping/): Mainly used for host alive checking, now reports OK on request (using `--always-ok`) if a host cannot be reached for some reason only on the ping side, but can otherwise be checked e.g. by the Icinga agent.


### Changed

Monitoring Plugins:

* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): add content of os family /etc/release file ([#319](https://github.com/Linuxfabrik/monitoring-plugins/issues/319))
* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): add GCC detection ([#306](https://github.com/Linuxfabrik/monitoring-plugins/issues/306))
* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): add GitLab Community Edition (Omnibus) detection ([#371](https://github.com/Linuxfabrik/monitoring-plugins/issues/371))
* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): add OpenVPN detection ([#341](https://github.com/Linuxfabrik/monitoring-plugins/issues/341))
* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): add the FQDN hostname to the first line ([#368](https://github.com/Linuxfabrik/monitoring-plugins/issues/368))
* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): add Veeam detection ([#315](https://github.com/Linuxfabrik/monitoring-plugins/issues/315))
* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): add vsftpd detection ([#269](https://github.com/Linuxfabrik/monitoring-plugins/issues/269))
* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): extend with more infos ([#362](https://github.com/Linuxfabrik/monitoring-plugins/issues/362))
* all plugins: add Python 3 versions for apache-httpd-stats ([#327](https://github.com/Linuxfabrik/monitoring-plugins/issues/327)), axenita-stats ([#376](https://github.com/Linuxfabrik/monitoring-plugins/issues/376)), borgbackup ([#287](https://github.com/Linuxfabrik/monitoring-plugins/issues/287)), countdown ([#377](https://github.com/Linuxfabrik/monitoring-plugins/issues/377)), disk-smart ([#401](https://github.com/Linuxfabrik/monitoring-plugins/issues/401)), docker-info ([#378](https://github.com/Linuxfabrik/monitoring-plugins/issues/378)), dummy ([#379](https://github.com/Linuxfabrik/monitoring-plugins/issues/379)), fail2ban ([#380](https://github.com/Linuxfabrik/monitoring-plugins/issues/380)), feed ([#402](https://github.com/Linuxfabrik/monitoring-plugins/issues/402)), file-count ([#381](https://github.com/Linuxfabrik/monitoring-plugins/issues/381)), fortios-\* ([#424](https://github.com/Linuxfabrik/monitoring-plugins/issues/424)), ipmi-sel ([#384](https://github.com/Linuxfabrik/monitoring-plugins/issues/384)), ipmi-sensor ([#385](https://github.com/Linuxfabrik/monitoring-plugins/issues/385)), kemp-services ([#403](https://github.com/Linuxfabrik/monitoring-plugins/issues/403)), keycloak-version ([#400](https://github.com/Linuxfabrik/monitoring-plugins/issues/400)), kvm-vm ([#388](https://github.com/Linuxfabrik/monitoring-plugins/issues/388)), librenms-alerts ([#389](https://github.com/Linuxfabrik/monitoring-plugins/issues/389)), librenms-health ([#390](https://github.com/Linuxfabrik/monitoring-plugins/issues/390)), librenms-version ([#314](https://github.com/Linuxfabrik/monitoring-plugins/issues/314)), mailq ([#391](https://github.com/Linuxfabrik/monitoring-plugins/issues/391)), matomo-reporting ([#405](https://github.com/Linuxfabrik/monitoring-plugins/issues/405)), matomo-version ([#406](https://github.com/Linuxfabrik/monitoring-plugins/issues/406)), metabase-stats ([#342](https://github.com/Linuxfabrik/monitoring-plugins/issues/342)), mysql-stats ([#407](https://github.com/Linuxfabrik/monitoring-plugins/issues/407)), needs-restarting ([#393](https://github.com/Linuxfabrik/monitoring-plugins/issues/393)), network-bonding ([#409](https://github.com/Linuxfabrik/monitoring-plugins/issues/409)), network-port-tcp ([#410](https://github.com/Linuxfabrik/monitoring-plugins/issues/410)), nextcloud-security-scan ([#411](https://github.com/Linuxfabrik/monitoring-plugins/issues/411)), nextcloud-stats ([#413](https://github.com/Linuxfabrik/monitoring-plugins/issues/413)), nginx-status ([#414](https://github.com/Linuxfabrik/monitoring-plugins/issues/414)), ntp-offset ([#387](https://github.com/Linuxfabrik/monitoring-plugins/issues/387)), onlyoffice-stats ([#394](https://github.com/Linuxfabrik/monitoring-plugins/issues/394)), openvpn-client-list ([#395](https://github.com/Linuxfabrik/monitoring-plugins/issues/395)), ping ([#348](https://github.com/Linuxfabrik/monitoring-plugins/issues/348)), qts-\* ([#423](https://github.com/Linuxfabrik/monitoring-plugins/issues/423)), rocketchat-stats ([#415](https://github.com/Linuxfabrik/monitoring-plugins/issues/415)), rocketchat-version ([#416](https://github.com/Linuxfabrik/monitoring-plugins/issues/416)), sensors-battery ([#418](https://github.com/Linuxfabrik/monitoring-plugins/issues/418)), sensors-temperature ([#419](https://github.com/Linuxfabrik/monitoring-plugins/issues/419)), wordpress-version ([#382](https://github.com/Linuxfabrik/monitoring-plugins/issues/382)), xca-cert ([#375](https://github.com/Linuxfabrik/monitoring-plugins/issues/375))
* all plugins: adapt source code to example plugin for file-size ([#398](https://github.com/Linuxfabrik/monitoring-plugins/issues/398)), json-values ([#399](https://github.com/Linuxfabrik/monitoring-plugins/issues/399)), logfile ([#404](https://github.com/Linuxfabrik/monitoring-plugins/issues/404)), scheduled-task ([#417](https://github.com/Linuxfabrik/monitoring-plugins/issues/417)), service ([#386](https://github.com/Linuxfabrik/monitoring-plugins/issues/386)), snmp ([#396](https://github.com/Linuxfabrik/monitoring-plugins/issues/396)), updates ([#383](https://github.com/Linuxfabrik/monitoring-plugins/issues/383)), wildfly-\* ([#422](https://github.com/Linuxfabrik/monitoring-plugins/issues/422))
* all plugins: consistently handle unicode ([#334](https://github.com/Linuxfabrik/monitoring-plugins/issues/334))
* all plugins: make usage of `--help` possible even if some Python modules are missing ([#42](https://github.com/Linuxfabrik/monitoring-plugins/issues/42))
* all plugins: remove unnecessary import of lib.args ([#347](https://github.com/Linuxfabrik/monitoring-plugins/issues/347))
* all plugins: replace `print()` by `oao()` for consistent unicode handling ([#344](https://github.com/Linuxfabrik/monitoring-plugins/issues/344))
* all plugins: replace unit test code by new "test" library ([#343](https://github.com/Linuxfabrik/monitoring-plugins/issues/343))
* all plugins: save with UTF-8 encoding ([#305](https://github.com/Linuxfabrik/monitoring-plugins/issues/305))
* all plugins: use `lib.base.cu()` instead of `print_exc()` ([#345](https://github.com/Linuxfabrik/monitoring-plugins/issues/345))
* all plugins: validate automatically converted Python 3 variants ([#359](https://github.com/Linuxfabrik/monitoring-plugins/issues/359))
* [apache-httpd-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/apache-httpd-status/): also print worker percentage state in table ([#311](https://github.com/Linuxfabrik/monitoring-plugins/issues/311))
* [borgbackup](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/borgbackup/): no need to open Borg logfile in binary mode ([#420](https://github.com/Linuxfabrik/monitoring-plugins/issues/420))
* cloudflare-security-level: make `--zone-id` repeatable ([#309](https://github.com/Linuxfabrik/monitoring-plugins/issues/309))
* [disk-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/disk-usage/): add `--ignore` parameter (repeating) ([#351](https://github.com/Linuxfabrik/monitoring-plugins/issues/351))
* [dmesg](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/dmesg/): add "brcmfmac" messages to ignore list ([#338](https://github.com/Linuxfabrik/monitoring-plugins/issues/338))
* [dmesg](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/dmesg/): add `--ignore` parameter (repeating) ([#340](https://github.com/Linuxfabrik/monitoring-plugins/issues/340))
* [dmesg](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/dmesg/): reduce the output to a maximum of ten lines ([#254](https://github.com/Linuxfabrik/monitoring-plugins/issues/254))
* [example](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/example/): provide unit-tests ([#326](https://github.com/Linuxfabrik/monitoring-plugins/issues/326))
* [file-age](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/file-age/): improve output message ([#361](https://github.com/Linuxfabrik/monitoring-plugins/issues/361))
* [file-ownership](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/file-ownership/): check /tmp/linuxfabrik-plugin-cache.db ([#356](https://github.com/Linuxfabrik/monitoring-plugins/issues/356))
* [file-ownership](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/file-ownership/): fix defaults for Debian ([#294](https://github.com/Linuxfabrik/monitoring-plugins/issues/294)), SLES ([#317](https://github.com/Linuxfabrik/monitoring-plugins/issues/317)) and Ubuntu ([#332](https://github.com/Linuxfabrik/monitoring-plugins/issues/332))
* [getent](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/getent/): also print the response ([#297](https://github.com/Linuxfabrik/monitoring-plugins/issues/297))
* [openvpn-client-list](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/openvpn-client-list/): no need to open OpenVPN logfile in binary mode ([#421](https://github.com/Linuxfabrik/monitoring-plugins/issues/421))
* [php-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/php-status/): improve config and module error messages ([#267](https://github.com/Linuxfabrik/monitoring-plugins/issues/267))
* [php-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/php-status/): make check for a high Cache "Hit Rate" optional ([#303](https://github.com/Linuxfabrik/monitoring-plugins/issues/303))
* [php-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/php-status/): print php.ini "Off" and "On" values as "Off" and "On" ([#325](https://github.com/Linuxfabrik/monitoring-plugins/issues/325))
* [php-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/php-status/): remove "simplexml" from default module list ([#284](https://github.com/Linuxfabrik/monitoring-plugins/issues/284))
* [php-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/php-status/): report more opcache-settings in output table ([#353](https://github.com/Linuxfabrik/monitoring-plugins/issues/353))
* [php-version](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/php-version/): just check on PHP version Major.Minor (default), not Major.Minor.Patch ([#304](https://github.com/Linuxfabrik/monitoring-plugins/issues/304))
* [php-version](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/php-version/): test against package manager, print version from php.net just as a hint ([#253](https://github.com/Linuxfabrik/monitoring-plugins/issues/253))
* [ping](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/ping/): add `--always-ok` for unpingable but check-capable hosts ([#392](https://github.com/Linuxfabrik/monitoring-plugins/issues/392))
* [procs](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/procs/): alert on specific processes ([#355](https://github.com/Linuxfabrik/monitoring-plugins/issues/355))
* [systemd-unit](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/systemd-unit/): the `--unitfilestate` parameter should accept None to disable checking of the unit file state ([#299](https://github.com/Linuxfabrik/monitoring-plugins/issues/299))
* [systemd-units-failed](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/systemd-units-failed/): add `--ignore` parameter (repeating) ([#160](https://github.com/Linuxfabrik/monitoring-plugins/issues/160), [#337](https://github.com/Linuxfabrik/monitoring-plugins/issues/337))
* [wildfly-gc-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/wildfly-gc-status/): increase default values for `avr_gc_time` ([#307](https://github.com/Linuxfabrik/monitoring-plugins/issues/307))
* [wildfly-gc-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/wildfly-gc-status/): refactor check ([#308](https://github.com/Linuxfabrik/monitoring-plugins/issues/308))
* [wildfly-memory-pool-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/wildfly-memory-pool-usage/): don't alert on "PS_Survivor_Space" (if it exists) ([#286](https://github.com/Linuxfabrik/monitoring-plugins/issues/286))

Icinga Director:

* provide the Icinga Director command definitions using the basket ([#301](https://github.com/Linuxfabrik/monitoring-plugins/issues/301))

Tools:

* check2basket: add update mode ([#203](https://github.com/Linuxfabrik/monitoring-plugins/issues/203))


### Fixed

Monitoring Plugins:

* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): only last disk is shown ([#281](https://github.com/Linuxfabrik/monitoring-plugins/issues/281))
* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): remove newline after printing "vsftpd" ([#364](https://github.com/Linuxfabrik/monitoring-plugins/issues/364))
* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): reports loolwsd even if it is not installed ([#370](https://github.com/Linuxfabrik/monitoring-plugins/issues/370))
* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): too many values to unpack ([#372](https://github.com/Linuxfabrik/monitoring-plugins/issues/372))
* [apache-httpd-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/apache-httpd-status/): ReqPerSec, BytesPerSec, BytesPerReq and DurationPerReq are average values calculated by Apache over its uptime ([#310](https://github.com/Linuxfabrik/monitoring-plugins/issues/310))
* [apache-httpd-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/apache-httpd-status/): unsupported operand type(s) for +: 'float' and 'str' ([#323](https://github.com/Linuxfabrik/monitoring-plugins/issues/323))
* [disk-io](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/disk-io/): after reboot, byte values are 0 or very low, so rate diffs are negative ([#312](https://github.com/Linuxfabrik/monitoring-plugins/issues/312))
* dmesg3: AttributeError: module 'lib' has no attribute 'base2' ([#330](https://github.com/Linuxfabrik/monitoring-plugins/issues/330))
* [dmesg](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/dmesg/): always counts +1 ([#331](https://github.com/Linuxfabrik/monitoring-plugins/issues/331))
* [dummy](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/dummy/): broken in dev branch ([#354](https://github.com/Linuxfabrik/monitoring-plugins/issues/354))
* example3: partially uses base2 library ([#369](https://github.com/Linuxfabrik/monitoring-plugins/issues/369))
* [file-age](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/file-age/): correctly handle negative times ([#188](https://github.com/Linuxfabrik/monitoring-plugins/issues/188))
* [getent](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/getent/): ascii codec can't decode byte ([#367](https://github.com/Linuxfabrik/monitoring-plugins/issues/367))
* [mydumper-version](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mydumper-version/): 'module' object has no attribute 'url2' ([#322](https://github.com/Linuxfabrik/monitoring-plugins/issues/322))
* [mydumper-version](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mydumper-version/): stumbles upon "v0.10.7-2" ([#318](https://github.com/Linuxfabrik/monitoring-plugins/issues/318))
* [network-port-tcp](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/network-port-tcp/): NameError: global name 'TYPE' is not defined ([#298](https://github.com/Linuxfabrik/monitoring-plugins/issues/298))
* [php-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/php-status/): monitoring.php does not run on PHP 7.2 ([#289](https://github.com/Linuxfabrik/monitoring-plugins/issues/289))
* [php-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/php-status/): reporting "Opcache not installed or not enabled" if monitoring.php is not used ([#324](https://github.com/Linuxfabrik/monitoring-plugins/issues/324))
* [php-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/php-status/): typo in output ("Opache") ([#296](https://github.com/Linuxfabrik/monitoring-plugins/issues/296))
* [php-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/php-status/): Uncaught Error: Call to undefined function opcache_get_status() ([#290](https://github.com/Linuxfabrik/monitoring-plugins/issues/290))
* [php-version](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/php-version/): ValueError: invalid literal for float(): 5.640-0+deb8u12 ([#293](https://github.com/Linuxfabrik/monitoring-plugins/issues/293))
* [procs](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/procs/): counting in output seems to be wrong ([#357](https://github.com/Linuxfabrik/monitoring-plugins/issues/357))
* [procs](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/procs/): NameError: name 'STATE_Ok' is not defined ([#363](https://github.com/Linuxfabrik/monitoring-plugins/issues/363))
* [qts-temperatures](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/qts-temperatures/): Traceback ([#360](https://github.com/Linuxfabrik/monitoring-plugins/issues/360))
* [service](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/service/): bad output/status if status is 'running' but not supposed to be 'running' ([#336](https://github.com/Linuxfabrik/monitoring-plugins/issues/336))
* systemd-units: UnitFileState might be empty ("") ([#292](https://github.com/Linuxfabrik/monitoring-plugins/issues/292))
* unit tests: fix failing tests ([#346](https://github.com/Linuxfabrik/monitoring-plugins/issues/346))


### Removed

Monitoring Plugins:

* We [removed](https://github.com/Linuxfabrik/monitoring-plugins/-/commit/661758831108a86a2a92f784aa0997c7286b0e07) the fah-stats, hostname and all Atlassian checks.



## 2021061501 - 2021-06-15

### Added

Features:

* 50% of the checks are ported to Python 3 (suffixed by `3`), 17 checks of those available on Windows (compiled with Nuitka and suffixed by `.zip`).
* The human-readable units of measurement in the output of the checks are more precise, for example:

    * Bytes: "MiB" always means "Mebibyte" = 1024 Kibibytes.
    * Counters: The SI symbol "G" means "Billion" in "US, Canada and modern British", and "Milliard" in "Traditional European (long scale)".
    * Date and Time: "M" means "Month" while "m" means "Minute".
    * See [README for further details](https://github.com/Linuxfabrik/monitoring-plugins).

* We are using more and more Prometheus-compatible Performance Data Names (first checks doing this are fs-xfs-stats and nginx-status).
* All README's have been revised, standardized and converted into RST format (reStructuredText). They are also available on https://docs.linuxfabrik.ch > Monitoring-Plugins.
* Icons have been updated (useful for Icingaweb and other).

Monitoring Plugins:

* Apache mod_qos
* Docker Info and Statistics
* Filesystem XFS Statistics
* HAProxy Status
* LibreNMS Alerts and Version
* Logfiles (although we prefer using Graylog)
* Metabase Statistics
* mydumper Version
* Nginx Status
* OnlyOffice Statistics
* Path read/write test
* PHP Status and Version
* PHP-FPM Status and Availability
* pip for pending updates
* SNMP (although we prefer using LibreNMS)
* WildFly Deployment Status, Garbage Collector Status, Memory and Memory Pool Usage, Server Status, Thread Usage, Uptime, XA and Non-XA Datasource Statistics


### Changed

Monitoring Plugins:

* [disk-io](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/disk-io/): Automatically determines the maximum possible disk throughput.
* file-\*: Deal directly with SMB/CIFS shares.
* ipmi-\*: Can now connect remotely to Supermicro's IPMI, HPE iLo and DELL iDRAC.


### Changed

Monitoring Plugins:

* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): add detection of Django ([#196](https://github.com/Linuxfabrik/monitoring-plugins/issues/196)), LibreNMS ([#195](https://github.com/Linuxfabrik/monitoring-plugins/issues/195)), mydumper ([#202](https://github.com/Linuxfabrik/monitoring-plugins/issues/202)), Nikto ([#197](https://github.com/Linuxfabrik/monitoring-plugins/issues/197)), OpenSSL-version ([#164](https://github.com/Linuxfabrik/monitoring-plugins/issues/164)), OpenVAS ([#194](https://github.com/Linuxfabrik/monitoring-plugins/issues/194)), tmate ([#175](https://github.com/Linuxfabrik/monitoring-plugins/issues/175)) and more software ([#171](https://github.com/Linuxfabrik/monitoring-plugins/issues/171))
* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): extend PHP version checking ([#136](https://github.com/Linuxfabrik/monitoring-plugins/issues/136)), improve version checking ([#172](https://github.com/Linuxfabrik/monitoring-plugins/issues/172))
* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): ignore zram devices ([#227](https://github.com/Linuxfabrik/monitoring-plugins/issues/227))
* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): report CentOS version in perfdata ([#137](https://github.com/Linuxfabrik/monitoring-plugins/issues/137))
* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): show "Local IP Address/Subnet" and "Public IP Address" ([#256](https://github.com/Linuxfabrik/monitoring-plugins/issues/256))
* all plugins: add Python 3 versions for dmesg ([#239](https://github.com/Linuxfabrik/monitoring-plugins/issues/239)), dns ([#229](https://github.com/Linuxfabrik/monitoring-plugins/issues/229)), file-descriptors ([#230](https://github.com/Linuxfabrik/monitoring-plugins/issues/230)), file-ownership ([#232](https://github.com/Linuxfabrik/monitoring-plugins/issues/232)), fs-inodes ([#274](https://github.com/Linuxfabrik/monitoring-plugins/issues/274)), fs-ro ([#236](https://github.com/Linuxfabrik/monitoring-plugins/issues/236)), getent ([#237](https://github.com/Linuxfabrik/monitoring-plugins/issues/237)), load ([#240](https://github.com/Linuxfabrik/monitoring-plugins/issues/240)), rpm-lastactivity ([#241](https://github.com/Linuxfabrik/monitoring-plugins/issues/241)), selinux-mode ([#275](https://github.com/Linuxfabrik/monitoring-plugins/issues/275)), swap-usage ([#242](https://github.com/Linuxfabrik/monitoring-plugins/issues/242)), systemd-unit ([#243](https://github.com/Linuxfabrik/monitoring-plugins/issues/243)), systemd-units-failed ([#244](https://github.com/Linuxfabrik/monitoring-plugins/issues/244)), top3-processes-which-caused-the-most-io ([#273](https://github.com/Linuxfabrik/monitoring-plugins/issues/273))
* all plugins: implement the `*_or_none` arguments ([#116](https://github.com/Linuxfabrik/monitoring-plugins/issues/116))
* [apache-httpd-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/apache-httpd-status/): clean up code ([#200](https://github.com/Linuxfabrik/monitoring-plugins/issues/200))
* [apache-httpd-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/apache-httpd-status/): make "total accesses" human-readable ([#219](https://github.com/Linuxfabrik/monitoring-plugins/issues/219))
* [axenita-stats](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/axenita-stats/): add version number to perfdata ([#184](https://github.com/Linuxfabrik/monitoring-plugins/issues/184))
* [cpu-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/cpu-usage/): migrate top3-processes-which-consumed-the-most-cpu-time into cpu-usage ([#248](https://github.com/Linuxfabrik/monitoring-plugins/issues/248))
* [cpu-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/cpu-usage/): state in the README the different values' units ([#209](https://github.com/Linuxfabrik/monitoring-plugins/issues/209))
* [disk-io](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/disk-io/): "State" belongs only to overusage of "RWx", remove separate column ([#279](https://github.com/Linuxfabrik/monitoring-plugins/issues/279))
* [disk-smart](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/disk-smart/): print "* sdc (model, ser) [CRIT]" instead of "* [CRIT] sdc (model, ser)" ([#214](https://github.com/Linuxfabrik/monitoring-plugins/issues/214))
* [dmesg](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/dmesg/): add messages to ignore list ([#192](https://github.com/Linuxfabrik/monitoring-plugins/issues/192), [#216](https://github.com/Linuxfabrik/monitoring-plugins/issues/216), [#270](https://github.com/Linuxfabrik/monitoring-plugins/issues/270))
* [dmesg](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/dmesg/): add severity parameter ([#115](https://github.com/Linuxfabrik/monitoring-plugins/issues/115))
* [dmesg](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/dmesg/): reduce the output to a maximum of ten lines ([#254](https://github.com/Linuxfabrik/monitoring-plugins/issues/254))
* [dmesg](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/dmesg/): use `--ctime` instead of `--reltime` ([#238](https://github.com/Linuxfabrik/monitoring-plugins/issues/238))
* [feed](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/feed/): change behaviour, do not fetch feed items from the future ([#95](https://github.com/Linuxfabrik/monitoring-plugins/issues/95), [#208](https://github.com/Linuxfabrik/monitoring-plugins/issues/208))
* [feed](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/feed/): in Atom feed, try "content" field when summary is not available ([#207](https://github.com/Linuxfabrik/monitoring-plugins/issues/207))
* [feed](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/feed/): strip HTML from content ([#206](https://github.com/Linuxfabrik/monitoring-plugins/issues/206))
* [file-descriptors](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/file-descriptors/): migrate top3-processes-opening-more-file-descriptors into file-descriptors ([#247](https://github.com/Linuxfabrik/monitoring-plugins/issues/247))
* [file-ownership](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/file-ownership/): add files according to CIS CentOS standard ([#233](https://github.com/Linuxfabrik/monitoring-plugins/issues/233))
* [file-ownership](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/file-ownership/): make the `--filename` parameter repeatable ([#6](https://github.com/Linuxfabrik/monitoring-plugins/issues/6))
* [file-ownership](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/file-ownership/): print file, owner and group as table ([#231](https://github.com/Linuxfabrik/monitoring-plugins/issues/231))
* fortios-\*: add the ability to specify a port ([#186](https://github.com/Linuxfabrik/monitoring-plugins/issues/186))
* fortios-\*: HTTP-encode the password/access_token ([#187](https://github.com/Linuxfabrik/monitoring-plugins/issues/187))
* [fs-ro](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/fs-ro/): make `--ignore` parameter repeatable ([#235](https://github.com/Linuxfabrik/monitoring-plugins/issues/235))
* [ipmi-sel](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/ipmi-sel/): make it usable against targets over the network ([#169](https://github.com/Linuxfabrik/monitoring-plugins/issues/169))
* ipmi-sensors: make it usable against targets over the network ([#168](https://github.com/Linuxfabrik/monitoring-plugins/issues/168))
* [kemp-services](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/kemp-services/): add port option ([#189](https://github.com/Linuxfabrik/monitoring-plugins/issues/189))
* [memory-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/memory-usage/): migrate top3-processes into memory-usage ([#246](https://github.com/Linuxfabrik/monitoring-plugins/issues/246))
* [memory-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/memory-usage/): unify v2 and v3 ([#245](https://github.com/Linuxfabrik/monitoring-plugins/issues/245))
* [network-connections](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/network-connections/): unify v2 and v3 ([#250](https://github.com/Linuxfabrik/monitoring-plugins/issues/250))
* [nextcloud-version](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/nextcloud-version/): get apache user from owner of config/config.php ([#225](https://github.com/Linuxfabrik/monitoring-plugins/issues/225))
* [nextcloud-version](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/nextcloud-version/): review handling of Enterprise Channel ([#142](https://github.com/Linuxfabrik/monitoring-plugins/issues/142))
* [nginx-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/nginx-status/): make perfdata compatible to Prometheus ([#271](https://github.com/Linuxfabrik/monitoring-plugins/issues/271))
* [php-fpm-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/php-fpm-status/): rename col "ContLen" to "POST" ([#211](https://github.com/Linuxfabrik/monitoring-plugins/issues/211))
* [php-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/php-status/): improve config and module error messages ([#267](https://github.com/Linuxfabrik/monitoring-plugins/issues/267))
* [php-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/php-status/): remove "shmop" and "zip" from default module list ([#215](https://github.com/Linuxfabrik/monitoring-plugins/issues/215), [#266](https://github.com/Linuxfabrik/monitoring-plugins/issues/266))
* [pip-updates](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/pip-updates/): change "No venv." to "Not running in a venv." ([#268](https://github.com/Linuxfabrik/monitoring-plugins/issues/268))
* [procs](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/procs/): always return perfdata for process memory usage ([#264](https://github.com/Linuxfabrik/monitoring-plugins/issues/264))
* [procs](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/procs/): improve output ([#255](https://github.com/Linuxfabrik/monitoring-plugins/issues/255))
* [procs](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/procs/): make filter for username, procname and arguments case-insensitive ([#261](https://github.com/Linuxfabrik/monitoring-plugins/issues/261))
* [procs](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/procs/): show used filter in output ([#263](https://github.com/Linuxfabrik/monitoring-plugins/issues/263))
* [wildfly-gc-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/wildfly-gc-status/): collection-time and -count in perfdata are continuous counters ([#185](https://github.com/Linuxfabrik/monitoring-plugins/issues/185))
* [wildfly-memory-pool-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/wildfly-memory-pool-usage/): refactor code to better distinguish between heap and non-heap ([#183](https://github.com/Linuxfabrik/monitoring-plugins/issues/183))


### Fixed

Monitoring Plugins:

* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): disk sizes are not shown on CentOS ([#259](https://github.com/Linuxfabrik/monitoring-plugins/issues/259))
* [apache-httpd-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/apache-httpd-status/): struggles about html pages served via HTTP, containing "::" ([#199](https://github.com/Linuxfabrik/monitoring-plugins/issues/199))
* [disk-io](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/disk-io/): if RW5 is < 0, set it to 0 ([#265](https://github.com/Linuxfabrik/monitoring-plugins/issues/265))
* [disk-smart](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/disk-smart/): ignore zram devices ([#221](https://github.com/Linuxfabrik/monitoring-plugins/issues/221))
* [disk-smart](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/disk-smart/): SyntaxError: invalid syntax, line 890 ([#220](https://github.com/Linuxfabrik/monitoring-plugins/issues/220))
* [docker-info](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/docker-info/): Byte-UOM must be "B", not "b" ([#180](https://github.com/Linuxfabrik/monitoring-plugins/issues/180))
* [docker-info](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/docker-info/): perfdata "ram" must be in "bytes" ([#179](https://github.com/Linuxfabrik/monitoring-plugins/issues/179))
* [docker-stats](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/docker-stats/): Byte-UOM must be "B", not "b" ([#181](https://github.com/Linuxfabrik/monitoring-plugins/issues/181))
* [docker-stats](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/docker-stats/): I/O values not usable ([#277](https://github.com/Linuxfabrik/monitoring-plugins/issues/277))
* [docker-stats](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/docker-stats/): remove "host_mem_usage", because counting is wrong ([#276](https://github.com/Linuxfabrik/monitoring-plugins/issues/276))
* [feed](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/feed/): sometimes runs into 10s Plugin Timeout in Icinga and gets killed with UNKNOWN ([#83](https://github.com/Linuxfabrik/monitoring-plugins/issues/83))
* haproxy-stats3: TypeError: a bytes-like object is required, not "str" ([#278](https://github.com/Linuxfabrik/monitoring-plugins/issues/278))
* [librenms-version](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/librenms-version/): KeyError: "local_branch" ([#204](https://github.com/Linuxfabrik/monitoring-plugins/issues/204))
* [nextcloud-stats](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/nextcloud-stats/): num_users counts every user who ever existed ([#224](https://github.com/Linuxfabrik/monitoring-plugins/issues/224))
* [php-fpm-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/php-fpm-status/): request duration is in us, not ms ([#210](https://github.com/Linuxfabrik/monitoring-plugins/issues/210))
* [php-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/php-status/): check status is printed without leading space ([#257](https://github.com/Linuxfabrik/monitoring-plugins/issues/257))
* [php-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/php-status/): don't set WARN threshold for Hit Rate in Perfdata ([#251](https://github.com/Linuxfabrik/monitoring-plugins/issues/251))
* [php-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/php-status/): opcache_hit_rate - WARN and CRIT are swapped ([#226](https://github.com/Linuxfabrik/monitoring-plugins/issues/226))
* [procs](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/procs/): checking processes on CPU usage is wrong ([#260](https://github.com/Linuxfabrik/monitoring-plugins/issues/260))
* [procs](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/procs/): several unknowns and tracebacks ([#162](https://github.com/Linuxfabrik/monitoring-plugins/issues/162), [#166](https://github.com/Linuxfabrik/monitoring-plugins/issues/166))
* [users](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/users/): "utf-8" codec can't decode byte 0x81 on Windows ([#201](https://github.com/Linuxfabrik/monitoring-plugins/issues/201))


### Removed

Monitoring Plugins:

* fs-file-usage: replaced by file-descriptors ([#234](https://github.com/Linuxfabrik/monitoring-plugins/issues/234))
* Three of the four "Top 3" checks are merged into cpu-usage, file-descriptors and memory-usage.



## 2021021701 - 2021-02-17

### Fixed

Monitoring Plugins:

* virtualenv is not activated if the plugin is called using an absolute path / from a different directory ([#154](https://github.com/Linuxfabrik/monitoring-plugins/issues/154))



## 2021021601 - 2021-02-16

### Added

Features:

* Added support for using a virtual environment (see README)


### Changed

Monitoring Plugins:

* file-age, file-count & file-size: Now support SMB.
* [users](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/users/): Added missing perfdata for Windows.
* [nextcloud-version](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/nextcloud-version/): throw UNKNOWN if update server is not available ([#147](https://github.com/Linuxfabrik/monitoring-plugins/issues/147))
* [nextcloud-version](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/nextcloud-version/): increase timeout for fetching the update server ([#148](https://github.com/Linuxfabrik/monitoring-plugins/issues/148))
* [procs](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/procs/): added thresholds for cpu & memory

### Fixed

Monitoring Plugins:

* json: renamed to json-values due to collision with the official json library.
* pip-version: fixed mixup in the output message.



## 2020122401 - 2020-12-24

### Added

Monitoring Plugins:

* cpu-usage (for Windows)
* disk-usage (for Windows)
* dummy
* dummy (for Windows)
* file-age (for Windows)
* file-count
* file-count (for Windows)
* file-size (for Windows)
* json
* json (for Windows)
* memory-usage (for Windows)
* network-connections (for Windows)
* procs (for Windows)
* scheduled-task (for Windows)
* service (for Windows)
* updates (for Windows)
* uptime (for Windows)
* users (for Windows)


### Changed

Monitoring Plugins:

* [file-age](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/file-age/): Now support globbing for selecting multiple files.
* [file-size](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/file-size/): Now support globbing for selecting multiple files.
* [updates](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/updates/): Added the --always-ok parameter.


### Fixed

* [users](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/users/): Fixed the counting of user under Windows (it also includes disconnected users now)




## 2020112001 - 2020-11-20

### Changed

Monitoring Plugins:

* [systemd-unit](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/systemd-unit/): added more states



## 2020111901 - 2020-11-19

### Fixed

Monitoring Plugins:

* ntp-offset: error on server without ntp ([#138](https://github.com/Linuxfabrik/monitoring-plugins/issues/138))



## 2020111801 - 2020-11-18

### Added

Features:

* Added sudoers for Debian 9 and 10


### Fixed

Monitoring Plugins:

* [dns](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/dns/): traceback ([#132](https://github.com/Linuxfabrik/monitoring-plugins/issues/132))
* disk-usage3: traceback ([#133](https://github.com/Linuxfabrik/monitoring-plugins/issues/133))
* ntp-offset: Wrong logic ([#134](https://github.com/Linuxfabrik/monitoring-plugins/issues/134))



## 2020102301 - 2020-10-23

### Breaking Changes

* This update restructures our GitLab repository and adds the first Windows-compatible python3 check plugins.


### Added

Features:

* We added a new utility to help generate Grafana Dashboards: grafana-tool. Check out the documentation for more infomation.

Monitoring Plugins:

* atlassian-confluence-version
* atlassian-jira-version
* cpu-usage (for Windows)
* disk-usage (for Windows)
* file-age (for Windows)
* file-size (for Windows)
* keycloak-version
* memory-usage (for Windows)
* network-connections (for Windows)
* pip-version
* procs (for Windows)
* qts-cpu-usage
* qts-disk-smart
* qts-memory-usage
* qts-temperatures
* qts-uptime
* qts-version
* scheduled-task (for Windows)
* service (for Windows)
* updates (for Windows)
* uptime (for Windows)
* users (for Windows)
* wordpress-version


### Changed

Features:

* We unified all the sudoers into one file (for each OS), in the assets/sudoers folder.

Monitoring Plugins:

* [borgbackup](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/borgbackup/): changed the expected string in the logfile from rc to retc.
* [feed](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/feed/): removed --no-icinga-callback, added --icinga-callback.
* [procs](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/procs/): new --argument parameter.


### Fixed

Monitoring Plugins:

* [feed](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/feed/): python traceback ([#107](https://github.com/Linuxfabrik/monitoring-plugins/issues/107))
* [memory-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/memory-usage/): Print top3 memory consuming processes in case of WARN/CRIT ([#108](https://github.com/Linuxfabrik/monitoring-plugins/issues/108))
* ntp-offset: add systemd-timesyncd ([#90](https://github.com/Linuxfabrik/monitoring-plugins/issues/90))
* [openvpn-client-list](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/openvpn-client-list/): output as table ([#19](https://github.com/Linuxfabrik/monitoring-plugins/issues/19))
* [qts-version](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/qts-version/): "None" after update ([#112](https://github.com/Linuxfabrik/monitoring-plugins/issues/112))
* [xca-cert](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/xca-cert/): Print a list of all checked certs with "commonName, CA (y/n), Serial, Expiry date" starting at the second line ([#65](https://github.com/Linuxfabrik/monitoring-plugins/issues/65))



## 2020061901 - 2020-06-19

### Added

Monitoring Plugins:

* network-bonding


### Changed

Monitoring Plugins:

* [procs](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/procs/): new username parameter


### Fixed

Monitoring Plugins:

* [nextcloud-version](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/nextcloud-version/): AttributeError: NoneType object has no attribute group ([#105](https://github.com/Linuxfabrik/monitoring-plugins/issues/105))



## 2020052801 - 2020-05-28

### Added

Monitoring Plugins:

* fortios-cpu-usage
* fortios-firewall-stats
* fortios-ha-stats
* fortios-memory-usage
* fortios-network-io
* fortios-sensor
* fortios-version
* fs-ro
* kemp-services
* matomo-reporting
* matomo-version
* sensors-battery
* sensors-fans
* sensors-temperatures
* systemd-units-failed


### Changed

Features:

* Most of the checks now also run on Ubuntu Server 16+.
* On stack traces, any token and password URL request parameters are now printed with asterisks.
* All checks calling shell commands force english output even if system locale is different.


### Fixed

Monitoring Plugins:

* [disk-smart](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/disk-smart/): Traceback if not running on hardware ([#82](https://github.com/Linuxfabrik/monitoring-plugins/issues/82))
* [disk-io](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/disk-io/): Counts n loop Devices on Ubuntu 20 ([#87](https://github.com/Linuxfabrik/monitoring-plugins/issues/87))
* [disk-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/disk-usage/): ignore snap Devices ([#88](https://github.com/Linuxfabrik/monitoring-plugins/issues/88))
* [mailq](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mailq/): Test with Exim ([#93](https://github.com/Linuxfabrik/monitoring-plugins/issues/93))
* [procs](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/procs/): total proc count in perfdata is always 0 ([#96](https://github.com/Linuxfabrik/monitoring-plugins/issues/96))
* [apache-httpd-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/apache-httpd-status/): Traceback on Ubuntu 16 ([#97](https://github.com/Linuxfabrik/monitoring-plugins/issues/97))
* [disk-io](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/disk-io/): Traceback on Ubuntu 16 ([#98](https://github.com/Linuxfabrik/monitoring-plugins/issues/98))
* [nextcloud-version](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/nextcloud-version/): Don't throw UNKNOWN if update server is not available, because it doesn't help at all ([#99](https://github.com/Linuxfabrik/monitoring-plugins/issues/99))
* [disk-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/disk-usage/): ignore iso9660 devices ([#100](https://github.com/Linuxfabrik/monitoring-plugins/issues/100))
* [apache-httpd-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/apache-httpd-status/): Report if server-info is malformed due to any reason ([#101](https://github.com/Linuxfabrik/monitoring-plugins/issues/101))
* sensors-temperature: Ignore psutil's IOError ([#102](https://github.com/Linuxfabrik/monitoring-plugins/issues/102))



## 2020042001 - 2020-04-20

### Added

Features:

* Most of the checks now also run on Ubuntu (tested on Ubuntu Server 20 Beta).

Monitoring Plugins:

* dns
* fah-stats


### Fixed

Monitoring Plugins:

* [nextcloud-security-scan](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/nextcloud-security-scan/): missing urllib ([#91](https://github.com/Linuxfabrik/monitoring-plugins/issues/91))
* [about-me](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/about-me/): doesn't report details about NVMe disks ([#89](https://github.com/Linuxfabrik/monitoring-plugins/issues/89))
* [ping](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/ping/): no duplicate Output; maybe switch to regex ([#84](https://github.com/Linuxfabrik/monitoring-plugins/issues/84))



## 2020041501 - 2020-04-15

### Added

Features:

* We refactored the whole library stack and adapted all checks to the new library standards.
* We started using docstrings for better documentation of libraries and plugins. Now its possible to use for example `pydoc cache` to get a description of the cache.py library.

Monitoring Plugins:

* getent
* nextcloud-version
* ping
* rocket.chat-version


### Removed

Monitoring Plugins:

* docker-info, docker-container, network-io, redis, xca-cert for now. We will rewrite them from scratch soon.



## 2020031201 - 2020-03-12

### Added

Monitoring Plugins:

* feed

### Changed

Monitoring Plugins:

* [cpu-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/cpu-usage/): Adjusted to changes in psutil
* [dmesg](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/dmesg/): expanded the ignore list
* [systemd-unit](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/systemd-unit/): improved output



## 2020022801 - 2020-02-28

Initial release for the general public.


[Unreleased]: https://github.com/Linuxfabrik/monitoring-plugins/compare/v6.0.0...HEAD
[v6.0.0]: https://github.com/Linuxfabrik/monitoring-plugins/compare/v5.2.0...v6.0.0
[v5.2.0]: https://github.com/Linuxfabrik/monitoring-plugins/compare/v5.1.0...v5.2.0
[v5.1.0]: https://github.com/Linuxfabrik/monitoring-plugins/compare/v5.0.0...v5.1.0
[v5.0.0]: https://github.com/Linuxfabrik/monitoring-plugins/compare/v4.1.0...v5.0.0
[v4.1.0]: https://github.com/Linuxfabrik/monitoring-plugins/compare/v4.0.0...v4.1.0
[v4.0.0]: https://github.com/Linuxfabrik/monitoring-plugins/compare/v3.0.0...v4.0.0
[v3.0.0]: https://github.com/Linuxfabrik/monitoring-plugins/compare/v2.2.1...v3.0.0
[v2.2.1]: https://github.com/Linuxfabrik/monitoring-plugins/compare/v2.2.0...v2.2.1
[v2.2.0]: https://github.com/Linuxfabrik/monitoring-plugins/compare/v2.1.1...v2.2.0
[v2.1.1]: https://github.com/Linuxfabrik/monitoring-plugins/compare/v2.1.0...v2.1.1
[v2.1.0]: https://github.com/Linuxfabrik/monitoring-plugins/compare/v2.0.0...v2.1.0
[v2.0.0]: https://github.com/Linuxfabrik/monitoring-plugins/compare/v1.2.0.11...v2.0.0
[v1.2.0.11]: https://github.com/Linuxfabrik/monitoring-plugins/compare/2024060401...v1.2.0.11
[2024060401]: https://github.com/Linuxfabrik/monitoring-plugins/compare/2024052901...2024060401
[2024052901]: https://github.com/Linuxfabrik/monitoring-plugins/compare/2023112901...2024052901
[2023112901]: https://github.com/Linuxfabrik/monitoring-plugins/compare/2023051201...2023112901
[2023051201]: https://github.com/Linuxfabrik/monitoring-plugins/compare/2023030801...2023051201
[2023030801]: https://github.com/Linuxfabrik/monitoring-plugins/compare/2022072001...2023030801
[2022072001]: https://github.com/Linuxfabrik/monitoring-plugins/compare/2022030201...2022072001
[2022030201]: https://github.com/Linuxfabrik/monitoring-plugins/compare/2022022801...2022030201
[2022022801]: https://github.com/Linuxfabrik/monitoring-plugins/compare/2021101401...2022022801
[2021101401]: https://github.com/Linuxfabrik/monitoring-plugins/compare/2021061501...2021101401
[2021061501]: https://github.com/Linuxfabrik/monitoring-plugins/compare/2021021701...2021061501
[2021021701]: https://github.com/Linuxfabrik/monitoring-plugins/compare/2021021601...2021021701
[2021021601]: https://github.com/Linuxfabrik/monitoring-plugins/compare/2020122401...2021021601
[2020122401]: https://github.com/Linuxfabrik/monitoring-plugins/compare/2020112001...2020122401
[2020112001]: https://github.com/Linuxfabrik/monitoring-plugins/compare/2020111901...2020112001
[2020111901]: https://github.com/Linuxfabrik/monitoring-plugins/compare/2020111801...2020111901
[2020111801]: https://github.com/Linuxfabrik/monitoring-plugins/compare/2020102301...2020111801
[2020102301]: https://github.com/Linuxfabrik/monitoring-plugins/compare/2020061901...2020102301
[2020061901]: https://github.com/Linuxfabrik/monitoring-plugins/compare/2020052801...2020061901
[2020052801]: https://github.com/Linuxfabrik/monitoring-plugins/compare/2020042001...2020052801
[2020042001]: https://github.com/Linuxfabrik/monitoring-plugins/compare/2020041501...2020042001
[2020041501]: https://github.com/Linuxfabrik/monitoring-plugins/compare/2020031201...2020041501
[2020031201]: https://github.com/Linuxfabrik/monitoring-plugins/compare/2020022801...2020031201
[2020022801]: https://github.com/Linuxfabrik/monitoring-plugins/releases/tag/2020022801
