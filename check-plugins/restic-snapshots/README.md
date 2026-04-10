# Check restic-snapshots


## Overview

Checks the age of the newest snapshot in a restic repository and alerts when the most recent backup is older than the configured thresholds. Useful for detecting failed or missing backup runs.

**Important Notes:**

* Requires restic 0.12.1+
* Requires root or sudo
* Refer to the [online manual](https://restic.readthedocs.io/en/latest/index.html) for more details about restic

**Data Collection:**

* Executes `restic --json --repo=... snapshots` with the specified filters
* Supports filtering by `--host`, `--path`, and `--tag`
* Supports grouping snapshots by host, paths, and/or tags via `--group-by` (default: `host,paths`)
* Shows the latest N snapshots per group via `--latest` (default: 3)
* Supports extended reporting via `--lengthy` (adds a Tags column)


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/restic-snapshots> |
| Nagios/Icinga Check Name              | `check_restic_snapshots` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | No (`--repo` is required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |


## Help

```text
usage: restic-snapshots [-h] [-V] [-c CRIT] [--group-by GROUP_BY]
                        [--host HOST] [--latest LATEST] [--lengthy]
                        [--password-file PASSWORD_FILE] [--path PATH]
                        --repo REPO [--tag TAG] [--test TEST] [-w WARN]

Checks the age of the newest snapshot in a restic repository. Alerts when the
most recent backup is older than the configured thresholds. Useful for
detecting failed or missing backup runs. Supports extended reporting via
--lengthy. Requires root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  -c, --critical CRIT   CRIT threshold for the age of the newest snapshot in
                        each group, in hours. Default: None
  --group-by GROUP_BY   Comma-separated list of fields to group snapshots by.
                        Allowed values: host, paths, tags. Default: host,paths
  --host HOST           Only consider snapshots for this host. Can be
                        specified multiple times.
  --latest LATEST       Number of latest snapshots to show per host and path.
                        Default: 3
  --lengthy             Extended reporting.
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
  -w, --warning WARN    WARN threshold for the age of the newest snapshot in
                        each group, in hours. Default: 24
```


## Usage Examples

Show the latest three snapshots for host www.example.com, grouped by hosts, tags and paths:

```bash
./restic-snapshots \
    --repo=/path/to/restic-repo \
    --password-file=/path/to/restic-pwd \
    --host=www.example.com \
    --latest=3 \
    --group-by='hosts,tags,paths' \
    --warning=8 \
    --lengthy
```

Output:

```text
There are warnings.

Latest snapshot 17h 52m ago [WARNING] (2022-12-04 16:10:05@www.example.com:/home, ID 34751e52); 3 snapshots found

Short ID ! Timestamp           ! Age               ! Host                  ! Paths ! Tags 
---------+---------------------+-------------------+-----------------------+-------+------
34751e52 ! 2022-12-04 16:10:05 ! 17h 52m [WARNING] ! www.example.com       ! /home !      
f958e789 ! 2022-12-04 16:08:51 ! 17h 53m           ! www.example.com       ! /home !      
4d2a09b2 ! 2022-12-04 16:08:49 ! 17h 53m           ! www.example.com       ! /home !      


Latest snapshot 17m 38s ago (2022-12-05 09:45:00@www.example.com:/home, ID a5cae06b); 1 snapshot found

Short ID ! Timestamp           ! Age     ! Host                  ! Paths ! Tags 
---------+---------------------+---------+-----------------------+-------+------
a5cae06b ! 2022-12-05 09:45:00 ! 17m 38s ! www.example.com       ! /home ! myTag
```

A restic snapshot check via SFTP:

```bash
./restic-snapshots \
    --repo=sftp://user123@linuxfabrik.your-storagebox.de:23//home/user123/myserver \
    --password-file=/home/user123/restic_passwords/myserver.txt \
    --latest=3 \
    --warning=30 \
    --critical=60
```


## States

* OK if the newest snapshot in each group is younger than `--warning`.
* WARN if the age of the newest snapshot exceeds `--warning` (default: 24 hours).
* CRIT if the age of the newest snapshot exceeds `--critical`.
* UNKNOWN if no snapshots match the filter criteria.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| snapshots | Number | Number of snapshots found based on the specified criteria. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
