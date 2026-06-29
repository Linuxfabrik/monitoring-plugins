# Check nextcloud-security-scan


## Overview

Checks the security of a Nextcloud (or ownCloud) server using the Nextcloud security scanner at <https://scan.nextcloud.com/>. Reports the assigned security rating and alerts on known vulnerabilities, missing hardenings, and setup issues.

**Important Notes:**

* Run it once a day at most. There is an API rate limit at scan.nextcloud.com of less than 100 POST requests per day (exceeding this returns "403 Forbidden").
* After a re-scan is triggered, it takes about 5 minutes until the new result is available

**Data Collection:**

* Submits the Nextcloud URL to the scan.nextcloud.com API to obtain a UUID
* Fetches the scan result using that UUID
* Triggers a re-scan if the result is older than the configured number of days (default: 14)
* Triggers a re-scan immediately when `--path` is set and the locally installed version differs from the one scan.nextcloud.com last saw, so the rating no longer lags a Nextcloud update
* The check does not need to run on the Nextcloud server itself, unless `--path` is used to detect updates (which requires sudo for the UID owning `config/config.php`)


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/nextcloud-security-scan> |
| Nagios/Icinga Check Name              | `check_nextcloud_security_scan` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | No (`--url` is required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |


## Help

```text
usage: nextcloud-security-scan [-h] [-V] [--insecure] [--no-proxy]
                               [--path PATH] [--timeout TIMEOUT]
                               [--trigger TRIGGER] -u URL

Checks the security of a private Nextcloud server using the Nextcloud security
scanner. Reports the assigned security rating and alerts on known
vulnerabilities in the installed version. When --path points at a local
Nextcloud installation, the plugin reads the installed version and forces a
fresh scan after an update, so the rating never lags behind.

options:
  -h, --help         show this help message and exit
  -V, --version      show program's version number and exit
  --insecure         This option explicitly allows insecure SSL connections.
  --no-proxy         Do not use a proxy.
  --path PATH        Local path to the Nextcloud installation, typically the
                     web server document root. When set, the plugin reads the
                     installed version via `occ` and triggers an immediate re-
                     scan if it differs from the version scan.nextcloud.com
                     last saw, so the rating no longer lags a Nextcloud
                     update. Requires running on the Nextcloud server with
                     sudo for the UID owning config/config.php.
  --timeout TIMEOUT  Network timeout in seconds. Default: 7 (seconds)
  --trigger TRIGGER  Trigger a re-scan if the result on scan.nextcloud.com is
                     older than this many days. Default: 14 (days)
  -u, --url URL      Nextcloud server URL. Example: `cloud.example.com`.
```


## Usage Examples

```bash
./nextcloud-security-scan --url cloud.linuxfabrik.io --timeout 1 --trigger 10
```

Output:

```text
"A+" rating for cloud.linuxfabrik.io, checked at 2021-06-04, on Nextcloud v21.0.2.1.
```


## States

* OK if the rating is A or A+.
* WARN if the rating is C or D.
* CRIT if the rating is E or F.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
