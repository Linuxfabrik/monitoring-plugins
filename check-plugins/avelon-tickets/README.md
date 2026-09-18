# Check avelon-tickets

## Overview

Checks the tickets of the Avelon Cloud building management platform, which its devices and data points raise as alarms. Alerts when a ticket is in a status that still needs attention, by default any unclosed alarm, whether acknowledged or not. Requires a license for the Avelon Public API. Supports extended reporting via `--lengthy`.

A ticket moves through these statuses. The check lists every unclosed ticket and rates it by its status:

* `OPEN`: nobody has acknowledged the alarm yet. WARN by default.
* `REOPENED`: the same alarm came back after it had been acknowledged, before the ticket was closed. WARN by default.
* `ACKNOWLEDGED`: a user took the ticket, the problem is still pending. WARN by default.
* `GONE`: the device reports the alarm as gone, nobody has acknowledged it yet. WARN by default.
* `ACKNOWLEDGED_AND_GONE`: acknowledged and gone, but not closed yet. WARN by default.
* `SUPPRESSED`: the alarm was suppressed and nobody was notified. Listed, but OK by default.
* `EVENT`: an informative event rather than an alarm. Listed, but OK by default.
* `CLOSED` and `EVENT_CLOSED`: done. Only listed with `--closed-ticket`, and never alert.

`--warning` and `--critical` replace these defaults with a list of their own.

**Important Notes:**

* The Public API needs a license from Avelon. The client ID and client secret are shown in Avelon under Settings > General > Public API, where the Public API also has to be enabled.
* The check logs in as an Avelon user and only sees the devices that user has been granted access to (the "Device Access" card of each device). Use a dedicated user whose groups have access to every device you want to monitor.
* An unclosed ticket is reported no matter how long ago it was touched last. `--closed-ticket` only adds the tickets closed within the past seven days.
* The check sends one request per device after logging in. With many devices, or a slow connection to the Avelon Cloud, a run may take longer than the short check timeout monitoring systems use by default (often 10 seconds). Give the check more time if it times out.
* Avelon returns at most 500 tickets per device and request. The check says so in its output when it hits that limit.

**Data Collection:**

