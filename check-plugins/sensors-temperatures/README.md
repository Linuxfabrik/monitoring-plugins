# Check sensors-temperatures


## Overview

Reports hardware temperature sensor readings (CPU, disk, chipset, etc.) in Celsius. Automatically checks against hardware-defined thresholds. Returns OK if the sensors are not supported by the OS.

**Important Notes:**

* Run `sensors-detect --auto` beforehand to scan the system for hardware monitoring chips supported by libsensors / lm_sensors

**Data Collection:**

* Uses `psutil.sensors_temperatures()` to read temperature data from hardware sensors
* Uses the hardware-defined high and critical thresholds for each sensor (no manual threshold configuration needed)


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/sensors-temperatures> |
| Nagios/Icinga Check Name              | `check_sensors_temperatures` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `psutil` |


## Help

```text
usage: sensors-temperatures [-h] [-V] [--always-ok] [--ignore IGNORE]
                            [--test TEST]

Reports hardware temperature sensor readings (CPU, disk, chipset, etc.) in
Celsius. Automatically checks against hardware-defined thresholds. Sensors can
be filtered by name using --ignore with regular expressions. Alerts when any
sensor exceeds its hardware-defined thresholds.

options:
  -h, --help       show this help message and exit
  -V, --version    show program's version number and exit
  --always-ok      Always returns OK.
  --ignore IGNORE  Ignore sensors matching this Python regular expression on
                   the sensor name or label. Can be specified multiple times.
                   Example: `--ignore="iwlwifi_1"` or `--ignore="^acpitz"`.
  --test TEST      For unit tests. Needs "path-to-stdout-file,path-to-stderr-
                   file,expected-retc".
```


## Usage Examples

```bash
./sensors-temperatures
```

Output:

```text
* nvme: Composite = 42.85°C, Sensor 1 = 42.85°C
* coretemp: Package id 0 = 52.0°C, Core 0 = 50.0°C, Core 1 = 52.0°C, Core 2 = 51.0°C, Core 3 = 50.0°C
* iwlwifi_1: iwlwifi_1 = 46.0°C
```


## States

* OK if all sensor readings are below their hardware-defined thresholds or if no sensors are detected.
* WARN if any sensor reading meets or exceeds its hardware-defined high threshold.
* CRIT if any sensor reading meets or exceeds its hardware-defined critical threshold.
* UNKNOWN if the platform is not supported by psutil.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| {sensor_name}_{label} | Number | Temperature in Celsius, one metric per sensor. |


## Troubleshooting

`Python module "psutil" is not installed.`  
Install `psutil`: `pip install psutil` or `dnf install python3-psutil`.

`Can't read any temperature.`  
No temperature sensors were detected. Run `sensors-detect --auto` to scan for available hardware monitoring chips.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits: <https://github.com/giampaolo/psutil/blob/master/scripts/temperatures.py>
