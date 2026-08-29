# Check sshd-logfile


## Overview

Scans the log of the OpenSSH server for the events an administrator has to act on: a server that refused to start, a host key it could not load, a key file it refused because of how it looks on disk, a key somebody revoked and is still using, a session that died on a signal, and a root login that only `PermitRootLogin` stopped - which means the credentials for it were valid. Startups, restarts, shutdowns and successful logins are counted alongside them, so a server that keeps restarting is visible. Everything a client can provoke - a password that did not match, a login for an account that does not exist, a connection that ended before authentication, a connection the server refused because it was at `MaxStartups` - is counted within `--lookback` and judged by how many of them arrived, not by the fact that they did: one is a typo or a bot, hundreds within ten minutes is somebody guessing passwords. Every host that answers on port 22 collects these all day, so counting them by rate is what keeps the check from being permanently yellow. sshd writes no severity into its lines, so what is reported is what this check recognizes; anything else it wrote is read but not counted. The log is read either from a file, from a systemd unit (`systemd:`) or from a container (`docker:`/`podman:`/`kubectl:`). Without `--server-log` the check takes the first of the usual authentication logs of the distributions that exists, and falls back to the journal of the sshd unit where there is none. The most recent rotated file is read along with the live one, so the window does not end where logrotate last ran. Note that sshd logs to its standard error until it has loaded its host keys, so a rejected configuration, a host key it could not read and the "no hostkeys available" it exits with never reach the syslog file. They show up only when the unit is read (`--server-log=systemd:sshd.service`). Requires root or sudo.

**Important Notes:**

