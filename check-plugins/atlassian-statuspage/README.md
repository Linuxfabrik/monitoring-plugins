# Check atlassian-statuspage

## Overview

Receive alerts on incidents on a specific [Atlassian Statuspage](https://www.atlassian.com/software/statuspage). The plugin requires access to the <span class="title-ref">/api/v2/status.json</span> endpoint.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/atlassian-statuspage> |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
usage: atlassian-statuspage [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                            [--test TEST] [--timeout TIMEOUT] [--url URL]

Receive alerts on incidents on a specific Atlassian Statuspage.

options:
  -h, --help         show this help message and exit
  -V, --version      show program's version number and exit
  --always-ok        Always returns OK.
  --insecure         This option explicitly allows to perform "insecure" SSL
                     connections. Default: False
  --no-proxy         Do not use a proxy. Default: False
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

See <https://support.atlassian.com/statuspage/docs/top-level-status-and-incident-impact-calculations/>:

* WARN if statuspage reports \['minor', 'maintenance'\]
* CRIT if statuspage reports \['major', 'critical'\]


## Perfdata / Metrics

| Name   | Type   | Description                                                  |
|--------|--------|--------------------------------------------------------------|
| impact | Number | The current state (0 = OK, 1 = WARN, 2 = CRIT, 3 = UNKNOWN). |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
