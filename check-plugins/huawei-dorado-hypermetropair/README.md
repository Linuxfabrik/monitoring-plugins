# Check huawei-dorado-hypermetropair


## Overview

Checks the health, running status, and synchronization state of all HyperMetro pairs on a Huawei OceanStor Dorado storage system via the REST API (`/hypermetropair` endpoint). Alerts when any pair reports a non-normal state or synchronization issue. Reports link status, last sync time, sync duration, sync progress, local/remote data consistency and host access state per pair.

**Important Notes:**

* Tested on Huawei OceanStor Dorado 8000 V6 6.1.0
* Create a read-only API user that can perform queries only
* The default session timeout period on the storage system is 20 minutes; `--cache-expire` defaults to 15 minutes to stay within that window

**Data Collection:**

* Queries the Huawei OceanStor Dorado REST API at `https://<ip>:<port>/deviceManager/rest/<deviceId>/hypermetropair`
* Authenticates via session tokens (iBaseToken + cookie), cached in a SQLite database to avoid repeated logins
* If the appliance rejects a request, the check logs in again and retries, up to three attempts one second apart


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/huawei-dorado-hypermetropair> |
| Nagios/Icinga Check Name              | `check_huawei_dorado_hypermetropair` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | No (`--device-id`, `--password`, `--url` and `--username` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-huawei-dorado.db` |


## Help

```text
usage: huawei-dorado-hypermetropair [-h] [-V] [--always-ok] [--brief]
                                    [--cache-expire CACHE_EXPIRE]
                                    [--device-id DEVICE_ID] [--ignore IGNORE]
                                    [--insecure] [--no-insecure]
                                    [--match MATCH]
                                    [--no-match-severity {ok,warn,crit,unknown}]
                                    [--no-perfdata] [--no-proxy]
                                    [--password PASSWORD]
                                    [--password-file PASSWORD_FILE]
                                    [--scope SCOPE] [--timeout TIMEOUT] -u URL
                                    --username USERNAME [-v]

Checks the health and running status of all HyperMetro pairs on a Huawei
OceanStor Dorado storage system via the REST API (/hypermetropair endpoint).
Alerts when any pair reports a non-normal state or synchronization issue.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --brief               Hide the rows that are within the thresholds and show
                        only those in a WARN or CRIT state. Perfdata and
                        alerting are unaffected: every item still emits
                        performance data and still drives the overall check
                        state, so this is safe to leave on. Worth setting on
                        an array with many HyperMetro pairs. Default: False
  --cache-expire CACHE_EXPIRE
                        The amount of time after which the credential/data
                        cache expires, in minutes. Default: 15
  --device-id DEVICE_ID
                        Huawei OceanStor Dorado API device ID. Optional: the
                        appliance reports its own at login, so this is only
                        needed to override that answer.
  --ignore IGNORE       Skip HyperMetro pairs. Any item matching this Python
                        regex will be ignored. Can be specified multiple
                        times. Example: `(?i)linuxfabrik` for a case-
                        insensitive match. The regex is anchored at the start
                        of the string (Python `re.match`) and is matched
                        against `UUID`, `LOCALOBJNAME`, `REMOTEOBJNAME`, so
                        prefix with `.*` to match anywhere.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-insecure         Verify the TLS certificate against the system trust
                        store, overriding the insecure default of this check.
                        Use it once the endpoint presents a publicly trusted
                        certificate, or once its CA has been added to the
                        system trust store.
  --match MATCH         Filter by HyperMetro pairs. Filter by this Python
                        regular expression. Case-sensitive by default; use
                        `(?i)` for case-insensitive matching. Can be specified
                        multiple times. Examples: `(?i)example` to match
                        "example" regardless of case. `^(?!.*example).*$` to
                        match any string except "example" (negative
                        lookahead). The regex is anchored at the start of the
                        string (Python `re.match`) and is matched against
                        `UUID`, `LOCALOBJNAME`, `REMOTEOBJNAME`, so prefix
                        with `.*` to match anywhere.
  --no-match-severity {ok,warn,crit,unknown}
                        State to report when no item matches the filters and
                        nothing is checked. Default: ok
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --no-proxy            Do not use a proxy.
  --password PASSWORD   Huawei OceanStor Dorado API password. Password.
  --password-file PASSWORD_FILE
                        Path to a file holding the password, read from its
                        first line. Keeps the password out of the process
                        list, where a command-line argument is visible to
                        every user on the host. Takes precedence over
                        `--password`. Keep the file readable only by the
                        monitoring user. Example: `--password-
                        file=/etc/icinga2/secrets/storage`.
  --scope SCOPE         Huawei OceanStor Dorado API scope.
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -u, --url URL         Huawei OceanStor Dorado API URL. URL to the endpoint.
  --username USERNAME   Huawei OceanStor Dorado API username. Username.
  -v, --verbose         Makes this plugin verbose during the operation. Useful
                        for debugging and seeing what is going on under the
                        hood. Appends what every API request returned, so the
                        appliance's own answers can be read while working out
                        how it reports something. Session tokens are redacted.
                        The output is as long as those answers are, so this is
                        a debugging aid rather than something to leave
                        switched on.

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/huawei-dorado-hypermetropair/
```


## Usage Examples

```bash
./huawei-dorado-hypermetropair --url=https://oceanstor:8088 --device-id=123456789 --username=monitoring --password=linuxfabrik
```

Output:

```text
Everything is ok.

UUID                                   ! Link ! Last Sync                       ! Duration ! Progr (%) ! LocalJob  ! DataState ! Access ! RemoteJob ! DataState ! Access ! Health ! Running 
---------------------------------------+------+---------------------------------+----------+-----------+-----------+-----------+--------+-----------+-----------+--------+--------+---------
15361:2100f4b78d046ec60000000000000000 ! [OK] ! 2021-08-18 10:39:47 (3M 6D ago) ! 2m 1s    ! 100       ! LUN01-BLH ! [OK]      ! R/W    ! LUN01-COL ! [OK]      ! R/W    ! [OK]   ! [OK]    
15361:2100f4b78d046ec60000000000000001 ! [OK] ! 2021-08-18 10:39:50 (3M 6D ago) ! 2m 3s    ! 100       ! LUN02-BLH ! [OK]      ! R/W    ! LUN02-COL ! [OK]      ! R/W    ! [OK]   ! [OK]    
15361:2100f4b78d046ec60000000000000002 ! [OK] ! 2021-08-18 10:38:29 (3M 6D ago) ! 42s      ! 100       ! LUN03-BLH ! [OK]      ! R/W    ! LUN03-COL ! [OK]      ! R/W    ! [OK]   ! [OK]    
```


## States

* OK if all HyperMetro pairs report normal health, running status, link status and data consistency.
* WARN if any pair reports a degraded health status, or one this check does not know.
* WARN if any pair's running status is not "Normal" or "Synchronizing", unless it reports an outright failure.
* CRIT if any pair reports health status "Faulty", "No Input", "Invalid" or "Offline".
* CRIT if any pair's running status reports a failure ("Not running", "Sleep in High Temperature", "Offline", "Invalid", "Migration fault", "Error/Faulty", "To be synchronized", "Power-on failed", "Abnormal" or "Rollback failure").
* WARN if any pair's link status is not "connected".
* WARN if any pair's local data state is not "consistent".
* WARN if any pair's remote data state is not "consistent".
* `--match` limits the check to the HyperMetro pairs whose identifier, location or name matches the regex; `--no-match-severity` sets what to report when nothing matches (default: OK).
* UNKNOWN on invalid API responses or responses with error codes.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| \<UUID\>\_health_status | Number | 0: unknown, 1: normal, 2: faulty. |
| \<UUID\>\_link_status | Number | 1: connected, 2: disconnected. |
| \<UUID\>\_local_data_state | Number | 1: consistent, 2: inconsistent. |
| \<UUID\>\_local_host_access_state | Number | 1: access forbidden, 2: read-only, 3: read/write. |
| \<UUID\>\_remote_data_state | Number | 1: consistent, 2: inconsistent. |
| \<UUID\>\_remote_host_access_state | Number | 1: access forbidden, 2: read-only, 3: read/write, 5: unknown. |
| \<UUID\>\_running_status | Number | 1: normal, 23: synchronizing, 35: invalid, 41: paused, 93: forcibly started, 100: to be synchronized. |
| \<UUID\>\_sync_progress | Percentage | Synchronization progress. |

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
