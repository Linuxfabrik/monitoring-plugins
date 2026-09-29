# Check aide-logfile


## Overview

Evaluates the report of the last AIDE file integrity check, which a timer such as aidecheck.timer runs on the host at regular intervals, and reports the number of added, removed and changed files together with the first of them. The check itself does not run AIDE, so it is fast, and it reads no more than the head of the report, however large the report gets. Alerts when AIDE found differences between its database and the file system, by default as CRITICAL, since an unexpected change to a monitored file can be an intrusion. Also alerts when the report is missing, empty or older than the maximum age, because then the regular check has stopped or failed.

AIDE (Advanced Intrusion Detection Environment) compares the file system with a database of file attributes and checksums it created earlier. The CIS benchmarks require it to be installed, initialized and run regularly, and this check tells whether it runs and what it found.

**Important Notes:**

* The check reads `/var/log/aide/aide.log`, which AIDE writes when `report_url=file:/var/log/aide/aide.log` is set in its configuration, as it is in the configuration RHEL ships and in the one the [LFOps aide role](https://linuxfabrik.github.io/lfops/roles/aide/) deploys. Something else has to run the check at regular intervals, for example `aidecheck.timer`, which the CIS benchmarks name and the LFOps aide role deploys, or the daily check of Debian's `aide-common`.
* `/var/log/aide` is readable by root only, so run the check via `sudo` (see the sudoers files in `assets/sudoers`). The `AIDE Service Set` in the Icinga Director does exactly that on every host tagged `aide`, and also checks `aidecheck.service` and `aidecheck.timer`.
* AIDE empties its report when it starts and writes the new one when it has compared the whole file system, which takes minutes on a large host. A check that runs during that time reports UNKNOWN once, and the next run reads the new report.
* The report has to be a plain one (`report_format=plain`, the default), written anew by every run (`report_append=no`, the default), also when AIDE finds nothing (`report_quiet=no`, the default), with at least `report_level=summary` (the default is `changed_attributes`), so that it tells how many differences there are and when the run started.
* A report of `aide --update` counts like a check: the run writes a new database next to the old one, and its differences are accepted only once the new database replaces the old one. The daily check of Debian's `aide-common` runs `aide --update` by default and never moves the new database into place (`COMMAND=update`, `COPYNEWDB=no` in `/etc/default/aide`).
* An unexpected change to a monitored file can mean an intrusion, which is why a difference is CRITICAL by default. A planned change (a package update, an edited configuration file) is reported just the same until the database is updated, see Troubleshooting.

**Data Collection:**

* Reads the report line by line and stops at the details of the changed files, so a report of many megabytes costs no more than its summary and its lists of files. It reads 16 MiB at most. A list that starts beyond that is counted, but not listed.
* The number of added, removed and changed entries comes from the summary of the report. Of each list, the first 10 entries are shown, with the attribute summary AIDE puts in front of each file name, for example `f > ...   ..H.. . : /etc/hosts` for a file that grew and whose checksum changed. `man aide.conf`, section `report_summarize_changes`, explains the letters.
* The age is the time since the start of the AIDE run, as AIDE records it in the report (`Start timestamp`). A report without that line falls back to the modification time of the file.
* While the report is empty or incomplete, the check looks for a running `aide` process to tell a run in progress from one that aborted.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/aide-logfile> |
| Nagios/Icinga Check Name              | `check_aide_logfile` |
| Check Interval Recommendation         | Every hour |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |
| Requirements                          | A regular AIDE check, for example `aidecheck.timer`; User with higher permissions |


## Help

```text
usage: aide-logfile [-h] [-V] [--always-ok] [-c CRIT] [--max-age MAX_AGE]
                    [--no-perfdata] [-w WARN]

Evaluates the report of the last AIDE file integrity check, which a timer such
as aidecheck.timer runs on the host at regular intervals, and reports the
number of added, removed and changed files together with the first of them.
The check itself does not run AIDE, so it is fast, and it reads no more than
the head of the report, however large the report gets. Alerts when AIDE found
differences between its database and the file system, by default as CRITICAL,
since an unexpected change to a monitored file can be an intrusion. Also
alerts when the report is missing, empty or older than the maximum age,
because then the regular check has stopped or failed. Requires root or sudo.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  -c, --critical CRIT  CRIT threshold for the number of differences (added,
                       removed and changed entries together) that the last
                       AIDE check found. Supports Nagios ranges. The default
                       alerts on the first difference. Default: 0
  --max-age MAX_AGE    Maximum age of the report in hours. An older report
                       means that the regular AIDE check no longer runs.
                       Default: 26 (0 disables the check)
  --no-perfdata        Suppress the performance data section from the output.
                       The status message and the exit code are unaffected, so
                       alerting keeps working while trending data is dropped.
  -w, --warning WARN   WARN threshold for the number of differences (added,
                       removed and changed entries together) that the last
                       AIDE check found. Supports Nagios ranges. Example:
                       `--warning=0 --critical=` to get a warning instead of a
                       critical alert. Default: (no warning)

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/aide-logfile/
```


## Usage Examples

```bash
sudo ./aide-logfile
```

```text
AIDE found 6 differences (2 added, 1 removed, 3 changed) [CRITICAL] in the check 2h 13m ago

Added entries:
* f++++++++++++++++++: /etc/sudoers.d/zz-linuxfabrik
* f++++++++++++++++++: /usr/local/bin/linuxfabrik-suid

Removed entries:
* f------------------: /etc/issue.net

Changed entries:
* f > ...   ..H.. .  : /etc/hosts
* f = p..   ...A. .  : /etc/sudoers.d/README
* f = p..   ...A. .  : /etc/sudoers.d/user

The details are in /var/log/aide/aide.log. Once the changes are known to be legitimate, accept them with `aide --update` and move the new database over the old one (for example `aide.db.new.gz` to `aide.db.gz`).
```

A host without differences:

```text
AIDE found no differences in the check 3h 4m ago
```

Warn instead of alerting as critical, and accept a report of up to two days:

```bash
sudo ./aide-logfile --warning=0 --critical= --max-age=48
```


## States

* OK if the last AIDE run found no differences, and the report is not older than `--max-age`.
* OK if AIDE initialized its database and no check has run since, as long as that is not longer ago than `--max-age`.
* CRIT if the last AIDE check or update run found differences (`--critical`, default: `0`, so the first difference counts). `--warning` (empty by default) and `--critical` take Nagios ranges on the number of differences.
* WARN if the AIDE run started more than `--max-age` hours ago (default: 26), because the regular check has then stopped. `--max-age 0` switches this off.
* WARN if there is no report, because the file integrity of the host is then not being checked.
* WARN if the report is empty or holds no result and no AIDE process is running, because the last run aborted.
* UNKNOWN if an AIDE run is in progress right now, so the report is not written yet, if the report cannot be read, most likely because the check does not run via `sudo`, and if the report is not a plain one.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| added | Number | Number of files AIDE found added in the last check or update run. |
| changed | Number | Number of files AIDE found changed in the last check or update run. |
| differences | Number | Number of added, removed and changed files together. |
| entries | Number | Number of files and directories in the AIDE database. |
| removed | Number | Number of files AIDE found removed in the last check or update run. |


## Troubleshooting

### `No AIDE report found at /var/log/aide/aide.log`

AIDE has not run on this host yet, or it writes its report elsewhere. Install AIDE, initialize its database, and have it check the host at regular intervals, for example with the [LFOps aide role](https://linuxfabrik.github.io/lfops/roles/aide/), which does all of that. On a host set up by hand, make sure that `/etc/aide.conf` contains `report_url=file:/var/log/aide/aide.log`.

### `Cannot access /var/log/aide/aide.log (Permission denied)`

The check does not run as root. Call it via `sudo`, as the `AIDE Service Set` and the `tpl-service-aide-logfile-sudo` template in the Icinga Director do, and deploy the sudoers file from `assets/sudoers`.

### AIDE found differences

1. Read the report: `less /var/log/aide/aide.log`. The section "Detailed information about changes" shows the old and new value of every changed attribute of every file.
2. Find out who changed the files and why: a package update (`dnf history`, `/var/log/apt/history.log`), a configuration management run, an administrator. A changed binary below `/usr` that no package update explains, a new setuid file, or a changed file below `/etc/sudoers.d` or `/etc/pam.d` that nobody can account for is a security incident.
3. Once the changes are known to be legitimate, accept them as the new baseline: `aide --config=/etc/aide.conf --update`, then `mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz`, then run a check, for example `systemctl start aidecheck.service`. `aide --update` accepts everything that changed since the database was last updated, not only the changes you reviewed.
4. Paths that change legitimately all the time belong excluded from the AIDE configuration (`!/path`), or checked with fewer attributes (`PERMS` instead of `NORMAL`), rather than accepted over and over.

### `The last AIDE run aborted before it wrote its report`

AIDE empties its report when it starts, and an aborted run leaves it empty. `journalctl --unit aidecheck.service` shows why, most often a missing database (`open (read-only) failed for file '/var/lib/aide/aide.db.gz'`, exit code 18), which `aide --init` and moving `aide.db.new.gz` to `aide.db.gz` create. Two configurations leave the report empty without any error:

* `report_quiet=yes` in the AIDE configuration writes no report at all when AIDE finds nothing. Remove it.
* logrotate with `copytruncate` empties the report when it rotates it, which the logrotate configuration RHEL ships in `/etc/logrotate.d/aide` does once the report is larger than 100 KiB. Use `copy` instead of `copytruncate` there: AIDE writes a new report on every run anyway. The LFOps aide role does exactly that.

### The report is older than `--max-age`

1. `systemctl list-timers aidecheck.timer` shows when the timer last ran and when it runs next. An inactive timer is not enabled: `systemctl enable --now aidecheck.timer`.
2. `systemctl status aidecheck.service` and `journalctl --unit aidecheck.service` show whether the last run failed.
3. A report written with `report_append=yes` holds every run since the last rotation, and the check reads the oldest one. Remove `report_append=yes` from the AIDE configuration.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
