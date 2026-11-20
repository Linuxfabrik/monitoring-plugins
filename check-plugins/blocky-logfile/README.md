# Check blocky-logfile

## Overview

Scans the log of the blocky DNS proxy and ad-blocker for the events an administrator has to act on: a start that failed, deprecated configuration options, list sources that could not be downloaded at their last attempt, and queries the upstream resolvers did not answer. Startups, shutdowns and the times blocking was disabled are counted alongside them. Alerts when one of those events shows up, when failed queries and other errors about single requests cross the rates the thresholds set within `--lookback`, and when a line arrives at a level `--critical-level` or `--warning-level` covers. Request errors are judged by how many of them arrived, not by the fact that they did, because a client asking for a broken domain produces them on every DNS server. Lines about the current blocky process count; what a process before the last startup wrote is history, because a restart reads the configuration and the lists again. A list source counts as failed only while its last download failed, so a source that is back clears the alert on its own. The log is read from the journal of the blocky unit by default, or from a file (`/var/log` only) or a container (`docker:`/`podman:`/`kubectl:`) named with `--server-log`. Reads the text and the JSON log format. Requires root or sudo.

**Important Notes:**

* The query log (`queryLog.type` empty or `console`, the default) writes one line per query into the journal. On a busy resolver the 30000 lines this check reads then cover only about an hour, so a list that fails at every refresh (every 4 hours by default) alerts for an hour and is quiet in between. Set `queryLog.type: none`, or write the query log to a file or a database. This also keeps client addresses and queried names out of the journal.
* A failed start alerts only while no start followed it. Use [systemd-unit](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/systemd-unit/) to know whether blocky runs.
* The download attempts blocky logs before `cannot open source` are not counted by their level.
* The test query blocky sends every upstream at startup counts as an upstream failure. It fails on every boot where the network comes up after blocky.
* `WARN` lines do not alert by default, because blocky also warns about the content of third-party lists. `--warning-level=WARN` changes that.
* With `log.target: syslog`, blocky writes no level into the line.
* `--server-log` is confined to `/var/log`, because the check runs as root.
* `--ignore` and `--match` are matched against the lowercased line.

**Data Collection:**

* Reads the journal of `blocky.service` (current boot, last 30000 lines) if systemd runs the host and the unit file exists, otherwise what `--server-log` names.
* Joins messages that span several lines.
* Reads the text format, with or without `log.timestamp`, and the JSON format.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/blocky-logfile> |
| Nagios/Icinga Check Name              | `check_blocky_logfile` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |
| Requirements                          | User with higher permissions |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-blocky-logfile-*.db` (only with `--icinga-callback`) |


## Help

```text
usage: blocky-logfile [-h] [-V] [--always-ok]
                      [--critical-level {PANIC,FATAL,ERROR,WARN,none}]
                      [--icinga-callback] [--icinga-password ICINGA_PASSWORD]
                      [--icinga-service-name ICINGA_SERVICE_NAME]
                      [--icinga-url ICINGA_URL]
                      [--icinga-username ICINGA_USERNAME] [--ignore IGNORE]
                      [--insecure] [--lookback LOOKBACK] [--match MATCH]
                      [--no-insecure]
                      [--no-match-severity {ok,warn,crit,unknown}]
                      [--no-perfdata] [--no-proxy] [--proxy PROXY]
                      [--request-errors-critical REQUEST_ERRORS_CRITICAL]
                      [--request-errors-warning REQUEST_ERRORS_WARNING]
                      [--server-log SERVER_LOG] [--timeout TIMEOUT]
                      [--upstream-failures-critical UPSTREAM_FAILURES_CRITICAL]
                      [--upstream-failures-warning UPSTREAM_FAILURES_WARNING]
                      [--warning-level {PANIC,FATAL,ERROR,WARN,none}]

