# Check uptime

## Overview

Reports how long the system has been running since the last boot. Optionally displays the timestamp and duration of the last downtime - the more frequently the check runs, the more accurate the downtime information will be.

**Data Collection:**

* Uses `psutil.boot_time()` to determine the boot timestamp and calculate uptime
* Stores timestamps in a SQLite database to detect reboots and calculate downtime duration between runs
* On the first run after a reboot, reports the approximate time and duration of the last power event

**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/uptime> |
| Nagios/Icinga Check Name              | `check_uptime` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | Yes |
| 3rd Party Python modules              | `psutil` |
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-monitoring-plugins-uptime.db` |


## Help

```text
usage: uptime [-h] [-V] [--always-ok] [-c CRIT] [-w WARN]

Reports how long the system has been running since the last boot. Optionally
displays the timestamp and duration of the last downtime - the more frequently
the check runs, the more accurate the downtime information will be. Alerts
when uptime exceeds the configured thresholds (useful for detecting servers
that have not been rebooted after patching).

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  -c, --critical CRIT  Threshold for the uptime in a human-readable format (s
                       = seconds, m = minutes, h = hours, D = days, W = weeks,
                       M = months, Y = years). Supports Nagios ranges.
                       Example: `:1Y` alerts if uptime is greater than 1 year.
                       Default: :1Y
  -w, --warning WARN   Threshold for the uptime in a human-readable format (s
                       = seconds, m = minutes, h = hours, D = days, W = weeks,
                       M = months, Y = years). Supports Nagios ranges.
                       Example: `5m:180D` warns if uptime is not between 5
                       minutes and 180 days. Default: 3m:180D
```


## Usage Examples

Warn if more than 180 days, crit if more than 365 days up:

```bash
./uptime --warning=180D --critical=1Y
```

Output:

```text
Up 2W 6h since 2024-03-30 08:08:01 (thresholds 180D/1Y)
```

Warn if less than 5 minutes up:

```bash
./uptime --warning=5m:
```

Output:

```text
Up 4m since 2024-03-30 08:08:01 (thresholds 5m:/:1Y) [WARNING]
```

Warn if not in 5 minutes to 6 months and 5 days uptime. If more than 2 years up, return crit:

```bash
./uptime --warning=5m:6M5D --critical=2Y
```

Output over time:

```text
Up 1m 39s since 2024-03-30 08:08:01 (thresholds 5m:6M5D/2Y) [WARNING]
Up 6M since 2024-03-30 08:08:01 (thresholds 5m:6M5D/2Y)
Up 6M 6D since 2024-03-30 08:08:01 (thresholds 5m:6M5D/2Y) [WARNING]
```

Output after planned/unplanned shutdown and subsequent boot:

```text
Up 1m 57s since 2024-11-22 14:44:31 (thresholds 3m:180D/:1Y) [WARNING].
Last power event at ~2024-11-22 14:44:18 and down for ~13s.
```


## States

* OK if uptime is within the configured range.
* WARN if uptime is outside `--warning` range (default: `3m:180D`).
* CRIT if uptime is outside `--critical` range (default: `:1Y`).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| uptime | Seconds | Uptime in seconds |


## Troubleshooting

`Python module "psutil" is not installed.`
Install `psutil`: `pip install psutil` or `dnf install python3-psutil`.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
