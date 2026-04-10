# Check restic-check


## Overview

Verifies the integrity of a restic backup repository by running `restic check`. Alerts when the repository contains errors or inconsistencies. In contrast to the interactive `restic check` sub-command, it cannot be used to read all data and therefore simulate a restore.

**Important Notes:**

* Requires root or sudo
* Refer to the [online manual](https://restic.readthedocs.io/en/latest/index.html) for more details about restic

**Data Collection:**

* Executes `restic --json --repo=... --password-file=... check`
* Always loads all data directly from the repository and does not use a local cache, so execution may take several minutes, especially if the repository is corrupted
* If the output exceeds 10 lines, it is shortened to the first 5 and last 5 lines

**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/restic-check> |
| Nagios/Icinga Check Name              | `check_restic_check` |
| Check Interval Recommendation         | Once a day |
| Can be called without parameters      | No (`--repo` is required) |
| Compiled for Windows                  | No |


## Help

```text
usage: restic-check [-h] [-V] [--password-file PASSWORD_FILE] --repo REPO
                    [--test TEST]

Verifies the integrity of a restic backup repository by running "restic
check". Alerts when the repository contains errors or inconsistencies.
Requires root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --password-file PASSWORD_FILE
                        Path to the file containing the repository password.
  --repo REPO           Restic repository location.
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
```


## Usage Examples

```bash
./restic-check --repo=/path/to/restic-repo --password-file=/path/to/restic-pwd
```

Output:

```text
There are warnings.

pack 74f3c4c9: does not exist
pack 590110aa: does not exist
pack 3a551e0f: does not exist
pack 1c9901af: does not exist
pack e577c6b0: does not exist
...
Load(<data/74f3c4c9f6>, 484, 616018) returned error, retrying after 13.811796615s: open /path/to/restic-repo/data/74/74f3c4c9f6d2c5d2d85acd07b7c72dc53926002f234fb4f8e161e51e2cd67ab7: no such file or directory
error for tree 5e730b1a:
  ReadFull(<data/74f3c4c9f6>): open /path/to/restic-repo/data/74/74f3c4c9f6d2c5d2d85acd07b7c72dc53926002f234fb4f8e161e51e2cd67ab7: no such file or directory
Fatal: repository contains errors
```


## States

* OK if `restic check` exits with 0 and the output contains "no errors".
* WARN if exit status of `restic check` != 0.
* WARN if output of `restic check` does not contain "no errors".


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
