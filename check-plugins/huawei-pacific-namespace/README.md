# Check huawei-pacific-namespace

## Overview

Checks the namespaces of a Huawei OceanStor Pacific storage system via the REST API (`/converged_service/namespaces` endpoint). Alerts when a namespace cannot be reached, when it turned read-only, and when it reports a running status other than normal. Reports the space and the number of files every namespace uses. Supports extended reporting via `--lengthy`.

**Important Notes:**

* Create a read-only API user that can perform queries only
* **This check does not alert on how full a namespace is.** Most namespaces have no size of their own to fill up. Where one does, the limit is a quota (`space_hard_quota`, and the appliance gives the namespace a `quota_id` alongside it), and `huawei-pacific-quota` is the check that watches those, for namespaces and dtrees alike. Duplicating it here would mean two services alerting on the same limit. The used space is reported and graphed here so its growth is visible
* A namespace that is read-only is not a fault by itself, and on a disaster recovery cluster it is the normal state: a namespace that is replicated as a whole is held read-only at the receiving end. An archive that must not change any more looks the same. It warns by default, so that a namespace which turns read-only unexpectedly is noticed; set `--read-only-severity=ok` on the services where it is the intended state, or exclude those namespaces with `--ignore`
* The vendor documents only the normal running status (`0`) and no name for any other value. The check therefore treats every other code as worth a look rather than as a failure it cannot name, and passes the code through. Look an unfamiliar code up with Huawei support
* On this appliance a namespace and a file system are the same object. `huawei-pacific-quota` reads the same objects through the file system endpoint to find their quotas
* The credential/session token is cached in a local SQLite database between runs; `--cache-expire` controls how long it is reused before a fresh login

**Data Collection:**

