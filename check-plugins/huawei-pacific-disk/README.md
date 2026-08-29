# Check huawei-pacific-disk


## Overview

Checks every disk of a Huawei OceanStor Pacific storage system via the REST API (`/data_service/diskpool` and `/cluster/diskpool/queryNodeDiskInfo` endpoints). Alerts when a disk is not healthy, and when its remaining life falls below the warning or critical threshold. Supports extended reporting via `--lengthy`.

**Important Notes:**

* Create a read-only API user that can perform queries only
* Disks are only reachable per disk pool, so the check enumerates the disk pools first and then queries the disks of each one. On a system with many disk pools, raise `--timeout` accordingly
* The disk listing lives below the appliance's older `/dsware/service/` endpoint generation, not below `/api/v2/`
* The remaining life is reported by the appliance in hours, and only by media that wear out. A spinning disk reports zero, which the check shows as "not reported" and leaves out of the threshold comparison instead of treating it as a drive at its end of life
* The vendor does not fill in the `diskModel` field, so the disk model is not available on this API

**Data Collection:**

* Queries the Huawei OceanStor Pacific REST API at `https://<ip>:<port>/api/v2/data_service/diskpool` for the disk pools, then at `https://<ip>:<port>/dsware/service/cluster/diskpool/queryNodeDiskInfo?diskPoolId=<id>` for the disks of each pool
* Authenticates via a session token (`X-Auth-Token`), cached in a SQLite database to avoid repeated logins
* If the appliance rejects a request (for example after a session reset or timeout), the check logs in again and retries


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/huawei-pacific-disk> |
| Nagios/Icinga Check Name              | `check_huawei_pacific_disk` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | No (`--password`, `--url` and `--username` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-huawei-pacific.db` |


## Help

```text
usage: huawei-pacific-disk [-h] [-V] [--always-ok] [--brief]
                           [--cache-expire CACHE_EXPIRE] [-c CRIT]
                           [--ignore IGNORE] [--insecure] [--lengthy]
                           [--match MATCH] [--no-insecure]
                           [--no-match-severity {ok,warn,crit,unknown}]
                           [--no-perfdata] [--no-proxy] [--password PASSWORD]
                           [--password-file PASSWORD_FILE] [--proxy PROXY]
                           [--scope SCOPE] [--timeout TIMEOUT] -u URL
                           --username USERNAME [-v] [-w WARN]

Checks every disk of a Huawei OceanStor Pacific storage system via the REST
API (/data_service/diskpool and /cluster/diskpool/queryNodeDiskInfo
endpoints). Alerts when a disk is not healthy, and when its remaining life
falls below the warning or critical threshold. Supports extended reporting via
--lengthy.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --brief               Hide the rows that are within the thresholds and show
                        only those in a WARN or CRIT state. Perfdata and
                        alerting are unaffected: every item still emits
                        performance data and still drives the overall check
                        state, so this is safe to leave on. Worth setting on a
                        cluster with many disks.
  --cache-expire CACHE_EXPIRE
                        The amount of time after which the credential/data
                        cache expires, in minutes. Default: 15
  -c, --critical CRIT   CRIT threshold for the remaining life of a disk, as a
                        Nagios range in days. Default: 30:
  --ignore IGNORE       Skip disks. Any item matching this Python regex will
                        be ignored. Can be specified multiple times. Example:
                        `(?i)linuxfabrik` for a case-insensitive match. The
                        regex is anchored at the start of the string (Python
                        `re.match`) and is matched against the node name, the
                        disk pool, the serial number and the slot, so prefix
                        with `.*` to match anywhere.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --lengthy             Extended reporting.
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
                        matched against the node name, the disk pool, the
                        serial number and the slot, so prefix with `.*` to
                        match anywhere.
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
  --password PASSWORD   Huawei OceanStor Pacific API password.
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
  --scope SCOPE         Huawei OceanStor Pacific API scope.
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -u, --url URL         Huawei OceanStor Pacific API URL.
  --username USERNAME   Huawei OceanStor Pacific API username.
  -v, --verbose         Makes this plugin verbose during the operation. Useful
                        for debugging and seeing what is going on under the
                        hood. Appends what every API request returned, so the
                        appliance's own answers can be read while working out
                        how it reports something. Session tokens are redacted.
                        The output is as long as those answers are, so this is
                        a debugging aid rather than something to leave
                        switched on.
  -w, --warning WARN    WARN threshold for the remaining life of a disk, as a
                        Nagios range in days. Default: 180:

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/huawei-pacific-disk/
```


## Usage Examples

```bash
./huawei-pacific-disk --url=https://oceanstor:8088 --username=monitoring --password=linuxfabrik --warning=180: --critical=30:
```

Output:

```text
There are critical errors.

Pool  ! Media    ! Status     ! State
------+----------+------------+------
pool0 ! ssd_disk ! normal (0) ! [OK]

Node  ! Pool ! Slot ! Capacity ! Remaining Life ! Status      ! State
------+------+------+----------+----------------+-------------+-----------
FSM01 ! 0    ! 0-1  ! 1.7TiB   ! 10Y 1W         ! healthy (0) ! [OK]
FSM01 ! 0    ! 0-2  ! 1.7TiB   ! 3M 1W          ! healthy (0) ! [WARNING]
FSM01 ! 0    ! 0-3  ! 1.7TiB   ! 2W 6D          ! healthy (0) ! [CRITICAL]
```

`--lengthy` adds the media type, the role the disk plays in its pool and its serial number, which is what an RMA case needs:

```bash
./huawei-pacific-disk --url=https://oceanstor:8088 --username=monitoring --password=linuxfabrik --warning=180: --critical=30: --lengthy
```

Output:

```text
There are critical errors.

Pool  ! Media    ! Status     ! State
------+----------+------------+------
pool0 ! ssd_disk ! normal (0) ! [OK]

Node  ! Pool ! Slot ! Type           ! Role                        ! Serial ! Capacity ! Remaining Life ! Status      ! State
------+------+------+----------------+-----------------------------+--------+----------+----------------+-------------+-----------
FSM01 ! 0    ! 0-1  ! SSD (SSD_DISK) ! main storage (MAIN_STORAGE) ! SN-A1  ! 1.7TiB   ! 10Y 1W         ! healthy (0) ! [OK]
FSM01 ! 0    ! 0-2  ! SSD (SSD_DISK) ! main storage (MAIN_STORAGE) ! SN-A2  ! 1.7TiB   ! 3M 1W          ! healthy (0) ! [WARNING]
FSM01 ! 0    ! 0-3  ! SSD (SSD_DISK) ! main storage (MAIN_STORAGE) ! SN-A3  ! 1.7TiB   ! 2W 6D          ! healthy (0) ! [CRITICAL]
```

The thresholds are Nagios ranges in days, so `180:` means "alert when less than 180 days are left". Set both to `1:` to keep the disk status alerting and switch the remaining-life alerting off in practice.


## States

* OK if every disk reports a healthy status and a remaining life above the warning threshold.
* WARN if a disk reports a sub-healthy status, or if it has been removed from the storage pool.
* WARN if a disk's remaining life falls below `--warning` (default: less than 180 days).
* CRIT if a disk reports a faulty status.
* WARN if a disk pool is write-protected, migrating, degraded or rebuilding, or reports a status this check does not know.
* CRIT if a disk pool is faulty or stopped, even when all of its disks report healthy.
* CRIT if a disk's remaining life falls below `--critical` (default: less than 30 days).
* OK with "No disk pool configured" if the appliance reports no disk pool.
* UNKNOWN on invalid API responses or responses with error codes.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| \<node\>\_\<slot\>\_remaining_life | Seconds | Remaining life of the disk. Only reported for media that wear out. |
| \<node\>\_\<slot\>\_status | Number | Status of the disk. 0: healthy, 1: faulty, 2: sub-healthy, 101: removed from the storage pool. |


## Troubleshooting

### Failed to query the disk pools

`Failed to query the disk pools on https://...`

Check the `--url`, `--username` and `--password` parameters. Verify that the API user has query permissions and that the storage system REST API is reachable.

### A disk shows "not reported" as its remaining life

The appliance only reports a remaining life for media that wear out, in practice SSDs and NVMe drives. A spinning disk answers with zero, which the check does not compare against the thresholds.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
