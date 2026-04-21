# Check atlassian-statuspage


## Overview

Monitors a public Atlassian Statuspage for incidents, degraded services, and scheduled maintenance windows. Reports the overall status indicator, the name and latest update of each unresolved incident, the status of each affected service, and any ongoing or upcoming maintenance. Returns OK when no incidents are reported, WARN for minor incidents, degraded or partially unavailable services and maintenance windows, and CRIT for major/critical incidents or major service outages. Works with any Statuspage-powered status page, not just Atlassian's own.

**Important Notes:**

* Works with any public status page powered by Atlassian Statuspage (e.g. `www.bexio-status.com`, `www.githubstatus.com`, `www.cloudflarestatus.com`, `status.hashicorp.com`, `status.asana.com`).
* "Service" in this plugin's output corresponds to the Atlassian Statuspage "component" concept. The name was chosen for consistency with the statuspal plugin, which the admin is expected to use side by side.

**Data Collection:**

* Queries the `/api/v2/summary.json` endpoint of the specified Statuspage URL, which in a single request returns page metadata, the top-level status indicator, all services with their current status, all unresolved incidents with their latest update, and all scheduled maintenance windows.
* Maps the Statuspage incident indicator to Nagios states according to the [Atlassian impact calculation](https://support.atlassian.com/statuspage/docs/top-level-status-and-incident-impact-calculations/).
* Surfaces the per-service status (`degraded_performance`, `partial_outage`, `major_outage`, `under_maintenance`) so the admin sees which specific service is affected.
* Prepends a single-line notice when a maintenance window is currently in progress.


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
                            [--service SERVICE] [--test TEST]
                            [--timeout TIMEOUT] [--url URL]

Monitors a public Atlassian Statuspage for incidents, degraded services, and
scheduled maintenance windows. Reports the overall status indicator, the name
and latest update of each unresolved incident, the status of each affected
service, and any ongoing or upcoming maintenance. Returns OK when no incidents
are reported, WARN for minor incidents, degraded or partially unavailable
services and maintenance windows, and CRIT for major/critical incidents or
major service outages. Works with any Statuspage-powered status page, not just
Atlassian's own.

options:
  -h, --help         show this help message and exit
  -V, --version      show program's version number and exit
  --always-ok        Always returns OK.
  --insecure         This option explicitly allows insecure SSL connections.
  --no-proxy         Do not use a proxy.
  --service SERVICE  Regex matching the "name" field of a service. Only
                     incidents affecting a matching service, matching degraded
                     services, and maintenance windows affecting a matching
                     service are reported. Can be specified multiple times
                     (logical OR). If not specified, all services are
                     considered. Examples: --service "^API$" --service "^bexio
                     " --service "PostFinance"
  --test TEST        For unit tests. Needs "path-to-stdout-file,path-to-
                     stderr-file,expected-retc".
  --timeout TIMEOUT  Network timeout in seconds. Default: 8 (seconds)
  --url URL          Atlassian Statuspage URL. Default:
                     https://status.atlassian.com
```


## Usage Examples

Everything fine:

```bash
./atlassian-statuspage --url=https://www.githubstatus.com
```

Output:

```text
All systems operational @ GitHub (https://www.githubstatus.com, TZ Etc/UTC)
```

Incident affecting specific services:

```bash
./atlassian-statuspage --url=https://www.bexio-status.com
```

Output:

```text
Minor incidents @ bexio AG (https://www.bexio-status.com, TZ Europe/Zurich): BCV interface currently unavailable / We are currently investigating this issue. (2026-04-21 10:58:27) (see https://stspg.io/2kxj9lf26m7f)

Service                                                        ! Status         ! Updated (Europe/Zurich) ! State    
---------------------------------------------------------------+----------------+-------------------------+----------
bLink / https://status.blink.six-group.com/#/service-providers ! partial_outage ! 2026-04-21 10:58:27     ! [WARNING]
Banking / Fetch transactions                                   ! partial_outage ! 2026-04-21 10:58:27     ! [WARNING]
```

Restrict to one or more services via regex (only alerts when a matching service is affected):

```bash
./atlassian-statuspage --url=https://www.bexio-status.com --service='^bexio ' --service='PostFinance'
```


## States

* OK if the Statuspage top-level indicator is `none` and no affected services or ongoing maintenance windows match the optional `--service` filter.
* WARN if the Statuspage top-level indicator is `minor` or `maintenance`, if any service is in `degraded_performance`, `partial_outage`, or `under_maintenance`, or if at least one maintenance window is currently in progress.
* CRIT if the Statuspage top-level indicator is `major` or `critical`, or if any service is in `major_outage`.
* The state is derived from the top-level indicator and the effective per-service status, not from a single incident's self-declared `impact` field. An incident with `major` impact whose affected services are only in `partial_outage` is WARN, not CRIT — the admin only escalates when a service actually degrades to `major_outage`.
* When `--service` is set, the top-level indicator is ignored and the state is derived purely from the services (and maintenance windows touching them) whose name matches at least one of the supplied regexes.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| cnt_crit | Number | The number of services mapped to a CRIT state (`major_outage`), after the `--service` filter. |
| cnt_warn | Number | The number of services mapped to a WARN state (`degraded_performance`, `partial_outage`, `under_maintenance`), after the `--service` filter. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
