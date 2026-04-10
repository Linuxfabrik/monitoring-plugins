# Check cometsystem

## Overview

Reads sensor data from Comet System Web Sensors via their JSON API endpoint. Monitors channels such as temperature, humidity, and other environmental values. Alarm states are mapped to configurable severity levels using a flexible pattern matching system (e.g. "temp:high:crit", "humi:low:warn").

**Data Collection:**

* Fetches sensor data from the JSON endpoint of a [COMET SYSTEM](https://www.cometsystem.com/) Web Sensor (e.g. `http://example.com/values.json`)
* Iterates over all channels (`ch1`, `ch2`, ...) and reads their name, value, unit, and alarm state
* Alarm mode per channel selects the direction: lower than limit (low alarm), higher than limit (high alarm), or disabled

**Compatibility:**

* Cross-platform

**Important Notes:**

* Works with any Comet System Web Sensor that exposes a `/values.json` endpoint
* The repeating `--severity` parameter can be set in different ways:

    * `--severity ok|warn|crit|unknown`: High and low alarm severity for all channels and all alarm modes.
    * `--severity part-of-channel-name:ok|warn|crit|unknown`: High and low alarm severity for a specific channel and all alarm modes. You just need to specify a part of the channel name. Case-insensitive.
    * `--severity part-of-channel-name:low|high:ok|warn|crit|unknown`: Alarm severity for a specific channel and a specific alarm mode.

* The order of `--severity` matters, the first match wins. If no `--severity` is specified, any alarm defaults to WARN.

Example:

```bash
./cometsystem --url http://example.com/values.json --severity temp:high:crit --severity humi:ok --severity warn
```

Here, the check raises critical for any channel with "temp" in its name on high alarms only, returns ok for any alarm in channels with "humi" in their name, and finally warns on all other alarms in all other channels. The last `--severity warn` can be omitted as this is the default behavior.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/cometsystem> |
| Nagios/Icinga Check Name              | `check_cometsystem` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | No (`--url` is required) |
| Compiled for Windows                  | No |


## Help

```text
usage: cometsystem [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                   [--severity SEVERITY] [--test TEST] [--timeout TIMEOUT]
                   -u URL

Reads sensor data from Comet System Web Sensors via their JSON API endpoint.
Monitors channels such as temperature, humidity, and other environmental
values. Alarm states are mapped to configurable severity levels using a
flexible pattern matching system (e.g. "temp:high:crit", "humi:low:warn").

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  --insecure           This option explicitly allows insecure SSL connections.
  --no-proxy           Do not use a proxy.
  --severity SEVERITY  Severity for alerting. Order matters, first match on
                       part of a channel name wins. Have a look at the README
                       for details. Can be specified multiple times. Example:
                       `--severity temp:high:crit --severity dew:low:crit
                       --severity humi:ok --severity warn`. Default: warn.
  --test TEST          For unit tests. Needs "path-to-stdout-file,path-to-
                       stderr-file,expected-retc".
  --timeout TIMEOUT    Network timeout in seconds. Default: 5 (seconds)
  -u, --url URL        Comet System URL pointing to the JSON endpoint.
                       Example: `http://example.com/values.json`.
```


## Usage Examples

```bash
./cometsystem --url http://example.com/values.json --severity temp:high:crit --severity dew:ok
```

Output:

```text
There are critical errors on Web Sensor SN 17965562.

Ch# ! Name                 ! Alarm ! Value            
----+----------------------+-------+------------------
ch1 ! Temperature          ! high  ! 27.3C [CRITICAL] 
ch2 ! Relative humidity    !       ! 43.1%RH          
ch3 ! Dew point            ! low   ! 13.7C
ch4 ! Atmospheric pressure !       ! 958.6hPa
```


## States

* OK if no sensor alarms are active.
* WARN, CRIT, or UNKNOWN depending on the `--severity` configuration when a sensor alarm is triggered. Default for any alarm without a matching `--severity` rule is WARN.
* UNKNOWN if the URL does not return valid JSON or the expected channel data is missing.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

Channel names and values depend on the Web Sensor model and its configuration. For example:

| Name | Type | Description |
|----|----|----|
| Atmospheric pressure | Number | Barometric pressure or weight of the atmosphere above. |
| Dew point | Number | Temperature at which condensation starts. |
| Relative humidity | Percentage | Relative humidity. |
| Temperature | Number | Temperature in C or F. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch); originally written by Dominik Riva, Universitätsspital Basel/Switzerland
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
