# Check qts-cpu-usage

## Overview

Returns the current system-wide CPU utilization as a percentage from a QNAP Appliance running QTS, using the HTTP API. Warns only if the overall CPU usage is above a certain threshold within the last n checks (default: 5).

Hints and Recommendations:

* Tested on [QuTScloud](https://www.qnap.com/en-us/download?model=qutscloud&category=firmware) v4.5.6+
* The user used for monitoring must be a member of the "administrators" group. It is not sufficient to be a member of the "everyone" group.
* `--count=5` (the default) while checking every minute means that the check reports a warning if the overall CPU usage is above a threshold in the last 5 minutes.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/qts-cpu-usage> |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | No |
| Compiled for Windows                  | No |
| Handles Periods                       | Yes |
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-monitoring-plugins-qts-cpu-usage.db` |


## Help

```text
usage: qts-cpu-usage [-h] [-V] [--always-ok] [--count COUNT] [-c CRIT]
                     [--insecure] [--no-proxy] --password PASSWORD
                     [--timeout TIMEOUT] --url URL [--username USERNAME]
                     [-w WARN]

Returns the current system-wide CPU utilization as a percentage from QNAP
Appliances running QTS via API. Warns only if the overall CPU usage is above a
certain threshold within the last n checks (default: 5). The authentication is
done via a single API token (Token-based authentication), not via Session-
based authentication, which is stated as "legacy".

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  --count COUNT        Number of times the value must exceed specified
                       thresholds before alerting. Default: 5
  -c, --critical CRIT  Set the critical threshold CPU Usage Percentage.
                       Default: 90
  --insecure           This option explicitly allows to perform "insecure" SSL
                       connections. Default: False
  --no-proxy           Do not use a proxy. Default: False
  --password PASSWORD  QTS Password.
  --timeout TIMEOUT    Network timeout in seconds. Default: 6 (seconds)
  --url URL            QTS-based Appliance URL, for example
                       https://192.168.1.1:8080.
  --username USERNAME  QTS User. Default: admin
  -w, --warning WARN   Set the warning threshold CPU Usage Percentage.
                       Default: 80
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

* OK if overall `cpu-usage` is below the thresholds within the last `--count` checks.
* Otherwise CRIT or WARN.


## Perfdata / Metrics

| Name      | Type       | Description            |
|-----------|------------|------------------------|
| cpu-usage | Percentage | The overall cpu usage. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
