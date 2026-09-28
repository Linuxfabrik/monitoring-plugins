# Check lynis-logfile


## Overview

Evaluates the report of the lynis security audit that runs on the host once a day, for example through lynis.timer, and reports the hardening index, the findings (the lynis warnings) and the hardening suggestions of lynis. The check itself does not run an audit, so it is fast and needs no more than read access to the report. Alerts when the hardening index is below the threshold, when lynis reports a finding, and when the report is missing, incomplete or older than the maximum age, because then the daily audit has stopped. Security posture is informational drift rather than a time-critical availability event, so by default only WARNING is raised.

**Important Notes:**

* The check reads `/var/log/lynis-report.dat`, which lynis writes when it audits the host as root. Something else has to run that audit once a day, for example `lynis.timer`, which the Debian and Ubuntu packages ship, or a timer of your own on the Red Hat family, where the EPEL package only ships the units as documentation. The command the timer runs is `lynis audit system --cronjob`.
* lynis creates the report readable by root only (`umask 027`), so run the check via `sudo` (see the sudoers files in `assets/sudoers`). The `Lynis Service Set` in the Icinga Director does exactly that on every host tagged `lynis`, and also checks `lynis.service` and `lynis.timer`.
* lynis rewrites the report while it audits and writes the hardening index and the end of the audit last. An audit takes 20 seconds to a minute (measured on Debian 12/13, Rocky 8/9/10 and Ubuntu 22.04/24.04/26.04). A check that runs during that time reports UNKNOWN once, and the next run reads the finished report.
* `lynis show details <test>` on the host prints the details of a finding or suggestion from `/var/log/lynis.log`.
* A security audit is posture drift, not a time-critical availability event, so by default only WARNING is raised. The default critical threshold is empty on purpose, to avoid paging someone at night for a hardening drop.

**Data Collection:**

* The state is the worst of: the hardening index against `--warning` / `--critical` (Nagios ranges, default warns below 65), the presence of any lynis warning, and the age of the report against `--max-age`.
* The age is the time since the audit finished, as lynis records it in the report (`report_datetime_end`), not the modification time of the file.
* Every lynis warning is listed under "Findings" with its test ID, its details where lynis gives any (the interface behind a `NETW-3015`, for example) and a `[WARNING]` marker. A warning is a concrete finding, not noise; accept it on the host (see Troubleshooting), not in this plugin.
* lynis suggestions are hardening advice. They are listed under "Suggestions" and do not change the state.
* Both lists are sorted by test ID.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/lynis-logfile> |
| Nagios/Icinga Check Name              | `check_lynis_logfile` |
| Check Interval Recommendation         | Every hour |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |
| Requirements                          | A daily lynis audit, for example `lynis.timer`; User with higher permissions |


## Help

```text
usage: lynis-logfile [-h] [-V] [--always-ok] [-c CRIT] [--max-age MAX_AGE]
                     [--no-perfdata] [-w WARN]

Evaluates the report of the lynis security audit that runs on the host once a
day, for example through lynis.timer, and reports the hardening index, the
findings (the lynis warnings) and the hardening suggestions of lynis. The
check itself does not run an audit, so it is fast and needs no more than read
access to the report. Alerts when the hardening index is below the threshold,
when lynis reports a finding, and when the report is missing, incomplete or
older than the maximum age, because then the daily audit has stopped. Security
posture is informational drift rather than a time-critical availability event,
so by default only WARNING is raised. Requires root or sudo.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  -c, --critical CRIT  CRIT threshold for the hardening index (0-100).
                       Supports Nagios ranges. Empty by default, because a
                       daily hardening scan is posture drift, not a time-
                       critical event that should page someone at night.
                       Default: (no critical)
  --max-age MAX_AGE    Maximum age of the report in hours. An older report
                       means that the daily audit no longer runs. Default: 26
                       (0 disables the check)
  --no-perfdata        Suppress the performance data section from the output.
                       The status message and the exit code are unaffected, so
                       alerting keeps working while trending data is dropped.
  -w, --warning WARN   WARN threshold for the hardening index (0-100).
                       Supports Nagios ranges. The default alerts when the
                       index drops below 65. Default: 65:

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/lynis-logfile/
```


