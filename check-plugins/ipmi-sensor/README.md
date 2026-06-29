# Check ipmi-sensor


## Overview

Checks IPMI sensor readings (temperature, voltage, fan speed, power, etc.) using ipmitool. Alerts when any sensor reports a non-ok status. Provides detailed output including current values, thresholds, and sensor states. Requires root or sudo.

**Important Notes:**

* Tested on Supermicro BMC and HPE iLO
* Requires hardware with an IPMI interface
* `Discrete` sensors are not supported and are silently skipped.
* Requires the `ipmitool` command-line tool to be installed.

**Data Collection:**

* Executes `ipmitool sensor list` locally or against a remote BMC/iLO via IPMI over LAN
* For remote access, supports both IPMI v1.5 (`--interface=lan`) and IPMI v2.0 (`--interface=lanplus`)
* Emits perfdata for every threshold-based sensor with IPMI-reported warning, critical, and min/max values


## Fact Sheet

| Fact | Value |
|----|------|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/ipmi-sensor> |
| Nagios/Icinga Check Name              | `check_ipmi_sensor` |
| Check Interval Recommendation         | Every 15 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Requirements                          | `ipmitool` |


## Help

```text
usage: ipmi-sensor [-h] [-V] [--authtype {NONE,PASSWORD,MD2,MD5,OEM}]
                   [-H HOSTNAME] [--interface {lan,lanplus}]
                   [--password PASSWORD] [--port PORT]
                   [--privlevel {CALLBACK,USER,OPERATOR,ADMINISTRATOR}]
                   [--username USERNAME]

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

Perfdata depends on the hardware. Each metric is named `<sensor-name>_<Type>`, where the sensor name has its spaces replaced with underscores and `<Type>` is derived from the sensor's unit of measurement (`_Temperature`, `_Fan`, `_Voltage`, `_Power` or `_Current`). The type suffix lets a dashboard group readings by a stable regex (for example `/Temperature$/`) even though IPMI sensor names are vendor-specific, and matches the Redfish sensor wording so this dashboard and redfish-sensors share the same grouping scheme. A type word the vendor already put in the name is dropped first, so `CPU Temp` becomes `CPU_Temperature` rather than `CPU_Temp_Temperature`. Sensors with an unmapped unit keep the bare sensor name. Example metrics from a Supermicro system:

| Name | Type | Description |
|----|----|----|
| 12V_Voltage | Number | 12V rail voltage reading. |
| 3.3VCC_Voltage | Number | 3.3V rail voltage reading. |
| 5VCC_Voltage | Number | 5V rail voltage reading. |
| AVG_Power | Number | Average power consumption reading. |
| CPU_Temperature | Number | CPU temperature reading. |
| DIMMA1_Temperature | Number | DIMM A1 temperature reading. |
| FAN1_Fan | Number | Fan 1 speed reading. |
| System_Temperature | Number | System temperature reading. |

The actual metrics vary per hardware platform. Warning and critical thresholds in perfdata are taken from the IPMI-reported upper non-critical and upper critical values.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
