# Check fail2ban-logfile

## Overview

Scans the log of fail2ban for the problems that leave a host unprotected while fail2ban itself keeps running and its jails keep listing bans: ban actions that fail, firewall rules that disappeared, bans that do not stop the client, jails that stopped reading their log, a database fail2ban cannot use, host names resolved instead of addresses, log lines fail2ban cannot place in time, and configuration errors that kept fail2ban or a jail from starting. Startups, shutdowns and bans are counted alongside them. Alerts when one of those problems shows up, when banned clients keep appearing in the logs more often than the thresholds allow within `--lookback`, and when a line arrives at a level `--critical-level` or `--warning-level` covers. Lines about the current fail2ban process count; what a process before the last startup wrote is history, because a restart rebuilds the firewall rules and rereads the configuration. The log is read from the file `logtarget` in the fail2ban configuration names, together with the journal of the fail2ban unit, which holds the errors of a start that failed, or from a file (`/var/log` only) or a container (`docker:`/`podman:`/`kubectl:`) named with `--server-log`. Requires root or sudo.

[fail2ban](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/fail2ban/) reports what fail2ban says about itself: whether it answers, and which addresses its jails list as banned. This check reports whether those bans work.

**Important Notes:**

* A ban that does not stop the client is found through fail2ban's own consistency check: it logs `already banned` as a `WARNING` only when a banned client shows up in a log more than a minute after its ban. Typical causes are a jail that bans a port the service does not listen on, a ban action that does not work on this firewall, and HTTP clients that go on over a connection they opened before the ban.
* A configuration error alerts only while no start followed it. Use [systemd-unit](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/systemd-unit/) or [fail2ban](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/fail2ban/) to know whether fail2ban runs.
* `WARNING` lines do not alert by default, because fail2ban also warns about things that need no action, such as a log line it read late. `--warning-level=WARNING` changes that. The warnings that do need action are named events and alert anyway.
* A line dated well before the current time does not alert: Apache logs a long request, a WebSocket for example, with its start time when it ends, hours later. A line dated after the current time does.
* With `logtarget = SYSTEMD-JOURNAL`, fail2ban writes no level into the line, so only the named events are recognized, and banned clients that show up again are not counted.
* `--server-log` is confined to `/var/log`, because the check runs as root.
* `--ignore` and `--match` are matched against the lowercased line.

**Data Collection:**

* Reads `logtarget` from `/etc/fail2ban/fail2ban.conf`, `fail2ban.d/*.conf`, `fail2ban.local` and `fail2ban.d/*.local`, in the order fail2ban reads them. A file is read together with the one it was rotated to (last 30000 lines). If systemd runs the host and `fail2ban.service` exists, its journal of the current boot is read as well, because a start whose configuration fails writes its errors there before fail2ban switches to its log target.
* Joins the lines of an action command that spans several lines.
* Judges every error and warning message of the fail2ban server and client (fail2ban 1.1.1):

| Event | Messages | Why it needs action |
|----|----|----|
| Configuration error | A start that failed (`Failed during configuration`, `Async configuration of server failed`, `Could not start server`, `Server already running`), a skipped jail (`Errors in jail`, `Unable to read the filter`, `Have not found any log file`, `Found no accessible config files`), and settings fail2ban replaced or could not apply (`Wrong value`, `Unknown backend`, `ban time increment is not available`, `Unable to find a corresponding IP address for` a host in `ignoreip`, `Unable to log to`) | fail2ban or a jail does not run, or runs with a setting other than the configured one. |
| Failed action | `Failed to execute ban/unban/reban jail`, `Failed to start/stop jail`, `Failed to flush bans`, `unhandled error in actions thread`, together with the `stderr:`, `timed out` and `killed` lines of the command | The firewall does not hold the bans fail2ban lists. |
| Lost firewall rule set | `Invariant check failed`, `Unable to restore environment` | The rules disappeared while fail2ban ran, usually through a firewall reload, and bans had no effect until fail2ban rebuilt them. |
| Failed log reader | `Caught unhandled exception in main cycle`, `Too many errors at once`, `Unable to open`, `Error reading line from systemd journal`, `Observer stopped after error` and the other errors of the backends | The jail bans no one while `fail2ban-client status` still lists it. |
| Database error | `Restore bans failed`, `Error opening fail2ban persistent database`, the errors of the `fail2ban.database` logger, and the SQLite errors the observer logs bare (`database disk image is malformed`) | Bans do not survive a restart, and repeat offenders are not banned longer. |
| Host name lookup | `Determined IP using DNS Lookup` | A filter caught a host name instead of an address, and fail2ban bans what that name resolves to. |
| Timestamp problem | `Detected a log entry ... after the current time`, `Found a match but no valid date/time found` | Lines from the future point to a wrong time zone or clock; matches without a date are dropped. |
| Ineffective ban | `already banned` at `WARNING` | The ban does not stop the client. |

