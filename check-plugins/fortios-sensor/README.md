# Check fortios-sensor

## Overview

Checks hardware sensor readings (temperature, voltage, fan speed) on FortiGate appliances running FortiOS via the REST API. Alerts when any sensor value crosses the appliance-defined thresholds (`lower_non_critical`, `lower_critical`, `upper_non_critical`, `upper_critical`). Sensors reporting a value of 0.0 are skipped automatically. Authentication uses a single API token (token-based authentication).

**Data Collection:**

* Queries the FortiOS REST API endpoint `/api/v2/monitor/system/sensor-info/select` to fetch all hardware sensor readings and their thresholds

**Compatibility:**

* Cross-platform

**Important Notes:**

* FortiGate appliances running FortiOS with REST API enabled



## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/fortios-sensor> |
| Nagios/Icinga Check Name              | `check_fortios_sensor` |
| Check Interval Recommendation         | Every 15 minutes |
| Can be called without parameters      | No (`--hostname` and `--password` are required) |
| Compiled for Windows                  | No |


## Help

```text
usage: fortios-sensor [-h] [-V] [--always-ok] -H HOSTNAME [--insecure]
                      [--no-proxy] --password PASSWORD [--timeout TIMEOUT]

Checks hardware sensor readings (temperature, voltage, fan speed) on FortiGate
appliances running FortiOS via the REST API. Alerts when any sensor reports an
alarm condition.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -H, --hostname HOSTNAME
                        FortiOS-based appliance address, optionally including
                        port. Example: `--hostname 192.168.1.1:443`.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-proxy            Do not use a proxy.
  --password PASSWORD   FortiOS REST API single-use access token.
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
```


## Usage Examples

```bash
./fortios-sensor --hostname fortigate-cluster.linuxfabrik.io --password mypass
```

Output:

```text
Checked 42 sensors, all are ok.
```

Output (with warnings):

```text
Checked 42 sensors. There are warnings.
* MAC_AVS 1V (0.92 V) is less or equal to a certain threshold (0.9214/0.892)
```


## States

* OK if all sensor values are within their non-critical thresholds.
* WARN if any sensor value is <= `lower_non_critical` or >= `upper_non_critical`.
* CRIT if any sensor value is <= `lower_critical` or >= `upper_critical`.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

Depends on the hardware sensors present on your appliance. Each sensor is reported by its ID (e.g. `fan.fan1`, `temperature.cpu_0_core_0`, `voltage.mac_avs_1v`). The warning and critical thresholds are set to the appliance's `upper_non_critical` and `upper_critical` values, with min/max set to `lower_non_recoverable` and `upper_non_recoverable`.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
