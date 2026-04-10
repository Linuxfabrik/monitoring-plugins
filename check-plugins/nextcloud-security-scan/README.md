# Check nextcloud-security-scan

## Overview

Checks the security of a Nextcloud (or ownCloud) server using the Nextcloud security scanner at <https://scan.nextcloud.com/>. Reports the assigned security rating and alerts on known vulnerabilities, missing hardenings, and setup issues.

**Data Collection:**

* Submits the Nextcloud URL to the scan.nextcloud.com API to obtain a UUID
* Fetches the scan result using that UUID
* Triggers a re-scan if the result is older than the configured number of days (default: 14)
* The check does not need to run on the Nextcloud server itself

**Important Notes:**

* Run it once a day at most. There is an API rate limit at scan.nextcloud.com of less than 100 POST requests per day (exceeding this returns "403 Forbidden").
* After a re-scan is triggered, it takes about 5 minutes until the new result is available



**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/nextcloud-security-scan> |
| Nagios/Icinga Check Name              | `check_nextcloud_security_scan` |
| Check Interval Recommendation         | Once a day or week |
| Can be called without parameters      | No (`--url` is required) |
| Compiled for Windows                  | No |


## Help

```text
usage: nextcloud-security-scan [-h] [-V] [--insecure] [--no-proxy]
                               [--timeout TIMEOUT] [--trigger TRIGGER] -u URL

Checks the security of a private Nextcloud server using the Nextcloud security
scanner. Reports the assigned security rating and alerts on known
vulnerabilities in the installed version.

options:
  -h, --help         show this help message and exit
  -V, --version      show program's version number and exit
  --insecure         This option explicitly allows insecure SSL connections.
  --no-proxy         Do not use a proxy.
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