* **sshd writes no log level, so this check reports what it recognizes and nothing else.** MySQL writes `[ERROR]`, PHP-FPM writes `WARNING:` and Apache writes `[core:error]`; sshd writes neither. The `error:` and `fatal:` prefixes it does write say how a message was logged, not how bad the situation is: an internet-facing host collects `error: kex_exchange_identification: Connection closed by remote host` by the thousand, and OpenSSH 8.0 on the RHEL 8 family words a scanner that walked away as `fatal: Timeout before authentication`. Alerting on those prefixes would page somebody every night. What is worth an alert is therefore named one message at a time, and a line the check does not recognize is read and left uncounted.
* **A server that never started is invisible in the syslog file.** sshd logs to its standard error until it has loaded its host keys, so a rejected configuration, a host key it could not read and `sshd: no hostkeys available -- exiting.` never reach `/var/log/secure` or `/var/log/auth.log`. Under systemd that output lands in the journal. Point the check at the unit (`--server-log=systemd:sshd.service`) to see those, and use [systemd-unit](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/systemd-unit.md) to know whether sshd is running at all. An address it could not bind is the exception and does reach the file, because binding happens after the switch to syslog.
* **The syslog file is the default because it sees every session, whatever unit handled it.** Where sshd is socket-activated with `Accept=yes` - which the RHEL family ships as `sshd.socket` and `sshd@.service`, disabled - every connection is handled by an instance of its own (`sshd@0-198.51.100.7:22-...service`), and the journal of `sshd.service` holds none of them. The file holds them all. The journal in turn holds what the file never sees, see above; on a host that matters, both are worth having as two services.
* **A refused root login means the credentials were valid.** sshd checks `PermitRootLogin` only after the password or the key has already been accepted, so `ROOT LOGIN REFUSED FROM` is not a failed attempt - it is a successful authentication that the directive stopped. Somebody or something holds working root credentials for this host. The line is written twice per attempt, once by the privileged process and once by the unprivileged one whose copy carries a ` [preauth]` suffix; the check counts the attempt once.
* **sshd decides per attempt whether to log a failed authentication at all.** It logs one at the level that the default `LogLevel INFO` still writes only when the method was `password`, when the account does not exist, or once half of `MaxAuthTries` has been used up; anything else stays below that and never reaches the log. On the distributions that run a password through PAM as keyboard-interactive, a failed password for an account that exists therefore produces no `Failed ...` line at all, and `error: PAM: Authentication failure for <user> from <address>` is the only trace of it. This check counts that line as the failed authentication it is, and counts the `pam_unix(sshd:auth)` line the module itself writes nowhere, so an attempt counts once whichever path it took. A `LogLevel` below `INFO` hides these lines from this check just as it hides them from the file, so the check reads the sshd configuration and says so as the first thing in its output when it finds one. It raises no state for it: turning the level down is a decision somebody took, and the check only says what follows from it.
* **A client does not get to choose which source it is counted under.** Parts of the lines this check reads are the client's own text - the account it asked for, the identification string it sent - and a client that writes an address into them would otherwise move its own lines into somebody else's count, or spread them out to stay below a threshold. The address is therefore taken from where the server writes the peer and nowhere else, and the two spellings of one client (`198.51.100.7` and `::ffff:198.51.100.7`) are counted as the one client they are.
* **A rate is counted per source address, not as a total.** Six failures from one address within the window is somebody working on this host; six failures spread over six addresses is the open network going past, and only the first is worth reporting. What the state follows is therefore the busiest single source, which is also the quantity an intrusion prevention system counts before it blocks one - so the thresholds compare against the same thing that system does. The summary names that source and, where they differ, the total and how many addresses it came from. Lines that name no source are counted together as one, so a burst of unattributable lines still reports. `--no-per-source` goes back to judging everything that arrived, for a log that reaches this check through something that rewrites or drops the address of the peer. Counters that are not about who caused them - a backend that could not be reached, connections refused for want of slots - always judge the total, because the address on such a line says nothing about the cause.
* **The rate thresholds assume an intrusion prevention system in front of this check.** A host reachable from the internet collects failed logins and probes around the clock, and the answer to those is a system that reads the same log, counts what a single source fails within a few minutes and blocks it. Such a system commonly lets five failures per source through before it steps in, so the defaults here sit just above that: what this check reports is what got past the blocking, not what the blocking is already handling. The window is `--lookback`, ten minutes by default, which is the same window those systems count in. On a host without one, the counters see every attempt of every source and the defaults are far too tight - raise them until they sit clear of what the host collects on a quiet day, and keep the ratio rather than the absolute number: a threshold is useful when it is a multiple of the normal rate, not when it is a fraction of it. `0` switches a threshold off entirely.
* **An attempt against an account that exists is not the same as one against an account that does not.** A bot working through a name list produces `Invalid user`, which every host on the internet sees all day and which alerts only in bulk. A failed password for an account that really exists is the more interesting number and has a lower threshold. sshd words both as `Failed password for ...`, with the words `invalid user` inserted in the second case, and the check keeps them apart on exactly that. It counts one `Invalid user` per connection rather than one per password tried, so a bot going through three passwords counts once.
* **`PerSourcePenalties` drops are not `MaxStartups` drops.** Since OpenSSH 9.8 the server remembers a source that misbehaved and refuses it for a while, writing `drop connection #0 from [...] penalty: exceeded LoginGraceTime`. That is the server working as designed and is counted with the aborted connections, on a loud threshold. A drop without a `penalty:` reason means sshd was at `MaxStartups` and turned away whoever connected next, an administrator included, which is why a single one of those already reports.
* **The authentication log holds more than sshd.** `sudo`, `su`, `crond` and `unix_chkpwd` write to the same syslog facility, and PAM writes its own lines under sshd's name (`pam_unix(sshd:auth): authentication failure`). None of them is counted; a PAM line about an attempt sshd already reported would count that attempt twice. A window that holds no sshd line at all is reported as UNKNOWN, because the source is then not the log sshd writes into.
* **A session that crashes is only visible from OpenSSH 9.8 on.** The listener learned to report `session process ... killed by signal` when 9.8 split it from the session process. A host below that - the RHEL 8 and RHEL 9 families among them - logs nothing when a session dies on a fault, and the counter stays at zero there.
* **The window spans the last rotation.** logrotate moves the old file aside (`secure-20260828` on the RHEL family, `auth.log.1` on the Debian family, then `.gz`) and the syslog daemon opens a fresh one. A check reading the live file alone would report a healthy server an hour after it broke. The most recent rotated file is therefore read along with the live one, gzip, xz and bzip2 included, and the first fact names the files it read. A rotator told to compress with something else, or to move its output to another directory, is out of reach; an event older than one rotation is too.
* **A start is one event even though sshd logs one line per address.** `Server listening on 0.0.0.0 port 22.` and `Server listening on :: port 22.` are written within the same second on every dual-stack host, and the check counts them as the one start they are. A restart moves both the restart and the startup counter, because sshd starts listening again after it re-reads its configuration.
* **Reading a container log costs the timestamps.** The container engines stamp every line themselves and that stamp is stripped while reading, so a line sshd wrote through syslog keeps no time of its own. The counted events then report every line as undated and never reach their thresholds. `docker:`/`podman:`/`kubectl:` is therefore useful here for the named events and the lifecycle counters, not for the rates.
* The check reads a window of the log on every run and reports what that window holds, rather than only what is new. The summary names how many lines that window holds, because everything else is counted within it: right after logrotate the window is a handful of lines, and a run reporting no login at all is then telling the truth about those rather than about the day. It also means an event keeps being reported until it leaves the window or the service is acknowledged (see `--icinga-callback`). The counted events are the exception: their state follows `--lookback` and falls back on its own as the burst ages out.
* Reading the authentication log needs root or sudo. Both `/var/log/secure` and `/var/log/auth.log` are installed mode `0600` and `0640`, owned by root.
* `--server-log` is confined to `/var/log`. The check runs as root via sudo, so it refuses a path that resolves outside that directory, which stops it from being turned into an arbitrary root file read. To read a log stored elsewhere, bind-mount that location under `/var/log`.
* Both `--ignore` and `--match` are matched against the lowercased log line, so write the patterns in lowercase (or use the `(?i)` flag).

