# Check virustotal-scan-url


## Overview

Submits a URL to VirusTotal for analysis and checks the scan results. Alerts when any antivirus engine flags the URL as malicious or suspicious. Useful for periodically scanning critical URLs against 90+ security vendors.

**Important Notes:**

* Requires a VirusTotal account and API key
* Takes at least 60 seconds to execute due to the built-in wait for analysis completion
* See the [VirusTotal documentation](https://docs.virustotal.com/reference/public-vs-premium-api) on any constraints and restrictions, especially for commercial use (Premium API may be required for business workflows)

**Data Collection:**

* Submits the URL to the [VirusTotal v3 API](https://docs.virustotal.com/reference/scan-url) (`POST /urls`)
* Waits 60 seconds for the analysis to complete
* Retrieves the full analysis report via the VirusTotal Analysis endpoint (`GET /analyses/{id}`)
* Reports per-engine results for any detection that is not "harmless" or "undetected"


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/virustotal-scan-url> |
| Nagios/Icinga Check Name              | `check_virustotal_scan_url` |
| Check Interval Recommendation         | Once an hour |
| Can be called without parameters      | No (`--token` and `--url` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Requirements                          | VirusTotal account and API key; Premium API if used in commercial products/services |


## Help

```text
usage: virustotal-scan-url [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                           [--severity {warn,crit}] [--test TEST]
                           [--timeout TIMEOUT] --token TOKEN --url URL

Submits a URL to VirusTotal for analysis and checks the scan results. Alerts
when any antivirus engine flags the URL as malicious or suspicious. Requires a
VirusTotal API key.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-proxy            Do not use a proxy.
  --severity {warn,crit}
                        Severity for alerting. Default: warn
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --token TOKEN         VirusTotal API token.
  --url URL             URL to submit for scanning.
```


## Usage Examples

```bash
./virustotal-scan-url --token=b480bd43 --url=https://secure.eicar.org/eicar.com
```

Output:

```text
9/97 security vendors flagged https://secure.eicar.org/eicar.com as malicious.

Engine      ! Result     ! Method    ! Category           
------------+------------+-----------+--------------------
Antiy-AVL   ! malicious  ! blacklist ! malicious [WARNING]
AutoShun    ! malicious  ! blacklist ! malicious [WARNING]
BitDefender ! malware    ! blacklist ! malicious [WARNING]
CRDF        ! malicious  ! blacklist ! malicious [WARNING]
Fortinet    ! malware    ! blacklist ! malicious [WARNING]
G-Data      ! malware    ! blacklist ! malicious [WARNING]
Lionic      ! malware    ! blacklist ! malicious [WARNING]
Sophos      ! malware    ! blacklist ! malicious [WARNING]
URLQuery    ! suspicious ! blacklist ! suspicious         
VIPRE       ! malware    ! blacklist ! malicious [WARNING]
```


## States

* OK if no scan engine categorizes the URL as malicious.
* WARN (or CRIT, depending on `--severity`) if any scan engine categorizes the URL as "malicious".
* UNKNOWN if the analysis is still queued or in progress.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

According to <https://docs.virustotal.com/reference/analyses-object>:

| Name | Type | Description |
|----|----|----|
| harmless | Number | Number of reports saying the URL is harmless. |
| malicious | Number | Number of reports saying the URL is malicious. |
| suspicious | Number | Number of reports saying the URL is suspicious. |
| timeout | Number | Number of timeouts when analysing this URL. |
| undetected | Number | Number of reports saying the URL is undetected. |
| vendors | Number | Total number of scan vendors used. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
