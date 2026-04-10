# Check qts-version

## Overview

Checks if firmware updates are available for a QNAP appliance running QTS by querying the QNAP update API. Reports the currently installed version and alerts when a newer firmware version is available.

**Alerting Logic:**

* WARN if a firmware update is available
* `--always-ok` suppresses all alerts and always returns OK

**Data Collection:**

* Authenticates against the QTS API and fetches system information via `/cgi-bin/management/manaRequest.cgi`
* Checks for updates via `/cgi-bin/sys/sysRequest.cgi?subfunc=firm_update`
* Compares the installed version against the latest available version

**Important Notes:**

* Tested on [QuTScloud](https://www.qnap.com/en-us/download?model=qutscloud&category=firmware) v4.5.6+
* Does not work on QTS 4.3 or less (see [#701](https://github.com/Linuxfabrik/monitoring-plugins/issues/701) for details).
* The user used for monitoring must be a member of the "administrators" group. It is not sufficient to be a member of the "everyone" group.

**Compatibility:**

* Linux only
* 3rd party Python module `xmltodict` required


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/qts-version> |
| Nagios/Icinga Check Name              | `check_qts_version` |
| Check Interval Recommendation         | Once a day |
| Can be called without parameters      | No (`--password` and `--url` are required) |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `xmltodict` |


## Help

```text
usage: qts-version [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                   --password PASSWORD [--timeout TIMEOUT] --url URL
                   [--username USERNAME]

Checks if firmware updates are available for a QNAP appliance running QTS by
querying the QNAP update API. Alerts when firmware updates are available.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
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
./qts-version --url http://qts:8080 --username admin --password linuxfabrik --insecure
```

Output:

```text
QTS vc5.0.1.2374 Build 20230419 installed, QTS vc5.1.0.2498 Build 20230822 available
```


## States

* OK if the installed firmware is up to date.
* WARN if a firmware update is available.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
