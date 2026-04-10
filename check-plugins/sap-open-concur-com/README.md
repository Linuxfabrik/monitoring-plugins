# Check sap-open-concur-com

## Overview

Monitors the SAP Concur Open status page (<https://open.concur.com>) for active service incidents. The dashboard displays the most recent 20 days of Concur service availability.

**Data Collection:**

* Queries the SAP Concur Open status API at `https://open.concur.com/api/v2/status_history`
* Checks a specific datacenter (us, us2, eu, eu2, cn, pscc) via `--datacenter`
* Can check a single service or all services at once via `--service`
* Available services: Analysis/Intelligence, Compleat (TMC Services), Expense, Imaging, Invoice, Mobile, Request, Travel

**Important Notes:**

* Not all SAP datacenters offer all services. Have a look at <https://open.concur.com> for details.

**Compatibility:**

* Linux


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/sap-open-concur-com> |
| Nagios/Icinga Check Name              | `check_sap_open_concur_com` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | No (`--datacenter` is required) |
| Compiled for Windows                  | No |


## Help

```text
usage: sap-open-concur-com [-h] [--always-ok] [-V]
                           --datacenter {us,us2,eu,eu2,cn,pscc} [--insecure]
                           [--no-proxy] [--service SERVICE] [--test TEST]
                           [--timeout TIMEOUT] [--utc-offset UTC_OFFSET]

Monitors the SAP Concur Open status page (open.concur.com) for active service
incidents. Alerts when unresolved incidents are reported on the dashboard.

options:
  -h, --help            show this help message and exit
  --always-ok           Always returns OK.
  -V, --version         show program's version number and exit
  --datacenter {us,us2,eu,eu2,cn,pscc}
                        SAP Concur datacenter to query. Default: eu
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-proxy            Do not use a proxy.
  --service SERVICE     SAP Concur service to check. One of
                        "Analysis/Intelligence", "Compleat (TMC Services)",
                        "Expense", "Imaging", "Invoice", "Mobile", "Request",
                        "Travel", or simply "All". Check
                        https://open.concur.com to see which service is
                        available for which datacenter. Default: All
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  --utc-offset UTC_OFFSET
                        UTC offset for timestamp display. Default: +0200
```


## Usage Examples

```bash
./sap-open-concur-com --datacenter=eu2 --service=All --utc-offset=+0200
```

Output:

```text
Analysis/Intelligence: disruption [CRITICAL], Expense: degradation [WARNING] (@emea, UTC+0200)
```


## States

* OK if all checked services are in "Normal" state.
* WARN if any checked service is in "Degradation" state.
* CRIT if any checked service is in "Disruption" state.
* UNKNOWN if the requested service is not available for the specified datacenter.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch); originally written by Dominik Riva, Universitätsspital Basel/Switzerland
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
