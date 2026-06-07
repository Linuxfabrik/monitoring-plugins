# Check redfish-sensors


## Overview

Checks hardware sensor readings (temperature, voltage, fan speed, power) from the Redfish Chassis collection via the Redfish API. Reads the modern Sensors collection where available and falls back to the legacy Thermal and Power endpoints otherwise. Alerts when any sensor reports a non-ok state. Also evaluates fan redundancy status. A Chassis is roughly defined as a physical view of a computer system as seen by a human. A single Chassis resource can house sensors, fans, and other components.

**Important Notes:**

* Tested on DELL iDRAC and DMTF Simulator
* A check takes up to 10 seconds. Increasing runtime timeout to 30 seconds is recommended.
* This check runs with both HTTP and HTTPS. It uses GET requests only.
* No additional Python Redfish modules need to be installed.

**Data Collection:**

* Queries `/redfish/v1/Chassis` to enumerate chassis members
* For each member, reads the modern Sensors collection to get individual sensor values, thresholds and health status
* When a chassis exposes no Sensors collection (typical of older BMCs such as iLO4), falls back to the legacy Thermal (temperatures, fans) and Power (voltages, power supplies) endpoints
* Also queries the Thermal endpoint for fan redundancy information
* Uses HTTP Basic authentication if `--username` and `--password` are provided
* Only evaluates sensors and chassis in "Enabled" or "Quiesced" state


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/redfish-sensors> |
| Nagios/Icinga Check Name              | `check_redfish_sensors` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |


## Help

```text
usage: redfish-sensors [-h] [-V] [--always-ok] [--brief]
                       [--cache-expire CACHE_EXPIRE] [--ignore IGNORE]
                       [--insecure] [--match MATCH] [--no-proxy]
                       [--password PASSWORD] [--retries RETRIES] [--test TEST]
                       [--timeout TIMEOUT] [--url URL] [--username USERNAME]

Checks hardware sensor readings (temperature, voltage, fan speed, power) from
the Redfish Chassis collection via the Redfish API. Reads the modern Sensors
collection where available and falls back to the legacy Thermal and Power
endpoints otherwise. Alerts when any sensor reports a non-ok state.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --brief               Hide items that are OK and show only those in
                        WARN/CRIT state. Alerting is unaffected: all items
                        still drive the overall check state. Default: False
  --cache-expire CACHE_EXPIRE
                        The amount of time after which the credential/data
                        cache expires, in minutes. Default: 15
  --ignore IGNORE       Ignore items whose name matches this Python regular
                        expression. Case-sensitive by default; use `(?i)` for
                        case-insensitive matching. Can be specified multiple
                        times.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --match MATCH         Only check items whose name matches this Python
                        regular expression. Case-sensitive by default; use
                        `(?i)` for case-insensitive matching. Can be specified
                        multiple times.
  --no-proxy            Do not use a proxy.
  --password PASSWORD   Redfish API password.
  --retries RETRIES     Number of extra attempts if a request to the Redfish
                        API fails, before the check gives up. Helps against an
                        occasionally slow or flaky management controller.
                        Default: 3
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --url URL             Redfish API URL. Default: https://localhost:5000
  --username USERNAME   Redfish API username.
```


## Usage Examples

```bash
./redfish-sensors --url=https://bmc --username=redfish-monitoring --password='linuxfabrik'
```

Output:

```text
Everything is ok, checked sensors on 1 member.

Member: Contoso 3500RX, Power: On, LED: Lit, SKU: 8675309, SerNo: 437XR1138R2, PartNumber: 224071-J23

Sensor                             ! Location    ! Reading ! Unit ! Value ! State
-----------------------------------+-------------+---------+------+-------+------
Ambient Temperature                ! Room        ! 22.5    ! Cel  ! [OK]  ! [OK]
CPU #1 Fan Speed                   ! CPU         ! 80      ! %    ! [OK]  ! [OK]
CPU #1 Temperature                 ! CPU         ! 37      ! Cel  ! [OK]  ! [OK]
DIMM #1 Temperature                ! Memory      ! 44      ! Cel  ! [OK]  ! [OK]
Power Supply #1 Input Power        ! PowerSupply ! 374     ! W    ! [OK]  ! [OK]

Redundancy            ! Mode ! State
----------------------+------+-------
BaseBoard System Fans ! N+m  ! [OK]
```


## States

* OK if all sensors are healthy and within their thresholds.
* WARN if an enabled sensor health or health rollup state is "Warning".
* WARN if a sensor value exceeds the Redfish non-critical threshold (`Thresholds_UpperCaution`, `Thresholds_LowerCaution`; the legacy `UpperThresholdNonCritical`, `LowerThresholdNonCritical`).
* CRIT if an enabled sensor health or health rollup state is "Critical".
* CRIT if a sensor value exceeds the Redfish critical threshold (`Thresholds_UpperCritical`, `Thresholds_LowerCritical`; the legacy `UpperThresholdCritical`, `LowerThresholdCritical`).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

Depends on your hardware. Each sensor reading (from the modern Sensors collection or, in the legacy fallback, from the Thermal and Power endpoints) is reported as a separate metric.

| Name | Type | Description |
|----|----|----|
| \<location\>_\<sensor-name\> | Number | Sensor reading. Examples: `Chassis_Chassis_Fan_1`, `CPU_CPU_1_Temperature`, `Memory_DIMM_1_Temperature`


## For Maintainers

You don't need a physical server with a real BMC (the management controller that serves the Redfish API, e.g. HPE iLO or Dell iDRAC) to develop or test this plugin. The official DMTF Redfish mockup server serves a static, read-only Redfish tree (including the modern `Sensors` collection as well as the legacy `Thermal` and `Power` endpoints) over plain HTTP, which is exactly what this GET-only plugin needs.

Run the mockup server and point the plugin at it, from the repository root:

```bash
podman run \
    --detach --rm \
    --name lfmp-redfish-mock \
    --publish 5000:8000 \
    docker.io/dmtf/redfish-mockup-server:latest
sleep 3
check-plugins/redfish-sensors/redfish-sensors --url=http://127.0.0.1:5000 --no-proxy
podman stop lfmp-redfish-mock
```

Use `http://127.0.0.1:5000` rather than `http://localhost:5000`, because `localhost` may resolve to IPv6 (`::1`) while the published container port is bound to IPv4.

The fixtures under [`unit-test/stdout/`](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/redfish-sensors/unit-test/stdout) are the raw Redfish responses the plugin walks. A modern scenario contains `<scenario>-chassises`, `<scenario>-chassis`, `<scenario>-sensors`, `<scenario>-sensor-N` and `<scenario>-thermal`. A legacy fallback scenario instead has a `<scenario>-chassis` without a Sensors link plus `<scenario>-thermal` and `<scenario>-power`. To simulate a fault, copy a set and edit a sensor's `Status.Health`, or push a reading past its critical threshold. The offline test suite is run with `./run` from the `unit-test` directory.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
