# Check file-count

## Overview

Checks the number of matching files or directories found. It can be also used to check the existence / absence of a single file.

Depending on the file and user (e.g. running as *icinga*), sudo (sudoers) is needed. It supports globs in accordance with [Python 3](https://docs.python.org/3/library/pathlib.html#pathlib.Path.glob). Beware that using recursive globs might cause high memory usage. Optionally, the check can be restricted to only consider files that were modified in a given timerange.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/file-count> |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
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
                        Supports Nagios ranges.
  --filename FILENAME   File or directory name to check (supports glob
                        patterns). Beware of recursive globs. Mutually
                        exclusive with --url.
  --only-dirs           Only count directories, ignoring files.
  --only-files          Only count files, ignoring directories.
  --password PASSWORD   Password for SMB authentication.
  --pattern PATTERN     SMB search pattern to match directory or file names.
                        Use `*` for multiple characters and `?` for a single
                        character. Does not support regex. Default: *.
  --timeout TIMEOUT     Network timeout in seconds. Default: 3.
  --timerange TIMERANGE
                        Only count files modified within this time range in
                        seconds. Supports Nagios ranges.
  -u, --url URL         SMB URL of the file or directory to check, starting
                        with `smb://`. Mutually exclusive with --filename.
  --username USERNAME   Username for SMB authentication.
  -w, --warning WARN    WARN threshold for the number of matching files.
                        Supports Nagios ranges.
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

* OK if all the found files (in accordance with the filtering parameters) are within the given thresholds (ranges).
* Otherwise CRIT or WARN.


## Perfdata / Metrics

* `file_count`: Number. Count of the files that were found in accordance with the filtering parameters.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
