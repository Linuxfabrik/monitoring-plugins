# Check freeipa-logfile


## Overview

Evaluates the result file of ipa-healthcheck, which checks a FreeIPA server for certificate, replication, topology, DNS, service and file permission problems once a day, for example through ipa-healthcheck.timer. The check itself does not run ipa-healthcheck, so it is fast and needs no more than read access to the result file. Alerts when ipa-healthcheck reports a problem, when a FreeIPA server has no result file, and when the result file is damaged or older than the maximum age, because then the daily run has stopped. After the nightly log rotation, the result of the rotated file stands until the next run. ipa-healthcheck runs once a day and the services of the server are better watched in real time, so by default only WARNING is raised.

**Important Notes:**

* The check reads `/var/log/ipa/healthcheck/healthcheck.log`, which `ipa-healthcheck.service` writes with `ipa-healthcheck --output-file`. The package (`ipa-healthcheck` on the Red Hat family, `freeipa-healthcheck` on Fedora, Debian and Ubuntu) ships the service and `ipa-healthcheck.timer`, but leaves the timer disabled. Enable it with `sudo systemctl enable --now ipa-healthcheck.timer`. The `FreeIPA Server Service Set` in the Icinga Director checks the timer as well.
* The result file is created `0644 root:root` in a `0755` directory, so the check needs no sudo (measured on Debian 12 and 13, Rocky 8, 9 and 10).
* ipa-healthcheck exits with 1 as soon as one result is not `SUCCESS`, so `ipa-healthcheck.service` is `failed` after every run that found something. This check reports the details, which is why the OS Basic Service Sets in the Icinga Director let `Systemd Units Failed` ignore `ipa-healthcheck.service`.
* A run takes 20 to 30 seconds on a single server and writes the whole file at its very end. A run that hangs or is killed leaves the result of the run before in place, and the age check reports it once it is older than `--max-age`.
* On a FreeIPA server without a result file, the check returns WARNING, not UNKNOWN: ipa-healthcheck belongs on a server that got this check, so a missing package or a timer that never ran is a gap to close. On a host without FreeIPA server it returns OK.
* The FreeIPA server is available on the Red Hat family and Fedora only. Debian and Ubuntu package ipa-healthcheck, but not the server, so on these hosts the check reports that no FreeIPA server is installed.

**Data Collection:**

* Reads the JSON list ipa-healthcheck writes, one entry per result with `source`, `check`, `result`, `when`, `duration` and `kw`.
* Lists every result that is not `SUCCESS` the way `ipa-healthcheck --output-type human` prints it, `<result>: <source>.<check>[.<key>]: <message>`, most severe first, at most 50 of them. A check that raised an exception reports the exception, never its traceback.
* `--ignore` drops results by a Python regular expression on the printed line without the result value, so it matches the check, the key or the message. The line is lowercased before matching, so write the pattern in lowercase (or use the `(?i)` flag). Ignored results do not count anywhere. To keep ipa-healthcheck itself from reporting something, use the `[excludes]` section of `/etc/ipahealthcheck/ipahealthcheck.conf` (`source`, `check` or `key`).
* The age of the result is the newest `when` in the file, the moment ipa-healthcheck recorded the result. Copying or touching the file does not change it. Only a file without a single result (`[]`, which `--failures-only` writes on a server without a problem) falls back to the modification time.
* logrotate rotates the file daily (`create`, `dateext`, `rotate 30`) and leaves an empty file until the next run. Until then, the check evaluates the newest rotated file (by modification time, compressed or not) and says so. Its age keeps counting, so a run that never comes is reported after `--max-age`.
* The result file and the rotated files are read only as regular files inside `/var/log/ipa/healthcheck`, and a symlink is never followed.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/freeipa-logfile> |
| Nagios/Icinga Check Name              | `check_freeipa_logfile` |
| Check Interval Recommendation         | Every hour |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |
| Requirements                          | A daily ipa-healthcheck run, for example `ipa-healthcheck.timer` |


## Help

