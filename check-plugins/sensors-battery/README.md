# Check sensors-battery


## Overview

Reports battery status information including charge percentage, time remaining, and power source (AC or battery). Returns OK if no battery is installed or if metrics cannot be determined.

**Important Notes:**

* Run `sensors-detect --auto` beforehand to scan the system for hardware monitoring chips supported by libsensors / lm_sensors

**Data Collection:**

* Uses `psutil.sensors_battery()` to read battery charge percentage, time remaining, and power plug status


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/sensors-battery> |
| Nagios/Icinga Check Name              | `check_sensors_battery` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `psutil` |


## Help

```text
usage: sensors-battery [-h] [-V] [--always-ok] [-c CRIT] [-w WARN]

Reports battery status information including charge percentage, time
remaining, and power source (AC or battery). Returns OK if no battery is
installed or if metrics cannot be determined.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  -c, --critical CRIT  CRIT threshold for battery power left, in percent.
                       Default: 5
  -w, --warning WARN   WARN threshold for battery power left, in percent.
                       Default: 20
```


## Usage Examples

```bash
./sensors-battery --warning 20 --critical 5
```

Output:

```text
94.13%, 4h 40m left (not plugged in and discharging)
```


## States

* OK if battery power is above the warning threshold or if the battery is plugged in.
* OK if no battery is installed.
* WARN if battery power left is at or below `--warning` (default: 20%).
* CRIT if battery power left is at or below `--critical` (default: 5%).
* UNKNOWN if the platform is not supported by psutil.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| battery_percent | Percentage | Battery charge level. |
| battery_secsleft | Seconds | Estimated time remaining on battery. |


## Troubleshooting

`Python module "psutil" is not installed.`  
Install `psutil`: `pip install psutil` or `dnf install python3-psutil`.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits: <https://github.com/giampaolo/psutil/blob/master/scripts/battery.py>
