# Check path-rw-test

## Overview

Tests if a path is writable and readable by creating, writing, reading, and deleting a temporary file. Especially useful for mounted filesystems such as NFS or SMB where the mount may silently become read-only or unresponsive. The local temporary directory is always tested as a baseline. Alerts if the path is not writable or readable.

**Data Collection:**

* Creates a temporary file in each specified path (and always in the system's temp directory)
* Writes a test string, reads it back, then deletes the temporary file
* Reports which paths failed and which were tested

**Compatibility:**

* Cross-platform: Linux and Windows
* May require root or sudo depending on the paths being tested


## Fact Sheet

| Fact | Value |
|----|----| 
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/path-rw-test> |
| Nagios/Icinga Check Name              | `check_path_rw_test` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | Yes |


## Help

```text
usage: path-rw-test [-h] [-V] [--always-ok] [--path PATH]
                    [--severity {warn,crit}]

Tests if a path is writable and readable by creating, writing, reading, and
deleting a temporary file. Especially useful for mounted filesystems such as
NFS or SMB where the mount may silently become read-only or unresponsive. The
local temporary directory is always tested as a baseline. Alerts if the path
is not writable or readable. Requires root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --path PATH           Path to test for read/write access by creating and
                        deleting a temporary file. Can be specified multiple
                        times. Default: ['/tmp']
  --severity {warn,crit}
                        Severity for alerting. Default: warn
```


## Usage Examples

```bash
./path-rw-test --path /mnt/nfs --path /mnt/smb --path /usr --severity warn
```

Output:

```text
Error creating/writing/reading/deleting file in `/usr` ([Errno 13] Permission denied: '/usr/tmptbt8daho'). Tested: /tmp, /mnt/nfs, /mnt/smb, /usr
```


## States

* OK if all paths are writable and readable.
* WARN if `--severity` is set to `warn` (default) and any path fails the read/write test.
* CRIT if `--severity` is set to `crit` and any path fails the read/write test.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
