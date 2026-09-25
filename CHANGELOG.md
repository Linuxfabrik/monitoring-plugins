# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [Unreleased]

### Fixed

Build, CI/CD:

* RPM: plugins no longer fail with `EOFError: marshal data too short` ([#1543](https://github.com/Linuxfabrik/monitoring-plugins/issues/1543))

### Security

Monitoring Plugins:

* apache-httpd-security, nginx-security: `--command` runs only a root-owned binary, closing a local root code execution
* docker-service, docker-swarm: `--test` no longer reveals which files exist on the host
* fail2ban: `--socket` accepts only a root-owned socket, closing a local root code execution
* logfile, \*-logfile, openvpn-client-list: a swapped directory can no longer redirect the read out of `/var/log`
* nextcloud-\*: `--path` no longer lets a local user run code as root or probe for files
* strongswan-connections: `--socket` accepts only a root-owned socket, and a hung charon yields WARN instead of a hang ([GHSA-cw8h-7h72-79v8](https://github.com/Linuxfabrik/monitoring-plugins/security/advisories/GHSA-cw8h-7h72-79v8))


## [v8.0.0] - 2026-09-23

**Highlights:** A hung network filesystem no longer takes a check down with it. More than thirty new checks cover LVM, software RAID, multipath, NFS, KVM guests, pressure stall information, server logs and the hardening of Apache httpd and NGINX. Several Director parameters, host tags and Service Sets change, so read the Breaking Changes first. `fail2ban` and `kdump` close a local privilege escalation.

### Breaking Changes

Monitoring Plugins:

* file-age, file-size: no longer run through sudo, grant the monitoring user read access where needed
* huawei-dorado-controller: `--warning` and `--critical` cover CPU only, set `--warning-mem` and `--critical-mem` for memory
* huawei-dorado-port: checks front-end and cluster ports only, add `--include-backend` for the others
* podman-stats: block and network I/O are rates under new metric names, adjust your graphs ([#1519](https://github.com/Linuxfabrik/monitoring-plugins/issues/1519))
* sudoers: split in two, a hand-deployed setup also needs `*-logging.sudoers` ([#1493](https://github.com/Linuxfabrik/monitoring-plugins/issues/1493))
* whmcs-status: `--url` is required, and a missing health check no longer counts as healthy

Icinga Director:

* Deb Updates, RPM Updates: also alert on ordinary updates after a grace period, tick `Only Critical` for the old behaviour
* delete the leftover `tpl-service-cert` that uses `cmd-check-url` ([#1474](https://github.com/Linuxfabrik/monitoring-plugins/issues/1474))
* Journald Query, Logfile, MySQL Logfile: `Ignore Pattern` / `Ignore Regex` become `Ignore` (regex), and MySQL Logfile's `Server Log` has to be re-entered
* KVM Host Service Set: tag your hypervisors `libvirtd` or `virtqemud`
* MySQL Database Metrics, Storage Engines, Table Indexes: `Ignore Schemas` / `Ignore Tables` become `Match` / `Ignore`
* the `rpm-updates` tag and Service Set are gone, the check is part of the Basic Service Sets

### Added

Monitoring Plugins:

* acmesh-status: expiring acme.sh certificates and stalled renewals
* apache-httpd-disclosure: what an Apache httpd server gives away about itself ([#373](https://github.com/Linuxfabrik/monitoring-plugins/issues/373))
* apache-httpd-logfile: problems in the Apache httpd error log
* apache-httpd-security: hardening of a local Apache httpd ([#373](https://github.com/Linuxfabrik/monitoring-plugins/issues/373))
* avelon-tickets: open alarm tickets in the Avelon Cloud ([#770](https://github.com/Linuxfabrik/monitoring-plugins/issues/770))
* conntrack: a filling netfilter connection tracking table
* cpu-vulnerabilities: unmitigated CPU vulnerabilities
* file-growth: a file growing or shrinking too fast ([#48](https://github.com/Linuxfabrik/monitoring-plugins/issues/48))
* fs-mounts: filesystems from `/etc/fstab` that are not mounted
* huawei-dorado-quota: shares filling up their quota
* kvm-cpu-usage: CPU usage and steal time per virtual machine ([#644](https://github.com/Linuxfabrik/monitoring-plugins/issues/644))
* kvm-disk-io: disk I/O and storage latency per virtual machine ([#644](https://github.com/Linuxfabrik/monitoring-plugins/issues/644))
* kvm-memory-usage: memory usage per virtual machine ([#644](https://github.com/Linuxfabrik/monitoring-plugins/issues/644))
* kvm-network-io: network I/O and drops per virtual machine ([#644](https://github.com/Linuxfabrik/monitoring-plugins/issues/644))
* kvm-storage-pool: state and free space of libvirt storage pools ([#644](https://github.com/Linuxfabrik/monitoring-plugins/issues/644))
* kvm-volume: libvirt volumes and pool overcommitment ([#644](https://github.com/Linuxfabrik/monitoring-plugins/issues/644))
* lvm-snapshots: filling and invalidated LVM snapshots
* lvm-thin-pools: LVM thin pools running out of data or metadata
* lvm-volume-groups: missing physical volumes and free space of LVM volume groups
* lvm-volumes: incomplete, degraded or inactive LVM logical volumes
* md-raid: software RAID arrays losing redundancy
* memory-paging: swap paging activity
* metabase-version: Metabase end of life and new releases
* multipath: LUNs losing paths
* nfs-exports: configured NFS exports that are not served
* nfs-mounts: stale or unresponsive NFS mounts
* nginx-disclosure: what an NGINX server gives away about itself
* nginx-security: hardening of a local NGINX
* openstack-cinder-list: block storage volumes of a project
* openstack-quota: compute, block storage and network quotas of a project ([#489](https://github.com/Linuxfabrik/monitoring-plugins/issues/489))
* php-fpm-logfile: problems in the PHP-FPM error log
* postfix-logfile: problems in the Postfix mail log
* psi-cpu: work waiting for a CPU ([#746](https://github.com/Linuxfabrik/monitoring-plugins/issues/746))
* psi-io: work waiting for storage ([#746](https://github.com/Linuxfabrik/monitoring-plugins/issues/746))
* psi-irq: CPUs busy servicing interrupts ([#746](https://github.com/Linuxfabrik/monitoring-plugins/issues/746))
* psi-memory: work waiting for memory ([#746](https://github.com/Linuxfabrik/monitoring-plugins/issues/746))
* sshd-logfile: failed logins and problems in the OpenSSH server log

Icinga Director:

* `libvirtd Service Set`
* `LVM Service Set`
* `MD RAID Service Set`
* `Multipath Service Set`
* `NFS Client Service Set`
* `Sensors Service Set`
* `smartmontools Service Set`
* `virtqemud Service Set`

### Changed

Monitoring Plugins:

* apache-httpd-status: more accurate worker usage, and works with `ExtendedStatus Off`
* cpu-usage: alerts on CPU steal, and correct percentages on hosts running virtual machines
* dmesg: fewer false alarms on physical servers and in virtual machines
* docker-\*, podman-\*: an unresponsive container engine warns after `--timeout`, and `--always-ok` covers it
* huawei-dorado-host, huawei-dorado-interface, huawei-dorado-lun: adjusted severities
* kvm-vm: reports crashed machines, and no longer needs root
* lynis: alerts when no host was audited
* mysql-database-metrics, mysql-storage-engines, mysql-table-indexes: `--ignore-schemas` / `--ignore-tables` are deprecated
* mysql-innodb-buffer-pool-size, mysql-innodb-log-waits: no more redo log alerts on idle databases
* mysql-logfile: aborted connections and denied logins are counted per source over time instead of alerting on each
* nextcloud-enterprise: alerts on an expired subscription and on account limits ([#647](https://github.com/Linuxfabrik/monitoring-plugins/issues/647))
* nextcloud-stats: lists the five largest accounts, which is slow on large instances, `--top=0` turns it off ([#103](https://github.com/Linuxfabrik/monitoring-plugins/issues/103))
* openstack-nova-list: alerts on an ACTIVE instance that is not running, and fewer false CRITICALs
* openstack-swift-stat: alerts on container and account quotas
* scanrootkit: detects 13 more rootkits and implants
* wordpress-security-scan: warns when it cannot check for vulnerabilities

Icinga Director:

* the Needs Restarting Service Set covers Debian, tag those hosts

Grafana:

* re-deploy the `icingaweb2-module-grafana` assets: Icinga Web 2 shows all graphs of a check
* re-import the dashboards of apache-httpd-status, cpu-usage, disk-io, huawei-dorado-hypermetropair, huawei-dorado-lun, Icinga overview, keycloak-memory-usage, kvm-vm, load, memory-usage, mysql-logfile, network-io, php-status, ping, procs and swap-usage

### Removed

Monitoring Plugins:

* huawei-dorado-hypermetropair, huawei-dorado-lun: the per-object status code metrics
* swap-usage: the `sin` and `sout` metrics, see memory-paging

Icinga Director:

* the Basic and Apache Service Sets for Debian 10, RHEL 7 and Ubuntu 16 to 20, including their host tags: retag those hosts
* the `File Size - /var/log/audit/audit.log` service in the RHEL and Fedora Basic Service Sets

Build, CI/CD:

* packages for Ubuntu 20.04

### Fixed

Monitoring Plugins:

* about-me: detects KVM hosts with the modular libvirt daemons again
* all checks over HTTP: honour network ranges in `no_proxy` and the Windows proxy exceptions
* all plugins: a command stuck on vanished storage no longer runs past `--timeout`
* all `*-version` checks: releases missing on endoflife.date no longer cause UNKNOWN or a crash
* cert: `2w` works as a threshold, and proxy settings are honoured ([#1474](https://github.com/Linuxfabrik/monitoring-plugins/issues/1474))
* deb-updates: `--only-critical` no longer misses a fresh security update, and concurrent runs no longer mix results
* disk-io: no false warning after a reboot ([#677](https://github.com/Linuxfabrik/monitoring-plugins/issues/677))
* disk-usage: `--fstype` works on a host with a hung network filesystem
* docker-service, docker-swarm: can reach the Docker daemon via sudo
* docker-stats: `--count` holds for every container on busy hosts
* file-ownership: a malformed `--filename` no longer crashes the check
* fortios-network-io, fortios-sensor, jitsi-videobridge-status: `--always-ok` works
* gitlab-version: an unreachable version-check service follows `--unreachable-severity` instead of forcing UNKNOWN
* haproxy-status: performance data no longer breaks on failed health checks or tracked servers
* huawei-dorado-\*: fewer false alarms and missed faults, correct I/O sizes, and no timeouts on large arrays
* icinga-topflap-services, kubectl-get-pods: concurrent runs no longer mix results
* keycloak-memory-usage, keycloak-stats, keycloak-version: name the missing "manage-realm" role instead of crashing
* logfile: a log that is not valid UTF-8 no longer breaks the check
* needs-restarting: fewer false results on RHEL and Debian ([#1522](https://github.com/Linuxfabrik/monitoring-plugins/issues/1522))
* nextcloud-status, spring-boot-actuator-health: honour proxy settings ([#1474](https://github.com/Linuxfabrik/monitoring-plugins/issues/1474))
* php-status: no longer warns when `post_max_size` is smaller than `upload_max_filesize`
* redfish-\*: recover after the controller drops its sessions, and put far less load on it ([#1372](https://github.com/Linuxfabrik/monitoring-plugins/discussions/1372), [#1507](https://github.com/Linuxfabrik/monitoring-plugins/issues/1507), [lib#350](https://github.com/Linuxfabrik/lib/issues/350))
* redfish-logservices: evaluates the System Event Log of Avigilon servers
* rpm-updates: shows the correct target version, and concurrent runs no longer mix results
* rpm-versionlock: finds all dnf 5 locks ([#1462](https://github.com/Linuxfabrik/monitoring-plugins/issues/1462))
* users: counts disconnected sessions on Windows
* wildfly-non-xa-datasource-stats, wildfly-xa-datasource-stats: `--always-ok` also covers a missing datasource
* wordpress-checksums: no false alarm on localized installations, and proxy settings are honoured ([#1474](https://github.com/Linuxfabrik/monitoring-plugins/issues/1474))
* xml: a missing `lxml` module reports UNKNOWN instead of a stack trace

Icinga Director:

* the Huawei Dorado Service Set runs all its checks again and copes with large arrays: re-import the basket
* the Postfix MTA Service Sets no longer abort `basket restore`

Build, CI/CD:

* the SELinux policy loads on RHEL 10 again

### Security

Monitoring Plugins:

* all checks over HTTP: passwords no longer leak via redirects or error messages, and oversized answers are refused ([GHSA-pq9x-4pp3-p5r9](https://github.com/Linuxfabrik/monitoring-plugins/security/advisories/GHSA-pq9x-4pp3-p5r9))
* fail2ban: `--socket` is confined to `/run`, closing a local root code execution
* kdump: `--path` no longer discloses files outside the crash-dump directory ([GHSA-q8c8-wxhc-3h4c](https://github.com/Linuxfabrik/monitoring-plugins/security/advisories/GHSA-q8c8-wxhc-3h4c))


## [v7.0.0] - 2026-08-14

**Highlights:** `disk-io` stops raising false CRITICALs on ZFS and Proxmox, and the Redfish checks no longer time out on large servers. Thirty-five new checks cover Docker, Podman, Huawei OceanStor, WordPress and package version locks. Counters become per-second rates and `redfish-*` needs `--url`, so re-import dashboards and review commands before updating.

### Breaking Changes

Monitoring Plugins:

* counters are per-second rates with partly new metric names: re-import the dashboards of cpu-usage, disk-io, fs-xfs-stats, jitsi-videobridge-stats, network-io, nginx-status, nodebb-cache, nodebb-errors, procs, redis-status, starface-database-stats, valkey-status and wildfly-gc-status ([#320](https://github.com/Linuxfabrik/monitoring-plugins/issues/320))
* disk-io: no longer measures I/O wait (false CRITICALs on ZFS and Proxmox) and only warns, re-import the dashboard ([#1371](https://github.com/Linuxfabrik/monitoring-plugins/issues/1371))
* docker-stats, podman-stats: special characters in per-container metric names become `_` (`web.1` → `web_1`)
* huawei-dorado-\*: metric names and units changed, re-import the dashboards
* redfish-\*: `--url` is mandatory ([#1306](https://github.com/Linuxfabrik/monitoring-plugins/issues/1306))

Icinga Director:

* the Host and Service templates are pinned to the master zone: with a satellite tier, unset the zone on `tpl-host-generic` and `tpl-service-generic` ([#721](https://github.com/Linuxfabrik/monitoring-plugins/issues/721))

### Added

Monitoring Plugins:

* apache-tomcat-version: Apache Tomcat end of life and updates ([#126](https://github.com/Linuxfabrik/monitoring-plugins/issues/126))
* deb-versionlock: packages APT holds back
* docker-container, podman-container: unhealthy, restarting or unexpected-state containers
* docker-image, podman-image: outdated images
* docker-service: Docker Swarm services running too few tasks
* docker-swarm: swarm membership, down nodes and manager quorum
* huawei-dorado-alarm: current alarms
* huawei-dorado-expboard: faulty expansion boards
* huawei-dorado-lun: faulty and filling LUNs
* huawei-dorado-port: faulty or slow front-end ports
* huawei-dorado-sfp: faulty optical modules and light levels
* huawei-dorado-storagepool: faulty and filling storage pools
* huawei-pacific-alarm: current alarms
* huawei-pacific-disk: faulty and worn-out disks
* huawei-pacific-fan: faulty fans
* huawei-pacific-namespace: unreachable or read-only namespaces
* huawei-pacific-node: faulty cluster nodes and expired warranties
* huawei-pacific-power: faulty power supplies
* huawei-pacific-quota: shares filling up their quota
* huawei-pacific-replicationpair: replication pairs that stopped mirroring
* huawei-pacific-service: stopped service processes
* huawei-pacific-storagepool: faulty and filling storage pools
* huawei-pacific-system: cluster capacity usage
* icingaweb2-module-updates: outdated Icinga Web 2 modules ([#124](https://github.com/Linuxfabrik/monitoring-plugins/issues/124))
* kdump: whether a kernel panic can be captured, and leftover crash dumps
* librenms-validate: problems LibreNMS reports about itself ([#366](https://github.com/Linuxfabrik/monitoring-plugins/issues/366))
* network-errors: interface receive and transmit errors ([#707](https://github.com/Linuxfabrik/monitoring-plugins/issues/707))
* nextcloud-app-updates: pending Nextcloud app updates ([#62](https://github.com/Linuxfabrik/monitoring-plugins/issues/62))
* nextcloud-status: pending database upgrades and maintenance mode ([#329](https://github.com/Linuxfabrik/monitoring-plugins/issues/329))
* rpm-versionlock: packages the RPM package manager holds back
* wildfly-version: outdated WildFly ([#123](https://github.com/Linuxfabrik/monitoring-plugins/issues/123))
* wordpress-checksums: modified WordPress core and plugin files
* wordpress-security-scan: known vulnerabilities and exposed credentials on a WordPress site

Icinga Director:

* `Icinga Web 2 Service Set`
* `Lynis Service Set` (tag only the host that runs the subnet audits)
* `OpenJDK Service Set`
* host tag `metabase` (no Service Set, apply the service template yourself)

Assets:

* bash completion for the plugin options

### Changed

Monitoring Plugins:

* all plugins: output shows `<`, `>` and `&` verbatim instead of escaped
* cpu-usage: no longer alerts on iowait
* docker-info: reports every warning the daemon raises
* huawei-dorado-\*: faulty components are CRITICAL instead of WARNING, and large arrays are fully reported
* mysql-innodb-log-waits: alerts only on real log waits
* php-status: warns when `post_max_size` is not larger than `upload_max_filesize` ([#516](https://github.com/Linuxfabrik/monitoring-plugins/issues/516))
* podman-stats: CPU usage is measured since the last run instead of since container start
* rhel-version: points to fedora-version on Fedora
* scanrootkit: detects VoidLink and RingReaper
* uptimerobot: checks UptimeRobot's own status page by default, other pages need `--url`

Icinga Director:

* huawei-dorado-disk, huawei-dorado-host, huawei-dorado-hypermetropair: hide items within their thresholds, re-import the basket
* the WordPress Service Set and host tag follow WordPress' spelling, re-tag your hosts

### Fixed

Monitoring Plugins:

* about-me: detects WordPress in the document root
* borgbackup, file-ownership, getent, nextcloud-enterprise, rpm-lastactivity, scheduled-task: work again
* cert: a subnet scan finishes within the timeout and needs far less memory
* csv-values, json-values: non-UTF-8 input no longer crashes the check ([lib#256](https://github.com/Linuxfabrik/lib/issues/256))
* deb-lastactivity: no stack trace on a host without APT packages
* disk-smart: reads RAID and USB drives again, `--ignore` works, and a failing drive stays CRITICAL ([#1388](https://github.com/Linuxfabrik/monitoring-plugins/issues/1388))
* disk-usage: performance data carries the thresholds again, and `(?-i:...)` patterns match ([#1310](https://github.com/Linuxfabrik/monitoring-plugins/issues/1310))
* docker-stats: a container without statistics no longer causes UNKNOWN
* fs-inodes: an unreadable mount point no longer aborts the check ([#1387](https://github.com/Linuxfabrik/monitoring-plugins/issues/1387))
* journald-query: relative `--since` values work again ([#1264](https://github.com/Linuxfabrik/monitoring-plugins/issues/1264))
* librenms-health: sensors past their limits alert
* logfile: detects a logfile that gets rewritten from the start ([#1330](https://github.com/Linuxfabrik/monitoring-plugins/issues/1330))
* lynis: works where lynis lives outside `/usr/share` ([#1262](https://github.com/Linuxfabrik/monitoring-plugins/issues/1262))
* mysql-replica-status: works on MySQL 8.4
* mysql-user-security: the suggested `ALTER USER` works on MariaDB 11.6 and newer
* ping: corrupted packets are counted correctly
* podman-info: no crash without unqualified search registries
* redfish-\*: no timeouts on large servers ([#1372](https://github.com/Linuxfabrik/monitoring-plugins/discussions/1372))
* sensors-fans, sensors-temperatures: identical sensors no longer overwrite each other's performance data
* snmp: net-snmp warnings no longer abort the check, and string-indexed OIDs work
* statusiq: no more flapping to UNKNOWN
* strongswan-connections: no false alarms or crashes on rekeying, shared, connecting or 3DES connections ([#806](https://github.com/Linuxfabrik/monitoring-plugins/issues/806))
* systemd-unit: the Ubuntu Service Sets check `ssh.service` ([#1373](https://github.com/Linuxfabrik/monitoring-plugins/issues/1373))

Grafana:

* ping: times are shown in milliseconds, re-import the dashboard

Assets:

* SELinux policy: loads on RHEL 10

### Security

Monitoring Plugins:

* all checks over HTTP: API keys and session tokens no longer follow a redirect to another host ([GHSA-4jc5-g844-4x33](https://github.com/Linuxfabrik/monitoring-plugins/security/advisories/GHSA-4jc5-g844-4x33))
* all plugins: `--test` can no longer read root-owned files via sudo ([GHSA-rh9c-rqvg-f7pr](https://github.com/Linuxfabrik/monitoring-plugins/security/advisories/GHSA-rh9c-rqvg-f7pr))
* keycloak-memory-usage, keycloak-stats, keycloak-version: admin credentials no longer leak to another host ([GHSA-88fj-95f7-w68m](https://github.com/Linuxfabrik/monitoring-plugins/security/advisories/GHSA-88fj-95f7-w68m))
* logfile: closed a local privilege escalation (only with `fs.protected_symlinks=0`) ([GHSA-w2gg-hx6w-24w3](https://github.com/Linuxfabrik/monitoring-plugins/security/advisories/GHSA-w2gg-hx6w-24w3))
* logfile, mysql-logfile, openvpn-client-list: log files are confined to `/var/log`, bind-mount logs stored elsewhere ([GHSA-f54c-p5vg-mr5c](https://github.com/Linuxfabrik/monitoring-plugins/security/advisories/GHSA-f54c-p5vg-mr5c))
* redfish-\*: a malicious controller can no longer redirect a check to another host ([GHSA-96fx-pqc3-28xv](https://github.com/Linuxfabrik/monitoring-plugins/security/advisories/GHSA-96fx-pqc3-28xv))
* virustotal-scan-url: the API key can no longer leak to another host

Notification Plugins:

* notify-host-mail, notify-service-mail: a monitored service can no longer inject markup into the email


## [v6.0.0] - 2026-06-14

**Highlights:** A local privilege escalation through crafted plugin arguments is closed. The Redfish checks are renamed, so update your commands, and five new ones join them.

### Breaking Changes

Monitoring Plugins:

* redfish-\*: renamed to match their API endpoints (`redfish-drives` → `redfish-storage`, `redfish-sel` → `redfish-logservices`, `redfish-sensor` → `redfish-sensors`, `redfish-system` → `redfish-systems`), update your commands

### Added

Monitoring Plugins:

* lynis: security hardening of the hosts in a subnet, over SSH
* redfish-ethernetinterfaces: Ethernet interface health
* redfish-firmwareinventory: firmware versions and health
* redfish-managers: management controller health (iLO, iDRAC)
* redfish-memory: memory module health
* redfish-processors: processor health

### Changed

Monitoring Plugins:

* by-ssh: `--shell` is ignored, pipes, globs and variables always work
* cert: scans whole subnets and checks the full certificate chain
* ipmi-sensor: performance data is grouped by sensor type, which resets the graph history once ([#22](https://github.com/Linuxfabrik/monitoring-plugins/issues/22))
* nextcloud-security-scan: fresh rating right after a Nextcloud update ([#118](https://github.com/Linuxfabrik/monitoring-plugins/issues/118))
* php-status: OPcache warns at 95% and on cache thrashing
* redfish-\*: no longer flood the controller's session table and audit log, and retry flaky requests
* swap-usage: a host without swap is OK instead of UNKNOWN ([#1142](https://github.com/Linuxfabrik/monitoring-plugins/issues/1142))

### Fixed

Monitoring Plugins:

* about-me: no crash while detecting installed software
* apache-httpd-version: works again ([PR #1224](https://github.com/Linuxfabrik/monitoring-plugins/pull/1224), thanks to [Salman Mohammadi](https://github.com/salmanxmoha))
* by-ssh: a failed connection no longer echoes the `--password` value
* redfish-sensors: no false warnings from placeholder ranges ([#1211](https://github.com/Linuxfabrik/monitoring-plugins/issues/1211))
* several plugins running system commands: a harmless warning on stderr no longer causes UNKNOWN
* Windows: no blank lines between output lines, and no garbled umlauts ([#681](https://github.com/Linuxfabrik/monitoring-plugins/issues/681))

Icinga Director:

* checks deploy correctly in distributed setups, the templates no longer pin them to the master zone ([#721](https://github.com/Linuxfabrik/monitoring-plugins/issues/721))

### Security

Monitoring Plugins:

* all plugins: crafted arguments can no longer execute arbitrary commands, most seriously via sudo ([GHSA-798h-hpph-m24j](https://github.com/Linuxfabrik/monitoring-plugins/security/advisories/GHSA-798h-hpph-m24j))


## [v5.2.0] - 2026-06-02

**Highlights:** Trend-data caches move out of the shared `/tmp`, closing a local symlink attack on checks running as root.

### Security

Monitoring Plugins:

* plugins caching trend data no longer use `/tmp`, closing a local symlink attack ([GHSA-r35r-fpx2-jgr4](https://github.com/Linuxfabrik/monitoring-plugins/security/advisories/GHSA-r35r-fpx2-jgr4), thanks to [OoYo0uto](https://github.com/OoYo0uto))


## [v5.1.0] - 2026-05-30

**Highlights:** A local privilege escalation through the Debian `apt-get` sudoers rule is closed. The `mysql-*` checks raise fewer false alarms, and `about-me` detects more platforms.

### Changed

Monitoring Plugins:

* about-me: `--tags` detects more software and platforms, and all user-installed packages are listed
* fail2ban: thresholds accept Nagios ranges, and a banned jail no longer mislabels the others ([#140](https://github.com/Linuxfabrik/monitoring-plugins/issues/140))

### Fixed

Monitoring Plugins:

* all plugins: no longer abort on RHEL 8's default Python 3.6
* mysql-\*: no more "Illegal mix of collations" ([#1139](https://github.com/Linuxfabrik/monitoring-plugins/issues/1139))
* mysql-innodb-buffer-pool-size: works on MySQL 9.3 and newer
* mysql-perf-metrics: fewer false alarms on MySQL 9.0 to 9.2 and on network storage
* mysql-table-definition-cache: recommends a valid value
* snmp: a malformed threshold in a device CSV reports UNKNOWN instead of being ignored ([#768](https://github.com/Linuxfabrik/monitoring-plugins/discussions/768))

### Security

Assets:

* Debian sudoers: the `apt-get` rule no longer grants a root shell ([GHSA-8w6w-23mq-h8rg](https://github.com/Linuxfabrik/monitoring-plugins/security/advisories/GHSA-8w6w-23mq-h8rg), thanks to [OoYo0uto](https://github.com/OoYo0uto))


## [v5.0.0] - 2026-05-15

**Highlights:** The `mysql-*` family is reworked: counters become rates and perfdata labels change, so re-import every MySQL dashboard. Six checks are new, two are gone.

### Added

Monitoring Plugins:

* cert: expiring X.509 certificates on TLS endpoints and in local files
* mysql-health: a single 0-100 health score for MySQL/MariaDB
* mysql-index-health: unused and redundant indexes
* mysql-long-queries: long-running queries
* mysql-tls: TLS setup and certificate expiry of MySQL/MariaDB
* ups-nut: UPS managed by Network UPS Tools

### Changed

Monitoring Plugins:

* mysql-\*: counters become rates and perfdata labels change, re-import the dashboards; thresholds use Nagios ranges (`>=N` becomes `>N`)
* mysql-aria, mysql-binlog-cache, mysql-innodb-log-waits: a disabled engine or `log_bin = OFF` is OK instead of UNKNOWN
* mysql-innodb-buffer-pool-size: checks `innodb_redo_log_capacity` and `innodb_file_per_table`
* mysql-logfile: reads the error log from Performance Schema where available, and reads container logs again
* mysql-memory: counts the Galera GCache, alerts at 85% and 95%, and accounts for `max_tmp_table_size` correctly
* mysql-perf-metrics: a deprecated variable only warns when set explicitly
* mysql-replica-status: needs fewer privileges on MariaDB, and no longer reports lag on every server
* mysql-storage-engines: the AUTO_INCREMENT check respects each column's type
* mysql-system: warns on `fs.nr_open < 1M`, and perfdata is renamed
* mysql-table-indexes: flags InnoDB tables without a primary key
* mysql-user-security: flags legacy authentication plugins and default passwords

Icinga Director:

* mysql-binlog-cache moves to the MySQL Service Set, hosts with only `mysql-replication` also need `mysql`

### Fixed

Monitoring Plugins:

* docker-stats, podman-stats: per-container CPU and memory perfdata is back ([#1104](https://github.com/Linuxfabrik/monitoring-plugins/issues/1104))
* mysql-database-metrics: no longer misjudges the `percona` schema or index sizes
* mysql-slow-queries: a ratio of 5.x% alerts again
* mysql-temp-tables: no crash on idle servers
* mysql-thread-cache: correct perfdata unit
* mysql-traffic: no "100% writes" on idle servers
* veeam-status: works with Veeam Enterprise Manager v13 ([#1001](https://github.com/Linuxfabrik/monitoring-plugins/issues/1001))

Grafana:

* dashboards import into Grafana 12 again

### Removed

Monitoring Plugins:

* hin-status: the HIN status page no longer exists
* mysql-innodb-buffer-pool-instances: obsolete on current MariaDB and MySQL


## [v4.1.0] - 2026-05-08

### Changed

Monitoring Plugins:

* sap-open-concur-com: defaults to the `eu2` datacenter, and slow responses no longer cause UNKNOWN

### Removed

Icinga Director:

* 13 single-plugin Service Sets, apply their templates via Apply rules
* the `tarifpool-v2` host tag

### Fixed

Monitoring Plugins:

* network-port-tcp: no longer crashes
* php-fpm-status: no false CRIT on dynamic and ondemand pools


## [v4.0.0] - 2026-05-07

### Added

Icinga Director:

* `Needs Restarting Service Set`
* `OS - RHEL 10 Basic Service Set`
* `Postfix MTA Service Set (Multi-Instance)` ([#535](https://github.com/Linuxfabrik/monitoring-plugins/issues/535))

### Changed

Monitoring Plugins:

* dmesg: `--ignore` takes regexes and replaces the defaults, `--severity` is ignored and alerts are always CRIT

Icinga Director:

* the Basic Service Sets no longer check `rsyslog.service`, tag rsyslog hosts `rsyslog`

### Removed

Icinga Director:

* the `OS - Debian 8 Basic Service Set`

### Fixed

Monitoring Plugins:

* librenms-alerts: `WORSE`, `BETTER` and `CHANGED` alerts are no longer reported OK


## [v3.0.0] - 2026-05-05

### Breaking Changes

Monitoring Plugins:

* plugins with repeatable parameters: your values replace the defaults instead of extending them ([#540](https://github.com/Linuxfabrik/monitoring-plugins/issues/540))
* haproxy-status: `--username` / `--password` are replaced by credentials in `--url`
* mailq: thresholds take a duration instead of a count ([#781](https://github.com/Linuxfabrik/monitoring-plugins/issues/781))
* php-fpm-status: all perfdata labels are renamed and prefixed `<pool>_`, update your queries
* procs: `--argument`, `--command` and `--username` take regexes, use `^foo$` for an exact match
* redfish-sensor: `--insecure` is the default, pass `--insecure=false` for trusted certificates

Tools:

* `check2basket` is now `build-basket`, `remove-uuids` is now `basket-remove-uuids`

### Added

Monitoring Plugins:

* by-winrm: runs commands on Windows hosts via WinRM
* nextcloud-enterprise: Nextcloud Enterprise subscription
* podman-info: system-wide Podman information ([#1023](https://github.com/Linuxfabrik/monitoring-plugins/issues/1023))
* podman-stats: CPU and memory of Podman containers ([#1023](https://github.com/Linuxfabrik/monitoring-plugins/issues/1023))
* redfish-system: overall system health ([#652](https://github.com/Linuxfabrik/monitoring-plugins/issues/652))

Icinga Director:

* Debian 13 Service Set
* Ubuntu 26 Basic Service Set

Build, CI/CD:

* packages for SLE 15, SLE 16 and Ubuntu 26.04

### Changed

Monitoring Plugins:

* all plugins: unknown arguments are ignored instead of erroring
* atlassian-statuspage: the `impact` perfdata is renamed to `cnt_warn` and `cnt_crit`
* disk-io: also alerts on iowait
* file-count: much faster on large directories
* file-ownership: checks more CIS-relevant files by default, which may raise new alerts
* gitlab-version: warns on security updates ([#688](https://github.com/Linuxfabrik/monitoring-plugins/issues/688))
* nextcloud-version: `occ` no longer has to be executable
* php-status: defaults to `http://localhost/monitoring.php`
* scanrootkit: 52 more signatures, fewer false positives, and the perfdata counts rootkits instead of indicators
* statuspal: detects emergency maintenance

Assets:

* sudoers: sudo calls no longer fill the log with PAM session lines

Build, CI/CD:

* the Windows MSI no longer needs an installed Icinga 2 agent

### Removed

Monitoring Plugins:

* cpu-usage: `--top`, use `procs --top`
* scanrootkit: the Suckit check and the `rootkit_extra` perfdata

Tools:

* `grafana-tool`

### Fixed

Monitoring Plugins:

* about-me: no errors on missing hardware information ([#1006](https://github.com/Linuxfabrik/monitoring-plugins/issues/1006))
* cpu-usage: no false 100% on Windows with 64 or more cores ([#626](https://github.com/Linuxfabrik/monitoring-plugins/issues/626))
* deb-updates: no crash when reporting updates
* docker-stats: memory perfdata no longer uses the CPU thresholds
* file-age: copes with files vanishing during the check
* fs-ro: ignores `/run/credentials`
* keycloak-stats: runs again
* librenms-alerts: reports `WORSE`, `BETTER` and `CHANGED` alerts ([#882](https://github.com/Linuxfabrik/monitoring-plugins/issues/882))
* logfile: services sharing a logfile no longer interfere, and the check works on Windows ([#698](https://github.com/Linuxfabrik/monitoring-plugins/issues/698), [#1035](https://github.com/Linuxfabrik/monitoring-plugins/issues/1035))
* mysql-joins, mysql-traffic: no crash right after a server start
* mysql-memory: no crash with psutil older than 5.3.0
* needs-restarting: reports a pending kernel upgrade on Debian
* notify-host-mail, notify-service-mail: the Icinga logo renders again ([#790](https://github.com/Linuxfabrik/monitoring-plugins/issues/790))
* ntp-\*: no more `TypeError`
* redfish-drives: system-level warnings no longer affect the check ([#652](https://github.com/Linuxfabrik/monitoring-plugins/issues/652))
* rocketchat-stats: no crash when reporting the user count
* service: Windows services with a space in their name match ([#921](https://github.com/Linuxfabrik/monitoring-plugins/issues/921))
* several plugins: logic errors fixed ([#1070](https://github.com/Linuxfabrik/monitoring-plugins/issues/1070))
* updates: no crash on Python 3.9
* users: correct TTY count with IPv6 clients ([#989](https://github.com/Linuxfabrik/monitoring-plugins/issues/989))
* valkey-status: TLS works ([PR #954](https://github.com/Linuxfabrik/monitoring-plugins/pull/954), thanks to [Claudio Kuenzler](https://github.com/Napsty))

Build, CI/CD:

* RPM: no conflict with other packages shipping build-id symlinks, such as `azure-cli` ([#979](https://github.com/Linuxfabrik/monitoring-plugins/issues/979))

Grafana:

* the Icinga dashboard works with any service name


## [v2.2.1] - 2025-09-22

### Fixed

Monitoring Plugins:

* ntp-chronyd, ntp-ntpd: no SyntaxError on Python 3.11 ([#952](https://github.com/Linuxfabrik/monitoring-plugins/issues/952))


## [v2.2.0] - 2025-09-19

### Added

Monitoring Plugins:

* spring-boot-actuator-health: Spring Boot Actuator health (derived from [PR #940](https://github.com/Linuxfabrik/monitoring-plugins/pull/940), thanks to [Dominik Riva](https://github.com/slalomsk8er))
* virustotal-scan-url: URLs flagged by VirusTotal

Build, CI/CD:

* packages for Debian 13 and RHEL 10

### Changed

Monitoring Plugins:

* cpu-usage: more accurate and faster
* gitlab-health, gitlab-liveness, gitlab-readiness, infomaniak-events: longer default timeouts
* procs: much cheaper on busy Windows servers
* statuspal: a "performance" incident is WARN instead of UNKNOWN

### Fixed

Monitoring Plugins:

* deb-updates: reports why apt-get fails, and no longer reports OK without the rights to check ([#904](https://github.com/Linuxfabrik/monitoring-plugins/issues/904), [#937](https://github.com/Linuxfabrik/monitoring-plugins/issues/937))
* icinga-topflap-services: no stack trace on empty parameters
* openstack-swift-stat: works with the current python-keystoneclient ([#900](https://github.com/Linuxfabrik/monitoring-plugins/issues/900))
* redis-status, valkey-status: `--ignore-thp` works ([#898](https://github.com/Linuxfabrik/monitoring-plugins/issues/898))
* safenet-hsm-state: performance data in the Director basket
* users: no longer reports "no one is logged in" on Ubuntu 24.04 ([#919](https://github.com/Linuxfabrik/monitoring-plugins/issues/919))

Assets:

* SELinux policy: no more denials on D-Bus IPC ([#918](https://github.com/Linuxfabrik/monitoring-plugins/issues/918))


## [v2.1.1] - 2025-06-20

### Fixed

Icinga Director:

* the Icinga 2 Service Set


## [v2.1.0] - 2025-06-20

### Added

Monitoring Plugins:

* icinga-version: Icinga end of life

Icinga Director:

* Icinga 2 Service Set

### Changed

Monitoring Plugins:

* matomo-version: uses the EOL library, `--cache-expire` is deprecated

### Fixed

Monitoring Plugins:

* disk-usage: copes with an inaccessible disk ([#792](https://github.com/Linuxfabrik/monitoring-plugins/issues/792))
* updates: no more "The syntax of the command is incorrect."

Icinga Director:

* nextcloud-app-update.timer unit states


## [v2.0.0] - 2025-06-06

### Breaking Changes

Build, CI/CD:

* Linux: the packages ship the source code instead of binaries and need Python 3.9 or newer on the host
* Windows: only checks for local resources are compiled, remote checks are meant to run on Linux

Icinga Director:

* the checks no longer compiled for Windows and the legacy commands are gone from the Windows configuration

### Added

Monitoring Plugins:

* atlassian-statuspage: incidents on an Atlassian Statuspage
* deb-updates: pending updates on `apt-get` systems
* kubectl-get-pods: health of Kubernetes pods
* rpm-updates: pending updates and their advisories
* valkey-status: Valkey server statistics
* valkey-version: Valkey end of life

### Changed

Monitoring Plugins:

* about-me: detects Valkey and the display server
* csv-values: copes with omitted `--warning-query` and `--critical-query`
* icinga-topflap-services: the default warning level rises from 5 to 7
* php-status: bz2 and curl are no longer expected by default
* redfish-sel: supports Supermicro ([#866](https://github.com/Linuxfabrik/monitoring-plugins/issues/866))

Assets:

* sudoers: the command alias is prefixed to avoid conflicts ([#880](https://github.com/Linuxfabrik/monitoring-plugins/issues/880))

### Fixed

Monitoring Plugins:

* by-ssh: no traceback on "permission denied"
* icinga-topflap-services: no UNKNOWN while Icinga DB synchronizes
* needs-restarting: works again
* ping: "10 received" is no longer read as "0 received" ([#860](https://github.com/Linuxfabrik/monitoring-plugins/issues/860))
* snmp: special characters in SNMPv3 passwords work ([#886](https://github.com/Linuxfabrik/monitoring-plugins/issues/886))


## [v1.2.0.11] - 2025-03-13

### Breaking Changes

Monitoring Plugins:

* the source-code variant requires Python 3.9 or newer
* jitsi-videobridge-stats: `--warning` / `--critical` are gone, the check always returns OK ([PR #780](https://github.com/Linuxfabrik/monitoring-plugins/pull/780), thanks to [SnejPro](https://github.com/SnejPro))

Notification Plugins:

* notify-\*-rocketchat-telegram: the Telegram functionality and the `-telegram` suffix are gone

Icinga Director:

* the Tarifpool-v2 Service Set is removed

Build, CI/CD:

* semantic versioning replaces calendar versioning, starting at `v1.0.0.0`

### Added

Monitoring Plugins:

* new checks: graylog-version, hin-status, icinga-topflap-services, keycloak-memory-usage, keycloak-stats, mastodon-version, moodle-version, openvpn-version, scanrootkit, statusiq, uptimerobot, whmcs-status

Icinga Director:

* new Service Sets: Debian 12 (Cloud Image), IcingaDB, Mastodon, Moodle, networking, rsyslog, Ubuntu 24, WHMCS

Build, CI/CD:

* packages for ARM ([#702](https://github.com/Linuxfabrik/monitoring-plugins/issues/702))

### Changed

Monitoring Plugins:

* about-me: more accurate VM birth date, detects Mastodon, Moodle and WHMCS
* dhcp-scope-usage: ignores PercentageInUse fractions
* disk-io: supports Windows again
* fs-inodes: checks inode usage per real disk, `--mount` is deprecated
* infomaniak-events: returns CRIT on critical events
* keycloak-version: reads the version over the REST API ([#748](https://github.com/Linuxfabrik/monitoring-plugins/issues/748))
* librenms-alerts, librenms-health: show non-OK entries only by default
* mysql-thread-cache: measures the hit rate only after one hour of uptime
* nextcloud-security-scan: handles errors from scan.nextcloud.com
* nodebb-stats: "Last user" no longer reports the check's own account ([#536](https://github.com/Linuxfabrik/monitoring-plugins/issues/536))
* openstack-nova-list: no longer needs keystoneauth and keystoneclient
* rocketchat-version: uses the EOL library, `--cache-expire` is deprecated
* uptime: reports downtime ([#191](https://github.com/Linuxfabrik/monitoring-plugins/issues/191))

Icinga Director:

* the Windows plugins move to `c:\Program Files\icinga2\sbin\linuxfabrik`, dmesg uses sudo, and the Debian Service Sets watch `/var/log/syslog`

Build, CI/CD:

* Windows ships as an MSI package

### Fixed

Monitoring Plugins:

* about-me: detects expanded RAM ([#757](https://github.com/Linuxfabrik/monitoring-plugins/issues/757))
* apache-httpd-status: works with mod_md enabled ([#783](https://github.com/Linuxfabrik/monitoring-plugins/issues/783))
* dhcp-relayed: binds to all network interfaces
* disk-io: no UnboundLocalError ([#777](https://github.com/Linuxfabrik/monitoring-plugins/issues/777))
* docker-stats: `--always-ok` works, and `0B` no longer crashes the check ([#776](https://github.com/Linuxfabrik/monitoring-plugins/issues/776), [#839](https://github.com/Linuxfabrik/monitoring-plugins/issues/839))
* fortios-network-io: reads its local database again
* needs-restarting: works under the nagios user ([#799](https://github.com/Linuxfabrik/monitoring-plugins/issues/799))
* redfish-sel: no UnboundLocalError ([#779](https://github.com/Linuxfabrik/monitoring-plugins/issues/779))
* service: `--starttype` works
* snmp: no `IndexError` on some device CSV files
* strongswan-connections: works with AES-GCM ([#806](https://github.com/Linuxfabrik/monitoring-plugins/issues/806))
* swap-usage: no ProcessLookupError

### Removed

Build, CI/CD:

* packages for Debian 10, RHEL 7 and Ubuntu 18.04


## [2024060401] - 2024-06-04

### Added

Monitoring Plugins:

* mysql-query: check running an arbitrary query against a MySQL/MariaDB server

Build, CI/CD:

* packages for Ubuntu 24.04


## [2024052901] - 2024-05-29

### Breaking Changes

Monitoring Plugins:

* disk-io: rewritten, with new parameters. The perfdata "throughput" is renamed to "bandwidth", only mounted disks are considered, and dm-\* device names are translated ([#709](https://github.com/Linuxfabrik/monitoring-plugins/issues/709), [#708](https://github.com/Linuxfabrik/monitoring-plugins/issues/708), [#676](https://github.com/Linuxfabrik/monitoring-plugins/issues/676))
* file-size: the thresholds require a size qualifier, `--warning=10K` instead of `--warning=10000`
* journald-query: pattern matching is always case-sensitive ([#745](https://github.com/Linuxfabrik/monitoring-plugins/issues/745))
* librenms-alerts, librenms-health: rewritten to read from the LibreNMS database, with new parameters
* php-fpm: the `--*-max-children` parameters are gone, because php-fpm's "max children reached" is either 0 or 1
* snmp: update your device CSV files, two more columns are required ([#481](https://github.com/Linuxfabrik/monitoring-plugins/issues/481))
* uptime: warns about recent reboots, and the thresholds require a time qualifier, `--warning=180D` instead of `--warning=180` ([#722](https://github.com/Linuxfabrik/monitoring-plugins/issues/722))

Notification Plugins:

* all notification plugins are installed in `/usr/lib64/nagios/plugins/notifications/`, otherwise installing both packages at once fails ([#726](https://github.com/Linuxfabrik/monitoring-plugins/issues/726))

Icinga Director:

* the predefined "Journald Query" definitions are gone, single services turned out to be more useful
* many service templates and service set services are less critical by default. Check the ones that matter to you and raise them again

### Added

Monitoring Plugins:

* new checks: composer-version, dhcp-relayed (a port of check_dhcp_relayed), mediawiki-version

Icinga Director:

* TuneD Service Set, therefore removed from all "OS - RHEL" service sets

### Changed

Monitoring Plugins:

* about-me: detects non-default software, UDP ports, hardware and much more
* deb-lastactivity: WARNs when the last modified timestamp is missing for one or more packages ([#743](https://github.com/Linuxfabrik/monitoring-plugins/issues/743))
* file-size: supports Nagios ranges for `--warning` and `--critical` ([PR #735](https://github.com/Linuxfabrik/monitoring-plugins/issues/735), thanks to [djmcd89](https://github.com/djmcd89))
* fs-ro: `/dev/loop` is ignored by default, and the output is easier to read ([PR #729](https://github.com/Linuxfabrik/monitoring-plugins/issues/729), [PR #730](https://github.com/Linuxfabrik/monitoring-plugins/issues/730), thanks to [Konrad Bucheli](https://github.com/kbucheli))
* journald-query: the hard-coded `--boot` is gone from the query
* librenms-version: reads from the local SQLite database
* mysql-memory: enhanced output, threshold at 95%
* ntp-chronyd: hints at the configuration when no NTP server is being used
* swap-usage: reports the top 3 processes causing the usage (Linux only)

Icinga Director:

* "Starface Java Status" is renamed to "Starface Java Memory Usage", and systemd-units-failed ignores session-c\*.scope by default

### Fixed

Monitoring Plugins:

* about-me: no longer throws an exception for openvas, and a pipe in the output no longer breaks the perfdata ([#741](https://github.com/Linuxfabrik/monitoring-plugins/issues/741), [#749](https://github.com/Linuxfabrik/monitoring-plugins/issues/749))
* csv-values: a pipe in the data is no longer read as the delimiter to the perfdata ([#727](https://github.com/Linuxfabrik/monitoring-plugins/issues/727))
* infomaniak-events: no longer aborts with an UnboundLocalError
* nextcloud-stats: no longer aborts with `KeyError: apps` ([#731](https://github.com/Linuxfabrik/monitoring-plugins/issues/731))
* ntp-ntpd: unpacks the `ntpq -p` values correctly ([PR #758](https://github.com/Linuxfabrik/monitoring-plugins/pull/758), thanks to [Leo Pempera](https://github.com/leo-pempera))
* ntp-w32tm: no longer aborts with an UnboundLocalError

Icinga Director:

* corrected the "FreeIPA Server Service Set" definition


## [2023112901] - 2023-11-29

### Breaking Changes

Notification Plugins:

* the generated URLs point at Icinga DB Web instead of the old IcingaWeb2 Monitoring Module ([#643](https://github.com/Linuxfabrik/monitoring-plugins/issues/643))

### Added

Monitoring Plugins:

* new checks: apache-solr-version, deb-lastactivity, gitlab-health, gitlab-liveness, gitlab-readiness, gitlab-version, ntp-w32tm, openjdk-redhat-version, openstack-nova-list, postgresql-version, python-version, redis-version, statuspal ([#670](https://github.com/Linuxfabrik/monitoring-plugins/issues/670), [#629](https://github.com/Linuxfabrik/monitoring-plugins/issues/629), [PR #710](https://github.com/Linuxfabrik/monitoring-plugins/issues/710), thanks to [Yannic Schüpbach](https://github.com/Dissiyt))

Icinga Director:

* Apache Solr Service Set, Debian 12 (Bookworm) coverage including deb-lastactivity

Grafana:

* dashboards for mysql-connections and mysql-memory

### Changed

Monitoring Plugins:

* \*-version: the version data is fetched from endoflife.date first and falls back to the bundled data, with an EOL offset date and optional warnings on a new major, minor or patch release ([#680](https://github.com/Linuxfabrik/monitoring-plugins/issues/680))
* about-me: detects ncdu and yarn, and shows systemd timers with their next runtime
* cpu-usage: excludes the "System Idle Process" from the Windows top 3 list
* disk-smart: skips unsupported disks ([#672](https://github.com/Linuxfabrik/monitoring-plugins/issues/672))
* fortios-firewall-stats: runs when a FortiOS user has only IPv4 or only IPv6 ([PR #719](https://github.com/Linuxfabrik/monitoring-plugins/issues/716), thanks to [Pierrot la menace](https://github.com/Pierrot-la-menace))
* mysql-aria: no longer WARNs on a low `pct_aria_keys_from_mem`
* mysql-connections: reports and warns on the current usage instead of the peak usage
* mysql-logfile: an empty logfile is OK instead of UNKNOWN, and the auto-configuration stops when `--server-log` is given ([PR #716](https://github.com/Linuxfabrik/monitoring-plugins/issues/716), thanks to [Eric Esser](https://github.com/dorkmaneuver))
* php-version: checks several installed PHP versions ([#694](https://github.com/Linuxfabrik/monitoring-plugins/issues/694))
* qts-\*: tested against QuTScloud 4.5.6, 5.0.1 and 5.1, and qts-version no longer reports "up to date" when new firmware is available ([#692](https://github.com/Linuxfabrik/monitoring-plugins/issues/692))
* rocketchat-stats: reports the values Rocket.Chat added ([#151](https://github.com/Linuxfabrik/monitoring-plugins/issues/151))
* uptime: also reports the last reboot time ([#190](https://github.com/Linuxfabrik/monitoring-plugins/issues/190))

Assets:

* sudoers: the command calls are no longer logged

### Fixed

Monitoring Plugins:

* csv-values: the header is no longer included in the data despite `--skip-header` ([#706](https://github.com/Linuxfabrik/monitoring-plugins/issues/706))
* journald-query: the perfdata is named "journald-query" instead of "sudo journald-query"
* path-rw-test: uses a unique filename to avoid a race condition ([#283](https://github.com/Linuxfabrik/monitoring-plugins/issues/283))
* qts-disk-smart: works again after a QTS update ([#696](https://github.com/Linuxfabrik/monitoring-plugins/issues/696))
* swap-usage: no longer aborts with `PdhAddEnglishCounterW failed`


## [2023051201] - 2023-05-12

### Breaking Changes

Monitoring Plugins:

* all Python 2 based plugins and libraries are gone, and the "3" suffix is dropped from the Python 3 ones ([#589](https://github.com/Linuxfabrik/monitoring-plugins/issues/589))
* the repository moves to a new directory structure ([#350](https://github.com/Linuxfabrik/monitoring-plugins/issues/350))
* disk-usage: `--ignore` is dropped in favour of including mount points and file systems ([#662](https://github.com/Linuxfabrik/monitoring-plugins/issues/662))
* keycloak-version, php-version, wordpress-version: simplified, no longer care about patch levels, no longer need internet access, and dropped some parameters

Assets:

* sudoers: simplified ([#651](https://github.com/Linuxfabrik/monitoring-plugins/issues/651))

### Added

Monitoring Plugins:

* new checks: apache-httpd-version, by-ssh, cometsystem, fedora-version, githubstatus, grafana-version, mysql-version, network-io, openstack-swift-stat, postfix-version, rhel-version, safenet-hsm-state ([#619](https://github.com/Linuxfabrik/monitoring-plugins/issues/619), [PR #648](https://github.com/Linuxfabrik/monitoring-plugins/pull/648), [PR #650](https://github.com/Linuxfabrik/monitoring-plugins/pull/650), thanks to [Dominik Riva](https://github.com/slalomsk8er))

Grafana:

* new and updated panels, plus a dashboard for the built-in icinga command ([#577](https://github.com/Linuxfabrik/monitoring-plugins/issues/577))

### Changed

Monitoring Plugins:

* apache-httpd-status: the `ReqPerSec`, `BytesPerSec`, `BytesPerReq` and `DurationPerReq` perfdata is gone, the values were wrong
* disk-io: `--ignore` ignores all disks starting with the given value, and the top 3 I/O processes moved here ([#285](https://github.com/Linuxfabrik/monitoring-plugins/issues/285))
* disk-usage: mount points and file systems can be included, absolute values are allowed for the thresholds, and the table also shows "free" ([#114](https://github.com/Linuxfabrik/monitoring-plugins/issues/114), [#482](https://github.com/Linuxfabrik/monitoring-plugins/issues/482), [#662](https://github.com/Linuxfabrik/monitoring-plugins/issues/662))
* fortios-version: simplified, returns the version information in the perfdata
* journald-query: the default `--since` drops from 24h to 8h
* kemp-services: displays the original status of every Virtual Service ([#654](https://github.com/Linuxfabrik/monitoring-plugins/issues/654))
* nextcloud-version: simplified, no longer needs internet access
* php-fpm-status: the meaningless `req per sec` perfdata is gone
* php-status: `monitoring.php` moved, and one perfdata item is renamed to `php-opcache-memory_usage-current_wasted-percentage`
* restic-snapshots: shorter output, `--lengthy` for the full table, and the default grouping changes to 'host,paths'

### Fixed

Monitoring Plugins:

* disk-smart: no longer aborts with `KeyError: 'serial_number'` ([#659](https://github.com/Linuxfabrik/monitoring-plugins/issues/659))
* disk-usage: works with current psutil ([#663](https://github.com/Linuxfabrik/monitoring-plugins/issues/663))
* file-age: works with current psutil on SMB shares ([#665](https://github.com/Linuxfabrik/monitoring-plugins/issues/665))
* kemp-services: the credentials are converted correctly ([#653](https://github.com/Linuxfabrik/monitoring-plugins/issues/653))

### Removed

Monitoring Plugins:

* top3-processes-which-caused-the-most-io, moved into disk-io


## [2023030801] - 2023-03-08

### Breaking Changes

Monitoring Plugins:

* journald-query: `--grep` and `--case-sensitive` are replaced by `--ignore-regex`, and the check comes with a new filter ([#641](https://github.com/Linuxfabrik/monitoring-plugins/issues/641))
* journald-usage: `--warning` switches from MiB to GiB
* mysql-\*: `--hostname`, `--password`, `--port` and `--username` are gone, all checks authenticate through an option file
* pip-updates, redis-status, service, veeam-status: rewritten or extended, all four come with new parameters ([#646](https://github.com/Linuxfabrik/monitoring-plugins/issues/646), [#623](https://github.com/Linuxfabrik/monitoring-plugins/issues/623), [#630](https://github.com/Linuxfabrik/monitoring-plugins/issues/630))

Icinga Director:

* removed Service Sets: "OS - RHEL 7 Basic (Hardware)", all six oVirt sets, "PostgreSQL 9.6", plus the duplicate tags "redhat7" and "redhat8"

### Added

Monitoring Plugins:

* new checks: crypto-policy, csv-values, grassfish-licenses, grassfish-players, grassfish-screens, infomaniak-events, journald-query, journald-usage, ntp-chronyd, ntp-ntpd, ntp-systemd-timesyncd, restic-check, restic-snapshots, restic-stats, systemd-timedate-status, tuned-profile. The three ntp checks replace ntp-offset ([#449](https://github.com/Linuxfabrik/monitoring-plugins/issues/449))

Notification Plugins:

* notify-host-rocketchat-telegram, notify-host-zoom, notify-service-rocketchat-telegram

Icinga Director:

* new Service Sets: AIDE, Apache for Debian 11, Basic for Debian 11, FreeIPA Server, Grav, Ubuntu 22, UPS (Network UPS Tools), plus debug-shell.service in all RHEL-based Basic Service Sets

Assets:

* SELinux Type Enforcement Policies, and sudoers files for Alma 9, RHEL 9, Rocky 9, Fedora 37, Oracle 7, Oracle 8 and Oracle 9 ([#627](https://github.com/Linuxfabrik/monitoring-plugins/issues/627))

### Changed

Monitoring Plugins:

* about-me: rewritten, recommends tags for the Icinga Director basket with `--tags`, detects restic and Snap, reports maker and model, and the external IP lookup is configurable and off by default ([#637](https://github.com/Linuxfabrik/monitoring-plugins/issues/637), [#645](https://github.com/Linuxfabrik/monitoring-plugins/issues/645))
* disk-usage: the state moves into the usage column
* fs-ro: squashfs and ramfs are excluded ([#412](https://github.com/Linuxfabrik/monitoring-plugins/issues/412), [#617](https://github.com/Linuxfabrik/monitoring-plugins/issues/617))
* infomaniak-swiss-backup-\*: adapted to the new API version
* mysql-connections: `--ignore-name-resolution` ([#631](https://github.com/Linuxfabrik/monitoring-plugins/issues/631))
* mysql-user-security: ignores the mysql.sys and mariadb.sys users
* network-connections: alerts above a configurable number of connections ([#621](https://github.com/Linuxfabrik/monitoring-plugins/issues/621))
* php-status: the URL to monitoring.php is optional, and startup, config and module errors are reported more clearly
* redis-status: no longer warns on "Peak memory"
* service: checks several Windows services at once ([#609](https://github.com/Linuxfabrik/monitoring-plugins/issues/609))

Icinga Director:

* the MariaDB/MySQL service set is split into InnoDB, Metrics, Replication, Schemas, Security and a baseline set
* the RHEL and Fedora sets gain TuneD Profile and Crypto Policy, every set with a systemd service gains a matching Journald Query and Systemd TimeDate Status, and notifications are enabled only for critical hardware-related services

### Fixed

Monitoring Plugins:

* disk-usage: CDFS is ignored by default ([#632](https://github.com/Linuxfabrik/monitoring-plugins/issues/632))
* docker-stats: the container name in the perfdata is shortened as intended ([#600](https://github.com/Linuxfabrik/monitoring-plugins/issues/600))
* file-age: new files are no longer reported critical because of a negative modification time ([#618](https://github.com/Linuxfabrik/monitoring-plugins/issues/618))
* infomaniak-swiss-backup-devices: no longer aborts with a TypeError
* librenms-version: no longer aborts with `KeyError: 'mysql_ver'` ([#602](https://github.com/Linuxfabrik/monitoring-plugins/issues/602))
* matomo-reporting: `--metric` returns the one metric asked for ([#603](https://github.com/Linuxfabrik/monitoring-plugins/issues/603))
* nextcloud-stats: no longer aborts on a missing ALWAYS_OK attribute ([#640](https://github.com/Linuxfabrik/monitoring-plugins/pull/640))
* ping: no longer aborts because `ping -t` was handed a float ([#628](https://github.com/Linuxfabrik/monitoring-plugins/issues/628))
* rpm-lastactivity: no longer aborts with a ValueError ([#616](https://github.com/Linuxfabrik/monitoring-plugins/issues/616))
* updates: no longer returns a PowerShell error on Windows behind a closed firewall ([#633](https://github.com/Linuxfabrik/monitoring-plugins/issues/633))

### Removed

Monitoring Plugins:

* ntp-offset, split into ntp-chronyd, ntp-ntpd and ntp-systemd-timesyncd ([#449](https://github.com/Linuxfabrik/monitoring-plugins/issues/449))
* all plugins: the code for self-handling Python virtual environments ([#543](https://github.com/Linuxfabrik/monitoring-plugins/issues/543))

Icinga Director:

* DiagTrack, Windows telemetry, is gone from the Windows Service Sets


## [2022072001] - 2022-07-20

### Breaking Changes

Monitoring Plugins:

* wildfly-memory-pool-usage: `--warning` and `--critical` are gone, they are not needed any more ([#563](https://github.com/Linuxfabrik/monitoring-plugins/issues/563))

### Added

Monitoring Plugins:

* new checks: diacos, infomaniak-swiss-backup-devices, infomaniak-swiss-backup-products, strongswan-connections, xml, the whole mysql-\* family (aria, binlog-cache, connections, database-metrics, innodb-buffer-pool-instances, innodb-buffer-pool-size, innodb-log-waits, joins, logfile, memory, open-files, perf-metrics, replica-status, slow-queries, sorts, storage-systems, system, table-cache, table-definition-cache, table-indexes, temp-tables, thread-cache, traffic, user-security) and the nodebb-\* family (cache, database, errors, events, groups, info, users) ([PR #567](https://github.com/Linuxfabrik/monitoring-plugins/pull/567), [PR #583](https://github.com/Linuxfabrik/monitoring-plugins/pull/583), thanks to [Dominik Riva](https://github.com/slalomsk8er))

Icinga Director:

* duplicity Service Set, strongSwan Service Set

Assets:

* sudoers files for Fedora 35 and Fedora 36

### Changed

Monitoring Plugins:

* about-me: reports birthdate, boot mode, listening ports, the active tuned profile and the key features of the machine, and detects AIDE, certbot, acme.sh, gpg, mod_security and swanctl
* all checks using SQLite databases: more unique database names ([#333](https://github.com/Linuxfabrik/monitoring-plugins/issues/333))
* cpu-usage: the "nice" percentage is subtracted from the thresholds ([#550](https://github.com/Linuxfabrik/monitoring-plugins/issues/550))
* dhcp-scope-usage: parses PercentageInUse locale-aware ([PR #551](https://github.com/Linuxfabrik/monitoring-plugins/pull/551))
* disk-smart: runs on Windows, and excludes zfs volumes ([PR #539](https://github.com/Linuxfabrik/monitoring-plugins/pull/539), [PR #553](https://github.com/Linuxfabrik/monitoring-plugins/pull/553))
* disk-usage: the first output line no longer says "OK" while the check is critical ([#545](https://github.com/Linuxfabrik/monitoring-plugins/issues/545))
* docker-info: raises CRIT on a return code other than 0 ([#569](https://github.com/Linuxfabrik/monitoring-plugins/issues/569))
* docker-stats: better handling of container names ([#586](https://github.com/Linuxfabrik/monitoring-plugins/issues/586))
* file-age: shorter message and better perfdata labels ([#559](https://github.com/Linuxfabrik/monitoring-plugins/issues/559), [PR #544](https://github.com/Linuxfabrik/monitoring-plugins/pull/544))
* ipmi-sel: the events are ordered differently ([#558](https://github.com/Linuxfabrik/monitoring-plugins/issues/558))
* needs-restarting: works on Debian Buster and Bullseye ([#572](https://github.com/Linuxfabrik/monitoring-plugins/issues/572))
* php-status: different handling of default values, and `--dev` suppresses the warnings on display_errors and display_startup_errors ([#461](https://github.com/Linuxfabrik/monitoring-plugins/issues/461), [#540](https://github.com/Linuxfabrik/monitoring-plugins/issues/540))
* qts-\*: the default connect timeout rises from 3 to 6 seconds
* systemd-units-failed: `--ignore` accepts wildcards ([#542](https://github.com/Linuxfabrik/monitoring-plugins/issues/542))

Icinga Director:

* longer check intervals for the Windows services

### Fixed

Monitoring Plugins:

* file-count: no longer aborts with `KeyError: 'lib'` ([#591](https://github.com/Linuxfabrik/monitoring-plugins/issues/591))
* fortios-memory-usage: works on Python 3 ([PR #599](https://github.com/Linuxfabrik/monitoring-plugins/pull/599))
* keycloak-version: no longer aborts on a missing match ([#555](https://github.com/Linuxfabrik/monitoring-plugins/issues/555))
* logfile: no longer runs into "Database locked" and UNKNOWN under heavy use on one host ([#578](https://github.com/Linuxfabrik/monitoring-plugins/issues/578))
* xca-cert: checks the expiry date again

### Removed

Monitoring Plugins:

* mysql-stats, nodebb-stats, nodebb-status

Icinga Director:

* gpsvc on Windows


## [2022030201] - 2022-03-02

This is a "we migrated everything from GitLab to GitHub, but had to adjust many details afterwards" version. **In terms of source code, nothing has changed** compared to 2022022801, just a bunch of links in source code comments and READMEs.


## [2022022801] - 2022-02-28

### Breaking Changes

* this is the last release including bugfixes for the Python 2 variant of all checks
* the project moved from our self-hosted GitLab to a [public repo on GitHub](https://github.com/linuxfabrik/monitoring-plugins). The branches "master" and "develop" are gone, releases are built from tags on "main", and all commit hashes changed with the removal of the binaries
* the checks compiled for Windows moved to the [download server](https://download.linuxfabrik.ch//monitoring-plugins/windows)

### Added

Monitoring Plugins:

* dhcp-scope-usage: IPv4 scope usage of a Windows DHCP server, locally via PowerShell or remotely via WinRM
* huawei-dorado-\*: backup power modules, controller, disks, enclosures, fans, interfaces, power, attached hosts, the system itself and the HyperMetro domain and pairing information of a Huawei OceanStor Dorado storage system
* redfish-drives, redfish-sel, redfish-sensor: drives, system event logs and sensor data of a Redfish-based BMC

Notification Plugins:

* notify via Zoom, notify via e-mail

Icinga Director:

* new Service Sets: acme.sh, Active Directory Certificate Services, Active Directory Domain Services, Active Directory Federation Services, Active Directory Lightweight Directory Services, DHCP Server, DHCP Server Failover Feature, DNS Server, Duplicati, Huawei Dorado, Redfish, Redfish no agent, Veeam Backup & Replication, Web Server (IIS), Windows Basic extended, Windows Defender Antivirus Service

Assets:

* sudoers for Rocky 8 and openSUSE Leap 15

### Changed

Monitoring Plugins:

* about-me: reports virtualisation, detects ownCloud and an alternate Nextcloud path, and runs even when psutil is missing ([#480](https://github.com/Linuxfabrik/monitoring-plugins/issues/480), [#512](https://github.com/Linuxfabrik/monitoring-plugins/issues/512), [#514](https://github.com/Linuxfabrik/monitoring-plugins/issues/514))
* librenms-alerts, librenms-health: more filtering parameters, among them `--device-group`
* nginx-status: prints human-readable total values ([#520](https://github.com/Linuxfabrik/monitoring-plugins/issues/520))
* php-status: hints when it is not running with sudo ([#459](https://github.com/Linuxfabrik/monitoring-plugins/issues/459))
* redis-status: supports Redis 3.0, is more tolerant about defragmentation, warns only below a 10% cache hit rate, and warns on a bad OS configuration ([#425](https://github.com/Linuxfabrik/monitoring-plugins/issues/425), [#428](https://github.com/Linuxfabrik/monitoring-plugins/issues/428), [#490](https://github.com/Linuxfabrik/monitoring-plugins/issues/490), [#510](https://github.com/Linuxfabrik/monitoring-plugins/issues/510))
* rocketchat-stats: rocket.chat is renamed to rocketchat ([#335](https://github.com/Linuxfabrik/monitoring-plugins/issues/335))
* swap-usage: no longer displays "swapped in" and "swapped out" on Windows ([#454](https://github.com/Linuxfabrik/monitoring-plugins/issues/454))
* veeam-status: `--username` and `--password` are mandatory ([#499](https://github.com/Linuxfabrik/monitoring-plugins/issues/499))
* wildfly-deployment-status: the deployment can be limited by name ([#497](https://github.com/Linuxfabrik/monitoring-plugins/issues/497))

Icinga Director:

* the Huawei service names and the Windows variants are adapted, notifications are enabled for the Redfish checks, the LibreNMS services are split by type, and getent gets a 30 second timeout ([#455](https://github.com/Linuxfabrik/monitoring-plugins/issues/455))

### Fixed

Monitoring Plugins:

* about-me: no longer aborts on a VMware hypervisor check, an index error or a missing psutil attribute ([#438](https://github.com/Linuxfabrik/monitoring-plugins/issues/438), [#443](https://github.com/Linuxfabrik/monitoring-plugins/issues/443), [#513](https://github.com/Linuxfabrik/monitoring-plugins/issues/513))
* apache-httpd-status: no longer aborts on Ubuntu 16.04 ([#436](https://github.com/Linuxfabrik/monitoring-plugins/issues/436))
* borgbackup: no longer aborts with an AttributeError ([#430](https://github.com/Linuxfabrik/monitoring-plugins/issues/430))
* disk-smart: disk names such as sdda and sdab are checked ([#487](https://github.com/Linuxfabrik/monitoring-plugins/issues/487))
* file-age: files dated in the future are handled, and the Windows variant no longer crashes on a glob wildcard ([#478](https://github.com/Linuxfabrik/monitoring-plugins/issues/478), [#494](https://github.com/Linuxfabrik/monitoring-plugins/issues/494))
* fs-xfs-stats: handles an I/O error while reading /proc/fs/xfs/stat ([#445](https://github.com/Linuxfabrik/monitoring-plugins/issues/445))
* jitsi-videobridge-status: no longer aborts with a TypeError ([#527](https://github.com/Linuxfabrik/monitoring-plugins/issues/527))
* librenms-health: no longer times out on too many values ([#365](https://github.com/Linuxfabrik/monitoring-plugins/issues/365))
* nextcloud-stats: no longer aborts on encoding errors, and the DB size is no longer reported in YiB ([#463](https://github.com/Linuxfabrik/monitoring-plugins/issues/463), [#517](https://github.com/Linuxfabrik/monitoring-plugins/issues/517), [#531](https://github.com/Linuxfabrik/monitoring-plugins/issues/531))
* nginx-status: the perfdata is correct ([#440](https://github.com/Linuxfabrik/monitoring-plugins/issues/440))
* ntp-offset: no longer regularly UNKNOWN when used with chrony ([#71](https://github.com/Linuxfabrik/monitoring-plugins/issues/71))
* php-status: handles a missing display_startup_errors ([#434](https://github.com/Linuxfabrik/monitoring-plugins/issues/434))
* php-version: no longer warns about a patch release that is not newer ([#435](https://github.com/Linuxfabrik/monitoring-plugins/issues/435))
* procs: no longer aborts on Windows, no longer reports "oldest proc created 52Y 1M ago", and reports a missing process as missing ([#453](https://github.com/Linuxfabrik/monitoring-plugins/issues/453), [#488](https://github.com/Linuxfabrik/monitoring-plugins/issues/488), [#506](https://github.com/Linuxfabrik/monitoring-plugins/issues/506))
* redis-status: no longer reports a false somaxconn warning, detects Redis forced into swap, and no longer warns about the password on the command line ([#450](https://github.com/Linuxfabrik/monitoring-plugins/issues/450), [#458](https://github.com/Linuxfabrik/monitoring-plugins/issues/458), [#486](https://github.com/Linuxfabrik/monitoring-plugins/issues/486))
* swap-usage: no longer aborts with an UnboundLocalError ([#456](https://github.com/Linuxfabrik/monitoring-plugins/issues/456))
* systemd-unit: failed units are printed with the correct columns on Fedora, and an empty UnitFileState is handled ([#328](https://github.com/Linuxfabrik/monitoring-plugins/issues/328), [#509](https://github.com/Linuxfabrik/monitoring-plugins/issues/509))
* users: no longer aborts on a decoding error on Windows, and a pipe symbol in the "WHAT" column no longer breaks the output ([#17](https://github.com/Linuxfabrik/monitoring-plugins/issues/17), [#451](https://github.com/Linuxfabrik/monitoring-plugins/issues/451))
* veeam-status: no longer aborts with a ValueError ([#45](https://github.com/Linuxfabrik/monitoring-plugins/issues/45))
* the Windows builds ship the required third-party Python modules again ([#504](https://github.com/Linuxfabrik/monitoring-plugins/issues/504))

Grafana:

* dns: the panels no longer divide the query time by 1000, and the fail2ban panel no longer lists "Banned IPs" twice ([#139](https://github.com/Linuxfabrik/monitoring-plugins/issues/139), [#453](https://github.com/Linuxfabrik/monitoring-plugins/issues/453))

Icinga Director:

* corrected the GUIDs in all-the-rest.json

### Removed

Icinga Director:

* SysMain and TimeBrokerSvc are gone from the Windows Service Set, and getent from the basic Service Sets ([#427](https://github.com/Linuxfabrik/monitoring-plugins/issues/427), [#446](https://github.com/Linuxfabrik/monitoring-plugins/issues/446))


## [2021101401] - 2021-10-14

### Added

Monitoring Plugins:

* all checks are ported to Python 3 (suffixed by `3`), most of them are also available on Windows, and all of them run on Rocky and Alma Linux
* new checks: jitsi-videobridge-stats, jitsi-videobridge-status, nodebb-stats, nodebb-status, nodebb-version, redis, sap-open-concur, veeam-status, and the starface-\* family (account, database and peer statistics, overall, backup and channel status, Java memory usage)

Event Plugins:

* cloudflare-security-level

Icinga Director:

* the Windows Basic Service Set gains disk-io, dns, swap-usage and top3-processes-which-caused-the-most-io

### Changed

Monitoring Plugins:

* about-me: reports much more inventory, among it interfaces, the systemd default target, timers, enabled units, mounts, automounts, non-default users and crontabs, plus GCC, GitLab, OpenVPN, Veeam and vsftpd detection
* apache-httpd-status: calculates ReqPerSec, BytesPerSec, BytesPerReq and DurationPerReq over Apache's uptime, and prints the worker percentage in the table
* dmesg: the output is capped at ten lines, and more messages are ignored by default ([#254](https://github.com/Linuxfabrik/monitoring-plugins/issues/254), [#338](https://github.com/Linuxfabrik/monitoring-plugins/issues/338))
* file-ownership: also checks /tmp/linuxfabrik-plugin-cache.db, with corrected defaults for Debian, SLES and Ubuntu ([#294](https://github.com/Linuxfabrik/monitoring-plugins/issues/294), [#317](https://github.com/Linuxfabrik/monitoring-plugins/issues/317), [#332](https://github.com/Linuxfabrik/monitoring-plugins/issues/332), [#356](https://github.com/Linuxfabrik/monitoring-plugins/issues/356))
* getent: also prints the response ([#297](https://github.com/Linuxfabrik/monitoring-plugins/issues/297))
* php-\*: report more, which needs the new `monitoring.php` installed
* php-status: the cache hit rate check is optional, "simplexml" is no longer a default module, and config and module errors are clearer ([#267](https://github.com/Linuxfabrik/monitoring-plugins/issues/267), [#284](https://github.com/Linuxfabrik/monitoring-plugins/issues/284), [#303](https://github.com/Linuxfabrik/monitoring-plugins/issues/303))
* php-version: checks major and minor by default rather than the patch level, and tests against the package manager ([#253](https://github.com/Linuxfabrik/monitoring-plugins/issues/253), [#304](https://github.com/Linuxfabrik/monitoring-plugins/issues/304))
* procs: counts more accurately, and can alert on specific processes ([#355](https://github.com/Linuxfabrik/monitoring-plugins/issues/355))
* systemd-unit: `--unitfilestate` accepts None to disable the unit file state check ([#299](https://github.com/Linuxfabrik/monitoring-plugins/issues/299))
* wildfly-gc-status, wildfly-memory-pool-usage: higher defaults for `avr_gc_time`, and "PS_Survivor_Space" no longer alerts ([#286](https://github.com/Linuxfabrik/monitoring-plugins/issues/286), [#307](https://github.com/Linuxfabrik/monitoring-plugins/issues/307))

Icinga Director:

* the command definitions are provided through the basket ([#301](https://github.com/Linuxfabrik/monitoring-plugins/issues/301))

### Fixed

Monitoring Plugins:

* about-me: shows all disks, no longer reports loolwsd when it is not installed, and no longer aborts on unpacking ([#281](https://github.com/Linuxfabrik/monitoring-plugins/issues/281), [#370](https://github.com/Linuxfabrik/monitoring-plugins/issues/370), [#372](https://github.com/Linuxfabrik/monitoring-plugins/issues/372))
* apache-httpd-status: no longer aborts on an unsupported operand type ([#323](https://github.com/Linuxfabrik/monitoring-plugins/issues/323))
* disk-io: negative rate differences after a reboot are handled ([#312](https://github.com/Linuxfabrik/monitoring-plugins/issues/312))
* dmesg: no longer counts one line too many ([#331](https://github.com/Linuxfabrik/monitoring-plugins/issues/331))
* file-age: negative times are handled correctly ([#188](https://github.com/Linuxfabrik/monitoring-plugins/issues/188))
* getent: no longer aborts on a decoding error ([#367](https://github.com/Linuxfabrik/monitoring-plugins/issues/367))
* mydumper-version: copes with a version such as "v0.10.7-2" ([#318](https://github.com/Linuxfabrik/monitoring-plugins/issues/318))
* network-port-tcp: no longer aborts with a NameError ([#298](https://github.com/Linuxfabrik/monitoring-plugins/issues/298))
* php-status: monitoring.php runs on PHP 7.2, and OPcache is no longer reported as missing when monitoring.php is not used ([#289](https://github.com/Linuxfabrik/monitoring-plugins/issues/289), [#290](https://github.com/Linuxfabrik/monitoring-plugins/issues/290), [#324](https://github.com/Linuxfabrik/monitoring-plugins/issues/324))
* php-version: no longer aborts on a Debian package version ([#293](https://github.com/Linuxfabrik/monitoring-plugins/issues/293))
* procs: the counting in the output is correct ([#357](https://github.com/Linuxfabrik/monitoring-plugins/issues/357))
* qts-temperatures: no longer aborts with a traceback ([#360](https://github.com/Linuxfabrik/monitoring-plugins/issues/360))
* service: reports the right state when a service is running but is not supposed to be ([#336](https://github.com/Linuxfabrik/monitoring-plugins/issues/336))
* systemd-unit: an empty UnitFileState is handled ([#292](https://github.com/Linuxfabrik/monitoring-plugins/issues/292))

### Removed

Monitoring Plugins:

* fah-stats, hostname and all Atlassian checks


## [2021061501] - 2021-06-15

### Added

Monitoring Plugins:

* half of the checks are ported to Python 3 (suffixed by `3`), 17 of them are available on Windows
* new checks: docker-info, docker-stats, fs-xfs-stats, haproxy-status, librenms-alerts, librenms-version, logfile, metabase-stats, mod-qos-stats, mydumper-version, nginx-status, onlyoffice-stats, path-rw-test, php-fpm-ping, php-fpm-status, php-status, php-version, pip-updates, snmp, and the wildfly-\* family (deployment status, garbage collector status, memory and memory pool usage, server status, thread usage, uptime, XA and non-XA datasource statistics)
* the human-readable units in the output are more precise: "MiB" always means Mebibyte, "M" means Month while "m" means Minute, and the SI symbol "G" means Billion
* the performance data names move towards Prometheus compatibility, starting with fs-xfs-stats and nginx-status

### Changed

Monitoring Plugins:

* about-me: detects Django, LibreNMS, mydumper, Nikto, OpenSSL, OpenVAS, tmate and more, reports the local and public IP address, and ignores zram devices ([#227](https://github.com/Linuxfabrik/monitoring-plugins/issues/227), [#256](https://github.com/Linuxfabrik/monitoring-plugins/issues/256))
* cpu-usage, file-descriptors, memory-usage: the three "Top 3" checks are merged into them ([#246](https://github.com/Linuxfabrik/monitoring-plugins/issues/246), [#247](https://github.com/Linuxfabrik/monitoring-plugins/issues/247), [#248](https://github.com/Linuxfabrik/monitoring-plugins/issues/248))
* disk-io: determines the maximum possible disk throughput automatically, and the separate "State" column is gone ([#279](https://github.com/Linuxfabrik/monitoring-plugins/issues/279))
* dmesg: uses `--ctime` instead of `--reltime`, caps the output at ten lines, and gained a severity parameter ([#115](https://github.com/Linuxfabrik/monitoring-plugins/issues/115), [#238](https://github.com/Linuxfabrik/monitoring-plugins/issues/238), [#254](https://github.com/Linuxfabrik/monitoring-plugins/issues/254))
* feed: no longer fetches items dated in the future, strips HTML from the content, and falls back to the "content" field of an Atom feed ([#95](https://github.com/Linuxfabrik/monitoring-plugins/issues/95), [#206](https://github.com/Linuxfabrik/monitoring-plugins/issues/206), [#207](https://github.com/Linuxfabrik/monitoring-plugins/issues/207))
* file-\*: deal directly with SMB/CIFS shares
* file-ownership: prints a table, and the default list follows the CIS CentOS standard ([#231](https://github.com/Linuxfabrik/monitoring-plugins/issues/231), [#233](https://github.com/Linuxfabrik/monitoring-plugins/issues/233))
* fortios-\*: the port can be specified, and the password is HTTP-encoded ([#186](https://github.com/Linuxfabrik/monitoring-plugins/issues/186), [#187](https://github.com/Linuxfabrik/monitoring-plugins/issues/187))
* ipmi-\*: can connect remotely to Supermicro IPMI, HPE iLO and DELL iDRAC ([#168](https://github.com/Linuxfabrik/monitoring-plugins/issues/168), [#169](https://github.com/Linuxfabrik/monitoring-plugins/issues/169))
* nextcloud-version: takes the Apache user from the owner of config/config.php, and handles the Enterprise channel ([#142](https://github.com/Linuxfabrik/monitoring-plugins/issues/142), [#225](https://github.com/Linuxfabrik/monitoring-plugins/issues/225))
* procs: the filters for username, process name and arguments are case-insensitive, the used filter is shown, and memory usage is always in the perfdata ([#261](https://github.com/Linuxfabrik/monitoring-plugins/issues/261), [#263](https://github.com/Linuxfabrik/monitoring-plugins/issues/263), [#264](https://github.com/Linuxfabrik/monitoring-plugins/issues/264))
* wildfly-gc-status: collection time and count are reported as continuous counters ([#185](https://github.com/Linuxfabrik/monitoring-plugins/issues/185))

### Fixed

Monitoring Plugins:

* about-me: disk sizes show up on CentOS ([#259](https://github.com/Linuxfabrik/monitoring-plugins/issues/259))
* apache-httpd-status: copes with HTML pages containing "::" ([#199](https://github.com/Linuxfabrik/monitoring-plugins/issues/199))
* disk-io: a negative RW5 is clamped to 0 ([#265](https://github.com/Linuxfabrik/monitoring-plugins/issues/265))
* disk-smart: ignores zram devices, and no longer aborts with a SyntaxError ([#220](https://github.com/Linuxfabrik/monitoring-plugins/issues/220), [#221](https://github.com/Linuxfabrik/monitoring-plugins/issues/221))
* feed: no longer runs into the 10s plugin timeout ([#83](https://github.com/Linuxfabrik/monitoring-plugins/issues/83))
* nextcloud-stats: num_users no longer counts every user who ever existed ([#224](https://github.com/Linuxfabrik/monitoring-plugins/issues/224))
* procs: checking processes by CPU usage is correct, and several tracebacks are gone ([#162](https://github.com/Linuxfabrik/monitoring-plugins/issues/162), [#166](https://github.com/Linuxfabrik/monitoring-plugins/issues/166), [#260](https://github.com/Linuxfabrik/monitoring-plugins/issues/260))
* users: no longer aborts on a decoding error on Windows ([#201](https://github.com/Linuxfabrik/monitoring-plugins/issues/201))

### Removed

Monitoring Plugins:

* fs-file-usage, replaced by file-descriptors ([#234](https://github.com/Linuxfabrik/monitoring-plugins/issues/234))
* three of the four "Top 3" checks, merged into cpu-usage, file-descriptors and memory-usage


## [2021021701] - 2021-02-17

### Fixed

Monitoring Plugins:

* the virtualenv is activated even when a plugin is called by an absolute path ([#154](https://github.com/Linuxfabrik/monitoring-plugins/issues/154))


## [2021021601] - 2021-02-16

### Added

Monitoring Plugins:

* support for running the plugins in a virtual environment

### Changed

Monitoring Plugins:

* file-age, file-count, file-size: support SMB
* nextcloud-version: returns UNKNOWN when the update server is unavailable, with a longer timeout ([#147](https://github.com/Linuxfabrik/monitoring-plugins/issues/147), [#148](https://github.com/Linuxfabrik/monitoring-plugins/issues/148))
* procs: thresholds for CPU and memory
* users: the missing perfdata on Windows

### Fixed

Monitoring Plugins:

* json: renamed to json-values, it collided with the official json library
* pip-version: the output message is no longer mixed up


## [2020122401] - 2020-12-24

### Added

Monitoring Plugins:

* new checks: dummy, file-count, json
* Windows builds for cpu-usage, disk-usage, dummy, file-age, file-count, file-size, json, memory-usage, network-connections, procs, scheduled-task, service, updates, uptime and users

### Changed

Monitoring Plugins:

* file-age, file-size: support globbing to select several files

### Fixed

Monitoring Plugins:

* users: the count on Windows includes disconnected users


## [2020112001] - 2020-11-20

### Changed

Monitoring Plugins:

* systemd-unit: knows more states


## [2020111901] - 2020-11-19

### Fixed

Monitoring Plugins:

* ntp-offset: no longer errors on a server without NTP ([#138](https://github.com/Linuxfabrik/monitoring-plugins/issues/138))


## [2020111801] - 2020-11-18

### Added

Assets:

* sudoers for Debian 9 and 10

### Fixed

Monitoring Plugins:

* disk-usage, dns: no longer abort with a traceback ([#132](https://github.com/Linuxfabrik/monitoring-plugins/issues/132), [#133](https://github.com/Linuxfabrik/monitoring-plugins/issues/133))
* ntp-offset: corrected logic ([#134](https://github.com/Linuxfabrik/monitoring-plugins/issues/134))


## [2020102301] - 2020-10-23

### Breaking Changes

* the repository is restructured, and the first Windows-compatible Python 3 check plugins arrive

### Added

Monitoring Plugins:

* new checks: atlassian-confluence-version, atlassian-jira-version, keycloak-version, pip-version, wordpress-version, and the qts-\* family (cpu-usage, disk-smart, memory-usage, temperatures, uptime, version)
* Windows builds for cpu-usage, disk-usage, file-age, file-size, memory-usage, network-connections, procs, scheduled-task, service, updates, uptime and users

Tools:

* grafana-tool, a utility to generate Grafana dashboards

### Changed

Monitoring Plugins:

* borgbackup: the expected string in the logfile changes from rc to retc
* feed: `--no-icinga-callback` is replaced by `--icinga-callback`

Assets:

* the sudoers are unified into one file per OS, in the assets/sudoers folder

### Fixed

Monitoring Plugins:

* feed: no longer aborts with a traceback ([#107](https://github.com/Linuxfabrik/monitoring-plugins/issues/107))
* memory-usage: prints the top 3 memory consuming processes on WARN and CRIT ([#108](https://github.com/Linuxfabrik/monitoring-plugins/issues/108))
* ntp-offset: supports systemd-timesyncd ([#90](https://github.com/Linuxfabrik/monitoring-plugins/issues/90))
* openvpn-client-list: the output is a table ([#19](https://github.com/Linuxfabrik/monitoring-plugins/issues/19))
* qts-version: no longer reports "None" after an update ([#112](https://github.com/Linuxfabrik/monitoring-plugins/issues/112))
* xca-cert: lists all checked certificates with common name, CA, serial and expiry date ([#65](https://github.com/Linuxfabrik/monitoring-plugins/issues/65))


## [2020061901] - 2020-06-19

### Added

Monitoring Plugins:

* network-bonding

### Fixed

Monitoring Plugins:

* nextcloud-version: no longer aborts with an AttributeError ([#105](https://github.com/Linuxfabrik/monitoring-plugins/issues/105))


## [2020052801] - 2020-05-28

### Added

Monitoring Plugins:

* new checks: fs-ro, kemp-services, matomo-reporting, matomo-version, sensors-battery, sensors-fans, sensors-temperatures, systemd-units-failed, and the fortios-\* family (cpu-usage, firewall-stats, ha-stats, memory-usage, network-io, sensor, version)

### Changed

Monitoring Plugins:

* most of the checks also run on Ubuntu Server 16 and newer
* any token and password URL parameter is printed with asterisks on a stack trace
* all checks calling shell commands force English output even when the system locale differs

### Fixed

Monitoring Plugins:

* apache-httpd-status: no longer aborts on Ubuntu 16, and reports a malformed server-info ([#97](https://github.com/Linuxfabrik/monitoring-plugins/issues/97), [#101](https://github.com/Linuxfabrik/monitoring-plugins/issues/101))
* disk-io: no longer counts loop devices on Ubuntu 20, and no longer aborts on Ubuntu 16 ([#87](https://github.com/Linuxfabrik/monitoring-plugins/issues/87), [#98](https://github.com/Linuxfabrik/monitoring-plugins/issues/98))
* disk-smart: no longer aborts when not running on hardware ([#82](https://github.com/Linuxfabrik/monitoring-plugins/issues/82))
* disk-usage: ignores snap and iso9660 devices ([#88](https://github.com/Linuxfabrik/monitoring-plugins/issues/88), [#100](https://github.com/Linuxfabrik/monitoring-plugins/issues/100))
* mailq: works with Exim ([#93](https://github.com/Linuxfabrik/monitoring-plugins/issues/93))
* nextcloud-version: no longer returns UNKNOWN when the update server is unavailable ([#99](https://github.com/Linuxfabrik/monitoring-plugins/issues/99))
* procs: the total process count in the perfdata is no longer always 0 ([#96](https://github.com/Linuxfabrik/monitoring-plugins/issues/96))


## [2020042001] - 2020-04-20

### Added

Monitoring Plugins:

* new checks: dns, fah-stats
* most of the checks also run on Ubuntu

### Fixed

Monitoring Plugins:

* about-me: reports the details of NVMe disks ([#89](https://github.com/Linuxfabrik/monitoring-plugins/issues/89))
* nextcloud-security-scan: no longer aborts on a missing urllib ([#91](https://github.com/Linuxfabrik/monitoring-plugins/issues/91))
* ping: no duplicate output ([#84](https://github.com/Linuxfabrik/monitoring-plugins/issues/84))


## [2020041501] - 2020-04-15

### Added

Monitoring Plugins:

* new checks: getent, nextcloud-version, ping, rocket.chat-version

### Removed

Monitoring Plugins:

* docker-info, docker-container, network-io, redis and xca-cert, to be rewritten from scratch


## [2020031201] - 2020-03-12

### Added

Monitoring Plugins:

* feed

### Changed

Monitoring Plugins:

* cpu-usage: adjusted to changes in psutil
* dmesg: a longer ignore list
* systemd-unit: improved output


## [2020022801] - 2020-02-28

Initial release for the general public.


[Unreleased]: https://github.com/Linuxfabrik/monitoring-plugins/compare/v8.0.0...HEAD
[v8.0.0]: https://github.com/Linuxfabrik/monitoring-plugins/compare/v7.0.0...v8.0.0
[v7.0.0]: https://github.com/Linuxfabrik/monitoring-plugins/compare/v6.0.0...v7.0.0
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
