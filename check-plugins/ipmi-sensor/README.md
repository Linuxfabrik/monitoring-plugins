# Check ipmi-sensor

## Overview

Checks IPMI sensor readings (temperature, voltage, fan speed, power, etc.) using ipmitool. Alerts when any sensor reports a non-ok status. Provides detailed output including current values, thresholds, and sensor states. Requires root or sudo.

**Data Collection:**

* Executes `ipmitool sensor list` locally or against a remote BMC/iLO via IPMI over LAN
* For remote access, supports both IPMI v1.5 (`--interface=lan`) and IPMI v2.0 (`--interface=lanplus`)
* Emits perfdata for every threshold-based sensor with IPMI-reported warning, critical, and min/max values

**Compatibility:**

* Tested on Supermicro BMC and HPE iLO
* Requires hardware with an IPMI interface

**Important Notes:**

* `Discrete` sensors are not supported and are silently skipped.
* Requires the `ipmitool` command-line tool to be installed.


## Fact Sheet

| Fact | Value |
|----|------|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/ipmi-sensor> |
| Nagios/Icinga Check Name              | `check_ipmi_sensor` |
| Check Interval Recommendation         | Every 15 minutes |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Requirements                          | `ipmitool` |


## Help

```text
usage: ipmi-sensor [-h] [-V] [--authtype {NONE,PASSWORD,MD2,MD5,OEM}]
                   [-H HOSTNAME] [--interface {lan,lanplus}]
                   [--password PASSWORD] [--port PORT]
                   [--privlevel {CALLBACK,USER,OPERATOR,ADMINISTRATOR}]
                   [--test TEST] [--username USERNAME]

Checks IPMI sensor readings (temperature, voltage, fan speed, power, etc.)
using ipmitool. Alerts when any sensor reports a non-ok status. Provides
detailed output including current values, thresholds, and sensor states.
Requires root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --authtype {NONE,PASSWORD,MD2,MD5,OEM}
                        Authentication type for IPMIv1.5 lan session
                        activation. Supported types are NONE, PASSWORD, MD2,
                        MD5, or OEM. Default: NONE
  -H, --hostname HOSTNAME
                        Remote server address, can be a hostname or IP
                        address. Required for lan and lanplus interfaces.
  --interface {lan,lanplus}
                        IPMI interface to use. Supported types are "lan" (IPMI
                        v1.5) or "lanplus" (IPMI v2.0). Default: lan
  --password PASSWORD   Remote server password.
  --port PORT           Remote server UDP port to connect to. Default: 623
  --privlevel {CALLBACK,USER,OPERATOR,ADMINISTRATOR}
                        Force session privilege level. Can be CALLBACK, USER,
                        OPERATOR, ADMINISTRATOR. Default: USER
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  --username USERNAME   Remote server username. Default: NULL
```


## Usage Examples

```bash
./ipmi-sensor --privlevel USER --interface lanplus --hostname 10.100.184.29 --username 'user' --password 'pa$$word'
```

Output:

```text
Everything is ok, checked 60 sensors.
```


## States

* OK if all sensors report "ok" status.
* WARN if any sensor is in "nc" (non-critical) state.
* CRIT if any sensor is in "cr" (critical) state.
* CRIT if any sensor is in "nr" (non-recoverable) state, indicating possible hardware damage.
* UNKNOWN if `ipmitool` is not found or returns an error.


## Perfdata / Metrics

Perfdata depends on the hardware. Sensor names have spaces replaced with underscores. Example metrics from a Supermicro system:

| Name | Type | Description |
|----|----|----|
| 12V | Number | 12V rail voltage reading. |
| 3.3VCC | Number | 3.3V rail voltage reading. |
| 5VCC | Number | 5V rail voltage reading. |
| CPU_Temp | Number | CPU temperature reading. |
| DIMMA1_Temp | Number | DIMM A1 temperature reading. |
| FAN1 | Number | Fan 1 speed reading. |
| System_Temp | Number | System temperature reading. |

The actual metrics vary per hardware platform. Warning and critical thresholds in perfdata are taken from the IPMI-reported upper non-critical and upper critical values.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
