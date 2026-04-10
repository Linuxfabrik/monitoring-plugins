# Check fortios-memory-usage

## Overview

Returns the current system-wide memory utilization as a percentage from a Forti Appliance like FortiGate running FortiOS, using the FortiOS REST API. The authentication is done via a single API token (Token-based authentication), not via Session-based authentication, which is stated as "legacy".

Hints:

* This plugin tries to check against the global configured `memory-use-threshold-green` and `memory-use-threshold-red` first; only if there is no value, the check's command line values are used.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/fortios-memory-usage> |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | No |
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

* OK if overall <span class="title-ref">memory-usage</span> is below the thresholds.
* Otherwise CRIT or WARN.


## Perfdata / Metrics

* `usage_percent`: The overall memory usage.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
