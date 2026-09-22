# Check huawei-dorado-lun


## Overview

Checks the health and running status of the LUNs of a Huawei OceanStor Dorado storage system via the REST API (`/lun` endpoint). Alerts when a LUN reports a non-normal state or when a HyperMetro LUN is not mapped to any host, and optionally when a thin LUN fills up. Only LUNs mapped to a host and HyperMetro LUNs are checked by default. Reports the allocated and the configured capacity, the usage of a thin LUN and the storage pool each LUN lives in. Supports extended reporting via `--lengthy`, and reporting the I/O counters via `--performance`.

**Important Notes:**

* Tested on Huawei OceanStor Dorado 8000 V6 6.1.0 and Dorado 6000 V6 V700R001C10SPH128
* Only LUNs mapped to a host are checked, plus HyperMetro LUNs. An unmapped LUN is usually a leftover or a snapshot and is not serving anything; add `--include-unmapped` to cover those as well, and `--unmapped-severity` to decide what they report
* A HyperMetro LUN that is not mapped to any host on this array is checked even without `--include-unmapped` and reports WARN by default (`--unmapped-hypermetro-severity`). Its hosts reach it only through the remote array, so losing that array or the link to it cuts them off. The appliance raises the alarm "The Local Array Has HyperMetro LUNs That Are Not Mapped To The Host" for the same condition
* As soon as an unmapped LUN is listed, the table shows a Mapped column, so an unmapped LUN that alerts says why: `no (HyperMetro)` for the local side of a HyperMetro pair, `no` for any other
* The LUN list is read in pages of 1000 LUNs, and a large array can need tens of seconds per run. `--timeout` defaults to 30 seconds, and the Icinga Director basket raises the command timeout to 180 seconds and runs the check every 15 minutes. Keep the monitoring server's own check timeout above the time a run takes
* The appliance carries a capacity alarm threshold per thin LUN, together with a switch saying whether it is in use. The vendor documents it as the capacity alarm for thin LUNs mounted to Windows Server 2012 hosts (50 to 99%, 90 by default). When the switch is on, the check alerts once a thin LUN reaches it; `--device-threshold-severity` tunes what that reports
* `--lengthy` shows the capacity alarm level the appliance reports for each thin LUN (`CAPACITYALARMLEVEL`, documented as the VASA thin LUN capacity alarm severity: Normal, Warning or Critical). It is shown for information only and never changes the state; `--warning` and `--critical` are the thresholds this check applies. On a Dorado 6000 V6 running V700R001C10SPH128 the appliance reported Warning from 80% and Critical from 90% usage
* A thick LUN has its whole capacity allocated by definition, so it reports no usage and is never checked against the thresholds. Reading its allocation as "100% full" would alert on every thick LUN forever
* The capacity thresholds are off by default. A thin LUN that is full is doing what it was created for; what actually runs out is the pool behind it, which `huawei-dorado-storagepool` watches
* On an array with many LUNs, `--brief` keeps the output readable by listing only the LUNs that alert
* The performance data summarizes the checked LUNs instead of reporting each one, which keeps it small on an array with hundreds of LUNs. Per-LUN detail is in the plugin output table, not in the performance data
* `--performance` is the exception: it costs one extra API request per checked LUN and adds 12 metrics per LUN, so on an array with hundreds of LUNs it multiplies both the run time and the metric count
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
| Compiled for Windows                  | No (runs with Python interpreter) |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-huawei-dorado.db` |


## Help

```text
usage: huawei-dorado-lun [-h] [-V] [--always-ok] [--brief]
                         [--cache-expire CACHE_EXPIRE] [-c CRIT]
                         [--device-id DEVICE_ID]
                         [--device-threshold-severity {ok,warn,crit,unknown}]
                         [--ignore IGNORE] [--include-unmapped] [--insecure]
                         [--lengthy] [--match MATCH] [--no-insecure]
                         [--no-match-severity {ok,warn,crit,unknown}]
                         [--no-perfdata] [--no-proxy] [--password PASSWORD]
                         [--password-file PASSWORD_FILE] [--performance]
                         [--proxy PROXY] [--scope SCOPE] [--timeout TIMEOUT]
                         [--unmapped-hypermetro-severity {ok,warn,crit,unknown}]
                         [--unmapped-severity {ok,warn,crit,unknown}] -u URL
                         --username USERNAME [-v] [-w WARN]

