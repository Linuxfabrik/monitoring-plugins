# Check file-descriptors


## Overview

Checks the system-wide file descriptor usage as a percentage of the kernel maximum. Also lists the top processes consuming the most file descriptors to help identify the source of high usage. Alerts when usage exceeds the configured thresholds.

**Data Collection:**

* Depending on the user (e.g. running as `icinga`), sudo may be needed to read all process information
* Reads `/proc/sys/fs/file-nr` to obtain the number of allocated file handles and the system-wide maximum
* Uses `psutil.process_iter()` to aggregate open file descriptors per process name for the top-N list

**Compatibility:**

* Linux


## Fact Sheet

| Fact | Value |
|----|------|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/file-descriptors> |
| Nagios/Icinga Check Name              | `check_file_descriptors` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `psutil` |


## Help

```text
usage: file-descriptors [-h] [-V] [--always-ok] [-c CRIT] [--top TOP]
                        [-w WARN]

Checks the system-wide file descriptor usage as a percentage of the kernel
maximum. Also lists the top processes consuming the most file descriptors to
help identify the source of high usage. Alerts when usage exceeds the
configured thresholds.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  -c, --critical CRIT  CRIT threshold for file descriptor usage in percent.
                       Default: 95
  --top TOP            Number of top processes to list by open file
                       descriptors. Default: 5
  -w, --warning WARN   WARN threshold for file descriptor usage in percent.
                       Default: 90
```


## Usage Examples

```bash
./file-descriptors --warning 90 --critical 95
```

Output:

```text
2.2% file descriptors used (2.1K/94.1K)

Top 5 processes opening file descriptors:
1. mongod: 183 FD
2. master: 91 FD
3. mariadbd: 75 FD
4. icinga2: 62 FD
5. php-fpm: 48 FD
```


## States

* OK if file descriptor usage is below `--warning` (default: 90%).
* WARN if file descriptor usage is >= `--warning` (default: 90%).
* CRIT if file descriptor usage is >= `--critical` (default: 95%).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| fd | Percentage | Allocated file handles divided by the system-wide maximum, multiplied by 100. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
