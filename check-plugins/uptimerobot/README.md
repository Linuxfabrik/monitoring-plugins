# Check uptimerobot


## Overview

Monitors all configured monitors on a given [UptimeRobot](https://uptimerobot.com/) status page. Reports the number of monitors in up, down, and paused states, along with the 24-hour uptime ratio.

**Data Collection:**

* Fetches the HTML of the UptimeRobot status page to extract the internal API path
* Then fetches the monitor list JSON from the discovered API endpoint
* Reports per-monitor name, type, and state in a table


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/uptimerobot> |
| Nagios/Icinga Check Name              | `check_uptimerobot` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |


## Help

```text
usage: uptimerobot [-h] [-V] [--always-ok] [--insecure] [--no-perfdata]
                   [--no-proxy] [--proxy PROXY] [--timeout TIMEOUT]
                   [--url URL]

Monitors all configured UptimeRobot monitors via the UptimeRobot API. Alerts
on any monitor that is in a down or unknown state.

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
  --timeout TIMEOUT  Network timeout in seconds. Default: 8 (seconds)
  --url URL          UptimeRobot status page URL. Default:
                     https://status.uptimerobot.com

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/uptimerobot/
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
