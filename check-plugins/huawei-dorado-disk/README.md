# Check huawei-dorado-disk


## Overview

Checks the health and running status of all disks on a Huawei OceanStor Dorado storage system via the REST API (`/disk` endpoint). Alerts when any disk reports a non-normal health or running state. Reports abrasion rate, capacity usage, runtime, temperature and remaining service life per disk.

**Important Notes:**

* Tested on Huawei OceanStor Dorado 8000 V6 6.1.0
* A spinning disk has no wear-out life to report and answers with 0. Such a disk is left out of the remaining-life check and out of the performance data, instead of being read as a drive at its end
* Create a read-only API user that can perform queries only
* The default session timeout period on the storage system is 20 minutes; `--cache-expire` defaults to 15 minutes to stay within that window

**Data Collection:**

* Queries the Huawei OceanStor Dorado REST API at `https://<ip>:<port>/deviceManager/rest/<deviceId>/disk`
* Authenticates via session tokens (iBaseToken + cookie), cached in a SQLite database to avoid repeated logins
* If the appliance rejects a request, the check logs in again and retries, up to three attempts one second apart


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/huawei-dorado-disk> |
| Nagios/Icinga Check Name              | `check_huawei_dorado_disk` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | No (`--device-id`, `--password`, `--url` and `--username` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-huawei-dorado.db` |


## Help

```text
usage: huawei-dorado-disk [-h] [-V] [--always-ok] [--brief]
                          [--cache-expire CACHE_EXPIRE] [-c CRIT]
                          [--critical-temperature CRIT_TEMPERATURE]
                          [--critical-health-mark CRIT_HEALTH_MARK]
                          [--critical-wear CRIT_WEAR] [--device-id DEVICE_ID]
                          [--ignore IGNORE] [--insecure] [--lengthy]
                          [--no-insecure] [--match MATCH]
                          [--no-match-severity {ok,warn,crit,unknown}]
                          [--no-perfdata] [--no-proxy] [--password PASSWORD]
                          [--password-file PASSWORD_FILE] [--proxy PROXY]
                          [--scope SCOPE]
                          [--unused-disk-severity {ok,warn,crit,unknown}]
                          [--timeout TIMEOUT] -u URL --username USERNAME
                          [-w WARN] [--warning-health-mark WARN_HEALTH_MARK]
                          [--warning-temperature WARN_TEMPERATURE]
                          [--warning-wear WARN_WEAR] [-v]

Checks the health status of all disks on a Huawei OceanStor Dorado storage
system via the REST API (/disk endpoint). Alerts when any disk reports a
non-normal health state or runs out of remaining service life, and optionally
when its health score drops, when it has worn through most of its service
life, or when it is running hot. Supports extended reporting via --lengthy.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --brief               Hide the rows that are within the thresholds and show
                        only those in a WARN or CRIT state. Perfdata and
                        alerting are unaffected: every item still emits
                        performance data and still drives the overall check
                        state, so this is safe to leave on. Worth setting on
                        an array with many disks. Default: False
  --cache-expire CACHE_EXPIRE
                        The amount of time after which the credential/data
                        cache expires, in minutes. Default: 15
  -c, --critical CRIT   CRIT threshold for the remaining life of a disk, as a
                        Nagios range in days. Default: 30:
  --critical-temperature CRIT_TEMPERATURE
                        CRIT threshold in degrees Celsius. Off by default,
                        because a healthy operating temperature depends on the
                        drive model and on where the array stands. Example:
                        `--critical-temperature=50`
  --critical-health-mark CRIT_HEALTH_MARK
                        CRIT threshold for the health score of a disk, as a
                        Nagios range. The appliance scores a disk from 0 to
                        100, where 100 is a disk with nothing wrong with it.
                        Flash media report 255 instead, which is a "not
                        applicable" marker and is never compared. Off by
                        default, so an update cannot start alerting on a fleet
                        nobody has looked at yet. 65: is what field practice
                        suggests. Example: `--critical-health-mark=65:`
  --critical-wear CRIT_WEAR
                        CRIT threshold for the wear of a disk, as a Nagios
                        range in percent of its service life used up. Spinning
                        media report -1 instead and are never compared. Off by
                        default. Example: `--critical-wear=90`
  --device-id DEVICE_ID
                        Huawei OceanStor Dorado API device ID. Optional: the
                        appliance reports its own at login, so this is only
                        needed to override that answer.
  --ignore IGNORE       Skip disks. Any item matching this Python regex will
                        be ignored. Can be specified multiple times. Example:
                        `(?i)linuxfabrik` for a case-insensitive match. The
                        regex is anchored at the start of the string (Python
                        `re.match`) and is matched against `UUID`, `LOCATION`,
                        so prefix with `.*` to match anywhere.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --lengthy             Extended reporting.
  --no-insecure         Verify the TLS certificate against the system trust
                        store, overriding the insecure default of this check.
                        Use it once the endpoint presents a publicly trusted
                        certificate, or once its CA has been added to the
                        system trust store.
  --match MATCH         Limit to disks. Filter by this Python regular
                        expression. Case-sensitive by default; use `(?i)` for
                        case-insensitive matching. Can be specified multiple
                        times. If both `--match` and `--ignore` are given, an
                        item must match `--match` AND not match `--ignore` to
                        be reported (include first, exclude second). Examples:
                        `(?i)example` to match "example" regardless of case.
                        `^(?!.*example).*$` to match any string except
                        "example" (negative lookahead). The regex is anchored
                        at the start of the string (Python `re.match`) and is
                        matched against `UUID`, `LOCATION`, so prefix with
                        `.*` to match anywhere.
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
  --unused-disk-severity {ok,warn,crit,unknown}
                        State to report for a disk that sits in the chassis
                        without belonging to a pool. Worth raising on an array
                        where every disk is meant to be in use, so a disk that
                        silently dropped out of its pool is noticed. Default:
                        ok
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -u, --url URL         Huawei OceanStor Dorado API URL.
  --username USERNAME   Huawei OceanStor Dorado API username.
  -w, --warning WARN    WARN threshold for the remaining life of a disk, as a
                        Nagios range in days. Default: 180:
  --warning-health-mark WARN_HEALTH_MARK
                        WARN threshold for the health score of a disk, as a
                        Nagios range. The appliance scores a disk from 0 to
                        100, where 100 is a disk with nothing wrong with it.
                        Flash media report 255 instead, which is a "not
                        applicable" marker and is never compared. Off by
                        default, so an update cannot start alerting on a fleet
                        nobody has looked at yet. 75: is what field practice
                        suggests. Example: `--warning-health-mark=75:`
  --warning-temperature WARN_TEMPERATURE
                        WARN threshold in degrees Celsius. Off by default,
                        because a healthy operating temperature depends on the
                        drive model and on where the array stands. Example:
                        `--warning-temperature=45`
  --warning-wear WARN_WEAR
                        WARN threshold for the wear of a disk, as a Nagios
                        range in percent of its service life used up. Spinning
                        media report -1 instead and are never compared. Off by
                        default. Example: `--warning-wear=80`
  -v, --verbose         Makes this plugin verbose during the operation. Useful
                        for debugging and seeing what is going on under the
                        hood. Appends what every API request returned, so the
                        appliance's own answers can be read while working out
                        how it reports something. Session tokens are redacted.
                        The output is as long as those answers are, so this is
                        a debugging aid rather than something to leave
                        switched on.

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/huawei-dorado-disk/
```


## Usage Examples

```bash
./huawei-dorado-disk --url=https://oceanstor:8088 --device-id=123456789 --username=monitoring --password=linuxfabrik
```

Output:

```text
Everything is ok.

UUID         ! Location ! Usage  ! Wear% ! Temp ! Health     ! Running     ! State
-------------+----------+--------+-------+------+------------+-------------+------
10:134234112 ! DAE000.0 ! in use ! 67    ! 36   ! Normal (1) ! Online (27) ! [OK]
10:134234113 ! DAE000.1 ! in use ! 70    ! 37   ! Normal (1) ! Online (27) ! [OK]
10:0         ! CTE0.0   ! free   ! 0     ! 37   ! Normal (1) ! Online (27) ! [OK]
```

`--lengthy` adds the model, the serial number and the rebuild progress, which is what an RMA case and a running rebuild need:

```bash
./huawei-dorado-disk --url=https://oceanstor:8088 --device-id=123456789 --username=monitoring --password=linuxfabrik --lengthy
```

Output:

```text
Everything is ok.

UUID         ! Location ! Manufacturer ! Model            ! SerialNumber         ! Usage  ! Wear% ! Progress% ! Runtime ! Temp ! Health     ! Running     ! State
-------------+----------+--------------+------------------+----------------------+--------+-------+-----------+---------+------+------------+-------------+------
10:134234112 ! DAE000.0 ! HUAWEI       ! HSSD-D7294DL7T6E ! 12345678             ! in use ! 67    ! 0         ! 4M 2W   ! 36   ! Normal (1) ! Online (27) ! [OK]
10:134234113 ! DAE000.1 ! HUAWEI       ! HSSD-D7294DL7T6E ! 12345679             ! in use ! 70    ! 0         ! 4M 2W   ! 37   ! Normal (1) ! Online (27) ! [OK]
10:0         ! CTE0.0   ! Seagate      ! ST2000NM0023     ! Z1X2F480000094381WYN ! free   ! 0     ! 0         ! 1Y 4M   ! 37   ! Normal (1) ! Online (27) ! [OK]
```


## States

* OK if all disks report normal health and running status.
* WARN if any disk reports a degraded health status, or one this check does not know.
* WARN if any disk's running status is not "Normal" or "Online", unless it reports an outright failure.
* CRIT if any disk reports health status "Faulty", "No Input", "Invalid" or "Offline".
* CRIT if any disk's running status reports a failure ("Not running", "Sleep in High Temperature", "Offline", "Invalid", "Migration fault", "Error/Faulty", "To be synchronized", "Power-on failed", "Abnormal" or "Rollback failure").
* WARN or CRIT if a disk's health score reaches `--warning-health-mark` or `--critical-health-mark`. Both are off by default, so an update cannot start alerting on a fleet nobody has looked at yet; `75:` and `65:` are what field practice suggests. Flash media report 255 instead of a score and are never compared.
* WARN or CRIT if a disk's wear reaches `--warning-wear` or `--critical-wear`. Both are off by default. Spinning media report -1 instead of a wear level and are never compared.
* `--unused-disk-severity` decides what a disk that belongs to no pool reports (default: OK). Worth raising on an array where every disk is meant to be in use, so a disk that dropped out of its pool is noticed.
* WARN if a disk's remaining life falls below `--warning` (default: less than 180 days).
* CRIT if a disk's remaining life falls below `--critical` (default: less than 30 days).
* WARN or CRIT if a disk's temperature reaches `--warning-temperature` or `--critical-temperature`. Both are off by default.
* UNKNOWN if the appliance lists no disks at all, which points at the query rather than at the hardware.
* `--match` limits the check to the disks whose identifier, location or name matches the regex; `--no-match-severity` sets what to report when nothing matches (default: OK).
* UNKNOWN on invalid API responses or responses with error codes.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| \<UUID\>\_abrasion_rate | Percentage | Wear rate (percentage of used service life to total service life). |
| \<UUID\>\_capacity_usage | Percentage | Capacity usage. |
| \<UUID\>\_health_mark | Number | Health score of the disk. |
| \<UUID\>\_health_status | Number | 0: unknown, 1: normal, 2: faulty, 3: about to fail, 17: single link. |
| \<UUID\>\_progress | Percentage | Progress of reconstruction, copyback, pre-copy, or destruction. |
| \<UUID\>\_remaining_life | Seconds | Remaining service life. |
| \<UUID\>\_running_status | Number | 0: unknown, 1: normal, 14: pre-copy, 16: reconstruction, 27: online, 28: offline, 114: erasing, 115: verifying. |
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
