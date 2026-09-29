# Check qts-temperatures


## Overview

Checks system and CPU temperatures on QNAP appliances running QTS via the API. The thresholds are the ones configured in QTS. A temperature the model does not report is left out. Alerts when a temperature reaches the warning or error threshold configured in QTS. All temperatures are expressed in Celsius.

**Important Notes:**

* See [QNAP plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-qnap/) for the monitoring account, the requirements and for testing without a QNAP appliance.

**Data Collection:**

* Authenticates against the QTS API and fetches system information via `/cgi-bin/management/manaRequest.cgi`
* Reads system temperature (`sys_tempc`), CPU temperature (`cpu_tempc`), and the corresponding warning/error thresholds from the QTS configuration


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/qts-temperatures> |
| Nagios/Icinga Check Name              | `check_qts_temperatures` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | No (`--password` and `--url` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| 3rd Party Python modules              | `xmltodict` |


## Help

```text
usage: qts-temperatures [-h] [-V] [--always-ok] [--insecure] [--no-perfdata]
                        [--no-proxy] --password PASSWORD [--proxy PROXY]
                        [--timeout TIMEOUT] --url URL [--username USERNAME]

Checks system and CPU temperatures on QNAP appliances running QTS via the API.
The thresholds are the ones configured in QTS. A temperature the model does
not report is left out. Alerts when a temperature reaches the warning or error
threshold configured in QTS.

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
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/qts-temperatures/
```


## Usage Examples

```bash
./qts-temperatures --url=http://qts:8080 --username=admin --password=linuxfabrik --insecure
```

Output:

```text
Sys: 59°C (Thresholds: 60/70°C), CPU: 82°C (Thresholds: 80/85°C) [WARNING]
```


## States

* OK if both system and CPU temperatures are below the QTS-configured thresholds.
* WARN if the system or CPU temperature exceeds the warning threshold configured in QTS.
* CRIT if the system or CPU temperature exceeds the error threshold configured in QTS.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| cputemp | Number | CPU temperature, in degrees Celsius.    |
| systemp | Number | System temperature, in degrees Celsius. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
