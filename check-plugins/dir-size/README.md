# Check dir-size

## Overview

Checks directory sizes against configurable thresholds using human-readable units (e.g. 25M, 1G). Supports glob patterns and SMB shares. Alerts when any directory exceeds the configured size thresholds. Requires root or sudo.

**Important Notes:**

- SMB share access requires the optional `PySmbClient` and `smbprotocol` Python modules
- Recursive globs (`**`) can cause high memory usage on large directory trees
- The `--dirname` and `--url` parameters are mutually exclusive
- Thresholds accept human-readable units (base 1024). Valid qualifiers: `b`, `k`/`kb`/`kib`, `m`/`mb`/`mib`, `g`/`gb`/`gib`, etc. Nagios ranges are supported (e.g. `:1G` alerts if size exceeds 1 GiB, `6 KiB:10k` alerts outside the 6-10 KiB range)
- Returns UNKNOWN if no directories are found

**Data Collection:**

- Uses Python's `glob.iglob()` for local directories and `lib.smb` for SMB shares
- Follows symbolic links
- Reads `st_size` from `os.stat()` for each matched directory
- Only directories are checked

## Fact Sheet

| Fact                             | Value                                                                                |
| -------------------------------- | ------------------------------------------------------------------------------------ |
| Check Plugin Download            | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/dir-size> |
| Nagios/Icinga Check Name         | `check_dir_size`                                                                     |
| Check Interval Recommendation    | Every 15 minutes                                                                     |
| Can be called without parameters | Yes                                                                                  |
| Runs on                          | Cross-platform                                                                       |
| Compiled for Windows             | Yes                                                                                  |
| 3rd Party Python modules         | optional: `PySmbClient`, `smbprotocol`                                               |

## Help

```text
usage: dir-size [-h] [-V] [--always-ok] [-c CRIT] [--dirname DIRNAME]
                [--pattern PATTERN] [--password PASSWORD] [--timeout TIMEOUT]
                [-u URL] [--username USERNAME] [-w WARN]

Checks directory sizes against configurable thresholds using human-readable units
(e.g. 25M, 1G). Supports glob patterns and SMB shares. Alerts when any directory
exceeds the configured size thresholds. Requires root or sudo.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  -c, --critical CRIT  CRIT threshold for the directory size in human-readable
                       format (base is always 1024; valid qualifiers are b,
                       k/kb/kib, m/mb/mib, g/gb/gib etc.). Supports Nagios
                       ranges. Example: `:1G` alerts if size is greater than 1
                       GiB. Default: 1G
  --dirname DIRNAME    Path of the directory to check. Supports glob patterns
                       according to
                       https://docs.python.org/3/library/glob.html. Recursive
                       globs can cause high memory usage. Mutually exclusive
                       with `-u` / `--url`. Example: `--dirname /tmp/*`.
  --pattern PATTERN    Search string to match against SMB directory names. Use
                       `*` as a wildcard for multiple characters and `?` for a
                       single character. Does not support regex patterns.
                       Default: *
  --password PASSWORD  Password for SMB authentication.
  --timeout TIMEOUT    Network timeout in seconds. Default: 3 (seconds)
  -u, --url URL        URL of the directory to check, starting with `smb://`.
                       Mutually exclusive with `--dirname`. Example: `--url
                       smb://server/share/path`.
  --username USERNAME  Username for SMB authentication.
  -w, --warning WARN   WARN threshold for the directory size in human-readable
                       format (base is always 1024; valid qualifiers are b,
                       k/kb/kib, m/mb/mib, g/gb/gib etc.). Supports Nagios
                       ranges. Example: `:1G` alerts if size is greater than 1
                       GiB. Default: 25M
```

## Usage Examples

Warn if directory is greater than 25M, crit if it is greater than 1G:

```bash
./dir-size --dirname=/var/log/ --warning=25M --critical=1G
```

Output:

```text
1 file checked. 1 is outside the given size thresholds (25M/1G). Checked /var/log/: 5.1GiB [CRITICAL]
```

Warn if directory are larger than 150 MiB, crit if files are larger than 300
MiB (plus showing the various formats):

```bash
./dir-size --dirname '/usr/*' --warning ':150MiB' --critical ':300MiB'
```

Output:

```text
11 files checked. 6 are outside the given size thresholds (:150MiB/:300MiB).

Directory    ! Size     ! State
-------------+----------+-----------
/usr/bin     ! 479.6MiB ! [CRITICAL]
/usr/games   ! 0.0B     ! [OK]
/usr/include ! 19.8MiB  ! [OK]
/usr/lib     ! 2.6GiB   ! [CRITICAL]
/usr/lib64   ! 1.1GiB   ! [CRITICAL]
/usr/libexec ! 692.5MiB ! [CRITICAL]
/usr/local   ! 12.9MiB  ! [OK]
/usr/sbin    ! 267.7MiB ! [WARNING]
/usr/share   ! 535.6MiB ! [CRITICAL]
/usr/src     ! 952.4KiB ! [OK]
/usr/tmp     ! 0.0B     ! [OK]
```

The same as above, but recursive (might use a lot of memory):

```bash
./file-size --dirname '/usr/**/*bin' --warning ':100KiB' --critical ':3MiB'
```

Output:

```text
3 files checked. 1 is outside the given size thresholds (:1MiB/:3MiB).

Directory        ! Size     ! State
-----------------+----------+-----------
/usr/local/bin   ! 12.9MiB  ! [CRITICAL]
/usr/local/sbin  ! 0.0B     ! [OK]
/usr/src/annobin ! 952.4KiB ! [WARNING]
```

## States

- OK if all found directories are within the given size thresholds (default: 25M/1G).
- WARN if any directory exceeds `--warning` (default: 25M).
- CRIT if any directory exceeds `--critical` (default: 1G).
- UNKNOWN if no directories are found.
- `--always-ok` suppresses all alerts and always returns OK.

## Perfdata / Metrics

There is no perfdata.

## Credits, License

- Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
- License: The Unlicense, see [LICENSE file](https://unlicense.org/).
