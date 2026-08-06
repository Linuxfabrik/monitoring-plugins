# Check huawei-dorado-enclosure


## Overview

Checks the health and running status of all enclosures (controller enclosures and disk enclosures) on a Huawei OceanStor Dorado storage system via the REST API (`/enclosure` endpoint). Alerts when any enclosure reports a non-normal health or running state. Reports model, serial number, logic type, MAC address, switch status and temperature per enclosure.

**Important Notes:**

* Tested on Huawei OceanStor Dorado 8000 V6 6.1.0
* A part that reports no temperature or no remaining life answers with 0 or -1, which is left out of the check and out of the performance data
* Create a read-only API user that can perform queries only
* The default session timeout period on the storage system is 20 minutes; `--cache-expire` defaults to 15 minutes to stay within that window

**Data Collection:**

* Queries the Huawei OceanStor Dorado REST API at `https://<ip>:<port>/deviceManager/rest/<deviceId>/enclosure`
* Authenticates via session tokens (iBaseToken + cookie), cached in a SQLite database to avoid repeated logins
* If the appliance rejects a request, the check logs in again and retries, up to three attempts one second apart


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/huawei-dorado-enclosure> |
| Nagios/Icinga Check Name              | `check_huawei_dorado_enclosure` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | No (`--device-id`, `--password`, `--url` and `--username` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-huawei-dorado.db` |


## Help

```text
usage: huawei-dorado-enclosure [-h] [-V] [--always-ok]
                               [--cache-expire CACHE_EXPIRE]
                               [--critical-temperature CRIT_TEMPERATURE]
                               --device-id DEVICE_ID [--insecure]
                               [--no-insecure] [--match MATCH]
                               [--no-match-severity {ok,warn,crit,unknown}]
                               [--no-perfdata] [--no-proxy]
                               --password PASSWORD [--scope SCOPE]
                               [--timeout TIMEOUT] -u URL --username USERNAME
                               [--warning-temperature WARN_TEMPERATURE]

Checks the health and running status of all enclosures on a Huawei OceanStor
Dorado storage system via the REST API (/enclosure endpoint). Alerts when any
enclosure reports a non-normal state.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --cache-expire CACHE_EXPIRE
                        The amount of time after which the credential/data
                        cache expires, in minutes. Default: 15
  --critical-temperature CRIT_TEMPERATURE
                        CRIT threshold in degrees Celsius. Off by default,
                        because a healthy operating temperature depends on the
                        enclosure model and on where the array stands.
                        Example: `--critical-temperature=50`
  --device-id DEVICE_ID
                        Huawei OceanStor Dorado API device ID.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-insecure         Verify the TLS certificate against the system trust
                        store, overriding the insecure default of this check.
                        Use it once the endpoint presents a publicly trusted
                        certificate, or once its CA has been added to the
                        system trust store.
  --match MATCH         Filter by enclosures. Filter by this Python regular
                        expression. Case-sensitive by default; use `(?i)` for
                        case-insensitive matching. Can be specified multiple
                        times. Examples: `(?i)example` to match "example"
                        regardless of case. `^(?!.*example).*$` to match any
                        string except "example" (negative lookahead). The
                        regex is anchored at the start of the string (Python
                        `re.match`) and is matched against `UUID`, `LOCATION`,
                        `NAME`, so prefix with `.*` to match anywhere.
                        Default:
  --no-match-severity {ok,warn,crit,unknown}
                        State to report when no item matches the filters and
                        nothing is checked. Default: ok
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --no-proxy            Do not use a proxy.
  --password PASSWORD   Huawei OceanStor Dorado API password.
  --scope SCOPE         Huawei OceanStor Dorado API scope.
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -u, --url URL         Huawei OceanStor Dorado API URL.
  --username USERNAME   Huawei OceanStor Dorado API username.
  --warning-temperature WARN_TEMPERATURE
                        WARN threshold in degrees Celsius. Off by default,
                        because a healthy operating temperature depends on the
                        enclosure model and on where the array stands.
                        Example: `--warning-temperature=40`

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/huawei-dorado-enclosure/
```


## Usage Examples

```bash
./huawei-dorado-enclosure --url https://oceanstor:8088 --device-id 123456789 --username monitoring --password mypass
```

Output:

```text
Everything is ok.

UUID   ! Location ! Name   ! Model                                 ! SerialNumber         ! Logic                                ! MacAddress        ! Switch ! Temp ! Health ! Running 
-------+----------+--------+---------------------------------------+----------------------+--------------------------------------+-------------------+--------+------+--------+---------
206:0  ! 0.1      ! CTE0   ! Unknown                               ! 210235843910E6000009 ! Controller Enclosure                 ! 30:d1:7e:b4:f7:61 ! On     ! 30   ! [OK]   ! [OK]    
206:0  ! --       ! CTE0   ! 4 U 4-controller controller enclosure ! 0815                 ! Controller Enclosure                 ! f4:b7:8d:04:6e:ca ! On     ! 22   ! [OK]   ! [OK]    
206:64 ! --       ! DAE000 ! 2 U 36-slot smart NVMe disk enclosure ! 4711                 ! Expansion Enclosure (Disk Enclosure) ! f4:b4:e1:ab:0f:33 ! On     ! 27   ! [OK]   ! [OK]    
206:65 ! --       ! DAE010 ! 2 U 36-slot smart NVMe disk enclosure ! 4711                 ! Expansion Enclosure (Disk Enclosure) ! f4:b4:e1:7a:13:5d ! On     ! 27   ! [OK]   ! [OK]    
206:66 ! --       ! DAE020 ! 2 U 36-slot smart NVMe disk enclosure ! 4711                 ! Expansion Enclosure (Disk Enclosure) ! f4:b4:e1:ab:14:a5 ! On     ! 28   ! [OK]   ! [OK] 
```


## States

* OK if all enclosures report normal health and running status.
* WARN if any enclosure reports a degraded health status, or one this check does not know.
* WARN if any enclosure's running status is not "Normal", "Running" or "Online", unless it reports an outright failure.
* CRIT if any enclosure reports health status "Faulty", "Invalid" or "Offline".
* CRIT if any enclosure's running status reports a failure ("Offline", "Invalid", "Migration fault", "Error/Faulty", "Power-on failed", "Abnormal" or "Rollback failure").
* WARN or CRIT if an enclosure's temperature reaches `--warning-temperature` or `--critical-temperature`. Both are off by default.
* UNKNOWN if the appliance lists no enclosures at all, which points at the query rather than at the hardware.
* `--match` limits the check to the enclosures whose identifier, location or name matches the regex; `--no-match-severity` sets what to report when nothing matches (default: OK).
* UNKNOWN on invalid API responses or responses with error codes.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| \<UUID\>\_health_status | Number | 0: unknown, 1: normal, 2: faulty. |
| \<UUID\>\_running_status | Number | 0: unknown, 1: normal, 2: running, 5: sleep in high temperature, 27: online, 28: offline, 105: abnormal. |
| \<UUID\>\_switch_status | Number | 1: on, 2: off. |
| \<UUID\>\_temperature | Number | Temperature. |

Have a look at the [API documentation](https://support.huawei.com/enterprise/en/doc/EDOC1100144155/387d790e/overview) for details.


## Troubleshooting

### No valuable response from the API

`Got no valuable response from https://...`

Check the `--url`, `--device-id`, `--username` and `--password` parameters. Verify that the API user has query permissions and that the storage system REST API is reachable.

### `This operation fails to be performed because of the unauthorized REST.`

This is a known transient issue with the Huawei REST API. The check makes up to three attempts and forces a fresh login before the second one. If the error persists, verify the API credentials and session timeout settings.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
