# Check statusiq

## Overview

Monitors a [StatusIQ](https://www.site24x7.com/statusiq/) (by Site24x7) status page via its RSS feed. Returns a component-by-component status overview with Nagios-compatible alerting.

**Data Collection:**

* Fetches the RSS feed of the specified StatusIQ status page (appends `/rss` to the URL)
* Parses the XML feed using BeautifulSoup to extract component statuses and publication dates

**Compatibility:**

* Cross-platform

**Important Notes:**

* Any StatusIQ status page with RSS enabled (e.g. `https://status.trustid.ch`, `https://status.kobv.de`)



## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/statusiq> |
| Nagios/Icinga Check Name              | `check_statusiq` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `beautifulsoup4` |


## Help

```text
usage: statusiq [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                [--test TEST] [--timeout TIMEOUT] [--url URL]

Monitors a StatusIQ (by Site24x7) status page via its RSS feed. Returns OK for
operational or informational messages, WARN for maintenance windows, and CRIT
for service disruptions or degraded performance.

options:
  -h, --help         show this help message and exit
  -V, --version      show program's version number and exit
  --always-ok        Always returns OK.
  --insecure         This option explicitly allows insecure SSL connections.
  --no-proxy         Do not use a proxy.
  --test TEST        For unit tests. Needs "path-to-stdout-file,path-to-
                     stderr-file,expected-retc".
  --timeout TIMEOUT  Network timeout in seconds. Default: 8 (seconds)
  --url URL          StatusIQ status page URL. Default:
                     https://status.trustid.ch
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