* Queries the Huawei OceanStor Pacific REST API at `https://<ip>:<port>/api/v2/`
* Reads the namespaces in one request (`/converged_service/namespaces`) and compares their number against the count the cluster keeps of them (`/converged_service/namespaces_count`), so a listing that was capped somewhere is reported instead of passing as a complete inventory
* The used space arrives in the unit the appliance names next to it, and is converted to bytes. Where the appliance has nothing to report it sends the maximum of the field's data type, which is skipped rather than reported as a namespace holding exbibytes
* Authenticates via a session token (`X-Auth-Token`), cached in a SQLite database to avoid repeated logins
* If the appliance rejects a request (for example after a session reset or timeout), the check logs in again and retries
* Namespaces can be limited with `--match` and excluded with `--ignore` (Python regular expressions, anchored at the start of the namespace identifier and its name)


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/huawei-pacific-namespace> |
| Nagios/Icinga Check Name              | `check_huawei_pacific_namespace` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | No (`--password`, `--url` and `--username` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-huawei-pacific.db` |


## Help

```text
usage: huawei-pacific-namespace [-h] [-V] [--always-ok]
                                [--cache-expire CACHE_EXPIRE]
                                [--ignore IGNORE] [--insecure] [--lengthy]
                                [--match MATCH] [--no-insecure]
                                [--no-match-severity {ok,warn,crit,unknown}]
                                [--no-perfdata] [--no-proxy]
                                [--password PASSWORD]
                                [--password-file PASSWORD_FILE]
                                [--proxy PROXY]
                                [--read-only-severity {ok,warn,crit,unknown}]
                                [--scope SCOPE] [--timeout TIMEOUT] -u URL
                                --username USERNAME [-v]

Checks the namespaces of a Huawei OceanStor Pacific storage system via the
REST API (/converged_service/namespaces endpoint). Alerts when a namespace
cannot be reached, when it turned read-only, and when it reports a running
status other than normal. Reports the space and the number of files every
namespace uses. Supports extended reporting via --lengthy.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --cache-expire CACHE_EXPIRE
                        The amount of time after which the credential/data
                        cache expires, in minutes. Default: 15
  --ignore IGNORE       Skip namespaces. Any item matching this Python regex
                        will be ignored. Can be specified multiple times.
                        Example: `(?i)linuxfabrik` for a case-insensitive
                        match. The regex is anchored at the start of the
                        string (Python `re.match`) and is matched against the
                        namespace identifier and its name, so prefix with `.*`
                        to match anywhere. Default: None
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --lengthy             Extended reporting.
  --match MATCH         Limit to namespaces. Filter by this Python regular
                        expression. Case-sensitive by default; use `(?i)` for
                        case-insensitive matching. Can be specified multiple
                        times. If both `--match` and `--ignore` are given, an
                        item must match `--match` AND not match `--ignore` to
                        be reported (include first, exclude second). Examples:
                        `(?i)example` to match "example" regardless of case.
                        `^(?!.*example).*$` to match any string except
                        "example" (negative lookahead). The regex is anchored
                        at the start of the string (Python `re.match`) and is
                        matched against the namespace identifier and its name,
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
  --read-only-severity {ok,warn,crit,unknown}
                        State to report for a namespace that is read-only. A
                        namespace can be set read-only on purpose, which is
                        what an archive that must not change any more looks
                        like, so this is not a fault by itself. Default: warn
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

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/huawei-pacific-namespace/
```


## Usage Examples

```bash
./huawei-pacific-namespace --username=icinga --password=linuxfabrik --url=https://storage.example.com:8088
```

Output:

```text
Everything is ok. Checked 3 namespaces, all healthy.

Name          ! Used    ! Files ! Access                    ! Status     ! State
--------------+---------+-------+---------------------------+------------+------
ns-r-o01-001  ! 0.0B    ! 0.0   ! readable and writable (0) ! normal (0) ! [OK]
ns-r-f01-001  ! 65.7TiB ! 79.4M ! readable and writable (0) ! normal (0) ! [OK]
ns-nr-f01-001 ! 0.0B    ! 0.0   ! readable and writable (0) ! normal (0) ! [OK]
```

A namespace nobody can reach, next to one that was set read-only:

```bash
./huawei-pacific-namespace --username=icinga --password=linuxfabrik --url=https://storage.example.com:8088
```

Output:

```text
There are critical errors. Checked 3 namespaces, 2 not healthy.

Name          ! Used    ! Files ! Access                      ! Status     ! State
--------------+---------+-------+-----------------------------+------------+-----------
ns-r-o01-001  ! 0.0B    ! 0.0   ! inaccessible (2) [CRITICAL] ! normal (0) ! [CRITICAL]
ns-r-f01-001  ! 65.7TiB ! 0.0   ! read-only (1) [WARNING]     ! normal (0) ! [WARNING]
ns-nr-f01-001 ! 0.0B    ! 0.0   ! readable and writable (0)   ! normal (0) ! [OK]
```

`--lengthy` adds the namespace identifier, the storage pool it sits in and the protocol it speaks.


## States

* OK if every checked namespace is readable and writable and reports running status `normal (0)`.
* CRIT if a namespace is `inaccessible (2)`. Nothing can reach it, whatever its running status says.
* WARN if a namespace is `read-only (1)`. Tunable with `--read-only-severity`, since an archive can be read-only on purpose.
* WARN if a namespace reports a running status other than `0`, or an access mode the enumeration does not know. The vendor documents no name for either, so the code is passed through.
* WARN if the cluster counts more namespaces than it listed. The list is then incomplete and says so, naming both numbers. A failing count query is not fatal on its own: it is a cross-check, not the data itself.
* The worst state of all checked namespaces becomes the state of the check.
* OK with "No namespaces matched" if `--match` or `--ignore` excluded every namespace. Use `--no-match-severity` to report WARN, CRIT or UNKNOWN instead.
* UNKNOWN if the appliance lists no namespace at all. A cluster that serves storage has at least one, so an empty list is a query that never reached them.
* UNKNOWN on invalid API responses or responses with error codes, and on an invalid `--match` or `--ignore` pattern.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

One set of metrics per checked namespace, prefixed with the namespace name in snake_case.

| Name | Type | Description |
|----|----|----|
| &lt;namespace&gt;_file_used | Number | Files the namespace holds. Absent where the appliance reports no usable count. |
| &lt;namespace&gt;_read_write_mode | Number | Access mode: 0 readable and writable, 1 read-only, 2 inaccessible. |
| &lt;namespace&gt;_running_status | Number | Running status code. `0` is the normal state and the only one the vendor documents. |
| &lt;namespace&gt;_space_used | Bytes | Space the namespace uses. Absent where the appliance reports no usable measurement. |


## Troubleshooting

### No valuable response from the API

`Got no valuable response from https://...`

Check the `--url`, `--username` and `--password` parameters. Verify that the API user has query permissions and that the storage system REST API is reachable.

### A namespace is inaccessible

`ns-r-o01-001 ! ... ! inaccessible (2) [CRITICAL]`

Nothing reaches this namespace, so whatever it holds is out of service. Check the storage pool it sits in first (`huawei-pacific-storagepool`, and the `Pool` column with `--lengthy` says which one it is): a pool that is faulty or stopped takes its namespaces with it, and then the pool is the thing to fix. If the pool is healthy, look at the alarms (`huawei-pacific-alarm`) of the same time window and open a support case.

### A namespace turned read-only and nobody changed it

`read-only (1)`

Check first whether the namespace is the receiving end of a replication. A namespace that is replicated as a whole is held read-only there, which `huawei-pacific-replicationpair` shows as a pair whose local resource is the namespace itself rather than a dtree inside it. On a disaster recovery cluster that is the intended state, and the service belongs on `--read-only-severity=ok`.

Where replication does not explain it, compare against the storage pool: a write-protected pool makes its namespaces read-only, and then the pool is the thing to fix (`huawei-pacific-storagepool` reports that separately). An appliance also sets a namespace read-only on its own when it protects data it can no longer safely write, so this is worth checking rather than acknowledging away.

### The used space does not match what the storage pool reports

The used space of a namespace counts what it holds, while the pool counts what its disks hold, which includes the redundancy the pool writes on top. The two therefore never add up exactly, and the difference grows with the number of small files. Compare each figure against its own history rather than against the other.

### A namespace is missing from the output

Check whether a `--match` or `--ignore` pattern excludes it. Both are anchored at the start of the identifier and the name, so prefix a pattern with `.*` to match anywhere. If the namespace is missing without a filter in place, run the check with `--verbose` to see what the appliance actually answered.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
