# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).


## [Unreleased]

### Added ("feat")

Build, CI/CD:

* Add support for sle15 packages


Monitoring Plugins:

* by-ssh: add alerting on single numeric values
* by-winrm: executes commands on remote Windows hosts by WinRM, supporting JEA (including the JEA endpoint via `--winrm-configuration-name`)
* nextcloud-enterprise: provides information about an installed Nextcloud Enterprise subscription
* statuspal: also detect 'emergency-maintenance' state
* valkey-status: support user and password credentials, fix tls connection [PR #954](https://github.com/Linuxfabrik/monitoring-plugins/pull/954), thanks to [Claudio Kuenzler](https://github.com/Napsty)


### Fixed ("fix")

Grafana:

* Icinga Dashboard: Use a query instead of a constant service name to allow the dashboard to be used even if the service name differs

Monitoring Plugins:

* about-me: error in perfdata if using `--dmidecode` and there is no HW information
* about-me: fix various errors with `sys_dimensions` on some machines
* by-ssh: add missing `--verbose` parameter
* fs-ro: ignore `/run/credentials` (https://systemd.io/CREDENTIALS/)
* ntp-*: prevent `TypeError: ''=' not supported between instances of 'int' and 'str'`


### Changed ("refactor", "chore" etc.)

Assets:

* sudoers: disable PAM's session stack log lines when user icinga or nagios uses sudo


Build, CI/CD:

* Windows MSI still installs all plugins to ProgramFiles64Folder/ICINGA2/sbin/linuxfabrik, but does not depend on an Icinga2 agent any longer


Grafana:

* All panels: do not connect across nulls


Monitoring Plugins:

* all plugins: ignore unknown arguments instead of generating an error (this helps with updating Icinga and Nagios service definitions considerably)
* nextcloud-version: modernize code
* php-status: always assume http://localhost/monitoring.php and, if not found, be tolerant
* redis-status, valkey-status: modernize code and unify both plugins again after [PR #954](https://github.com/Linuxfabrik/monitoring-plugins/pull/954)
* rocketchat-stats: improve output
* updates: adapt to updated powershell.py library


### Removed ("chore" etc.)

Tools:

* remove legacy `grafana-tool`



## [v2.2.1] - 2025-09-22

### Fixed ("fix")

Monitoring Plugins:

* ntp-chronyd, ntp-ntpd: SyntaxError: f-string: unmatched '(' on python 3.11 ([#952](https://github.com/Linuxfabrik/monitoring-plugins/issues/952))



## [v2.2.0] - 2025-09-19

### Added ("feat")

Build, CI/CD:

* Add support for debian13 and rhel10 packages


Monitoring Plugins:

* about-me: add option to avoid dmidecode and sudo ([#948](https://github.com/Linuxfabrik/monitoring-plugins/issues/948))
* ntp-\*: add `--stratum` parameter and modernize code
* spring-boot-actuator-health: derived from [PR #940](https://github.com/Linuxfabrik/monitoring-plugins/pull/940), thanks to [Dominik Riva](https://github.com/slalomsk8er) - a monitoring plugin for the Spring Boot Actuator `/health` endpoint
* virustotal-scan-url: analyses URLs to detect malware and other breaches using VirusTotal


### Fixed ("fix")

Assets:

* Linuxfabrik Monitoring Plugins [SELinux Type Enforcement Policies](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/assets/selinux/linuxfabrik-monitoring-plugins.te): allow D-Bus daemon IPC with unconfined services via FIFOs and UNIX sockets
* Linuxfabrik Monitoring Plugins [SELinux Type Enforcement Policies](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/assets/selinux/linuxfabrik-monitoring-plugins.te): add missing type enforcement requirements ([#918](https://github.com/Linuxfabrik/monitoring-plugins/issues/918))


Build, CI/CD:

* Build on Ubuntu 24.02 error on system_dbusd_t ([#918](https://github.com/Linuxfabrik/monitoring-plugins/issues/918))


Monitoring Plugins:

* deb-updates: apt-get returns with an error ([#904](https://github.com/Linuxfabrik/monitoring-plugins/issues/904))
* deb-updates: missing rights and still OK ([#937](https://github.com/Linuxfabrik/monitoring-plugins/issues/937))
* icinga-topflap-services: prevent stacktrace when required parameters are empty
* openstack-swift-stat: problem with python-keystoneclient, optimize requirements* ([#900](https://github.com/Linuxfabrik/monitoring-plugins/issues/900))
* safenet-hsm-state: set `use_agent` to false and enable perfdata in Icinga Director Basket
* statuspal: handle incident_type "performance"
* users: "no one is logged in" on Ubuntu 24.04 LTS ([#919](https://github.com/Linuxfabrik/monitoring-plugins/issues/919))
* valkey-status|redis-status: improve `--ignore-thp` ([#898](https://github.com/Linuxfabrik/monitoring-plugins/issues/898))


### Changed ("refactor", "chore" etc.)

Assets:

* To make it easier to integrate with other tools, all RST files have been converted to GitHub-flavoured Markdown.


Build, CI/CD:

* Change to official, up-to-date Rocky Linux containers for building RPMs ([Motivation](https://hub.docker.com/_/rockylinux#important-note))


Icinga Director:

* about-me: change command timeout from 30 to 60
* atlassian-statuspage: increase Icinga Director command timeout
* disk-io: change command timeout from 10 to 30 for Windows
* memory-usage: change command timeout from 10 to 30 for Windows
* ntp-w32tm: change command timeout from 10 to 30 and check interval from 60 to 600
* procs: change command timeout from 10 to 30 for Windows


Monitoring Plugins:

* about-me: report current cpu frequency and avoid dmidecode noise, new perfdata
* cpu-usage: non-blocking behaviour (interval=None + manual deltas via SQLite DB) so we get both accuracy and faster runtime
* disk-io: modernize code
* gitlab-health: increase timeout from 3 to 8 secs
* gitlab-liveness: increase timeout from 3 to 8 secs
* gitlab-readiness: increase timeout from 3 to 8 secs
* infomaniak-events: increase timeout from 8 to 28 secs
* journald-usage: also print SystemMaxUse and SystemKeepFree
* memory-usage: modernize code
* pip-updates: modernize code
* procs: avoid token + PEB reads and repeated attribute calls per process, as this has an impact on busy Windows servers
* rocketchat-stats: improve output and docs a little bit
* statuspal: 'performance' degredation is now a WARN, not UNKNOWN



## [v2.1.1] - 2025-06-20

### Fixed ("fix")

Icinga Director:

* Icinga2 Service Set



## [v2.1.0] - 2025-06-20

### Added ("feat")

Icinga Director:

* Icinga2 Service Set


Monitoring Plugins:

* icinga-version: tracks if Icinga is EOL


### Fixed ("fix")

Icinga Director:

* all-the-rest.json: correct nextcloud-app-update.timer unit states


Monitoring Plugins:

* disk-usage: handle disk accessibility ([#792](https://github.com/Linuxfabrik/monitoring-plugins/issues/792))
* updates: "The syntax of the command is incorrect."


### Changed ("refactor", "chore" etc.)

Icinga Director:

* atlassian-statuspage: Increase timeout from 8 to 30 secs
* uptimerobot: Increase timeout from 8 to 30 secs
* Path to notification plugins changed back to `/usr/lib64/nagios/plugins` 


Monitoring Plugins:

* matomo-version: use EOL library, parameter `--cache-expire` is deprecated



## [v2.0.0] - 2025-06-06

### Breaking Changes ("!")

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


### Added ("feat")

Monitoring Plugins:

* atlassian-statuspage: receive alerts on incidents on a specific Atlassian Statuspage
* deb-updates: checks for software updates on systems that use package management systems based on the `apt-get` command
* kubectl-get-pods: checks the health and status of kubernetes pods by running `kubectl get pods` and parsing the results
* rpm-updates: displays available updates, including a list of advisories about newer versions of installed packages
* valkey-status: returns information and statistics about a Valkey server
* valkey-version: tracks if Valkey is EOL


### Fixed ("fix")

Build, CI/CD:

* compile-one.sh: provide Nuitka's no-deployment-flag ([#864](https://github.com/Linuxfabrik/monitoring-plugins/issues/864))


Monitoring Plugins:

* by-ssh: fix traceback on "permission denied"
* icinga-topflap-services: ignore events with "Waiting for Icinga DB to synchronize the config." to prevent UNKNOWNs
* needs-restarting: add missung import of lib.disk
* ping: '10 received' contains '0 received' ([#860](https://github.com/Linuxfabrik/monitoring-plugins/issues/860))
* snmp: Special characters not supported in options --v3-auth-prot-password and --v3-priv-prot-password ([#886](https://github.com/Linuxfabrik/monitoring-plugins/issues/886))


### Changed ("refactor", "chore" etc.)

Build, CI/CD:

* create-fpms.sh: fix OS detection for setting OS family
* change linux packaging workflow to use native tools (rpmbuild, debuild)


Assets:

* prefix sudoers command alias to avoid conflicts ([#880](https://github.com/Linuxfabrik/monitoring-plugins/issues/880))


Monitoring Plugins:

* about-me: add valkey detection
* about-me: reports type of display server (if any)
* about-me: switch from lib.version to lib.distro
* csv-values: make use of ommitted --warning-query and --critical-query more robust
* disk-io: improve help text
* fail2ban: be a bit more verbose in case everything is ok
* fedora-version: switch from lib.version to lib.distro
* fs-inodes: improve code
* grassfish-screens: initialize screen statuses earlier
* haproxy-status: add unix socket support as alternative to HTTP(S) ([#767](https://github.com/Linuxfabrik/monitoring-plugins/issues/767))
* icinga-topflap-services: increase default warning level from 5 to 7
* load: Use `os.getloadavg()` instead of `cat /proc/loadavg` ([#295](https://github.com/Linuxfabrik/monitoring-plugins/issues/295))
* php-status: bz2 and curl are no default modules
* redfish-sel: add support for Supermicro ([#866](https://github.com/Linuxfabrik/monitoring-plugins/issues/866))
* rhel-version: switch from lib.version to lib.distro
* snmp: add column "skip output" to CSV definition for devices, add unit tests
* snmp: make table output suppressable, streamline output
* systemd-unit: implement support for `systemctl --machine` and `--user`



## [v1.2.0.11] - 2025-03-13

### Breaking Changes ("!")

Build, CI/CD:

* Due to the new [conventional commits](https://www.conventionalcommits.org/en/v1.0.0/) and version string requirements in Windows MSI setup files, the project switches from [calendar versioning](https://calver.org/) to [semantic versioning](https://semver.org/). Project starts at `v1.0.0.0`.
* Re-implemented `/build` and `/.github` from scratch.


Assets:

* Move `/selinux` to `/assets/selinux`


Icinga Director:

* all-the-rest.json: Remove Tarifpool-v2 Service Set


Monitoring Plugins:

* Since some libraries such as pymysql or openssl have security vulnerabilities for Python 3.6, the project now requires Python 3.9+ to use the plugins in the source code variant.
* jitsi-videobridge-stats: Remove deprecated values ([PR #780](https://github.com/Linuxfabrik/monitoring-plugins/pull/780), thanks to [SnejPro](https://github.com/SnejPro))
* jitsi-videobridge-stats: Remove deprecated warning and critical parameters, always returns OK


Notification Plugins:

* notify-\*-rocketchat-telegram: Remove Telegram functionality, remove ``-telegram`` suffix


### Added ("feat")

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


### Fixed ("fix")

Icinga Director:

* crypto-policy: New defaults according to LFOps crypto_policy role
* dhcp-relayed: Binding a socket to all network interfaces
* disk-io: UnboundLocalError: cannot access local variable 'msg' where it is not associated with a value ([#777](https://github.com/Linuxfabrik/monitoring-plugins/issues/777))
* docker-stats: always-ok not referenced ([#839](https://github.com/Linuxfabrik/monitoring-plugins/issues/839))
* fortios-network-io: Fix reading from local SQLite database
* mysql-query: Fix director basket
* needs-restarting: UnboundLocalError under nagios user ([#799](https://github.com/Linuxfabrik/monitoring-plugins/issues/799))
* service: Implement `--starttype`, as code was missing (parameter is now appending); implement unit-tests
* snmp: With some CSV files, user gets traceback `IndexError: list index out of range`. Add more unit-tests.
* strongswan-connections: check fails if using AES-GCM algorithm ([#806](https://github.com/Linuxfabrik/monitoring-plugins/issues/806))
* swap-usage: Fix ProcessLookupError


Monitoring Plugins:

* about-me: expanded RAM isn't updating ([#757](https://github.com/Linuxfabrik/monitoring-plugins/issues/757))
* apache-httpd-status: failure when mod_md is enabled ([#783](https://github.com/Linuxfabrik/monitoring-plugins/issues/783))
* docker-stats: ValueError: could not convert string to float: '0B' ([#776](https://github.com/Linuxfabrik/monitoring-plugins/issues/776))
* redfish-sel: UnboundLocalError: local variable 'sel_path' referenced before assignment ([#779](https://github.com/Linuxfabrik/monitoring-plugins/issues/779))
* whmcs-status: handle null correctly in whmcs api response ([#820](https://github.com/Linuxfabrik/monitoring-plugins/pull/820))


### Changed ("refactor", "chore" etc.)

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

* about-me: Determines date of birth of cloud VMs more accurately
* about-me: Add Mastodon detection
* about-me: Add Moodle detection
* about-me: Add WHMCS detection
* dhcp-scope-usage: Ignore PercentageInUse fractions
* disk-io: Re-add support for Windows after last rewrite
* disk-usage: Add `--list-fstypes` and `--fstype` for specifying the file system type
* fail2ban: More compact output (closes #141)
* file-size: fix help text
* fs-inodes: Check inode usage on real and different disks. `--mount` parameter is deprecated.
* infomaniak-events: return CRIT in case of critical events
* keycloak-version: Check Keycloak Version via REST API ([#748](https://github.com/Linuxfabrik/monitoring-plugins/issues/748))
* librenms-alerts, librenms-health: Compact output is the new default and shows non-OK only
* mysql-thread-cache: DB daemon must have been running for an hour before the cache hit rate is measured.
* mysql-version: handle `mysql: Deprecated program name`
* nextcloud-security-scan: Handle error on https://scan.nextcloud.com/
* nodebb-stats: In "Last user", don't report the user you login with ([#536](https://github.com/Linuxfabrik/monitoring-plugins/issues/536))
* openstack-nova-list: No more need for keystoneauth and keystoneclient
* redis-status: Add `--tls` parameter
* rhel-version: `--extended-support` checks for "Extended Life Cycle Support" EOL ([#740](https://github.com/Linuxfabrik/monitoring-plugins/issues/740))
* rocketchat-version: use EOL library, parameter `--cache-expire` is deprecated
* systemd-unit: Improve output
* uptime: Report downtime ([#191](https://github.com/Linuxfabrik/monitoring-plugins/issues/191))


### Removed

Build, CI/CD:

* Remove support for debian10, rhel7, ubuntu1804 packages (OS's are EOL)


Notification Plugins:

* notify-\*-rocketchat: remove telegram functionality



## [2024060401] - 2024-06-04

### Added

Monitoring Plugins:

* mysql-query

CI/CD:

* Added Ubuntu 24.04


## [2024052901] - 2024-05-29

### Breaking Changes

Icinga Director:

* all-the-rest.json: Remove all predefined "Journald Query" definitions, as they were not as useful in practice as we thought. Single services are more useful.
* Lowered the criticality of many service templates and service set services to make the monitoring less noisy by default. Make sure to double check and increase the criticality for important services.

Monitoring Plugins:

* disk-io: Nearly rewritten from scratch, old parameters have been replaced by new, better ones. Perfdata "throughput" has been renamed to "bandwidth". Filter disks which are really mounted, translate dm-* device names, wildcard support for ignore disks ([#709](https://github.com/Linuxfabrik/monitoring-plugins/issues/709), [#708](https://github.com/Linuxfabrik/monitoring-plugins/issues/708), [#676](https://github.com/Linuxfabrik/monitoring-plugins/issues/676))
* file-size: Note that the plugin now requires a size qualifier when specifying parameters, e.g. ``--warning=10K`` for 10 KiB (instead of ``--warning=10000`` as in previous versions).
* journald-query: Pattern-matching is now always case-sensitive ([#745](https://github.com/Linuxfabrik/monitoring-plugins/issues/745))
* librenms-alerts: Rewritten from scratch to fetch from LibreNMS MySQL/MariaDB database (therefore the check comes with new parameters)
* librenms-health: Rewritten from scratch to fetch from LibreNMS MySQL/MariaDB database (therefore the check comes with new parameters)
* php-fpm: Remove parameters `--*-max-children` because php-fpm `max children reached` is either 0 or 1
* snmp: Improve Performance Data Handling ([#481](https://github.com/Linuxfabrik/monitoring-plugins/issues/481)) - update your CSV definition files and add two more columns according to the check's README
* uptime: Use the plugin to warn about recent reboots ([#722](https://github.com/Linuxfabrik/monitoring-plugins/issues/722)). Note that the plugin now requires a time qualifier when specifying parameters, e.g. ``--warning=180D`` for 180 days (instead of ``--warning=180`` as in previous versions).

Notification Plugins:

* All notification plugins are now installed in `/usr/lib64/nagios/plugins/notifications/` by default, because otherwise installing the notification and monitoring plugins package at the same time fails ([#726](https://github.com/Linuxfabrik/monitoring-plugins/issues/726))


### Added

Icinga Director:

* all-the-rest.json: New TuneD Service Set (therefore removed from all "OS - RHEL" service sets)

Monitoring Plugins:

* dhcp-relayed (a port of [check_dhcp_relayed](https://exchange.nagios.org/directory/Plugins/Network-Protocols/DHCP-and-BOOTP/check_dhcp_relayed/details))
* composer-version
* mediawiki-version


### Changed ("enhancement")

Icinga Director:

* all-the-rest.json: Rename "Starface Java Status" to "Starface Java Memory Usage"
* all-the-rest.json: Ignore session-c*.scope in systemd-units-failed by default

Monitoring Plugins:

* \*-version: Add new parameters `--insecure` `--no-proxy` `--timeout`
* about-me: Add detection of non-default software, udp ports, hardware and much more
* about-me: Add new parameters `--insecure` `--no-proxy` `--timeout`
* about-me: Pipes ("|") within the plugin output lead to broken perfdata ([#741](https://github.com/Linuxfabrik/monitoring-plugins/issues/741))
* apache-httpd-status: Add new parameters `--no-proxy` `--timeout`
* axenita-stats: Add new parameters `--insecure` `--no-proxy`
* cpu-usage: Add `--top` parameter, showing 5 top processes by default
* csv-values: Pipes in data are seen as delimiter between check output and performance data ([#727](https://github.com/Linuxfabrik/monitoring-plugins/issues/727))
* deb-lastactivity: WARN if last modified timestamp is not found for one or more packages ([#743](https://github.com/Linuxfabrik/monitoring-plugins/issues/743))
* diacos: Add new parameter `--insecure`
* feed: Make use of `--insecure` `--no-proxy` `--timeout`
* file-descriptors: Add `--top` parameter, showing 5 top processes by default
* file-size: Support Nagios ranges for `--warning` and `--critical` ([PR #735](https://github.com/Linuxfabrik/monitoring-plugins/issues/735), thanks to [djmcd89](https://github.com/djmcd89))
* fs-ro: Add `/dev/loop` to default ignore list
* fs-ro: Make output better readable ([PR #729](https://github.com/Linuxfabrik/monitoring-plugins/issues/729), thanks to [Konrad Bucheli](https://github.com/kbucheli))
* fs-ro: Show mount point info on first line when there is only one hit ([PR #730](https://github.com/Linuxfabrik/monitoring-plugins/issues/730), thanks to [Konrad Bucheli](https://github.com/kbucheli))
* githubstatus: Add new parameters `--insecure` `--no-proxy` `--timeout`
* gitlab-health: Add new parameters `--insecure` `--no-proxy`
* gitlab-liveness: Add new parameters `--insecure` `--no-proxy`
* gitlab-readiness: Add new parameters `--insecure` `--no-proxy`
* grassfish-\*: Add new parameters `--insecure` `--no-proxy` `--timeout`
* haproxy-status: Add new parameters `--insecure` `--no-proxy`
* huawei-dorado-\*: Add new parameter `--insecure`
* infomaniak-\*: Add new parameters `--insecure` `--no-proxy` `--timeout`
* infomaniak-events: Add new parameter `--ignore-regex`
* infomaniak-swiss-backup-products: Improve output
* jitsi-\*: Add new parameters `--insecure` `--no-proxy`
* journald-query: Remove hard-coded `--boot` parameter from query
* kvm-vm: Improve output
* librenms-version: Fetches info from local SQLite using new librenms library
* logfile: Add new parameters `--insecure` `--no-proxy` `--timeout`
* memory-usage: Add `--top` parameter, showing 5 top processes by default
* metabase-stats: Add new parameters `--insecure` `--no-proxy` `--timeout`
* mod-qos-stats: Add new parameters `--insecure` `--no-proxy` `--timeout`
* mysql-memory: Enhance output, set threshold to 95%
* nextcloud-security-scan: Add new parameters `--insecure` `--no-proxy`
* nextcloud-stats: Add new parameter `--timeout`
* nodebb-\*: Add new parameter `--no-proxy`
* nginx-status: Add new parameters `--insecure` `--no-proxy` `--timeout`
* ntp-chronyd: Provide config info if an ntp server is not being used
* onlyoffice-status: Add new parameters `--insecure` `--no-proxy`
* php-fpm-ping: Add new parameters `--insecure` `--no-proxy` `--timeout`
* php-fpm-status: Add new parameters `--insecure` `--no-proxy` `--timeout`
* php-status: Add new parameters `--insecure` `--no-proxy` `--timeout`
* redfish-drives: Add new parameters `--insecure` `--no-proxy` `--timeout`
* redfish-sel: Add new parameters `--insecure` `--no-proxy` `--timeout`
* redfish-sensor: Add new parameters `--insecure` `--no-proxy` `--timeout`
* rocket-\*: Add new parameters `--insecure` `--no-proxy` `--timeout`
* sap-open-concur: Add new parameter `--insecure`
* statuspal: Add new parameters `--insecure` `--no-proxy` `--timeout`
* swap-usage: Report the top 3 processes causing the usage (Linux only)
* swap-usage: Add `--top` parameter, showing 5 top processes by default
* veeam-status: Add new parameters `--insecure` `--no-proxy`
* wildfly-\*: Add new parameters `--insecure` `--no-proxy`
* xml: Add new parameter `--insecure`


### Fixed ("bug")

Icinga Director:

* all-the-rest.json: Fix "FreeIPA Server Service Set" definition

Monitoring Plugins:

* about-me: Throws exception for openvas ([#749](https://github.com/Linuxfabrik/monitoring-plugins/issues/749))
* infomaniak-events: Fix `UnboundLocalError: local variable 'keys' referenced before assignment`
* nextcloud-stats: KeyError: apps ([#731](https://github.com/Linuxfabrik/monitoring-plugins/issues/731))
* ntp-ntpd: Fixed unpacking of ntpq -p values ([PR #758](https://github.com/Linuxfabrik/monitoring-plugins/pull/758), thanks to [Leo Pempera](https://github.com/leo-pempera))
* ntp-w32tm: Fix `UnboundLocalError: local variable 'clock_rate' referenced before assignment`


## [2023112901] - 2023-11-29

### Breaking Changes

Monitoring Plugins:

* Notifications Plugins now generate URLs for Icinga DB Web instead of the old IcingaWeb2 Monitoring Module ([#643](https://github.com/Linuxfabrik/monitoring-plugins/issues/643))


### Added

Grafana:

* mysql-connections: Add Grafana dashboard
* mysql-memory: Add Grafana dashboard

Icinga Director:

* all-the-rest.json: Add Debian 12 (Bookworm), add deb-lastactivity
* all-the-rest.json: Add Apache Solr Service Set
* all-the-rest.json: Increase file size warning for `/var/log/secure`

Monitoring Plugins:

* about-me: Add detection of Apache Solr
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


### Changed ("enhancement")

Features:

* sudoers: Don't log command calls any longer.

Icinga Director:

* all-the-rest.json: Remove "Journald Query - aide-check.service" from the AIDE service set because it's not useful

Monitoring Plugins:

* All plugins: Consistently reporting errors using cu() instead of oao()
* \*-version: Add eol offset date, optional warn on new major/minor/patch
* \*-version: Curl from https://endoflife.date first, then use hardcoded version ([#680](https://github.com/Linuxfabrik/monitoring-plugins/issues/680))
* about-me: Add detection of ncdu
* about-me: Add detection of yarn
* about-me: Show systemd timers with next runtime
* cpu-usage: On Windows, exclude "System Idle Process" from the Top3 list
* disk-smart: Skip unsupported disks ([#672](https://github.com/Linuxfabrik/monitoring-plugins/issues/672))
* disk-usage: Add a parameter to select performance data ([#697](https://github.com/Linuxfabrik/monitoring-plugins/issues/697))
* fail2ban: Improve output, add unit-test
* fortios-firewall-stats: Allow the check to run even some FortiOS users use only IPv4 or IPv6 ([PR #719](https://github.com/Linuxfabrik/monitoring-plugins/issues/716), thanks to [Pierrot la menace](https://github.com/Pierrot-la-menace))
* grafana-version: Add Grafana v9.5
* infomaniak-events: Add filter for service categories
* infomaniak-swiss-backup-devices: Improve column ordering in output
* journald-query: Improve output
* mysql-aria: Remove WARN if `aria_pagecache_read_requests` > 0 and `pct_aria_keys_from_mem` < 95%
* mysql-connections: Add perfdata mysql_max_used_connections
* mysql-connections: Report and warn on current usage instead of peak usage, and improved output.
* mysql-innodb-buffer-pool-size: Improve code and output
* mysql-logfile: Returns OK instead of UNKNOWN if logfile is found but empty
* mysql-logfile: State only UNKNOWN if the log is empty and wasn't set deliberately ([PR #716](https://github.com/Linuxfabrik/monitoring-plugins/issues/716), thanks to [Eric Esser](https://github.com/dorkmaneuver))
* mysql-logfile: Stop magic auto-configure if `--server-log` is given
* openstack-nova-list: Make more robust in case of OpenStack errors
* php-version: Check multiple installed PHP versions ([#694](https://github.com/Linuxfabrik/monitoring-plugins/issues/694))
* ping: Check plugin to fast states "error" ([#691](https://github.com/Linuxfabrik/monitoring-plugins/issues/691))
* qts-\*: 'Keyerror: func' while executing qts-plugins ([#692](https://github.com/Linuxfabrik/monitoring-plugins/issues/692))
* qts-\*: General code and README improvements, all tested against QuTScloud 4.5.6, 5.0.1 and 5.1
* qts-temperature: Is it correct to have one value for CPU and System Temperature Threshold? ([#313](https://github.com/Linuxfabrik/monitoring-plugins/issues/313))
* qts-version: Shows up to date even when new firmware available ([#692](https://github.com/Linuxfabrik/monitoring-plugins/issues/692))
* rocketchat-stats: There are new values available ([#151](https://github.com/Linuxfabrik/monitoring-plugins/issues/151))
* systemd-unit: Encode unit-name to text before running systemd command
* uptime: Additionally report last reboot time ([#190](https://github.com/Linuxfabrik/monitoring-plugins/issues/190)
* xca-cert: refactor check, make better use of the new libraries ([#75](https://github.com/Linuxfabrik/monitoring-plugins/issues/75))


### Fixed ("bug")

Monitoring Plugins:

* csv-values: header included in data results despite setting "--skip-header" ([#706](https://github.com/Linuxfabrik/monitoring-plugins/issues/706))
* journald-query: Rename perfdata from "sudo journald-query" to "journald-query"
* path-rw-test: To avoid race conditions, use a unique filename ([#283](https://github.com/Linuxfabrik/monitoring-plugins/issues/283))
* qts-disk-smart: Plugin not working since new update ([#696](https://github.com/Linuxfabrik/monitoring-plugins/issues/696))
* swap-usage: Fix Traceback `PdhAddEnglishCounterW failed`



## [2023051201] - 2023-05-12

### Breaking Changes

Monitoring Plugins:

* disk-usage: Add include mount points/fs ([#662](https://github.com/Linuxfabrik/monitoring-plugins/issues/662)) (so dropped `--ignore` parameter)
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


### Changed ("enhancement")

Monitoring Plugins:

* apache-httpd-status: Remove `ReqPerSec`, `BytesPerSec`, `BytesPerReq`, `DurationPerReq` perfdata as they are wrong
* disk-io: `--ignore` now ignores all disks "starting with" the given parameter value
* disk-io: Move top3-processes-which-caused-the-most-io to here ([#285](https://github.com/Linuxfabrik/monitoring-plugins/issues/285))
* disk-usage: Add include mount points/fs ([#662](https://github.com/Linuxfabrik/monitoring-plugins/issues/662))
* disk-usage: allow passing absolute values for warn/crit ([#114](https://github.com/Linuxfabrik/monitoring-plugins/issues/114))
* disk-usage: Also show "free" in table ([#482](https://github.com/Linuxfabrik/monitoring-plugins/issues/482))
* disk-usage: Make plugin output more generic ([#664](https://github.com/Linuxfabrik/monitoring-plugins/issues/664))
* fortios-version: Simplified, returns version information in perfdata
* journald-query: Lower default for `--since` from 24h to 8h
* kemp-services: Display the original status of every Virtual Service ([#654](https://github.com/Linuxfabrik/monitoring-plugins/issues/654))
* Move "test3" and "examples" folder into a new "unit-test" folder for each plugin ([#288](https://github.com/Linuxfabrik/monitoring-plugins/issues/288))
* nextcloud-version: Simplified, no longer cares about patch levels, no longer needs internet access
* php-fpm-status: Remove `req per sec` perfdata as it is meaningless
* php-status: Move monitoring.php
* php-status: Rename perfdata item from `php-opcache-memory_usage-current_wasted_percentage` to `php-opcache-memory_usage-current_wasted-percentage`
* restic-snapshots: Shorten output, add `--lengthy` parameter, change DEFAULT_GROUP_BY to 'host,paths'
* Unified most of the \*-version3 checks in behavior, also using data from https://endoflife.date (no need for internet access).


### Fixed ("bug")

Monitoring Plugins:

* kemp-services: Credentials not converted correctly ([#653](https://github.com/Linuxfabrik/monitoring-plugins/issues/653))
* disk-smart: Getting error: "KeyError: 'serial_number'" ([#659](https://github.com/Linuxfabrik/monitoring-plugins/issues/659))
* disk-usage: module 'psutil' has no attribute 'disk_partitions' ([#663](https://github.com/Linuxfabrik/monitoring-plugins/issues/663))
* file-age: Type object 'SMBDirEntry' has no attribute 'from_filename' ([#665](https://github.com/Linuxfabrik/monitoring-plugins/issues/665))


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


### Changed ("enhancement")

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
* disk-usage: Move state output to usage column
* dmesg3: add additional message to ignorelist
* docker-info3: Report more info in case of failures
* docker-stats3: Report more info in case of failures
* fs-ro: Exclude squashfs filesystems ([#412](https://github.com/Linuxfabrik/monitoring-plugins/issues/412))
* fs-ro: Ignore ramfs ([#617](https://github.com/Linuxfabrik/monitoring-plugins/issues/617))
* infomaniak-swiss-backup-\*: Apply new API version
* journald-usage: Increase DEFAULT_WARN to 6 GiB
* matomo-reporting3: Perfdata now is also aware of percentages
* mysql-connections: add --ignore-name-resolution ([#631](https://github.com/Linuxfabrik/monitoring-plugins/issues/631))
* mysql-storage-engines3: Improve recognition of schema.table
* mysql-user-security: Ignore mysql.sys and mariadb.sys users
* network-connections: Alert if there's more than a specified number of conns ([#621](https://github.com/Linuxfabrik/monitoring-plugins/issues/621))
* php-status3: Improve output in case of startup/config/module errors
* php-status3: URL to monitoring.php should be optional
* php-version: Add PHP 8.3
* qts-version3: Add support for firmware 5.0.1+
* redis-status: Do not warn on "Peak memory"
* rpm-lastactivity: do | sort | tail -1 with Python Code ([#94](https://github.com/Linuxfabrik/monitoring-plugins/issues/94))
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


### Fixed ("bug")

Monitoring Plugins:

* disk-usage: ignore type CDFS by default ([#632](https://github.com/Linuxfabrik/monitoring-plugins/issues/632))
* docker-stats missing shortening of containername in perfdata output ([#600](https://github.com/Linuxfabrik/monitoring-plugins/issues/600))
* file-age: critical reported for new files because modification time is negative or not set ([#618](https://github.com/Linuxfabrik/monitoring-plugins/issues/618))
* infomaniak-swiss-backup-devices3: Fix TypeError: unsupported operand type(s) for -: 'int' and 'NoneType'
* librenms-version: KeyError: 'mysql_ver' ([#602](https://github.com/Linuxfabrik/monitoring-plugins/issues/602))
* matomo-reporting3: --metric - Got more information back instead one metric ([#603](https://github.com/Linuxfabrik/monitoring-plugins/issues/603))
* nextcloud-stats: Fix error non-existing ALWAYS_OK Attribute ([#640](https://github.com/Linuxfabrik/monitoring-plugins/pull/640))
* ping: ping -t has to be int but its float ([#628](https://github.com/Linuxfabrik/monitoring-plugins/issues/628))
* rpm-lastactivity: ValueError: invalid literal for int() with base 10: '' ([#616](https://github.com/Linuxfabrik/monitoring-plugins/issues/616))
* systemd-timedate-status: UNKNOWN with "unknown operation show" on RHEL7 ([#605]https://github.com/Linuxfabrik/monitoring-plugins/issues/605))
* updates: On Windows with closed firewall a PowerShell error is returned ([#633]https://github.com/Linuxfabrik/monitoring-plugins/issues/633))


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


### Changed ("enhancement")

Monitoring Plugins:

* about-me: Add AIDE ([#546](https://github.com/Linuxfabrik/monitoring-plugins/issues/546))
* about-me: Add Birthdate ([#554](https://github.com/Linuxfabrik/monitoring-plugins/issues/554))
* about-me: Add certbot and acme.sh ([#433](https://github.com/Linuxfabrik/monitoring-plugins/issues/433))
* about-me: Add gpg ([#511](https://github.com/Linuxfabrik/monitoring-plugins/issues/511))
* about-me: Add list of listening ports ([#538](https://github.com/Linuxfabrik/monitoring-plugins/issues/538))
* about-me: Add mod_security ([#496](https://github.com/Linuxfabrik/monitoring-plugins/issues/496))
* about-me: Add swanctl ([#575](https://github.com/Linuxfabrik/monitoring-plugins/issues/575))
* about-me: Print its own version ([#439](https://github.com/Linuxfabrik/monitoring-plugins/issues/439))
* about-me: Report active tuned-Profile in first line if tuned.service is found and running ([#374](https://github.com/Linuxfabrik/monitoring-plugins/issues/374))
* about-me: Report Boot Mode ([#562](https://github.com/Linuxfabrik/monitoring-plugins/issues/562)) 
* about-me: Show key features of the Machine ([#561](https://github.com/Linuxfabrik/monitoring-plugins/issues/561))
* All checks using SQLite databases: More unique sqlite db names ([#333](https://github.com/Linuxfabrik/monitoring-plugins/issues/333))
* apache-httpd-status: New parameter `--insecure`
* cpu-usage: Subtract the "nice" percentage from thresholds ([#550](https://github.com/Linuxfabrik/monitoring-plugins/issues/550))
* dhcp-scope-usage: Parse PercentageInUse locale-aware ([PR #551](https://github.com/Linuxfabrik/monitoring-plugins/pull/551))
* disk-io: Checks if psutil has a certain minimum version on systems with kernel 4.18+.
* disk-smart: Exclude zfs-volumes ([PR #539](https://github.com/Linuxfabrik/monitoring-plugins/pull/539))
* disk-smart: Now also runs on Windows ([PR #553](https://github.com/Linuxfabrik/monitoring-plugins/pull/553))
* disk-smart: Properly handle Power_On_Hours_and_Msec attribute perfdata parsing ([PR #549](https://github.com/Linuxfabrik/monitoring-plugins/pull/549))
* disk-usage: Critical but first line of plugin output prints "OK" ([#545](https://github.com/Linuxfabrik/monitoring-plugins/issues/545))
* docker-info: Raise CRIT on return code != 0 ([#569](https://github.com/Linuxfabrik/monitoring-plugins/issues/569))
* docker-stats: Improve handling of container names ([#586](https://github.com/Linuxfabrik/monitoring-plugins/issues/586)). New parameter `--full-name`.
* file-age: Improve perfdata labels
* file-age: Performance data aggregation on file_age check ([PR #544](https://github.com/Linuxfabrik/monitoring-plugins/pull/544))
* file-age: shorten the message ([#559](https://github.com/Linuxfabrik/monitoring-plugins/issues/559))
* infomaniak-swiss-backup-devices3: Increase default thresholds from 80/90% to 90/95%
* infomaniak-swiss-backup-devices3: Sort output table by "Tags" column
* infomaniak-swiss-backup-products3: Changed thresholds from 14/5 days to 6/3 days
* infomaniak-swiss-backup-products3: Sort output table by "Tags" column
* ipmi-sel: Change the order of events ([#558](https://github.com/Linuxfabrik/monitoring-plugins/issues/558))
* needs-restarting3: Debian Buster/bullseye command not found ([#572](https://github.com/Linuxfabrik/monitoring-plugins/issues/572))
* php-status: Add a "--dev" switch to not warn on display_errors=On and display_startup_errors=On ([#461](https://github.com/Linuxfabrik/monitoring-plugins/issues/461))
* php-status: Change behavior when handling default values ([#540](https://github.com/Linuxfabrik/monitoring-plugins/issues/540))
* qts-\*: Increase default connect timeout from 3 to 6 seconds
* Revert Python 3.6+ `f`-strings to use `.format()` to be more conservative
* systemd-units-failed: Allow wildcards for the `--ignore` parameter ([#542](https://github.com/Linuxfabrik/monitoring-plugins/issues/542))

Icinga Director:

* Adjust windows director definitions to the new folder structure
* Increase windows service check intervals


### Fixed ("bug")

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

* Active Directory Certificate Services Service Set
* Active Directory Domain Services Service Set
* Active Directory Federation Services Service Set
* Active Directory Lightweight Directory Services Service Set
* DHCP Server Service Set
* DHCP Server Failover Feature Service Set
* DNS Server Service Set
* Duplicati Service Set
* Huawei Dorado Service Set
* Redfish Service Set
* Redfish no agent Service Set
* Veeam Backup & Replication Service Set
* Web Server (IIS) Service Set
* Windows Defender Antivirus Service Service Set
* Windows Basic Service Set extended Service Set


### Fixed ("bug")

Monitoring Plugins:

* Able to choose a single or some DS in cmd-check-wildfly-non-xa-datasource-stats ([#495](https://github.com/Linuxfabrik/monitoring-plugins/issues/495))
* about-me: Add ownCloud and alternate Nextcloud Path ([#512](https://github.com/Linuxfabrik/monitoring-plugins/issues/512))
* about-me: Open Virtual Machine Tools Error: vmtoolsd must be run inside a virtual machine on a VMware hypervisor product. ([#513](https://github.com/Linuxfabrik/monitoring-plugins/issues/513))
* about-me: report virtualisation ([#480](https://github.com/Linuxfabrik/monitoring-plugins/issues/480))
* about-me: Should be able to run even if psutil is or cannot be installed ([#514](https://github.com/Linuxfabrik/monitoring-plugins/issues/514))
* about-me: Traceback "IndexError: list index out of range" ([#443](https://github.com/Linuxfabrik/monitoring-plugins/issues/443))
* about-me: Traceback 'ModuleWrapper' object has no attribute 'net_if_addrs' ([#438](https://github.com/Linuxfabrik/monitoring-plugins/issues/438))
* Adapt check-plugin to pylinted libraries ([#526](https://github.com/Linuxfabrik/monitoring-plugins/issues/526))
* added basket for redfish-sel and redfish-sensor, re-ran check2basket
* added director config for huawei checks
* added huawei dorado service set
* added notify-host-mail
* added notify-host-zoom
* added notify-service-mail
* added notify-service-zoom
* added redfish no agent service set
* added redfish service set
* added redfish-drives to the service sets
* added redfish-sel and redfish-sensor windows variants
* added Rocky8.sudoers
* added sudoers for openSUSE Leap15
* added tpl-service-cert and improved tpl-service-url
* added tpl-service-cert-no-agent
* added unit-test examples
* adjusted director baskets for the new windows variants
* adjusted huawei service names
* All Python3 Plugins: Use new §rary "human.py" ([#521](https://github.com/Linuxfabrik/monitoring-plugins/issues/521))
* All Python3 Plugins: Use new library "shell3.py" ([#525](https://github.com/Linuxfabrik/monitoring-plugins/issues/525))
* All Python3 Plugins: Use new library "time3.py" ([#524](https://github.com/Linuxfabrik/monitoring-plugins/issues/524))
* All Python3 Plugins: Use new library "txt3.py" ([#522](https://github.com/Linuxfabrik/monitoring-plugins/issues/522))
* all-the-rest.json: add service set for acme.sh ([#447](https://github.com/Linuxfabrik/monitoring-plugins/issues/447))
* all-the-rest.json: Delete SysMain from Windows Service Set ([#446](https://github.com/Linuxfabrik/monitoring-plugins/issues/446))
* all-the-rest.json: fixed guids
* all-the-rest.json: added acme.sh tag
* all-the-rest.json: added duplicati service set
* all-the-rest.json: adjusted loolwsd to coolwsd
* all-the-rest.json: removed getent from the basic service sets
* apache-httpd-status: Traceback on Ubuntu Xenial (16.04) ([#436](https://github.com/Linuxfabrik/monitoring-plugins/issues/436))
* basket-join: allowed missing Datafield key
* basket-join: error on duplicate entries in json
* BorgBackup: AttributeError: 'str' object has no attribute 'decode' ([#430](https://github.com/Linuxfabrik/monitoring-plugins/issues/430))
* check2basket: abort on error with the --auto option
* check2basket: added workaround for notification-plugins
* check2basket: extended to support notification-plugins
* check2basket: fixed problem with notification-plugins
* check2basket: removed default states for notifications
* dhcp-scope-usage: Add WinRM capability ([#477](https://github.com/Linuxfabrik/monitoring-plugins/issues/477))
* dhcp-scope-usage: added director config
* disabled TimeBrokerSvc for now ([#427](https://github.com/Linuxfabrik/monitoring-plugins/issues/427))
* disk-smart: disk names like sdda, sdab and so on were not checked ([#487](https://github.com/Linuxfabrik/monitoring-plugins/issues/487))
* dns: Grafana Panels divide query time by 1000 ([#228](https://github.com/Linuxfabrik/monitoring-plugins/issues/453))
* enabled notifcations for redfish checks
* extended windows basic service set
* fail2ban: Grafana Panels list "Banned IPs" twice ([#139](https://github.com/Linuxfabrik/monitoring-plugins/issues/139))
* file-age: new files or modifications after now result in files from the future ([#478](https://github.com/Linuxfabrik/monitoring-plugins/issues/478))
* file-age: recompiled for windows
* file-age: Windows variant crashes if using a glob wildcard ([#494](https://github.com/Linuxfabrik/monitoring-plugins/issues/494))
* fortios-network-io: adjusted grafana dashboard name
* fs-xfs-stats: I/O error "No such file or directory" while opening or reading /proc/fs/xfs/stat ([#445](https://github.com/Linuxfabrik/monitoring-plugins/issues/445))
* getent: Increase Icinga Timeout to 30sec ([#455](https://github.com/Linuxfabrik/monitoring-plugins/issues/455))
* jitsi-videobridge-status3: TypeError: string indices must be integers ([#527](https://github.com/Linuxfabrik/monitoring-plugins/issues/527))
* Let the new txt3 library do all encoding and decoding ([#507](https://github.com/Linuxfabrik/monitoring-plugins/issues/507))
* librenms checks: added more filtering parameters
* librenms-alerts: added --device-group parameter
* librenms-health: adjusted check timeout
* librenms-health: Timeout on too many values ([#365](https://github.com/Linuxfabrik/monitoring-plugins/issues/365))
* made sure that the no-agent and sudo variant are based on linux
* mysql-stats: Traceback ([#170](https://github.com/Linuxfabrik/monitoring-plugins/issues/170))
* nextcloud-stats3: TypeError: a bytes-like object is required, not 'str' ([#517](https://github.com/Linuxfabrik/monitoring-plugins/issues/517))
* nextcloud-stats3: TypeError: string argument without an encoding ([#531](https://github.com/Linuxfabrik/monitoring-plugins/issues/531))
* nextcloud-stats: DB size is reported using YiB ([#463](https://github.com/Linuxfabrik/monitoring-plugins/issues/463))
* nextcloud-version3: Put get_owner() from base3 in here ([#523](https://github.com/Linuxfabrik/monitoring-plugins/issues/523))
* nginx-status3: ModuleNotFoundError: No module named 'lib.globals2' ([#515](https://github.com/Linuxfabrik/monitoring-plugins/issues/515))
* nginx-status: Print human readable total values ([#520](https://github.com/Linuxfabrik/monitoring-plugins/issues/520))
* nginx-status: wrong perfdata ([#440](https://github.com/Linuxfabrik/monitoring-plugins/issues/440))
* ntp-offset: Regular UNKOWN when using with chrony ([#71](https://github.com/Linuxfabrik/monitoring-plugins/issues/71))
* php-status3: SyntaxError: invalid syntax ([#532](https://github.com/Linuxfabrik/monitoring-plugins/issues/532))
* php-status: Cannot report some values if not running with sudo, so please give a hint ([#459](https://github.com/Linuxfabrik/monitoring-plugins/issues/459))
* php-status: needs to run with sudo
* php-status: On some machines, display_startup_errors is N/A ([#434](https://github.com/Linuxfabrik/monitoring-plugins/issues/434))
* php-version: Warns "PHP v7.4.25 is available (installed: v7.4.24)", but should not ([#435](https://github.com/Linuxfabrik/monitoring-plugins/issues/435))
* Procs (Windows): Traceback "AttributeError: module object has no attribute STATUS_PARKED" ([#453](https://github.com/Linuxfabrik/monitoring-plugins/issues/453))
* procs3: on windows, it always returns [oldest proc created 52Y 1M ago` (`#506](https://github.com/Linuxfabrik/monitoring-plugins/issues/506))
* procs: on Windows, Traceback "AttributeError: 'module' object has no attribute 'STATUS_PARKED'" ([#453](https://github.com/Linuxfabrik/monitoring-plugins/issues/453))
* procs: when checking if a process exists, returns OK even if the process is missing ([#488](https://github.com/Linuxfabrik/monitoring-plugins/issues/488))
* pylint all check plugins ([#529](https://github.com/Linuxfabrik/monitoring-plugins/issues/529))
* redfish-sensor: returns 404 against esx ([#460](https://github.com/Linuxfabrik/monitoring-plugins/issues/460))
* redis-status3: AttributeError: module lib has no attribute "disk2" ([#498](https://github.com/Linuxfabrik/monitoring-plugins/issues/498))
* redis-status: Make it more tolerant when it comes to Defragmentation ([#425](https://github.com/Linuxfabrik/monitoring-plugins/issues/425))
* redis-status: Mistakenly reports "net.core.somaxconn is lower than net.ipv4.tcp_max_syn_backlog [WARNING]" ([#458](https://github.com/Linuxfabrik/monitoring-plugins/issues/458))
* redis-status: Redis requires more memory than available and is forced to use swap ([#486](https://github.com/Linuxfabrik/monitoring-plugins/issues/486))
* redis-status: Support Redis 3.0 ([#510](https://github.com/Linuxfabrik/monitoring-plugins/issues/510))
* redis-status: warning only if cache hit rate < 10% ([#490](https://github.com/Linuxfabrik/monitoring-plugins/issues/490))
* redis-status: Warning when using a password on command line ([#450](https://github.com/Linuxfabrik/monitoring-plugins/issues/450))
* redis: Warn on bad OS configuration ([#428](https://github.com/Linuxfabrik/monitoring-plugins/issues/428))
* rocketchat-stats: rename rocket.chat to rocketchat ([#335](https://github.com/Linuxfabrik/monitoring-plugins/issues/335))
* Some compiled Windows-Plugins are shipped without required 3rd Party Python Modules ([#504](https://github.com/Linuxfabrik/monitoring-plugins/issues/504))
* split up librenms services by type in the services set
* swap-usage: recompiled for windows ([#454](https://github.com/Linuxfabrik/monitoring-plugins/issues/454))
* swap-usage: recompiled for windows ([#456](https://github.com/Linuxfabrik/monitoring-plugins/issues/456))
* swap-usage: UnboundLocalError: local variable msg_body referenced before assignment ([#456](https://github.com/Linuxfabrik/monitoring-plugins/issues/456))
* swap: Dont display "swapped in" and "swapped out" on Windows ([#454](https://github.com/Linuxfabrik/monitoring-plugins/issues/454))
* systemd-unit: On Fedora, failed Units are printed with all columns shifted one to the right ([#328](https://github.com/Linuxfabrik/monitoring-plugins/issues/328))
* systemd-unit: UnitFileState is "", but supposed to be "empty" ([#509](https://github.com/Linuxfabrik/monitoring-plugins/issues/509))
* users: On Windows: UnicodeDecodeError: 'utf-8' codec can't decode byte 0x81 in position 25: invalid start byte ([#451](https://github.com/Linuxfabrik/monitoring-plugins/issues/451))
* users: quote the output because of possible pipe symbol in "WHAT" column ([#17](https://github.com/Linuxfabrik/monitoring-plugins/issues/17))
* veeam-status: Make --username and --password mandatory ([#499](https://github.com/Linuxfabrik/monitoring-plugins/issues/499))
* veeam.py: ValueError: need more than 2 values to unpack ([#45](https://github.com/Linuxfabrik/monitoring-plugins/issues/45))
* wildfly-deployment-status: Allow to limit deployment by name ([#497](https://github.com/Linuxfabrik/monitoring-plugins/issues/497))
* Windows: New Service Set for "Windows Defender Antivirus Service" ([#469](https://github.com/Linuxfabrik/monitoring-plugins/issues/469))
* Windows: New Service Set for Windos-Servers running "Web Server (IIS)" ([#465](https://github.com/Linuxfabrik/monitoring-plugins/issues/465))
* Windows: New Service Set for Windows Servers running "Active Directory Certificate Services" ([#472](https://github.com/Linuxfabrik/monitoring-plugins/issues/472))
* Windows: New Service Set for Windows Servers running "Active Directory Domain Services" ([#468](https://github.com/Linuxfabrik/monitoring-plugins/issues/468))
* Windows: New Service Set for Windows Servers running "Active Directory Federation Services" ([#471](https://github.com/Linuxfabrik/monitoring-plugins/issues/471))
* Windows: New Service Set for Windows Servers running "Active Directory Lightweight Directory Services" ([#473](https://github.com/Linuxfabrik/monitoring-plugins/issues/473))
* Windows: New Service Set for Windows-Servers running "DHCP Server Failover Feature" ([#467](https://github.com/Linuxfabrik/monitoring-plugins/issues/467))
* Windows: New Service Set for Windows-Servers running "DHCP Server" ([#466](https://github.com/Linuxfabrik/monitoring-plugins/issues/466))
* Windows: New Service Set for Windows-Servers running "DNS Server" ([#470](https://github.com/Linuxfabrik/monitoring-plugins/issues/470))
* Windows: New ServiceSet for Windows-Servers running "Veeam Backup & Replication" ([#464](https://github.com/Linuxfabrik/monitoring-plugins/issues/464))




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
* Starface PBX: Account, Database and Perr Statistics; Overall, Backup and Channel Status; Java Memory Usage
* Veeam Status

Event Plugins:

* Cloudflare Security Level

Icinga Director:

* Four checks have been added to the Windows Basic ServiceSet (disk-io, dns, swap-usage, top3-processes-which-caused-the-most-io)


### Changed ("enhancement")

Monitoring Plugins:

* about-me: Reports much much more inventory info. New sections are Interfaces (IPv4), systemd default target, systemd timers, systemd enabled units, systemd mounts, systemd automounts, non-default users and crontabs.
* apache-httpd-status: Now calculates the average values ReqPerSec, BytesPerSec, BytesPerReq and DurationPerReq over Apache's uptime.
* php-\*: Report more (don't forget to install the new `monitoring.php` as well).
* procs: Counting is more accurate.
* ping: Mainly used for host alive checking, now reports OK on request (using `--always-ok`) if a host cannot be reached for some reason only on the ping side, but can otherwise be checked e.g. by the Icinga agent.


### Fixed ("bug")

Monitoring Plugins:

* about-me: Add content of os family /etc/release file ([#319](https://github.com/Linuxfabrik/monitoring-plugins/issues/319))
* about-me: Add GCC ([#306](https://github.com/Linuxfabrik/monitoring-plugins/issues/306))
* about-me: Add GitLab Community Edition (Omnibus) ([#371](https://github.com/Linuxfabrik/monitoring-plugins/issues/371))
* about-me: Add OpenVPN ([#341](https://github.com/Linuxfabrik/monitoring-plugins/issues/341))
* about-me: Add the FQDN hostname to the first line ([#368](https://github.com/Linuxfabrik/monitoring-plugins/issues/368))
* about-me: Add Veeam ([#315](https://github.com/Linuxfabrik/monitoring-plugins/issues/315))
* about-me: extend with more infos ([#362](https://github.com/Linuxfabrik/monitoring-plugins/issues/362))
* about-me: Find vsftpd ([#269](https://github.com/Linuxfabrik/monitoring-plugins/issues/269))
* about-me: Only last disk is shown ([#281](https://github.com/Linuxfabrik/monitoring-plugins/issues/281))
* about-me: Remove newline after printing "vsftpd" ([#364](https://github.com/Linuxfabrik/monitoring-plugins/issues/364))
* about-me: Reports loolwsd even if it is not installed ([#370](https://github.com/Linuxfabrik/monitoring-plugins/issues/370))
* about-me: too many values to unpack ([#372](https://github.com/Linuxfabrik/monitoring-plugins/issues/372))
* apache-httpd-stats: Add a Python 3 version ([#327](https://github.com/Linuxfabrik/monitoring-plugins/issues/327))
* apache-httpd-status: also print worker percentage state in table ([#311](https://github.com/Linuxfabrik/monitoring-plugins/issues/311))
* apache-httpd-status: ReqPerSec, BytesPerSec, BytesPerReq and DurationPerReq are average values that are calculated by Apache over its uptime ([#310](https://github.com/Linuxfabrik/monitoring-plugins/issues/310))
* apache-httpd-status: unsupported operand type(s) for +: 'float' and 'str' ([#323](https://github.com/Linuxfabrik/monitoring-plugins/issues/323))
* axenita-stats: Add a Python 3 version ([#376](https://github.com/Linuxfabrik/monitoring-plugins/issues/376))
* borgbackup: add a Python 3 version ([#287](https://github.com/Linuxfabrik/monitoring-plugins/issues/287))
* borgbackup: No need to open Borg logfile in binary mode ([#420](https://github.com/Linuxfabrik/monitoring-plugins/issues/420))
* check2basket: add update mode ([#203](https://github.com/Linuxfabrik/monitoring-plugins/issues/203))
* cloudflare-security-level: Make "--zone-id" repeatable ([#309](https://github.com/Linuxfabrik/monitoring-plugins/issues/309))
* consistently handle unicode ([#334](https://github.com/Linuxfabrik/monitoring-plugins/issues/334))
* countdown: Add a Python 3 version ([#377](https://github.com/Linuxfabrik/monitoring-plugins/issues/377))
* disk-io: After reboot, byte values are 0 or very low, so rate diffs are negative ([#312](https://github.com/Linuxfabrik/monitoring-plugins/issues/312))
* disk-smart: Add a Python 3 version ([#401](https://github.com/Linuxfabrik/monitoring-plugins/issues/401))
* disk-usage: Add --ignore parameter (repeating) ([#351](https://github.com/Linuxfabrik/monitoring-plugins/issues/351))
* dmesg3: AttributeError: module 'lib' has no attribute 'base2' ([#330](https://github.com/Linuxfabrik/monitoring-plugins/issues/330))
* dmesg: Add "brcmfmac" messages to ignore list ([#338](https://github.com/Linuxfabrik/monitoring-plugins/issues/338))
* dmesg: Add --ignore parameter (repeating) ([#340](https://github.com/Linuxfabrik/monitoring-plugins/issues/340))
* dmesg: Always counts +1 ([#331](https://github.com/Linuxfabrik/monitoring-plugins/issues/331))
* dmesg: Reduce the output to a maximum of ten lines ([#254](https://github.com/Linuxfabrik/monitoring-plugins/issues/254))
* docker-info: Add a Python 3 version ([#378](https://github.com/Linuxfabrik/monitoring-plugins/issues/378))
* dummy broken in dev branch ([#354](https://github.com/Linuxfabrik/monitoring-plugins/issues/354))
* dummy: Add a Python 3 version ([#379](https://github.com/Linuxfabrik/monitoring-plugins/issues/379))
* example3: Partially uses base2 library ([#369](https://github.com/Linuxfabrik/monitoring-plugins/issues/369))
* example: Provide unit-tests ([#326](https://github.com/Linuxfabrik/monitoring-plugins/issues/326))
* fail2ban: Add a Python 3 version ([#380](https://github.com/Linuxfabrik/monitoring-plugins/issues/380))
* feed: Add a Python 3 version ([#402](https://github.com/Linuxfabrik/monitoring-plugins/issues/402))
* file-age: correctly handle negative times ([#188](https://github.com/Linuxfabrik/monitoring-plugins/issues/188))
* file-age: Improve output message ([#361](https://github.com/Linuxfabrik/monitoring-plugins/issues/361))
* file-count: Add a Python 3 version ([#381](https://github.com/Linuxfabrik/monitoring-plugins/issues/381))
* file-ownership: Check /tmp/linuxfabrik-plugin-cache.db ([#356](https://github.com/Linuxfabrik/monitoring-plugins/issues/356))
* file-ownership: On Debian, there are some other defaults ([#294](https://github.com/Linuxfabrik/monitoring-plugins/issues/294))
* file-ownership: On SLES, there are some other defaults ([#317](https://github.com/Linuxfabrik/monitoring-plugins/issues/317))
* file-ownership: On Ubuntu, there are some other defaults ([#332](https://github.com/Linuxfabrik/monitoring-plugins/issues/332))
* file-size: Adapt source code to example ([#398](https://github.com/Linuxfabrik/monitoring-plugins/issues/398))
* fortios-\*: Add a Python 3 version ([#424](https://github.com/Linuxfabrik/monitoring-plugins/issues/424))
* getent: Also print the response (could be interesting) ([#297](https://github.com/Linuxfabrik/monitoring-plugins/issues/297))
* getent: ascii codec can't decode byte ([#367](https://github.com/Linuxfabrik/monitoring-plugins/issues/367))
* ipmi-sel: Add Python 3 version ([#384](https://github.com/Linuxfabrik/monitoring-plugins/issues/384))
* ipmi-sensor: Add a Python 3 version ([#385](https://github.com/Linuxfabrik/monitoring-plugins/issues/385))
* json-values: Adapt source code to example ([#399](https://github.com/Linuxfabrik/monitoring-plugins/issues/399))
* kemp-services: Add a Python 3 version ([#403](https://github.com/Linuxfabrik/monitoring-plugins/issues/403))
* keycloak-version: Add a Python 3 version ([#400](https://github.com/Linuxfabrik/monitoring-plugins/issues/400))
* kvm-vm: Add a Python 3 version ([#388](https://github.com/Linuxfabrik/monitoring-plugins/issues/388))
* librenms-alerts: Add Python 3 version ([#389](https://github.com/Linuxfabrik/monitoring-plugins/issues/389))
* librenms-health: Add a Python 3 version ([#390](https://github.com/Linuxfabrik/monitoring-plugins/issues/390))
* librenms-version: add a Python 3 version ([#314](https://github.com/Linuxfabrik/monitoring-plugins/issues/314))
* logfile: Adapt source code to example ([#404](https://github.com/Linuxfabrik/monitoring-plugins/issues/404))
* mailq: Add a Python 3 version ([#391](https://github.com/Linuxfabrik/monitoring-plugins/issues/391))
* Make usage of --help possible even if some python modules are missing ([#42](https://github.com/Linuxfabrik/monitoring-plugins/issues/42))
* matomo-reporting: Add a Python 3 version ([#405](https://github.com/Linuxfabrik/monitoring-plugins/issues/405))
* matomo-version: Add a Python 3 version ([#406](https://github.com/Linuxfabrik/monitoring-plugins/issues/406))
* metabase-stats: Add a Python 3 version ([#342](https://github.com/Linuxfabrik/monitoring-plugins/issues/342))
* mydumper-version: 'module' object has no attribute 'url2' ([#322](https://github.com/Linuxfabrik/monitoring-plugins/issues/322))
* mydumper-version: Stumbles upon "v0.10.7-2" ([#318](https://github.com/Linuxfabrik/monitoring-plugins/issues/318))
* mysql-stats: Add a Python 3 version ([#407](https://github.com/Linuxfabrik/monitoring-plugins/issues/407))
* needs-restarting: Add a Python 3 version ([#393](https://github.com/Linuxfabrik/monitoring-plugins/issues/393))
* network-bonding: Add a Python 3 version ([#409](https://github.com/Linuxfabrik/monitoring-plugins/issues/409))
* network-port-tcp: Add a Python 3 version ([#410](https://github.com/Linuxfabrik/monitoring-plugins/issues/410))
* network-port-tcp: NameError: global name 'TYPE' is not defined ([#298](https://github.com/Linuxfabrik/monitoring-plugins/issues/298))
* nextcloud-security-scan: Add a Python 3 version ([#411](https://github.com/Linuxfabrik/monitoring-plugins/issues/411))
* nextcloud-stats: Add a Python 3 version ([#413](https://github.com/Linuxfabrik/monitoring-plugins/issues/413))
* nginx-status: Add a Python 3 version ([#414](https://github.com/Linuxfabrik/monitoring-plugins/issues/414))
* ntp-offset: Add Python 3 version ([#387](https://github.com/Linuxfabrik/monitoring-plugins/issues/387))
* onlyoffice-stats: Add a Python 3 version ([#394](https://github.com/Linuxfabrik/monitoring-plugins/issues/394))
* openvpn-client-list: Add a Python 3 version ([#395](https://github.com/Linuxfabrik/monitoring-plugins/issues/395))
* openvpn-client-list: No need to open OpenVPN logfile in binary mode ([#421](https://github.com/Linuxfabrik/monitoring-plugins/issues/421))
* php-status: Config and Module error message could be a little bit more precise ([#267](https://github.com/Linuxfabrik/monitoring-plugins/issues/267))
* php-status: Make check for a high Cache "Hit Rate" optional ([#303](https://github.com/Linuxfabrik/monitoring-plugins/issues/303))
* php-status: monitoring.php does not run on PHP 7.2 ([#289](https://github.com/Linuxfabrik/monitoring-plugins/issues/289))
* php-status: Print php.ini "Off" and "On" values as "Off" and "On" ([#325](https://github.com/Linuxfabrik/monitoring-plugins/issues/325))
* php-status: Remove "simplexml" from default module list ([#284](https://github.com/Linuxfabrik/monitoring-plugins/issues/284))
* php-status: Report more opcache-settings in output table ([#353](https://github.com/Linuxfabrik/monitoring-plugins/issues/353))
* php-status: Reporting "Opcache not installed or not enabled" if monitoring.php is not used ([#324](https://github.com/Linuxfabrik/monitoring-plugins/issues/324))
* php-status: Typo in Output ("Opache") ([#296](https://github.com/Linuxfabrik/monitoring-plugins/issues/296))
* php-status: Uncaught Error: Call to undefined function opcache_get_status() in /var/www/html/monitoring.php:6 ([#290](https://github.com/Linuxfabrik/monitoring-plugins/issues/290))
* php-version: Just check on PHP Version Major.Minor (default), not on Major.Minor.Patch ([#304](https://github.com/Linuxfabrik/monitoring-plugins/issues/304))
* php-version: Test against package manager. Print version from php.net just as a hint. ([#253](https://github.com/Linuxfabrik/monitoring-plugins/issues/253))
* php-version: ValueError: invalid literal for float(): 5.640-0+deb8u12 ([#293](https://github.com/Linuxfabrik/monitoring-plugins/issues/293))
* ping: Add --always-ok for unpingable but check-capable hosts ([#392](https://github.com/Linuxfabrik/monitoring-plugins/issues/392))
* ping: Add a Python 3 version ([#348](https://github.com/Linuxfabrik/monitoring-plugins/issues/348))
* procs: Alert on specific processes ([#355](https://github.com/Linuxfabrik/monitoring-plugins/issues/355))
* procs: Counting in output seems to be wrong ([#357](https://github.com/Linuxfabrik/monitoring-plugins/issues/357))
* procs: NameError: name 'STATE_Ok' is not defined ([#363](https://github.com/Linuxfabrik/monitoring-plugins/issues/363))
* provide the icinga director command definitions using the basket ([#301](https://github.com/Linuxfabrik/monitoring-plugins/issues/301))
* qts-\*: Add a Python 3 version ([#423](https://github.com/Linuxfabrik/monitoring-plugins/issues/423))
* qts-temperatures: Traceback ([#360](https://github.com/Linuxfabrik/monitoring-plugins/issues/360))
* Remove unnecessary import of lib.args ([#347](https://github.com/Linuxfabrik/monitoring-plugins/issues/347))
* Replace print() in all plugins by oao() to make unicode handling more consistent ([#344](https://github.com/Linuxfabrik/monitoring-plugins/issues/344))
* Replace unit test code in all plugins by new "test" library ([#343](https://github.com/Linuxfabrik/monitoring-plugins/issues/343))
* rocketchat-stats: Add a Python 3 version ([#415](https://github.com/Linuxfabrik/monitoring-plugins/issues/415))
* rocketchat-version: Add a Python 3 version ([#416](https://github.com/Linuxfabrik/monitoring-plugins/issues/416))
* Save all plugins with UTF-8 Encoding ([charset=utf-8` format) (`#305](https://github.com/Linuxfabrik/monitoring-plugins/issues/305))
* scheduled-task: Adapt source code to example ([#417](https://github.com/Linuxfabrik/monitoring-plugins/issues/417))
* sensors-battery: Add a Python 3 version ([#418](https://github.com/Linuxfabrik/monitoring-plugins/issues/418))
* sensors-temperature: Add a Python 3 version ([#419](https://github.com/Linuxfabrik/monitoring-plugins/issues/419))
* service: Adapt source code to example3 ([#386](https://github.com/Linuxfabrik/monitoring-plugins/issues/386))
* service: bad output/status if status is 'running' but not supposed to be 'running', ([#336](https://github.com/Linuxfabrik/monitoring-plugins/issues/336))
* snmp: Adapt source code to example ([#396](https://github.com/Linuxfabrik/monitoring-plugins/issues/396))
* systemd-unit: the --unitfilestate parameter should accept None to disable checking of the unit file state ([#299](https://github.com/Linuxfabrik/monitoring-plugins/issues/299))
* systemd-units-failed: add "ignore" parameter (repeating) ([#160](https://github.com/Linuxfabrik/monitoring-plugins/issues/160))
* systemd-units-failed: add --ignore parameter (repeating) ([#337](https://github.com/Linuxfabrik/monitoring-plugins/issues/337))
* systemd-units: UnitFileState might be empty ("") ([#292](https://github.com/Linuxfabrik/monitoring-plugins/issues/292))
* Unit test fails ([#346](https://github.com/Linuxfabrik/monitoring-plugins/issues/346))
* updates: Adapt source code to example3 ([#383](https://github.com/Linuxfabrik/monitoring-plugins/issues/383))
* Use lib.base.cu() instead of print_exc() ([#345](https://github.com/Linuxfabrik/monitoring-plugins/issues/345))
* validate automatically converted python3 variants (before next release) ([#359](https://github.com/Linuxfabrik/monitoring-plugins/issues/359))
* wildfly-\*: Adapt source code to example ([#422](https://github.com/Linuxfabrik/monitoring-plugins/issues/422))
* wildfly-gc-status: Increase default values for [avr_gc_time` (`#307](https://github.com/Linuxfabrik/monitoring-plugins/issues/307))
* wildfly-gc-status: Refactor Check ([#308](https://github.com/Linuxfabrik/monitoring-plugins/issues/308))
* wildfly-memory-pool-usage: Don't alert on "PS_Survivor_Space" (if it exists) ([#286](https://github.com/Linuxfabrik/monitoring-plugins/issues/286))
* wordpress-version: Add a Python 3 version ([#382](https://github.com/Linuxfabrik/monitoring-plugins/issues/382))
* xca-cert: Add a Python 3 version ([#375](https://github.com/Linuxfabrik/monitoring-plugins/issues/375))


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


### Changed ("enhancement")

Monitoring Plugins:

* disk-io: Automatically determines the maximum possible disk throughput.
* file-\*: Deal directly with SMB/CIFS shares.
* ipmi-\*: Can now connect remotely to Supermicro's IPMI, HPE iLo and DELL iDRAC.


### Fixed ("bug")

* about-me: Add Django ([#196](https://github.com/Linuxfabrik/monitoring-plugins/issues/196))
* about-me: Add LibreNMS ([#195](https://github.com/Linuxfabrik/monitoring-plugins/issues/195))
* about-me: add more software ([#171](https://github.com/Linuxfabrik/monitoring-plugins/issues/171))
* about-me: Add mydumper ([#202](https://github.com/Linuxfabrik/monitoring-plugins/issues/202))
* about-me: Add Nikto ([#197](https://github.com/Linuxfabrik/monitoring-plugins/issues/197))
* about-me: add OpenSSL-version ([#164](https://github.com/Linuxfabrik/monitoring-plugins/issues/164))
* about-me: Add OpenVAS ([#194](https://github.com/Linuxfabrik/monitoring-plugins/issues/194))
* about-me: add tmate ([#175](https://github.com/Linuxfabrik/monitoring-plugins/issues/175))
* about-me: Disk sizes are not shown on CentOS ([#259](https://github.com/Linuxfabrik/monitoring-plugins/issues/259))
* about-me: Ignore zram Devices ([#227](https://github.com/Linuxfabrik/monitoring-plugins/issues/227))
* about-me: improve version checking ([#172](https://github.com/Linuxfabrik/monitoring-plugins/issues/172))
* about-me: Pruefung der installierten PHP Version erweitern ([#136](https://github.com/Linuxfabrik/monitoring-plugins/issues/136))
* about-me: Report CentOS Version in Perfdata ([#137](https://github.com/Linuxfabrik/monitoring-plugins/issues/137))
* about-me: Show "Local IP Address/Subnet" and "Public IP Address" ([#256](https://github.com/Linuxfabrik/monitoring-plugins/issues/256))
* Add port option to kemp-services ([#189](https://github.com/Linuxfabrik/monitoring-plugins/issues/189))
* All fortios-checks: Add the ability to specify a port ([#186](https://github.com/Linuxfabrik/monitoring-plugins/issues/186))
* All fortios-checks: HTTP-encode the password/access_token ([#187](https://github.com/Linuxfabrik/monitoring-plugins/issues/187))
* apache-httpd-status: Clean up code a little bit ([#200](https://github.com/Linuxfabrik/monitoring-plugins/issues/200))
* apache-httpd-status: Make "total accesses" human-readable ([#219](https://github.com/Linuxfabrik/monitoring-plugins/issues/219))
* apache-httpd-status: Struggles about html pages served via HTTP, containing "::" ([#199](https://github.com/Linuxfabrik/monitoring-plugins/issues/199))
* axenita-stats: add version number to perfdata ([#184](https://github.com/Linuxfabrik/monitoring-plugins/issues/184))
* cpu-usage:  Migrate top3-processes-which-consumed-the-most-cpu-time into cpu-usage ([#248](https://github.com/Linuxfabrik/monitoring-plugins/issues/248))
* cpu-usage: State in the README the different values" units ([#209](https://github.com/Linuxfabrik/monitoring-plugins/issues/209))
* disk-io: "State" belongs only to overusage of "RWx", so a separate column is misleading ([#279](https://github.com/Linuxfabrik/monitoring-plugins/issues/279))
* disk-io: If RW5 is < 0, set it to 0 ([#265](https://github.com/Linuxfabrik/monitoring-plugins/issues/265))
* disk-smart: Ignore zram Devices ([#221](https://github.com/Linuxfabrik/monitoring-plugins/issues/221))
* disk-smart: print "* sdc (model, ser) [CRIT]" instead of "* [CRIT] sdc (model, ser)" ([#214](https://github.com/Linuxfabrik/monitoring-plugins/issues/214))
* disk-smart: SyntaxError: invalid syntax, line 890 ([#220](https://github.com/Linuxfabrik/monitoring-plugins/issues/220))
* dmesg:  Use --ctime instead of --reltime ([#238](https://github.com/Linuxfabrik/monitoring-plugins/issues/238))
* dmesg: "kvm_set_msr_common: MSR_IA32_DEBUGCTLMSR" to ignore list ([#216](https://github.com/Linuxfabrik/monitoring-plugins/issues/216))
* dmesg: Add "CIFS VFS: Free previous auth_key.response = " to ignore list ([#192](https://github.com/Linuxfabrik/monitoring-plugins/issues/192))
* dmesg: Add "vcpu0 disabled perfctr wrmsr" to ignore list ([#270](https://github.com/Linuxfabrik/monitoring-plugins/issues/270))
* dmesg: add a Python 3 version ([#239](https://github.com/Linuxfabrik/monitoring-plugins/issues/239))
* dmesg: add severity parameter ([#115](https://github.com/Linuxfabrik/monitoring-plugins/issues/115))
* dmesg: Reduce the output to a maximum of ten lines ([#254](https://github.com/Linuxfabrik/monitoring-plugins/issues/254))
* dns: add a Python3 version ([#229](https://github.com/Linuxfabrik/monitoring-plugins/issues/229))
* docker-info: Byte-UOM must be "B", not "b" ([#180](https://github.com/Linuxfabrik/monitoring-plugins/issues/180))
* docker-info: perfdata "ram" must be in "bytes" (currently without any UOM) ([#179](https://github.com/Linuxfabrik/monitoring-plugins/issues/179))
* docker-stats: Byte-UOM must be "B", not "b" ([#181](https://github.com/Linuxfabrik/monitoring-plugins/issues/181))
* docker-stats: I/O values not usable ([#277](https://github.com/Linuxfabrik/monitoring-plugins/issues/277))
* docker-stats: Remove "host_mem_usage", because counting is wrong ([#276](https://github.com/Linuxfabrik/monitoring-plugins/issues/276))
* feed: Change behaviour ([#95](https://github.com/Linuxfabrik/monitoring-plugins/issues/95))
* feed: Change default behaviour and do not fetch feed items from the future ([#208](https://github.com/Linuxfabrik/monitoring-plugins/issues/208))
* feed: in Atom feed, try "content" field for summary is not available ([#207](https://github.com/Linuxfabrik/monitoring-plugins/issues/207))
* feed: sometimes runs into 10s Plugin Timeout in Icinga and gets killed with UNKNOWN ([#83](https://github.com/Linuxfabrik/monitoring-plugins/issues/83))
* feed: strip HTML from content ([#206](https://github.com/Linuxfabrik/monitoring-plugins/issues/206))
* file-descriptors: add a Python3 version ([#230](https://github.com/Linuxfabrik/monitoring-plugins/issues/230))
* file-descriptors: Migrate top3-processes-opening-more-file-descriptors into file-descriptors ([#247](https://github.com/Linuxfabrik/monitoring-plugins/issues/247))
* file-ownership: add a bunch of files according to CIS CentOS standard ([#233](https://github.com/Linuxfabrik/monitoring-plugins/issues/233))
* file-ownership: add a Python 3 version ([#232](https://github.com/Linuxfabrik/monitoring-plugins/issues/232))
* file-ownership: make the --filename parameter repeatable ([#6](https://github.com/Linuxfabrik/monitoring-plugins/issues/6))
* file-ownership: Print file, owner and group as table ([#231](https://github.com/Linuxfabrik/monitoring-plugins/issues/231))
* fs-file-usage: Does the same as file-descriptors, just in different way ([#234](https://github.com/Linuxfabrik/monitoring-plugins/issues/234))
* fs-inodes: add a Python 3 version ([#274](https://github.com/Linuxfabrik/monitoring-plugins/issues/274))
* fs-ro: add a Python 3 version ([#236](https://github.com/Linuxfabrik/monitoring-plugins/issues/236))
* fs-ro: Make --ignore parameter repeatable ([#235](https://github.com/Linuxfabrik/monitoring-plugins/issues/235))
* getent: add a Python 3 version ([#237](https://github.com/Linuxfabrik/monitoring-plugins/issues/237))
* haproxy-stats3: TypeError: a bytes-like object is required, not "str" ([#278](https://github.com/Linuxfabrik/monitoring-plugins/issues/278))
* implement  the \*_or_none arguments in the checks ([#116](https://github.com/Linuxfabrik/monitoring-plugins/issues/116))
* ipmi-sel: make it usable against targets over the network ([#169](https://github.com/Linuxfabrik/monitoring-plugins/issues/169))
* ipmi-sensors: make it usable against targets over the network ([#168](https://github.com/Linuxfabrik/monitoring-plugins/issues/168))
* librenms-version: KeyError: "local_branch" ([#204](https://github.com/Linuxfabrik/monitoring-plugins/issues/204))
* load: add a Python 3 version ([#240](https://github.com/Linuxfabrik/monitoring-plugins/issues/240))
* memory-usage: Migrate top3-processes-opening-more-file-descriptors completely into memory-usage ([#246](https://github.com/Linuxfabrik/monitoring-plugins/issues/246))
* memory-usage: unify v2 and v3 ([#245](https://github.com/Linuxfabrik/monitoring-plugins/issues/245))
* network-connections: unify v2 and v3 ([#250](https://github.com/Linuxfabrik/monitoring-plugins/issues/250))
* nextcloud-stats: num_users counts every user who ever existed ([#224](https://github.com/Linuxfabrik/monitoring-plugins/issues/224))
* nextcloud-version: Get apache user from owner of config/config.php ([#225](https://github.com/Linuxfabrik/monitoring-plugins/issues/225))
* nextcloud-version: Review handling of Enterprise Channel ([#142](https://github.com/Linuxfabrik/monitoring-plugins/issues/142))
* nginx-status: Make perfdata compatible to Prometheus ([#271](https://github.com/Linuxfabrik/monitoring-plugins/issues/271))
* php-fpm-status: Rename col "ContLen" to "POST" ([#211](https://github.com/Linuxfabrik/monitoring-plugins/issues/211))
* php-fpm-status: request duration is in us, not ms ([#210](https://github.com/Linuxfabrik/monitoring-plugins/issues/210))
* php-status: check status is printed without leading space ([#257](https://github.com/Linuxfabrik/monitoring-plugins/issues/257))
* php-status: Config and Module error message could be a little bit more precise ([#267](https://github.com/Linuxfabrik/monitoring-plugins/issues/267))
* php-status: Don't set WARN threshold for Hit Rate in Perfdata ([#251](https://github.com/Linuxfabrik/monitoring-plugins/issues/251))
* php-status: opcache_hit_rate - WARN and CRIT are swapped ([#226](https://github.com/Linuxfabrik/monitoring-plugins/issues/226))
* php-status: Remove "shmop" from default module list ([#215](https://github.com/Linuxfabrik/monitoring-plugins/issues/215))
* php-status: Remove "zip" from default module list ([#266](https://github.com/Linuxfabrik/monitoring-plugins/issues/266))
* pip-updates: Change "No venv." in "Not running in a venv." ([#268](https://github.com/Linuxfabrik/monitoring-plugins/issues/268))
* procs: Always return perfdata for process memory usage ([#264](https://github.com/Linuxfabrik/monitoring-plugins/issues/264))
* procs: checking processes on CPU usage is wrong ([#260](https://github.com/Linuxfabrik/monitoring-plugins/issues/260))
* procs: Improve output a little bit ([#255](https://github.com/Linuxfabrik/monitoring-plugins/issues/255))
* procs: Make filter for username, procname and arguments case-insensitive. ([#261](https://github.com/Linuxfabrik/monitoring-plugins/issues/261))
* procs: several unknowns and tracebacks ([#162](https://github.com/Linuxfabrik/monitoring-plugins/issues/162))
* procs: Show used filter in output ([#263](https://github.com/Linuxfabrik/monitoring-plugins/issues/263))
* procs: Some comments are wrong ([#262](https://github.com/Linuxfabrik/monitoring-plugins/issues/262))
* procs: Traceback ([#166](https://github.com/Linuxfabrik/monitoring-plugins/issues/166))
* rpm-lastactivity: add a Python 3 version ([#241](https://github.com/Linuxfabrik/monitoring-plugins/issues/241))
* selinux-mode: add a Python 3 version ([#275](https://github.com/Linuxfabrik/monitoring-plugins/issues/275))
* swap-usage: add a Python 3 version ([#242](https://github.com/Linuxfabrik/monitoring-plugins/issues/242))
* systemd-unit: add a Python 3 version ([#243](https://github.com/Linuxfabrik/monitoring-plugins/issues/243))
* systemd-units-failed: add a Python 3 version ([#244](https://github.com/Linuxfabrik/monitoring-plugins/issues/244))
* top3-processes-which-caused-the-most-io: add a Python 3 version ([#273](https://github.com/Linuxfabrik/monitoring-plugins/issues/273))
* users:  "utf-8" codec can't decode byte 0x81 on Windows ([#201](https://github.com/Linuxfabrik/monitoring-plugins/issues/201))
* wildfly-gc-status: collection-time and -count in perfdata are continous counters ([#185](https://github.com/Linuxfabrik/monitoring-plugins/issues/185))
* wildfly-memory-pool-usage: Refactor code to better distinguish between heap and non-heap ([#183](https://github.com/Linuxfabrik/monitoring-plugins/issues/183))


### Removed

* Three of the four "Top 3" checks are merged into cpu-usage, file-descriptros  and memory-usage.



## 2021021701 - 2021-02-17

### Fixed ("bug")

Monitoring Plugins:

* virtualenv is not activated if the plugin is called using an absolute path / from a different directory ([#154](https://github.com/Linuxfabrik/monitoring-plugins/issues/154))



## 2021021601 - 2021-02-16

### Added

Features:

* Added support for using a virtual environment (see README)


### Changed ("enhancement")

Monitoring Plugins:

* file-age, file-count & file-size: Now support SMB.
* users: Added missing perfdata for Windows.
* nextcloud-version: throw UNKNOWN if update server is not available ([#147](https://github.com/Linuxfabrik/monitoring-plugins/issues/147))
* nextcloud-version: increase timeout for fetching the update server ([#148](https://github.com/Linuxfabrik/monitoring-plugins/issues/148))
* procs: added thresholds for cpu & memory

### Fixed ("bug")

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


### Changed ("enhancement")

Monitoring Plugins:

* file-age: Now support globbing for selecting multiple files.
* file-size: Now support globbing for selecting multiple files.
* updates: Added the --always-ok parameter.


### Fixed

* users: Fixed the counting of user under Windows (it also includes disconnected users now)




## 2020112001 - 2020-11-20

### Changed ("enhancement")

Monitoring Plugins:

* systemd-unit: added more states



## 2020111901 - 2020-11-19

### Fixed ("bug")

Monitoring Plugins:

* ntp-offset: error on server without ntp ([#138](https://github.com/Linuxfabrik/monitoring-plugins/issues/138))



## 2020111801 - 2020-11-18

### Added

Features:

* Added sudoers for Debian 9 and 10


### Fixed ("bug")

Monitoring Plugins:

* dns: traceback ([#132](https://github.com/Linuxfabrik/monitoring-plugins/issues/132))
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


### Changed ("enhancement")

Features:

* We unified all the sudoers into one file (for each OS), in the assets/sudoers folder.

Monitoring Plugins:

* borgbackup: changed the expected string in the logfile from rc to retc.
* feed: removed --no-icinga-callback, added --icinga-callback.
* procs: new --argument parameter.


### Fixed ("bug")

Monitoring Plugins:

* feed: python traceback ([#107](https://github.com/Linuxfabrik/monitoring-plugins/issues/107))
* memory-usage: Print top3 memory consuming processes in case of WARN/CRIT ([#108](https://github.com/Linuxfabrik/monitoring-plugins/issues/108))
* ntp-offset: add systemd-timesyncd ([#90](https://github.com/Linuxfabrik/monitoring-plugins/issues/90))
* openvpn-client-list: output as table ([#19](https://github.com/Linuxfabrik/monitoring-plugins/issues/19))
* qts-version: "None" after update ([#112](https://github.com/Linuxfabrik/monitoring-plugins/issues/112))
* xca-cert: Print a list of all checked certs with "commonName, CA (y/n), Serial, Expiry date" starting at the second line ([#65](https://github.com/Linuxfabrik/monitoring-plugins/issues/65))



## 2020061901 - 2020-06-19

### Added

Monitoring Plugins:

* network-bonding


### Changed ("enhancement")

Monitoring Plugins:

* procs: new username parameter


### Fixed ("bug")

Monitoring Plugins:

* nextcloud-version: AttributeError: NoneType object has no attribute group ([#105](https://github.com/Linuxfabrik/monitoring-plugins/issues/105))



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


### Changed ("enhancement")

Features:

* Most of the checks now also run on Ubuntu Server 16+.
* On stack traces, any token and password URL request parameters are now printed with asterisks.
* All checks calling shell commands force english output even if system locale is different.


### Fixed ("bug")

Monitoring Plugins:

* disk-smart: Traceback if not running on hardware ([#82](https://github.com/Linuxfabrik/monitoring-plugins/issues/82))
* disk-io: Counts n loop Devices on Ubuntu 20 ([#87](https://github.com/Linuxfabrik/monitoring-plugins/issues/87))
* disk-usage: ignore snap Devices ([#88](https://github.com/Linuxfabrik/monitoring-plugins/issues/88))
* mailq: Test with Exim ([#93](https://github.com/Linuxfabrik/monitoring-plugins/issues/93))
* procs: total proc count in perfdata is always 0 ([#96](https://github.com/Linuxfabrik/monitoring-plugins/issues/96))
* apache-httpd-status: Traceback on Ubuntu 16 ([#97](https://github.com/Linuxfabrik/monitoring-plugins/issues/97))
* disk-io: Traceback on Ubuntu 16 ([#98](https://github.com/Linuxfabrik/monitoring-plugins/issues/98))
* nextcloud-version: Don't throw UNKNOWN if update server is not available, because it doesn't help at all ([#99](https://github.com/Linuxfabrik/monitoring-plugins/issues/99))
* disk-usage: ignore iso9660 devices ([#100](https://github.com/Linuxfabrik/monitoring-plugins/issues/100))
* apache-httpd-status: Report if server-info is malformed due to any reason ([#101](https://github.com/Linuxfabrik/monitoring-plugins/issues/101))
* sensors-temperature: Ignore psutil's IOError ([#102](https://github.com/Linuxfabrik/monitoring-plugins/issues/102))



## 2020042001 - 2020-04-20

### Added

Features:

* Most of the checks now also run on Ubuntu (tested on Ubuntu Server 20 Beta).

Monitoring Plugins:

* dns
* fah-stats


### Fixed ("bug")

Monitoring Plugins:

* nextcloud-security-scan: missing urllib ([#91](https://github.com/Linuxfabrik/monitoring-plugins/issues/91))
* about-me: doesn't report details about NVMe disks ([#89](https://github.com/Linuxfabrik/monitoring-plugins/issues/89))
* ping: no duplicate Output; maybe switch to regex ([#84](https://github.com/Linuxfabrik/monitoring-plugins/issues/84))



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

### Changed ("enhancement")

Monitoring Plugins:

* cpu-usage: Adjusted to changes in psutil
* dmesg: expanded the ignore list
* systemd-unit: improved output



## 2020022801 - 2020-02-28

Initial release for the general public.


[Unreleased]: https://github.com/Linuxfabrik/monitoring-plugins/compare/v2.2.1...HEAD
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
