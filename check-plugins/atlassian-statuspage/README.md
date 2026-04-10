# Check atlassian-statuspage


## Overview

Monitors a public Atlassian Statuspage for incidents and maintenance windows. Returns OK when no incidents are reported, WARN for minor incidents or scheduled maintenance, and CRIT for major or critical incidents. Works with any Statuspage-powered status page, not just Atlassian's own.

**Important Notes:**

* Works with any public status page powered by Atlassian Statuspage (e.g. GitHub, Cloudflare, Datadog)

**Data Collection:**

* Queries the `/api/v2/status.json` endpoint of the specified Statuspage URL
* Maps the Statuspage incident indicator to Nagios states according to the [Atlassian impact calculation](https://support.atlassian.com/statuspage/docs/top-level-status-and-incident-impact-calculations/)
* Reports the time elapsed since the last status update when an incident is active


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/atlassian-statuspage> |
| Nagios/Icinga Check Name              | `check_atlassian_statuspage` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |


## Help

```text
usage: atlassian-statuspage [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                            [--test TEST] [--timeout TIMEOUT] [--url URL]

Monitors a public Atlassian Statuspage for incidents and maintenance windows.
Returns OK when no incidents are reported, WARN for minor incidents or
scheduled maintenance, and CRIT for major or critical incidents. Works with
any Statuspage-powered status page, not just Atlassian's own.

options:
  -h, --help         show this help message and exit
  -V, --version      show program's version number and exit
  --always-ok        Always returns OK.
  --insecure         This option explicitly allows insecure SSL connections.
  --no-proxy         Do not use a proxy.
  --test TEST        For unit tests. Needs "path-to-stdout-file,path-to-
                     stderr-file,expected-retc".
  --timeout TIMEOUT  Network timeout in seconds. Default: 8 (seconds)
  --url URL          Atlassian Statuspage URL. Default:
                     https://status.atlassian.com
```


## Usage Examples

```bash
./atlassian-statuspage --url=https://www.githubstatus.com
```

Output:

```text
Minor Service Outage @ https://www.githubstatus.com, last update at 2025-05-28T12:41:26 Etc/UTC (23m 11s ago)
```


## States

* OK if the Statuspage indicator is "none" (no active incidents).
* WARN if the Statuspage indicator is "minor" or "maintenance".
* CRIT if the Statuspage indicator is "major" or "critical".
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| impact | Number | The current state (0 = OK, 1 = WARN, 2 = CRIT, 3 = UNKNOWN). |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
