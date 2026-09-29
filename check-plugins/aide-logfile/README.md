# Check aide-logfile


## Overview

Evaluates the report of the last AIDE file integrity check, which a timer such as aidecheck.timer runs on the host at regular intervals, and reports the number of added, removed and changed files together with the first of them. The check itself does not run AIDE, so it is fast, and it keeps no more than the summary and the first entries of the report in memory, however large the report gets. Alerts when AIDE found differences between its database and the file system, and when the report is missing, empty or older than the maximum age, because then the regular check has stopped or failed. AIDE reports a change hours after it happened, and most changes are planned ones, so by default only WARNING is raised.

AIDE (Advanced Intrusion Detection Environment) compares the file system with a database of file attributes and checksums it created earlier. The CIS benchmarks require it to be installed, initialized and run regularly, and this check tells whether it runs and what it found.

**Important Notes:**

* The check reads `/var/log/aide/aide.log`, which AIDE writes when `report_url=file:/var/log/aide/aide.log` is set in its configuration, as it is in the configuration RHEL ships and in the one the [LFOps aide role](https://linuxfabrik.github.io/lfops/roles/aide/) deploys. Something else has to run the check at regular intervals, for example `aidecheck.timer`, which the CIS benchmarks name and the LFOps aide role deploys, or the daily check of Debian's `aide-common`.
* `/var/log/aide` is readable by root only (on Debian and Ubuntu with `aide-common` by the group `adm` as well), so run the check via `sudo` (see the sudoers files in `assets/sudoers`). The `AIDE Service Set` in the Icinga Director does exactly that on every host tagged `aide`, and also checks `aidecheck.service` and `aidecheck.timer`.
* AIDE empties its report when it starts and writes the new one when it has compared the whole file system, which takes an hour or more on a large file server. Meanwhile, the check reports the result of the previous run, which it keeps in its state file, with the note that a new run is in progress, so the service does not flap. The age of that result still counts against `--max-age`, so an AIDE run that hangs raises a warning after all.
* The report has to be a plain one (`report_format=plain`, the default), written anew by every run (`report_append=no`, the default), also when AIDE finds nothing (`report_quiet=no`, the default). With `report_level=minimal` it tells that there are differences, but neither how many nor when the run started, so keep at least `report_level=summary` (the default is `changed_attributes`). AIDE 0.16 (RHEL 8) knows `verbose` instead, and writes the start of the run from `verbose=2` on (the default is `5`). The check understands every report level and the grouped and ungrouped lists of AIDE 0.16 to 0.19.
* `aide --update` writes a new database next to the old one, and its differences are accepted only once the new database replaces the old one. The report of an update run therefore counts like a check as long as the new database it names is still there, and as accepted once it is gone. The daily check of Debian's `aide-common` runs `aide --update` by default and never moves the new database into place (`COMMAND=update`, `COPYNEWDB=no` in `/etc/default/aide`), so its differences keep alerting.
* AIDE checks at fixed times, so it reports a change hours after it happened, and most changes it reports are planned ones (a package update, an edited configuration file) until the database is updated, see Troubleshooting. A difference therefore raises WARNING by default. Set `--critical=0` for hosts where any unexpected change has to be handled at once.

**Data Collection:**

* Reads the report line by line and keeps no more than its summary and the first entries of its lists, so a report of many megabytes costs little memory. It reads 16 MiB at most. A list that starts beyond that is counted, but not listed.
* The number of added, removed and changed entries comes from the summary of the report. Of each list, the first 10 entries are shown, each with the file type in front (`f` file, `d` directory, `l` symlink, `c`/`b` character/block device, `p` FIFO, `s` socket, `!` type changed). For a changed entry, the check puts into words what AIDE's change summary (`report_summarize_changes`, `summarize_changes` on AIDE 0.16) encodes: AIDE's `f > ...   ..H.. . : /etc/hosts` becomes `f: /etc/hosts: grew, content`, and `d = ...   i.  ... : /boot/efi` becomes `d: /boot/efi: replaced (new inode)`, a directory or file that was deleted and created anew. Control characters in file names, which AIDE before 0.19.2 wrote as they are, are shown as `?`.
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
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-aide-logfile.db` |


## Help

```text
usage: aide-logfile [-h] [-V] [--always-ok] [-c CRIT] [--max-age MAX_AGE]
                    [--no-perfdata] [-w WARN]

Evaluates the report of the last AIDE file integrity check, which a timer such
as aidecheck.timer runs on the host at regular intervals, and reports the
number of added, removed and changed files together with the first of them.
The check itself does not run AIDE, so it is fast, and it keeps no more than
the summary and the first entries of the report in memory, however large the
report gets. Alerts when AIDE found differences between its database and the
file system, and when the report is missing, empty or older than the maximum
age, because then the regular check has stopped or failed. AIDE reports a
change hours after it happened, and most changes are planned ones, so by
default only WARNING is raised. Requires root or sudo.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  -c, --critical CRIT  CRIT threshold for the number of differences (added,
                       removed and changed entries together) that the last
                       AIDE check found. Supports Nagios ranges. Example:
                       `--critical=0` to get a critical alert on the first
                       difference. Default: (no critical)
  --max-age MAX_AGE    Maximum age of the report in hours. An older report
                       means that the regular AIDE check no longer runs.
                       Default: 26 (0 disables the check)
  --no-perfdata        Suppress the performance data section from the output.
                       The status message and the exit code are unaffected, so
                       alerting keeps working while trending data is dropped.
  -w, --warning WARN   WARN threshold for the number of differences (added,
                       removed and changed entries together) that the last
                       AIDE check found. Supports Nagios ranges. The default
                       alerts on the first difference. Default: 0

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/aide-logfile/
```


## Usage Examples

```bash
sudo ./aide-logfile
```

```text
AIDE found 6 differences (2 added, 1 removed, 3 changed) [WARNING] 2h 13m ago

Added entries:
* f: /etc/sudoers.d/zz-linuxfabrik
* f: /usr/local/bin/linuxfabrik-suid

Removed entries:
* f: /etc/issue.net

Changed entries:
* f: /etc/hosts: grew, content
* f: /etc/sudoers.d/README: permissions, ACL
* f: /etc/sudoers.d/user: permissions, ACL

The details are in /var/log/aide/aide.log. Once the changes are known to be legitimate, accept them with `sudo aide --config=/etc/aide.conf --update && sudo mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz`.
```

A host without differences:

```text
AIDE found no differences 3h 4m ago
```

Alert as critical on the first difference, and accept a report of up to two days:

```bash
sudo ./aide-logfile --critical=0 --max-age=48
```


## States

* OK if the last AIDE run found no differences, and the report is not older than `--max-age`.
* OK if AIDE initialized its database, or updated it and the new database replaced the old one, and no AIDE check has run since, as long as that is not longer ago than `--max-age`.
* WARN if the last AIDE check found differences, or an update run whose new database has not replaced the old one yet (`--warning`, default: `0`, so the first difference counts).
* CRIT if the number of differences exceeds `--critical` (empty by default, so CRIT is never raised unless a threshold is set). `--warning` and `--critical` take Nagios ranges on the number of differences.
* WARN if the AIDE run started more than `--max-age` hours ago (default: 26), because the regular check has then stopped. `--max-age 0` switches this off.
* WARN if there is no report, because the file integrity of the host is then not being checked.
* WARN if the report is empty or holds no result and no AIDE process is running, because the last run aborted.
* While an AIDE run is in progress, the state of the previous run, or OK if no earlier result is known.
* UNKNOWN if the report cannot be read, most likely because the check does not run via `sudo`, if the report is not a plain one, and if it holds the reports of several runs (`report_append=yes`).
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

1. Read the report: `sudo less /var/log/aide/aide.log`. The section "Detailed information about changes" shows the old and new value of every changed attribute of every file.
2. Find out who changed the files and why: a package update (`dnf history`, `/var/log/apt/history.log`), a configuration management run, an administrator. A changed binary below `/usr` that no package update explains, a new setuid file, or a changed file below `/etc/sudoers.d` or `/etc/pam.d` that nobody can account for is a security incident.
3. Once the changes are known to be legitimate, accept them as the new baseline with `sudo aide --config=/etc/aide.conf --update && sudo mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz`, then run a check, for example `sudo systemctl start aidecheck.service`. `aide --update` accepts everything that changed since the database was last updated, not only the changes you reviewed.
4. Paths that change legitimately all the time belong excluded from the AIDE configuration (`!/path`), or checked with fewer attributes (`PERMS` instead of `NORMAL`), rather than accepted over and over.

### `The last AIDE run aborted before it wrote its report`

AIDE empties its report when it starts, and an aborted run leaves it empty. Most often the database is missing, for example on a fresh installation. The check then says so and names the command that creates it: `sudo aide --config=/etc/aide.conf --init && sudo mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz`. Run it once the host is set up completely, since everything that changes afterwards is reported. For any other cause, `sudo journalctl --unit aidecheck.service` shows why, or, on a host without `aidecheck.service`, running `sudo aide --config=/etc/aide.conf --check` by hand does. Two configurations leave the report empty without any error:

* `report_quiet=yes` in the AIDE configuration writes no report at all when AIDE finds nothing. Remove it.
* logrotate with `copytruncate` empties the report when it rotates it, which the logrotate configuration RHEL ships in `/etc/logrotate.d/aide` does once the report is larger than 100 KiB. Use `copy` instead of `copytruncate` there: AIDE writes a new report on every run anyway. The LFOps aide role does exactly that.

### `/var/log/aide/aide.log holds the reports of several AIDE runs`

`report_append=yes` in the AIDE configuration writes every run behind the previous ones. The check refuses to pick one of them, since a later report in the same file cannot be told apart from text a file name put there. Remove `report_append=yes`: AIDE then writes a new report on every run.

### The report is older than `--max-age`

1. `systemctl list-timers aidecheck.timer` shows when the timer last ran and when it runs next. An inactive timer is not enabled: `sudo systemctl enable --now aidecheck.timer`.
2. `systemctl status aidecheck.service` and `sudo journalctl --unit aidecheck.service` show whether the last run failed.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
