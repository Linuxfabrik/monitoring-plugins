# Check path-rw-test

## Overview

Tests if a temporary file can be created, written to a specified path, read, and then deleted. Especially useful with mounted file systems such as NFS or SMB. The local temporary directory is always tested, regardless of whether the check is called with or without parameters. May require sudo privileges.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/path-rw-test> |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | Yes |


## Help

```text
usage: path-rw-test [-h] [-V] [--always-ok] [--path PATH]
                    [--severity {warn,crit}]

Tests if a temporary file can be created, written to a specified path, read,
and then deleted. Especially useful with mounted file systems such as NFS or
SMB. The local temporary directory is always tested, regardless of whether the
check is called with or without parameters. May require sudo privileges.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --path PATH           Path to which the file is to be written and from which
                        it will be deleted (repeating). Default: ['/tmp']
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

* WARN if `--severity` is set to `warn` (default)
* CRIT if `--severity` is set to `crit`


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
