# Check qts-disk-smart


## Overview

Checks disk SMART values on QNAP appliances running QTS via the API. Reports drive health and temperature against the thresholds configured in QTS. A disk that reports no temperature is rated by its health only. Alerts when any disk reports a non-normal SMART status or reaches a temperature threshold.

**Important Notes:**

* See [QNAP plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-qnap/) for the monitoring account, the requirements and for testing without a QNAP appliance.

**Data Collection:**

* Authenticates against the QTS API and fetches disk SMART data via `/cgi-bin/disk/qsmart.cgi`
* Fetches system information via `/cgi-bin/management/manaRequest.cgi` to retrieve temperature thresholds
* A disk that reports no temperature, a virtual disk of QuTScloud for example, is rated by its health only and adds no perfdata.
* This check does not run SMART itself. To get the latest values, schedule the built-in SMART check in the QTS web interface.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/qts-disk-smart> |
| Nagios/Icinga Check Name              | `check_qts_disk_smart` |
| Check Interval Recommendation         | Every 8 hours |
| Can be called without parameters      | No (`--password` and `--url` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| 3rd Party Python modules              | `xmltodict` |


## Help

```text
usage: qts-disk-smart [-h] [-V] [--always-ok] [--insecure] [--no-perfdata]
                      [--no-proxy] --password PASSWORD [--proxy PROXY]
                      [--timeout TIMEOUT] --url URL [--username USERNAME]

Checks disk SMART values on QNAP appliances running QTS via the API. Reports
drive health and temperature against the thresholds configured in QTS. A disk
that reports no temperature is rated by its health only. Alerts when any disk
reports a non-normal SMART status or reaches a temperature threshold.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  --insecure           This option explicitly allows insecure SSL connections.
  --no-perfdata        Suppress the performance data section from the output.
                       The status message and the exit code are unaffected, so
                       alerting keeps working while trending data is dropped.
  --no-proxy           Do not use a proxy, not even one the environment names.
                       Overrides `--proxy`.
  --password PASSWORD  QTS API password.
  --proxy PROXY        Proxy to reach the target through. The scheme defaults
                       to `http` when omitted. Overrides the proxy the
                       environment names (`http_proxy`, `https_proxy`,
                       `all_proxy`) together with the exceptions it lists in
                       `no_proxy`, and is itself overridden by `--no-proxy`.
                       Without either parameter the environment applies.
                       Credentials belong into the environment variable rather
                       than here, because a command-line argument is visible
                       to every user on the host. Example:
                       `--proxy=http://proxy.example.com:3128`.
  --timeout TIMEOUT    Network timeout in seconds. Default: 6 (seconds)
  --url URL            QTS-based appliance URL. Example:
                       `--url=https://192.168.1.1:8080`.
  --username USERNAME  QTS API username. Default: admin

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/qts-disk-smart/
```


## Usage Examples

```bash
./qts-disk-smart --url=http://qts:8080 --username=admin --password=linuxfabrik --insecure
```

Output:

```text
Checked 4 disks. All are healthy.
* Unknown Alias (WD30EFRX-68EUZN0, SerNo WD-XXX, Temp 32°C (Thresholds: 55/60°C))
* Unknown Alias (WD30EFRX-68EUZN0, SerNo WD-XXX, Temp 32°C (Thresholds: 55/60°C))
* Unknown Alias (WD30EFRX-68EUZN0, SerNo WD-XXX, Temp 31°C (Thresholds: 55/60°C))
* Unknown Alias (WD30EFRX-68EUZN0, SerNo WD-XXX, Temp 28°C (Thresholds: 55/60°C))
```


## States

* OK if all disks are healthy and temperatures are below the thresholds.
* WARN if any disk reports a non-normal SMART health status or temperature exceeds the warning threshold.
* CRIT if any disk temperature exceeds the critical threshold.
* UNKNOWN if no disks are found.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| NAME\_\<model\>\_\<serno\>\_temperature | Number | Temperature in degrees Celsius. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
