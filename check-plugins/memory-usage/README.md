# Check memory-usage


## Overview

Monitors system memory usage and alerts when the overall usage percentage exceeds the configured thresholds. Reports total, used, available, and free memory plus shared, buffers, and cached values. Optionally lists the top memory-consuming processes via `--top` to help identify the source of high usage.

**Important Notes:**

* Memory usage calculations differ between tools (top, htop, free) due to different counting methods and kernel versions. This check uses psutil's cross-platform `available` metric for consistency
* Process memory percentages may sum to >100% on Linux due to shared memory accounting
* The `--top` list reports RSS (Resident Set Size) per process from psutil's `memory_info()`. RSS is the non-swapped physical memory a process has used. On UNIX it matches the `top` RES column. On Windows it maps to `WorkingSetSize`

**Data Collection:**

* Physical memory statistics only (RAM, excludes swap)
* Reports the `available` metric for cross-platform usable memory estimation
* Platform-specific metrics on Linux/BSD: shared, buffers, cached
* Optional top-N memory-consuming processes by RSS (`--top`, default: 5), aggregated by process name

**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/memory-usage> |
| Nagios/Icinga Check Name              | `check_memory_usage` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | Yes |
| 3rd Party Python modules              | `psutil` |


## Help

```text
usage: memory-usage [-h] [-V] [--always-ok] [-c CRIT] [--top TOP] [-w WARN]

Monitors system memory usage and alerts when the overall usage percentage
exceeds the configured thresholds. Reports total, used, available, and free
memory plus shared, buffers, and cached values. Optionally lists the top
memory-consuming processes via --top to help identify the source of high
usage.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  -c, --critical CRIT  CRIT threshold for memory usage in percent. Default: 95
  --top TOP            Number of top memory-consuming processes to list. Use
                       `--top=0` to disable. Default: 5
  -w, --warning WARN   WARN threshold for memory usage in percent. Default: 90
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

* OK if memory usage is below `--warning` (default: 90%).
* WARN if memory usage is >= `--warning` (default: 90%).
* CRIT if memory usage is >= `--critical` (default: 95%).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| available | Bytes | Memory that can be given instantly to processes without the system going into swap. Calculated by summing different memory values depending on the platform. Intended to monitor actual memory usage in a cross-platform fashion. |
| buffers | Bytes | Cache for things like file system metadata (Linux, BSD). |
| cached | Bytes | Cache for various things (Linux, BSD). |
| free | Bytes | Memory not being used at all (zeroed) that is readily available. Note that this does not reflect the actual available memory (use `available` instead). `total - used` does not necessarily match `free`. |
| shared | Bytes | Memory that may be simultaneously accessed by multiple processes (Linux, BSD). |
| total | Bytes | Total physical memory (exclusive of swap). |
| usage_percent | Percentage | Overall memory usage percentage. |
| used | Bytes | Memory used, calculated differently depending on the platform and designed for informational purposes only. `total - free` does not necessarily match `used`. |


## Troubleshooting

`This check sometimes reports > 100% memory usage on Linux`
That can happen. The RES column in `top` shows the same if you sum up all values for a process and compare process memory to total physical system memory. If the machine does not swap, this is a Linux memory management side effect.

`Python module "psutil" is not installed.`
Install `psutil`: `pip install psutil` or `dnf install python3-psutil`.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits: <https://github.com/giampaolo/psutil/blob/master/scripts/free.py>
