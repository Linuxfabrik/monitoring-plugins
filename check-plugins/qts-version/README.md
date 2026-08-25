# Check qts-version


## Overview

Checks if firmware updates are available for a QNAP appliance running QTS by querying the QNAP update API. Reports the currently installed version and alerts when a newer firmware version is available.

**Important Notes:**

* 3rd party Python module `xmltodict` required
* Tested on [QuTScloud](https://www.qnap.com/en-us/download?model=qutscloud&category=firmware) v4.5.6+
* Does not work on QTS 4.3 or less (see [#701](https://github.com/Linuxfabrik/monitoring-plugins/issues/701) for details).
* The user used for monitoring must be a member of the "administrators" group. It is not sufficient to be a member of the "everyone" group.

**Data Collection:**

* Authenticates against the QTS API and fetches system information via `/cgi-bin/management/manaRequest.cgi`
* Checks for updates via `/cgi-bin/sys/sysRequest.cgi?subfunc=firm_update`
* Compares the installed version against the latest available version


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/qts-version> |
| Nagios/Icinga Check Name              | `check_qts_version` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | No (`--password` and `--url` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `xmltodict` |


## Help

```text
usage: qts-version [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                   --password PASSWORD [--proxy PROXY] [--timeout TIMEOUT]
                   --url URL [--username USERNAME]

Checks if firmware updates are available for a QNAP appliance running QTS by
querying the QNAP update API. Alerts when firmware updates are available.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  --insecure           This option explicitly allows insecure SSL connections.
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
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/qts-version/
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