Checks the health and running status of the LUNs of a Huawei OceanStor Dorado
storage system via the REST API (/lun endpoint). Alerts when a LUN reports a
non-normal state or when a HyperMetro LUN is not mapped to any host, and
optionally when a thin LUN fills up. Only LUNs mapped to a host and HyperMetro
LUNs are checked by default. Supports extended reporting via --lengthy, and
reporting the I/O counters via --performance.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --brief               Hide the rows that are within the thresholds and show
                        only those in a WARN or CRIT state. Perfdata and
                        alerting are unaffected: every item still emits
                        performance data and still drives the overall check
                        state, so this is safe to leave on. Worth setting on
                        an array with many LUNs.
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
  --device-threshold-severity {ok,warn,crit,unknown}
                        State to report for a thin LUN that reached the
                        capacity alarm threshold the appliance keeps for it.
                        The vendor documents that threshold as the capacity
                        alarm for thin LUNs mounted to Windows Server 2012
                        hosts (50 to 99 percent, 90 by default), with a
                        separate switch that turns it on. A LUN whose switch
                        is off is not affected. Default: warn
  --ignore IGNORE       Skip LUNs. Any item matching this Python regex will be
                        ignored. Can be specified multiple times. Example:
                        `(?i)linuxfabrik` for a case-insensitive match. The
                        regex is anchored at the start of the string (Python
                        `re.match`) and is matched against the LUN identifier,
                        the LUN name and the name of its storage pool, so
                        prefix with `.*` to match anywhere. Default: None
  --include-unmapped    Also check LUNs that are not mapped to any host. Those
                        are not serving anything, so they are left out by
                        default. HyperMetro LUNs are always checked, see
                        `--unmapped-hypermetro-severity`.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --lengthy             Extended reporting.
  --match MATCH         Limit to LUNs. Filter by this Python regular
                        expression. Case-sensitive by default; use `(?i)` for
                        case-insensitive matching. Can be specified multiple
                        times. If both `--match` and `--ignore` are given, an
                        item must match `--match` AND not match `--ignore` to
                        be reported (include first, exclude second). Examples:
                        `(?i)example` to match "example" regardless of case.
                        `^(?!.*example).*$` to match any string except
                        "example" (negative lookahead). The regex is anchored
                        at the start of the string (Python `re.match`) and is
                        matched against the LUN identifier, the LUN name and
                        the name of its storage pool, so prefix with `.*` to
                        match anywhere. Default: None
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
  --no-proxy            Do not use a proxy, not even one the environment
                        names. Overrides `--proxy`.
  --password PASSWORD   Huawei OceanStor Dorado API password.
  --password-file PASSWORD_FILE
                        Path to a file holding the password, read from its
                        first line. Keeps the password out of the process
                        list, where a command-line argument is visible to
                        every user on the host. Takes precedence over
                        `--password`. Keep the file readable only by the
                        monitoring user. Example: `--password-
                        file=/etc/icinga2/secrets/storage`.
  --performance         Additionally report the I/O counters of every LUN.
                        Costs one API request per object, so a large appliance
                        may need a higher --timeout.
  --proxy PROXY         Proxy to reach the target through. The scheme defaults
                        to `http` when omitted. Overrides the proxy the
                        environment names (`http_proxy`, `https_proxy`,
                        `all_proxy`) together with the exceptions it lists in
                        `no_proxy`, and is itself overridden by `--no-proxy`.
                        Without either parameter the environment applies.
                        Credentials belong into the environment variable
                        rather than here, because a command-line argument is
                        visible to every user on the host. Example:
                        `--proxy=http://proxy.example.com:3128`.
  --scope SCOPE         Huawei OceanStor Dorado API scope.
  --timeout TIMEOUT     Network timeout in seconds. Default: 30 (seconds)
  --unmapped-hypermetro-severity {ok,warn,crit,unknown}
                        State to report for a HyperMetro LUN that is not
                        mapped to any host on this array. Hosts then reach the
                        LUN only through the remote array, so losing that
                        array or the link to it cuts them off, and the
                        appliance raises an alarm for it as well. Such LUNs
                        are checked even without `--include-unmapped`.
                        Default: warn
  --unmapped-severity {ok,warn,crit,unknown}
                        State to report for a LUN that is not mapped to any
                        host. Only takes effect together with `--include-
                        unmapped`, which is what brings those LUNs into the
                        check in the first place. Worth raising on an array
                        where every LUN is meant to be in use, so a LUN that
                        dropped out of its mapping view is noticed. Does not
                        apply to HyperMetro LUNs, see `--unmapped-hypermetro-
                        severity`. Default: ok
  -u, --url URL         Huawei OceanStor Dorado API URL.
  --username USERNAME   Huawei OceanStor Dorado API username.
  -v, --verbose         Makes this plugin verbose during the operation. Useful
                        for debugging and seeing what is going on under the
                        hood. Appends what every API request returned, so the
                        appliance's own answers can be read while working out
                        how it reports something. Session tokens are redacted.
                        The output is as long as those answers are, so this is
                        a debugging aid rather than something to leave
                        switched on.
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

