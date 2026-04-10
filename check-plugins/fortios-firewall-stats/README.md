# Check fortios-firewall-stats

## Overview

Summarizes traffic statistics for all IPv4 and IPv6 firewall policies from Forti Appliances like FortiGate running FortiOS, using the FortiOS REST API. The authentication is done via a single API token (Token-based authentication), not via Session-based authentication, which is stated as "legacy".


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/fortios-firewall-stats> |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | No |
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


## Perfdata / Metrics

For example:

* `total_active_sessions`
* `total_asic_bytes`
* `total_bytes`
* `total_hit_count`
* `total_nturbo_bytes`
* `total_session_count`
* `total_software_bytes`


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
