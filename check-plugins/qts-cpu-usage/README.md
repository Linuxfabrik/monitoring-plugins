# Check qts-cpu-usage


## Overview

Monitors CPU utilization on QNAP appliances running QTS via the HTTP API. Alerts only if the threshold has been exceeded for a configurable number of consecutive check runs (default: 5), suppressing short spikes.

**Important Notes:**

* 3rd party Python module `xmltodict` required
* Tested on [QuTScloud](https://www.qnap.com/en-us/download?model=qutscloud&category=firmware) v4.5.6+
* The user used for monitoring must be a member of the "administrators" group. It is not sufficient to be a member of the "everyone" group.

**Data Collection:**

* Authenticates against the QTS API and fetches system information via `/cgi-bin/management/manaRequest.cgi`
* Uses a local SQLite database to store historical CPU measurements for trend tracking
* `--count=5` (the default) while checking every minute means the check reports a warning if the overall CPU usage is above a threshold in the last 5 minutes


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/qts-cpu-usage> |
| Nagios/Icinga Check Name              | `check_qts_cpu_usage` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | No (`--password` and `--url` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `xmltodict` |
| Handles Periods                       | Yes |
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-monitoring-plugins-qts-cpu-usage.db` |


## Help

```text
usage: qts-cpu-usage [-h] [-V] [--always-ok] [--count COUNT] [-c CRIT]
                     [--insecure] [--no-proxy] --password PASSWORD
                     [--timeout TIMEOUT] --url URL [--username USERNAME]
                     [-w WARN]

Monitors CPU utilization on QNAP appliances running QTS via the API. Alerts
only if the threshold has been exceeded for a configurable number of
consecutive check runs (default: 5), suppressing short spikes.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  --count COUNT        Number of consecutive checks the threshold must be
                       exceeded before alerting. Default: 5
  -c, --critical CRIT  CRIT threshold in percent. Default: >= 90
  --insecure           This option explicitly allows insecure SSL connections.
  --no-proxy           Do not use a proxy.
  --password PASSWORD  QTS API password.
  --timeout TIMEOUT    Network timeout in seconds. Default: 6 (seconds)
  --url URL            QTS-based appliance URL. Example:
                       `https://192.0.2.10:8080`.
  --username USERNAME  QTS API username. Default: admin
  -w, --warning WARN   WARN threshold in percent. Default: >= 80
```


## Usage Examples

```bash
./qts-cpu-usage --url http://qts:8080 --username admin --password linuxfabrik --insecure
```

Output:

```text
1.9%
```


## States

* OK if CPU usage is below the thresholds within the last `--count` checks.
* WARN if CPU usage exceeds `--warning` (default: 80%) for `--count` (default: 5) consecutive checks.
* CRIT if CPU usage exceeds `--critical` (default: 90%) for `--count` (default: 5) consecutive checks.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| cpu-usage | Percentage | The overall CPU usage. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
