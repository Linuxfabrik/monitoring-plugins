# Check huawei-dorado-lun


## Overview

Checks the health and running status of the LUNs of a Huawei OceanStor Dorado storage system via the REST API (`/lun` endpoint). Alerts when a LUN reports a non-normal state, and optionally when a thin LUN fills up. Reports the allocated and the configured capacity, the usage of a thin LUN and the storage pool each LUN lives in.

**Important Notes:**

* Tested on Huawei OceanStor Dorado 8000 V6 6.1.0
* Only LUNs mapped to a host are checked. An unmapped LUN is not serving anything; add `--include-unmapped` to cover those as well
* A thick LUN has its whole capacity allocated by definition, so it reports no usage and is never checked against the thresholds. Reading its allocation as "100% full" would alert on every thick LUN forever
* The capacity thresholds are off by default. A thin LUN that is full is doing what it was created for; what actually runs out is the pool behind it, which `huawei-dorado-storagepool` watches
* On an array with many LUNs, `--brief` keeps the output readable by listing only the LUNs that alert
* The API counts every capacity in 512-byte sectors. The per-LUN `SECTORSIZE` field is the block size the LUN exposes to the host and is a different thing
* Create a read-only API user that can perform queries only
* The default session timeout period on the storage system is 20 minutes; `--cache-expire` defaults to 15 minutes to stay within that window

**Data Collection:**

