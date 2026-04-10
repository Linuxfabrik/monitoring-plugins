# Check sensors-fans

## Overview

Reports hardware fan speeds in RPM (rounds per minute). Returns OK if no fans are detected.

**Data Collection:**

* Uses `psutil.sensors_fans()` to read fan speed data from hardware sensors

**Important Notes:**

* Run `sensors-detect --auto` beforehand to scan the system for hardware monitoring chips supported by libsensors / lm_sensors

**Compatibility:**

* Linux and all psutil-supported systems with fan sensors


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/sensors-fans> |
| Nagios/Icinga Check Name              | `check_sensors_fans` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `psutil` |


## Help

```text
usage: sensors-fans [-h] [-V] [--always-ok] [-c CRIT] [-w WARN]

Reports hardware fan speeds in RPM (rounds per minute). Alerts when fan speeds
fall outside the thresholds reported by the hardware sensors.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  -c, --critical CRIT  CRIT threshold for fan speed, in RPM. Default: 20000
  -w, --warning WARN   WARN threshold for fan speed, in RPM. Default: 10000
```


## Usage Examples

```bash
./sensors-fans --warning 10000 --critical 20000
```

Output:

```text
dell_smm: dell_smm = 4714 RPM, dell_smm = 4428 RPM
```


## States

* OK if all fan speeds are below the warning threshold or if no fans are detected.
* WARN if any fan speed meets or exceeds `--warning` (default: 10000 RPM).
* CRIT if any fan speed meets or exceeds `--critical` (default: 20000 RPM).
* UNKNOWN if the platform is not supported by psutil.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| {sensor_name}_{label} | Number | Fan speed in RPM, one metric per fan sensor. |


## Troubleshooting

`Python module "psutil" is not installed.`  
Install `psutil`: `pip install psutil` or `dnf install python3-psutil`.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits: <https://github.com/giampaolo/psutil/blob/master/scripts/fans.py>
