# Check qts-version


## Overview

Checks if firmware updates are available for a QNAP appliance running QTS, as reported by the update check of the appliance itself. Compares version and build number, so a new build of the installed version counts as an update. Alerts when a firmware update is available.

**Important Notes:**

* See [QNAP plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-qnap/) for the monitoring account, the requirements and for testing without a QNAP appliance.

**Data Collection:**

* Authenticates against the QTS API and fetches system information via `/cgi-bin/management/manaRequest.cgi`
* Checks for updates via `/cgi-bin/sys/sysRequest.cgi?subfunc=firm_update`, which reports the update QTS itself knows of. Newer firmware reports one update per channel ("official" and "recommended"), the plugin reports the newest of them.
* Compares version and build number of the installed firmware against the available one, so a new build of the same version (for example 5.2.10.3568 to 5.2.10.3577) counts as an update


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/qts-version> |
| Nagios/Icinga Check Name              | `check_qts_version` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | No (`--password` and `--url` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| 3rd Party Python modules              | `xmltodict` |


## Help

```text
usage: qts-version [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                   --password PASSWORD [--proxy PROXY] [--timeout TIMEOUT]
                   --url URL [--username USERNAME]

Checks if firmware updates are available for a QNAP appliance running QTS, as
reported by the update check of the appliance itself. Compares version and
build number, so a new build of the installed version counts as an update.
Alerts when a firmware update is available.

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
./qts-version --url=http://qts:8080 --username=admin --password=linuxfabrik --insecure
```

Output:

```text
QTS vc5.2.4.3041 Build 20250211 installed, QTS vc5.2.9.3468 Build 20260413 available [WARNING]
```


## States

* OK if the installed firmware is up to date, or if QTS knows of no update.
* WARN if a firmware update is available.
* UNKNOWN if QTS reports an error for its update check. An error of the "recommended" channel alone is ignored, some firmware versions ask for a channel QNAP does not serve.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