**Data Collection:**

* Takes the first of `/var/log/secure` and `/var/log/auth.log` that exists.
* Falls back to `systemd:sshd.service`, or to `systemd:ssh.service` on the distributions that use that name, deciding by which of the two has a unit file below `/etc/systemd/system`, `/usr/lib/systemd/system` or `/lib/systemd/system`.
* Supports reading from a file path, `docker:CONTAINER`, `podman:CONTAINER`, `kubectl:CONTAINER` or `systemd:UNITNAME` via `--server-log`.
* Reads at most the last 30000 lines of the source, the most recent rotated file included, and reports how many lines it actually saw, which files they came from, whether it stopped at that cap, and which stretch of time they cover.
* Reads the `LogLevel` of `/etc/ssh/sshd_config` and the files it includes, taking the first value as sshd does and ignoring what a `Match` block sets, to tell whether sshd is writing what this check counts.
* Recognizes a line as sshd's by the syslog identifier it was written under, which is `sshd`, `sshd-session` or `sshd-auth` - OpenSSH 9.8 split the daemon, and everything about authentication is logged by `sshd-session` since.
* Reads when a line was written from the timestamp its syslog daemon put in front of it, in the traditional format (`Aug 28 19:25:03`) as well as in ISO 8601.
* Lines can be narrowed down with `--match` and filtered out with `--ignore`, both Python regular expressions.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/sshd-logfile> |
| Nagios/Icinga Check Name              | `check_sshd_logfile` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |
| Requirements                          | User with higher permissions |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-sshd-logfile-*.db` (only with `--icinga-callback`) |


## Help

```text
usage: sshd-logfile [-h] [-V]
                    [--aborted-connections-critical ABORTED_CONNECTIONS_CRITICAL]
                    [--aborted-connections-warning ABORTED_CONNECTIONS_WARNING]
                    [--access-denials-critical ACCESS_DENIALS_CRITICAL]
                    [--access-denials-warning ACCESS_DENIALS_WARNING]
                    [--always-ok]
                    [--auth-failures-critical AUTH_FAILURES_CRITICAL]
                    [--auth-failures-warning AUTH_FAILURES_WARNING]
                    [--icinga-callback] [--icinga-password ICINGA_PASSWORD]
                    [--icinga-service-name ICINGA_SERVICE_NAME]
                    [--icinga-url ICINGA_URL]
                    [--icinga-username ICINGA_USERNAME] [--ignore IGNORE]
                    [--insecure]
                    [--invalid-users-critical INVALID_USERS_CRITICAL]
                    [--invalid-users-warning INVALID_USERS_WARNING]
                    [--lookback LOOKBACK] [--match MATCH] [--no-insecure]
                    [--no-match-severity {ok,warn,crit,unknown}]
                    [--no-per-source] [--no-perfdata] [--no-proxy]
                    [--per-source] [--proxy PROXY] [--server-log SERVER_LOG]
                    [--throttled-connections-critical THROTTLED_CONNECTIONS_CRITICAL]
                    [--throttled-connections-warning THROTTLED_CONNECTIONS_WARNING]
                    [--timeout TIMEOUT]

