# The Linuxfabrik Monitoring Plugins Collection

![image](https://download.linuxfabrik.ch/monitoring-plugins/assets/img/linuxfabrik-monitoring-check-plugins-teaser.png)

This Enterprise Class Check Plugin Collection made by [Linuxfabrik](https://www.linuxfabrik.ch) offers a package of 200+ Python-based, Nagios-compatible check plugins for Icinga, Naemon, Nagios, OP5, Shinken, Sensu and other monitoring applications. Each plugin is a stand-alone command line tool that provides a specific type of check. Typically, your monitoring software will run these check plugins to determine the current status of hosts and services on your network.

The check plugins run on

* Linux - Tested on RHEL 7+, Fedora 30+, Ubuntu Server 16+, Debian 9+, SLES 15+
* Windows - Tested on Windows 10+ and Windows Server 2019+

All plugins are written in Python and licensed under the [UNLICENSE](https://unlicense.org/), which is a license with no conditions whatsoever that dedicates works to the public domain.

The plugins are fast, reliable and use as few system resources as possible. They uniformly and consistently report the same metrics briefly and precisely on all platforms (for example, always "used" instead of a mixture of "used" and "free"). Automatic detection and Auto-Discovery mechanisms are built-in where possible. Using meaningful default settings, the plugins trigger WARNs and CRITs only where absolutely necessary. In addition they provide information for troubleshooting. We try to avoid dependencies on 3rd party system libraries where possible.


## Support & Sponsoring

The source code is published here without support. If you need Enterprise Support, [conclude a Service Contract](https://www.linuxfabrik.ch/en/products/service-support).

If you simply like to support our work, please consider donating and become a sponsor:

* [![GitHubSponsors](https://img.shields.io/github/sponsors/Linuxfabrik?label=GitHub%20Sponsors)](https://github.com/sponsors/Linuxfabrik)
* [![PayPal](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=7AW3VVX62TR4A&source=url)

Do you think more people should know about it? Sharing is caring, so feel free to spread the word. We would really appreciate if you share this on any social media, or link this site on any blog or forum. Or more specifically: [It would be great if you could tell on GitHub discussions how you use the plugins](https://github.com/Linuxfabrik/monitoring-plugins/discussions/categories/show-and-tell?discussions_q=is%3Aopen+category%3A%22Show+and+tell%22).


## Installation

* Have a look at the [INSTALL](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/INSTALL.rst) document for the various options, including SELinux etc.
* For details on installing the plugins in Icinga Director, see [ICINGA](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/ICINGA.rst).


## Reporting Issues

For now, there are two ways:

1.  [Submit an issue](https://github.com/Linuxfabrik/monitoring-plugins/issues/new/choose) (preferred).
2.  [Contact us](https://www.linuxfabrik.ch/en/contact) by email or web form and describe your problem.


## Check Plugin Poster

See some of our check plugins at a glance on an Icinga server:

<img alt="about-me" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/about-me.png" width="30%"/> &nbsp;
<img alt="apache-httpd-status" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/apache-httpd-status.png" width="30%"/> &nbsp;
<img alt="apache-httpd-version" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/apache-httpd-version.png" width="30%"/> &nbsp;
<img alt="apache-solr-version" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/apache-solr-version.png" width="30%"/> &nbsp;
<img alt="cpu-usage" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/cpu-usage.png" width="30%"/> &nbsp;
<img alt="crypto-policy" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/crypto-policy.png" width="30%"/> &nbsp;
<img alt="disk-io" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/disk-io.png" width="30%"/> &nbsp;
<img alt="disk-usage" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/disk-usage.png" width="30%"/> &nbsp;
<img alt="dmesg" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/dmesg.png" width="30%"/> &nbsp;
<img alt="dns" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/dns.png" width="30%"/> &nbsp;
<img alt="fail2ban" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/fail2ban.png" width="30%"/> &nbsp;
<img alt="file-age" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/file-age.png" width="30%"/> &nbsp;
<img alt="file-count" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/file-count.png" width="30%"/> &nbsp;
<img alt="file-descriptors" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/file-descriptors.png" width="30%"/> &nbsp;
<img alt="file-ownership" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/file-ownership.png" width="30%"/> &nbsp;
<img alt="file-size" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/file-size.png" width="30%"/> &nbsp;
<img alt="fs-inodes" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/fs-inodes.png" width="30%"/> &nbsp;
<img alt="fs-ro" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/fs-ro.png" width="30%"/> &nbsp;
<img alt="githubstatus" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/githubstatus.png" width="30%"/> &nbsp;
<img alt="gitlab-health" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/gitlab-health.png" width="30%"/> &nbsp;
<img alt="gitlab-liveness" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/gitlab-liveness.png" width="30%"/> &nbsp;
<img alt="gitlab-readiness" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/gitlab-readiness.png" width="30%"/> &nbsp;
<img alt="gitlab-version" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/gitlab-version.png" width="30%"/> &nbsp;
<img alt="grafana-version" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/grafana-version.png" width="30%"/> &nbsp;
<img alt="infomaniak-events" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/infomaniak-events.png" width="30%"/> &nbsp;
<img alt="infomaniak-swiss-backp-devices" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/infomaniak-swiss-backp-devices.png" width="30%"/> &nbsp;
<img alt="infomaniak-swiss-backup-products" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/infomaniak-swiss-backup-products.png" width="30%"/> &nbsp;
<img alt="journald-query" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/journald-query.png" width="30%"/> &nbsp;
<img alt="journald-usage" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/journald-usage.png" width="30%"/> &nbsp;
<img alt="keycloak-version" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/keycloak-version.png" width="30%"/> &nbsp;
<img alt="kvm-vm" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/kvm-vm.png" width="30%"/> &nbsp;
<img alt="librenms-alerts" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/librenms-alerts.png" width="30%"/> &nbsp;
<img alt="librenms-health" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/librenms-health.png" width="30%"/> &nbsp;
<img alt="librenms-version" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/librenms-version.png" width="30%"/> &nbsp;
<img alt="load" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/load.png" width="30%"/> &nbsp;
<img alt="mailq" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/mailq.png" width="30%"/> &nbsp;
<img alt="matomo-version" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/matomo-version.png" width="30%"/> &nbsp;
<img alt="memory-usage" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/memory-usage.png" width="30%"/> &nbsp;
<img alt="mydumper-version" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/mydumper-version.png" width="30%"/> &nbsp;
<img alt="mysql-aria" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/mysql-aria.png" width="30%"/> &nbsp;
<img alt="mysql-connections" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/mysql-connections.png" width="30%"/> &nbsp;
<img alt="mysql-database-metrics" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/mysql-database-metrics.png" width="30%"/> &nbsp;
<img alt="mysql-innodb-buffer-pool-instances" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/mysql-innodb-buffer-pool-instances.png" width="30%"/> &nbsp;
<img alt="mysql-innodb-buffer-pool-size" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/mysql-innodb-buffer-pool-size.png" width="30%"/> &nbsp;
<img alt="mysql-innodb-log-waits" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/mysql-innodb-log-waits.png" width="30%"/> &nbsp;
<img alt="mysql-joins" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/mysql-joins.png" width="30%"/> &nbsp;
<img alt="mysql-logfile" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/mysql-logfile.png" width="30%"/> &nbsp;
<img alt="mysql-memory" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/mysql-memory.png" width="30%"/> &nbsp;
<img alt="mysql-open-files" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/mysql-open-files.png" width="30%"/> &nbsp;
<img alt="mysql-perf-metrics" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/mysql-perf-metrics.png" width="30%"/> &nbsp;
<img alt="mysql-slow-queries" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/mysql-slow-queries.png" width="30%"/> &nbsp;
<img alt="mysql-sorts" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/mysql-sorts.png" width="30%"/> &nbsp;
<img alt="mysql-storage-engines" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/mysql-storage-engines.png" width="30%"/> &nbsp;
<img alt="mysql-system" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/mysql-system.png" width="30%"/> &nbsp;
<img alt="mysql-table-cache" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/mysql-table-cache.png" width="30%"/> &nbsp;
<img alt="mysql-table-definition-cache" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/mysql-table-definition-cache.png" width="30%"/> &nbsp;
<img alt="mysql-table-indexes" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/mysql-table-indexes.png" width="30%"/> &nbsp;
<img alt="mysql-table-locks" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/mysql-table-locks.png" width="30%"/> &nbsp;
<img alt="mysql-temp-tables" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/mysql-temp-tables.png" width="30%"/> &nbsp;
<img alt="mysql-thread-cache" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/mysql-thread-cache.png" width="30%"/> &nbsp;
<img alt="mysql-traffic" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/mysql-traffic.png" width="30%"/> &nbsp;
<img alt="mysql-user-security" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/mysql-user-security.png" width="30%"/> &nbsp;
<img alt="mysql-version" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/mysql-version.png" width="30%"/> &nbsp;
<img alt="network-connections" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/network-connections.png" width="30%"/> &nbsp;
<img alt="network-io" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/network-io.png" width="30%"/> &nbsp;
<img alt="network-port-tcp" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/network-port-tcp.png" width="30%"/> &nbsp;
<img alt="nextcloud-security-scan" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/nextcloud-security-scan.png" width="30%"/> &nbsp;
<img alt="nextcloud-stats" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/nextcloud-stats.png" width="30%"/> &nbsp;
<img alt="nextcloud-version" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/nextcloud-version.png" width="30%"/> &nbsp;
<img alt="ntp-chronyd" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/ntp-chronyd.png" width="30%"/> &nbsp;
<img alt="openstack-nova-list" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/openstack-nova-list.png" width="30%"/> &nbsp;
<img alt="openstack-swift-stat" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/openstack-swift-stat.png" width="30%"/> &nbsp;
<img alt="openvpn-client-list" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/openvpn-client-list.png" width="30%"/> &nbsp;
<img alt="path-rw-test" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/path-rw-test.png" width="30%"/> &nbsp;
<img alt="php-fpm-ping" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/php-fpm-ping.png" width="30%"/> &nbsp;
<img alt="php-fpm-status" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/php-fpm-status.png" width="30%"/> &nbsp;
<img alt="php-status" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/php-status.png" width="30%"/> &nbsp;
<img alt="php-version" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/php-version.png" width="30%"/> &nbsp;
<img alt="ping" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/ping.png" width="30%"/> &nbsp;
<img alt="postfix-version" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/postfix-version.png" width="30%"/> &nbsp;
<img alt="procs" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/procs.png" width="30%"/> &nbsp;
<img alt="redis-status" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/redis-status.png" width="30%"/> &nbsp;
<img alt="redis-version" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/redis-version.png" width="30%"/> &nbsp;
<img alt="rhel-version" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/rhel-version.png" width="30%"/> &nbsp;
<img alt="rocketchat-stats" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/rocketchat-stats.png" width="30%"/> &nbsp;
<img alt="rocketchat-version" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/rocketchat-version.png" width="30%"/> &nbsp;
<img alt="rpm-lastactivity" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/rpm-lastactivity.png" width="30%"/> &nbsp;
<img alt="selinux-mode" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/selinux-mode.png" width="30%"/> &nbsp;
<img alt="service" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/service.png" width="30%"/> &nbsp;
<img alt="starface-account-stats" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/starface-account-stats.png" width="30%"/> &nbsp;
<img alt="starface-backup-status" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/starface-backup-status.png" width="30%"/> &nbsp;
<img alt="starface-channel-status" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/starface-channel-status.png" width="30%"/> &nbsp;
<img alt="starface-database-stats" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/starface-database-stats.png" width="30%"/> &nbsp;
<img alt="starface-java-memory-usage" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/starface-java-memory-usage.png" width="30%"/> &nbsp;
<img alt="starface-peer-stats" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/starface-peer-stats.png" width="30%"/> &nbsp;
<img alt="starface-status" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/starface-status.png" width="30%"/> &nbsp;
<img alt="statuspal" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/statuspal.png" width="30%"/> &nbsp;
<img alt="swap-usage" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/swap-usage.png" width="30%"/> &nbsp;
<img alt="systemd-unit" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/systemd-unit.png" width="30%"/> &nbsp;
<img alt="systemd-units-failed" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/systemd-units-failed.png" width="30%"/> &nbsp;
<img alt="tuned-profile" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/tuned-profile.png" width="30%"/> &nbsp;
<img alt="updates" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/updates.png" width="30%"/> &nbsp;
<img alt="uptime" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/uptime.png" width="30%"/> &nbsp;
<img alt="users" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/users.png" width="30%"/> &nbsp;
<img alt="wildfly-deployment-status" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/wildfly-deployment-status.png" width="30%"/> &nbsp;
<img alt="wildfly-gc-status" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/wildfly-gc-status.png" width="30%"/> &nbsp;
<img alt="wildfly-memory-pool-usage" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/wildfly-memory-pool-usage.png" width="30%"/> &nbsp;
<img alt="wildfly-memory-usage" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/wildfly-memory-usage.png" width="30%"/> &nbsp;
<img alt="wildfly-non-xa-datasource-stats" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/wildfly-non-xa-datasource-stats.png" width="30%"/> &nbsp;
<img alt="wildfly-server-status" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/wildfly-server-status.png" width="30%"/> &nbsp;
<img alt="wildfly-thread-usage" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/wildfly-thread-usage.png" width="30%"/> &nbsp;
<img alt="wildfly-uptime" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/wildfly-uptime.png" width="30%"/> &nbsp;
<img alt="wildfly-xa-datasources-stats" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/wildfly-xa-datasources-stats.png" width="30%"/> &nbsp;
<img alt="wordpress-version" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/wordpress-version.png" width="30%"/> &nbsp;
<img alt="xca-cert" src="https://download.linuxfabrik.ch/monitoring-plugins/screenshots/xca-cert.png" width="30%"/> &nbsp;

If you zoom in, for example on *CPU Usage*:

![image](https://download.linuxfabrik.ch/monitoring-plugins/assets/img/linuxfabrik-monitoring-check-plugins-cpu-usage.png)


## Feedback from our Community

Some comments from the community about our monitoring plugins:

> Thanks again @linuxfabrik for writing the csv-values check the way you did and not what I originally requested ;-)

-- [Dominik Riva](https://community.icinga.com/t/monitor-ldap-queries-on-active-directory-controllers/13066)


> ... the Linuxfabrik-Monitoring-Plugins are great, thanks for your effort, we are using them very much.

-- [Patric Stiffel](https://github.com/edpstiffel)


> ... thanks for your awesome plugins.

-- [Robert Christian](https://github.com/soulsymphonies)


> ... Thanks for your awesome work & have a good day.

-- [\Barney](https://github.com/bangerer)


> ... the Linux fabrik plugins are excellent.

-- [u/exekewtable@reddit](https://www.reddit.com/r/icinga/comments/xq9jt6/does_somebody_know_a_plugin_like_check_interfaces/)


> ... I can recommend this family of plugins, they are the highest quality I have seen around. ...

-- [u/exekewtable@reddit](https://www.reddit.com/r/icinga/comments/xcewsg/icinga_python_script_for_qradar_log_source/)


> Ich bin vor kurzem (via Video vom Icinga Camp) über Eure Monitoringplugins gestolpert. Ganz herzlichen Dank dafür, großartige Arbeit!!

-- Christian Lox


> ... many thanks for your great collection of monitoring plugins! I've just found them - clean structure and output, cross-platform, Icinga Directory Basket configurations - loving it and currently migrating step by step most of my checks to use them where possible. 😍

-- [Bernd Bestel](https://github.com/berrnd)


> Nachdem ich beim Versuch, Nagios-Plugins auf VMwares Photon-OS zum laufen zu kriegen, graue Haare gekriegt habe, haben mir eure Plugins zum Ziel verholfen.

-- [MajorTwip](https://twitter.com/MajorTwip)


> A well engineered, regularly updated and maintained collection of plugins. Specially focused on Linux servers/VMs and used at large scale by the company developing it.

-- [straessler](https://exchange.icinga.com/straessler)


> Hello, I stumbled across your collection and am thrilled! Especially the extensive documentary and the Director Baskets are a dream.

-- Stefan Beining


## Merchandise! ;-)

The "Linuxfabrik Monitoring Plugins" on a card of our popular Open Source Quartet from 2023 🙂. Sold out, but there's still more to discover in the [Linuxfabrik Spreadshop](https://www.linuxfabrik.ch/en/about-us/merch).

[![image](https://download.linuxfabrik.ch/monitoring-plugins/assets/img/linuxfabrik-monitoring-check-quartets-card-2023.png)](https://ws.linuxfabrik.io/index.php/store/diverses/linuxfabrik-open-source-quartett-2023)


## Human Readable Numbers

Regarding the check plugin output, this is how we convert and append symbols to large numbers in a human-readable format (according to Wikipedia [Names of large numbers](https://en.wikipedia.org/w/index.php?title=Names_of_large_numbers&section=5#Extensions_of_the_standard_dictionary_numbers), and other).

Since the primary hosting platform is Linux, which uses IEC, the plugins display byte sizes in powers of 2 (KiB, MiB, GiB etc.) - otherwise it would be very confusing to have the monitoring plugins said something different than the command line.

| Value             | Symbol   | Origin       | Type              | Description |
| ----------------- | -------- | ------------ | ----------------- | --------------------------------- |
| 1000\^1           | K        |              | Number            | Thousand |
| 1000\^2           | M        | SI Symbol    | Number            | Million (1), Million (2) |
| 1000\^3           | G        | SI Symbol    | Number            | Milliard (1), Billion (2) |
| 1000\^4           | T        | SI Symbol    | Number            | Billion (1), Trillion (2) |
| 1000\^5           | P        | SI Symbol    | Number            | Billiard (1), Quadrillion (2) |
| 1000\^6           | E        | SI Symbol    | Number            | Trillion (1), Quintillion (2) |
| 1000\^7           | Z        | SI Symbol    | Number            | Trilliard (1), Sextillion (2) |
| 1000\^8           | Y        | SI Symbol    | Number            | Quadrillion (1), Septillion (2) |
| 1024\^0           | B        |              | Bytes             | Bytes |
| 1024\^1           | KiB      | IEC unit     | Bytes             | Kibibytes |
| 1024\^2           | MiB      | IEC unit     | Bytes             | Mebibytes |
| 1024\^3           | GiB      | IEC unit     | Bytes             | Gibibytes |
| 1024\^4           | TiB      | IEC unit     | Bytes             | Tebibytes |
| 1024\^5           | PiB      | IEC unit     | Bytes             | Pebibytes |
| 1024\^6           | EiB      | IEC unit     | Bytes             | Exbibytes |
| 1024\^7           | ZiB      | IEC unit     | Bytes             | Zebibytes |
| 1024\^8           | YiB      | IEC unit     | Bytes             | Yobibytes |
| 1000\^1           | KB       |              | Bytes             | Kilobytes |
| 1000\^2           | MB       |              | Bytes             | Megabytes |
| 1000\^3           | GB       |              | Bytes             | Gigabytes |
| 1000\^4           | TB       |              | Bytes             | Terrabytes |
| 1000\^5           | PB       |              | Bytes             | Petabytes |
| 1000\^6           | EB       |              | Bytes             | Exabytes |
| 1000\^7           | ZB       |              | Bytes             | Zetabytes |
| 1000\^8           | YB       |              | Bytes             | Yottabytes |
| 1000\^1           | Kbps     |              | Bits per Second   | Kilobits |
| 1000\^2           | Mbps     |              | Bits per Second   | Megabits |
| 1000\^3           | Gbps     |              | Bits per Second   | Gigabits |
| 1000\^4           | Tbps     |              | Bits per Second   | Terrabits |
| 1000\^5           | Pbps     |              | Bits per Second   | Petabits |
| 1000\^6           | Ebps     |              | Bits per Second   | Exabits |
| 1000\^7           | Zbps     |              | Bits per Second   | Zetabits |
| 1000\^8           | Ybps     |              | Bits per Second   | Yottabits |
| 1e-12             | ps       |              | Time              | Picoseconds |
| 1e-9              | ns       |              | Time              | Nanoseconds |
| 1e-6              | us       |              | Time              | Microseconds |
| 1e-3              | ms       |              | Time              | Milliseconds |
| 1..59             | s        |              | Time              | Seconds |
| 60                | m        |              | Time              | Minutes |
| 60\*60            | h        |              | Time              | Hours |
| 60\*60\*24        | D        |              | Time              | Days |
| 60\*60\*24\*7     | W        |              | Time              | Weeks |
| 60\*60\*24\*30    | M        |              | Time              | Months |
| 60\*60\*24\*365   | Y        |              | Time              | Years |

* (1): Traditional European (Peletier, long scale)
* (2): US, Canada and modern British (short scale)


## Threshold and Ranges

If a check supports Nagios ranges, they can be used as follows:

* Simple value: A range from 0 up to and including the value.
* A "Range" is the same as on [nagios-plugins.org](https://nagios-plugins.org/doc/guidelines.html#THRESHOLDFORMAT): *... defined as a start and end point (inclusive) on a numeric scale (possibly negative or positive infinity).*, in the format `start:end`.
* Empty value after `:`: Positive infinity.
* `~`: Negative infinity.
* `@`: Like a NOT for the whole expression. So if range starts with `@`, then alert if inside this range (including endpoints).

Examples:

| -w, -c    | OK if result is     | WARN/CRIT if        |
| --------- | ------------------- | ------------------- |
| 10        | in (0..10)          | not in (0..10)      |
| -10       | in (-10..0)         | not in (-10..0)     |
| 10:       | in (10..inf)        | not in (10..inf)    |
| :         | in (0..inf)         | not in (0..inf)     |
| ~:10      | in (-inf..10)       | not in (-inf..10)   |
| 10:20     | in (10..20)         | not in (10..20)     |
| @10:20    | not in (10..20)     | in 10..20           |
| @~:20     | not in (-inf..20)   | in (-inf..20)       |
| @         | not in (0..inf)     | in (0..inf)         |


## Command, Parameters and Arguments

Shell commands like `./file-age --filename='/tmp/*'` have two basic parts:

* Command name of the program to run (`./file-age`). May be followed by one or more options, which adjust the behavior of the command or what it will do.
* Options/Parameters normally start with one or two dashes to distinguish them from arguments (parameter `--filename`, value `'/tmp/*'`). They adjust the behavior of the command. Parameters may be short (`-w`) or long (`--warning`). We prefer and often offer only the long version.

Many shell commands may also be followed by one or more arguments, which often indicate a target that the command should operate upon (`useradd linus` for example) . This does not apply to the check-plugins.

To avoid problems when passing *parameter values* that start with a `-`, the command line call must look like this:

* Long parameters: `./file-age --warning=-60:3600` (use `--param=value` instead of `--param value`).
* Short parameters: `./file-age -w-60:3600` (so simply not putting any space nor escaping it in any special way).


## Directory Layout explained

```
└── plugin-name
    ├── assets                      Additional ressources, for example helper scripts like monitoring.php
    ├── grafana                     Grafana dashboard definition
    ├── icingaweb2-module-director  Icinga Director basket definition
    ├── icingaweb2-module-grafana   Grafana panel definition for Icinga's Grafana module
    ├── lib                         Link to the Linuxfabrik Python libraries
    ├── unit-test                   File for unit tests
    │   ├── retc                    Files for simulating return codes
    │   ├── stdin                   Files for simulating output to STDOUT
    │   ├── stdout                  Files for simulating output to STDERR
    │   └── run                     The unit test
    └── plugin-name                 The monitoring plugin
```


## Python

When running from source, almost all check plugins are happy with at least Python 3.6. All plugins define the `#!/usr/bin/env python3` shebang.


## Icons

You can download all check plugin icons from [download.linuxfabrik.ch](https://download.linuxfabrik.ch/monitoring-plugins/icons/icons.tar.gz). For Icinga, put them in `/usr/share/icingaweb2/public/img/icons/`.


## Grafana

See [GRAFANA](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/GRAFANA.rst)


## Contributing

See [CONTRIBUTING](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/CONTRIBUTING.rst)


## Compiling

See [BUILD](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/BUILD.rst)


## Tips & Tricks

Q: After an update, I get **Operational Error: no such column: ...**, state UNKNOWN. On the next run, this disappears. What happened?

A: Some check plugins require SQLite database files to cache data or to calculate data over time. After an update it is possible that the check plugin uses a new schema, but the database file on disk hasn't been updated (we don't implement database migrations). So in case of an "OperationalError", which happens for example when the plugin tries to INSERT into an outdated table, the database library simply deletes the sqlite database file. It will then be recreated from scratch by the plugin on the next run, with the updated database structure.


Q: **How can I remove the performance data after the `|` from the check output?**

A: In Bash, use `/usr/lib64/nagios/plugins/check-command | cut -f1 -d'|'`


Q: **Do the plugins also handle proxy environment variables like `HTTP_PROXY`?**

A: Yes, `HTTP_PROXY`, `HTTPS_PROXY`, `http_proxy` and `http_proxy` are automatically used by the Linuxfabrik monitoring plugins if they are set.


Q: **Icinga does not seem to pass the environment variable `http_proxy` to the plugins. What am i doing wrong?**

This has nothing to do with the Linuxfabrik monitoring plugins - the Icinga configuration needs to be adjusted here. You need to do some additional configuration to make custom environment variables generally available. According to [this Icinga community post](https://community.icinga.com/t/environments-for-all-check-commands/9092) you need to set them in `/etc/icinga2/icinga2.conf`:

```
template CheckCommand default {
  env.http_proxy = "http://username:password@proxy.example.com:port"
  env.https_proxy = "http://username:password@proxy.example.com:port"
}
```

If you are also using `sudo` to call some plugins from within Icinga, you will also need to set this in your `/etc/sudoers.d/whatever.sudoers`:

```
Defaults env_keep += "http_proxy https_proxy"
```

Pro tips:

* Note that you can't set environment variables in Icinga Director. Even if you are only using the Icinga Director, follow the steps above.
* Environment variables with the same name in both `/etc/environment` and `/etc/icinga2/icinga2.conf` will be overwritten by `/etc/icinga2/icinga2.conf`.


Q: **All pipe characters `|` in the output of any plugin are replaced with `!`. Why?**

A: We have to. The output syntax of Nagios plugins is fixed and not very flexible:

```
Output lines | Performance data
```

So the `|` character is reserved to separate plugin output from performance data. There is no way to escape it - so we have to replace it with `!`.


