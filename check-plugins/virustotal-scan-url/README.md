# Check virustotal-scan-url

## Overview

Analyses URLs to detect malware and other breaches using [VirusTotal](https://www.virustotal.com/).

Hints:

* In order to use this plugin, you will need to create a VirusTotal account.
* This plugin uses the [VirusTotal API v3](https://docs.virustotal.com/reference/overview). See the [documentation](https://docs.virustotal.com/reference/public-vs-premium-api) on any constraints and restrictions, especially for commercial use.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/virustotal-scan-url> |
| Check Interval Recommendation         | Once an hour |
| Can be called without parameters      | No |
| Requirements                          | VirusTotal account, VirusTotal API key and Premium API if this plugin is used in business workflows that do not contribute new files or in commercial products/services. |


## Help

```text
usage: virustotal-scan-url [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                           [--severity {warn,crit}] [--test TEST]
                           [--timeout TIMEOUT] --token TOKEN --url URL

Analyses URLs to detect malware and other breaches using VirusTotal.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --insecure            This option explicitly allows to perform "insecure"
                        SSL connections. Default: False
  --no-proxy            Do not use a proxy. Default: False
  --severity {warn,crit}
                        Severity for alerting. Default: warn
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --token TOKEN         VirusTotal API token
  --url URL             URL to scan.
```


## Usage Examples

```bash
./virustotal-scan-url --token b480bd43 --url https://secure.eicar.org/eicar.com
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

* Alerts according to the given severity level (default: WARN due to the many false positives on VT) if the scanner's result falls into the "malicious" category.


## Perfdata / Metrics

According to <https://docs.virustotal.com/reference/analyses-object>:

| Name | Type | Description |
|----|----|----|
| harmless | Number | Number of reports saying that is harmless. |
| malicious | Number | Number of reports saying that is malicious. |
| suspicious | Number | Number of reports saying that is suspicious. |
| timeout | Number | Number of timeouts when analysing this URL. |
| undetected | Number | Number of reports saying that is undetected. |
| vendors | Number | Number of scan vendors used. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