Counted, but not alerting: refused `fail2ban-client` commands (`Command [...] has failed`), which the administrator already saw on the command line, and the companion lines of a timestamp problem. Everything else counts by its level, for example the communication errors of the server socket and the errors of the Cymru lookups.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/fail2ban-logfile> |
| Nagios/Icinga Check Name              | `check_fail2ban_logfile` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |
| Requirements                          | User with higher permissions |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-fail2ban-logfile-*.db` (only with `--icinga-callback`) |


## Help

```text
usage: fail2ban-logfile [-h] [-V] [--always-ok]
                        [--critical-level {CRITICAL,ERROR,WARNING,none}]
                        [--icinga-callback]
                        [--icinga-password ICINGA_PASSWORD]
                        [--icinga-service-name ICINGA_SERVICE_NAME]
                        [--icinga-url ICINGA_URL]
                        [--icinga-username ICINGA_USERNAME] [--ignore IGNORE]
                        [--ineffective-bans-critical INEFFECTIVE_BANS_CRITICAL]
                        [--ineffective-bans-warning INEFFECTIVE_BANS_WARNING]
                        [--insecure] [--lookback LOOKBACK] [--match MATCH]
                        [--no-insecure]
                        [--no-match-severity {ok,warn,crit,unknown}]
                        [--no-perfdata] [--no-proxy] [--proxy PROXY]
                        [--server-log SERVER_LOG] [--timeout TIMEOUT]
                        [--warning-level {CRITICAL,ERROR,WARNING,none}]

