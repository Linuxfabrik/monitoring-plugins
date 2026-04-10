# Check journald-query


## Overview

Queries the systemd journal using journalctl and alerts when matching entries are found. Supports all journalctl filtering options such as `--unit`, `--priority`, `--facility`, `--identifier`, and `--grep`. Useful for monitoring specific log patterns in real time. Requires root or sudo.

**Important Notes:**

* If the initial execution takes more than 10 seconds, the journal is probably too large. Check with [journald-usage](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/journald-usage) and consider vacuuming the journal first.
* Default priority range is `emerg..err`. Default lookback window is 8 hours (`--since=-8h`).
* To monitor a specific application service, call this check separately with `--unit=httpd` (for example).

**Data Collection:**

* Executes `journalctl` with the configured filters and parses the JSON output
* If no `--unit` or `--user-unit` is specified, the check looks for errors in a predefined set of basic system services commonly found after a fresh installation (RHEL 7+, Ubuntu 16+, Debian 9+). Application services like httpd are not included by default.
* If more than 10 events are found, the output table is truncated to show the 5 newest and 5 oldest messages
* Messages longer than 80 characters are truncated in the output table
* The full journalctl command used is always appended to the output for reference

**Compatibility:**

* Linux


## Fact Sheet

| Fact | Value |
|----|------|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/journald-query> |
| Nagios/Icinga Check Name              | `check_journald_query` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Requirements                          | `journalctl` |


## Help

```text
usage: journald-query [-h] [-V] [--always-ok] [--facility FACILITY]
                      [--identifier IDENTIFIER]
                      [--ignore-pattern IGNORE_PATTERN]
                      [--ignore-regex IGNORE_REGEX] [--priority PRIORITY]
                      [--severity {warn,crit}] [--since SINCE] [--test TEST]
                      [--unit UNIT] [--user-unit USER_UNIT]

Queries the systemd journal using journalctl and alerts when matching entries
are found. Supports all journalctl filtering options such as --unit,
--priority, --facility, --identifier, and --grep. Useful for monitoring
specific log patterns in real time. Requires root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --facility FACILITY   Filter output by syslog facility (passed to
                        journalctl). Takes a comma-separated list of numbers
                        or facility names. Default: None
  --identifier IDENTIFIER
                        Show messages for the specified syslog identifier
                        (passed to journalctl). Default: None
  --ignore-pattern IGNORE_PATTERN
                        Any line containing this case-sensitive string in the
                        MESSAGE field will be ignored. Can be specified
                        multiple times. Unlike journalctl, this allows easy
                        string-based filtering.
  --ignore-regex IGNORE_REGEX
                        Any line matching this Python regex on the MESSAGE
                        field will be ignored. Can be specified multiple
                        times. Example: `--ignore-regex='(?i)linuxfabrik'`.
  --priority PRIORITY   Filter output by message priorities or priority ranges
                        (passed to journalctl). Default: emerg..err
  --severity {warn,crit}
                        Severity for alerts when journalctl returns results.
                        Default: warn
  --since SINCE         Show entries on or newer than the specified date
                        (passed to journalctl). Default: -8h
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  --unit UNIT           Show messages for the specified systemd unit
                        UNIT|PATTERN (passed to journalctl). Can be specified
                        multiple times. Default: None
  --user-unit USER_UNIT
                        Show messages for the specified user session unit
                        (passed to journalctl). Can be specified multiple
                        times. Default: None
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


## States

* OK if journalctl returns no matching entries (after applying all filters).
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
