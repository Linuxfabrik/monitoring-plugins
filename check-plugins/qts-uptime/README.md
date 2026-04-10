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

**Compatibility:**

* Cross-platform



## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/qts-uptime> |
| Nagios/Icinga Check Name              | `check_qts_uptime` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | No (`--password` and `--url` are required) |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `xmltodict` |


## Help

```text
usage: qts-uptime [-h] [-V] [--insecure] [--no-proxy] --password PASSWORD
                  [--timeout TIMEOUT] --url URL [--username USERNAME]

Reports how long a QNAP appliance running QTS has been running since the last
boot.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --insecure           This option explicitly allows insecure SSL connections.
  --no-proxy           Do not use a proxy.
  --password PASSWORD  QTS API password.
  --timeout TIMEOUT    Network timeout in seconds. Default: 6 (seconds)
  --url URL            QTS-based appliance URL. Example:
                       `--url=https://192.168.1.1:8080`.
  --username USERNAME  QTS API username. Default: admin
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

| Name   | Type    | Description                              |
|--------|---------|------------------------------------------|
| uptime | Seconds | The time the appliance has been running for. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
