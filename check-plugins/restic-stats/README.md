# Check restic-stats


## Overview

Collects statistics across multiple snapshots in a restic repository, including the number of unique files and their total size. Supports different counting modes (restore-size, files-by-contents, blobs-per-file, raw-data). The figures are reported for trending and capacity planning and never alert on their own; alerts only if restic fails or times out.

**Important Notes:**

* Requires root or sudo
* Refer to the [online manual](https://restic.readthedocs.io/en/latest/index.html) for more details about restic

**Data Collection:**

* Executes `restic --json --no-cache --no-lock --repo=... --password-file=... stats` with the specified filters and counting mode, so the check writes nothing into the repository or the restic cache
* Supports filtering by `--host`, `--path`, and `--tag`
* Supports different counting modes via `--mode`:
    * `blobs-per-file`: A combination of files-by-contents and raw-data
    * `files-by-contents`: Counts total size of files, where a file is considered unique if it has unique contents
    * `raw-data`: Counts the size of blobs in the repository, regardless of how many files reference them
    * `restore-size`: Counts the size of the restored files (default)


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/restic-stats> |
| Nagios/Icinga Check Name              | `check_restic_stats` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | No (`--password-file` and one of `--repo` or `--repository-file` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| Requirements                          | command-line tool `restic`; User with higher permissions |


## Help

```text
usage: restic-stats [-h] [-V] [--always-ok] [--host HOST]
                    [--mode {restore-size,files-by-contents,blobs-per-file,raw-data}]
                    [--no-perfdata] [--password-file PASSWORD_FILE]
                    [--path PATH] [--repo REPO]
                    [--repository-file REPOSITORY_FILE] [--tag TAG]
                    [--timeout TIMEOUT]

Collects statistics across multiple snapshots in a restic repository,
including the number of unique files and their total size. Supports different
counting modes (restore-size, files-by-contents, blobs-per-file, raw-data).
The figures are reported for trending and never alert on their own; alerts
only if restic fails or times out. Requires root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --host HOST           Only consider snapshots for this host. Can be
                        specified multiple times.
  --mode {restore-size,files-by-contents,blobs-per-file,raw-data}
                        Counting mode for the statistics calculation. Default:
                        restore-size
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --password-file PASSWORD_FILE
                        Path to the file containing the repository password.
                        Must be a file that only root can change.
  --path PATH           Only consider snapshots for this path. Can be
                        specified multiple times.
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
  --tag TAG             Only consider snapshots matching this taglist in the
                        format `tag[,tag,...]`. Can be specified multiple
                        times.
  --timeout TIMEOUT     Network timeout in seconds. Default: 280 (seconds)

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/restic-stats/
```


## Usage Examples

```bash
./restic-stats --repo=/path/to/restic-repo --password-file=/path/to/restic-pwd --host=www.example.com
```

Output:

```text
242 files, 433.4KiB size (total stats in restore-size mode over all snapshots)
```


## States

* OK if `restic stats` succeeds. The figures never alert on their own.
* WARN if `restic stats` fails or runs longer than `--timeout` (default: 280 seconds).
* UNKNOWN if not exactly one of `--repo` and `--repository-file` is given, if `--password-file` is missing, if `--repo` names an `rclone:` repository, a `rest:` repository over a Unix socket or an `sftp:` repository whose host is invalid or starts with `-`, or if the local repository, `--repository-file` or `--password-file` can be changed by anybody but root.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| total_file_count | Number | Number of unique files, according to the counting mode given by `--mode`. Only reported in the `restore-size` and `files-by-contents` modes; `raw-data` and `blobs-per-file` count no files. |
| total_size | Number | Size of unique files, according to the counting mode given by `--mode`. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
