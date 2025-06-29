# Check sap-open-concur-com

## Overview

This plugin checks for incidents mentioned at the [SAP Concur Open](https://open.concur.com/) Service Status Dashboard. The Concur Open service status dashboard displays the most recent 20 days of Concur service availability.

Hints:

* Not all SAP datacenters offer all services. Have a look at <https://open.concur.com> for details.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/example> |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
usage: sap-open-concur-com [-h] [--always-ok] [-V]
                           --datacenter {us,us2,eu,eu2,cn,pscc} [--insecure]
                           [--no-proxy] [--service SERVICE] [--test TEST]
                           [--timeout TIMEOUT] [--utc-offset UTC_OFFSET]

This plugin checks for incidents mentioned at the SAP Concur Open
(https://open.concur.com/) Service Status Dashboard.

options:
  -h, --help            show this help message and exit
  --always-ok           Always returns OK.
  -V, --version         show program's version number and exit
  --datacenter {us,us2,eu,eu2,cn,pscc}
                        Datacenter to query. Default: eu
  --insecure            This option explicitly allows to perform "insecure"
                        SSL connections. Default: False
  --no-proxy            Do not use a proxy. Default: False
  --service SERVICE     Service to check. One of "Analysis/Intelligence",
                        "Compleat (TMC Services)", "Expense", "Imaging",
                        "Invoice", "Mobile", "Request", "Travel", or simply
                        "All". Check https://open.concur.com to see which
                        service is available for which data center. Default:
                        All
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  --utc-offset UTC_OFFSET
                        UTC offset. Default: +0200
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

* OK if (all) service(s) is/are in "Normal" state.
* WARN if (any) service is in "Degradation" state.
* CRIT if (any) service is in "Disruption" state.
* If wanted, always returns OK.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch); originally written by Dominik Riva, Universitätsspital Basel/Switzerland
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
