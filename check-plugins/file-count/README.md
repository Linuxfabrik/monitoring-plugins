# Check file-count


## Overview

Counts the number of files matching a glob pattern and alerts when the count exceeds the configured thresholds. Can filter by modification time range, restrict to files or directories only, and supports SMB shares.

**Important Notes:**

* SMB share access requires the optional `PySmbClient` and `smbprotocol` Python modules
* Recursive globs (`**`) can cause high memory usage on large directory trees
* The `--filename` and `--url` parameters are mutually exclusive
* Thresholds support Nagios ranges. Use `--warning 1` to check for file existence (warn if missing) or `--warning '~:0'` to check for file absence (warn if present)
* `--timerange` accepts Nagios range syntax in seconds. Only files whose modification time falls within this range are counted
* Depending on the file and user (e.g. running as `icinga`), sudo (sudoers) may be needed

**Data Collection:**

* Uses Python's `pathlib.Path.glob()` for local files and `lib.smb` for SMB shares
* Applies `os.stat()` once per item to determine type and modification time, minimizing syscalls
* When both `--warning` and `--critical` thresholds are simple numeric values, the check breaks early once the threshold is exceeded (to save time and resources on directories with millions of files)


## Fact Sheet

| Fact | Value |
|----|------|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/file-count> |
| Nagios/Icinga Check Name              | `check_file_count` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | Yes |
| 3rd Party Python modules              | `PySmbClient`, `smbprotocol` |


## Help

```text
usage: file-count [-h] [-V] [--always-ok] [-c CRIT] [--filename FILENAME]
                  [--only-dirs] [--only-files] [--password PASSWORD]
                  [--pattern PATTERN] [--timeout TIMEOUT]
                  [--timerange TIMERANGE] [-u URL] [--username USERNAME]
                  [-w WARN]

Counts the number of files matching a glob pattern and alerts when the count
exceeds the configured thresholds. Can filter by modification time range,
restrict to files or directories only, and supports SMB shares.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRIT   CRIT threshold for the number of matching files.
  --filename FILENAME   File or directory name to check (supports glob
                        patterns). Beware of recursive globs. Mutually
                        exclusive with --url.
  --only-dirs           Only count directories, ignoring files.
  --only-files          Only count files, ignoring directories.
  --password PASSWORD   Password for SMB authentication.
  --pattern PATTERN     SMB search pattern to match directory or file names.
                        Use `*` for multiple characters and `?` for a single
                        character. Does not support regex. Default: *
  --timeout TIMEOUT     Network timeout in seconds. Default: 3
  --timerange TIMERANGE
                        Only count files modified within this time range in
                        seconds.
  -u, --url URL         SMB URL of the file or directory to check, starting
                        with `smb://`. Mutually exclusive with --filename.
  --username USERNAME   Username for SMB authentication.
  -w, --warning WARN    WARN threshold for the number of matching files.
```


## Usage Examples

```bash
# check the existence of a file; if missing warn
./file-count --filename '/path/to/file' --warning 1

# check the absence of a file; if present warn
./file-count --filename '/path/to/file' --warning '~:0'

# check that there are at least 5 `.md` files, else warn
./file-count --filename '/path/to/*.md' --warning 5

# check that there are at least 5 files modified in the last 10 seconds, else warn
./file-count --filename '/path/to/file/*' --warning 5 --timerange 5

# check a SMB share
./file-count  --username USER --password mysecret --pattern '*' --timeout 3 --url smb://\\server\path
```

Output:

```text
Found 1 matching file (thresholds 1/None)|'file_count'=1;1;;0;
```


## States

* OK if the file count is within the given thresholds (Nagios ranges).
* WARN if the file count is outside `--warning`.
* CRIT if the file count is outside `--critical`.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| file_count | Number | Count of files matching the glob pattern and filters. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
