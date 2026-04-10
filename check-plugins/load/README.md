# Check load


## Overview

Reports the average system load per CPU over the last 1, 5, and 15 minutes. Load represents the average number of processes waiting in the run queue plus those currently executing. The values are normalized by dividing by the number of CPUs, making machines with different CPU counts comparable and simplifying Grafana panel design.

**Data Collection:**

* Uses `psutil.getloadavg()` (psutil >= 5.6.2) for cross-platform support, falls back to `os.getloadavg()` on older psutil versions (Linux only)
* Divides raw load averages by `psutil.cpu_count()` to normalize per CPU

**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/load> |
| Nagios/Icinga Check Name              | `check_load` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `psutil` |


## Help

```text
usage: load [-h] [-V] [--always-ok] [-c CRIT] [-w WARN]

Reports the average system load per CPU over the last 1, 5, and 15 minutes.
Load represents the average number of processes waiting in the run queue plus
those currently executing. The values are normalized by dividing by the number
of CPUs. Alerts when the load average exceeds the configured thresholds.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  -c, --critical CRIT  CRIT threshold for load15 per CPU. Default: 5.0
  -w, --warning WARN   WARN threshold for load15 per CPU. Default: 1.15
```


## Usage Examples

```bash
./load --warning 1.15 --critical 5.0
```

Output:

```text
Avg per CPU: 0.11 0.12 0.09
```


## States

* OK if load15 per CPU is below `--warning` (default: 1.15).
* WARN if load15 per CPU is >= `--warning` (default: 1.15).
* CRIT if load15 per CPU is >= `--critical` (default: 5.0).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| load1 | Number | 1-minute load average, normalized per CPU. |
| load15 | Number | 15-minute load average, normalized per CPU. |
| load5 | Number | 5-minute load average, normalized per CPU. |


## Troubleshooting

`Python module "psutil" is not installed.`
Install `psutil`: `pip install psutil` or `dnf install python3-psutil`.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