* Queries the Huawei OceanStor Dorado REST API at `https://<ip>:<port>/deviceManager/rest/<deviceId>/lun`
* Walks the LUN list page by page, so an array with thousands of LUNs is covered completely
* Authenticates via session tokens (iBaseToken + cookie), cached in a SQLite database to avoid repeated logins
* If the appliance rejects a request, the check logs in again and retries, up to three attempts one second apart


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/huawei-dorado-lun> |
| Nagios/Icinga Check Name              | `check_huawei_dorado_lun` |
| Check Interval Recommendation         | Every 15 minutes |
| Can be called without parameters      | No (`--device-id`, `--password`, `--url` and `--username` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-huawei-dorado.db` |


## Help

```text
usage: huawei-dorado-lun [-h] [-V] [--always-ok] [--brief]
                         [--cache-expire CACHE_EXPIRE] [-c CRIT]
                         [--device-id DEVICE_ID] [--include-unmapped]
                         [--ignore IGNORE] [--insecure] [--lengthy]
                         [--match MATCH] [--no-insecure]
                         [--no-match-severity {ok,warn,crit,unknown}]
                         [--no-perfdata] [--no-proxy] [--performance]
                         [--password PASSWORD] [--password-file PASSWORD_FILE]
                         [--scope SCOPE] [--timeout TIMEOUT] -u URL
                         --username USERNAME [-w WARN]

Checks the health and running status of the LUNs of a Huawei OceanStor Dorado
storage system via the REST API (/lun endpoint). Alerts when a LUN reports a
non-normal state, and optionally when a thin LUN fills up. Only LUNs mapped to
a host are checked by default. Supports reporting the I/O counters via
--performance.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --brief               Hide table rows for LUNs that are ok and show only
                        those in WARN/CRIT state. Perfdata and alerting are
                        unaffected. Worth setting on an array with many LUNs.
                        Default: False
  --cache-expire CACHE_EXPIRE
                        The amount of time after which the credential/data
                        cache expires, in minutes. Default: 15
  -c, --critical CRIT   CRIT threshold for the used capacity of a thin LUN, as
                        a Nagios range in percent. Off by default, because a
                        thin LUN that is full is doing what it was created
                        for; what runs out is the pool behind it. Example:
                        `--critical=95`
  --device-id DEVICE_ID
                        Huawei OceanStor Dorado API device ID. Optional: the
                        appliance reports its own at login, so this is only
                        needed to override that answer.
  --include-unmapped    Also check LUNs that are not mapped to any host. Those
                        are not serving anything, so they are left out by
                        default. Default: False
  --ignore IGNORE       Skip LUNs. Any item matching this Python regex will be
                        ignored. Can be specified multiple times. Example:
                        `(?i)linuxfabrik` for a case-insensitive match. The
                        regex is anchored at the start of the string (Python
                        `re.match`) and is matched against the LUN identifier,
                        the LUN name and the name of its storage pool, so
                        prefix with `.*` to match anywhere. Default: None
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --lengthy             Extended reporting.
  --match MATCH         Filter by LUNs. Filter by this Python regular
                        expression. Case-sensitive by default; use `(?i)` for
                        case-insensitive matching. Can be specified multiple
                        times. Examples: `(?i)example` to match "example"
                        regardless of case. `^(?!.*example).*$` to match any
                        string except "example" (negative lookahead). The
                        regex is anchored at the start of the string (Python
                        `re.match`) and is matched against the LUN identifier,
                        the LUN name and the name of its storage pool, so
                        prefix with `.*` to match anywhere. Default: None
  --no-insecure         Verify the TLS certificate against the system trust
                        store, overriding the insecure default of this check.
                        Use it once the endpoint presents a publicly trusted
                        certificate, or once its CA has been added to the
                        system trust store.
  --no-match-severity {ok,warn,crit,unknown}
                        State to report when no item matches the filters and
                        nothing is checked. Default: ok
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --no-proxy            Do not use a proxy.
  --performance         Additionally report the I/O counters of every LUN.
                        Costs one API request per object, so a large appliance
                        may need a higher --timeout.
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
  -u, --url URL         Huawei OceanStor Dorado API URL.
  --username USERNAME   Huawei OceanStor Dorado API username.
  -w, --warning WARN    WARN threshold for the used capacity of a thin LUN, as
                        a Nagios range in percent. Off by default, because a
                        thin LUN that is full is doing what it was created
                        for; what runs out is the pool behind it. Example:
                        `--warning=85`

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/huawei-dorado-lun/
```


## Usage Examples

```bash
./huawei-dorado-lun --url=https://oceanstor:8088 --device-id=123456789 --username=monitoring --password=linuxfabrik
```

Output:

```text
Everything is ok. Checked 2 LUNs.

UUID ! Name   ! Pool           ! Allocated ! Capacity ! Usage ! Health ! Running
-----+--------+----------------+-----------+----------+-------+--------+--------
11:0 ! LUN001 ! StoragePool001 ! 30.0GiB   ! 100.0GiB ! 30%   ! [OK]   ! [OK]
11:1 ! LUN002 ! StoragePool001 ! 10.0GiB   ! 100.0GiB ! 10%   ! [OK]   ! [OK]
```

On an array with many LUNs, list only the ones that alert, and watch how full the thin LUNs get:

```bash
./huawei-dorado-lun --url=https://oceanstor:8088 --device-id=123456789 --username=monitoring --password=linuxfabrik --brief --warning=85 --critical=95
```


## States

* OK if all checked LUNs report normal health and are online.
* WARN if a LUN reports a degraded health status, or one this check does not know.
* WARN if a LUN's running status is one this check does not know.
* CRIT if a LUN reports health status "Faulty", "Invalid" or "Offline".
* CRIT if a LUN's running status is "Offline".
* WARN or CRIT if a thin LUN's used capacity reaches `--warning` or `--critical`. Both are off by default.
* WARN if the appliance reports more LUNs than the check reads in one run, because the list is then incomplete.
* OK with "No mapped LUNs found." if the array has no mapped LUN, which is unusual but legitimate while an array is being set up.
* UNKNOWN on invalid API responses or responses with error codes.
* `--match` limits the check to the LUNs whose identifier, name or storage pool matches the regex; `--no-match-severity` sets what to report when nothing matches (default: OK).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| \<UUID\>\_allocated_capacity | Bytes | Capacity actually allocated to the LUN. |
| \<UUID\>\_capacity | Bytes | Configured capacity of the LUN. |
| \<UUID\>\_health_status | Number | 1: normal, 2: faulty. |
| \<UUID\>\_running_status | Number | 27: online, 28: offline. |
| \<UUID\>\_usage_percent | Percentage | Used capacity of a thin LUN. Not reported for a thick LUN. |

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
