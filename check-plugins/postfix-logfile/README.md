# Check postfix-logfile


## Overview

Scans the Postfix mail log for the events an administrator has to act on, on both sides of the server. Outbound: mail that could not be delivered, a relay host that cannot be reached, credentials it will not take, a TLS handshake that fails, and a mail system that refused to start. Inbound: what a client provoked - a login it got wrong, a recipient the server refused, a conversation that ended in the middle. Alerts when one of those events shows up, when the lines one client provokes cross the rates the thresholds set, and when a line arrives at a level `--critical-level` or `--warning-level` covers. The inbound lines are counted within `--lookback` and judged by how many of them arrived, per source address: one is a bot or a typo, dozens within ten minutes is somebody working on this host. Every server that answers on port 25 collects these all day, so counting them by rate is what keeps the check from being permanently yellow. Deliveries that were deferred or bounced are counted the same way, because a single one is a mailbox that is full and a burst of them is the relay being down. What is left is counted by the word Postfix puts in front of the message: `panic` and `fatal` return CRITICAL, `error` and `warning` return WARNING, which `--critical-level` and `--warning-level` move. The events named above carry their own state and are counted there and nowhere else. The log is read either from a file, from a systemd unit (`systemd:`) or from a container (`docker:`/`podman:`/`kubectl:`). `--server-log` may be given several times, and everything named is then read as one window. Without it the check takes `maillog_file` from the Postfix configuration where it is set, falls back to the mail log of the distribution, and reads the journal of the Postfix unit along with it; what both hold is counted once. The most recent rotated file is read along with the live one, so the window does not end where logrotate last ran. Requires root or sudo.

**Important Notes:**

* **Postfix is two servers in one log, and this check reports on both.** A host that only sends its own mail - which is what `inet_interfaces = 127.0.0.1` makes it - fails outbound: the relay refuses the connection, the credentials or the TLS handshake, and every message waits in the queue. A host that answers the internet fails inbound: somebody works through a mailbox, a bot walks the recipients. The first kind is reported one event at a time because every one of them stops mail; the second is counted by rate, because a server on port 25 collects it all day.
* **One failed connection to the relay is not an outage.** A host without an IPv6 route logs `connect to relay[2001:db8::1]:587: Network is unreachable` for the AAAA record of its relay and delivers over IPv4 in the same second, and every message it sends produces the pair again - measured on a production host: 35 of them over four days, every message delivered. Connections to the next hop and TLS handshakes are therefore counted within `--lookback` rather than reported one by one; a relay that is really down produces them by the dozen within one queue run, and the deferrals behind it say the same thing from the other side.
* **A line is counted once.** The line naming a cause (`connect to relay[198.51.100.9]:587: Connection refused`) is a named event; the delivery lines behind it (`status=deferred`) are counted by rate. Neither doubles the other, and what a catalog claimed is not counted by its level as well.
* **The rate thresholds assume an intrusion prevention system in front of this check.** A server reachable from the internet collects failed logins and rejected recipients around the clock. The defaults report what gets past the blocking: five failures from one source within ten minutes is what such a system commonly allows, six is the first number above it. Without one, raise `--auth-failures-warning`, `--rejects-warning` and `--aborted-connections-warning`; a busy MX wants them in the hundreds.
* **A rate is counted per source address, not as a total.** Six failed logins from one address within the window is somebody working on this host; six from six addresses is the internet going past. `--no-per-source` goes back to the total. A delivery of ours names the host we handed the message to rather than a peer, so deferrals and bounces are always judged by the total.
* **A deferral is not a bounce.** A deferred message is still in the queue and will be tried again; a bounced one was given up on and is gone. On a host that only sends its own mail, every bounce is a message nobody will read, which is why both are counted separately.
* **The queue itself is not what this check reads.** How much mail is waiting is what [mailq](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mailq.md) answers. This check reads why it is waiting.
* **A mail system that never started is invisible in the mail log, which is why the journal is read too.** `postfix start` writes what it refuses to its standard error, and under systemd that lands in the journal. The check therefore reads the file and the unit by default and counts once what it finds in both.
* **The mail log holds more than Postfix.** A Dovecot, an OpenDKIM, an amavisd and a spam filter all write to the same syslog facility. A line another program wrote is recognized by its syslog identifier and left out of every count.
* **A start is one event even though Postfix logs two lines.** `postfix-script: starting the Postfix mail system` and `master: daemon started -- version 3.5.25` are one start, and the second of the pair is collapsed rather than counted.
* **The window spans the last rotation.** logrotate moves the old file aside (`maillog-20260828` on the RHEL family, `mail.log.1` on the Debian family, then `.gz`) and the syslog daemon opens a fresh one. The most recent rotated file is therefore read along with the live one, gzip, xz and bzip2 included, and the last section names every file it read.
* **Postfix can write its own log file.** From Postfix 3.4 on, `maillog_file` takes the lines away from syslog and puts them where it names. The check reads that setting and follows it.
* The check reads a window of the log on every run and reports what that window holds, rather than only what is new. It also means an event keeps being reported until it leaves the window or the service is acknowledged (see `--icinga-callback`). The counted events are the exception: their state follows `--lookback` and falls back on its own as the burst ages out.
* Reading the mail log needs root or sudo. The RHEL family installs `/var/log/maillog` mode `0600`, owned by root.
* `--server-log` is confined to `/var/log`. The check runs as root via sudo, so it refuses a path that resolves outside that directory, which stops it from being turned into an arbitrary root file read. This also applies to the path `maillog_file` names. To read a log stored elsewhere, bind-mount that location under `/var/log`.
* Both `--ignore` and `--match` are matched against the lowercased log line, so write the patterns in lowercase (or use the `(?i)` flag).