Scans the log of the OpenSSH server for the events an administrator has to act
on: a server that refused to start, a host key it could not load, a key file
it refused because of how it looks on disk, a key somebody revoked and is
still using, a session that died on a signal, and a root login that only
`PermitRootLogin` stopped - which means the credentials for it were valid.
Startups, restarts, shutdowns and successful logins are counted alongside
them, so a server that keeps restarting is visible. Everything a client can
provoke - a password that did not match, a login for an account that does not
exist, a connection that ended before authentication, a connection the server
refused because it was at `MaxStartups` - is counted within `--lookback` and
judged by how many of them arrived, not by the fact that they did: one is a
typo or a bot, hundreds within ten minutes is somebody guessing passwords.
Every host that answers on port 22 collects these all day, so counting them by
rate is what keeps the check from being permanently yellow, and counting them
per source address is what tells one determined client from the open network
going past. sshd writes no severity into its lines, so what is reported is
what this check recognizes; anything else it wrote is read but not counted.
The log is read either from a file, from a systemd unit (`systemd:`) or from a
container (`docker:`/`podman:`/`kubectl:`). Without `--server-log` the check
takes the first of the usual authentication logs of the distributions that
exists, and falls back to the journal of the sshd unit where there is none.
The most recent rotated file is read along with the live one, so the window
does not end where logrotate last ran. Note that sshd logs to its standard
error until it has loaded its host keys, so a rejected configuration, a host
key it could not read and the "no hostkeys available" it exits with never
reach the syslog file. They show up only when the unit is read
(`--server-log=systemd:sshd.service`). Requires root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --aborted-connections-critical ABORTED_CONNECTIONS_CRITICAL
                        Number of connections that ended before authentication
                        within `--lookback` that returns CRITICAL. 0 turns the
                        threshold off. Example: `--aborted-connections-
                        critical=5000`. Default: 2000
  --aborted-connections-warning ABORTED_CONNECTIONS_WARNING
                        Number of connections that ended before authentication
                        within `--lookback` that returns WARNING. Every host
                        answering on the SSH port collects these all day, so
                        this is meant to catch a scan starting and not the
                        background noise. 0 turns the threshold off. Example:
                        `--aborted-connections-warning=500`. Default: 200
  --access-denials-critical ACCESS_DENIALS_CRITICAL
                        Number of accounts turned away by policy within
                        `--lookback` that returns CRITICAL. 0 turns the
                        threshold off. Example: `--access-denials-
                        critical=200`. Default: 60
  --access-denials-warning ACCESS_DENIALS_WARNING
                        Number of accounts turned away by policy within
                        `--lookback` that returns WARNING. Counts the accounts
                        that exist and that `AllowUsers`, `DenyUsers`, the
                        group lists, a missing login shell or a locked
                        password refused. 0 turns the threshold off. Example:
                        `--access-denials-warning=1`. Default: 6
  --always-ok           Always returns OK.
  --auth-failures-critical AUTH_FAILURES_CRITICAL
                        Number of failed authentications for accounts that
                        exist within `--lookback` that returns CRITICAL. 0
                        turns the threshold off. Example: `--auth-failures-
                        critical=200`. Default: 60
  --auth-failures-warning AUTH_FAILURES_WARNING
                        Number of failed authentications for accounts that
                        exist within `--lookback` that returns WARNING.
                        Attempts for accounts that do not exist are counted by
                        `--invalid-users-warning` instead. 0 turns the
                        threshold off. Example: `--auth-failures-warning=5`.
                        Default: 6
  --icinga-callback     Ask the monitoring server whether the service running
                        this check is acknowledged. Where it is, what this run
                        reports is remembered as already handled, so it no
                        longer raises an alert on the following runs. Requires
                        `--icinga-url`, `--icinga-username`, `--icinga-
                        password` and `--icinga-service-name`. Default: False
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
                        Example: `--ignore='invalid user'`.
  --insecure            Applies to the connection to the monitoring server
                        that `--icinga-callback` makes, which is the only
                        network connection this check opens. This option
                        explicitly allows insecure SSL connections.
  --invalid-users-critical INVALID_USERS_CRITICAL
                        Number of logins attempted for accounts that do not
                        exist within `--lookback` that returns CRITICAL. 0
                        turns the threshold off. Example: `--invalid-users-
                        critical=500`. Default: 60
  --invalid-users-warning INVALID_USERS_WARNING
                        Number of logins attempted for accounts that do not
                        exist within `--lookback` that returns WARNING.
                        Counted once per connection, however many passwords it
                        went through. 0 turns the threshold off. Example:
                        `--invalid-users-warning=50`. Default: 6
  --lookback LOOKBACK   Failed authentications, invalid users, access denials,
                        throttled and aborted connections are counted within
                        this window rather than reported one by one. Time
                        window in seconds to look back over, ending at the
                        moment of the run. Only what falls within it is
                        counted, so what is reported is how often something
                        happened lately rather than a total that keeps growing
                        for as long as the source is kept. Example:
                        `--lookback=3600`. Default: 600 (seconds)
  --match MATCH         Only consider a log line matching this Python regular
                        expression. The log line is lowercased before
                        matching, so write the pattern in lowercase (or use
                        the `(?i)` flag). Can be specified multiple times. If
                        both `--match` and `--ignore` are given, an item must
                        match `--match` AND not match `--ignore` to be
                        reported (include first, exclude second). Example:
                        `--match='sshd-session'`.
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
  --no-per-source       Judge a rate by everything that arrived within the
                        window, whatever source the lines name. Use this where
                        the log reaches this check through something that
                        rewrites or drops the address of the peer, or where
                        every source is as interesting as the next.
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --no-proxy            Applies to the connection to the monitoring server
                        that `--icinga-callback` makes, which is the only
                        network connection this check opens. Do not use a
                        proxy, not even one the environment names. Overrides
                        `--proxy`.
  --per-source          Judge a rate by the busiest single source address
                        rather than by everything that arrived. A handful of
                        failures from one address within the window is
                        somebody working on this host; the same number spread
                        over as many addresses is the background of an open
                        network going past, and only the first is worth
                        reporting. Lines that name no source are counted
                        together as one, so a burst of those still reports.
                        Default: True
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
                        `kubectl:CONTAINER` or `systemd:UNITNAME`. If omitted,
                        the check takes the first of the usual authentication
                        logs of the distributions that exists, and falls back
                        to the journal of the sshd unit where there is none.
                        Example: `--server-log=systemd:sshd.service`.
  --throttled-connections-critical THROTTLED_CONNECTIONS_CRITICAL
                        Number of connections refused for being past
                        `MaxStartups` within `--lookback` that returns
                        CRITICAL. 0 turns the threshold off. Example:
                        `--throttled-connections-critical=50`. Default: 10
  --throttled-connections-warning THROTTLED_CONNECTIONS_WARNING
                        Number of connections refused for being past
                        `MaxStartups` within `--lookback` that returns
                        WARNING. These hit whoever connects next, an
                        administrator included, which is why one of them is
                        already worth reporting. 0 turns the threshold off.
                        Example: `--throttled-connections-warning=5`. Default:
                        1
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/sshd-logfile/
```


## Usage Examples

```bash
./sshd-logfile
./sshd-logfile --server-log=/var/log/secure
./sshd-logfile --server-log=systemd:sshd.service
./sshd-logfile --server-log=systemd:ssh.service

