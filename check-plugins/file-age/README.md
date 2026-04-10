# Check file-age


## Overview

Checks the time since last modification of one or more files or directories. Supports glob patterns (including recursive), SMB shares, and optional aggregation (mean or median) across all matched files. Can also alert on the number of files within a specific age range. Requires root or sudo.

**Important Notes:**

* SMB share access requires the optional `PySmbClient` and `smbprotocol` Python modules
* Recursive globs (`**`) can cause high memory usage on large directory trees
* The `--filename` and `--url` parameters are mutually exclusive
* Thresholds support Nagios ranges (e.g. `15:` to alert when files are *younger* than 15 seconds, or `10` for a simple upper bound)
* The `--warning-count` and `--critical-count` thresholds control how many files may exceed the age thresholds before the check alerts. This allows monitoring whether an application produces or removes files at the expected rate
* When more than 10 files are outside the thresholds, the output is truncated to the first and last 5 entries

**Data Collection:**

* Uses Python's `pathlib.Path.glob()` for local files and `lib.smb` for SMB shares
* Follows symbolic links
* Reads the `st_mtime` attribute from each file or directory
* Supports filtering by `--only-files` or `--only-dirs`
* Files that disappear during the check (e.g. temporary files) are silently skipped


## Fact Sheet

| Fact | Value |
|----|------|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/file-age> |
| Nagios/Icinga Check Name              | `check_file_age` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | Yes |
| 3rd Party Python modules              | `PySmbClient`, `smbprotocol` |


## Help

```text
usage: file-age [-h] [-V] [--always-ok] [-c CRIT]
                [--critical-count CRIT_COUNT] [--filename FILENAME]
                [--only-dirs] [--only-files] [--password PASSWORD]
                [--pattern PATTERN] [--perfdata-mode {mean,median,None}]
                [--timeout TIMEOUT] [-u URL] [--username USERNAME] [-w WARN]
                [--warning-count WARN_COUNT]

Checks the time since last modification of one or more files or directories.
Supports glob patterns (including recursive), SMB shares, and optional
aggregation (mean or median) across all matched files. Can also alert on the
number of files within a specific age range. Requires root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRIT   CRIT threshold for file age in seconds. Default: >=
                        31536000 (365d).
  --critical-count CRIT_COUNT
                        CRIT threshold for the number of files exceeding the
                        critical age. Default: > 0.
  --filename FILENAME   File or directory name to check (supports glob
                        patterns). Beware of recursive globs. Mutually
                        exclusive with --url.
  --only-dirs           Only consider directories, ignoring files.
  --only-files          Only consider files, ignoring directories.
  --password PASSWORD   Password for SMB authentication.
  --pattern PATTERN     SMB search pattern to match directory or file names.
                        Use `*` for multiple characters and `?` for a single
                        character. Does not support regex. Default: *
  --perfdata-mode {mean,median,None}
                        Aggregation mode for performance data across matched
                        files. Default: None
  --timeout TIMEOUT     Network timeout in seconds. Default: 3
  -u, --url URL         SMB URL of the file or directory to check, starting
                        with `smb://`. Mutually exclusive with --filename.
  --username USERNAME   Username for SMB authentication.
  -w, --warning WARN    WARN threshold for file age in seconds. Default: >=
                        2592000 (30d).
  --warning-count WARN_COUNT
                        WARN threshold for the number of files exceeding the
                        warning age. Default: > 0.
```


## Usage Examples

```bash
# file is more than 5 seconds old -> warning
# file is more than 10 seconds old -> critical
./file-age --filename='/path/to/file' --warning=5 --critical=10

# same thresholds, but checking multiple files
./file-age --filename='/path/to/files/*' --warning=5 --critical=10

# same thresholds, but recursive (might use a lot of memory)
./file-age --filename='/path/to/files/**/*' --warning=5 --critical=10

# Check if an application creates at least 2 files every 10s, else throw a warning.
# If it is missing for more than 20s, throw a critical.
./file-age --filename='/path/to/files/*' --warning='15:' --warning-count='3:' --critical='20:' --critical-count='2:'

# Check if an application removes files fast enough.
# If there are more than 2 files in the last 10s, throw a warning.
# If there are more than 3 files in the last 15s, throw a critical.
# No files are ok.
./file-age --filename='/path/to/files/*' --warning='10:' --warning-count=2 --critical='15:' --critical-count=3
```

Output:

```text
Everything is ok. 3 items checked, all within the specified count and time range.

* /tmp/test/file-1d-ago: 1D 56m
* /tmp/test/file-2d-ago: 2D 56m
* /tmp/test/file-today: 56m 11s
```

```text
Everything is ok. 3 items checked. All within the specified count range, but 2 outside "1D" time range, and 0 outside "1Y" time range.

* /tmp/test/file-1d-ago: 1D 56m [WARNING]
* /tmp/test/file-2d-ago: 2D 56m [WARNING]
* /tmp/test/file-today: 56m 1s
```

```text
1 item outside count range "0" and outside "@86400" time range. 2 items outside count range "0" and outside "0:86400" time range. 3 items checked.

* /tmp/test/file-1d-ago: 1D 55m [CRITICAL]
* /tmp/test/file-2d-ago: 2D 55m [CRITICAL]
* /tmp/test/file-today: 55m 47s [WARNING]
```


## States

* OK if all items are within the specified count and time ranges.
* WARN if the number of items exceeding the warning age is outside the `--warning-count` range (default: > 0).
* CRIT if the number of items exceeding the critical age is outside the `--critical-count` range (default: > 0).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

The `--perfdata-mode` parameter decides which aggregation mode is used. The check does not return any performance data for empty directories (even with the flag set).

| Name | Type | Description |
|----|----|----|
| mean-ages | Seconds | The mean (average) age across all matched files. Only with `--perfdata-mode=mean`. |
| median-ages | Seconds | The median age across all matched files. Only with `--perfdata-mode=median`. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