* Logs in to the Avelon Public API with the client ID and secret and the username and password (OAuth 2.0 password grant), then fetches the list of devices the user may see and the tickets of each device, filtered by `--type` and by status.
* `--match` and `--ignore` filter the tickets by their message (case-sensitive Python regular expressions; use `(?i)` for case-insensitive matching). A ticket hit by `--ignore` is dropped even if it also matches `--match`. A dropped ticket does not change the state of the check.
* `--url` points the check at another Avelon installation than the Avelon Cloud.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/avelon-tickets> |
| Nagios/Icinga Check Name              | `check_avelon_tickets` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | No (`--client-id`, `--client-secret`, `--username` and `--password` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| Requirements                          | License for the Avelon Public API |


## Help

```text
usage: avelon-tickets [-h] [-V] [--always-ok] --client-id CLIENT_ID
                      --client-secret CLIENT_SECRET [--closed-ticket]
                      [-c {ACKNOWLEDGED,ACKNOWLEDGED_AND_GONE,EVENT,GONE,OPEN,REOPENED,SUPPRESSED,none}]
                      [--ignore IGNORE] [--insecure] [--lengthy]
                      [--match MATCH] [--no-proxy] --password PASSWORD
                      [--proxy PROXY] [--timeout TIMEOUT]
                      [--type {ALARM,BUILDING,SYSTEM_MONITOR}] [--url URL]
                      --username USERNAME
                      [-w {ACKNOWLEDGED,ACKNOWLEDGED_AND_GONE,EVENT,GONE,OPEN,REOPENED,SUPPRESSED,none}]

Checks the tickets of the Avelon Cloud building management platform, which its
devices and data points raise as alarms. Alerts when a ticket is in a status
that still needs attention, by default any unclosed alarm, whether
acknowledged or not. Requires a license for the Avelon Public API. Supports
extended reporting via --lengthy.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --client-id CLIENT_ID
                        Client ID of the Avelon Public API. Shown in Avelon
                        under Settings > General > Public API.
  --client-secret CLIENT_SECRET
                        Client secret of the Avelon Public API. Shown in
                        Avelon under Settings > General > Public API.
  --closed-ticket       Also list the tickets that were closed within the past
                        seven days. They never change the state of the check.
  -c, --critical {ACKNOWLEDGED,ACKNOWLEDGED_AND_GONE,EVENT,GONE,OPEN,REOPENED,SUPPRESSED,none}
                        Ticket status that returns CRIT. `none` returns CRIT
                        for no status. Takes precedence over `--warning`. Can
                        be specified multiple times. Example: `--critical=OPEN
                        --critical=REOPENED`. Default: none
  --ignore IGNORE       Any item matching this Python regex will be ignored.
                        Can be specified multiple times. Example:
                        `(?i)linuxfabrik` for a case-insensitive match.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --lengthy             Extended reporting.
  --match MATCH         Filter by this Python regular expression. Case-
                        sensitive by default; use `(?i)` for case-insensitive
                        matching. Can be specified multiple times. If both
                        `--match` and `--ignore` are given, an item must match
                        `--match` AND not match `--ignore` to be reported
                        (include first, exclude second). Examples:
                        `(?i)example` to match "example" regardless of case.
                        `^(?!.*example).*$` to match any string except
                        "example" (negative lookahead).
  --no-proxy            Do not use a proxy, not even one the environment
                        names. Overrides `--proxy`.
  --password PASSWORD   Password.
  --proxy PROXY         Proxy to reach the target through. The scheme defaults
                        to `http` when omitted. Overrides the proxy the
                        environment names (`http_proxy`, `https_proxy`,
                        `all_proxy`) together with the exceptions it lists in
                        `no_proxy`, and is itself overridden by `--no-proxy`.
                        Without either parameter the environment applies.
                        Credentials belong into the environment variable
                        rather than here, because a command-line argument is
                        visible to every user on the host. Example:
                        `--proxy=http://proxy.example.com:3128`.
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --type {ALARM,BUILDING,SYSTEM_MONITOR}
                        Ticket type to check. `ALARM` is raised by a device or
                        a data point, `BUILDING` is a report by a tenant or a
                        user, `SYSTEM_MONITOR` is a system event. Can be
                        specified multiple times. Example: `--type=ALARM
                        --type=SYSTEM_MONITOR`. Default: ALARM
  --url URL             Base URL of the Avelon Cloud. Default:
                        https://avelon.cloud
  --username USERNAME   Username.
  -w, --warning {ACKNOWLEDGED,ACKNOWLEDGED_AND_GONE,EVENT,GONE,OPEN,REOPENED,SUPPRESSED,none}
                        Ticket status that returns WARN. `none` returns WARN
                        for no status. Can be specified multiple times.
                        Example: `--warning=OPEN --warning=REOPENED`. Default:
                        ACKNOWLEDGED, ACKNOWLEDGED_AND_GONE, GONE, OPEN,
                        REOPENED

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/avelon-tickets/
```


## Usage Examples

```bash
./avelon-tickets --client-id=CLIENT_ID --client-secret=linuxfabrik --username=monitoring --password=linuxfabrik --critical=OPEN --critical=REOPENED
```

Output:

```text
5 tickets need attention (1 ACKNOWLEDGED, 1 ACKNOWLEDGED_AND_GONE, 1 GONE, 1 OPEN, 1 REOPENED).

ID       ! Created                         ! Message                              ! Status                         
---------+---------------------------------+--------------------------------------+--------------------------------
20000001 ! 2026-09-01 08:00:00 (2W 3D ago) ! Anlage 1: Pumpe P1 Störung           ! OPEN [CRITICAL]                
20000002 ! 2026-09-01 08:05:00 (2W 3D ago) ! Anlage 1: Pumpe P2 Störung           ! REOPENED [CRITICAL]            
20000003 ! 2026-09-01 09:00:00 (2W 3D ago) ! Anlage 1: Filter verschmutzt         ! ACKNOWLEDGED [WARNING]         
20000004 ! 2026-09-01 10:00:00 (2W 3D ago) ! Anlage 1: Vorlauftemperatur zu tief  ! GONE [WARNING]                 
20000005 ! 2026-09-01 11:00:00 (2W 3D ago) ! Anlage 1: Rücklauftemperatur zu hoch ! ACKNOWLEDGED_AND_GONE [WARNING]
20000006 ! 2026-09-01 12:00:00 (2W 3D ago) ! Anlage 1: Wartungsschalter aktiv     ! SUPPRESSED                     
20000007 ! 2026-09-01 22:00:00 (2W 2D ago) ! Anlage 1: Betriebsart Nacht          ! EVENT
```

With `--lengthy`:

```bash
./avelon-tickets --client-id=CLIENT_ID --client-secret=linuxfabrik --username=monitoring --password=linuxfabrik --lengthy
```

Output:

```text
2 tickets need attention (1 ACKNOWLEDGED, 1 OPEN).

ID       ! Type  ! Created                         ! Modified                        ! Message                                                     ! Status                
---------+-------+---------------------------------+---------------------------------+-------------------------------------------------------------+-----------------------
13927572 ! ALARM ! 2024-06-18 19:46:56 (2Y 3M ago) ! 2024-06-18 19:47:33 (2Y 3M ago) ! Abschaltend: 6102/5/22: Durchfluss Notkühlung FQ201 Störung ! OPEN [WARNING]        
13927573 ! ALARM ! 2024-06-18 19:46:56 (2Y 3M ago) ! 2024-06-19 14:43:35 (2Y 3M ago) ! Störung: 6102/5/0: Anlage Zustand Störung                   ! ACKNOWLEDGED [WARNING]
```


## States

* OK if no listed ticket is in a status given by `--warning` or `--critical`.
* WARN if a ticket is in a status given by `--warning` (default: `ACKNOWLEDGED`, `ACKNOWLEDGED_AND_GONE`, `GONE`, `OPEN`, `REOPENED`).
* CRIT if a ticket is in a status given by `--critical` (default: none). A status given by both counts as CRIT.
* `--warning=none` and `--critical=none` rate no status at all.
* Closed tickets never change the state, even when listed via `--closed-ticket`.
* UNKNOWN if the login is refused, the user sees no devices, Avelon cannot be reached or answers with unexpected data, on an invalid `--match` or `--ignore` pattern, or on invalid command-line arguments.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

There is no perfdata.


## Troubleshooting

### Login refused

`Failed to authenticate. Check the client ID and secret, the username and password, and that the Public API is enabled for the client account.`

Avelon refused the login. Compare the client ID and client secret with the ones shown in Avelon under Settings > General > Public API, check that the Public API is enabled there, and log in to the Avelon web interface once with the username and password the check uses.

### No devices

`Avelon shows this user no devices. Grant one of its user groups access on the "Device Access" card of each device.`

The login worked, but the user may not see any device, so there are no tickets to check. Open each device in Avelon and add one of the user's groups on its "Device Access" card.

### Tickets are missing

A ticket that Avelon shows in its ticket list is missing from the output. Check in this order:

1. The ticket type: by default only alarms are checked. Add `--type=BUILDING` for reports by tenants or users, and `--type=SYSTEM_MONITOR` for system events.
2. The device: the user the check logs in with has to have access to the device the ticket belongs to (see "No devices").
3. The filters: `--match` and `--ignore` drop tickets by their message.
4. The limit: if the output says that Avelon returned its maximum number of tickets for a device, close the tickets that are done, since the check requests the unclosed ones.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch); originally written by Stadt Luzern/Switzerland
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