Scans the log of fail2ban for the problems that leave a host unprotected while
fail2ban itself keeps running and its jails keep listing bans: ban actions
that fail, firewall rules that disappeared, bans that do not stop the client,
jails that stopped reading their log, a database fail2ban cannot use, host
names resolved instead of addresses, log lines fail2ban cannot place in time,
and configuration errors that kept fail2ban or a jail from starting. Startups,
shutdowns and bans are counted alongside them. Alerts when one of those
problems shows up, when banned clients keep appearing in the logs more often
than the thresholds allow within `--lookback`, and when a line arrives at a
level `--critical-level` or `--warning-level` covers. Lines about the current
fail2ban process count; what a process before the last startup wrote is
history, because a restart rebuilds the firewall rules and rereads the
configuration. The log is read from the file `logtarget` in the fail2ban
configuration names, together with the journal of the fail2ban unit, which
holds the errors of a start that failed, or from a file (`/var/log` only) or a
container (`docker:`/`podman:`/`kubectl:`) named with `--server-log`. Requires
root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --critical-level {CRITICAL,ERROR,WARNING,none}
                        Least severe fail2ban log level that returns CRITICAL.
                        Each level includes everything more severe than
                        itself, so `ERROR` covers `CRITICAL` as well. Case-
                        sensitive. `none` lets no level return CRITICAL, which
                        leaves the events this check names as the only way to
                        reach it. Example: `--critical-level=ERROR`. Default:
                        CRITICAL
  --icinga-callback     Ask the monitoring server whether the service running
                        this check is acknowledged. Where it is, what this run
                        reports is remembered as already handled, so it no
                        longer raises an alert on the following runs. Requires
                        `--icinga-url`, `--icinga-username`, `--icinga-
                        password` and `--icinga-service-name`.
  --icinga-password ICINGA_PASSWORD
                        Monitoring server API password.
  --icinga-service-name ICINGA_SERVICE_NAME
                        Unique name of the service running this check, as the
                        monitoring server knows it. Take it from the `__name`
                        service attribute. Example: `monitoring-server!my-
                        service-name`.
  --icinga-url ICINGA_URL
                        Monitoring server API URL. Example:
                        `https://monitoring.example.com:5665`.
  --icinga-username ICINGA_USERNAME
                        Monitoring server API username.
  --ignore IGNORE       Ignore a log line matching this Python regular
                        expression. The log line is lowercased before
                        matching, so write the pattern in lowercase (or use
                        the `(?i)` flag). Can be specified multiple times.
                        Example: `--ignore='(?i)linuxfabrik'`
  --ineffective-bans-critical INEFFECTIVE_BANS_CRITICAL
                        Number of banned clients that showed up in the logs
                        again more than a minute after their ban within
                        `--lookback` that returns CRITICAL. 0 turns the
                        threshold off. Example: `--ineffective-bans-
                        critical=100`. Default: 0
  --ineffective-bans-warning INEFFECTIVE_BANS_WARNING
                        Number of banned clients that showed up in the logs
                        again more than a minute after their ban within
                        `--lookback` that returns WARNING. 0 turns the
                        threshold off. Example: `--ineffective-bans-
                        warning=50`. Default: 10
  --insecure            Applies to the connection to the monitoring server
                        that `--icinga-callback` makes, which is the only
                        network connection this check opens. This option
                        explicitly allows insecure SSL connections.
  --lookback LOOKBACK   Banned clients that show up in the logs again are
                        counted within this window rather than reported one by
                        one. Time window in seconds to look back over, ending
                        at the moment of the run. Only what falls within it is
                        counted, so what is reported is how often something
                        happened lately rather than a total that keeps growing
                        for as long as the source is kept. Example:
                        `--lookback=86400`. Default: 3600 (seconds)
  --match MATCH         Only consider a log line matching this Python regular
                        expression. The log line is lowercased before
                        matching, so write the pattern in lowercase (or use
                        the `(?i)` flag). Can be specified multiple times. If
                        both `--match` and `--ignore` are given, an item must
                        match `--match` AND not match `--ignore` to be
                        reported (include first, exclude second). Example:
                        `--match='\[sshd\]'`
  --no-insecure         Applies to the connection to the monitoring server
                        that `--icinga-callback` makes, which is the only
                        network connection this check opens. Verify the TLS
                        certificate against the system trust store, overriding
                        the insecure default of this check. Use it once the
                        endpoint presents a publicly trusted certificate, or
                        once its CA has been added to the system trust store.
  --no-match-severity {ok,warn,crit,unknown}
                        State to report when no item matches the filters and
                        nothing is checked. Default: ok
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --no-proxy            Applies to the connection to the monitoring server
                        that `--icinga-callback` makes, which is the only
                        network connection this check opens. Do not use a
                        proxy, not even one the environment names. Overrides
                        `--proxy`.
  --proxy PROXY         Applies to the connection to the monitoring server
                        that `--icinga-callback` makes, which is the only
                        network connection this check opens. Proxy to reach
                        the target through. The scheme defaults to `http` when
                        omitted. Overrides the proxy the environment names
                        (`http_proxy`, `https_proxy`, `all_proxy`) together
                        with the exceptions it lists in `no_proxy`, and is
                        itself overridden by `--no-proxy`. Without either
                        parameter the environment applies. Credentials belong
                        into the environment variable rather than here,
                        because a command-line argument is visible to every
                        user on the host. Example:
                        `--proxy=http://proxy.example.com:3128`.
  --server-log SERVER_LOG
                        Log source to read from. Accepts a file path,
                        `docker:CONTAINER`, `podman:CONTAINER`,
                        `kubectl:CONTAINER` or `systemd:UNITNAME`. Can be
                        specified multiple times, and everything named is then
                        read as one window; a source named twice is read once.
                        If omitted, the check reads the file `logtarget` in
                        the fail2ban configuration names, and the journal of
                        `fail2ban.service`. Example: `--server-
                        log=/var/log/fail2ban.log`
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --warning-level {CRITICAL,ERROR,WARNING,none}
                        Least severe fail2ban log level that returns WARNING.
                        Each level includes everything more severe than
                        itself, and a level that `--critical-level` already
                        covers returns CRITICAL instead. Case-sensitive.
                        `none` lets no level return WARNING, which leaves the
                        events this check names as the only way to reach it.
                        Example: `--warning-level=WARNING`. Default: ERROR

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/fail2ban-logfile/
```


## Usage Examples

```bash
./fail2ban-logfile
```

```text
2026-11-23 03:48 .. 2026-11-24 16:11 (1D 12h): No errors or warnings found. 3 startups detected (last: 2026-11-24 16:11:20). 3 shutdowns detected (last: 2026-11-24 16:11:20). fail2ban 1.1.1.