## Usage Examples

```bash
sudo ./lynis-logfile
```

```text
Hardening index 60 [WARNING], 1 finding [WARNING], 49 suggestions, audited 3h 12m ago

Findings:
* PKGS-7392: Found one or more vulnerable packages. [WARNING]

Suggestions:
* ACCT-9622: Enable process accounting.
* ACCT-9626: Enable sysstat to collect accounting (no results).
...
* USB-1000: Disable drivers like USB storage when not used, to prevent unauthorized storage or data theft.

To look up an item, run `lynis show details PKGS-7392` on the host. To accept it, add `skip-test=PKGS-7392` to `/etc/lynis/custom.prf`.
```

Warn below a hardening index of 70, critical below 50, and accept a report of up to two days:

```bash
sudo ./lynis-logfile --warning=70: --critical=50: --max-age=48
```


## States

* OK if the hardening index is within the `--warning` / `--critical` range, lynis reports no warning, and the report is not older than `--max-age`.
* WARN if the hardening index drops below `--warning` (default: 65), or lynis reports at least one warning.
* WARN if the audit finished more than `--max-age` hours ago (default: 26), because the daily audit has then stopped. `--max-age 0` switches this off.
* WARN if there is no report, because the host is then not being audited.
* WARN if the report is incomplete and no audit is running, because the last audit did not finish.
* CRIT if the hardening index drops below `--critical` (empty by default, so CRIT is never raised unless a threshold is set).
* UNKNOWN if an audit is running right now, so the report is not complete yet, and if the report cannot be read, most likely because the check does not run via `sudo`.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| findings | Number | Number of findings (lynis warnings). |
| hardening_index | Number | Hardening index of the host (0-100). |
| suggestions | Number | Number of lynis suggestions. |


## Troubleshooting

### `No lynis report found at /var/log/lynis-report.dat`

No lynis audit has run on this host yet. Install lynis (from EPEL on the RHEL family, from the distribution on Debian and Ubuntu) and have it audit the host once a day, for example with `systemctl enable --now lynis.timer`. On the Red Hat family, create the timer first: the EPEL package only ships `lynis.service` and `lynis.timer` below `/usr/share/doc/lynis`.

### `The report is readable by root only`

The check does not run as root. Call it via `sudo`, as the `Lynis Service Set` and the `tpl-service-lynis-logfile-sudo` template in the Icinga Director do, and deploy the sudoers file from `assets/sudoers`.

### `The lynis report /var/log/lynis-report.dat is incomplete`

The last audit did not finish, so the report lacks the hardening index and the end of the audit. `journalctl --unit lynis.service` shows why the audit stopped. Start a new audit with `systemctl start lynis.service` once the cause is fixed.

### The report is older than `--max-age`

1. `systemctl list-timers lynis.timer` shows when the timer last ran and when it runs next. An inactive timer is not enabled: `systemctl enable --now lynis.timer`.
2. `systemctl status lynis.service` and `journalctl --unit lynis.service` show whether the last run failed.
3. A host that was switched off for a while catches up after the next boot if the timer is `Persistent=true`.

### Accepting a finding you do not want to fix

The plugin never silences individual lynis warnings; every warning raises at least WARNING. Acceptance belongs in lynis itself, where a test is skipped when its ID is listed with `skip-test=` in a profile. For example, to accept this finding:

```text
* PKGS-7392: Found one or more vulnerable packages. [WARNING]
```

Add the test ID to the host's `/etc/lynis/custom.prf`:

```text
skip-test=PKGS-7392
```

The next audit no longer reports `PKGS-7392`. A single check within a test is skipped with `skip-test=SSH-7408:loglevel`. Lynis refuses to run at all if a line of a profile other than a comment contains a character outside of letters, digits and `/[]()_|,.:;=-`, so keep the reason for an exception on a comment line of its own.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
