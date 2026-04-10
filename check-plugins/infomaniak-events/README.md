# Check infomaniak-events


## Overview

Monitors the Infomaniak status page for open events and incidents. Alerts when active events are reported.

**Important Notes:**

* Works with the Infomaniak API v2
* The API call may take more than 10 seconds. The default timeout is 28 seconds.
* Known service categories that can be filtered with `--service`:

    * administration_console
    * certificate
    * cloud
    * drive
    * email_hosting
    * hosting
    * housing
    * jelastic
    * public_cloud
    * radio
    * swiss_backup
    * web_hosting
    * webmail

* Links:

    * API Documentation: <https://developer.infomaniak.com/docs/api/get/2/events>
    * API Tokens: <https://manager.infomaniak.com/v3/$ACCOUNT_ID/ng/accounts/token>
    * Infomaniak Status Page: <https://infomaniakstatus.com/>


**Data Collection:**

* Queries the Infomaniak API for current events
* Requires a Bearer Token with scope "event" from Infomaniak
* Displays event type, title, services, start/end time, and duration in a table

**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|------|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/infomaniak-events> |
| Nagios/Icinga Check Name              | `check_infomaniak_events` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | No (`--token` is required) |
| Compiled for Windows                  | No |


## Help

```text
usage: infomaniak-events [-h] [-V] [--always-ok] [--ignore-regex IGNORE_REGEX]
                         [--insecure] [--no-proxy] [--service SERVICE]
                         [--timeout TIMEOUT] --token TOKEN [--test TEST]

Monitors the Infomaniak status page for open events and incidents. Alerts when
active events are reported.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --ignore-regex IGNORE_REGEX
                        Any English event title matching this Python regex
                        will be ignored. Can be specified multiple times.
                        Example: `--ignore-regex "(?i)linuxfabrik"`.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-proxy            Do not use a proxy.
  --service SERVICE     Only report events for this service category. Can be
                        specified multiple times. If not specified, all
                        categories are reported. Example: `--service
                        swiss_backup --service public_cloud`.
  --timeout TIMEOUT     Network timeout in seconds. Default: 28 (seconds)
  --token TOKEN         Infomaniak API token.
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
```


## Usage Examples

```bash
./infomaniak-events --token=TOKEN --service=public_cloud --service=swiss_backup --ignore-regex='(?i)acronis'
```

Output:

```text
information: Wave of fraudulent e-mails () - see https://infomaniakstatus.com/en/

Type        ! Title                            ! Services     ! Start               ! End                             ! Duration 
------------+----------------------------------+--------------+---------------------+---------------------------------+----------
impacting   ! Public Cloud: service disruption ! public_cloud ! 2023-05-10 19:30:15 ! 2023-05-10 20:12:02 (1M 3W ago) ! 41m 47s  
```


## States

* OK if all events are in state "terminated".
* WARN if an active event is reported (type is not "critical").
* CRIT if an active event of type "critical" is reported.
* UNKNOWN on invalid `--ignore-regex` patterns or invalid command-line arguments.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| event | Number | 0 = no active event, 1 = at least one active event in progress. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
