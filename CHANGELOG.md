# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project does NOT adhere to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [Unreleased]

### Breaking Changes

*  wildfly-memory-pool-usage: Flapping PS_Eden_Space reporting ([fix #563](https://github.com/Linuxfabrik/monitoring-plugins/issues/563)) - Removed `--warning` and `--critical` parameters (not needed anymore)


### Added

New features:

* This CHANGELOG.
* Add hidden `.windows` files as indication for automatic compilation on/for Windows systems
* Add lib/distro3.py
* Add sudoers file for Fedora 35 and Fedora 36
* Icinga: duplicity Service Set
* New check diacos ([PR #567](https://github.com/Linuxfabrik/monitoring-plugins/pull/567))
* New check infomaniak-swiss-backup-devices
* New check infomaniak-swiss-backup-products
* New check mysql-aria
* New check mysql-binlog-cache
* New check mysql-connections
* New check mysql-innodb-buffer-pool-instances
* New check mysql-innodb-buffer-pool-size
* New check mysql-innodb-log-waits
* New check mysql-joins
* New check mysql-logfile
* New check mysql-memory
* New check mysql-open-files
* New check mysql-slow-queries
* New check mysql-sorts
* New check mysql-system
* New check mysql-table-cache
* New check mysql-table-definition-cache
* New check mysql-temp-tables
* New check mysql-thread-cache
* New check mysql-traffic
* New check strongswan-connections
* New check xml ([PR #583](https://github.com/Linuxfabrik/monitoring-plugins/pull/583) for "wsdl" check; enhanced and renamed to "xml")


### Changed

Changes in existing functionality:

* about-me: Add AIDE ([fix #546](https://github.com/Linuxfabrik/monitoring-plugins/issues/546))
* about-me: Add Birthdate ([fix #554](https://github.com/Linuxfabrik/monitoring-plugins/issues/554))
* about-me: Add certbot and acme.sh ([fix #433](https://github.com/Linuxfabrik/monitoring-plugins/issues/433))
* about-me: Add gpg ([fix #511](https://github.com/Linuxfabrik/monitoring-plugins/issues/511))
* about-me: Add list of listening ports ([fix #538](https://github.com/Linuxfabrik/monitoring-plugins/issues/538))
* about-me: Add mod_security ([fix #496](https://github.com/Linuxfabrik/monitoring-plugins/issues/496))
* about-me: Add swanctl ([fix #575](https://github.com/Linuxfabrik/monitoring-plugins/issues/575))
* about-me: Print its own version ([fix #439](https://github.com/Linuxfabrik/monitoring-plugins/issues/439))
* about-me: Report active tuned-Profile in first line if tuned.service is found and running ([fix #374](https://github.com/Linuxfabrik/monitoring-plugins/issues/374))
* about-me: Report Boot Mode ([fix #562](https://github.com/Linuxfabrik/monitoring-plugins/issues/562)) 
* about-me: Show key features of the Machine ([fix #561](https://github.com/Linuxfabrik/monitoring-plugins/issues/561))
* All checks using SQLite databases: More unique sqlite db names ([fix #333](https://github.com/Linuxfabrik/monitoring-plugins/issues/333))
* apache-httpd-status: New parameter `--insecure`
* cpu-usage: Subtract the "nice" percentage from thresholds ([fix #550](https://github.com/Linuxfabrik/monitoring-plugins/issues/550))
* dhcp-scope-usage: Parse PercentageInUse locale-aware ([PR #551](https://github.com/Linuxfabrik/monitoring-plugins/pull/551))
* disk-io: Checks if psutil has a certain minimum version on systems with kernel 4.18+.
* disk-smart: Exclude zfs-volumes ([PR #539](https://github.com/Linuxfabrik/monitoring-plugins/pull/539))
* disk-smart: Now also runs on Windows ([PR #553](https://github.com/Linuxfabrik/monitoring-plugins/pull/553))
* disk-smart: Properly handle Power_On_Hours_and_Msec attribute perfdata parsing ([PR #549](https://github.com/Linuxfabrik/monitoring-plugins/pull/549))
* disk-usage: Critical but first line of plugin output prints "OK" ([fix #545](https://github.com/Linuxfabrik/monitoring-plugins/issues/545))
* docker-info: Raise CRIT on return code != 0 ([fix #569](https://github.com/Linuxfabrik/monitoring-plugins/issues/569))
* docker-stats: Improve handling of container names ([fix #586](https://github.com/Linuxfabrik/monitoring-plugins/issues/586)). New parameter `--full-name`.
* file-age: Improve perfdata labels
* file-age: Performance data aggregation on file_age check ([PR #544](https://github.com/Linuxfabrik/monitoring-plugins/pull/544))
* file-age: shorten the message ([fix #559](https://github.com/Linuxfabrik/monitoring-plugins/issues/559))
* infomaniak-swiss-backup-devices3: Increase default thresholds from 80/90% to 90/95%
* infomaniak-swiss-backup-devices3: Sort output table by "Tags" column
* infomaniak-swiss-backup-products3: Changed thresholds from 14/5 days to 6/3 days
* infomaniak-swiss-backup-products3: Sort output table by "Tags" column
* needs-restarting3: Debian Buster/bullseye command not found ([fix #572](https://github.com/Linuxfabrik/monitoring-plugins/issues/572))
* php-status: Add a "--dev" switch to not warn on display_errors=On and display_startup_errors=On ([fix #461](https://github.com/Linuxfabrik/monitoring-plugins/issues/461))
* php-status: Change behavior when handling default values ([fix #540](https://github.com/Linuxfabrik/monitoring-plugins/issues/540))
* qts-\*: Increase default connect timeout from 3 to 6 seconds
* systemd-units-failed: Allow wildcards for the `--ignore` parameter ([fix #542](https://github.com/Linuxfabrik/monitoring-plugins/issues/542))

* lib/cache3.py: Use more unique default names for sqlite databases
* lib/db_mysql3.py: Enhanced for new mysql-checks
* lib/db_mysql3.py: Switch from mysql.connector to PyMySQL  ([fix #570](https://github.com/Linuxfabrik/monitoring-plugins/issues/570))
* lib/db_mysql3.py: Use more unique default names for sqlite databases
* lib/disk3.py: Add file_exists() function
* Icinga: Adjust windows director definitions to the new folder structure
* Icinga: Increase windows service check intervals
* Revert Python 3.6+ `f`-strings to use `.format()` to be more conservative


### Fixed

Bug fixes:

* disk-io3: Fix python3 lib calls
* file-count3: Traceback: KeyError: 'lib'  ([fix #591](https://github.com/Linuxfabrik/monitoring-plugins/issues/591))
* ipmi-sel: Change the order of events ([fix #558](https://github.com/Linuxfabrik/monitoring-plugins/issues/558))
* logfile3: "Database locked" and "UNKNOWN" in case of massive usage on a host ([fix #578](https://github.com/Linuxfabrik/monitoring-plugins/issues/578))
* keycloak-version3: AttributeError: 'NoneType' object has no attribute 'group' ([fix #555](https://github.com/Linuxfabrik/monitoring-plugins/issues/555))
* xca-cert3: Checks expiry date again


### Removed

For now removed features:

* Icinga: Remove gpsvc on windows



[Unreleased]: https://github.com/Linuxfabrik/monitoring-plugins/compare/2022030201...HEAD
