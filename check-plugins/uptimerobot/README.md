# Check uptimerobot

## Overview

Monitors all configured monitors on a given [UptimeRobot](https://uptimerobot.com/) status page. Reports the number of monitors in up, down, and paused states, along with the 24-hour uptime ratio.

**Alerting Logic:**

* OK if all monitors are in "success" state
* WARN if any monitor is in "danger" state (down)
* UNKNOWN for monitors in any other state (e.g. paused)
* `--always-ok` suppresses all alerts and always returns OK

**Data Collection:**

* Fetches the HTML of the UptimeRobot status page to extract the internal API path
* Then fetches the monitor list JSON from the discovered API endpoint
* Reports per-monitor name, type, and state in a table

**Compatibility:**

* Any public UptimeRobot status page (e.g. `https://status.linuxfabrik.io`)


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/uptimerobot> |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
usage: uptimerobot [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                   [--test TEST] [--timeout TIMEOUT] [--url URL]

Monitors all configured UptimeRobot monitors via the UptimeRobot API. Alerts
on any monitor that is in a down or unknown state.

options:
  -h, --help         show this help message and exit
  -V, --version      show program's version number and exit
  --always-ok        Always returns OK.
  --insecure         This option explicitly allows insecure SSL connections.
  --no-proxy         Do not use a proxy.
  --test TEST        For unit tests. Needs "path-to-stdout-file,path-to-
                     stderr-file,expected-retc".
  --timeout TIMEOUT  Network timeout in seconds. Default: 8 (seconds)
  --url URL          UptimeRobot status page URL. Default:
                     https://status.linuxfabrik.io
```


## Usage Examples

```bash
./uptimerobot --url=https://status.linuxfabrik.io
```

Output:

```text
0/0/3 of 3 monitors are down/paused/up, 24h uptime: 99.976%

Name                      ! Type    ! State 
--------------------------+---------+-------
001 cloud.linuxfabrik.io  ! HTTP(s) ! [OK]  
001 office.linuxfabrik.io ! HTTP(s) ! [OK]  
001 ws.linuxfabrik.io     ! HTTP(s) ! [OK]
```


## States

* OK if all monitors are in "success" state.
* WARN if any monitor is in "danger" state.
* UNKNOWN for monitors in any other state.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| cnt_down | Number | Number of monitors in "down" state |
| cnt_paused | Number | Number of monitors in "paused" state |
| cnt_up | Number | Number of monitors in "up" state |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
