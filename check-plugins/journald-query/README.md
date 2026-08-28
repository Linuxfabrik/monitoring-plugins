# Check journald-query


## Overview

Queries the systemd journal using journalctl and alerts when matching entries are found. Supports all journalctl filtering options such as `--unit`, `--priority`, `--facility`, `--identifier`, and `--grep`. Useful for monitoring specific log patterns in real time. Requires root or sudo.

**Important Notes:**

* If the initial execution takes more than 10 seconds, the journal is probably too large. Check with [journald-usage](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/journald-usage) and consider vacuuming the journal first.
* Default priority range is `emerg..err`. Default lookback window is 8 hours (`--since=-8h`).
* To monitor a specific application service, call this check separately with `--unit=httpd` (for example).
* When using `--icinga-callback`, the parameters `--icinga-url`, `--icinga-password`, `--icinga-username`, and `--icinga-service-name` are all required. Create an Icinga API user like so:

```text
object ApiUser "linuxfabrik-check-journald-query" {
  password = "linuxfabrik"
  permissions = [
  {
    permission = "objects/query/service"
  }]
}
```

**Data Collection:**

* Executes `journalctl` with the configured filters and parses the JSON output
* If no `--unit` or `--user-unit` is specified, the check looks for errors in a predefined set of basic system services commonly found after a fresh installation (RHEL 7+, Ubuntu 16+, Debian 9+). Application services like httpd are not included by default.
* If more than 10 events are found, the output table is truncated to show the 5 newest and 5 oldest messages
* Messages longer than 80 characters are truncated in the output table
* The full journalctl command used is always appended to the output for reference
* With `--icinga-callback`: when the service is acknowledged in Icinga, the currently reported journald events are persisted to a SQLite state DB as "already handled". On following runs, these events are filtered out of the journalctl result so they do not re-alert. Each combination of filter arguments (`--priority`, `--since`, `--unit`, `--user-unit`, `--facility`, `--identifier`, `--ignore-pattern`, `--ignore-regex`) gets its own state DB, keyed by a short hash over those arguments. Ack records older than 30 days are auto-pruned.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/journald-query> |
| Nagios/Icinga Check Name              | `check_journald_query` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |
| Requirements                          | `journalctl` |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-journald-query-<hash>.db` (only with `--icinga-callback`; one DB per combination of filter arguments) |


## Help

```text
usage: journald-query [-h] [-V] [--always-ok] [--facility FACILITY]
                      [--icinga-callback] [--icinga-password ICINGA_PASSWORD]
                      [--icinga-service-name ICINGA_SERVICE_NAME]
                      [--icinga-url ICINGA_URL]
                      [--icinga-username ICINGA_USERNAME]
                      [--identifier IDENTIFIER] [--ignore IGNORE]
                      [--match MATCH]
                      [--no-match-severity {ok,warn,crit,unknown}]
                      [--insecure] [--no-insecure] [--no-perfdata]
                      [--no-proxy] [--priority PRIORITY] [--proxy PROXY]
                      [--severity {warn,crit}] [--since SINCE]
                      [--timeout TIMEOUT] [--unit UNIT]
                      [--user-unit USER_UNIT]

Queries the systemd journal using journalctl and alerts when matching entries
are found. Supports all journalctl filtering options such as --unit,
--priority, --facility, --identifier, and --grep. Useful for monitoring
specific log patterns in real time. Optionally integrates with Icinga: when
the service is acknowledged, the matching events are suppressed on following
runs so they don't re-alert. Requires root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --facility FACILITY   Filter output by syslog facility (passed to
                        journalctl). Takes a comma-separated list of numbers
                        or facility names. Default: None
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
  --identifier IDENTIFIER
                        Show messages for the specified syslog identifier
                        (passed to journalctl). Default: None
  --ignore IGNORE       Ignore an event whose MESSAGE field matches this
                        Python regular expression. Case-sensitive by default;
                        use `(?i)` for case-insensitive matching. Can be
                        specified multiple times. Example:
                        `--ignore='(?i)linuxfabrik'`.
  --match MATCH         Only report an event whose MESSAGE field matches this
                        Python regular expression. Case-sensitive by default;
                        use `(?i)` for case-insensitive matching. Can be
                        specified multiple times. If both `--match` and
                        `--ignore` are given, an item must match `--match` AND
                        not match `--ignore` to be reported (include first,
                        exclude second). Example: `--match='(?i)out of
                        memory'`.
  --no-match-severity {ok,warn,crit,unknown}
                        State to report when no item matches the filters and
                        nothing is checked. Default: ok
  --insecure            Applies to the connection to the monitoring server
                        that `--icinga-callback` makes, which is the only
                        network connection this check opens. This option
                        explicitly allows insecure SSL connections.
  --no-insecure         Applies to the connection to the monitoring server
                        that `--icinga-callback` makes, which is the only
                        network connection this check opens. Verify the TLS
                        certificate against the system trust store, overriding
                        the insecure default of this check. Use it once the
                        endpoint presents a publicly trusted certificate, or
                        once its CA has been added to the system trust store.
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --no-proxy            Applies to the connection to the monitoring server
                        that `--icinga-callback` makes, which is the only
                        network connection this check opens. Do not use a
                        proxy, not even one the environment names. Overrides
                        `--proxy`.
  --priority PRIORITY   Filter output by message priorities or priority ranges
                        (passed to journalctl). Default: emerg..err
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
  --severity {warn,crit}
                        Severity for alerts when journalctl returns results.
                        Default: warn
  --since SINCE         Show entries on or newer than the specified date
                        (passed to journalctl). Default: -8h
  --timeout TIMEOUT     Network timeout in seconds. Default: 5 (seconds)
  --unit UNIT           Show messages for the specified systemd unit
                        UNIT|PATTERN (passed to journalctl). Can be specified
                        multiple times. Default: None
  --user-unit USER_UNIT
                        Show messages for the specified user session unit
                        (passed to journalctl). Can be specified multiple
                        times. Default: None

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/journald-query/
```


## Usage Examples

Simple call that checks the most common system services for errors of any kind:

```bash
./journald-query
```

Output:

```text
27 events. Latest event at 2022-07-28 15:08:04 from systemd-resolved, level err: `Failed to send hostname reply: Transport endpoint is not connected` [WARNING]
Attention: Table below is truncated, showing the 5 newest and the 5 oldest messages.

