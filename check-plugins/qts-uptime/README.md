# Check qts-uptime


## Overview

Reports how long a QNAP appliance running QTS has been running since the last boot.

**Important Notes:**

* 3rd party Python module `xmltodict` required
* Tested on [QuTScloud](https://www.qnap.com/en-us/download?model=qutscloud&category=firmware) v4.5.6+
* The user used for monitoring must be a member of the "administrators" group. It is not sufficient to be a member of the "everyone" group.

**Data Collection:**

* Authenticates against the QTS API and fetches system information via `/cgi-bin/management/manaRequest.cgi`
* Calculates uptime from the day, hour, minute, and second fields reported by QTS


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/qts-uptime> |
| Nagios/Icinga Check Name              | `check_qts_uptime` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | No (`--password` and `--url` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| 3rd Party Python modules              | `xmltodict` |


## Help

```text
usage: qts-uptime [-h] [-V] [--always-ok] [--insecure] [--no-perfdata]
                  [--no-proxy] --password PASSWORD [--proxy PROXY]
                  [--timeout TIMEOUT] --url URL [--username USERNAME]

Reports how long a QNAP appliance running QTS has been running since the last
boot.

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
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/qts-uptime/
```


## Usage Examples

```bash
./qts-uptime --url http://192.168.1.100:8080 --username admin --password linuxfabrik --insecure
```

Output:

```text
Up 1W 6D
```


## States

* Always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| uptime | Seconds | The time the appliance has been running for. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