Read 127 lines from 2 sources:
* `/var/log/fail2ban.log` (size: 10.6KiB) + `/var/log/fail2ban.log-20261124` (size: 108.0B)
* `systemd:fail2ban.service`
```

A firewall reload that removed the rules of fail2ban while it ran:

```text
2026-11-24 17:25 .. 2026-11-24 17:26 (12s): 1 WARNING line found. Found 1 lost firewall rule set [WARNING]. 1 startup detected (last: 2026-11-24 17:25:55). 2 bans logged (last: 2026-11-24 17:26:03). fail2ban 1.1.0.

Lost firewall rule sets:
* 1x Invariant check failed. Trying to restore a sane environment (last: 2026-11-24 17:26:03)

Command errors:
* 3x stderr: 'iptables: No chain/target/match by that name.' (last: 2026-11-24 17:26:03)
* 2x stderr: "iptables v1.8.11 (nf_tables): Chain 'f2b-t-ipt' does not exist" (last: 2026-11-24 17:26:03)
* 2x stderr: "Try `iptables -h' or 'iptables --help' for more information." (last: 2026-11-24 17:26:03)

Warning lines:
* 1x New database created. Version '4' (last: 2026-11-24 17:25:55)

Recommendations:
* The firewall rules of fail2ban disappeared while it ran, usually because the firewall was reloaded or flushed, and the bans had no effect until fail2ban rebuilt them; reload the firewall in a way that keeps the `f2b-*` chains or sets, or restart fail2ban after a reload

Read 48 lines from 1 source:
* `/var/log/fail2ban.log` (size: 4.5KiB)
```

A production host whose sshd jail lost the journal file it read:

```text
2026-11-13 05:02 .. 2026-11-21 08:21 (1W 1D): Found 7 failed log readers [WARNING]. 1 startup detected (last: 2026-11-13 05:02:40). fail2ban 1.1.0.

Failed log readers:
* 6x Caught unhandled exception in main cycle: AttributeError("'NoneType' object has no attribute 'wait'") (last: 2026-11-21 08:21:05)
* 1x Caught unhandled exception in main cycle: FileNotFoundError(2, 'No such file or directory') (last: 2026-11-21 08:20:53)

Recommendations:
* A jail stopped reading its log or journal, so it bans no one while it is still listed as running; restart fail2ban, and if the error comes back, check that the log the jail names (`fail2ban-client get sshd logpath` for the sshd jail) exists and is readable

Read 61 lines from 1 source:
* `/var/log/fail2ban.log` (size: 7.0KiB)
```

```bash
# Count banned clients that show up again over a day instead of an hour.
./fail2ban-logfile --lookback=86400 --ineffective-bans-warning=50