Scans the log of the blocky DNS proxy and ad-blocker for the events an
administrator has to act on: a start that failed, deprecated configuration
options, list sources that could not be downloaded at their last attempt, and
queries the upstream resolvers did not answer. Startups, shutdowns and the
times blocking was disabled are counted alongside them. Alerts when one of
those events shows up, when failed queries and other errors about single
requests cross the rates the thresholds set within `--lookback`, and when a
line arrives at a level `--critical-level` or `--warning-level` covers.
Request errors are judged by how many of them arrived, not by the fact that
they did, because a client asking for a broken domain produces them on every
DNS server. Lines about the current blocky process count; what a process
before the last startup wrote is history, because a restart reads the
configuration and the lists again. A list source counts as failed only while
its last download failed, so a source that is back clears the alert on its
own. The log is read from the journal of the blocky unit by default, or from a
file (`/var/log` only) or a container (`docker:`/`podman:`/`kubectl:`) named
with `--server-log`. Reads the text and the JSON log format. Requires root or
sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --critical-level {PANIC,FATAL,ERROR,WARN,none}
                        Least severe blocky log level that returns CRITICAL.
                        Each level includes everything more severe than
                        itself, so `ERROR` covers `FATAL` and `PANIC` as well.
                        Case-sensitive. `none` lets no level return CRITICAL,
                        which leaves the events this check names as the only
                        way to reach it. Example: `--critical-level=ERROR`.
                        Default: FATAL
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
  --insecure            Applies to the connection to the monitoring server
                        that `--icinga-callback` makes, which is the only
                        network connection this check opens. This option
                        explicitly allows insecure SSL connections.
  --lookback LOOKBACK   Failed queries and other request errors are counted
                        within this window rather than reported one by one.
                        Time window in seconds to look back over, ending at
                        the moment of the run. Only what falls within it is
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
                        `--match='list_cache'`
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
  --request-errors-critical REQUEST_ERRORS_CRITICAL
                        Number of request errors other than failed queries
                        within `--lookback` that returns CRITICAL. 0 turns the
                        threshold off. Example: `--request-errors-
                        critical=100`. Default: 500
  --request-errors-warning REQUEST_ERRORS_WARNING
                        Number of request errors other than failed queries
                        within `--lookback` that returns WARNING. 0 turns the
                        threshold off. Example: `--request-errors-warning=50`.
                        Default: 10
  --server-log SERVER_LOG
                        Log source to read from. Accepts a file path,
                        `docker:CONTAINER`, `podman:CONTAINER`,
                        `kubectl:CONTAINER` or `systemd:UNITNAME`. Can be
                        specified multiple times, and everything named is then
                        read as one window; a source named twice is read once.
                        If omitted, the check reads the journal of
                        `blocky.service`. Example: `--server-
                        log=podman:blocky`
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --upstream-failures-critical UPSTREAM_FAILURES_CRITICAL
                        Number of queries no upstream resolver answered within
                        `--lookback` that returns CRITICAL. 0 turns the
                        threshold off. Example: `--upstream-failures-
                        critical=100`. Default: 500
  --upstream-failures-warning UPSTREAM_FAILURES_WARNING
                        Number of queries no upstream resolver answered within
                        `--lookback` that returns WARNING. 0 turns the
                        threshold off. Example: `--upstream-failures-
                        warning=50`. Default: 10
  --warning-level {PANIC,FATAL,ERROR,WARN,none}
                        Least severe blocky log level that returns WARNING.
                        Each level includes everything more severe than
                        itself, and a level that `--critical-level` already
                        covers returns CRITICAL instead. Case-sensitive.
                        `none` lets no level return WARNING, which leaves the
                        events this check names as the only way to reach it.
                        Example: `--warning-level=WARN`. Default: ERROR

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/blocky-logfile/
```


## Usage Examples

```bash
./blocky-logfile
```

```text
2026-11-20 16:33 .. 2026-11-20 16:34 (13s): No errors or warnings found. 1 startup detected (last: 2026-11-20 16:33:48). blocky v0.36.0.

Read 85 lines from 1 source:
* `systemd:blocky.service`
```

A production resolver whose list source was discontinued:

```text
2026-11-19 20:34 .. 2026-11-20 16:32 (19h 57m): Found 1 failing list source [WARNING].

Failing list sources:
* 1x https://urlhaus.abuse.ch/downloads/hostfile/: got status code 410 (last: 2026-11-20 15:50:48)

Recommendations:
* List sources could not be downloaded at their last attempt, so their entries are missing or stale; an HTTP 404 or 410 means the list was moved or discontinued, remove or replace it in `blocking.denylists` / `blocking.allowlists`

Read 30K lines from 1 source:
* `systemd:blocky.service`
```

A configuration that blocky could not read:

```text
2026-11-20 16:24 .. 2026-11-20 16:25 (1m 32s): Found 1 failed start [CRITICAL]. 2 startups detected (last: 2026-11-20 16:25:03). 2 shutdowns detected (last: 2026-11-20 16:25:39). blocky v0.36.0.

