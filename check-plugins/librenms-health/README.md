# Check librenms-health

## Overview

Retrieves hardware sensor information (temperature, humidity, voltage, power, state, etc.) for each device from a LibreNMS instance and alerts when sensor values exceed their configured thresholds in LibreNMS.

**Data Collection:**

* Queries the LibreNMS MySQL/MariaDB database directly (the API is too resource-intensive for large-scale environments)
* Joins `devices`, `sensors`, `sensors_to_state_indexes`, `state_translations`, `device_groups`, and `locations` tables
* For state-class sensors, displays the state description instead of the raw numeric value
* For numeric sensors with defined limits, displays the value together with its low/high range
* Supports filtering by device group (`--device-group`, with SQL wildcards), device hostname (`--device-hostname`, repeatable), and device type (`--device-type`, repeatable)
* In default (compact) mode, only sensors with alerts are shown; use `--lengthy` to display all sensors with extended details (type, location, sensor class, last update time)

**Compatibility:**

* Requires access to the LibreNMS MySQL/MariaDB database

**Important Notes:**

* See [additional notes for all monitoring plugins accessing MySQL/MariaDB](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-MYSQL.md) on how to configure database access.
* When defining device groups in LibreNMS for use with `--device-group`, do not use slashes in the name (see [this topic](https://github.com/laravel/framework/issues/22125)).
* This check does not return per-device or per-sensor performance data because LibreNMS provides direct integration with time series databases (Graphite, InfluxDB, OpenTSDB, Prometheus, RRDTool) under Settings > Global Settings > Poller > Datastore.


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/librenms-health> |
| Nagios/Icinga Check Name              | `check_librenms_health` |
| Check Interval Recommendation         | Once an hour |
| Can be called without parameters      | No (`--defaults-file` with valid MySQL/MariaDB credentials is required) |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: librenms-health [-h] [-V] [--always-ok] [--defaults-file DEFAULTS_FILE]
                       [--defaults-group DEFAULTS_GROUP]
                       [--device-group DEVICE_GROUP]
                       [--device-hostname DEVICE_HOSTNAME]
                       [--device-type {appliance,collaboration,environment,firewall,loadbalancer,management,network,power,printer,server,storage,wireless,workstation}]
                       [--lengthy] [--timeout TIMEOUT]

Retrieves hardware sensor information (temperature, humidity, voltage, power,
etc.) for each device from a LibreNMS instance. Alerts when sensor values
exceed their configured thresholds. Requires direct access to the LibreNMS
MySQL/MariaDB database. Supports extended reporting via --lengthy.

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
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
```


## Usage Examples

```bash
./librenms-health --defaults-file=/var/spool/icinga2/.my.cnf --device-group="%storage%"
```

Output:

```text
There are 4 alerts. Checked 113 sensors.

Hostname     ! SysName  ! Sensor                   ! Val (Range)        ! State
-------------+----------+--------------------------+--------------------+-----------
192.0.2.11   ! synoRZ02 ! Disk 17 MZILT1T9HAJQ/007 ! NotInitialized     ! [WARNING]
192.0.2.11   ! synoRZ02 ! Disk 18 MZILT1T9HAJQ/007 ! NotInitialized     ! [WARNING]
storinator02 ! synoRZ04 ! Upgrade Availability     ! Available          ! [WARNING]
storinator02 ! synoRZ04 ! Disk 5 WD4000FYYZ-01UL1B3 ! NotInitialized    ! [WARNING]
```

With `--lengthy`:

```text
There are 4 alerts. Checked 113 sensors.

Hostname     ! SysName  ! Type    ! Location ! Sensor                   ! Class       ! Changed ! Val (Range)        ! State
-------------+----------+---------+----------+--------------------------+-------------+---------+--------------------+-----------
192.0.2.11   ! synoRZ02 ! storage ! DC1      ! Disk 17 MZILT1T9HAJQ/007 ! state       ! 2h 15m  ! NotInitialized     ! [WARNING]
...
```


## States

* OK if all sensor values are within their LibreNMS-configured thresholds.
* WARN, CRIT, or UNKNOWN based on the sensor's `state_generic_value` in LibreNMS (mirrors the alert state from LibreNMS).
* Sensors with alerting disabled in LibreNMS are excluded and do not affect the check state.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| alert_count | Number | Number of sensor alerts. |
| sensor_count | Number | Number of sensors checked. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