# A host reachable from the internet, where the background noise is constant and only a
# real burst is worth a look.
./sshd-logfile --invalid-users-warning=500 --invalid-users-critical=5000

# A jump box only a handful of people use, where a single failed password already says
# something.
./sshd-logfile --auth-failures-warning=1 --lookback=3600

# A host behind an intrusion prevention system, which already answers what the
# aborted connections describe.
./sshd-logfile --aborted-connections-warning=0 --aborted-connections-critical=0

# A host where `DenyUsers root` turns bots away all day and the denials are not news.
./sshd-logfile --access-denials-warning=0

# Only the events sshd logs about itself, with everything a client can provoke silenced.
./sshd-logfile --auth-failures-warning=0 --auth-failures-critical=0 \
    --invalid-users-warning=0 --invalid-users-critical=0 \
    --aborted-connections-warning=0 --aborted-connections-critical=0

# Watch the journal of the unit instead, which also holds a rejected configuration and a
# host key sshd could not read.
./sshd-logfile --server-log=systemd:sshd.service
```

Output of a healthy host:

```text
No failed logins and nothing else worth reporting found. 1 startup detected (last: Aug 28 19:25:03 host sshd[231]: Server listening on 0.0.0.0 port 22.). No restarts detected. 1 shutdown detected (last: Aug 28 19:25:50 host sshd[231]: Received signal 15; terminating.). 1 successful login in the last 10m (last: Aug 28 19:25:05 host sshd-session[236]: Accepted password for alice from 198.51.100.7 port 54876 ssh2). Read 9 lines from `/var/log/secure` (size: 909.0B), covering 2026-08-28 19:25..2026-08-28 19:25 (47s).
```

Output of a host whose sshd could not take its port, and whose users cannot get in with their keys:

```text
Found 3 startup failures [CRITICAL], 1 refused key file [WARNING]. 0 authentication failures in the last 10m (5 in the window read). 0 invalid-user attempts in the last 10m (1 in the window read). 0 access denials in the last 10m (1 in the window read). 6 startups detected (last: Aug 28 19:25:52 host sshd[367]: Server listening on 0.0.0.0 port 22.). 4 restarts detected (last: Aug 28 19:25:48 host sshd[231]: Received SIGHUP; restarting.). 2 shutdowns detected (last: Aug 28 19:25:54 host sshd[367]: Received signal 15; terminating.). 1 successful login in the last 10m (last: Aug 28 19:25:05 host sshd-session[236]: Accepted password for alice from 198.51.100.7 port 54876 ssh2). Read 73 lines from `/var/log/secure` (size: 7.4KiB), covering 2026-08-28 19:25..2026-08-28 19:25 (51s).

