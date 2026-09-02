# Check path-rw-test


## Overview

Tests if a path is writable and readable by creating, writing, reading, and deleting a temporary file. Especially useful for mounted filesystems such as NFS or SMB where the mount may silently become read-only or unresponsive. The local temporary directory is always tested as a baseline. A path on a network filesystem whose server has stopped answering does not fail, it blocks, and it blocks in a way no timeout inside a process reaches. Each path is therefore tested in a process of its own, all of them at the same time and under one shared deadline, so the check stays within `--timeout` however many paths are unreachable, and a path that misses the deadline is reported like one that cannot be written to. Alerts if the path is not writable, not readable, or does not answer at all.

**Important Notes:**

* A path whose server is gone is reported as `no answer within Ns` and graded by `--severity`, like every other failure. The paths that did answer are still reported, so one unreachable mount does not cost the check everything else it knows.
* A path named twice, which is what naming the temporary directory explicitly does next to the default, is tested and reported once.

**Data Collection:**

* May require root or sudo depending on the paths being tested
* By design this check creates, writes, reads and deletes a probe file in whatever directory it is pointed at, with root privileges when run via sudo. That is inherent to its purpose, so the path cannot be confined to a fixed directory: anyone who can invoke the check through sudo can test write access anywhere on the system. Securing that capability is the operator's responsibility. Restrict the permitted arguments in your sudoers entry if your threat model requires it.

* Creates a temporary file in each specified path (and always in the system's temp directory)
* Writes a test string, reads it back, then deletes the temporary file
* Gives every path `--timeout` seconds to answer, all of them at the same time, and gives up on the ones that do not
* Reports which paths failed and which were tested


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/path-rw-test> |
| Nagios/Icinga Check Name              | `check_path_rw_test` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | Yes |


## Help

```text
usage: path-rw-test [-h] [-V] [--always-ok] [--path PATH]
                    [--severity {warn,crit}] [--timeout TIMEOUT]

Tests if a path is writable and readable by creating, writing, reading, and
deleting a temporary file. Especially useful for mounted filesystems such as
NFS or SMB where the mount may silently become read-only or unresponsive. The
local temporary directory is always tested as a baseline. A path on a network
filesystem whose server has stopped answering does not fail, it blocks, and it
blocks in a way no timeout inside a process reaches. Each path is therefore
tested in a process of its own, all of them at the same time and under one
shared deadline, so the check stays within --timeout however many paths are
unreachable, and a path that misses the deadline is reported like one that
cannot be written to. Alerts if the path is not writable, not readable, or
does not answer at all. Requires root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --path PATH           Path to test for read/write access by creating and
                        deleting a temporary file. Can be specified multiple
                        times. Default: ['/tmp']
  --severity {warn,crit}
                        Severity for alerting. Default: warn
  --timeout TIMEOUT     How long a path gets to answer before it is reported
                        as unreachable. Every path is tested at the same time
                        and they share one deadline, so this is the runtime of
                        the whole check and not a budget per path. Default: 8
                        (seconds)

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/path-rw-test/
```


## Usage Examples

```bash
./path-rw-test --path=/mnt/nfs --path=/mnt/smb --path=/usr --severity=warn
```

Output:

```text
Error creating/writing/reading/deleting file in `/usr` ([Errno 13] Permission denied: '/usr/tmptbt8daho'). Tested: /tmp, /mnt/nfs, /mnt/smb, /usr
```


## States

* OK if all paths are writable and readable.
* WARN if `--severity` is set to `warn` (default) and any path fails the read/write test or does not answer within `--timeout`.
* CRIT if `--severity` is set to `crit` and any path fails the read/write test or does not answer within `--timeout`.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
