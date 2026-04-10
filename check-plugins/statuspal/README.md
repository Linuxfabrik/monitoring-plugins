# Check statuspal

## Overview

Monitors a [Statuspal](https://www.statuspal.io/) status page, checking overall status, service states, active incidents, and scheduled maintenances.

List of public Statuspal sites - Europe:

* <https://statuspal.eu/api/v2/status_pages/a/summary>
* <https://statuspal.eu/api/v2/status_pages/exoscalestatus/summary>
* <https://statuspal.eu/api/v2/status_pages/oneid/summary>
* <https://statuspal.eu/api/v2/status_pages/rasannnt/summary>
* <https://statuspal.eu/api/v2/status_pages/rmdit/summary>
* <https://statuspal.eu/api/v2/status_pages/seppmail/summary>

List of public Statuspal sites - USA:

* <https://statuspal.io/api/v2/status_pages/2factor/summary>
* <https://statuspal.io/api/v2/status_pages/activityinfo/summary>
* <https://statuspal.io/api/v2/status_pages/ae/summary>
* <https://statuspal.io/api/v2/status_pages/aeratechnology/summary>
* <https://statuspal.io/api/v2/status_pages/alchemix/summary>
* <https://statuspal.io/api/v2/status_pages/aleeva/summary>
* <https://statuspal.io/api/v2/status_pages/amestoapps/summary>
* <https://statuspal.io/api/v2/status_pages/animaker/summary>
* <https://statuspal.io/api/v2/status_pages/anycloud/summary>
* <https://statuspal.io/api/v2/status_pages/aplaut/summary>
* <https://statuspal.io/api/v2/status_pages/arvancloud/summary>
* <https://statuspal.io/api/v2/status_pages/as134220/summary>
* <https://statuspal.io/api/v2/status_pages/ascentlogistics/summary>
* <https://statuspal.io/api/v2/status_pages/avakin/summary>
* <https://statuspal.io/api/v2/status_pages/cloudcone/summary>
* <https://statuspal.io/api/v2/status_pages/edudip/summary>
* <https://statuspal.io/api/v2/status_pages/elkir/summary>
* <https://statuspal.io/api/v2/status_pages/emango/summary>
* <https://statuspal.io/api/v2/status_pages/everynet/summary>
* <https://statuspal.io/api/v2/status_pages/finqu/summary>
* <https://statuspal.io/api/v2/status_pages/hosttech/summary>
* <https://statuspal.io/api/v2/status_pages/maslak/summary>

**Important Notes:**

* Statuspal has EU (`statuspal.eu`) and US (`statuspal.io`) endpoints
* You need to provide the URL to the Statuspal API `summary` endpoint
* API Documentation: <https://www.statuspal.io/api-docs/v2>

**Data Collection:**

* Fetches JSON from the Statuspal API v2 `summary` endpoint
* Recursively flattens nested service trees into a dotted hierarchy (e.g. `Global.DNS`)
* Lists active incidents with their latest update, and upcoming/ongoing maintenances

**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/statuspal> |
| Nagios/Icinga Check Name              | `check_statuspal` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
usage: statuspal [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                 [--test TEST] [--timeout TIMEOUT] [--url URL]

Monitors a Statuspal status page, including overall status, service states,
active incidents, and scheduled maintenances. Alerts on degraded services,
ongoing incidents, or emergency maintenance windows.

options:
  -h, --help         show this help message and exit
  -V, --version      show program's version number and exit
  --always-ok        Always returns OK.
  --insecure         This option explicitly allows insecure SSL connections.
  --no-proxy         Do not use a proxy.
  --test TEST        For unit tests. Needs "path-to-stdout-file,path-to-
                     stderr-file,expected-retc".
  --timeout TIMEOUT  Network timeout in seconds. Default: 8 (seconds)
  --url URL          Statuspal API URL pointing to the summary endpoint.
                     Default: https://statuspal.eu/api/v2/status_pages/exoscal
                     estatus/summary
```


## Usage Examples

```bash
./statuspal --url=https://statuspal.eu/api/v2/status_pages/exoscalestatus/summary
```

Output:

```text
Major incidents @ Exoscale (exoscale.com, TZ Europe/Zurich): [Network] Transient network disturbance / Situation has been resolved, we're monitoring the situation (2023-10-10 09:03:06) (see https://exoscalestatus.com/incidents/81315)

Service                            ! State 
-----------------------------------+-------
Global.DNS                         ! [OK]  
Global.Portal                      ! [OK]  
CH-GVA-2                           ! [OK]  
CH-GVA-2.API                       ! [OK]  
AT-VIE-1.Network Load Balancer NLB ! [CRITICAL] 
AT-VIE-1.Object Storage SOS        ! [OK]       
AT-VIE-2                           ! [CRITICAL] 

Upcoming Maintenance                                ! Type      ! Start               ! End      
----------------------------------------------------+-----------+---------------------+----------
Core Network Architecture - Internal routing update ! scheduled ! 2023-09-20 07:00:00 ! open end
```

```bash
./statuspal --url=https://statuspal.io/api/v2/status_pages/ascentlogistics/summary
```

Output:

```text
Major incidents @ Ascent Global Logistics (ascentlogistics.com, TZ America/Detroit): Service PEAK - Customer API  Production seems to be down / According to our monitoring system this service has become unresponsive, we're investigating. (2022-04-20 18:27:16)

Service                               ! State      
--------------------------------------+------------
Ascent Websites.Main Ascent Website   ! [OK]       
PEAK.PEAK - Customer API  Integration ! [CRITICAL] 
PEAK.PEAK - Customer API  Production  ! [CRITICAL] 
Global IT Monitoring                  ! [CRITICAL]
```


## States

* OK if all services are operational.
* WARN if minor incidents or degraded performance are found.
* CRIT if major incidents or emergency maintenance are found.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| cnt_crit | Number | Number of critical events |
| cnt_warn | Number | Number of warning events |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
