# Check fortios-ha-stats


## Overview

Monitors the high-availability cluster status on FortiGate appliances running FortiOS via the REST API. Alerts if the number of HA members differs from the expected count (default: 2). Reports serial number, role, priority, hostname, and synchronization status per member.

**Important Notes:**

* FortiGate appliances running FortiOS with REST API access and HA configured

**Data Collection:**

* Queries the FortiOS REST API endpoint `/api/v2/monitor/system/ha-statistics/select/` to retrieve HA member details
* Aggregates total sessions and traffic across all cluster members
* Emits per-member perfdata for sessions, network usage, traffic bytes, CPU usage, and memory usage
* Authentication uses a single API token (Token-based authentication)


## Fact Sheet

| Fact | Value |
|----|------|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/fortios-ha-stats> |
| Nagios/Icinga Check Name              | `check_fortios_ha_stats` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | No (`--hostname` and `--password` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |


## Help

```text
usage: fortios-ha-stats [-h] [-V] [--always-ok] [--count COUNT] -H HOSTNAME
                        [--insecure] [--no-proxy] --password PASSWORD
                        [--timeout TIMEOUT]

Monitors the high-availability cluster status on FortiGate appliances running
FortiOS via the REST API. Alerts if the number of HA members differs from the
expected count (default: 2). Reports serial number, role, priority, hostname,
and synchronization status per member.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --count COUNT         Expected number of HA cluster members. Alerts if the
                        actual count differs. Default: 2
  -H, --hostname HOSTNAME
                        FortiOS-based appliance address, optionally including
                        port. Example: `--hostname 192.168.1.1:443`.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-proxy            Do not use a proxy.
  --password PASSWORD   FortiOS REST API single-use access token.
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
```


## Usage Examples

```bash
./fortios-ha-stats --hostname fortigate-cluster.linuxfabrik.io --password mypass --count 2
```

Output:

```text
Found 2 HA cluster members, which handled 87458 sessions and 187.0TiB traffic so far.
```


## States

* OK if the number of HA cluster members matches `--count` (default: 2).
* WARN if the number of HA cluster members differs from `--count`.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

Per HA member (prefixed with the member hostname):

| Name | Type | Description |
|----|----|----|
| `<hostname>_cpu_usage` | Percentage | CPU usage of the HA member. |
| `<hostname>_mem_usage` | Percentage | Memory usage of the HA member. |
| `<hostname>_net_usage` | Percentage | Network usage of the HA member. |
| `<hostname>_sessions` | Number | Number of sessions handled by the HA member. |
| `<hostname>_tbyte` | Bytes | Total traffic in bytes handled by the HA member. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
