# Check fortios-memory-usage


## Overview

Monitors memory utilization on FortiGate appliances running FortiOS via the REST API. First checks against the globally configured memory-use-threshold on the appliance, then falls back to command-line thresholds if no global configuration exists. Alerts when memory usage exceeds the configured thresholds.

**Important Notes:**

* FortiGate appliances running FortiOS with REST API access
* The globally configured `memory-use-threshold-green` takes precedence over `--warning`, and `memory-use-threshold-red` takes precedence over `--critical`

**Data Collection:**

* Queries the FortiOS REST API endpoint `/api/v2/monitor/system/resource/usage?resource=mem&interval=1-min` for the current memory usage
* Queries `/api/v2/cmdb/system/global` to read the appliance's globally configured `memory-use-threshold-green` (warning) and `memory-use-threshold-red` (critical); if present, these values override `--warning` and `--critical`
* Authentication uses a single API token (Token-based authentication)


## Fact Sheet

| Fact | Value |
|----|------|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/fortios-memory-usage> |
| Nagios/Icinga Check Name              | `check_fortios_memory_usage` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | No (`--hostname` and `--password` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |


## Help

```text
usage: fortios-memory-usage [-h] [-V] [--always-ok] [-c CRIT] -H HOSTNAME
                            [--insecure] [--no-proxy] --password PASSWORD
                            [--timeout TIMEOUT] [-w WARN]

Monitors memory utilization on FortiGate appliances running FortiOS via the
REST API. First checks against the globally configured memory-use-threshold on
the appliance, then falls back to command-line thresholds if no global
configuration exists. Alerts when memory usage exceeds the configured
thresholds.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRIT   CRIT threshold for memory usage in percent. The plugin
                        first checks against the globally configured `memory-
                        use-threshold-red` on the appliance; this value is
                        only used if no global threshold exists. Default: 88
  -H, --hostname HOSTNAME
                        FortiOS-based appliance address, optionally including
                        port. Example: `--hostname 192.168.1.1:443`.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-proxy            Do not use a proxy.
  --password PASSWORD   FortiOS REST API single-use access token.
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -w, --warning WARN    WARN threshold for memory usage in percent. The plugin
                        first checks against the globally configured `memory-
                        use-threshold-green` on the appliance; this value is
                        only used if no global threshold exists. Default: 82
```


## Usage Examples

```bash
./fortios-memory-usage --hostname fortigate-cluster.linuxfabrik.io --password mypass --warning=50 --critical=70
```

Output:

```text
1%
```


## States

* OK if memory usage is below the warning threshold.
* WARN if memory usage exceeds the warning threshold (appliance's `memory-use-threshold-green` or `--warning`, default: 82%).
* CRIT if memory usage exceeds the critical threshold (appliance's `memory-use-threshold-red` or `--critical`, default: 88%).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| usage_percent | Percentage | Current memory usage of the FortiGate appliance. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