# fail2ban in a container.
./fail2ban-logfile --server-log=podman:fail2ban
```


## States

* OK if no event, no line at the levels `--critical-level` and `--warning-level` cover and no rate above its threshold is found.
* WARN if the current process logged a configuration error, a failed action, a lost firewall rule set, a failed log reader, a database error, a host name lookup or a timestamp problem, or if a start failed after the last start that worked.
* WARN or CRIT if the number of banned clients that showed up again more than a minute after their ban within `--lookback` reaches `--ineffective-bans-warning` (default: 10) or `--ineffective-bans-critical` (default: 0, off).
* WARN if the current process logged a line at `--warning-level` (default: `ERROR`) or worse, CRIT at `--critical-level` (default: `CRITICAL`) or worse.
* WARN if one of several sources could not be read.
* If the most recent 30000 lines read per source reach back less far than `--lookback`, the output says so and recommends a shorter `--lookback`, without changing the state. Every rate is then counted over a shorter stretch of time than its thresholds assume and counts low, so a burst that matters could stay below them.
* UNKNOWN if neither a log file nor `fail2ban.service` is found and no `--server-log` is given, if the source cannot be read, if no line was written by fail2ban, and on invalid command-line arguments.
* `--no-match-severity` sets the state when `--match` drops every line (default: `ok`).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| fail2ban_action_failures | Number | Number of failed ban, unban, start, stop or flush actions of the current process. |
| fail2ban_bans | Number | Number of bans found in the log, restored ones included. |
| fail2ban_config_errors | Number | Number of configuration errors of the current process, or of the start that failed after it. |
| fail2ban_critical_lines | Number | Number of `CRITICAL` lines of the current process, not counting the events. |
| fail2ban_database_errors | Number | Number of database errors of the current process. |
| fail2ban_dns_lookups | Number | Number of host names a filter caught and fail2ban resolved, in the current process. |
| fail2ban_error_lines | Number | Number of `ERROR` lines of the current process, not counting the events and the action commands. |
| fail2ban_ineffective_bans | Number | Number of banned clients that showed up in a log again more than a minute after their ban, within the lookback window. |
| fail2ban_logfile_size | Bytes | Log file size, for a file source only. |
| fail2ban_lost_rules | Number | Number of times the current process found its firewall rules gone. |
| fail2ban_reader_failures | Number | Number of errors of jails reading their log or journal, in the current process. |
| fail2ban_shutdowns | Number | Number of shutdowns found in the log. |
| fail2ban_startups | Number | Number of startups found in the log. |
| fail2ban_timestamp_problems | Number | Number of lines from the future and matches without a date, in the current process. |
| fail2ban_warning_lines | Number | Number of `WARNING` lines of the current process, not counting the events. |


## Troubleshooting

### No log found

`Found neither a log file in the fail2ban configuration nor a fail2ban.service unit`

fail2ban logs to the journal on a host that systemd does not run, or runs under another unit name or in a container. Name the source: `--server-log=systemd:my-fail2ban.service`, `--server-log=podman:fail2ban` or a file below `/var/log`.

### The log does not look like the log of fail2ban

`None of the <n> lines read from <source> looks like a line of fail2ban`

The source holds something else. Check `--server-log`, and `logtarget` in `/etc/fail2ban/fail2ban.local`.

### Banned clients keep showing up

1. Compare the `port` of the jail (`fail2ban-client get sshd actionproperties iptables-multiport` or the jail configuration) with the port the service listens on (`ss --listening --tcp --numeric --processes`). A jail that bans port 22 does not stop a client of an sshd on port 2222.
2. Check that the ban reaches the firewall: `iptables --list --numeric | grep f2b-` or `nft list ruleset | grep f2b`.
3. For a web server, check that the jail closes the connections a client opened before its ban; a firewall rule for new connections does not stop a client that keeps one HTTP/2 connection busy.

### A jail stopped reading its log

Restart fail2ban. If the error comes back, check the log the jail reads: `fail2ban-client get <jail> logpath`, or for `backend = systemd` the journal (`journalctl --verify`).

### The database is corrupt

Stop fail2ban, move `/var/lib/fail2ban/fail2ban.sqlite3` aside and start fail2ban again. It creates a new database and forgets the current bans and the ban history of repeat offenders.

### Host names are resolved

Find the jail whose `Found` lines name the address the lookup returned. Its filter took something else for the client, for example the virtual host name an Apache log format writes in front of the client address. Fix the filter or the log format. Where the log really holds host names only, set `usedns = yes` in the jail to make the lookup deliberate, or `usedns = no` to ignore such lines.

### The rates cover only part of `--lookback`

`The rates count low: they cover only the last <duration> of --lookback (<duration>), as far as the most recent 30K lines read per source reach back`

The log grows faster than the 30000 lines this check reads per source reach back, so the rates are counted over less time than `--lookback` names. Lower `--lookback` to the duration the message names and the rate thresholds in proportion, for example `--lookback=300` with half the thresholds where the check covers five of the ten minutes. Where one application floods the log, keeping that out of it widens the window again.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