Startup failures:
* Aug 28 19:25:53 host sshd[371]: error: Bind to port 22 on 0.0.0.0 failed: Address already in use.
* Aug 28 19:25:53 host sshd[371]: error: Bind to port 22 on :: failed: Address already in use.
* Aug 28 19:25:53 host sshd[371]: fatal: Cannot bind any address.

Refused key files:
* Aug 28 19:25:41 host sshd-session[329]: Authentication refused: bad ownership or modes for file /home/alice/.ssh/authorized_keys

Recommendations:
* sshd could not start or could not take all its addresses; `sshd -t` names a rejected directive, and a port that is already taken names the process holding it in `ss --listening --processes`
* sshd ignored a key file because of its ownership or its mode; the home directory and `.ssh` may not be group- or world-writable, and `chmod 700 ~/.ssh; chmod 600 ~/.ssh/authorized_keys` is what the file itself needs
```

Output of a host somebody is guessing passwords on:

```text
147 authentication failures in the last 10m [WARNING]. 173 invalid-user attempts in the last 10m. No startups detected. No restarts detected. No shutdowns detected. No successful logins in the last 10m. Read the most recent 30K lines from `/var/log/secure` (size: 25.0KiB) + `/var/log/secure-20260828`, covering 2026-08-28 01:33..2026-08-29 07:53 (1D 6h).