UUID ! Name   ! Pool           ! Allocated ! Capacity ! Usage ! Health     ! Running     ! State
-----+--------+----------------+-----------+----------+-------+------------+-------------+------
11:0 ! LUN001 ! StoragePool001 ! 30.0GiB   ! 100.0GiB ! 30%   ! Normal (1) ! Online (27) ! [OK]
11:1 ! LUN002 ! StoragePool001 ! 10.0GiB   ! 100.0GiB ! 10%   ! Normal (1) ! Online (27) ! [OK]
```

On an array with many LUNs, list only the ones that alert, and watch how full the thin LUNs get:

```bash
./huawei-dorado-lun --url=https://oceanstor:8088 --device-id=123456789 --username=monitoring --password=linuxfabrik --brief --warning=85 --critical=95
```


## States

* OK if all checked LUNs report normal health and are online.
* WARN if a LUN reports a degraded health status, or one this check does not know.
* WARN if a LUN reports health status "Write-protected".
* WARN if a LUN is "Initializing" or "Deleting", or reports a running status this check does not know.
* CRIT if a LUN reports health status "Faulty", "No Input", "Invalid" or "Offline".
* CRIT if a LUN's running status is "Offline".
* WARN or CRIT if a thin LUN's used capacity reaches `--warning` or `--critical`. Both are off by default.
* WARN if a HyperMetro LUN is not mapped to any host on this array. `--unmapped-hypermetro-severity` sets the state.
* With `--include-unmapped`, any other unmapped LUN reports the state set by `--unmapped-severity` (default: OK).
* The capacity alarm level shown with `--lengthy` is never evaluated.
* WARN if the appliance reports more LUNs than the check reads in one run, because the list is then incomplete.
* OK with "No mapped LUNs found." if the array has no mapped LUN, which is unusual but legitimate while an array is being set up.
* UNKNOWN on invalid API responses or responses with error codes.
* `--match` limits the check to the LUNs whose identifier, name or storage pool matches the regex; `--no-match-severity` sets what to report when nothing matches (default: OK).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| allocated_capacity | Bytes | Sum of the capacity actually allocated to the checked LUNs. |
| capacity | Bytes | Sum of the configured capacity of the checked LUNs. |
| luns | Number | Number of LUNs checked, after `--include-unmapped`, `--match` and `--ignore`. |
| luns_not_ok | Number | Number of checked LUNs in a WARN or CRIT state. |
| usage_percent_max | Percentage | Highest used capacity of a checked thin LUN, with the `--warning` and `--critical` thresholds. Not reported if no thin LUN is checked. |

With `--performance`, every checked LUN additionally reports its I/O counters as \<UUID\>\_\<counter\>: `avg_io_response_time`, `avg_read_io_response_time`, `avg_read_io_size`, `avg_write_io_response_time`, `avg_write_io_size`, `block_bandwidth`, `queue_length`, `read_bandwidth`, `read_iops`, `total_iops`, `write_bandwidth` and `write_iops`.

Have a look at the [API documentation](https://support.huawei.com/enterprise/en/doc/EDOC1100144155/387d790e/overview) for details.


## Troubleshooting

### No valuable response from the API

`Got no valuable response from https://...`

Check the `--url`, `--device-id`, `--username` and `--password` parameters. Verify that the API user has query permissions and that the storage system REST API is reachable.

### HyperMetro LUN not mapped to any host

The check reports `no (HyperMetro) [WARNING]` in the Mapped column.

1. Find the LUN in DeviceManager. It is one side of a HyperMetro pair, and the appliance shows the alarm "The Local Array Has HyperMetro LUNs That Are Not Mapped To The Host" for it.
2. Map it to the same hosts on this array as on the remote one. A LUN can be in a LUN group and still be unmapped, when that LUN group is not part of a mapping view. Until it is mapped, those hosts depend on the remote array alone.
3. If the LUN is deliberately left unmapped on this array, exclude it with `--ignore`, or set `--unmapped-hypermetro-severity=ok` for the whole array.

### `This operation fails to be performed because of the unauthorized REST.`

This is a known transient issue with the Huawei REST API. The check makes up to three attempts and forces a fresh login before the second one. If the error persists, verify the API credentials and session timeout settings.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
