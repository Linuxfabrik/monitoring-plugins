# Check githubstatus

## Overview

Monitors the GitHub status page for service disruptions. Reports the overall status indicator, individual component states, and any unresolved incidents. Alerts on active incidents or degraded components.

**Alerting Logic:**

* WARN if there are any unresolved incidents
* WARN if any GitHub component is not in "operational" state
* WARN if the overall status indicator is not "none" (when no individual components or incidents are reported)

**Data Collection:**

* Queries the public GitHub status API at `https://www.githubstatus.com/api/v2/summary.json`
* Reports a table listing each component with its current status and last update timestamp

**Compatibility:**

* Cross-platform: any system with outbound HTTPS access to `www.githubstatus.com`


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/githubstatus> |
| Nagios/Icinga Check Name              | `check_githubstatus` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
usage: githubstatus [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                    [--test TEST] [--timeout TIMEOUT]

Monitors the GitHub status page for service disruptions. Reports the overall
status indicator, individual component states, and any unresolved incidents.
Alerts on active incidents or degraded components.

options:
  -h, --help         show this help message and exit
  -V, --version      show program's version number and exit
  --always-ok        Always returns OK.
  --insecure         This option explicitly allows insecure SSL connections.
  --no-proxy         Do not use a proxy.
  --test TEST        For unit tests. Needs "path-to-stdout-file,path-to-
                     stderr-file,expected-retc".
  --timeout TIMEOUT  Network timeout in seconds. Default: 8 (seconds)
```


## Usage Examples

```bash
./githubstatus
```

Output:

```text
Everything is ok.

Component      ! Status      ! Updated (Etc/UTC)
---------------+-------------+---------------------
Git Operations ! operational ! 2023-05-11 14:40:16
API Requests   ! operational ! 2023-05-11 14:40:15
Webhooks       ! operational ! 2023-05-11 14:40:18
Issues         ! operational ! 2023-05-11 14:40:17
Pull Requests  ! operational ! 2023-05-11 14:33:31
Actions        ! operational ! 2023-05-11 14:40:14
Packages       ! operational ! 2023-04-27 09:56:19
Pages          ! operational ! 2023-05-11 14:46:14
Codespaces     ! operational ! 2023-05-11 14:40:16
Copilot        ! operational ! 2023-05-04 16:18:39
```

Output (with incident):

```text
1 incindent, 1 component affected. 2023-05-11 17:53:35, minor impact, investigating: Incident with Actions, API Requests, Codespaces, Git Operations, Issues, Pages, Pull Requests and Webhooks.

Component      ! Status         ! Updated (Etc/UTC)
---------------+----------------+---------------------
Pull Requests  ! partial_outage ! 2023-05-11 13:33:31
Actions        ! operational    ! 2023-05-11 14:40:14
```


## States

* OK if no incidents are reported and all components are "operational".
* WARN if there are any unresolved incidents.
* WARN if any component is not "operational".
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| components | Number | Number of GitHub components currently affected (not "operational"). |
| incidents | Number | Number of unresolved incidents. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
