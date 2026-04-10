# Check librenms-alerts


## Overview

Checks for unacknowledged alerts in LibreNMS and reports the most recent alert per device. Only considers devices that do not have alerting disabled in their LibreNMS device settings. When you acknowledge an alert in the LibreNMS web UI (Alerts > Notifications), this check changes the status for the corresponding device to OK.

**Important Notes:**

* Requires access to the LibreNMS MySQL/MariaDB database
* See [additional notes for all monitoring plugins accessing MySQL/MariaDB](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-MYSQL.md) on how to configure database access.
* When defining device groups in LibreNMS for use with `--device-group`, do not use slashes in the name (see [this topic](https://github.com/laravel/framework/issues/22125)).
* This check does not return per-device performance data because LibreNMS provides direct integration with time series databases (Graphite, InfluxDB, OpenTSDB, Prometheus, RRDTool) under Settings > Global Settings > Poller > Datastore.

**Data Collection:**

* Queries the LibreNMS MySQL/MariaDB database directly (the API is too resource-intensive for large-scale environments)
* Joins `devices`, `alerts`, `alert_rules`, `device_groups`, and `locations` tables to build the device/alert overview
* Supports filtering by device group (`--device-group`, with SQL wildcards), device hostname (`--device-hostname`, repeatable), and device type (`--device-type`, repeatable)
* In default (compact) mode, only devices with active alerts are shown; use `--lengthy` to display all devices with extended details (hardware, type, OS, location, uptime)


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/librenms-alerts> |
| Nagios/Icinga Check Name              | `check_librenms_alerts` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | No (`--defaults-file` with valid MySQL/MariaDB credentials is required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: librenms-alerts [-h] [-V] [--always-ok] [--defaults-file DEFAULTS_FILE]
                       [--defaults-group DEFAULTS_GROUP]
                       [--device-group DEVICE_GROUP]
                       [--device-hostname DEVICE_HOSTNAME]
                       [--device-type {appliance,collaboration,environment,firewall,loadbalancer,management,network,power,printer,server,storage,wireless,workstation}]
                       [--lengthy] [--severity {warn,crit}]
                       [--timeout TIMEOUT]

Checks for unacknowledged alerts in LibreNMS and reports the most recent alert
per device. Only considers devices that do not have alerting disabled in their
LibreNMS settings. Requires direct access to the LibreNMS MySQL/MariaDB
database. Supports extended reporting via --lengthy.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --defaults-file DEFAULTS_FILE
                        Specifies a cnf file to read parameters like user,
                        host and password from (for MySQL/MariaDB cnf-style
                        files). Example: `/var/spool/icinga2/.my.cnf`.
                        Default: /var/spool/icinga2/.my.cnf
  --defaults-group DEFAULTS_GROUP
                        Group/section to read from in the cnf file. Default:
                        client
  --device-group DEVICE_GROUP
                        Filter by LibreNMS device group. Supports SQL
                        wildcards.
  --device-hostname DEVICE_HOSTNAME
                        Filter by LibreNMS hostname. Can be specified multiple
                        times.
  --device-type {appliance,collaboration,environment,firewall,loadbalancer,management,network,power,printer,server,storage,wireless,workstation}
                        Filter by LibreNMS device type. Can be specified
                        multiple times.
  --lengthy             Extended reporting.
  --severity {warn,crit}
                        Severity for alerting. Default: crit
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
```


## Usage Examples

```bash
./librenms-alerts --defaults-file=/var/spool/icinga2/.my.cnf --device-group="%network%" --severity=warn
```

Output:

```text
There are 2 alerts. Checked 5 devices.

Hostname   ! SysName                 ! Alert        ! State
-----------+-------------------------+--------------+------------
192.0.2.33 ! rack03-usw              ! Ping Latency ! [WARNING]
192.0.2.32 ! rack03-usw-pro-48server ! Ping Latency ! [WARNING]
```

With `--lengthy`:

```text
There are 2 alerts. Checked 5 devices.

Hostname   ! SysName                 ! Hardware ! Type    ! OS    ! Location ! Uptime ! Alert        ! State
-----------+-------------------------+----------+---------+-------+----------+--------+--------------+----------
192.0.2.10 ! synology                ! DS920+   ! storage ! linux ! DC1      ! 3M 2W  ! None         ! [OK]
192.0.2.33 ! rack03-usw              ! USW-48   ! network ! linux ! DC1      ! 1M 3W  ! Ping Latency ! [WARNING]
...
```


## States

* OK if there are no unacknowledged alerts.
* WARN or CRIT (default: CRIT, configurable via `--severity`) for each device with an unacknowledged alert.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| alert_count | Number | Number of device alerts. |
| device_count | Number | Number of devices checked. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
