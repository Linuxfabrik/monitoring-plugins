# Check restic-stats


## Overview

Collects statistics across multiple snapshots in a restic repository, including the number of unique files and their total size. Reports these as perfdata for trending and capacity planning.

**Important Notes:**

* Requires root or sudo
* Refer to the [online manual](https://restic.readthedocs.io/en/latest/index.html) for more details about restic

**Data Collection:**

* Executes `restic --json --repo=... stats` with the specified filters and counting mode
* Supports filtering by `--host`, `--path`, and `--tag`
* Supports different counting modes via `--mode`:
    * `blobs-per-file`: A combination of files-by-contents and raw-data
    * `files-by-contents`: Counts total size of files, where a file is considered unique if it has unique contents
    * `raw-data`: Counts the size of blobs in the repository, regardless of how many files reference them
    * `restore-size`: Counts the size of the restored files (default)


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/restic-stats> |
| Nagios/Icinga Check Name              | `check_restic_stats` |
| Check Interval Recommendation         | Once a day |
| Can be called without parameters      | No (`--repo` is required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |


## Help

```text
usage: restic-stats [-h] [-V] [--host HOST]
                    [--mode {restore-size,files-by-contents,blobs-per-file,raw-data}]
                    [--password-file PASSWORD_FILE] [--path PATH] --repo REPO
                    [--tag TAG] [--test TEST]

Collects statistics across multiple snapshots in a restic repository,
including the number of unique files and their total size. Supports different
counting modes (restore-size, files-by-contents, raw-data). Requires root or
sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --host HOST           Only consider snapshots for this host. Can be
                        specified multiple times.
  --mode {restore-size,files-by-contents,blobs-per-file,raw-data}
                        Counting mode for the statistics calculation. Default:
                        restore-size
  --password-file PASSWORD_FILE
                        Path to the file containing the repository password.
  --path PATH           Only consider snapshots for this path. Can be
                        specified multiple times.
  --repo REPO           Restic repository location.
  --tag TAG             Only consider snapshots matching this taglist in the
                        format `tag[,tag,...]`. Can be specified multiple
                        times.
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
```


## Usage Examples

```bash
./restic-stats --repo=/path/to/restic-repo --password-file=/path/to/restic-pwd --host=www.example.com
```

Output:

```text
242.0 files, 433.7KiB size (total stats in restore-size mode over all snapshots)
```


## States

* Always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| total_file_count | Number | Number of unique files, according to the counting mode given by `--mode`. |
| total_size | Number | Size of unique files, according to the counting mode given by `--mode`. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
