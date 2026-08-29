# Check file-growth

## Overview

Checks how fast files grow or shrink, by comparing their size against the previous check runs and reporting the change as a rate per second. Supports glob patterns, SMB shares, and optional aggregation (mean or median) across all matched files. Directories are skipped because their reported size is not meaningful across filesystems. Alerts when a file grows or shrinks faster than the configured thresholds, which are given as a size per second and take a negative bound to catch a file that is losing data. Alerts only if a threshold has been exceeded for a configurable number of consecutive check runs (default: 3), suppressing short bursts. The first run of a file reports OK and waits for a second measurement to compare against. Supports extended reporting via `--lengthy`. Reads only the file metadata, never the contents. The plugin is not shipped in the sudoers allowlist, so it can only see files the monitoring user may read; see [PLUGINS-FILE.md](../PLUGINS-FILE.md) for what to do about a file it cannot access.

This plugin is part of the file plugin group. Selecting files with globs, reading from an SMB share, the threshold format, aggregating performance data, and what to do when the plugin cannot read a file are described once in [PLUGINS-FILE.md](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-FILE.md).

Use it where a size threshold answers the wrong question. A log file that sits at 800 MiB for a year is not a problem; the same file gaining 200 MiB an hour is, long before it reaches whatever absolute limit was configured. It also catches the opposite: a file that suddenly loses data, which is what a truncation or an unexpected rotation looks like.

**Important Notes:**

* The first run reports OK with "Waiting for more data." and nothing else, because a rate needs two measurements. The same happens after the state file is deleted. When a glob matches a mix of known and new files, the new ones say so in their own table row and the rest is reported as usual.
* Thresholds are a size **per second**. `1M` means 1 MiB/s, which is roughly 84 GiB a day. See the Usage Examples for converting the rate you have in mind.
* The default thresholds only alert on growth. Shrinking is measured and reported, and alerts once the threshold has a negative lower bound, for example `--warning=-1M:1M`.
* `--count` defaults to 3, so a threshold has to be exceeded in three consecutive check runs before the check alerts. A single large write does not.
* A second run within the same second reports the previous rate again instead of recalculating. Two measurements less than a second apart are not a rate.
* Per-file performance data is only emitted when the check matches exactly one file. For a glob, use `--perfdata-mode` to get one aggregated series.
* `--brief` hides the rows within the thresholds, `--lengthy` adds the current size and the number of stored measurements as columns. The two combine, and neither changes the state or the performance data.

**Data Collection:**

* Reads `st_size` from `os.stat()` for local files and `lib.smb` for SMB shares
* Keeps the previous measurements in a local SQLite database and calculates the rate itself, so the performance data is a gauge rather than a continuously rising counter
* The state file keeps `--count` + 1 measurements per matched file and prunes older ones on every run


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/file-growth> |
| Nagios/Icinga Check Name              | `check_file_growth` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | Yes |
| 3rd Party Python modules              | optional: `PySmbClient`, `smbprotocol` |
| Handles Periods                       | Yes (alerts only after `--count` consecutive threshold violations) |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-file-growth.db` |


## Help

```text
usage: file-growth [-h] [-V] [--always-ok] [--brief] [--count COUNT] [-c CRIT]
                   [--filename FILENAME] [--lengthy] [--no-perfdata]
                   [--password PASSWORD] [--pattern PATTERN]
                   [--perfdata-mode {mean,median,None}] [--timeout TIMEOUT]
                   [-u URL] [--username USERNAME] [-w WARN]

Checks how fast files grow or shrink, by comparing their size against the
previous check runs and reporting the change as a rate per second. Supports
glob patterns, SMB shares, and optional aggregation (mean or median) across
all matched files. Directories are skipped because their reported size is not
meaningful across filesystems. Alerts when a file grows or shrinks faster than
the configured thresholds, which are given as a size per second and take a
negative bound to catch a file that is losing data. Alerts only if a threshold
has been exceeded for a configurable number of consecutive check runs
(default: 3), suppressing short bursts. The first run of a file reports OK and
waits for a second measurement to compare against. Supports extended reporting
via --lengthy. Reads only the file metadata, never the contents. The plugin is
not shipped in the sudoers allowlist, so it can only see files the monitoring
user may read; see PLUGINS-FILE.md for what to do about a file it cannot
access.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --brief               Hide the rows that are within the thresholds and show
                        only those in a WARN or CRIT state. Perfdata and
                        alerting are unaffected: every item still emits
                        performance data and still drives the overall check
                        state, so this is safe to leave on.
  --count COUNT         Number of consecutive checks the threshold must be
                        exceeded before alerting. Default: 3
  -c, --critical CRIT   CRIT threshold for the rate of change per second, in
                        human-readable format (base is always 1024; valid
                        qualifiers are B, KiB, MiB, GiB etc., see UNITS.md; a
                        value without a qualifier is a number of bytes). A
                        negative bound catches a file that is shrinking.
                        Supports Nagios ranges. Default: ~:10M (alerts above
                        10 MiB/s, ignores shrinking). Example: `-10M:10M`
                        alerts if a file grows or shrinks by more than 10
                        MiB/s.
  --filename FILENAME   Path of the file to check. Supports glob patterns
                        according to
                        https://docs.python.org/3/library/glob.html. Recursive
                        globs can cause high memory usage. Mutually exclusive
                        with `-u` / `--url`. Example: `--filename /tmp/*.log`.
  --lengthy             Extended reporting.
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --password PASSWORD   Password for SMB authentication.
  --pattern PATTERN     Search string to match against SMB directory or file
                        names. Use `*` as a wildcard for multiple characters
                        and `?` for a single character. Does not support regex
                        patterns. Default: *
  --perfdata-mode {mean,median,None}
                        Aggregation mode for performance data across matched
                        files. Default: None
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -u, --url URL         URL of the file to check, starting with `smb://`.
                        Mutually exclusive with `--filename`. Example: `--url
                        smb://server/share/path`.
  --username USERNAME   Username for SMB authentication.
  -w, --warning WARN    WARN threshold for the rate of change per second, in
                        human-readable format (base is always 1024; valid
                        qualifiers are B, KiB, MiB, GiB etc., see UNITS.md; a
                        value without a qualifier is a number of bytes). A
                        negative bound catches a file that is shrinking.
                        Supports Nagios ranges. Default: ~:1M (alerts above 1
                        MiB/s, ignores shrinking). Example: `-1M:1M` alerts if
                        a file grows or shrinks by more than 1 MiB/s.

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/file-growth/
```


## Usage Examples

```bash
./file-growth --filename=/var/log/messages
```

Output on the first run:

```text
Waiting for more data.
```

Output once a second measurement exists:

```text
Everything is ok. Growth of 1 file checked, all in (-inf..1.0MiB/s). Checked /var/log/messages: 12.4KiB/s
```

A runaway log file, alerting after three consecutive runs above the threshold:

```text
Growth of 1 file checked. 1 not in (-inf..1.0MiB/s) [WARNING]. Checked /var/log/messages: 3.0MiB/s [WARNING]
```

Converting a rate into a threshold. The thresholds are per second, so divide the amount you care about by the length of the period:

```bash
# alert above 100 MiB per hour: 100 * 1024 * 1024 / 3600 = 29127 bytes/s
./file-growth --filename=/var/log/messages --warning='~:29127'

