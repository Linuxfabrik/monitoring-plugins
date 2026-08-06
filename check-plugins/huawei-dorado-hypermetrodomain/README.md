# Check huawei-dorado-hypermetrodomain


## Overview

Checks the running status of all HyperMetro domains on a Huawei OceanStor Dorado storage system via the REST API (`/hypermetrodomain` endpoint). Alerts when any domain reports a non-normal running state. Reports the quorum server name and quorum type per domain.

**Important Notes:**

* Tested on Huawei OceanStor Dorado 8000 V6 6.1.0
* Create a read-only API user that can perform queries only
* The default session timeout period on the storage system is 20 minutes; `--cache-expire` defaults to 15 minutes to stay within that window

**Data Collection:**

* Queries the Huawei OceanStor Dorado REST API at `https://<ip>:<port>/deviceManager/rest/<deviceId>/hypermetrodomain`
* Authenticates via session tokens (iBaseToken + cookie), cached in a SQLite database to avoid repeated logins
* If the appliance rejects a request, the check logs in again and retries, up to three attempts one second apart


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/huawei-dorado-hypermetrodomain> |
| Nagios/Icinga Check Name              | `check_huawei_dorado_hypermetrodomain` |
| Check Interval Recommendation         | Every 15 minutes |
| Can be called without parameters      | No (`--device-id`, `--password`, `--url` and `--username` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-huawei-dorado.db` |


## Help

```text
usage: huawei-dorado-hypermetrodomain [-h] [-V] [--always-ok]
                                      [--cache-expire CACHE_EXPIRE]
                                      --device-id DEVICE_ID [--insecure]
                                      [--no-insecure] [--match MATCH]
                                      [--no-match-severity {ok,warn,crit,unknown}]
                                      [--no-perfdata] [--no-proxy]
                                      --password PASSWORD [--scope SCOPE]
                                      [--timeout TIMEOUT] -u URL
                                      --username USERNAME

Checks the health and running status of all HyperMetro domains on a Huawei
OceanStor Dorado storage system via the REST API (/hypermetrodomain endpoint).
Alerts when any domain reports a non-normal state.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --cache-expire CACHE_EXPIRE
                        The amount of time after which the credential/data
                        cache expires, in minutes. Default: 15
  --device-id DEVICE_ID
                        Huawei OceanStor Dorado API device ID.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-insecure         Verify the TLS certificate against the system trust
                        store, overriding the insecure default of this check.
                        Use it once the endpoint presents a publicly trusted
                        certificate, or once its CA has been added to the
                        system trust store.
  --match MATCH         Filter by HyperMetro domains. Filter by this Python
                        regular expression. Case-sensitive by default; use
                        `(?i)` for case-insensitive matching. Can be specified
                        multiple times. Examples: `(?i)example` to match
                        "example" regardless of case. `^(?!.*example).*$` to
                        match any string except "example" (negative
                        lookahead). The regex is anchored at the start of the
                        string (Python `re.match`) and is matched against
                        `UUID`, `NAME`, so prefix with `.*` to match anywhere.
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

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/huawei-dorado-hypermetrodomain/
```


## Usage Examples

```bash
./huawei-dorado-hypermetrodomain --url https://oceanstor:8088 --device-id 123456789 --username monitoring --password mypass
```

Output:

```text
Everything is ok.

UUID                   ! Name               ! QuorumSrv ! QuorumType    ! Running 
-----------------------+--------------------+-----------+---------------+---------
15362:f4b78d046ec60100 ! HyperMetroDomain01 ! xyz       ! Quorum Server ! [OK]    
15362:8038bc14bd750100 ! test               !           ! None          ! [OK] 
```


## States

* OK if all HyperMetro domains report normal running status.
* WARN if any HyperMetro domain is recovering, split or force started, or reports a running status this check does not know.
* CRIT if any HyperMetro domain is faulty or invalid.
* `--match` limits the check to the HyperMetro domains whose identifier, location or name matches the regex; `--no-match-severity` sets what to report when nothing matches (default: OK).
* UNKNOWN on invalid API responses or responses with error codes.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| \<UUID\>\_running_status | Number | 0: normal, 1: recovering, 2: faulty, 3: split, 4: force started, 5: invalid. A HyperMetro domain numbers these codes from 0 up and does not share the enumeration the other objects on the same appliance use. |

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
