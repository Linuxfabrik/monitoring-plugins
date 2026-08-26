# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [Unreleased]

### Breaking Changes

Icinga Director:

* the certificate check no longer ships a second, older service template under the same name. Delete the leftover `tpl-service-cert` whose check command is `cmd-check-url`, otherwise the Director may keep rendering that one and the check reports on the wrong endpoint ([#1474](https://github.com/Linuxfabrik/monitoring-plugins/issues/1474))
* the MySQL Database Metrics, Storage Engines and Table Indexes services swap their `Ignore Schemas` / `Ignore Tables` fields for `Match` / `Ignore`. Re-import the basket and move your patterns over, the old fields are no longer handed to the check
* the KVM Host Service Set no longer carries the libvirtd unit check. Which libvirt daemon a host runs is not a property of it being a KVM host, so the check moved into a `libvirtd` and a `virtqemud` Service Set of its own. Tag your hypervisors with whichever of the two they run, otherwise they lose the check on the next deployment; `about-me --tags` names the right one
* the RPM Updates Service Set and its `rpm-updates` host tag are gone. The check moved into the Fedora and RHEL Basic Service Sets, where a host carrying both would have ended up with the service twice. Drop the tag from your hosts. A host that carried the tag without the matching Basic Service Set needs that set to keep the check
* the Deb Updates and RPM Updates services report every pending update instead of security updates only, and they hold an ordinary update back for a week and a day before alerting on it. A security update still alerts right away. Expect hosts that have not been patched for over a week to go WARNING. Tick `Only Critical` on the service for the old report, or set `Grace Updates` to `0D` to alert on an ordinary update immediately

### Added

Monitoring Plugins:

* apache-httpd-disclosure: reports what an Apache httpd server gives away about itself in its HTTP responses ([#373](https://github.com/Linuxfabrik/monitoring-plugins/issues/373))
* apache-httpd-security: audits the loaded modules, the worker account, the file permissions and the request limits of a local Apache httpd installation ([#373](https://github.com/Linuxfabrik/monitoring-plugins/issues/373))
* conntrack: alerts when the netfilter connection tracking table fills up and when the kernel starts evicting connections or dropping packets
* cpu-vulnerabilities: alerts when the CPU is affected by a hardware vulnerability that no mitigation is holding off
* file-growth: alerts when a file grows or shrinks faster than a configured rate ([#48](https://github.com/Linuxfabrik/monitoring-plugins/issues/48))
* fs-mounts: alerts when a filesystem listed in `/etc/fstab` is not mounted, which no other check and no failed systemd unit reports
* kvm-cpu-usage: reports the CPU each virtual machine of a libvirt host uses, and how much CPU the host makes it wait for ([#644](https://github.com/Linuxfabrik/monitoring-plugins/issues/644))
* kvm-disk-io: reports what each virtual machine of a libvirt host reads and writes, and how long its storage takes to answer ([#644](https://github.com/Linuxfabrik/monitoring-plugins/issues/644))
* kvm-memory-usage: reports the memory each virtual machine of a libvirt host has, needs and occupies, and how much of the host is promised to them ([#644](https://github.com/Linuxfabrik/monitoring-plugins/issues/644))
* kvm-network-io: reports what each virtual machine of a libvirt host sends and receives per network interface, and the frames it loses ([#644](https://github.com/Linuxfabrik/monitoring-plugins/issues/644))
* kvm-storage-pool: reports the state and free space of a libvirt host's storage pools ([#644](https://github.com/Linuxfabrik/monitoring-plugins/issues/644))
* kvm-volume: reports what a libvirt host's storage pools hold and how far they have promised more space than they have ([#644](https://github.com/Linuxfabrik/monitoring-plugins/issues/644))
* md-raid: alerts when a software RAID array loses redundancy, when the kernel says a member is failing, and on inconsistent sectors
* memory-paging: alerts when a host pages to and from swap, which swap usage on its own never shows
* multipath: alerts when a LUN loses one of its paths and when a multipath map runs out of them altogether
* nfs-mounts: alerts when an NFS mount reports a stale file handle or stops answering, and never blocks on one itself
* nginx-disclosure: reports what an NGINX server gives away about itself and about the application behind it
* nginx-security: audits the loaded modules, the worker account, the file permissions and the request body limit of a local NGINX installation
* openstack-cinder-list: lists the block storage volumes of a project and alerts on the ones in a status that needs attention
* openstack-quota: alerts when the compute, block storage or network quotas of a project fill up ([#489](https://github.com/Linuxfabrik/monitoring-plugins/issues/489))
* psi-cpu: alerts when work waits for a CPU, which CPU utilization and the load average do not show ([#746](https://github.com/Linuxfabrik/monitoring-plugins/issues/746))
* psi-io: alerts when work waits for storage, which throughput and device utilization do not show ([#746](https://github.com/Linuxfabrik/monitoring-plugins/issues/746))
* psi-irq: alerts when the CPUs are busy servicing interrupts instead of running work ([#746](https://github.com/Linuxfabrik/monitoring-plugins/issues/746))
* psi-memory: alerts when work waits for memory, which memory and swap usage do not show ([#746](https://github.com/Linuxfabrik/monitoring-plugins/issues/746))
* redfish-*: `--verbose` records every request to the management controller, with timings, into a log file, so a check that runs into its timeout can be diagnosed ([#1372](https://github.com/Linuxfabrik/monitoring-plugins/discussions/1372))

Icinga Director:

* `libvirtd Service Set` (host tag `libvirtd`) and `virtqemud Service Set` (host tag `virtqemud`), one per libvirt daemon. A host runs either the monolithic daemon or the modular one
* `Sensors Service Set` (host tag `sensors`) runs the fan and temperature checks, and `smartmontools Service Set` (host tag `smartmontools`) runs the SMART check. Both checks shipped without a tag so far, which meant nothing rolled them out. `about-me --tags` proposes them on real hardware and stays quiet on a virtual machine
* `MD RAID Service Set` (host tag `md-raid`) and `Multipath Service Set` (host tag `multipath`) run the two new storage checks. Neither belongs in the OS Basic Service Sets, because neither exists on an ordinary virtual machine. `about-me --tags` proposes both
* `NFS Client Service Set` (host tag `nfs-client`) runs the NFS mount check, as the counterpart to the existing `nfs-server` tag. `about-me --tags` proposes it on a host that mounts NFS or is set up to

### Changed

Monitoring Plugins:

* apache-httpd-status: worker usage counts every busy slot, so a graceful restart no longer reads as an idle server; rates replace per-interval totals and `ExtendedStatus Off` no longer blanks most metrics
* cert: reaches a TLS endpoint through an HTTP proxy, so the certificate an external client sees can be checked from inside ([#1474](https://github.com/Linuxfabrik/monitoring-plugins/issues/1474))
* countdown: reports its dates as a table, thresholds accept Nagios ranges, and days left are reported as performance data
* cpu-usage: alerts when an oversubscribed hypervisor takes CPU time away from a virtual machine, at 10% steal by default
* deb-updates, rpm-updates: `--grace-updates` and `--grace-security` hold an alert back until an update has been pending for a while, so a host stays quiet about updates it has had no chance to install yet. Both are off in the plugin; the Director service template sets a week plus a day for ordinary updates and nothing for security ones
* dmesg: fewer false alarms on physical servers and in virtual machines
* file-age, file-size: no longer shipped in the sudoers allowlist and no longer offer a `-sudo` check command, so they see only the files the monitoring user may read
* file-age, file-count, file-growth, file-size: the summary line names the range a file broke in plain words (`2 not in (0s..2D) [WARNING]`) instead of repeating the threshold syntax
* kvm-vm: reports a machine set to start with the host but not running, and no longer needs root, so it is gone from the sudoers allowlist
* lynis: alerts when no host was audited and says why, and counts answering hosts apart from probed addresses
* mysql-database-metrics, mysql-storage-engines, mysql-table-indexes: `--ignore-schemas` and `--ignore-tables` are deprecated in favour of `--match` and `--ignore`, and keep working
* nextcloud-stats: also lists the five accounts using the most storage, and runs longer on instances with many accounts ([#103](https://github.com/Linuxfabrik/monitoring-plugins/issues/103))
* openstack-nova-list: a password reset or a rescue image no longer alerts as CRITICAL
* openstack-swift-stat: alerts on the object quota of a container and on the account quota, reuses the token of the previous run, reads only the containers the filters keep, and no longer drops one the store refused
* procs: reports how many processes the system creates per second, which a headcount of running processes never shows (Linux only)

Icinga Director:

* the Apache apache2 Service Set for Ubuntu is renamed to "(Ubuntu 22+)"
* the Basic Service Sets also report excluded and pinned packages, so a host carrying a repository exclude or an APT pin goes WARNING
* the Basic Service Sets no longer report a version lock on the monitoring plugins packages themselves
* the Basic Service Sets no longer report the exclusions and pins that the Grafana and InfluxData repository configurations set
* the Huawei Dorado Service Set runs the storage pool check
* the Needs Restarting service runs hourly instead of once a day

Grafana:

* apache-httpd-status: re-import the dashboard, the metric names changed
* cpu-usage: re-import the dashboard, it has panels for steal time and for the per-core utilization
* kvm-vm: import the dashboard, the check ships one now
* procs: re-import the dashboard, it has a panel for the fork rate

### Removed

Monitoring Plugins:

* swap-usage: the cumulative `sin` and `sout` metrics are gone, memory-paging reports the paging traffic as a rate

Build, CI/CD:

* Drop packages for Ubuntu 20.04

Icinga Director:

* the Basic and Apache Service Sets for Debian 10, RHEL 7, Ubuntu 16, Ubuntu 18 and Ubuntu 20 are gone, together with their host tags. Hosts still carrying those tags lose their checks on the next deployment; retag them or drop them from monitoring
* the `File Size - /var/log/audit/audit.log` service is gone from the RHEL and Fedora Basic Service Sets. auditd rotates its log at 8 MB by default, so a threshold of 180/200 MB could never fire; PLUGINS-FILE.md shows what to watch instead

### Fixed

Monitoring Plugins:

* apache-httpd-disclosure, nextcloud-status, nginx-disclosure, spring-boot-actuator-health, wordpress-checksums: use the proxy the environment names, and honour `--no-proxy`; they connected directly no matter what was set
* countdown: a malformed `--input` names the date it cannot read instead of printing a traceback
* cpu-usage: the CPU percentages of a host running virtual machines were wrong, guest time was counted twice
* deb-updates, icinga-topflap-services, kubectl-get-pods, rpm-updates: two runs of the same check at the same time no longer report each other's rows
* deb-updates: `--only-critical` no longer stays OK on a fresh security update that only the security repository offers
* disk-usage: no longer runs forever when a network filesystem stops answering. It reports that filesystem as unreachable and the others as usual, and `--fstype` and `--list-fstypes` work again on such a host
* disk-usage: the warning and critical lines in the graphs stay on the chart for filesystems smaller than an absolute `FREE` threshold
* file-ownership: a `--filename` that is missing its `owner:group,` prefix names the expected format instead of crashing
* grassfish-players: the warning line in the player-count graphs matches when the check actually warns, instead of showing the `--warning` hours
* haproxy-status: the performance data no longer breaks when a health check fails or a server is tracked
* keycloak-memory-usage, keycloak-stats, keycloak-version: name the missing "manage-realm" role instead of crashing when Keycloak withholds the server info
* about-me: recognises a KVM host again. It only ever asked about `libvirtd`, which current installations do not run, so no hypervisor with the modular daemons was tagged
* kvm-vm: a machine that crashed, was killed off the host or never started is reported instead of counted as switched off
* kvm-vm: no longer fails on a machine whose name contains a space, and reports the machines of the host instead of an empty list when it runs without root
* openstack-nova-list, openstack-swift-stat: no longer killed on a slow cloud, and use the domain the rc file names
* path-rw-test: no longer runs forever when a path sits on a network filesystem whose server stopped answering; such a path is reported like one that cannot be written to
* php-status: no longer warns when `post_max_size` is smaller than `upload_max_filesize`, which only limits classic form uploads
* redfish-\*: the checks recover on their own after a management controller drops its sessions, instead of failing until their cached credentials expire. They also log in far less often, no longer leave a session behind on every login, and retry a login that fails once instead of falling back to slower authentication ([#1372](https://github.com/Linuxfabrik/monitoring-plugins/discussions/1372))

Icinga Director:

* the Active Directory Domain Service Set names two services the way the rest of the set does, `Service - ADWS` becomes `Service - Active Directory Web Services` and `Service - DFSR` becomes `Service - DFS Replication`. Both are renamed on the next deployment and start their history over
* the Huawei Dorado Service Set runs all of its checks again, six of its services shared one name and only one of them was deployed

Build, CI/CD:

* the SELinux policy loads on RHEL 10 again, on fully updated hosts as well as on those still on the initial release

Grafana:

* series hidden from a panel no longer show up in its tooltip. Re-import the affected dashboards (the Icinga overview plus apache-httpd-status, cpu-usage, disk-io, keycloak-memory-usage, load, memory-usage, network-io, php-status, ping, procs, swap-usage)


## [v7.0.0] - 2026-08-14

**Highlights:** `disk-io` no longer raises false CRITICALs on ZFS and Proxmox, and the Redfish checks no longer time out on large servers. Thirty-five new checks cover Docker, Podman, Huawei OceanStor, WordPress and the package managers' version locks. Counters are now reported as per-second rates and `redfish-*` requires an explicit `--url`, so re-import the affected Grafana dashboards and review your Redfish commands before updating. The Icinga Director templates now keep configuration on the master, which stops deployments on setups with a satellite tier.

### Breaking Changes

Monitoring Plugins:

* counters are reported as per-second rates, and some metric names change. Re-import the affected Grafana dashboards (cpu-usage, disk-io, fs-xfs-stats, jitsi-videobridge-stats, network-io, nginx-status, nodebb-cache, nodebb-errors, procs, redis-status, starface-database-stats, valkey-status, wildfly-gc-status) ([#320](https://github.com/Linuxfabrik/monitoring-plugins/issues/320))
* disk-io: no longer measures I/O wait and is WARN-only, so `--critical` and the `--iowait-*` thresholds are ignored. Re-import the Grafana dashboard
* docker-stats, podman-stats: every character outside letters, digits and underscore in a per-container metric name becomes an underscore, so `web.1` is now `web_1`. Adjust dashboards and graphs built on those metrics
* huawei-dorado-\*: performance data metric names, capacity units and voltage units changed. Re-import the affected Grafana dashboards
* redfish-\*: `--url` is mandatory, the localhost default is gone. Add it to every Redfish command ([#1306](https://github.com/Linuxfabrik/monitoring-plugins/issues/1306))

Icinga Director:

* the Host and Service templates are pinned to the master zone, so credentials stay on the master instead of reaching every agent. Setups with a satellite tier no longer deploy; unset the zone on `tpl-host-generic` and `tpl-service-generic` to restore the previous behaviour ([#721](https://github.com/Linuxfabrik/monitoring-plugins/issues/721))

### Added

Monitoring Plugins:

* apache-tomcat-version: check for an end-of-life or outdated Apache Tomcat ([#126](https://github.com/Linuxfabrik/monitoring-plugins/issues/126))
* deb-versionlock: check alerting on packages APT holds back
* docker-container, podman-container: check for unhealthy, unexpected-state, frequently restarting or too-young containers
* docker-image, podman-image: check alerting on images older than a configurable age
* docker-service: check alerting when a Docker Swarm service runs fewer tasks than expected
* docker-swarm: check alerting on swarm membership, a down node, or lost manager quorum
* huawei-dorado-alarm: check listing the current alarms
* huawei-dorado-expboard: check alerting on a faulty expansion board
* huawei-dorado-lun: check alerting on a faulty LUN, and on a thin LUN filling up
* huawei-dorado-port: check alerting on a faulty or too slowly negotiated front-end port
* huawei-dorado-sfp: check alerting on a faulty optical module, or one whose light levels leave its operating range
* huawei-dorado-storagepool: check alerting on a faulty storage pool, and on one filling up
* huawei-pacific-alarm: check listing the current alarms
* huawei-pacific-disk: check alerting on a faulty disk, and on one running out of remaining life
* huawei-pacific-fan: check alerting on a faulty fan
* huawei-pacific-namespace: check alerting when a namespace cannot be reached or turned read-only
* huawei-pacific-node: check alerting on a faulty cluster node and on an expired warranty
* huawei-pacific-power: check alerting on a faulty power supply
* huawei-pacific-quota: check alerting when a share fills up its quota
* huawei-pacific-replicationpair: check alerting when a remote replication pair stops mirroring, and optionally when its last synchronization gets too old
* huawei-pacific-service: check alerting when a service process on a cluster node is not running
* huawei-pacific-storagepool: check alerting on a faulty storage pool, and on one filling up
* huawei-pacific-system: check alerting on cluster capacity usage
* icingaweb2-module-updates: check alerting when an Icinga Web 2 module installed from a tarball or a Git checkout is behind its latest GitHub release ([#124](https://github.com/Linuxfabrik/monitoring-plugins/issues/124))
* kdump: check alerting when a kernel panic cannot be captured, or when a previous panic left a crash dump behind
* librenms-validate: check alerting on the problems LibreNMS reports about its own installation ([#366](https://github.com/Linuxfabrik/monitoring-plugins/issues/366))
* network-errors: check alerting on interface receive and transmit errors ([#707](https://github.com/Linuxfabrik/monitoring-plugins/issues/707))
* nextcloud-app-updates: check alerting when a Nextcloud app update is pending longer than a grace period ([#62](https://github.com/Linuxfabrik/monitoring-plugins/issues/62))
* nextcloud-status: check alerting on a pending database upgrade or on maintenance mode ([#329](https://github.com/Linuxfabrik/monitoring-plugins/issues/329))
* rpm-versionlock: check alerting on packages the RPM package manager holds back
* wildfly-version: check alerting when WildFly is behind the latest stable release ([#123](https://github.com/Linuxfabrik/monitoring-plugins/issues/123))
* wordpress-checksums: check verifying core and plugin files against the checksums wordpress.org publishes
* wordpress-security-scan: check scanning a WordPress site for known vulnerabilities and exposed credentials

Icinga Director:

* `Icinga Web 2 Service Set` (host tag `icingaweb2`) for hosts running the Icinga Web 2 interface
* `Lynis Service Set` (host tag `lynis`) for the host that runs the subnet security audits. Tag one host, not every host carrying the package
* `OpenJDK Service Set` (host tag `openjdk`) for hosts running a Red Hat OpenJDK
* host tag `metabase`, without a Service Set: the check needs credentials, so create the service from its template via an Apply rule

Grafana:

* dashboard for nextcloud-stats ([#157](https://github.com/Linuxfabrik/monitoring-plugins/issues/157))

Assets:

* bash completion for the plugins' command line options, installed by the packages and the one-liner installer

### Changed

Monitoring Plugins:

* all plugins: output shows `<`, `>` and `&` verbatim instead of escaped
* cert: a `/24` scan finishes within the check timeout, and `--max-workers` bounds its parallelism
* cpu-usage: no longer alerts on iowait, which is unreliable on multi-core systems, but keeps reporting and graphing it
* disk-usage: runs every minute instead of every 5 minutes
* docker-info: reports every warning the daemon raises about itself, including the ones it only writes as a deprecation notice, and drops the registry address that Docker itself removed in version 24
* docker-image, podman-image: the summary line counts the images that are too old and names the oldest one, instead of listing every affected image before the table
* huawei-dorado-\*: a faulty or dead component, an overheated parked disk and a HyperMetro pair that is not mirroring are CRITICAL instead of WARNING
* huawei-dorado-\*: an empty hardware inventory reports UNKNOWN instead of "Everything is ok"
* huawei-dorado-\*: `--device-id` is optional, the appliance reports its own at login
* huawei-dorado-disk: no longer graphs the operating time
* huawei-dorado-system: `--warning` and `--critical` accept Nagios ranges
* mysql-innodb-log-waits: alerts only on real InnoDB log waits
* php-status: warns when `post_max_size` is not larger than `upload_max_filesize`, which silently breaks file uploads ([#516](https://github.com/Linuxfabrik/monitoring-plugins/issues/516))
* podman-info: the reported logging driver is the one containers log through, not the event logger
* podman-stats: CPU usage is the load since the previous check run instead of the average since the container started, so a container that is busy now shows it. The first run after the update reports no CPU value yet
* rhel-version: on Fedora, names fedora-version as the check to use instead of comparing the release against the Red Hat Enterprise Linux lifecycle
* scanrootkit: detects the VoidLink rootkit framework, and reports the RingReaper io_uring agent as a possible finding
* snmp: `--device` also accepts an absolute path ([#1308](https://github.com/Linuxfabrik/monitoring-plugins/issues/1308))
* uptimerobot: reads UptimeRobot's own status page by default; a check pointed at another status page needs `--url`

Icinga Director:

* docker-image, podman-image hide the images within their thresholds, so re-import the basket
* huawei-dorado-disk, -host and -hypermetropair hide the items within their thresholds, so re-import the basket
* the WordPress service set, its services and the WordPress host tag are spelled the way WordPress spells itself, so re-tag the affected hosts after importing the basket

### Fixed

Monitoring Plugins:

* six checks that aborted with a Python error on every run work again (borgbackup, file-ownership, getent, nextcloud-enterprise, rpm-lastactivity, scheduled-task)
* all \*-version checks: name the file, binary or endpoint they read and the parameter that moves it when they find no version, instead of only stating that the software was not found
* a table whose cell reads like an HTML tag, `&lt;unknown&gt;` for example, keeps its columns aligned
* about-me: a WordPress installation in the document root is detected when guessing Icinga Director tags, the repository of a package whose origin is unknown is readable, and the timer table no longer mixes the remaining time into the next elapse
* cert: a subnet scan needs far less memory, and one that runs out of file descriptors reports UNKNOWN instead of OK
* csv-values, json-values, strongswan-connections: non-UTF-8 input no longer crashes the check ([#256](https://github.com/Linuxfabrik/lib/issues/256))
* deb-lastactivity, strongswan-connections: a host without APT packages or without a running strongSwan gets the sentence that says so, without a Python stack trace below it
* dhcp-relayed, dmesg: a refused permission names what to do about it instead of only what failed
* disk-io: no longer produces false CRITICAL alerts from I/O wait, in particular on ZFS and Proxmox ([#1371](https://github.com/Linuxfabrik/monitoring-plugins/issues/1371))
* disk-smart: drives behind a hardware RAID controller and external USB drives are read again, `--ignore` matches, and a failing drive is no longer downgraded to WARNING ([#1388](https://github.com/Linuxfabrik/monitoring-plugins/issues/1388))
* disk-usage: performance data carries the thresholds again, `(?-i:...)` patterns match, and the table is sorted by usage ([#1310](https://github.com/Linuxfabrik/monitoring-plugins/issues/1310))
* docker-container, docker-image: report on Docker only; on a host whose `docker` command is Podman they name the podman-* checks instead of reporting Podman's containers and images as Docker's
* docker-service: says that swarm mode needs Docker on a Podman host, instead of passing Podman's usage text through
* docker-stats: a container the daemon delivers no statistics for no longer takes the whole check to UNKNOWN
* file-count: no longer reports "None" as the threshold when none was set
* file-descriptors: a kernel that does not cap the number of file handles is reported as having no limit instead of "9.2E"
* fs-inodes: an unreadable mount point such as a Kubernetes CSI volume no longer aborts the check ([#1387](https://github.com/Linuxfabrik/monitoring-plugins/issues/1387))
* haproxy-status: the `--username` / `--password` migration hint is readable again
* huawei-dorado-\*: an unexpected firmware response no longer turns the check UNKNOWN
* huawei-dorado-\*: capacities, wear levels and health scores are reported in the right unit
* huawei-dorado-\*: a large array reports its full inventory
* huawei-dorado-\*: a component without a temperature sensor no longer reports CRITICAL when a temperature threshold is set
* huawei-dorado-hypermetrodomain: a faulty HyperMetro domain is detected
* journald-query: a relative `--since` such as `-8h` from the Icinga Director works again, and a journal entry carrying newlines no longer breaks the first line of the output ([#1264](https://github.com/Linuxfabrik/monitoring-plugins/issues/1264))
* librenms-health: a temperature, humidity, voltage or power sensor past its limit alerts instead of reporting OK
* logfile: detects a logfile that an application rewrites from the beginning instead of appending to ([#1330](https://github.com/Linuxfabrik/monitoring-plugins/issues/1330))
* lynis: audits produce a report on distributions that keep lynis outside `/usr/share` ([#1262](https://github.com/Linuxfabrik/monitoring-plugins/issues/1262))
* mysql-replica-status: works on MySQL 8.4, and an account that may not list replicas no longer turns the check UNKNOWN
* mysql-user-security: the suggested `ALTER USER` runs on MariaDB 11.6 and newer, which needs a one-time `INSTALL SONAME`
* openstack-nova-list, openstack-swift-stat: a dependency warning of the `requests` module no longer takes the first line of the output
* ping: checksum-corrupted packets are counted correctly, and a corrupted reply no longer turns the check UNKNOWN
* podman-info: a host that has no unqualified search registries configured no longer ends the check with a Python error
* redfish-\*: servers with many components no longer time out ([#1372](https://github.com/Linuxfabrik/monitoring-plugins/discussions/1372))
* sensors-fans, sensors-temperatures: a chip that reports several sensors alike, or none of them with a label, no longer overwrites its own performance data
* snmp: a harmless net-snmp warning no longer aborts the check, string-indexed OIDs are read correctly, and the bundled device profiles work on current net-snmp
* statusiq: a status page that intermittently answers with an error no longer flaps into UNKNOWN
* strongswan-connections: a rekeying, shared, still-connecting or 3DES connection no longer raises a false alarm or crashes ([#806](https://github.com/Linuxfabrik/monitoring-plugins/issues/806))
* systemd-unit: the bundled Ubuntu service sets check `ssh.service` ([#1373](https://github.com/Linuxfabrik/monitoring-plugins/issues/1373))
* updates: reports that it runs on Windows only instead of aborting with a Python error

Grafana:

* ping: the round-trip time and total-time graphs are scaled in milliseconds instead of seconds

Assets:

* SELinux policy: loads on RHEL 10 as well, where it silently did nothing before

Tools:

* build-basket: switches that turn an option off, such as `--no-insecure`, end up in the Director basket
* installer: a source install on a host with too-old system Python rebuilds cleanly

### Security

Monitoring Plugins:

* all plugins: the internal `--test` argument can no longer be abused to read arbitrary root-owned files on hosts that grant the checks passwordless sudo ([GHSA-rh9c-rqvg-f7pr](https://github.com/Linuxfabrik/monitoring-plugins/security/advisories/GHSA-rh9c-rqvg-f7pr))
* keycloak-memory-usage, keycloak-stats, keycloak-version: a malicious Keycloak can no longer make the check send its admin credentials to another host ([GHSA-88fj-95f7-w68m](https://github.com/Linuxfabrik/monitoring-plugins/security/advisories/GHSA-88fj-95f7-w68m))
* logfile: closed a local privilege-escalation path, exploitable only with the non-default `fs.protected_symlinks=0`. The first run after updating re-scans the whole logfile once ([GHSA-w2gg-hx6w-24w3](https://github.com/Linuxfabrik/monitoring-plugins/security/advisories/GHSA-w2gg-hx6w-24w3))
* logfile, mysql-logfile, openvpn-client-list: the log file to read is confined to `/var/log` (mysql-logfile also allows `/var/lib/mysql`). Bind-mount a log stored elsewhere under `/var/log` ([GHSA-f54c-p5vg-mr5c](https://github.com/Linuxfabrik/monitoring-plugins/security/advisories/GHSA-f54c-p5vg-mr5c))
* redfish-\*: a malicious controller can no longer redirect a check to another host ([GHSA-96fx-pqc3-28xv](https://github.com/Linuxfabrik/monitoring-plugins/security/advisories/GHSA-96fx-pqc3-28xv))
* virustotal-scan-url: the API key can no longer end up at another host

Notification Plugins:

* notify-host-mail, notify-service-mail: a monitored service can no longer inject markup into the notification email

Tools:

* installer: a source install no longer hands the monitoring user ownership of the installed files, closing a local root code-execution path
* installer: the Python dependencies bundled with a source install no longer carry known vulnerabilities, except `h2` on RHEL 8, RHEL 9 and Debian 11, where no fixed release supports their Python 3.9


## [v6.0.0] - 2026-06-14

**Highlights:** A local privilege escalation through crafted plugin arguments is closed, which on its own makes this update worth doing. The Redfish checks are renamed to match their API endpoints and gain five new checks, so update every Icinga command referencing an old name. `cert` and `lynis` audit a whole subnet instead of a single host.

### Breaking Changes

Monitoring Plugins:

* redfish-\*: plugins renamed to match their Redfish API endpoints (`redfish-drives` → `redfish-storage`, `redfish-sel` → `redfish-logservices`, `redfish-sensor` → `redfish-sensors`, `redfish-system` → `redfish-systems`). Update any Icinga commands that reference the old names

### Added

Monitoring Plugins:

* csv-values: is shipped as a Windows build again
* lynis: check auditing the security hardening of hosts across a subnet over SSH (hardening index, warnings, suggestions)
* redfish-ethernetinterfaces: check for a server's Ethernet interface health
* redfish-firmwareinventory: check for a server's firmware component versions and health
* redfish-managers: check for a server's management controller health (BMC, e.g. iLO or iDRAC)
* redfish-memory: check for a server's memory module health
* redfish-processors: check for a server's processor health

### Changed

Monitoring Plugins:

* by-ssh: `--shell` is deprecated and ignored, and remote commands using pipes, globs or variables always work
* cert: scans a whole subnet across many common ports, checks the full certificate chain, and thresholds also accept a percentage of the lifetime or a duration
* ipmi-sensor: performance data is grouped by sensor type, which resets the existing IPMI graph history once ([#22](https://github.com/Linuxfabrik/monitoring-plugins/issues/22))
* nextcloud-security-scan: reports a fresh rating right after a Nextcloud update instead of a stale one ([#118](https://github.com/Linuxfabrik/monitoring-plugins/issues/118))
* php-status: OPcache alerting warns at 95% and flags cache thrashing, a full interned strings buffer no longer warns, and the raw hits and misses counters are gone from the performance data
* redfish-\*: frequent checks no longer flood a management controller's session table or audit log, and a slow or flaky request is retried before the check fails
* redfish-sensors: also reports chassis-wide power consumption, reads fan speed whether reported in RPM or percent, and falls back to the legacy Thermal and Power endpoints
* redfish-storage: also checks volumes (logical drives), not just physical drives and controllers
* swap-usage: a host without any swap is OK by default instead of UNKNOWN ([#1142](https://github.com/Linuxfabrik/monitoring-plugins/issues/1142))

Icinga Director:

* the Redfish baskets raise the command timeout to 60 seconds

### Fixed

Monitoring Plugins:

* several plugins that run system commands no longer report UNKNOWN when the command only writes a harmless warning to stderr, while a genuine command failure is reported as WARN (deb-lastactivity, disk-smart, getent, journald-query, journald-usage, kubectl-get-pods, ntp-chronyd, ntp-ntpd, ntp-systemd-timesyncd, redis-status, restic-snapshots, restic-stats, rpm-lastactivity, safenet-hsm-state, valkey-status)
* on Windows, multi-line output is no longer shown with a blank line between every line in IcingaWeb, and umlauts from system commands are no longer garbled ([#681](https://github.com/Linuxfabrik/monitoring-plugins/issues/681))
* about-me: no longer crashes when detecting installed software on a host
* apache-httpd-version: adapted to the new endoflife.date URL ([PR #1224](https://github.com/Linuxfabrik/monitoring-plugins/pull/1224), thanks to [Salman Mohammadi](https://github.com/salmanxmoha))
* by-ssh: a failed connection no longer echoes the full command line, which can contain the `--password` value
* redfish-sensors: no longer raises false warnings for sensors that report a placeholder min/max range ([#1211](https://github.com/Linuxfabrik/monitoring-plugins/issues/1211))

Icinga Director:

* the shipped Service and Host templates no longer pin checks to the master zone, so checks deploy correctly in distributed setups, while the agentless `-no-agent` checks still run from the master ([#721](https://github.com/Linuxfabrik/monitoring-plugins/issues/721))

Tools:

* installer: a source install cleans up a sudoers drop-in left under an earlier name, so sudo no longer warns about a duplicate `Cmnd_Alias`

### Security

Monitoring Plugins:

* all plugins: crafted plugin arguments can no longer execute arbitrary commands, most seriously on hosts where a plugin is allowed to run via sudo ([GHSA-798h-hpph-m24j](https://github.com/Linuxfabrik/monitoring-plugins/security/advisories/GHSA-798h-hpph-m24j))


## [v5.2.0] - 2026-06-02

**Highlights:** Checks that cache trend data keep their SQLite databases in a private, per-user directory instead of the shared `/tmp`, closing a local symlink attack against checks running as root. The NUT service set gains the `ups-nut` UPS check.

### Changed

Icinga Director:

* the NUT Service Set also activates the `ups-nut` UPS check, not just the NUT systemd units

Tools:

* installer: a source install no longer relies on the build host having `setuptools` preinstalled ([#1138](https://github.com/Linuxfabrik/monitoring-plugins/issues/1138))

### Security

Monitoring Plugins:

* plugins that cache trend data keep their SQLite databases, and the `csv-values` staging file, in a private per-user directory instead of the shared `/tmp`, closing a local symlink attack against a check running as root ([GHSA-r35r-fpx2-jgr4](https://github.com/Linuxfabrik/monitoring-plugins/security/advisories/GHSA-r35r-fpx2-jgr4), thanks to [OoYo0uto](https://github.com/OoYo0uto))


## [v5.1.0] - 2026-05-30

**Highlights:** A local privilege escalation through the Debian `apt-get` sudoers rule is closed. Several `mysql-*` checks stop raising false alarms and stop handing out advice that does not work, and `mysql-database-metrics` points at the largest tables before you enlarge the InnoDB buffer pool. `about-me` detects far more platforms when guessing Icinga Director tags.

### Changed

Monitoring Plugins:

* about-me: `--tags` covers Jitsi, Needs Restarting, Podman and Proxmox, and emits all `MariaDB *` and `MySQL *` variant tags
* fail2ban: the per-jail breakdown is a table, and thresholds accept Nagios ranges ([#140](https://github.com/Linuxfabrik/monitoring-plugins/issues/140))
* mysql-database-metrics: lists the largest tables by data plus index size, to spot cleanup candidates before raising the InnoDB buffer pool

### Fixed

Monitoring Plugins:

* all plugins: no longer abort on RHEL 8's default Python 3.6 when importing `lib.url`, while the officially supported minimum stays Python 3.9
* about-me: `--tags` distinguishes MariaDB from MySQL, package-based detection works on Debian, Ubuntu, SUSE, Arch, Alpine and the Red Hat family, and "User-Installed Software" lists every package instead of just the first one
* fail2ban: a banned jail no longer mislabels the following jails with its state
* mysql-\*: queries against `mysql.user` and `mysql.global_priv` no longer abort with "Illegal mix of collations" ([#1139](https://github.com/Linuxfabrik/monitoring-plugins/issues/1139))
* mysql-innodb-buffer-pool-size: no longer aborts on MySQL 9.3 and newer, where `innodb_log_file_size` was removed in favour of `innodb_redo_log_capacity`
* mysql-perf-metrics: no longer flags `innodb_log_file_size` and `innodb_log_files_in_group` as obsolete on MySQL 9.0 to 9.2, and `innodb_io_capacity` no longer raises false alarms on virtualised or network-backed storage such as Ceph and cloud volumes
* mysql-table-definition-cache: recommends a concrete value above the table count instead of the incorrect `table_definition_cache = -1`
* snmp: a malformed "Perfdata Alert Thresholds" entry in a device CSV is reported as UNKNOWN instead of being silently ignored ([#768](https://github.com/Linuxfabrik/monitoring-plugins/discussions/768))

### Security

Assets:

* Debian sudoers: the monitoring user can no longer obtain a root shell through the `apt-get` rule, which is restricted to the exact command `deb-updates` runs ([GHSA-8w6w-23mq-h8rg](https://github.com/Linuxfabrik/monitoring-plugins/security/advisories/GHSA-8w6w-23mq-h8rg), thanks to [OoYo0uto](https://github.com/OoYo0uto))


## [v5.0.0] - 2026-05-15

**Highlights:** The `mysql-*` family is reworked from end to end: cumulative counters become per-second rates and several perfdata labels are renamed, so every MySQL dashboard has to be re-imported. Six checks are new, among them a single-number MySQL health score and a UPS check for Network UPS Tools. Two checks are gone.

### Added

Monitoring Plugins:

* cert: check inspecting X.509 certificates from a TLS endpoint or local PEM/DER files, alerting on days until expiry
* mysql-health: check reporting a single 0-100 health score for a MySQL/MariaDB server
* mysql-index-health: check alerting on unused and redundant indexes. Needs Performance Schema, which is off by default on MariaDB
* mysql-long-queries: check alerting on in-flight queries running longer than a threshold, naming session, user, database and statement
* mysql-tls: check reporting the TLS posture of a server, including certificate expiry and remote users without `REQUIRE SSL`
* ups-nut: check for a UPS managed by Network UPS Tools (NUT), covering battery, load, voltages, runtime, temperature and status

### Changed

Monitoring Plugins:

* mysql-\*: cumulative counters are replaced by per-second rates and several perfdata labels are renamed, so re-import the MySQL dashboards after updating
* mysql-\*: thresholds accept Nagios ranges, which shifts a boundary from `>=N` to `>N`
* mysql-\*: the required privileges are verified up front, and a missing one exits UNKNOWN naming it
* mysql-aria, mysql-binlog-cache, mysql-innodb-log-waits, mysql-logfile: an absent or disabled engine, `log_bin = OFF` and an empty log file report OK instead of UNKNOWN
* mysql-database-metrics: excludes the `percona` schema, which was falsely flagged, and emits performance data
* mysql-innodb-buffer-pool-size: checks `innodb_redo_log_capacity` on MySQL 8.0.30 and newer, and `innodb_file_per_table`
* mysql-logfile: prefers `performance_schema.error_log` on MySQL 8.0.22 and newer, which also works remotely
* mysql-memory: counts the Galera GCache on cluster nodes, and alerts at 85% and 95%
* mysql-open-files, mysql-slow-queries, mysql-sorts, mysql-table-cache, mysql-table-locks, mysql-temp-tables, mysql-thread-cache: the hardcoded limits are replaced by `--warning`/`--critical` thresholds
* mysql-perf-metrics: the duplicate `innodb_file_per_table` check is gone, a deprecated variable only warns when it was set explicitly, and the storage-type-aware InnoDB knobs are checked
* mysql-replica-status: the required privilege is narrowed to `SLAVE MONITOR` / `REPLICA MONITOR` on MariaDB 10.5 and newer
* mysql-storage-engines: the AUTO_INCREMENT check uses each column's own type ceiling
* mysql-system: warns on `fs.nr_open < 1M`, counts only ports in LISTEN state, and renames its `kernel.*` and `mysql_opened_ports` perfdata
* mysql-table-indexes: rewritten, and InnoDB base tables without a user-defined `PRIMARY KEY` are flagged
* mysql-user-security: flags accounts on legacy authentication plugins and with common default passwords, and excludes MariaDB roles

Icinga Director:

* mysql-binlog-cache moved from the MySQL Replication Service Set to the baseline MySQL Service Set. Hosts activating only `mysql-replication` should now also activate `mysql`

Build, CI/CD:

* one hash-pinned lockfile per supported Python LTS in `lockfiles/pyXX/`. `INSTALL.md` documents how a source install on RHEL 8 can opt out of the frozen `py39` lockfile by installing AppStream `python3.12`

### Fixed

Monitoring Plugins:

* docker-stats, podman-stats: per-container CPU and memory perfdata is back ([#1104](https://github.com/Linuxfabrik/monitoring-plugins/issues/1104))
* mysql-database-metrics: the index-vs-data-size check no longer misjudges a table
* mysql-logfile: the docker, podman and kubectl sources read container logs again
* mysql-memory: `max_tmp_table_size` is accounted for correctly
* mysql-replica-status: lag detection no longer fires on every server
* mysql-slow-queries: a slow-query ratio of 5.x% alerts again instead of being truncated away
* mysql-temp-tables: no longer crashes on idle servers, and the effective temp-table cap is the smaller of `tmp_table_size` and `max_heap_table_size`
* mysql-thread-cache: the `mysql_thread_cache_size` perfdata carries the correct unit
* mysql-traffic: no longer reports "100% writes" on idle servers
* veeam-status: works again against Veeam Enterprise Manager v13 ([#1001](https://github.com/Linuxfabrik/monitoring-plugins/issues/1001))

Grafana:

* dashboards import into Grafana 12 again

### Removed

Monitoring Plugins:

* hin-status: removed, the HIN support status page no longer exists
* mysql-innodb-buffer-pool-instances: removed, the underlying variable is gone on MariaDB 10.6 and newer and obsolete on modern MySQL. Also removed from both InnoDB Service Sets


## [v4.1.0] - 2026-05-08

### Changed

Monitoring Plugins:

* sap-open-concur-com: the default `--datacenter` is `eu2`, the legacy `eu` endpoint returns HTTP 500, and a slow but healthy response no longer flips to UNKNOWN
* systemd-units-failed: in OK state, the output names the last failed unit since the last reboot, its timestamp and how long ago

Icinga Director:

* the Apache service sets match `rhel10`, `ubuntu24` and `ubuntu26`, and the Debian 10 set no longer matches the obsolete `debian8` and `debian9`
* the `OS - RHEL 10 Basic Service Set` drops the `audit-rules.service` check, a oneshot unit that stays inactive. Audit health stays covered by `auditd.service` and the `audit.log` file-size check

### Removed

Icinga Director:

* 13 single-plugin Service Sets removed, each needed per-instance parameters. The Service Templates remain, configure them via Director Apply rules instead
* the obsolete `tarifpool-v2` host tag is dropped

### Fixed

Monitoring Plugins:

* network-port-tcp: no longer crashes on every invocation
* php-fpm-status: no more false CRIT on dynamic and ondemand pools when all current workers are momentarily busy


## [v4.0.0] - 2026-05-07

### Added

Icinga Director:

* `Needs Restarting Service Set` (host tag `needs-restarting`) for Linux servers patched but not yet rebooted. Tag only hosts where reboots are manual
* `OS - RHEL 10 Basic Service Set` for Rocky Linux 10, RHEL 10 and AlmaLinux 10 hosts
* `Postfix MTA Service Set (Multi-Instance)` for hosts running the MTA as `postfix@-.service` ([#535](https://github.com/Linuxfabrik/monitoring-plugins/issues/535))

### Changed

Monitoring Plugins:

* dmesg: `--ignore` takes a regex instead of a substring, is repeatable, and replaces the bundled defaults instead of extending them. The defaults grew to cover SHPC PCI hot-plug noise
* dmesg: `--severity` is deprecated and the plugin always alerts as CRIT. Existing templates with `dmesg_severity = warn` keep working but no longer downgrade

Icinga Director:

* the hard-wired `rsyslog.service` check is gone from every OS Basic Service Set. Tag hosts running rsyslog with `rsyslog` to activate the dedicated `rsyslog Service Set`
* the older Debian OS Basic Service Sets get the missing `Disk I/O` and `Network I/O` checks

### Removed

Icinga Director:

* the `OS - Debian 8 Basic Service Set` is dropped, Debian 8 (Jessie) has been EOL since June 2020

### Fixed

Monitoring Plugins:

* librenms-alerts: alerts in the LibreNMS states `WORSE`, `BETTER` and `CHANGED` are no longer silently reported OK


## [v3.0.0] - 2026-05-05

### Breaking Changes

Monitoring Plugins:

* a batch of plugins with `append` parameters: user values replace the defaults instead of extending them ([#540](https://github.com/Linuxfabrik/monitoring-plugins/issues/540))
* haproxy-status: `--username` / `--password` are replaced by HTTP basic auth in `--url` (e.g. `https://user:pw@host/server-status`). The old parameters exit UNKNOWN with a migration hint
* mailq: thresholds take a duration (`1h`, `3D`) instead of a count, and `--mta` selects the MTA ([#781](https://github.com/Linuxfabrik/monitoring-plugins/issues/781))
* php-fpm-status: multi-pool via repeatable `--url`, HTTP basic auth in the URL, and all perfdata labels renamed and prefixed `<pool>_`. Update Grafana and InfluxDB queries
* procs: `--argument`, `--command` and `--username` are regex instead of substring and startswith. Use `^foo` for startswith and `^foo$` for an exact match
* redfish-sensor: `--insecure` defaults to `True`, because BMCs usually serve self-signed certificates. Pass `--insecure=false` explicitly if a trusted CA chain is installed

Build, CI/CD:

* the `flatdict` dependency is dropped and `statuspal` reworked accordingly, which unblocks builds on RHEL 10 and SLE 15/16 ([#1044](https://github.com/Linuxfabrik/monitoring-plugins/issues/1044))

Tools:

* `tools/check2basket` is now `tools/build-basket` and `tools/remove-uuids` is now `tools/basket-remove-uuids`. Update any wrappers or documentation

### Added

Monitoring Plugins:

* by-winrm: executes commands on remote Windows hosts via WinRM, with JEA support
* nextcloud-enterprise: reports Nextcloud Enterprise subscription information
* podman-info: displays system-wide Podman information ([#1023](https://github.com/Linuxfabrik/monitoring-plugins/issues/1023))
* podman-stats: CPU and memory statistics for all running Podman containers ([#1023](https://github.com/Linuxfabrik/monitoring-plugins/issues/1023))
* redfish-system: checks overall system health from a Redfish-compatible server, split off from `redfish-drives` ([#652](https://github.com/Linuxfabrik/monitoring-plugins/issues/652))

Build, CI/CD:

* documentation site at <https://linuxfabrik.github.io/monitoring-plugins/>
* packages for SLE 15, SLE 16 and Ubuntu 26.04, including an "OS - Ubuntu 26 Basic Service Set"

Icinga Director:

* Debian 13 Service Set

### Changed

Monitoring Plugins:

* all plugins: unknown arguments are ignored instead of erroring, which helps when rolling out updated service definitions
* atlassian-statuspage: reports the primary incident, affected services and maintenance windows, and the `impact` perfdata is renamed to `cnt_warn`/`cnt_crit`
* disk-io: also monitors normalized iowait on Linux (100% = one fully I/O-saturated core)
* file-count: much faster on large directories, it stops counting once the thresholds are exceeded
* file-ownership: the default file list is extended with CIS benchmark-relevant files (login.defs, sudoers, sysctl, systemd, PAM), so a host can newly alert
* gitlab-version: warns on security-relevant updates by default ([#688](https://github.com/Linuxfabrik/monitoring-plugins/issues/688))
* librenms-alerts, librenms-health: support device-type `management`
* nextcloud-version: `occ` no longer has to be executable, `php occ <cmd>` is invoked under the owner of `config/config.php`
* php-status: defaults to `http://localhost/monitoring.php` and tolerates its absence
* scanrootkit: 52 further signatures for modern Linux rootkits and implants, fewer false positives, and the `rootkit_items` / `rootkit_possible` perfdata count distinct rootkits instead of indicators
* statuspal: also detects the `emergency-maintenance` state

Assets:

* sudoers: PAM's session stack log lines are disabled when the user icinga or nagios uses sudo

Build, CI/CD:

* the Windows MSI no longer depends on an installed Icinga 2 agent, the install path is unchanged

Icinga Director:

* Service Templates: "Notes URL" points at the docs site instead of the GitHub source. Re-run `tools/build-basket --auto` to pick up the new URL

Tools:

* build-basket: `--auto` is truly non-interactive, unknown datafields and objects get fresh uuids instead of prompting

### Removed

Monitoring Plugins:

* cpu-usage: `--top` is removed and lives on as `procs --top`
* scanrootkit: the Suckit rootkit check and the `rootkit_extra` perfdata are removed. Update Grafana panels and alerts that rely on `rootkit_extra`

Tools:

* the legacy `grafana-tool` is removed

### Fixed

Monitoring Plugins:

* semantic bugfixes across a batch of plugins (keycloak-version, mysql-table-locks, valkey-status, wildfly-\*, ...) ([#1070](https://github.com/Linuxfabrik/monitoring-plugins/issues/1070))
* ntp-\*: no longer raise a `TypeError` when comparing int and str
* about-me: no longer errors on `sys_dimensions`, or on `--dmidecode` when no hardware information is available ([#1006](https://github.com/Linuxfabrik/monitoring-plugins/issues/1006))
* cpu-usage: no more false 100% readings on Windows with 64 or more cores ([#626](https://github.com/Linuxfabrik/monitoring-plugins/issues/626))
* deb-updates: no longer crashes when reporting the number of available updates
* docker-stats: memory perfdata no longer uses the CPU thresholds, and the aggregate metrics include block and network I/O totals
* file-age: handles the race when files disappear on busy file systems
* fs-ro: ignores `/run/credentials`
* keycloak-stats: the check runs again, its library symlink was wrong
* librenms-alerts: reports `WORSE`, `BETTER` and `CHANGED` alerts too, which LibreNMS 25.2 and newer produce for many alerts ([#882](https://github.com/Linuxfabrik/monitoring-plugins/issues/882))
* logfile: several services on the same logfile with different patterns no longer interfere with each other, the read offset no longer resets on every run, and the check no longer aborts on Windows ([#698](https://github.com/Linuxfabrik/monitoring-plugins/issues/698), [#1035](https://github.com/Linuxfabrik/monitoring-plugins/issues/1035))
* mysql-joins, mysql-traffic: no longer crash on a server booted less than one second ago
* mysql-memory: no longer crashes in "other process memory" on hosts with psutil older than 5.3.0
* needs-restarting: shows "Running Kernel X != Installed Kernel Y" on Debian-based systems when `needrestart` reports a pending kernel upgrade
* notify-host-mail, notify-service-mail: the Icinga logo renders inline again on hosts with long FQDNs ([#790](https://github.com/Linuxfabrik/monitoring-plugins/issues/790))
* redfish-drives: system-level warnings such as inlet temperature no longer flip the check to WARN, they are covered by `redfish-system` ([#652](https://github.com/Linuxfabrik/monitoring-plugins/issues/652))
* rocketchat-stats: no longer crashes when reporting the user count
* scanrootkit: a single malformed signature file no longer crashes the whole check, and directory-only rootkit signatures are evaluated at all
* service: Windows services with a space in their technical name match `--service` ([#921](https://github.com/Linuxfabrik/monitoring-plugins/issues/921))
* updates: no longer crashes on Python 3.9 when pending updates are reported
* users: correct TTY count when SSH clients connect via IPv6 ([#989](https://github.com/Linuxfabrik/monitoring-plugins/issues/989))
* valkey-status: TLS connections work ([PR #954](https://github.com/Linuxfabrik/monitoring-plugins/pull/954), thanks to [Claudio Kuenzler](https://github.com/Napsty))

Build, CI/CD:

* RPM: no longer conflicts with other RPMs shipping ELF build-id symlinks, such as `azure-cli` ([#979](https://github.com/Linuxfabrik/monitoring-plugins/issues/979))

Grafana:

* Icinga Dashboard: uses a query for the service name, so the dashboard works regardless of the configured service name

Tools:

* build-basket: Icinga Director basket descriptions no longer carry argparse `%%` escaping, and `append` parameters with `default=None` get `[]` as default value


## [v2.2.1] - 2025-09-22

### Fixed

Monitoring Plugins:

* ntp-chronyd, ntp-ntpd: no longer abort with a SyntaxError on Python 3.11 ([#952](https://github.com/Linuxfabrik/monitoring-plugins/issues/952))


## [v2.2.0] - 2025-09-19

### Added

Monitoring Plugins:

* spring-boot-actuator-health: check for the Spring Boot Actuator `/health` endpoint (derived from [PR #940](https://github.com/Linuxfabrik/monitoring-plugins/pull/940), thanks to [Dominik Riva](https://github.com/slalomsk8er))
* virustotal-scan-url: check analysing URLs for malware and other breaches using VirusTotal

Build, CI/CD:

* packages for Debian 13 and RHEL 10

### Changed

Monitoring Plugins:

* about-me: reports the current CPU frequency, and avoids dmidecode noise
* cpu-usage: measures without blocking, which makes the check both more accurate and faster
* gitlab-health, gitlab-liveness, gitlab-readiness, infomaniak-events: longer default timeouts, so a slow but healthy endpoint no longer flips to UNKNOWN
* journald-usage: also prints SystemMaxUse and SystemKeepFree
* procs: much cheaper on busy Windows servers, where reading every process ate into the check interval
* statuspal: a "performance" degradation is WARN instead of UNKNOWN

Icinga Director:

* longer command timeouts for about-me, atlassian-statuspage and the Windows variants of disk-io, memory-usage, ntp-w32tm and procs

### Fixed

Monitoring Plugins:

* deb-updates: reports the real reason when apt-get fails, and no longer reports OK when it lacks the rights to check ([#904](https://github.com/Linuxfabrik/monitoring-plugins/issues/904), [#937](https://github.com/Linuxfabrik/monitoring-plugins/issues/937))
* icinga-topflap-services: no longer produces a stacktrace when required parameters are empty
* openstack-swift-stat: works with the current python-keystoneclient ([#900](https://github.com/Linuxfabrik/monitoring-plugins/issues/900))
* safenet-hsm-state: performance data is enabled in the Icinga Director basket
* statuspal: handles the incident type "performance"
* users: no longer reports "no one is logged in" on Ubuntu 24.04 LTS ([#919](https://github.com/Linuxfabrik/monitoring-plugins/issues/919))
* valkey-status, redis-status: `--ignore-thp` works as documented ([#898](https://github.com/Linuxfabrik/monitoring-plugins/issues/898))

Assets:

* SELinux policy: the checks no longer trip over D-Bus IPC with unconfined services ([#918](https://github.com/Linuxfabrik/monitoring-plugins/issues/918))


## [v2.1.1] - 2025-06-20

### Fixed

Icinga Director:

* the Icinga 2 Service Set


## [v2.1.0] - 2025-06-20

### Added

Monitoring Plugins:

* icinga-version: check tracking whether Icinga is end of life

Icinga Director:

* Icinga 2 Service Set

### Changed

Monitoring Plugins:

* matomo-version: uses the EOL library, `--cache-expire` is deprecated

Icinga Director:

* the notification plugins are called from `/usr/lib64/nagios/plugins` again
* longer timeouts for atlassian-statuspage and uptimerobot

### Fixed

Monitoring Plugins:

* disk-usage: handles a disk that cannot be accessed ([#792](https://github.com/Linuxfabrik/monitoring-plugins/issues/792))
* updates: no longer fails with "The syntax of the command is incorrect."

Icinga Director:

* corrected the nextcloud-app-update.timer unit states


## [v2.0.0] - 2025-06-06

### Breaking Changes

Build, CI/CD:

* Linux: the plugins are no longer compiled to binaries. The .rpm and .deb packages ship the source code and require Python 3.9 or newer on the target host, plus a venv in `/usr/lib64/linuxfabrik-monitoring-plugins/venv/` for the Python libraries
* Windows: only the plugins that check local system resources are compiled, to save disk space. Plugins checking remote services are meant to run on Linux (cpu-usage, dhcp-scope-usage, disk-io, disk-usage, dns, dummy, file-age, file-count, file-size, logfile, memory-usage, network-connections, network-io, network-port-tcp, ntp-w32tm, path-rw-test, procs, scheduled-task, service, swap-usage, updates, uptime, users)

Icinga Director:

* the plugins no longer compiled for Windows are removed from the Windows configuration, and the legacy commands are dropped. Affected are around 140 checks, among them all fortios-\*, huawei-dorado-\*, mysql-\*, nodebb-\*, php-\*, qts-\*, redfish-\*, starface-\*, wildfly-\* and the single checks apache-solr-version, axenita-stats, composer-version, countdown, csv-values, dhcp-relayed, diacos, disk-smart, feed, githubstatus, grassfish-\*, haproxy-status, hin-status, icinga-topflap-services, infomaniak-\*, jitsi-\*, json-values, kemp-services, keycloak-\*, librenms-\*, matomo-\*, mediawiki-version, metabase-stats, mod-qos-stats, moodle-version, nextcloud-\*, nginx-status, onlyoffice-stats, openjdk-redhat-version, openvpn-version, pip-updates, python-version, restic-\*, rocketchat-\*, sap-open-concur-com, statusiq, statuspal, uptimerobot, veeam-status, whmcs-status, wordpress-version and xml

### Added

Monitoring Plugins:

* atlassian-statuspage: check alerting on incidents on a specific Atlassian Statuspage
* deb-updates: check for software updates on systems using `apt-get`
* kubectl-get-pods: check for the health and status of Kubernetes pods
* rpm-updates: check listing available updates, including the advisories for newer versions of installed packages
* valkey-status: check reporting information and statistics about a Valkey server
* valkey-version: check tracking whether Valkey is end of life

### Changed

Monitoring Plugins:

* about-me: detects Valkey and reports the type of display server, if any
* csv-values: copes with an omitted `--warning-query` and `--critical-query`
* fail2ban: is a bit more verbose when everything is OK
* haproxy-status: supports a UNIX socket as an alternative to HTTP(S) ([#767](https://github.com/Linuxfabrik/monitoring-plugins/issues/767))
* icinga-topflap-services: the default warning level rises from 5 to 7
* php-status: bz2 and curl are no longer expected as default modules
* redfish-sel: supports Supermicro ([#866](https://github.com/Linuxfabrik/monitoring-plugins/issues/866))
* snmp: the table output can be suppressed, and a "skip output" column is available in the device CSV
* systemd-unit: supports `systemctl --machine` and `--user`

Assets:

* sudoers: the command alias is prefixed to avoid conflicts ([#880](https://github.com/Linuxfabrik/monitoring-plugins/issues/880))

### Fixed

Monitoring Plugins:

* by-ssh: no longer produces a traceback on "permission denied"
* icinga-topflap-services: ignores "Waiting for Icinga DB to synchronize the config." instead of going UNKNOWN
* needs-restarting: a missing import no longer breaks the check
* ping: "10 received" is no longer read as "0 received" ([#860](https://github.com/Linuxfabrik/monitoring-plugins/issues/860))
* snmp: special characters in `--v3-auth-prot-password` and `--v3-priv-prot-password` are supported ([#886](https://github.com/Linuxfabrik/monitoring-plugins/issues/886))


## [v1.2.0.11] - 2025-03-13

### Breaking Changes

Monitoring Plugins:

* the source-code variant requires Python 3.9 or newer, because libraries such as pymysql and openssl have known vulnerabilities on Python 3.6
* jitsi-videobridge-stats: deprecated values and the `--warning` / `--critical` parameters are gone, the check always returns OK ([PR #780](https://github.com/Linuxfabrik/monitoring-plugins/pull/780), thanks to [SnejPro](https://github.com/SnejPro))

Notification Plugins:

* notify-\*-rocketchat-telegram: the Telegram functionality and the `-telegram` suffix are gone

Icinga Director:

* the Tarifpool-v2 Service Set is removed

Build, CI/CD:

* the project switches from calendar versioning to semantic versioning, starting at `v1.0.0.0`

### Added

Monitoring Plugins:

* new checks: graylog-version, hin-status, icinga-topflap-services, keycloak-memory-usage, keycloak-stats, mastodon-version, moodle-version, openvpn-version, scanrootkit, statusiq, uptimerobot, whmcs-status

Icinga Director:

* new Service Sets: Debian 12 (Cloud Image), IcingaDB, Mastodon, Moodle, networking, rsyslog, Ubuntu 24, WHMCS

Build, CI/CD:

* packages for ARM ([#702](https://github.com/Linuxfabrik/monitoring-plugins/issues/702))

### Changed

Monitoring Plugins:

* about-me: determines the date of birth of cloud VMs more accurately, and detects Mastodon, Moodle and WHMCS
* dhcp-scope-usage: ignores PercentageInUse fractions
* disk-io: supports Windows again after the rewrite
* disk-usage: `--fstype` and `--list-fstypes` select the file system type
* fs-inodes: checks inode usage per real disk, `--mount` is deprecated
* infomaniak-events: returns CRIT on critical events
* keycloak-version: reads the version over the REST API ([#748](https://github.com/Linuxfabrik/monitoring-plugins/issues/748))
* librenms-alerts, librenms-health: compact output is the default and shows non-OK entries only
* mysql-thread-cache: measures the cache hit rate only after the database has been running for an hour
* nextcloud-security-scan: handles an error from scan.nextcloud.com
* nodebb-stats: "Last user" no longer reports the account the check logs in with ([#536](https://github.com/Linuxfabrik/monitoring-plugins/issues/536))
* openstack-nova-list: no longer needs keystoneauth and keystoneclient
* rhel-version: `--extended-support` checks against the Extended Life Cycle Support dates ([#740](https://github.com/Linuxfabrik/monitoring-plugins/issues/740))
* rocketchat-version: uses the EOL library, `--cache-expire` is deprecated
* uptime: reports downtime ([#191](https://github.com/Linuxfabrik/monitoring-plugins/issues/191))

Icinga Director:

* the Windows plugins move to `c:\Program Files\icinga2\sbin\linuxfabrik`, all dmesg Service Sets use sudo, and the Debian Service Sets watch the size of `/var/log/syslog`

Build, CI/CD:

* Windows ships as an MSI package, and the Linux builds switch from pyinstaller to Nuitka

### Fixed

Monitoring Plugins:

* about-me: expanded RAM is picked up ([#757](https://github.com/Linuxfabrik/monitoring-plugins/issues/757))
* apache-httpd-status: no longer fails when mod_md is enabled ([#783](https://github.com/Linuxfabrik/monitoring-plugins/issues/783))
* dhcp-relayed: binds its socket to all network interfaces
* disk-io: no longer aborts with an UnboundLocalError ([#777](https://github.com/Linuxfabrik/monitoring-plugins/issues/777))
* docker-stats: `--always-ok` works, and a container reporting `0B` no longer crashes the check ([#776](https://github.com/Linuxfabrik/monitoring-plugins/issues/776), [#839](https://github.com/Linuxfabrik/monitoring-plugins/issues/839))
* fortios-network-io: reads its local SQLite database again
* needs-restarting: no longer aborts under the nagios user ([#799](https://github.com/Linuxfabrik/monitoring-plugins/issues/799))
* redfish-sel: no longer aborts with an UnboundLocalError ([#779](https://github.com/Linuxfabrik/monitoring-plugins/issues/779))
* service: `--starttype` is implemented at all, and repeatable
* snmp: some device CSV files no longer end in an `IndexError`
* strongswan-connections: works with the AES-GCM algorithm ([#806](https://github.com/Linuxfabrik/monitoring-plugins/issues/806))
* swap-usage: no longer aborts with a ProcessLookupError

### Removed

Build, CI/CD:

* packages for debian10, rhel7 and ubuntu1804, whose distributions are end of life


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


## 2022022801 - 2022-02-28

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


## 2021101401 - 2021-10-14

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


## 2021061501 - 2021-06-15

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


## 2021021701 - 2021-02-17

### Fixed

Monitoring Plugins:

* the virtualenv is activated even when a plugin is called by an absolute path ([#154](https://github.com/Linuxfabrik/monitoring-plugins/issues/154))


## 2021021601 - 2021-02-16

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


## 2020122401 - 2020-12-24

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


## 2020112001 - 2020-11-20

### Changed

Monitoring Plugins:

* systemd-unit: knows more states


## 2020111901 - 2020-11-19

### Fixed

Monitoring Plugins:

* ntp-offset: no longer errors on a server without NTP ([#138](https://github.com/Linuxfabrik/monitoring-plugins/issues/138))


## 2020111801 - 2020-11-18

### Added

Assets:

* sudoers for Debian 9 and 10

### Fixed

Monitoring Plugins:

* disk-usage, dns: no longer abort with a traceback ([#132](https://github.com/Linuxfabrik/monitoring-plugins/issues/132), [#133](https://github.com/Linuxfabrik/monitoring-plugins/issues/133))
* ntp-offset: corrected logic ([#134](https://github.com/Linuxfabrik/monitoring-plugins/issues/134))


## 2020102301 - 2020-10-23

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


## 2020061901 - 2020-06-19

### Added

Monitoring Plugins:

* network-bonding

### Fixed

Monitoring Plugins:

* nextcloud-version: no longer aborts with an AttributeError ([#105](https://github.com/Linuxfabrik/monitoring-plugins/issues/105))


## 2020052801 - 2020-05-28

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


## 2020042001 - 2020-04-20

### Added

Monitoring Plugins:

* new checks: dns, fah-stats
* most of the checks also run on Ubuntu

### Fixed

Monitoring Plugins:

* about-me: reports the details of NVMe disks ([#89](https://github.com/Linuxfabrik/monitoring-plugins/issues/89))
* nextcloud-security-scan: no longer aborts on a missing urllib ([#91](https://github.com/Linuxfabrik/monitoring-plugins/issues/91))
* ping: no duplicate output ([#84](https://github.com/Linuxfabrik/monitoring-plugins/issues/84))


## 2020041501 - 2020-04-15

### Added

Monitoring Plugins:

* new checks: getent, nextcloud-version, ping, rocket.chat-version

### Removed

Monitoring Plugins:

* docker-info, docker-container, network-io, redis and xca-cert, to be rewritten from scratch


## 2020031201 - 2020-03-12

### Added

Monitoring Plugins:

* feed

### Changed

Monitoring Plugins:

* cpu-usage: adjusted to changes in psutil
* dmesg: a longer ignore list
* systemd-unit: improved output


## 2020022801 - 2020-02-28

Initial release for the general public.


[Unreleased]: https://github.com/Linuxfabrik/monitoring-plugins/compare/v7.0.0...HEAD
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
