# Check huawei-pacific-storagepool

## Overview

Checks the status and capacity usage of all storage pools on a Huawei OceanStor Pacific storage system via the REST API (`/data_service/storagepool` endpoint). Alerts when a pool reports a non-normal status and when its used capacity reaches the warning or critical threshold. Supports extended reporting via `--lengthy`.

**Important Notes:**

* Create a read-only API user that can perform queries only
* The default thresholds of 92 and 95 percent are chosen for a pool measured in petabytes, where the usual 80/90 would alert with hundreds of terabytes still free. On a small pool, lower them
* The fill level is the one the appliance calculates itself, so the check and the management GUI agree on how full a pool is
* A pool that is migrating or reconstructing data warns rather than alerts: it still serves I/O, and it works itself out of that state. Only a pool that is faulty, stopped, or faulty and write-protected is critical
* The credential/session token is cached in a local SQLite database between runs; `--cache-expire` controls how long it is reused before a fresh login

**Data Collection:**

* Queries the Huawei OceanStor Pacific REST API at `https://<ip>:<port>/api/v2/`
* Reads every storage pool of the cluster in a single request (`/data_service/storagepool`)
* Authenticates via a session token (`X-Auth-Token`), cached in a SQLite database to avoid repeated logins
* If the appliance rejects a request (for example after a session reset or timeout), the check logs in again and retries
* Pools can be limited with `--match` and excluded with `--ignore` (Python regular expressions, anchored at the start of the pool identifier and the pool name)


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/huawei-pacific-storagepool> |
| Nagios/Icinga Check Name              | `check_huawei_pacific_storagepool` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | No (`--password`, `--url` and `--username` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-huawei-pacific.db` |


## Help

```text
usage: huawei-pacific-storagepool [-h] [-V] [--always-ok]
                                  [--cache-expire CACHE_EXPIRE] [-c CRIT]
                                  [--ignore IGNORE] [--insecure] [--lengthy]
                                  [--match MATCH] [--no-insecure]
                                  [--no-match-severity {ok,warn,crit,unknown}]
                                  [--no-perfdata] [--no-proxy]
                                  [--password PASSWORD]
                                  [--password-file PASSWORD_FILE]
                                  [--proxy PROXY] [--scope SCOPE]
                                  [--timeout TIMEOUT] -u URL
                                  --username USERNAME [-v] [-w WARN]

Checks the status and capacity usage of all storage pools on a Huawei
OceanStor Pacific storage system via the REST API (/data_service/storagepool
endpoint). Alerts when a pool reports a non-normal status and when its used
capacity reaches the warning or critical threshold. Supports extended
reporting via --lengthy.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --cache-expire CACHE_EXPIRE
                        The amount of time after which the credential/data
                        cache expires, in minutes. Default: 15
  -c, --critical CRIT   CRIT threshold for the used capacity of a pool, as a
                        Nagios range in percent. Default: 95
  --ignore IGNORE       Skip storage pools. Any item matching this Python
                        regex will be ignored. Can be specified multiple
                        times. Example: `(?i)linuxfabrik` for a case-
                        insensitive match. The regex is anchored at the start
                        of the string (Python `re.match`) and is matched
                        against the pool identifier and the pool name, so
                        prefix with `.*` to match anywhere. Default: None
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --lengthy             Extended reporting.
  --match MATCH         Limit to storage pools. Filter by this Python regular
                        expression. Case-sensitive by default; use `(?i)` for
                        case-insensitive matching. Can be specified multiple
                        times. If both `--match` and `--ignore` are given, an
                        item must match `--match` AND not match `--ignore` to
                        be reported (include first, exclude second). Examples:
                        `(?i)example` to match "example" regardless of case.
                        `^(?!.*example).*$` to match any string except
                        "example" (negative lookahead). The regex is anchored
                        at the start of the string (Python `re.match`) and is
                        matched against the pool identifier and the pool name,
                        so prefix with `.*` to match anywhere. Default: None
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
  -w, --warning WARN    WARN threshold for the used capacity of a pool, as a
                        Nagios range in percent. Default: 92

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/huawei-pacific-storagepool/
```


## Usage Examples

```bash
./huawei-pacific-storagepool --username=icinga --password=linuxfabrik --url=https://storage.example.com:8088
```

Output:

```text
Everything is ok. (warn=92 crit=95) Checked 2 storage pools.

Name  ! Used     ! Total    ! Usage ! Status     ! State
------+----------+----------+-------+------------+------
pool0 ! 71.4TiB  ! 5.0PiB   ! 1%    ! normal (0) ! [OK]
pool1 ! 256.0GiB ! 512.0GiB ! 50%   ! normal (0) ! [OK]
```

With `--lengthy`, every pool additionally reports its identifier, its free capacity, how much its data reduction saves, how it is protected and against what, and, while a rebuild is running, how far along it is:

```bash
./huawei-pacific-storagepool --username=icinga --password=linuxfabrik --url=https://storage.example.com:8088 --lengthy
```

Output:

```text
There are critical errors. (warn=92 crit=95) Checked 2 storage pools.

ID ! Name  ! Used     ! Free     ! Total    ! Usage ! Reduction ! Redundancy                            ! Security Level ! Rebuild ! Status              ! State
---+-------+----------+----------+----------+-------+-----------+---------------------------------------+----------------+---------+---------------------+-----------
0  ! pool0 ! 71.4TiB  ! 4.9PiB   ! 5.0PiB   ! 1%    ! 1.0:1     ! EC, 4 parity, 4 node failures allowed ! node level     ! --      ! faulty (1)          ! [CRITICAL]
1  ! pool1 ! 256.0GiB ! 256.0GiB ! 512.0GiB ! 50%   ! 3.2:1     ! replication                           ! cabinet level  ! 42%     ! rebuilding data (8) ! [WARNING]
```


## States

* OK if every checked pool reports status `normal (0)` and its used capacity is below the warning threshold.
* WARN if any checked pool is write-protected, is migrating data, is degraded or is rebuilding data. Such a pool still serves I/O.
* WARN if the used capacity of any checked pool is at or above `--warning` (default: 92).
* WARN if a pool reports a status code the vendor's enumeration does not list, or none at all.
* CRIT if any checked pool is faulty, stopped, or faulty and write-protected.
* CRIT if the used capacity of any checked pool is at or above `--critical` (default: 95).
* The worst state of all checked pools becomes the state of the check.
* OK with "No storage pools matched" if `--match` or `--ignore` excluded every pool. Use `--no-match-severity` to report WARN, CRIT or UNKNOWN instead.
* UNKNOWN if the appliance lists no storage pool at all. A cluster that serves storage has at least one, so an empty list is a query that never reached them.
* UNKNOWN on invalid API responses or responses with error codes, and on an invalid `--match` or `--ignore` pattern.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

One set of metrics per checked pool, prefixed with the pool name in snake_case.

| Name | Type | Description |
|----|----|----|
| &lt;pool&gt;_data_reduction_ratio | Number | Data reduction ratio of the pool, deduplication and compression combined. `1.0` means nothing was saved. |
| &lt;pool&gt;_free_capacity | Bytes | Capacity of the pool that is not used. |
| &lt;pool&gt;_reconstruction_progress | Percentage | How far the appliance has got rebuilding the pool's redundancy. `100` while there is nothing to rebuild. |
| &lt;pool&gt;_status | Number | Storage pool status code: 0 normal, 1 faulty, 2 write-protected, 3 stopped, 4 faulty and write-protected, 5 migrating data, 7 degraded, 8 reconstructing data. |
| &lt;pool&gt;_total_capacity | Bytes | Total capacity of the pool. |
| &lt;pool&gt;_usage_percent | Percentage | Used capacity of the pool in percent of its total capacity. |
| &lt;pool&gt;_used_capacity | Bytes | Used capacity of the pool. |


## Troubleshooting

### No valuable response from the API

`Got no valuable response from https://...`

Check the `--url`, `--username` and `--password` parameters. Verify that the API user has query permissions and that the storage system REST API is reachable.

### The appliance reports no storage pools

`https://... reported no storage pools. Verify that the API user is allowed to query them.`

The appliance answered the request and listed nothing. A cluster that serves storage always has at least one pool, so this is a permission problem far more often than an empty cluster. Log in to DeviceManager with the same account and open the storage pool list: if it is empty there as well, the account is missing the query permission for the pool layer.

### A pool sits at WARNING and nothing looks wrong

Read the `Status` column. `migrating data (5)`, `degraded (7)` and `rebuilding data (8)` all mean the pool is busy restoring its own redundancy, which is a state it works itself out of. Run the check with `--lengthy` to see the `Rebuild` column, which says how far along it is, and give it time. A pool that stays in one of these states for days is worth a support case, because it usually means the rebuild cannot finish for lack of free capacity or a spare node.

### A pool is over the threshold and cannot be emptied

The defaults of 92 and 95 percent are chosen for a petabyte-class pool. On a small pool they leave far too little runway, so lower them per service. When the pool really is filling up, the only two answers are deleting data or adding nodes, and both take longer than a check interval: raise the thresholds deliberately with `--warning` and `--critical` while the hardware is on order, rather than acknowledging the alert away.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
