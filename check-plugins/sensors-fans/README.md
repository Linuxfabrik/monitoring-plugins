# Check sensors-fans

## Overview

Return the speed of the hardware fans. Fan speed is expressed in RPM (rounds per minute). The plugin returns 'OK' if no fans are found.

Hints:

* Run `sensors-detect --auto` beforehand to scan your system for the various hardware monitoring chips or sensors supported by libsensors or, more generally, by the lm_sensors tool suite.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/sensors-fans> |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `psutil` |


## Help

```text
usage: sensors-fans [-h] [-V] [--always-ok] [-c CRIT] [-w WARN]

Return hardware fans speed. Fan speed is expressed in RPM (rounds per minute).

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  -c, --critical CRIT  Set the critical threshold for fan speed in RPM.
                       Default: 20000
  -w, --warning WARN   Set the warning threshold for fan speed in RPM.
                       Default: 10000
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

* WARN or CRIT if fan speed (RPM) is above a given threshold.


## Perfdata / Metrics

* for each fan: its speed (RPM)


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits: <https://github.com/giampaolo/psutil/blob/master/scripts/fans.py>