Timestamp           ! Unit             ! Prio ! Message
--------------------+------------------+------+----------------------------------------------------------------------------
2022-07-28 15:08:04 ! systemd-resolved ! err  ! Failed to send hostname reply: Transport endpoint is not connected
2022-07-28 09:27:03 ! dnf-makecache    ! err  ! Failed to start dnf makecache.
2022-07-28 09:10:55 ! session-c1.scope ! err  ! GLib-GObject: g_object_unref: assertion 'G_IS_OBJECT (object)' failed
2022-07-28 09:10:51 ! user@1000        ! err  ! Failed to start Application launched by gnome-session-binary.
2022-07-28 09:10:51 ! user@1000        ! err  ! Failed to start Application launched by gnome-session-binary.
2022-07-27 20:36:52 ! user@1000        ! err  ! Ignoring duplicate name 'org.freedesktop.FileManager1' in service file ...
2022-07-27 20:36:36 ! user@1000        ! err  ! Ignoring duplicate name 'org.freedesktop.FileManager1' in service file ...
2022-07-27 20:36:36 ! user@1000        ! err  ! Ignoring duplicate name 'org.freedesktop.FileManager1' in service file ...
2022-07-27 20:36:34 ! user@1000        ! err  ! Ignoring duplicate name 'org.freedesktop.FileManager1' in service file ...
2022-07-27 20:36:34 ! user@1000        ! err  ! Ignoring duplicate name 'org.freedesktop.FileManager1' in service file ...

Use `journalctl --reverse --priority=emerg..err --since=-8h` as a starting point for debugging.
```

Explicitly search for error messages in the Apache httpd unit only:

```bash
./journald-query --unit=httpd --priority=emerg..err --severity=crit --ignore-regex='mod_qos.*: Access denied, invalid request line'
```

Output:

```text
994 events. Latest event at 2022-07-28 18:00:04 from httpd, level err: `[proxy_fcgi:error] [pid 896:tid 929] [client 127.0.0.1:50256] AH01071: Got error 'Primary script unknown'` [CRITICAL]
Attention: Table below is truncated, showing the 5 newest and the 5 oldest messages.

Timestamp           ! Unit  ! Prio ! Message
--------------------+-------+------+-----------------------------------------------------------------------------------
2022-07-28 18:00:04 ! httpd ! err  ! [proxy_fcgi:error] [pid 896:tid 929] [client 127.0.0.1:50256] AH01071: Got er...
2022-07-28 17:59:55 ! httpd ! err  ! [proxy_fcgi:error] [pid 896:tid 927] [client 127.0.0.1:57732] AH01071: Got er...
2022-07-28 17:59:04 ! httpd ! err  ! [proxy_fcgi:error] [pid 896:tid 945] [client 127.0.0.1:53908] AH01071: Got er...
2022-07-28 17:58:55 ! httpd ! err  ! [proxy_fcgi:error] [pid 896:tid 943] [client 127.0.0.1:56074] AH01071: Got er...
2022-07-28 17:58:04 ! httpd ! err  ! [proxy_fcgi:error] [pid 896:tid 936] [client 127.0.0.1:44684] AH01071: Got er...
2022-07-28 09:45:55 ! httpd ! err  ! [proxy_fcgi:error] [pid 896:tid 947] [client 127.0.0.1:52536] AH01071: Got er...
2022-07-28 09:45:04 ! httpd ! err  ! [proxy_fcgi:error] [pid 896:tid 940] [client 127.0.0.1:53256] AH01071: Got er...
2022-07-28 09:44:55 ! httpd ! err  ! [proxy_fcgi:error] [pid 896:tid 938] [client 127.0.0.1:44544] AH01071: Got er...
2022-07-28 09:44:04 ! httpd ! err  ! [proxy_fcgi:error] [pid 897:tid 904] [client 127.0.0.1:40142] AH01071: Got er...
2022-07-28 09:43:55 ! httpd ! err  ! [proxy_fcgi:error] [pid 896:tid 931] [client 127.0.0.1:34050] AH01071: Got er...
```

Monitor a unit with Icinga acknowledgement support. After the admin acknowledges the service in Icinga, the matching events are persisted as "already handled" and no longer re-alert on following runs:

```bash
./journald-query --unit=auditd --icinga-callback --icinga-url=https://icinga.example.com:5665 --icinga-username=linuxfabrik-check-journald-query --icinga-password=linuxfabrik --icinga-service-name='monitoring-host!journald-auditd'
```

Output when no matching events are found (or once previously reported events have been acknowledged):

```text
Queried the systemd journal (0 events) using priority='emerg..err', since='-8h', units 'auditd'.
```


## States

* OK if journalctl returns no matching entries (after applying all filters).
* OK if all matching entries have already been acknowledged via `--icinga-callback` on a previous run.
* WARN if `--severity=warn` (default) and matching entries are found.
* CRIT if `--severity=crit` and matching entries are found.
* UNKNOWN on journalctl errors or unparseable journal entries.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| journald-query | Number | Number of matching events found in the journal. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
