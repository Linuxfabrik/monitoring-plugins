# Check librenms-health


## Overview

Retrieves hardware sensor information (temperature, humidity, voltage, power, state, etc.) for each device from a LibreNMS instance and alerts when sensor values exceed their configured thresholds in LibreNMS.

**Important Notes:**

* Requires access to the LibreNMS MySQL/MariaDB database
* See [additional notes for all monitoring plugins accessing MySQL/MariaDB](https://linuxfabrik.github.io/monitoring-plugins/plugins-mysql/) on how to configure database access.
* When defining device groups in LibreNMS for use with `--device-group`, do not use slashes in the name (see [this topic](https://github.com/laravel/framework/issues/22125)).
* This check does not return per-device or per-sensor performance data because LibreNMS provides direct integration with time series databases (Graphite, InfluxDB, OpenTSDB, Prometheus, RRDTool) under Settings > Global Settings > Poller > Datastore.

**Data Collection:**

* Queries the LibreNMS MySQL/MariaDB database directly (the API is too resource-intensive for large-scale environments)
* Joins `devices`, `sensors`, `sensors_to_state_indexes`, `state_translations`, `device_groups`, and `locations` tables
* For state-class sensors, displays the state description instead of the raw numeric value
* For numeric sensors, compares the value against its four configured limits the same way LibreNMS does on its device health pages (warning and critical, low and high) and displays the value together with its low/high range
* Supports filtering by device group (`--device-group`, with SQL wildcards), device hostname (`--device-hostname`, repeatable), and device type (`--device-type`, repeatable)
* In default (compact) mode, only sensors with alerts are shown; use `--lengthy` to display all sensors with extended details (type, location, sensor class, last update time)


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/librenms-health> |
| Nagios/Icinga Check Name              | `check_librenms_health` |
| Check Interval Recommendation         | Every hour |
| Can be called without parameters      | No (`--defaults-file` with valid MySQL/MariaDB credentials is required) |
| Runs on                               | Cross-platform |
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
./librenms-health --defaults-file=/var/spool/icinga2/.my.cnf
```

Output:

```text
There are 2 alerts. Checked 4 sensors.

Hostname     ! SysName  ! Sensor                   ! Val (warn/crit Range)        ! State
-------------+----------+--------------------------+------------------------------+-----------
192.0.2.11   ! pdu-a1   ! lgpEnvSupplyAirHumidity  ! 71.7 (35.0..65.0/30.0..70.0) ! [CRITICAL]
192.0.2.11   ! pdu-a1   ! lgpEnvReturnAirHumidity  ! 82.0 (-/20.0..70.0)          ! [CRITICAL]
storinator02 ! synoRZ04 ! Disk 17 MZILT1T9HAJQ/007 ! NotInitialized               ! [WARNING]
```

With `--lengthy`:

```text
There are 2 alerts. Checked 4 sensors.

Hostname     ! SysName        ! Type    ! Location    ! Sensor                   ! Class    ! Changed ! Val (warn/crit Range)        ! State
-------------+----------------+---------+-------------+--------------------------+----------+---------+------------------------------+-----------
192.0.2.11   ! pdu-a1         ! power   ! DC1 Rack A1 ! lgpEnvSupplyAirHumidity  ! humidity ! 3m 22s  ! 71.7 (35.0..65.0/30.0..70.0) ! [CRITICAL]
192.0.2.11   ! pdu-a1         ! power   ! DC1 Rack A1 ! lgpEnvReturnAirHumidity  ! humidity ! 23m 27s ! 82.0 (-/20.0..70.0)          ! [CRITICAL]
storinator02 ! synoRZ04       ! storage ! DC1 Rack B3 ! Disk 17 MZILT1T9HAJQ/007 ! state    ! 2h 15m  ! NotInitialized               ! [WARNING]
sw01         ! core-switch-01 ! network ! DC1 Rack A2 ! PSU 1 Voltage            ! voltage  ! 5m 1s   ! 12.0 (11.8..12.6/11.4..13.0) ! [OK]
```

The value column shows each sensor's current reading followed by its two limit ranges, the warning range first and the critical range second:

```text
71.7 (35.0..65.0/30.0..70.0)
     `----------'`----------'
      warn range   crit range
     low..high     low..high
```

* A range that has a limit on only one side is left open on the other, for example `31.0 (..30.0/..35.0)` for a sensor with high limits but no low limits.
* A range that is not configured at all is shown as `-`, for example `82.0 (-/20.0..70.0)` for a sensor that has critical limits but no warning limits. This is common: LibreNMS auto-discovery sets only the critical limits for most sensors and leaves the warning limits empty, so a lot of sensors report only a critical range and can therefore only ever reach CRITICAL, never WARNING.
* Discrete state sensors have no numeric limits and show only their state description.

Warning (and critical) limits can be set per sensor in LibreNMS: open the device, go to its settings (the gear icon), and edit the values on the **Health** tab. Once a warning limit is filled in, that sensor starts reporting WARNING before it reaches its critical limit, and its warning range appears here in place of the `-`.


## States

* OK if all sensors are within their LibreNMS-configured limits.
* Numeric sensors (temperature, humidity, voltage, power, etc.) report CRIT when the value is at or beyond its critical low/high limit, and WARN when it is at or beyond its warning low/high limit.
* Discrete state sensors (fan, power supply, disk state, etc.) report the severity LibreNMS assigned to the current state: WARN, CRIT or UNKNOWN.
* A sensor without a current reading is UNKNOWN.
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
