# Check load

## Overview

On the *No Sheep* blog, Zachary Tirrell [defines the load average](http://nosheep.net/story/defining-unix-load-average/) on GNU/Linux operating system:

> *In short it is the average sum of the number of processes waiting in the run-queue plus the number currently executing over 1, 5, and 15 minutes time periods.*

Alerts on load average are only set on 15 minutes time period. For this, the check gets the number of CPU cores to *normalize* load values *automatically*. Loads are computed by dividing the 15 minutes average load per CPU(s) count. For example, if you have 3 CPUs and the 15 minutes load is 6.0, then you get a warning because of (6 / 3) \>= 1.15, where 1.15 is the default warning threshold. Main advantage of this method is to make machines comparable and making the design of Grafana panels easier.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/load> |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `psutil` |


## Help

```text
usage: load [-h] [-V] [--always-ok] [-c CRIT] [-w WARN]

Return the average system load per CPU over the last 1, 5 and 15 minutes. In
short, "load" is the average sum of the number of processes waiting in the
run-queue plus the number currently executing over 1, 5, and 15 minute time
periods.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  -c, --critical CRIT  Set the critical threshold for load15 per CPU. Default:
                       5.0
  -w, --warning WARN   Set the warning threshold for load15 per CPU. Default:
                       1.15
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

* WARN if load15 \>= 1.15 (default)
* CRIT if load15 \>= 5.00 (default)


## Perfdata / Metrics

| Name   | Type   | Description |
|--------|--------|-------------|
| load1  | Number | load1       |
| load5  | Number | load5       |
| load15 | Number | load15      |

A value below 1 indicates satisfactory resource utilization and minimal wait times. A value above 1 indicates resource saturation and some amount of processing delay.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