**Data Collection:**

* Takes `maillog_file` from `/etc/postfix/main.cf` where it is set, and otherwise the first of `/var/log/maillog` and `/var/log/mail.log` that exists.
* Reads the journal of `postfix.service` or `postfix@-.service` along with the file where `--server-log` names nothing, deciding by which of them has a unit file below `/etc/systemd/system`, `/usr/lib/systemd/system` or `/lib/systemd/system`, and counts an event the two share once.
* Supports reading from a file path, `docker:CONTAINER`, `podman:CONTAINER`, `kubectl:CONTAINER` or `systemd:UNITNAME` via `--server-log`, which can be given several times; everything named is read as one window. A wildcard is not expanded, so name each file.
* Reads at most the last 30000 lines of each source, the most recent rotated file included, and reports how many lines it saw, which files they came from, whether it stopped at that cap, and which stretch of time they cover.
* Recognizes a line as Postfix's by the syslog identifier it was written under, which is `postfix` plus the daemon that wrote it (`postfix/smtpd`, `postfix/qmgr`) and, on a host running several instances, the instance name as well (`postfix-incoming/smtpd`).
* Reads when a line was written from the timestamp its syslog daemon put in front of it, in the traditional format (`Aug 29 09:12:03`) as well as in ISO 8601.
* Lines can be narrowed down with `--match` and filtered out with `--ignore`, both Python regular expressions.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/postfix-logfile> |
| Nagios/Icinga Check Name              | `check_postfix_logfile` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |
| Requirements                          | User with higher permissions |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-postfix-logfile-*.db` (only with `--icinga-callback`) |


## Help

```text
usage: postfix-logfile [-h] [-V]
                       [--aborted-connections-critical ABORTED_CONNECTIONS_CRITICAL]
                       [--aborted-connections-warning ABORTED_CONNECTIONS_WARNING]
                       [--always-ok]
                       [--auth-failures-critical AUTH_FAILURES_CRITICAL]
                       [--auth-failures-warning AUTH_FAILURES_WARNING]
                       [--bounced-critical BOUNCED_CRITICAL]
                       [--bounced-warning BOUNCED_WARNING]
                       [--critical-level {panic,fatal,error,warning,none}]
                       [--deferred-critical DEFERRED_CRITICAL]
                       [--deferred-warning DEFERRED_WARNING]
                       [--icinga-callback] [--icinga-password ICINGA_PASSWORD]
                       [--icinga-service-name ICINGA_SERVICE_NAME]
                       [--icinga-url ICINGA_URL]
                       [--icinga-username ICINGA_USERNAME] [--ignore IGNORE]
                       [--insecure] [--lookback LOOKBACK] [--match MATCH]
                       [--no-insecure]
                       [--no-match-severity {ok,warn,crit,unknown}]
                       [--no-per-source] [--no-perfdata] [--no-proxy]
                       [--per-source] [--proxy PROXY]
                       [--rejects-critical REJECTS_CRITICAL]
                       [--rejects-warning REJECTS_WARNING]
                       [--relay-failures-critical RELAY_FAILURES_CRITICAL]
                       [--relay-failures-warning RELAY_FAILURES_WARNING]
                       [--server-log SERVER_LOG] [--timeout TIMEOUT]
                       [--tls-failures-critical TLS_FAILURES_CRITICAL]
                       [--tls-failures-warning TLS_FAILURES_WARNING]
                       [--warning-level {panic,fatal,error,warning,none}]

