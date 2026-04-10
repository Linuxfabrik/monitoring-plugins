# Check axenita-stats

## Overview

Monitors the health and performance of an Axenita/Achilles installation by querying four API endpoints: ReadModel state, active user sessions, build information, and maintenance mode status. Alerts if any endpoint returns an error, if the ReadModel initialization is incomplete, or if maintenance mode is active. Axenita Praxissoftware is powered by Axonlab / Axon Lab AG.

**Data Collection:**

* Queries four Axenita/Achilles REST API endpoints:
    * `/api/admin/readmodel/state` - ReadModel initialization state, current step, total steps, and duration
    * `/api/admin/user-info/number-of-current-sessions` - logged-in users and active sessions
    * `/api/build-info` - version and build timestamp
    * `/api/login/maintenance-state-active` - maintenance mode status

**Compatibility:**

* Requires network access to the Axenita/Achilles API (default: `http://localhost:10000/achilles/ar`)


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/axenita-stats> |
| Nagios/Icinga Check Name              | `check_axenita_stats` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
usage: axenita-stats [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                     [--test TEST] [--timeout TIMEOUT] [--url URL]

Monitors the health and performance of an Axenita/Achilles installation by
querying four API endpoints: ReadModel state, active user sessions, build
information, and maintenance mode status. Alerts if any endpoint returns an
error, if the ReadModel initialization is incomplete, or if maintenance mode
is active.

options:
  -h, --help         show this help message and exit
  -V, --version      show program's version number and exit
  --always-ok        Always returns OK.
  --insecure         This option explicitly allows insecure SSL connections.
  --no-proxy         Do not use a proxy.
  --test TEST        For unit tests. Needs "path-to-stdout-file,path-to-
                     stderr-file,expected-retc".
  --timeout TIMEOUT  Network timeout in seconds. Default: 3 (seconds)
  --url URL          Axenita API URL. Default:
                     http://localhost:10000/achilles/ar
```


## Usage Examples

```bash
./axenita-stats --url http://localhost:10000/achilles/ar --timeout 3
```


## States

* OK if all API endpoints return "SUCCESS", the ReadModel state is "DONE", and maintenance mode is inactive.
* WARN if `readmodel['state']` != "SUCCESS".
* WARN if `readmodel['data']['readModelState']` != "DONE".
* WARN if `userinfo['state']` != "SUCCESS".
* WARN if `buildinfo['state']` != "SUCCESS".
* WARN if `maintenance['state']` != "SUCCESS".
* WARN if `maintenance['data']` is not `false` (maintenance mode is active).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| axenita-version | Number | Axenita version as a comparable number, e.g. "14.0.8" becomes "1408". |
| currentActiveSessions | Number | Number of currently active user sessions. |
| currentInitRmStep | Number | Current ReadModel initialization step. |
| loggedInUsers | Number | Number of logged-in users. |
| maintenance | Number | Maintenance mode status (0 = inactive, 1 = active). |
| totalDurationInitRm | Number | Total duration of the ReadModel initialization. |
| totalInitRmSteps | Number | Total number of ReadModel initialization steps. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
