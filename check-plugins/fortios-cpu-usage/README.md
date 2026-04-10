# Check fortios-cpu-usage

## Overview

Returns the current system-wide CPU utilization as a percentage from a Forti Appliance like FortiGate running FortiOS, using the FortiOS REST API. Warns only if the overall CPU usage is above a certain threshold within the last n checks (default: 5). The authentication is done via a single API token (Token-based authentication), not via Session-based authentication, which is stated as "legacy".

Hints:

* This plugin tries to check against the global configured `cpu-use-threshold` first; only if there is no value, the check's command line values (or their defaults) are used.
* `--count=5` (the default) while checking every minute means that the check reports a warning if the overall CPU usage is above a threshold in the last 5 minutes.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/fortios-cpu-usage> |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | No |
| Compiled for Windows                  | No |
| Handles Periods                       | Yes |
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-monitoring-plugins-fortios-cpu-usage.db` |


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
                        if no global threshold exists. Default: 90.
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
                        if no global threshold exists. Default: 80.
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

* OK if overall `cpu-usage` is below the thresholds within the last `--count` checks.
* Otherwise CRIT or WARN.


## Perfdata / Metrics

* `cpu-usage`: The overall cpu usage.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
