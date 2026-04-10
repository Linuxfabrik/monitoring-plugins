# Check kemp-services

## Overview

Monitors virtual services on a KEMP LoadMaster appliance via its REST API and alerts when any virtual service or its real servers are in a non-operational state.

**Data Collection:**

* Queries the KEMP LoadMaster REST API endpoint `/access/listvs` using Basic authentication
* Parses the XML response to extract the NickName and Status of each virtual service
* Use `--filter` to only check virtual services whose NickName contains a specific string

**Compatibility:**

* Any KEMP LoadMaster appliance with REST API enabled


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/kemp-services> |
| Nagios/Icinga Check Name              | `check_kemp_services` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | No (`--hostname`, `--username`, and `--password` are required) |
| Compiled for Windows                  | No |


## Help

```text
usage: kemp-services [-h] [-V] [--always-ok] [--filter FILTER] -H HOSTNAME
                     [--insecure] [--no-proxy] --password PASSWORD
                     [--port PORT] [--severity {warn,crit}] [--test TEST]
                     [--timeout TIMEOUT] -u USERNAME

Monitors virtual services on a KEMP LoadMaster appliance via its REST API.
Alerts when any virtual service or its real servers are in a non-operational
state.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --filter FILTER       Only check virtual services whose NickName contains
                        this string.
  -H, --hostname HOSTNAME
                        KEMP LoadMaster appliance address, can be a hostname
                        or IP address.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-proxy            Do not use a proxy.
  --password PASSWORD   KEMP REST API password.
  --port PORT           KEMP LoadMaster appliance port. Default: 443
  --severity {warn,crit}
                        Severity for alerting. Default: warn
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -u, --username USERNAME
                        KEMP REST API username.
```


## Usage Examples

```bash
./kemp-services --hostname=192.0.2.10 --username=user --password=password
./kemp-services --hostname=192.0.2.10 --username=user --password=password --filter=PROD
./kemp-services --hostname=192.0.2.10 --username=user --password=password --filter=PROD --severity=crit
```

Output:

```text
5 services checked.

NickName               ! Status
-----------------------+----------------
KEMP LoadBalancer PROD ! Up
website1 PROD          ! Down [WARNING]
website2 PROD          ! Up
website01 DEV          ! Up
Redirect 192.0.2.1     ! Disabled
```


## States

* OK if all checked virtual services are in "Up", "Unchecked", or "Disabled" state.
* WARN (default) or CRIT (via `--severity=crit`) if any virtual service is in "Down" state.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| services | Number | Total number of virtual services checked. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
