# Check fortios-firewall-stats

## Overview

Summarizes traffic statistics for all IPv4 and IPv6 firewall policies on FortiGate appliances running FortiOS via the REST API. Reports byte and packet counters, active sessions, and hit counts per policy.

**Important Notes:**

* FortiGate appliances running FortiOS with REST API access
* This is a reporting-only check. It does not apply thresholds and always returns OK unless both API requests fail (UNKNOWN).


**Data Collection:**

* Queries the FortiOS REST API endpoints `/api/v2/monitor/firewall/policy/select/` (IPv4) and `/api/v2/monitor/firewall/policy6/select/` (IPv6)
* If one of the two requests fails (e.g. IPv6 not configured), the check continues with the successful result
* Aggregates byte counters, session counts, and hit counts across all policies
* Authentication uses a single API token (Token-based authentication)

**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|------|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/fortios-firewall-stats> |
| Nagios/Icinga Check Name              | `check_fortios_firewall_stats` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | No (`--hostname` and `--password` are required) |
| Compiled for Windows                  | No |


## Help

```text
usage: fortios-firewall-stats [-h] [-V] [--always-ok] -H HOSTNAME [--insecure]
                              [--no-proxy] --password PASSWORD
                              [--timeout TIMEOUT]

Summarizes traffic statistics for all IPv4 and IPv6 firewall policies on
FortiGate appliances running FortiOS via the REST API. Reports byte and packet
counters, active sessions, and hit counts per policy.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
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
./fortios-firewall-stats --hostname fortigate-cluster.linuxfabrik.io --password mypass
```

Output:

```text
2 policies, 0 sessions (0 active), 21 hits, 1.8KiB bytes (1.8KiB software, 0.0B asic, 0.0B nturbo)
```


## States

* Always returns OK.
* UNKNOWN if both IPv4 and IPv6 API requests fail.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| total_active_sessions | Number | Total number of active sessions across all policies. |
| total_asic_bytes | Bytes | Total bytes processed by ASIC offloading across all policies. |
| total_bytes | Bytes | Total bytes processed across all policies. |
| total_hit_count | Number | Total policy hit count across all policies. |
| total_nturbo_bytes | Bytes | Total bytes processed by NTurbo across all policies. |
| total_session_count | Number | Total session count across all policies. |
| total_software_bytes | Bytes | Total bytes processed in software across all policies. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