```text
usage: freeipa-logfile [-h] [-V] [--always-ok]
                       [-c {CRITICAL,ERROR,WARNING,none}] [--ignore IGNORE]
                       [--max-age MAX_AGE] [--no-perfdata]
                       [-w {CRITICAL,ERROR,WARNING,none}]

Evaluates the result file of ipa-healthcheck, which checks a FreeIPA server
for certificate, replication, topology, DNS, service and file permission
problems once a day, for example through ipa-healthcheck.timer. The check
itself does not run ipa-healthcheck, so it is fast and needs no more than read
access to the result file. Alerts when ipa-healthcheck reports a problem, when
a FreeIPA server has no result file, and when the result file is damaged or
older than the maximum age, because then the daily run has stopped. After the
nightly log rotation, the result of the rotated file stands until the next
run. ipa-healthcheck runs once a day and the services of the server are better
watched in real time, so by default only WARNING is raised.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical {CRITICAL,ERROR,WARNING,none}
                        Least severe ipa-healthcheck result that returns
                        CRITICAL. Each result includes everything more severe
                        than itself, so `ERROR` covers `CRITICAL` as well.
                        Case-sensitive. `none` lets no result return CRITICAL.
                        Example: `--critical=CRITICAL`. Default: none
  --ignore IGNORE       Ignore an ipa-healthcheck result matching this Python
                        regular expression. It is matched against the line the
                        check prints for the result,
                        `<source>.<check>[.<key>]: <message>`, without the
                        result value. The line is lowercased before matching,
                        so write the pattern in lowercase (or use the `(?i)`
                        flag). Can be specified multiple times. Example:
                        `--ignore=ipadnssystemrecordscheck`
  --max-age MAX_AGE     Maximum age of the ipa-healthcheck result in hours. An
                        older result means that the daily run no longer
                        happens. Default: 26 (0 disables the check)
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  -w, --warning {CRITICAL,ERROR,WARNING,none}
                        Least severe ipa-healthcheck result that returns
                        WARNING. Each result includes everything more severe
                        than itself, and a result that `--critical` already
                        covers returns CRITICAL instead. Case-sensitive.
                        `none` lets no result return WARNING. Example:
                        `--warning=ERROR`. Default: WARNING

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/freeipa-logfile/
```


## Usage Examples

```bash
./freeipa-logfile
```

Output on a server installed without the integrated DNS, where the SRV and URI records ipa-healthcheck expects are missing:

```text
ipa-healthcheck found 12 warnings in 277 results [WARNING], last run 2h 13m ago

* WARNING: ipahealthcheck.ipa.idns.IPADNSSystemRecordsCheck._ldap._tcp.example.test.:ipa-rocky-9.example.test.: Expected SRV record missing [WARNING]
* WARNING: ipahealthcheck.ipa.idns.IPADNSSystemRecordsCheck._kerberos._tcp.example.test.:ipa-rocky-9.example.test.: Expected SRV record missing [WARNING]
...
* WARNING: ipahealthcheck.ipa.idns.IPADNSSystemRecordsCheck.ipa_ca_missing_ipa-rocky-9.example.test: missing IP address for ipa-ca server ipa-rocky-9.example.test [WARNING]

The current state of the server: `sudo ipa-healthcheck --failures-only`.
```

The same server, with the DNS records accepted:

```bash
./freeipa-logfile --ignore=ipadnssystemrecordscheck
```

```text
ipa-healthcheck found no problem in 265 results (12 ignored by `--ignore`), last run 2h 13m ago
```

A stopped service and a file with the wrong permissions, alerting CRITICAL from `ERROR` on:

```bash
./freeipa-logfile --critical=ERROR
```

```text
ipa-healthcheck found 2 errors, 12 warnings in 277 results [CRITICAL], last run 1h 2m ago

* ERROR: ipahealthcheck.meta.services.ipa_custodia: ipa-custodia: not running [CRITICAL]
* ERROR: ipahealthcheck.ipa.files.IPAFileCheck._etc_ipa_ca.crt_mode: Permissions of /etc/ipa/ca.crt are too restrictive: 0600 and should be 0644 [CRITICAL]
* WARNING: ipahealthcheck.ipa.idns.IPADNSSystemRecordsCheck._ldap._tcp.example.test.:ipa-rocky-9.example.test.: Expected SRV record missing [WARNING]
...
```


## States

ipa-healthcheck knows four result values (`ipahealthcheck.core.constants`). By default they map as follows:

* `SUCCESS`: OK.
* `WARNING`: WARN. Something deserves attention but does not break the server yet, for example a certificate that expires within 28 days or a missing DNS record.
* `ERROR`: WARN. Something is wrong, for example a stopped service, wrong file permissions or a check that ran out of time.
* `CRITICAL`: WARN. A check raised an exception, often because the directory server was not reachable during the run, or lib389 reports a high severity problem of the directory server.
* Any other value: WARN. ipa-healthcheck writes a value it has no name for as it is, so a newer version could bring one, and a human should look at it.