Scans the Postfix mail log for the events an administrator has to act on, on
both sides of the server. Outbound: mail that could not be delivered, a relay
host that cannot be reached, credentials it will not take, a TLS handshake
that fails, and a mail system that refused to start. Inbound: what a client
provoked - a login it got wrong, a recipient the server refused, a
conversation that ended in the middle. Alerts when one of those events shows
up, when the lines one client provokes cross the rates the thresholds set, and
when a line arrives at a level `--critical-level` or `--warning-level` covers.
The inbound lines are counted within `--lookback` and judged by how many of
them arrived, per source address: one is a bot or a typo, dozens within ten
minutes is somebody working on this host. Every server that answers on port 25
collects these all day, so counting them by rate is what keeps the check from
being permanently yellow. Deliveries that were deferred or bounced are counted
the same way, because a single one is a mailbox that is full and a burst of
them is the relay being down. What is left is counted by the word Postfix puts
in front of the message: `panic` and `fatal` return CRITICAL, `error` and
`warning` return WARNING, which `--critical-level` and `--warning-level` move.
The events named above carry their own state and are counted there and nowhere
else. The log is read either from a file, from a systemd unit (`systemd:`) or
from a container (`docker:`/`podman:`/`kubectl:`). `--server-log` may be given
several times, and everything named is then read as one window. Without it the
check takes `maillog_file` from the Postfix configuration where it is set,
falls back to the mail log of the distribution, and reads the journal of the
Postfix unit along with it; what both hold is counted once. The most recent
rotated file is read along with the live one, so the window does not end where
logrotate last ran. Requires root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --aborted-connections-critical ABORTED_CONNECTIONS_CRITICAL
                        Number of conversations that ended before a message
                        was handed over within `--lookback` that returns
                        CRITICAL. 0 turns the threshold off. Example:
                        `--aborted-connections-critical=5000`. Default: 2000
  --aborted-connections-warning ABORTED_CONNECTIONS_WARNING
                        Number of conversations that ended before a message
                        was handed over within `--lookback` that returns
                        WARNING. Every server answering on port 25 collects
                        these all day, so this is meant to catch a scan
                        starting and not the background noise. 0 turns the
                        threshold off. Example: `--aborted-connections-
                        warning=500`. Default: 200
  --always-ok           Always returns OK.
  --auth-failures-critical AUTH_FAILURES_CRITICAL
                        Number of failed SMTP logins within `--lookback` that
                        returns CRITICAL. 0 turns the threshold off. Example:
                        `--auth-failures-critical=200`. Default: 60
  --auth-failures-warning AUTH_FAILURES_WARNING
                        Number of failed SMTP logins within `--lookback` that
                        returns WARNING. Counted per source address, so a run
                        against one mailbox from one host reaches it while the
                        same number of typos across a fleet does not. 0 turns
                        the threshold off. Example: `--auth-failures-
                        warning=5`. Default: 6
  --bounced-critical BOUNCED_CRITICAL
                        Number of deliveries given up on within `--lookback`
                        that returns CRITICAL. 0 turns the threshold off.
                        Example: `--bounced-critical=500`. Default: 200
  --bounced-warning BOUNCED_WARNING
                        Number of deliveries given up on within `--lookback`
                        that returns WARNING. On a host that only sends its
                        own mail, every one of them is a message nobody will
                        read; a server receiving from the internet bounces all
                        day and wants this raised. 0 turns the threshold off.
                        Example: `--bounced-warning=1`. Default: 20
  --critical-level {panic,fatal,error,warning,none}
                        Level from which a line returns CRITICAL, the levels
                        above it included. `none` turns the level counts off
                        and leaves the named events. Example: `--critical-
                        level=error`. Default: fatal
  --deferred-critical DEFERRED_CRITICAL
                        Number of deliveries put back into the queue within
                        `--lookback` that returns CRITICAL. 0 turns the
                        threshold off. Example: `--deferred-critical=500`.
                        Default: 200
  --deferred-warning DEFERRED_WARNING
                        Number of deliveries put back into the queue within
                        `--lookback` that returns WARNING. A single one is a
                        mailbox that is full; a burst of them is the next hop
                        being down. 0 turns the threshold off. Example:
                        `--deferred-warning=5`. Default: 20
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
                        Example: `--ignore='status=bounced'`.
  --insecure            Applies to the connection to the monitoring server
                        that `--icinga-callback` makes, which is the only
                        network connection this check opens. This option
                        explicitly allows insecure SSL connections.
  --lookback LOOKBACK   Failed logins, rejected messages, aborted connections,
                        deferred and bounced deliveries are counted within
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
                        `--match='postfix/smtpd'`.
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
  --rejects-critical REJECTS_CRITICAL
                        Number of messages the server turned away within
                        `--lookback` that returns CRITICAL. 0 turns the
                        threshold off. Example: `--rejects-critical=200`.
                        Default: 60
  --rejects-warning REJECTS_WARNING
                        Number of messages the server turned away within
                        `--lookback` that returns WARNING. Counted per source
                        address. A server that answers the internet turns mail
                        away all day and wants this raised. 0 turns the
                        threshold off. Example: `--rejects-warning=50`.
                        Default: 6
  --relay-failures-critical RELAY_FAILURES_CRITICAL
                        Number of failed connections to the next hop within
                        `--lookback` that returns CRITICAL. 0 turns the
                        threshold off. Example: `--relay-failures-
                        critical=500`. Default: 200
  --relay-failures-warning RELAY_FAILURES_WARNING
                        Number of failed connections to the next hop within
                        `--lookback` that returns WARNING. A host without an
                        IPv6 route logs one for the AAAA record of its relay
                        and delivers over IPv4 in the same second, so a single
                        one is not a failure; a relay that is really down
                        produces them by the dozen. 0 turns the threshold off.
                        Example: `--relay-failures-warning=5`. Default: 20
  --server-log SERVER_LOG
                        Log source to read from. Accepts a file path,
                        `docker:CONTAINER`, `podman:CONTAINER`,
                        `kubectl:CONTAINER` or `systemd:UNITNAME`. Can be
                        specified multiple times, and everything named is then
                        read as one window; a source named twice is read once.
                        If omitted, the check takes `maillog_file` from the
                        Postfix configuration where it is set, falls back to
                        the mail log of the distribution, and reads the
                        journal of the Postfix unit along with it; what the
                        two share is counted once. Example: `--server-
                        log=systemd:postfix.service`.
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --tls-failures-critical TLS_FAILURES_CRITICAL
                        Number of TLS connections that did not come off within
                        `--lookback` that returns CRITICAL. 0 turns the
                        threshold off. Example: `--tls-failures-critical=500`.
                        Default: 200
  --tls-failures-warning TLS_FAILURES_WARNING
                        Number of TLS connections that did not come off within
                        `--lookback` that returns WARNING. A single one is one
                        remote server having a bad day; a server that answers
                        the internet collects those all day. 0 turns the
                        threshold off. Example: `--tls-failures-warning=5`.
                        Default: 20
  --warning-level {panic,fatal,error,warning,none}
                        Level from which a line returns WARNING, up to the
                        level `--critical-level` names. `none` turns the level
                        counts off and leaves the named events. Example:
                        `--warning-level=error`. Default: warning

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/postfix-logfile/
```


## Usage Examples

```bash
./postfix-logfile
./postfix-logfile --server-log=/var/log/maillog
./postfix-logfile --server-log=systemd:postfix.service