Failed starts:
* 1x Error: unable to load configuration: failed to unmarshal config from /etc/blocky/config.yml: wrong file structure: yaml: line 1: did not find expected node content (last: 2026-11-20 16:25:39)

Recommendations:
* blocky did not start, so this host answers no DNS queries; the line above says why, check `/etc/blocky/config.yml` with `blocky validate --config=/etc/blocky/config.yml`

Read 206 lines from 1 source:
* `systemd:blocky.service`
```

```bash
# A quiet resolver, where a handful of failed queries within ten minutes is
# already unusual.
./blocky-logfile --upstream-failures-warning=3

# Container deployment.
./blocky-logfile --server-log=podman:blocky
```


## States

* OK if no event, no line at the levels `--critical-level` and `--warning-level` cover and no rate above its threshold is found.
* WARN if the current process logged a deprecated configuration option.
* WARN if the last download of a list source failed.
* WARN or CRIT if the number of upstream failures within `--lookback` reaches `--upstream-failures-warning` (default: 10) or `--upstream-failures-critical` (default: 500).
* WARN or CRIT if the number of other request errors within `--lookback` reaches `--request-errors-warning` (default: 10) or `--request-errors-critical` (default: 500).
* WARN if the current process logged a line at `--warning-level` (default: `ERROR`) or worse, CRIT at `--critical-level` (default: `FATAL`) or worse.
* CRIT if the last start attempt failed.
* WARN if one of several sources could not be read.
* UNKNOWN if no `blocky.service` unit is found and no `--server-log` is given, if the source cannot be read, if no line carries a blocky log level, and on invalid command-line arguments.
* `--no-match-severity` sets the state when `--match` drops every line (default: `ok`).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| blocky_blocking_disables | Number | Number of times blocking was disabled, for all or some groups. |
| blocky_deprecated_options | Number | Number of deprecated configuration options the current process reported. |
| blocky_error_lines | Number | Number of `ERROR` lines of the current process, not counting the events and request errors. |
| blocky_fatal_lines | Number | Number of `FATAL` lines of the current process. |
| blocky_list_failures | Number | Number of list sources whose last download failed. |
| blocky_logfile_size | Bytes | Log file size, for a file source only. |
| blocky_panic_lines | Number | Number of `PANIC` lines of the current process. |
| blocky_request_errors | Number | Number of request lines at `WARN` or above other than upstream failures, within the lookback window. |
| blocky_shutdowns | Number | Number of shutdowns found in the log. |
| blocky_startup_failures | Number | Number of failed start attempts after the last startup. |
| blocky_startups | Number | Number of startups found in the log. |
| blocky_upstream_failures | Number | Number of queries no upstream answered, and of failed startup test queries, within the lookback window. |
| blocky_warn_lines | Number | Number of `WARN` lines of the current process, not counting the events and request errors. |


## Troubleshooting

### No blocky unit found

``Found no `blocky.service` unit``

blocky runs under another unit name, in a container, or without systemd. Name the source: `--server-log=systemd:my-blocky.service`, `--server-log=podman:blocky` or a file below `/var/log`.

### Not allowed to read the journal

``Not allowed to read `systemd:blocky.service` ``

Run the check with sudo (see `assets/sudoers`), or add the monitoring user to the `systemd-journal` group.

### `does not look like the log of blocky`

The source holds something else. Check `--server-log`. A blocky with `log.target: syslog` writes no level into its lines; switch it back to `stdout`.

### A list source keeps failing

Download the URL by hand from the blocky host: `curl --head <url>`. An HTTP 404 or 410 means the list moved or was discontinued; remove or replace it in `/etc/blocky/config.yml` and restart blocky. A name resolution error means blocky cannot resolve the host of the list: set `bootstrapDns` or check `/etc/resolv.conf`.

### Many upstream failures

1. Check that each upstream in `upstreams.groups` answers, for example `dig @192.0.2.53 example.com`.
2. Check `upstreams.timeout`; the default of 2 seconds is short for DNS-over-TLS or DNS-over-HTTPS upstreams far away.
3. After a reboot, the failed startup test queries mean blocky started before the network was up. Add `After=network-online.target` and `Wants=network-online.target` to the unit.

### The window covers only an hour

See the first of the Important Notes: set `queryLog.type: none`, or write the query log to a file or a database.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
