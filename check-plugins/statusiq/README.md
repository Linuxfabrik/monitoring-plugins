# Check statusiq


## Overview

Monitors a [StatusIQ](https://www.site24x7.com/statusiq/) (by Site24x7) status page via its RSS feed. Returns a component-by-component status overview. Alerts when a component is under maintenance, degraded or partially out, and raises a critical state for a service disruption or a major outage.

**Important Notes:**

* Any StatusIQ status page with RSS enabled (e.g. `https://status.trustid.ch`, `https://status.kobv.de`)

**Data Collection:**

* Fetches the RSS feed of the specified StatusIQ status page (appends `/rss` to the URL)
* Parses the XML feed using BeautifulSoup to extract component statuses and publication dates


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/statusiq> |
| Nagios/Icinga Check Name              | `check_statusiq` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| 3rd Party Python modules              | `beautifulsoup4` |


## Help

```text
usage: statusiq [-h] [-V] [--always-ok] [--insecure] [--no-perfdata]
                [--no-proxy] [--proxy PROXY] [--retries RETRIES]
                [--timeout TIMEOUT] [--url URL]

Monitors a StatusIQ (by Site24x7) status page via its RSS feed. Alerts when a
component is under maintenance, degraded or partially out, and raises a
critical state for a service disruption or a major outage.

options:
  -h, --help         show this help message and exit
  -V, --version      show program's version number and exit
  --always-ok        Always returns OK.
  --insecure         This option explicitly allows insecure SSL connections.
  --no-perfdata      Suppress the performance data section from the output.
                     The status message and the exit code are unaffected, so
                     alerting keeps working while trending data is dropped.
  --no-proxy         Do not use a proxy, not even one the environment names.
                     Overrides `--proxy`.
  --proxy PROXY      Proxy to reach the target through. The scheme defaults to
                     `http` when omitted. Overrides the proxy the environment
                     names (`http_proxy`, `https_proxy`, `all_proxy`) together
                     with the exceptions it lists in `no_proxy`, and is itself
                     overridden by `--no-proxy`. Without either parameter the
                     environment applies. Credentials belong into the
                     environment variable rather than here, because a command-
                     line argument is visible to every user on the host.
                     Example: `--proxy=http://proxy.example.com:3128`.
  --retries RETRIES  Number of extra attempts if the status page does not
                     answer with its feed, before the check gives up. Helps
                     against a status page that intermittently returns an
                     error page or an empty response instead. Default: 3
  --timeout TIMEOUT  Network timeout in seconds. Default: 8 (seconds)
  --url URL          StatusIQ status page URL. Default:
                     https://status.trustid.ch

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/statusiq/
```


## Usage Examples

```bash
./statusiq --url=https://status.trustid.ch
```

Output:

```text
Everything is ok @ https://status.trustid.ch

Component Name                    ! Published                 ! State
----------------------------------+---------------------------+-------
AutoIdent - Operational           ! 2025-03-05 08:00:00+01:00 ! [OK]
TrustID API Service - Operational ! 2025-02-24 23:12:10+01:00 ! [OK]
TrustID BO Service - Operational  ! 2025-02-10 13:15:00+01:00 ! [OK]
TrustID IDP Service - Operational ! 2025-02-10 13:15:00+01:00 ! [OK]
TrustID SSE Service - Operational ! 2025-02-10 13:15:00+01:00 ! [OK]
VideoIdent - Operational          ! 2025-03-05 08:00:00+01:00 ! [OK]
```

```bash
./statusiq --url=https://status.kobv.de
```

Output:

```text
Major incidents @ https://status.kobv.de

Component Name                  ! Pub Date                        ! State
--------------------------------+---------------------------------+------------
GVI via SRU - Major Outage      ! Thu, 06 Mar 2025 14:44:59 +0100 ! [CRITICAL]
ALBERT - Operational            ! Wed, 05 Mar 2025 20:54:24 +0100 ! [OK]
B-TU Laubert - Operational      ! Thu, 27 Feb 2025 14:48:15 +0100 ! [OK]
FHP FHPKat+ - Operational       ! Thu, 20 Feb 2025 18:43:16 +0100 ! [OK]
Fernleihe - Operational         ! Thu, 06 Mar 2025 15:46:05 +0100 ! [OK]
K2 Portal - Operational         ! Tue, 04 Mar 2025 11:15:00 +0100 ! [OK]
OPUS Uni Würzburg - Operational ! Tue, 18 Feb 2025 02:49:47 +0100 ! [OK]
Opus Uni Potsdam - Operational  ! Fri, 14 Feb 2025 13:45:45 +0100 ! [OK]
THW WILBERT - Operational       ! Wed, 26 Feb 2025 14:15:32 +0100 ! [OK]
```


## States

* OK if all components are "Operational" or "Informational".
* WARN for "Under Maintenance", "Degraded Performance", or "Partial Outage" messages.
* CRIT for "Major Outage" messages.
* UNKNOWN if the RSS feed returns no data (RSS may be disabled for this page).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| cnt_crit | Number | Number of critical events |
| cnt_warn | Number | Number of warning events |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