# A host that only relays its own mail out, where a single message that did not get
# through is worth knowing about.
./postfix-logfile --deferred-warning=1 --bounced-warning=1

# A host that does have an IPv6 route, where a connection to the relay that fails is
# never the address family being tried in vain.
./postfix-logfile --relay-failures-warning=1

# A server that answers the internet, where mail is turned away and logins are guessed
# around the clock and only a real burst is worth a look.
./postfix-logfile --rejects-warning=500 --auth-failures-warning=50

# Judge over an hour instead of ten minutes.
./postfix-logfile --lookback=3600

# Silence the deferrals of one relay that is known to be flaky, and keep everything else.
./postfix-logfile --ignore='relay.example.com'

# Read the log of a container.
./postfix-logfile --server-log=podman:postfix
```

Output of a host that only sends its own mail, with somebody working through a mailbox on it:

```text
2026-08-29 09:00 .. 2026-08-29 09:15 (14m 59s): 0 failed logins in the last 10m (6 in the window read). 0 rejected messages in the last 10m (2 in the window read). 0 aborted connections in the last 10m (5 in the window read). 1 startup detected (last: Aug 29 09:00:01 mail postfix/postfix-script[1101]: starting the Postfix mail system). 0 deliveries in the last 10m (1 in the window read) (last: Aug 29 09:15:00 mail postfix/smtp[2220]: 3F2A14804001: to=<user@example.org>, relay=mail.example.org[198.51.100.20]:25, delay=0.4, delays=0.1/0/0.2/0.1, dsn=2.0.0, status=sent (250 2.0.0 Ok: queued)).

