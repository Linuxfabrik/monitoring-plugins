# Check restic-check


## Overview

Verifies the integrity of a restic backup repository by running `restic check`. Alerts when the repository contains errors or inconsistencies. In contrast to the interactive `restic check` sub-command, it cannot be used to read all data and therefore simulate a restore.

**Important Notes:**

* Requires root or sudo
* Refer to the [online manual](https://restic.readthedocs.io/en/latest/index.html) for more details about restic

**Data Collection:**

* Executes `restic --json --no-cache --no-lock --repo=... --password-file=... check` (or `--repository-file=...` instead of `--repo=...`)
* Runs read-only: creates no lock in the repository and no local cache, so it always loads all data directly from the repository. Execution may take several minutes, especially if the repository is corrupted
* If the output exceeds 10 lines, it is shortened to the first 5 and last 5 lines


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/restic-check> |
| Nagios/Icinga Check Name              | `check_restic_check` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | No (`--password-file` and one of `--repo` or `--repository-file` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| Requirements                          | command-line tool `restic`; User with higher permissions |


## Help

```text
usage: restic-check [-h] [-V] [--always-ok] [--password-file PASSWORD_FILE]
                    [--repo REPO] [--repository-file REPOSITORY_FILE]
                    [--timeout TIMEOUT]

Verifies the integrity of a restic backup repository by running "restic
check". Alerts when the repository contains errors or inconsistencies.
Requires root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --password-file PASSWORD_FILE
                        Path to the file containing the repository password.
                        Must be a file that only root can change.
  --repo REPO           Restic repository location. A local repository has to
                        be a directory that only root can change. Give exactly
                        one of --repo and --repository-file.
  --repository-file REPOSITORY_FILE
                        Path to a file whose first line is the repository
                        location. Use this instead of --repo for a repository
                        whose location selects an external helper (an
                        `rclone:` repository): the file must be one that only
                        root can change, so an unprivileged caller cannot
                        choose what runs. Give exactly one of --repo and
                        --repository-file.
  --timeout TIMEOUT     Network timeout in seconds. Default: 280 (seconds)

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/restic-check/
```


## Usage Examples

```bash
./restic-check --repo=/path/to/restic-repo --password-file=/path/to/restic-pwd
```

Output on a healthy repository:

```text
Everything is ok.
```

Output on a damaged repository:

```text
There are errors.

pack 764fcd1a: does not exist
error for tree 5e730b1a:
  ReadFull(<data/764fcd1a>): open /path/to/restic-repo/data/76/764fcd1a...: no such file or directory
Fatal: repository contains errors
```


## States

* OK if the repository has no errors.
* WARN if `restic check` reports errors in the repository, fails (for example no repository at that location, or a wrong password), or does not finish within `--timeout`.
* UNKNOWN if `--repo` names an `rclone:` repository or a `rest:` repository over a Unix socket, or if a local repository, `--repository-file` or `--password-file` can be changed by anybody but root.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
