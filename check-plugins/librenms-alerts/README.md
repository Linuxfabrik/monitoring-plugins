# Check librenms-alerts

## Overview

LibreNMS includes a highly customizable alerting system. The system requires a set of user-defined rules to evaluate the situation of each device, port, service, or other entity. This check warns of unacknowledged alerts in LibreNMS and reports the most recent alert for each device (only for those that do not have "Disabled alerting" in their LibreNMS device settings). If alerts have been triggered in LibreNMS, you will see them on the *Alerts \> Notifications* page within the Web UI. When you acknowledge an alert in LibreNMS, this check will change the status for the corresponding device to OK.

This check requires direct access to the LibreNMS MySQL/MariaDB database, because the API is simply too resource intensive for use in a large scale environment.

Notes:

* See [additional notes for all monitoring plugins accessing MySQL/MariaDB](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-MYSQL.md) on how to configure access to the database.
* When defining device groups in LibreNMS for use with `--device--group`, do not use slashes in the name, as this will not work. See [this topic for example](https://github.com/laravel/framework/issues/22125).
* This check could, but does not, return performance data for each device as LibreNMS provides direct integration with several time series databases such as Graphite, InfluxDB, OpenTSDB, Prometheus and RRDTool. The configuration options can be found in LibreNMS under Settings \> Global Settings \> Poller \> Datastore.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/librenms-alerts> |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | No |
| Compiled for Windows                  | No |
| Requirements                          | Access to LibreNMS' MySQL/MariaDB database. User with no privileges, locked down to `127.0.0.1` - for example `monitoring\@127.0.0.1`. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions. |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: librenms-alerts [-h] [-V] [--always-ok] [--defaults-file DEFAULTS_FILE]
                       [--defaults-group DEFAULTS_GROUP]
                       [--device-group DEVICE_GROUP]
                       [--device-hostname DEVICE_HOSTNAME]
                       [--device-type {appliance,collaboration,environment,firewall,management,loadbalancer,network,power,printer,server,storage,wireless,workstation}]
                       [--lengthy] [--severity {warn,crit}]
                       [--timeout TIMEOUT]

This check warns of unacknowledged alerts in LibreNMS and reports the most
recent alert for each device (only for those that do not have "Disabled
alerting" in their LibreNMS device settings). If alerts have been triggered in
LibreNMS, you will see them on the *Alerts > Notifications* page within the
Web UI. When you acknowledge an alert in LibreNMS, this check will change the
status for the corresponding device to OK. This check requires direct access
to the LibreNMS MySQL/MariaDB database, because the API is simply too resource
intensive for use in a large scale environment.

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
  --severity {warn,crit}
                        Severity for alerts. One of "warn" or "crit". Default:
                        crit
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
```


## Usage Examples

```bash
./librenms-alerts '--timeout' '3' --defaults-file=/var/spool/icinga2/.my.cnf --device-group="%network%" --severity=warn
```

Output:

```text
Checked 5 devices. There are 2 alerts.

Hostname   ! SysName                 ! Alert        ! State      
-----------+-------------------------+--------------+------------
192.0.2.10 ! synology                ! None         ! [OK]       
192.0.2.33 ! rack03-usw              ! Ping Latency ! [WARNING] 
192.0.2.51 ! uap-ac-001              ! None         ! [OK]       
192.0.2.57 ! uap-ac-002              ! None         ! [OK]       
192.0.2.50 ! uap-ac-003              ! None         ! [OK]       
192.0.2.32 ! rack03-usw-pro-48server ! Ping Latency ! [WARNING] 
...
```

The `--lengthy` switch reports Hostname, SysName, Hardware, Type, OS, Location, Uptime, Alert and State.


## States

* Alerts according to the given severity (default: CRIT) on any alert in LibreNMS
* OK on OK or ACK in LibreNMS


## Perfdata / Metrics

| Name         | Type   | Description             |
|--------------|--------|-------------------------|
| device_count | Number | Number of devices found |
| alert_count  | Number | Number of device alerts |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
