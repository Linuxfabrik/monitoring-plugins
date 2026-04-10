# Check qts-memory-usage

## Overview

Monitors system memory utilization on QNAP appliances running QTS via the HTTP API. Reports total, used, and free memory along with the usage percentage.

**Alerting Logic:**

* WARN if memory usage exceeds `--warning` (default: 80%)
* CRIT if memory usage exceeds `--critical` (default: 90%)
* `--always-ok` suppresses all alerts and always returns OK

**Data Collection:**

* Authenticates against the QTS API and fetches system information via `/cgi-bin/management/manaRequest.cgi`
* Calculates memory usage from the total and free memory values reported by QTS

**Important Notes:**

* Tested on [QuTScloud](https://www.qnap.com/en-us/download?model=qutscloud&category=firmware) v4.5.6+
* The user used for monitoring must be a member of the "administrators" group. It is not sufficient to be a member of the "everyone" group.

**Compatibility:**

* Linux only
* 3rd party Python module `xmltodict` required


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/qts-memory-usage> |
| Nagios/Icinga Check Name              | `check_qts_memory_usage` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | No (`--password` and `--url` are required) |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `xmltodict` |


## Help

```text
usage: qts-memory-usage [-h] [-V] [--always-ok] [-c CRIT] [--insecure]
                        [--no-proxy] --password PASSWORD [--timeout TIMEOUT]
                        --url URL [--username USERNAME] [-w WARN]

Monitors system memory utilization on QNAP appliances running QTS via the API.
Alerts when memory usage exceeds the configured thresholds.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  -c, --critical CRIT  CRIT threshold for memory usage as a percentage.
                       Default: 90
  --insecure           This option explicitly allows insecure SSL connections.
  --no-proxy           Do not use a proxy.
  --password PASSWORD  QTS API password.
  --timeout TIMEOUT    Network timeout in seconds. Default: 6 (seconds)
  --url URL            QTS-based appliance URL. Example:
                       `--url=https://192.168.1.1:8080`.
  --username USERNAME  QTS API username. Default: admin
  -w, --warning WARN   WARN threshold for memory usage as a percentage.
                       Default: 80
```


## Usage Examples

```bash
./qts-memory-usage --url http://qts:8080 --username admin --password linuxfabrik --insecure
```

Output:

```text
7.33% - total: 62.8GiB, used: 4.6GiB, free: 58.2GiB
```


## States

* OK if memory usage is below the thresholds.
* WARN if memory usage exceeds `--warning` (default: 80%).
* CRIT if memory usage exceeds `--critical` (default: 90%).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name         | Type       | Description                    |
|--------------|------------|--------------------------------|
| free         | Bytes      | Free memory.                   |
| memory-usage | Percentage | Memory usage, in percent.      |
| total        | Bytes      | Total memory.                  |
| used         | Bytes      | Used memory.                   |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