Why WARN for `ERROR` and `CRITICAL`: the result is up to a day old when the check reads it, paging someone at night does not make it fresher, and a server that is really down is reported in real time by the service and port checks of the `FreeIPA Server Service Set`. `--warning` and `--critical` move the boundaries: `--critical=CRITICAL` returns CRITICAL for `CRITICAL` results, `--critical=ERROR` also for `ERROR` results, `--warning=ERROR` lets `WARNING` results pass, and `none` switches a level off.

In addition:

* WARN if the newest result is older than `--max-age` hours (default: 26), because the daily run has then stopped. `--max-age=0` switches this off.
* WARN if the result file is not a JSON list of results: damaged, or written with another `--output-type`. ipa-healthcheck writes the file in one go at the end of a run, so a check that happens to read it in that moment sees this once.
* OK if the result file is empty and no rotated file holds a result, WARN once that file is older than `--max-age`.
* WARN on a FreeIPA server without a result file, with a hint: without ipa-healthcheck how to install it, and where ipa-healthcheck has not run yet how to enable the timer.
* OK on a host without FreeIPA server, since there is nothing to check.
* UNKNOWN if the check may not list `/var/log/ipa/healthcheck`, or if the result file is a symlink or not a regular file.
* UNKNOWN on an invalid `--ignore` regular expression.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| report_age | Seconds | Time since ipa-healthcheck recorded the newest result. |
| results_critical | Number | Number of `CRITICAL` results. |
| results_error | Number | Number of `ERROR` results. |
| results_success | Number | Number of `SUCCESS` results. |
| results_warning | Number | Number of `WARNING` results. |

Results dropped by `--ignore` are not counted.


## Troubleshooting

### ipa-healthcheck is not installed

`No ipa-healthcheck result found at /var/log/ipa/healthcheck/healthcheck.log, because ipa-healthcheck is not installed.`

Install ipa-healthcheck and run it once a day: `sudo dnf --assumeyes install ipa-healthcheck && sudo systemctl enable --now ipa-healthcheck.timer`. On Fedora, `ipa-healthcheck` installs the `freeipa-healthcheck` package.

### ipa-healthcheck has not run yet

`No ipa-healthcheck result found at /var/log/ipa/healthcheck/healthcheck.log, so ipa-healthcheck has not run yet.`

The package is installed, but its timer is disabled by default. Enable it with `sudo systemctl enable --now ipa-healthcheck.timer`, and write a first result right away with `sudo systemctl start ipa-healthcheck.service`.

### The result is older than `--max-age`

1. `systemctl list-timers ipa-healthcheck.timer` shows when the timer last ran and when it runs next. An inactive timer is not enabled: `sudo systemctl enable --now ipa-healthcheck.timer`.
2. `sudo journalctl --unit ipa-healthcheck.service` shows the last runs. A run that hangs never writes its result; `systemctl status ipa-healthcheck.service` shows whether one is still running.
3. The shipped timer runs at a fixed time and catches up on nothing, so a server that was switched off at that time has no result for that day.

### The result file is no JSON list

`The ipa-healthcheck result file /var/log/ipa/healthcheck/healthcheck.log is not a JSON list of results.`

The file was damaged, or something wrote it with another output type, for example `ipa-healthcheck --output-type human --output-file /var/log/ipa/healthcheck/healthcheck.log` by hand. Write a new result with `sudo systemctl start ipa-healthcheck.service`.

### `Failed to list /var/log/ipa/healthcheck: permission denied`

The directory is `0755` as shipped, so someone changed it. Restore it with `sudo chmod 0755 /var/log/ipa/healthcheck`.

### A result you do not want to fix

Accept it in ipa-healthcheck itself, so that `ipa-healthcheck --failures-only` on the console no longer shows it either. In `/etc/ipahealthcheck/ipahealthcheck.conf`:

```ini
[excludes]
check = IPADNSSystemRecordsCheck
```

`source` excludes a whole source (`ipahealthcheck.ipa.idns`), `key` a single result by its key. The next run no longer reports it. To accept it only on the monitoring side, use `--ignore` with a regular expression on the printed line instead, for example `--ignore=ipadnssystemrecordscheck`.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