Read 20 lines from 1 source:
* `/var/log/maillog` (size: 2.5KiB)|'postfix_logfile_size'=2568B;;;0 'postfix_panic_lines'=0;;0;0 'postfix_fatal_lines'=0;;0;0 'postfix_error_lines'=0;0;;0 'postfix_warning_lines'=0;0;;0 'postfix_startup_failures'=0;;0;0 'postfix_relay_auth_failures'=0;0;;0 'postfix_queue_problems'=0;;0;0 'postfix_auth_failures'=0;6;60;0 'postfix_rejects'=0;6;60;0 'postfix_aborted_connections'=0;200;2000;0 'postfix_relay_failures'=0;20;200;0 'postfix_tls_failures'=0;20;200;0 'postfix_deferred'=0;20;200;0 'postfix_bounced'=0;20;200;0 'postfix_startups'=1;;;0 'postfix_reloads'=0;;;0 'postfix_shutdowns'=0;;;0 'postfix_deliveries'=0;;;0
```

Output of a host whose relay is unreachable, refuses the credentials and speaks no TLS, and whose mail system then failed to start:

```text
2026-08-29 17:17 .. 2026-08-29 17:19 (1m 55s): Found 2 startup failures [CRITICAL], 1 refused credential [WARNING]. 0 rejected messages in the last 10m (1 in the window read). 0 aborted connections in the last 10m (9 in the window read). 0 unreachable next hops in the last 10m (3 in the window read). 0 TLS failures in the last 10m (3 in the window read). 0 deferred deliveries in the last 10m (3 in the window read). 0 bounced deliveries in the last 10m (1 in the window read). 3 startups detected (last: Aug 29 17:18:20 mail postfix/postfix-script[1182]: starting the Postfix mail system). 5 reloads detected (last: Aug 29 17:19:46 mail postfix/postfix-script[1323]: refreshing the Postfix mail system). 2 shutdowns detected (last: Aug 29 17:18:15 mail postfix/master[1093]: terminating on signal 15). 0 deliveries in the last 10m (2 in the window read) (last: Aug 29 17:17:57 mail postfix/local[943]: C5E354804356: to=<root@mail.example.com>, relay=local, delay=0, delays=0/0/0/0, dsn=2.0.0, status=sent (delivered to mailbox)).

Startup failures:
* Aug 29 17:18:14 mail postfix[1099]: fatal: chdir(/var/spool/postfix-nonexistent): No such file or directory
* Aug 29 17:18:15 mail postfix[1106]: fatal: chdir(/var/spool/postfix-nonexistent): No such file or directory

Refused credentials:
* Aug 29 17:19:48 mail postfix/smtp[1338]: warning: SASL authentication failure: No worthy mechs found

Read 74 lines from 1 source:
* `/var/log/maillog` (size: 8.2KiB)

