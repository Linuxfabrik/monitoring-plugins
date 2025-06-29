# Check librenms-health

## Overview

This check plugin retrieves sensor information for each device from a LibreNMS instance.

This check requires direct access to the LibreNMS MySQL/MariaDB database, because the API is simply too resource intensive for use in a large scale environment.

Notes:

* See [additional notes for all monitoring plugins accessing MySQL/MariaDB](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-MYSQL.rst) on how to configure access to the database.
* When defining device groups in LibreNMS for use with `--device--group`, do not use slashes in the name, as this will not work. See [this topic for example](https://github.com/laravel/framework/issues/22125).
* This check could, but does not, return performance data for each device or sensor as LibreNMS provides direct integration with several time series databases such as Graphite, InfluxDB, OpenTSDB, Prometheus and RRDTool. The configuration options can be found in LibreNMS under Settings \> Global Settings \> Poller \> Datastore.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/librenms-health> |
| Check Interval Recommendation         | Once an hour |
| Can be called without parameters      | No |
| Compiled for Windows                  | No |
| Requirements                          | Access to LibreNMS' MySQL/MariaDB database. User with no privileges, locked down to `127.0.0.1` - for example `monitoring\@127.0.0.1`. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions. |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: librenms-health [-h] [-V] [--always-ok] [--defaults-file DEFAULTS_FILE]
                       [--defaults-group DEFAULTS_GROUP]
                       [--device-group DEVICE_GROUP]
                       [--device-hostname DEVICE_HOSTNAME]
                       [--device-type {appliance,collaboration,environment,firewall,loadbalancer,network,power,printer,server,storage,wireless,workstation}]
                       [--lengthy] [--timeout TIMEOUT]

This check plugin retrieves sensor information for each device from a LibreNMS
instance. This check requires direct access to the LibreNMS MySQL/MariaDB
database, because the API is simply too resource intensive for use in a large
scale environment.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --defaults-file DEFAULTS_FILE
                        Specifies a cnf file to read parameters like user,
                        host and password from (instead of specifying them on
                        the command line), for example
                        `/var/spool/icinga2/.my.cnf`. Default:
                        /var/spool/icinga2/.my.cnf
  --defaults-group DEFAULTS_GROUP
                        Group/section to read from in the cnf file. Default:
                        client
  --device-group DEVICE_GROUP
                        Filter by LibreNMS Device Group. Supports SQL
                        Wildcards.
  --device-hostname DEVICE_HOSTNAME
                        Filter by LibreNMS Hostname (repeating).
  --device-type {appliance,collaboration,environment,firewall,loadbalancer,network,power,printer,server,storage,wireless,workstation}
                        Filter by LibreNMS Device Type (repeating).
  --lengthy             Extended reporting.
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
```


## Usage Examples

```bash
./librenms-health '--timeout' '3' --defaults-file=/var/spool/icinga2/.my.cnf --device-group="%storage%"
```

Output:

```text
Checked 113 devices. There are 4 alerts.

Hostname     ! SysName  ! Sensor                      ! Val (Range)       ! State     
-------------+----------+-----------------------------+-------------------+-----------
192.0.2.10   ! synoRZ01 ! System                      ! 33.0 (23.0..53.0) ! [OK]      
192.0.2.11   ! synoRZ02 ! System                      ! Normal            ! [OK]      
192.0.2.11   ! synoRZ02 ! Power                       ! Normal            ! [OK]      
192.0.2.11   ! synoRZ02 ! FAN - System                ! Normal            ! [OK]      
192.0.2.11   ! synoRZ02 ! FAN - CPU                   ! Normal            ! [OK]      
192.0.2.11   ! synoRZ02 ! Upgrade Availability        ! Unavailable       ! [OK]      
192.0.2.11   ! synoRZ02 ! Volume 1                    ! Normal            ! [OK]      
192.0.2.11   ! synoRZ02 ! Disk 17 MZILT1T9HAJQ/007    ! NotInitialized    ! [WARNING] 
192.0.2.11   ! synoRZ02 ! Disk 18 MZILT1T9HAJQ/007    ! NotInitialized    ! [WARNING] 
192.0.2.11   ! synoRZ02 ! Disk 1 MZILT1T9HAJQ/007     ! Normal            ! [OK]      
192.0.2.11   ! synoRZ02 ! Disk 2 MZILT1T9HAJQ/007     ! Normal            ! [OK]      
192.0.2.11   ! synoRZ02 ! Disk 3 MZILT1T9HAJQ/007     ! Normal            ! [OK]      
192.0.2.11   ! synoRZ02 ! Disk 4 MZILT1T9HAJQ/007     ! Normal            ! [OK]      
192.0.2.11   ! synoRZ02 ! System                      ! 40.0              ! [OK]      
192.0.2.11   ! synoRZ02 ! Disk 17 MZILT1T9HAJQ/007    ! 32.0 (22.0..52.0) ! [OK]      
192.0.2.11   ! synoRZ02 ! Disk 18 MZILT1T9HAJQ/007    ! 32.0 (22.0..52.0) ! [OK]      
192.0.2.11   ! synoRZ02 ! Disk 1 MZILT1T9HAJQ/007     ! 25.0 (23.0..53.0) ! [OK]      
192.0.2.11   ! synoRZ02 ! Disk 2 MZILT1T9HAJQ/007     ! 25.0 (23.0..53.0) ! [OK]      
192.0.2.11   ! synoRZ02 ! Disk 3 MZILT1T9HAJQ/007     ! 25.0 (23.0..53.0) ! [OK]      
192.0.2.11   ! synoRZ02 ! Disk 4 MZILT1T9HAJQ/007     ! 25.0 (23.0..53.0) ! [OK]      
storinator02 ! synoRZ04 ! System                      ! Normal            ! [OK]      
storinator02 ! synoRZ04 ! Power                       ! Normal            ! [OK]      
storinator02 ! synoRZ04 ! FAN - System                ! Normal            ! [OK]      
storinator02 ! synoRZ04 ! FAN - CPU                   ! Normal            ! [OK]      
storinator02 ! synoRZ04 ! Upgrade Availability        ! Available         ! [WARNING] 
storinator02 ! synoRZ04 ! Volume 1                    ! Normal            ! [OK]      
storinator02 ! synoRZ04 ! Disk 6 ST4000NM0035-1V4107  ! Normal            ! [OK]      
storinator02 ! synoRZ04 ! Disk 2 WD4002FYYZ-01B7CB1   ! Normal            ! [OK]      
storinator02 ! synoRZ04 ! Disk 5 WD4000FYYZ-01UL1B3   ! NotInitialized    ! [WARNING] 
storinator02 ! synoRZ04 ! Disk 1 WD4000FYYZ-01UL1B3   ! Normal            ! [OK]      
storinator02 ! synoRZ04 ! Disk 4 WD4002FYYZ-01B7CB1   ! Normal            ! [OK]      
storinator02 ! synoRZ04 ! Disk 3 WD4000FYYZ-01UL1B3   ! Normal            ! [OK]      
storinator02 ! synoRZ04 ! System                      ! 47.0              ! [OK]      
storinator02 ! synoRZ04 ! Disk 6 ST4000NM0035-1V4107  ! 36.0 (26.0..56.0) ! [OK]      
storinator02 ! synoRZ04 ! Disk 2 WD4002FYYZ-01B7CB1   ! 38.0 (27.0..57.0) ! [OK]      
storinator02 ! synoRZ04 ! Disk 5 WD4000FYYZ-01UL1B3   ! 36.0 (26.0..56.0) ! [OK]      
storinator02 ! synoRZ04 ! Disk 1 WD4000FYYZ-01UL1B3   ! 36.0 (25.0..55.0) ! [OK]      
storinator02 ! synoRZ04 ! Disk 4 WD4002FYYZ-01B7CB1   ! 36.0 (27.0..57.0) ! [OK]      
storinator02 ! synoRZ04 ! Disk 3 WD4000FYYZ-01UL1B3   ! 35.0 (25.0..55.0) ! [OK]
...
```

The `--lengthy` switch reports Hostname, SysName, Type, Location, Sensor, Class, Changed, Val (Range) and State.


## States

* OK, WARN, CRIT or UNKNOWN according to the same sensor state in LibreNMS
* OK if you disable the alerting for a particular sensor in LibreNMS


## Perfdata / Metrics

| Name         | Type   | Description             |
|--------------|--------|-------------------------|
| sensor_count | Number | Number of sensors found |
| alert_count  | Number | Number of sensor alerts |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
