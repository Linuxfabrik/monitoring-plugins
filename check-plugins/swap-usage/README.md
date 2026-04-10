# Check swap-usage

## Overview

Monitors swap space usage as a percentage of total swap. On Linux, optionally lists the top processes consuming the most swap to help identify the source of high usage.

**Data Collection:**

* Uses `psutil.swap_memory()` to retrieve swap statistics (total, used, free, percent)
* On Linux, also reports cumulative swap-in and swap-out bytes, and scans `/proc` for the top `--top` processes consuming the most swap
* The top-processes feature is not available on Windows

**Compatibility:**

* Linux


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/swap-usage> |
| Nagios/Icinga Check Name              | `check_swap_usage` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | Yes |
| 3rd Party Python modules              | `psutil` |


## Help

```text
usage: swap-usage [-h] [-V] [--always-ok] [-c CRIT] [--top TOP] [-w WARN]

Monitors swap space usage as a percentage of total swap. Optionally lists the
top processes consuming the most swap to help identify the source of high
usage. Alerts when usage exceeds the configured thresholds.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  -c, --critical CRIT  Threshold for swap usage, in percent. Default: 90
  --top TOP            Number of top processes consuming the most swap space
                       to list (not available on Windows). Default: 5
  -w, --warning WARN   Threshold for swap usage, in percent. Default: 70
```


## Usage Examples

```bash
./swap-usage --warning 70 --critical 90 --top 3
```

Output:

```text
77.7% - total: 2.0GiB, used: 1.6GiB, free: 456.1MiB
swapped in: 997.6MiB, swapped out: 2.6GiB (both cumulative)

Top 3 processes that use the most swap space:
1. php-fpm: 1.6GiB
2. icinga2: 7.7MiB
3. tuned: 3.9MiB
```


## States

* OK if swap usage is below the warning threshold.
* WARN if swap usage is >= `--warning` (default: 70%).
* CRIT if swap usage is >= `--critical` (default: 90%).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| free | Bytes | Free swap memory |
| sin | Bytes | Number of bytes the system has swapped in from disk (cumulative, Linux only) |
| sout | Bytes | Number of bytes the system has swapped out to disk (cumulative, Linux only) |
| total | Bytes | Total swap memory |
| usage_percent | Percentage | Swap usage calculated as (total - available) / total \* 100 |
| used | Bytes | Used swap memory |


## Troubleshooting

`Python module "psutil" is not installed.`
Install `psutil`: `pip install psutil` or `dnf install python3-psutil`.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
