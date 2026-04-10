# Check file-size

## Overview

Checks file sizes against configurable thresholds using human-readable units (e.g. 25M, 1G). Supports glob patterns and SMB shares. Directories are skipped because their reported size is not meaningful across filesystems. Alerts when any file exceeds the configured size thresholds. Requires root or sudo.

**Data Collection:**

* Uses Python's `glob.iglob()` for local files and `lib.smb` for SMB shares
* Follows symbolic links
* Reads `st_size` from `os.stat()` for each matched file
* Directories are silently skipped

**Compatibility:**

* Cross-platform: Linux and Windows
* SMB share access requires the optional `PySmbClient` and `smbprotocol` Python modules
* Recursive globs (`**`) can cause high memory usage on large directory trees

**Important Notes:**

* The `--filename` and `--url` parameters are mutually exclusive
* Thresholds accept human-readable units (base 1024). Valid qualifiers: `b`, `k`/`kb`/`kib`, `m`/`mb`/`mib`, `g`/`gb`/`gib`, etc. Nagios ranges are supported (e.g. `:1G` alerts if size exceeds 1 GiB, `6 KiB:10k` alerts outside the 6-10 KiB range)
* Returns UNKNOWN if no files are found


## Fact Sheet

| Fact | Value |
|----|------|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/file-size> |
| Nagios/Icinga Check Name              | `check_file_size` |
| Check Interval Recommendation         | Every 15 minutes |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | Yes |
| 3rd Party Python modules              | optional: `PySmbClient`, `smbprotocol` |


## Help

```text
usage: file-size [-h] [-V] [--always-ok] [-c CRIT] [--filename FILENAME]
                 [--pattern PATTERN] [--password PASSWORD] [--timeout TIMEOUT]
                 [-u URL] [--username USERNAME] [-w WARN]

Checks file sizes against configurable thresholds using human-readable units
(e.g. 25M, 1G). Supports glob patterns and SMB shares. Directories are skipped
because their reported size is not meaningful across filesystems. Alerts when
any file exceeds the configured size thresholds. Requires root or sudo.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  -c, --critical CRIT  CRIT threshold for the file size in human-readable
                       format (base is always 1024; valid qualifiers are b,
                       k/kb/kib, m/mb/mib, g/gb/gib etc.). Supports Nagios
                       ranges. Example: `:1G` alerts if size is greater than 1
                       GiB. Default: 1G
  --filename FILENAME  Path of the file to check. Supports glob patterns
                       according to
                       https://docs.python.org/3/library/glob.html. Recursive
                       globs can cause high memory usage. Mutually exclusive
                       with `-u` / `--url`. Example: `--filename /tmp/*.log`.
  --pattern PATTERN    Search string to match against SMB directory or file
                       names. Use `*` as a wildcard for multiple characters
                       and `?` for a single character. Does not support regex
                       patterns. Default: *
  --password PASSWORD  Password for SMB authentication.
  --timeout TIMEOUT    Network timeout in seconds. Default: 3 (seconds)
  -u, --url URL        URL of the file to check, starting with `smb://`.
                       Mutually exclusive with `--filename`. Example: `--url
                       smb://server/share/path`.
  --username USERNAME  Username for SMB authentication.
  -w, --warning WARN   WARN threshold for the file size in human-readable
                       format (base is always 1024; valid qualifiers are b,
                       k/kb/kib, m/mb/mib, g/gb/gib etc.). Supports Nagios
                       ranges. Example: `:1G` alerts if size is greater than 1
                       GiB. Default: 25M
```


## Usage Examples

Warn if file is greater than 25M, crit if it is greater than 1G:

```bash
./file-size --filename=/var/log/coolwsd.log --warning=25M --critical=1G
```

Output:

```text
1 file checked. It is within the given size thresholds (25M/1G). Checked /var/log/coolwsd.log: 119.9KiB
```

Warn if files are not within 6 to 10 KB, crit if files are larger than 14 KB (plus showing the various formats):

```bash
./file-size --filename '/path/to/m*.png*' --warning '6 KiB:10k' --critical ':14 KB'
```

Output:

```text
28 files checked. 21 are outside the given size thresholds (6 KiB:10k/:14 KB).

File                                   ! Size    ! State      
---------------------------------------+---------+------------
mailq.png                              ! 5.2KiB  ! [WARNING]  
matomo-version.png                     ! 7.2KiB  ! [OK]       
memory-usage.png                       ! 12.4KiB ! [WARNING]  
mydumper-version.png                   ! 8.3KiB  ! [OK]       
mysql-aria.png                         ! 12.2KiB ! [WARNING]  
mysql-connections.png                  ! 15.3KiB ! [CRITICAL] 
mysql-database-metrics.png             ! 15.2KiB ! [CRITICAL] 
mysql-innodb-buffer-pool-instances.png ! 12.7KiB ! [WARNING]  
mysql-innodb-buffer-pool-size.png      ! 15.5KiB ! [CRITICAL] 
mysql-innodb-log-waits.png             ! 9.2KiB  ! [OK]       
mysql-joins.png                        ! 11.7KiB ! [WARNING]  
mysql-logfile.png                      ! 15.5KiB ! [CRITICAL] 
mysql-memory.png                       ! 16.5KiB ! [CRITICAL] 
mysql-open-files.png                   ! 8.8KiB  ! [OK]       
mysql-perf-metrics.png                 ! 6.9KiB  ! [OK]       
mysql-slow-queries.png                 ! 9.2KiB  ! [OK]       
mysql-sorts.png                        ! 10.9KiB ! [WARNING]  
mysql-storage-engines.png              ! 16.9KiB ! [CRITICAL] 
mysql-system.png                       ! 19.6KiB ! [CRITICAL] 
mysql-table-cache.png                  ! 26.3KiB ! [CRITICAL] 
mysql-table-definition-cache.png       ! 14.0KiB ! [CRITICAL] 
mysql-table-indexes.png                ! 9.9KiB  ! [WARNING]  
mysql-table-locks.png                  ! 10.3KiB ! [WARNING]  
mysql-temp-tables.png                  ! 12.3KiB ! [WARNING]  
mysql-thread-cache.png                 ! 10.2KiB ! [WARNING]  
mysql-traffic.png                      ! 10.8KiB ! [WARNING]  
mysql-user-security.png                ! 16.3KiB ! [CRITICAL] 
mysql-version.png                      ! 10.3KiB ! [WARNING]
```

The same as above, but recursive (might use a lot of memory):

```bash
./file-size --filename '/path/to/**/m*.png*' --warning 6000B:10K --critical :14KB
```


## States

* OK if all found files are within the given size thresholds (default: 25M/1G).
* WARN if any file exceeds `--warning` (default: 25M).
* CRIT if any file exceeds `--critical` (default: 1G).
* UNKNOWN if no files are found.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
