# Check qts-uptime

## Overview

Checks and tells how long the system has been running (in days).

Hints and Recommendations:

* Tested on [QuTScloud](https://www.qnap.com/en-us/download?model=qutscloud&category=firmware) v4.5.6+
* The user used for monitoring must be a member of the "administrators" group. It is not sufficient to be a member of the "everyone" group.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/qts-uptime> |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | No |
| Compiled for Windows                  | No |


## Help

```text
usage: qts-uptime [-h] [-V] [--insecure] [--no-proxy] --password PASSWORD
                  [--timeout TIMEOUT] --url URL [--username USERNAME]

Tells how long the QTS system has been running.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --insecure           This option explicitly allows to perform "insecure" SSL
                       connections. Default: False
  --no-proxy           Do not use a proxy. Default: False
  --password PASSWORD  QTS Password.
  --timeout TIMEOUT    Network timeout in seconds. Default: 6 (seconds)
  --url URL            QTS-based Appliance URL, for example
                       https://192.168.1.1:8080.
  --username USERNAME  QTS User. Default: admin
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
| uptime | Seconds | The time the server has been running for |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
