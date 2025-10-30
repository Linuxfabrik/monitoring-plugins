# Check memory-usage

## Overview

Monitors physical memory utilization with threshold-based alerting on overall memory usage percentage. Reports total, used, available, and free memory, plus platform-specific metrics (shared, buffers, cached).

**Alerting Logic:**

* Thresholds apply to overall memory usage percentage (default: WARN at 90%, CRIT at 95%)
* Single-point evaluation - alerts immediately when threshold exceeded (no sustained load detection)
* Uses psutil's `percent` calculation which accounts for platform-specific memory semantics

**Data Collection:**

* Physical memory statistics only (RAM, excludes swap)
* Reports `available` metric for cross-platform usable memory estimation
* Platform-specific metrics on Linux/BSD: shared, buffers, cached
* Optional top-N memory-consuming processes by RSS (`--top`, default: 5), aggregated by process name

**Compatibility:**

* Cross-platform: Linux, Windows, \*BSD, macOS
* Stateless check - no database or state persistence required

**Important Notes:**

* Memory usage calculations differ between tools (top, htop, free) due to different counting methods and kernel versions
* This check uses psutil's cross-platform `available` metric for consistency
* Process memory percentages may sum to >100% on Linux due to shared memory accounting


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/memory-usage> |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | Yes |
| 3rd Party Python modules              | `psutil` |


## Help

```text
usage: memory-usage [-h] [-V] [--always-ok] [-c CRIT] [--top TOP] [-w WARN]

Displays system memory usage and alerts on sustained high usage. Reports
total/used/available/free plus shared/buffers/cached, and evaluates WARN/CRIT
against the overall usage percentage. Perfdata is emitted for all fields so
you can graph trends over time. With `--top`, the most memory-consuming
processes are listed (by RSS and percentage) to aid quick diagnosis. Cross-
platform on all psutil-supported systems (Linux, Windows, *BSD, macOS).

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  -c, --critical CRIT  Set the critical threshold for memory usage (in
                       percent). Default: 95
  --top TOP            List x "Top most memory consuming processes". Use
                       `--top=0` to disable this feature. Default: 5
  -w, --warning WARN   Set the warning threshold for memory usage (in
                       percent). Default: 90
```


## Usage Examples

```bash
./memory-usage
./memory-usage --warning=90 --critical=95 --top=5
```

Output:

```text
36.2% - total: 3.8GiB, used: 1.1GiB, available: 2.4GiB, free: 989.4MiB
shared: 41.6MiB, buffers: 3.6MiB, cached: 1.8GiB

Top 5 most memory consuming processes:
1. php-fpm: 810.7MiB (20.7%)
2. forkit: 418.3MiB (10.7%)
3. kit_spare_001: 335.5MiB (8.6%)
4. mariadbd: 306.2MiB (7.8%)
5. icinga2: 63.8MiB (1.6%)
```


## States

* WARN or CRIT if total memory usage is above a given threshold.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| available | Bytes | The memory that can be given instantly to processes without the system going into swap. This is calculated by summing different memory values depending on the platform and it is supposed to be used to monitor actual memory usage in a cross platform fashion. |
| buffers | Bytes | Cache for things like file system metadata (Linux, BSD). |
| cached | Bytes | Cache for various things (Linux, BSD). |
| free | Bytes | Memory not being used at all (zeroed) that is readily available; note that this doesn't reflect the actual memory available (use `available` instead). `total - used` does not necessarily match `free`. |
| shared | Bytes | Memory that may be simultaneously accessed by multiple processes (Linux, BSD). |
| total | Bytes | Total physical memory (exclusive swap). |
| usage_percent | Percentage |  |
| used | Bytes | Memory used, calculated differently depending on the platform and designed for informational purposes only. `total - free` does not necessarily match `used`. |


## Troubleshooting

This checks sometimes reports \> 100% memory usage on Linux  
That's fine, the RES column in `top` says the same if you sum up all values for a process (attention: the values in top's RES column are KB by default), and compare process memory to total physical system memory. If machine does not swap, this is kind of Linux memory management mystery.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits: <https://github.com/giampaolo/psutil/blob/master/scripts/free.py>
