# Check fortios-cpu-usage

## Overview

Monitors CPU utilization on FortiGate appliances running FortiOS via the REST API. Alerts only if the threshold has been exceeded for a configurable number of consecutive check runs (default: 5), suppressing short spikes. First checks against the globally configured cpu-use-threshold on the appliance, then falls back to command-line thresholds.

**Important Notes:**

* FortiGate appliances running FortiOS with REST API access
* `--count=5` (the default) while checking every minute means the check reports a warning only if the CPU usage exceeds the threshold for 5 consecutive minutes
* The globally configured `cpu-use-threshold` on the appliance takes precedence over the `--warning` command-line value. The `--critical` threshold is always used as-is.


**Data Collection:**

* Queries the FortiOS REST API endpoint `/api/v2/monitor/system/resource/usage?resource=cpu&interval=1-min` for the current CPU usage
* Queries `/api/v2/cmdb/system/global` to read the appliance's globally configured `cpu-use-threshold`; if present, this value overrides `--warning`
* Stores each measurement in a local SQLite database, retaining the last `--count` rows
* Authentication uses a single API token (Token-based authentication)

**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|------|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/fortios-cpu-usage> |
| Nagios/Icinga Check Name              | `check_fortios_cpu_usage` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | No (`--hostname` and `--password` are required) |
| Compiled for Windows                  | No |
| Handles Periods                       | Yes |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-fortios-cpu-usage.db` |


## Help

```text
usage: fortios-cpu-usage [-h] [-V] [--always-ok] [--count COUNT] [-c CRIT]
                         -H HOSTNAME [--insecure] [--no-proxy]
                         --password PASSWORD [--timeout TIMEOUT] [-w WARN]

Monitors CPU utilization on FortiGate appliances running FortiOS via the REST
API. Alerts only if the threshold has been exceeded for a configurable number
of consecutive check runs (default: 5), suppressing short spikes. First checks
against the globally configured cpu-use-threshold on the appliance, then falls
back to command-line thresholds.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --count COUNT         Number of consecutive checks the threshold must be
                        exceeded before alerting. Default: 5
  -c, --critical CRIT   CRIT threshold for CPU usage in percent. The plugin
                        first checks against the globally configured `cpu-use-
                        threshold` on the appliance; this value is only used
                        if no global threshold exists. Default: 90
  -H, --hostname HOSTNAME
                        FortiOS-based appliance address, optionally including
                        port. Example: `--hostname 192.168.1.1:443`.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-proxy            Do not use a proxy.
  --password PASSWORD   FortiOS REST API single-use access token.
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -w, --warning WARN    WARN threshold for CPU usage in percent. The plugin
                        first checks against the globally configured `cpu-use-
                        threshold` on the appliance; this value is only used
                        if no global threshold exists. Default: 80
```


## Usage Examples

```bash
./fortios-cpu-usage --hostname fortigate-cluster.linuxfabrik.io --password mypass --count=15 --warning=50 --critical=70
```

Output:

```text
0%
```


## States

* OK if CPU usage is below the thresholds within the last `--count` consecutive checks.
* WARN if CPU usage exceeds the warning threshold (appliance's `cpu-use-threshold` or `--warning`, default: 80%) for `--count` consecutive checks (default: 5).
* CRIT if CPU usage exceeds `--critical` (default: 90%) for `--count` consecutive checks (default: 5).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| cpu-usage | Percentage | Current CPU usage of the FortiGate appliance. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