Recommendations:
* Authentications are failing in bulk for accounts that exist, which is what a guessing run against known user names looks like; the names and addresses in the log say whether it is that or an automation still using a password that was changed
```


## States

* CRIT if the window holds a start sshd refused to complete: an address it could not bind, a configuration it rejected, a re-exec that failed, or the exit it takes when no host key is left.
* CRIT if the window holds a key that was revoked and is still being offered.
* WARN if the window holds a host key sshd could not load, a key file it refused for its ownership or its mode, a session process that died on a signal, or a root login that only `PermitRootLogin` stopped.
* WARN or CRIT if more failed authentications, invalid users, access denials, throttled connections or aborted connections arrived within `--lookback` than `--auth-failures-warning` / `--auth-failures-critical`, `--invalid-users-warning` / `--invalid-users-critical`, `--access-denials-warning` / `--access-denials-critical`, `--throttled-connections-warning` / `--throttled-connections-critical` and `--aborted-connections-warning` / `--aborted-connections-critical` allow. A single one of any of them except a throttled connection never alerts.
* WARN if the log file is configured but is not an existing regular file.
* UNKNOWN if not a single line in the window was written by sshd. The source is then something else, `SyslogFacility` sends sshd's lines to a file this check is not looking at, or nobody has connected to this host for as long as the window reaches back. Naming the source with `--server-log` settles the first two and is what to do in the third case as well.
* UNKNOWN if the host keeps none of the usual authentication logs and has no sshd unit either, so there is nothing to read without `--server-log`.
* OK if the log file is empty, which is what a log looks like right after logrotate ran.
* OK with `--no-match-severity` at its default when `--match` dropped every line; set it to `warn`, `crit` or `unknown` to have a filter that matches nothing reported instead.
* A `LogLevel` below `INFO` is reported as the first thing in the output and never alerts, because it says what the rest of the output is worth rather than that something is wrong.
* Successful logins are counted within `--lookback` rather than over the whole window, so the number says how much the server is used rather than how far back the lines it read reach. Startups, restarts and shutdowns are counted over the whole window instead: they are rare enough that how many the window holds is the useful answer, and on a quiet host the window reaches back weeks where ten minutes would always read zero. None of the four ever alerts.
* The size of the log file is reported and trended but never alerted on. An unrotated log is the business of `logrotate` and of the [disk-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/disk-usage.md) check.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| sshd_aborted_connections | Number | Number of connections that ended before anybody authenticated, within the lookback window. |
| sshd_access_denials | Number | Number of accounts that exist and that policy turned away, within the lookback window. |
| sshd_auth_failures | Number | Number of failed authentications for accounts that exist, within the lookback window. |
| sshd_child_crashes | Number | Number of session processes that died on a signal. Reported from OpenSSH 9.8 on. |
| sshd_host_key_problems | Number | Number of host keys and host certificates sshd could not use. |
| sshd_invalid_users | Number | Number of connections that named an account which does not exist, within the lookback window. |
| sshd_key_file_refusals | Number | Number of key files sshd ignored for their ownership or their mode. |
| sshd_logfile_size | Bytes | Log file size. |
| sshd_logins | Number | Number of successful logins within the lookback window. |
| sshd_restarts | Number | Number of restarts found in the log. |
| sshd_revoked_keys | Number | Number of revoked keys that were offered. |
| sshd_root_login_refusals | Number | Number of root logins that authenticated and were stopped by `PermitRootLogin`. |
| sshd_shutdowns | Number | Number of shutdowns found in the log. |
| sshd_startup_failures | Number | Number of starts sshd refused to complete. |
| sshd_startups | Number | Number of startups found in the log, restarts included. |
| sshd_throttled_connections | Number | Number of connections refused for being past `MaxStartups`, within the lookback window. |


## Troubleshooting

### The check is green while nobody can log in

The syslog file only holds what a running sshd wrote. A server that never came up wrote its reason to standard error and exited.

1. `systemctl status sshd` (or `ssh`) says whether it is running, and [systemd-unit](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/systemd-unit.md) is what monitors that.
2. `--server-log=systemd:sshd.service` points this check at the journal instead of at the file, where a rejected configuration and a host key sshd could not read are visible.
3. `sshd -t` names the directive sshd refused, without touching the running server.

### The check reports no sshd line although sshd is running

1. `SyslogFacility` in `/etc/ssh/sshd_config` decides where sshd's lines go. Anything other than `AUTH` or `AUTHPRIV` sends them to a file this check does not probe for; name that file with `--server-log`.
2. A host without a syslog daemon keeps no such file at all. Read the journal instead: `--server-log=systemd:sshd.service`.
3. Where sshd is socket-activated with `Accept=yes`, every connection runs as `sshd@...service` and the journal of `sshd.service` holds only the listener. Read the file, or the whole journal through the generic [journald-query](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/journald-query.md) check.

### The check is permanently yellow on an internet-facing host

Look at which counter it names. Everything a client can provoke is counted as a rate, so the thresholds are what to move.

1. `invalid-user attempts` and `aborted connections` are the background noise of the internet. Raise their thresholds, or set both to `0` on a host where an intrusion prevention system or the firewall already answers them.
2. `access denials` on a host with `DenyUsers root` counts every bot that tries root. `--access-denials-warning=0` turns that counter off without touching the others.
3. `authentication failures` is the one worth keeping low. A run of them against accounts that exist is a guessing run against known names, or an automation still using a password that was changed.
4. Widen `--lookback` to judge over a longer stretch, for instance `--lookback=3600`, and raise the thresholds with it.

### The check keeps reporting the same lines

Every run reads a window of the log rather than only what is new, so a line keeps being reported until it leaves the window or logrotate moves it away. That is what makes the startup, restart and login counts meaningful. Acknowledge the service and hand the check `--icinga-callback` together with the credentials of the monitoring server, and the lines it currently reports are remembered as handled and stop raising an alert.

### `throttled connections` although the host is idle

sshd counts every connection that has not authenticated yet against `MaxStartups`, which defaults to `10:30:100`. A backup or a configuration management run that opens many sessions at once reaches that on an otherwise idle host.

1. `sshd -T | grep maxstartups` says what the host actually allows.
2. Raising the limit is the fix where the load is real. Where it is not, the addresses in the log say who is filling it.
3. `ControlMaster` on the client side turns many sessions into one connection and removes the cause rather than the symptom.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