Recommendations:
* The mail system did not start; `postfix check` names what it refuses, and nothing leaves this host until it does
* The relay refused the credentials this host offered; check `smtp_sasl_password_maps` and whether the account still exists|'postfix_logfile_size'=8430B;;;0 'postfix_panic_lines'=0;;0;0 'postfix_fatal_lines'=0;;0;0 'postfix_error_lines'=0;0;;0 'postfix_warning_lines'=0;0;;0 'postfix_startup_failures'=2;;0;0 'postfix_relay_auth_failures'=1;0;;0 'postfix_queue_problems'=0;;0;0 'postfix_auth_failures'=0;6;60;0 'postfix_rejects'=0;6;60;0 'postfix_aborted_connections'=0;200;2000;0 'postfix_relay_failures'=0;20;200;0 'postfix_tls_failures'=0;20;200;0 'postfix_deferred'=0;20;200;0 'postfix_bounced'=0;20;200;0 'postfix_startups'=3;;;0 'postfix_reloads'=5;;;0 'postfix_shutdowns'=2;;;0 'postfix_deliveries'=0;;;0
```


## States

* CRIT if a line carries a level of `--critical-level` or above (`panic` and `fatal` by default).
* CRIT if the mail system did not start, or if the queue could not be written.
* WARN if a line carries a level of `--warning-level` or above (`error` and `warning` by default), up to the level `--critical-level` names.
* WARN if the relay refused the credentials this host offered. Unlike a connection that did not come off, this one never fixes itself on the next attempt.
* WARN or CRIT if more failed logins, rejected messages or aborted connections arrived within `--lookback` than `--auth-failures-warning` / `--auth-failures-critical`, `--rejects-warning` / `--rejects-critical` and `--aborted-connections-warning` / `--aborted-connections-critical` allow, counted per source address.
* WARN or CRIT if more connections to the next hop failed or more TLS handshakes did not come off within `--lookback` than `--relay-failures-warning` / `--relay-failures-critical` and `--tls-failures-warning` / `--tls-failures-critical` allow, counted as a total.
* WARN or CRIT if more deliveries were deferred or bounced within `--lookback` than `--deferred-warning` / `--deferred-critical` and `--bounced-warning` / `--bounced-critical` allow, counted as a total.
* WARN if the log file is configured but is not an existing regular file.
* WARN if a log this check was told to read could not be read at all. The run goes on with the other sources rather than reporting the state of the ones that happened to work.
* UNKNOWN if not a single line in the window was written by Postfix. The source is then something else, the log of the application that hands its mail over for example.
* UNKNOWN if no log could be determined at all.
* OK if the log file is empty, which is what a log looks like right after logrotate ran.
* OK with `--no-match-severity` at its default when `--match` dropped every line; set it to `warn`, `crit` or `unknown` to have a filter that matches nothing reported instead.
* The size of the log file is reported and trended but never alerted on. An unrotated log is the business of `logrotate` and of the [disk-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/disk-usage.md) check.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| postfix_aborted_connections | Number | Number of conversations that ended before a message was handed over, within the lookback window. |
| postfix_auth_failures | Number | Number of failed SMTP logins within the lookback window. |
| postfix_bounced | Number | Number of deliveries given up on within the lookback window. |
| postfix_deferred | Number | Number of deliveries put back into the queue within the lookback window. |
| postfix_deliveries | Number | Number of messages delivered within the lookback window. |
| postfix_error_lines | Number | Number of lines Postfix logged at `error`. |
| postfix_fatal_lines | Number | Number of lines Postfix logged at `fatal`. |
| postfix_logfile_size | Bytes | Log file size. |
| postfix_panic_lines | Number | Number of lines Postfix logged at `panic`. |
| postfix_queue_problems | Number | Number of times the queue could not be written. |
| postfix_rejects | Number | Number of messages the server turned away within the lookback window. |
| postfix_relay_auth_failures | Number | Number of times a relay refused the credentials this host offered. |
| postfix_relay_failures | Number | Number of failed connections to the next hop within the lookback window. |
| postfix_reloads | Number | Number of reloads found in the log. |
| postfix_shutdowns | Number | Number of shutdowns found in the log. |
| postfix_startup_failures | Number | Number of starts the mail system refused to complete. |
| postfix_startups | Number | Number of startups found in the log. |
| postfix_tls_failures | Number | Number of TLS connections that did not come off, within the lookback window. |
| postfix_warning_lines | Number | Number of lines Postfix logged at `warning`. |


## Troubleshooting

### `None of the ... lines read from ... was written by Postfix`

Not one line in the window carried a Postfix syslog identifier. The file that gets mixed up with this one most often is the log of an application that hands its mail over, or the mail log of another host. Check `--server-log`, and `postconf maillog_file` to see whether Postfix writes its own file rather than logging through syslog.

### `Found no log to read`

Neither `/var/log/maillog` nor `/var/log/mail.log` exists and this host has no Postfix unit either. On a host where Postfix logs into a container or under a name of its own, name the log with `--server-log`.

### Deferrals that never turn into bounces

A message stays in the queue until `maximal_queue_lifetime` runs out - five days by default - so a relay that is down produces deferrals for days and bounces only afterwards. The deferral count is therefore the earlier signal of the two.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