# alert above 1 GiB per day: 1024 * 1024 * 1024 / 86400 = 12427 bytes/s
./file-growth --filename=/var/lib/mysql/ibdata1 --critical='~:12427'
```

Alerting in both directions, so a truncation is caught as well:

```bash
./file-growth --filename=/var/log/messages --warning=-1M:1M --critical=-10M:10M
```

Watching a whole directory, with a single aggregated series instead of one per file:

```bash
./file-growth --filename='/var/log/*.log' --perfdata-mode=mean
```

```text
Growth of 3 files checked. 1 not in (-inf..1.0MiB/s) [WARNING].

File                  ! Growth   ! State
----------------------+----------+----------
/var/log/messages     ! 3.0MiB/s ! [WARNING]
/var/log/secure       ! 1.0KiB/s ! [OK]
/var/log/maillog      ! 0.0B/s   ! [OK]
```

Reacting faster, at the cost of alerting on single bursts:

```bash
./file-growth --filename=/var/log/messages --count=1
```

On a directory with many files, `--brief` reduces the table to what needs
attention, and `--lengthy` adds the current size and how many measurements the
rate rests on:

```bash
./file-growth --filename='/var/log/*.log' --brief --lengthy
```

```text
Growth of 3 files checked. 1 not in (-inf..1.0MiB/s) [WARNING].

File              ! Growth   ! Size   ! Samples ! State
------------------+----------+--------+---------+----------
/var/log/messages ! 3.0MiB/s ! 2.1GiB ! 4       ! [WARNING]
```


## States

* OK if every matched file changed size within the given thresholds.
* OK with "Waiting for more data." when no matched file has a previous measurement yet, on the first run or after the state file was deleted. A rate needs two measurements.
* WARN or CRIT if a file's rate of change was outside `--warning` or `--critical` in each of the last `--count` intervals. A range bound includes its own value, so a file growing at exactly the threshold is still OK.
* The reported state is the worst one that *every* interval in the window reached. One interval within the thresholds is enough to keep the file OK, which is what suppresses a single large write.
* UNKNOWN if no file matches `--filename`, if both `--filename` and `--url` are given, if `--count` is below 1, or if the URL uses a protocol other than `smb://`.
* `--always-ok` suppresses all alerts and always returns OK.
* `--brief` and `--lengthy` only reshape the table. Every matched file is checked, drives the state and emits performance data either way.


## Perfdata / Metrics

Which series is emitted depends on how many files matched and on `--perfdata-mode`.

| Name | Type | Description |
|----|----|----|
| growth | Bytes | Bytes per second the file gained or lost since the previous run. Emitted when exactly one file matched. Negative when the file shrank. |
| mean-growth | Bytes | Mean rate of change across all matched files, with `--perfdata-mode=mean`. |
| median-growth | Bytes | Median rate of change across all matched files, with `--perfdata-mode=median`. |

A glob that matches several files emits no performance data unless `--perfdata-mode` is given, so that a wildcard cannot fill the time series database with one series per file.


## Troubleshooting

### `Waiting for more data.`

Expected on the first run, and for every file a glob newly matches. The check needs two measurements to calculate a rate. Wait for the next check interval.

If it persists across many runs, the state file is being removed between runs. It lives in the temp directory (see the Fact Sheet) and is written by the user running the check; a `tmpfiles` cleaner or a per-run private tmp directory will keep the check from ever seeing its own history.

### `No files found.`

The pattern matched nothing, or the monitoring user may not read the directory. Both look the same to a glob. See [PLUGINS-FILE.md](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-FILE.md) for how to tell the two apart and how to grant access.

### The rate is much higher than expected right after a reboot

The temp directory is cleared on boot on many distributions, so the check starts from an empty history and reports "Waiting for more data." on its first run afterwards. A rate that looks implausible instead usually means the file was replaced rather than appended to, for example by a restore or a rotation that put a large file in place of a small one.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
