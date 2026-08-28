# Check huawei-pacific-replicationpair

## Overview

Checks the remote replication pairs of a Huawei OceanStor Pacific storage system via the REST API (`/dsware/service/REPLICATIONPAIR` endpoint). Alerts when a pair is faulty or has stopped mirroring, and optionally when its last synchronization is older than the given thresholds. Supports extended reporting via `--lengthy` and shorter output via `--brief`.

**Important Notes:**

* Create a read-only API user that can perform queries only
* Run the check on both ends of the replication. The disaster recovery side reports every pair as `secondary`, which is what it is supposed to be and not a fault, and it is the side that notices when the primary stops sending
* A pair that is `synchronizing` is transferring, which is the working state of an asynchronous pair rather than a fault. It reports OK
* **A pair can report a healthy status and still have stopped moving data.** `--warning` and `--critical` alert on how long the far end has been without a complete copy and catch that; they are off by default, because the synchronization interval is configured per pair on the appliance and no default would fit. Read the interval from the `Schedule` column with `--lengthy` and set the thresholds above it
* A pair whose transfer is still running reports no end time, and its `Last Sync` column says `in progress since ...` rather than naming a completed synchronization. The thresholds measure from the start of that transfer, so a synchronization that never completes is caught as well: it leaves the far end just as stale as one that never starts. Only a pair that has neither finished nor started a transfer reads `never`, and no threshold applies to it
* The endpoint returns at most 40 pairs per request, so the check pages through them. If it still runs out of pages, it says so and warns rather than reporting a smaller but healthy cluster
* A cluster that replicates nothing reports OK with "No replication pairs configured."
* The credential/session token is cached in a local SQLite database between runs; `--cache-expire` controls how long it is reused before a fresh login

**Data Collection:**

* Queries the Huawei OceanStor Pacific REST API at `https://<ip>:<port>/dsware/service/`, the older endpoint generation, which is the only place this information is served
* Reads the replication pairs page by page (`/REPLICATIONPAIR`), 40 per request
* Authenticates via a session token (`X-Auth-Token`), cached in a SQLite database to avoid repeated logins
* If the appliance rejects a request (for example after a session reset or timeout), the check logs in again and retries
* Pairs can be limited with `--match` and excluded with `--ignore` (Python regular expressions, anchored at the start of the pair identifier and the local and remote resource names)


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/huawei-pacific-replicationpair> |
| Nagios/Icinga Check Name              | `check_huawei_pacific_replicationpair` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | No (`--password`, `--url` and `--username` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-huawei-pacific.db` |


## Help

```text
usage: huawei-pacific-replicationpair [-h] [-V] [--always-ok] [--brief]
                                      [--cache-expire CACHE_EXPIRE] [-c CRIT]
                                      [--ignore IGNORE] [--insecure]
                                      [--lengthy] [--match MATCH]
                                      [--no-insecure]
                                      [--no-match-severity {ok,warn,crit,unknown}]
                                      [--no-perfdata] [--no-proxy]
                                      [--password PASSWORD]
                                      [--password-file PASSWORD_FILE]
                                      [--proxy PROXY] [--scope SCOPE]
                                      [--timeout TIMEOUT] -u URL
                                      --username USERNAME [-w WARN] [-v]

Checks the remote replication pairs of a Huawei OceanStor Pacific storage
system via the REST API (/dsware/service/REPLICATIONPAIR endpoint). Alerts
when a pair is faulty or has stopped mirroring, and optionally when its last
synchronization is older than the given thresholds. Supports extended
reporting via --lengthy and shorter output via --brief.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --brief               Hide table rows for pairs that are mirroring and show
                        only those that are not. Perfdata and alerting are
                        unaffected: every pair still emits perfdata and still
                        drives the overall check state. Default: False
  --cache-expire CACHE_EXPIRE
                        The amount of time after which the credential/data
                        cache expires, in minutes. Default: 15
  -c, --critical CRIT   CRIT threshold for how long a pair has been without a
                        complete copy at the far end, as a Nagios range in
                        seconds. That is the time since the pair last finished
                        transferring, or, while a transfer is running that has
                        not finished, the time since it started. A pair can
                        report a healthy status and still have stopped moving
                        data, which is what this catches. Set it above the
                        pair's own synchronization interval; there is no
                        useful default, because that interval is configured
                        per pair on the appliance. Off by default. Example:
                        `--critical=172800` for two days
  --ignore IGNORE       Skip replication pairs. Any item matching this Python
                        regex will be ignored. Can be specified multiple
                        times. Example: `(?i)linuxfabrik` for a case-
                        insensitive match. The regex is anchored at the start
                        of the string (Python `re.match`) and is matched
                        against the pair identifier and the local and remote
                        resource names, so prefix with `.*` to match anywhere.
                        Default: None
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --lengthy             Extended reporting.
  --match MATCH         Limit to replication pairs. Filter by this Python
                        regular expression. Case-sensitive by default; use
                        `(?i)` for case-insensitive matching. Can be specified
                        multiple times. If both `--match` and `--ignore` are
                        given, an item must match `--match` AND not match
                        `--ignore` to be reported (include first, exclude
                        second). Examples: `(?i)example` to match "example"
                        regardless of case. `^(?!.*example).*$` to match any
                        string except "example" (negative lookahead). The
                        regex is anchored at the start of the string (Python
                        `re.match`) and is matched against the pair identifier
                        and the local and remote resource names, so prefix
                        with `.*` to match anywhere. Default: None
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
  --timeout TIMEOUT     Network timeout in seconds. Default: 30 (seconds)
  -u, --url URL         Huawei OceanStor Pacific API URL.
  --username USERNAME   Huawei OceanStor Pacific API username.
  -w, --warning WARN    WARN threshold for how long a pair has been without a
                        complete copy at the far end, as a Nagios range in
                        seconds. Off by default, see --critical. Example:
                        `--warning=86400` for one day
  -v, --verbose         Makes this plugin verbose during the operation. Useful
                        for debugging and seeing what is going on under the
                        hood. Appends what every API request returned, so the
                        appliance's own answers can be read while working out
                        how it reports something. Session tokens are redacted.
                        The output is as long as those answers are, so this is
                        a debugging aid rather than something to leave
                        switched on.

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/huawei-pacific-replicationpair/
```


## Usage Examples

```bash
./huawei-pacific-replicationpair --username=icinga --password=linuxfabrik --url=https://storage.example.com:8088
```

Output:

```text
Everything is ok. Checked 3 replication pairs, all mirroring.

Local                     ! Remote Device             ! Last Sync                        ! Running            ! Health     ! State
--------------------------+---------------------------+----------------------------------+--------------------+------------+------
ns-r-f01-001@01_archive01 ! Rep_Cluster20260527145804 ! 2026-08-12 09:00:08 (1h 35m ago) ! normal (1)         ! normal (1) ! [OK]
ns-r-f01-001@01_archive02 ! Rep_Cluster20260527145804 ! 2026-08-12 09:00:08 (1h 35m ago) ! normal (1)         ! normal (1) ! [OK]
ns-r-f01-001@01_archive03 ! Rep_Cluster20260527145804 ! 2026-08-12 09:00:08 (1h 35m ago) ! synchronizing (23) ! normal (1) ! [OK]
```

With `--brief` only the pairs that stopped mirroring are listed, which is what a cluster with dozens of them wants:

```bash
./huawei-pacific-replicationpair --username=icinga --password=linuxfabrik --url=https://storage.example.com:8088 --brief
```

Output:

```text
There are critical errors. Checked 4 replication pairs, 4 not mirroring.

Local                     ! Remote Device             ! Last Sync                        ! Running              ! Health     ! State
--------------------------+---------------------------+----------------------------------+----------------------+------------+-----------
ns-r-f01-001@01_archive01 ! Rep_Cluster20260527145804 ! 2026-08-12 09:00:08 (1h 35m ago) ! interrupted (34)     ! normal (1) ! [CRITICAL]
ns-r-f01-001@01_archive02 ! Rep_Cluster20260527145804 ! 2026-08-12 09:00:08 (1h 35m ago) ! split (26)           ! normal (1) ! [WARNING]
ns-r-f01-001@01_archive03 ! Rep_Cluster20260527145804 ! 2026-08-12 09:00:08 (1h 35m ago) ! to be recovered (33) ! normal (1) ! [WARNING]
ns-r-f01-001@01_archive04 ! Rep_Cluster20260527145804 ! 2026-08-12 09:00:08 (1h 35m ago) ! normal (1)           ! faulty (2) ! [CRITICAL]
```

`--lengthy` adds the pair identifier, the remote resource, which end this cluster is, the synchronization schedule and how long the last transfer took.


## States

* OK if every checked pair reports health `normal (1)` and a running status of `normal (1)` or `synchronizing (23)`.
* WARN if a pair is `split (26)`, which is a pair an administrator detached, or `to be recovered (33)`, which is one waiting to be resumed. Neither is mirroring, and neither is a surprise.
* WARN if a pair reports a health or running status the vendor's enumeration does not list, or none at all.
* WARN if a pair's health is `invalid (3)`, so the appliance cannot state it.
* CRIT if a pair is `interrupted (34)` or `invalid (35)`. Such a pair stopped mirroring without being told to, so what it protects is no longer protected.
* CRIT if a pair's health is `faulty (2)`.
* WARN or CRIT if the time a pair has been without a complete copy at the far end reaches `--warning` or `--critical`. Both are off by default. A pair that has neither finished nor started a transfer has no age and is not affected by them.
* WARN if the appliance reports more pairs than the check reads in one run. The list is then incomplete and says so.
* OK with "No replication pairs configured." if the cluster replicates nothing.
* OK with "No replication pairs matched" if `--match` or `--ignore` excluded every pair. Use `--no-match-severity` to report WARN, CRIT or UNKNOWN instead.
* UNKNOWN on invalid API responses or responses with error codes, and on an invalid `--match` or `--ignore` pattern.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

One set of metrics per checked pair, prefixed with the local resource name in snake_case. `--brief` and `--lengthy` do not change the perfdata: every pair is always reported.

| Name | Type | Description |
|----|----|----|
| &lt;pair&gt;_health_status | Number | Health status code of the pair: 1 normal, 2 faulty, 3 invalid. |
| &lt;pair&gt;_last_sync_age | Seconds | How long the far end has been without a complete copy: the time since the last completed synchronization, or, while a transfer is running that has not finished, the time since it started. Absent for a pair that has neither finished nor started one. |
| &lt;pair&gt;_running_status | Number | Running status code of the pair: 1 normal, 23 synchronizing, 26 split, 33 to be recovered, 34 interrupted, 35 invalid. |


## Troubleshooting

### No valuable response from the API

`Got no valuable response from https://...`

Check the `--url`, `--username` and `--password` parameters. Verify that the API user has query permissions and that the storage system REST API is reachable.

### A pair is interrupted

`ns-r-f01-001@01_archive01 ! ... ! interrupted (34) ! ... ! [CRITICAL]`

The pair stopped mirroring and did not do so on request, so what it replicates is running without a current copy at the far end. Check the link between the two clusters first, then the far end itself: an interrupted pair is far more often a network path or a full secondary than a fault on the primary. The alarms (`huawei-pacific-alarm`) of the same time window usually name the cause. Resuming a pair by hand re-synchronizes it, which costs bandwidth, so do it deliberately rather than as a reflex.

### A pair is split

`split (26)`

Somebody detached this pair, which is a normal administrative action and the reason this is a warning rather than an alert. If the split was intended and is permanent, exclude the pair with `--ignore`; if it was meant to be temporary, resume it on the appliance. A split pair does not protect anything in the meantime.

### The last synchronization is old and the status looks fine

This is exactly what `--warning` and `--critical` are for, and they are off until you set them. Read the pair's own interval from the `Schedule` column with `--lengthy`, then set the thresholds above it, for example `--warning=86400 --critical=172800` for a pair that synchronizes daily. Without them the age is reported and graphed but never alerts.

### A pair has been `in progress` for far longer than its interval

`in progress since 2026-08-11 14:34:52 (20h 9m)`

The pair started a transfer and has not finished it, which is normal for the first synchronization of a large share and worth looking at when it outlasts the pair's own interval by a wide margin. Check the bandwidth between the clusters and how much data the share holds before assuming a fault: a multi-terabyte archive legitimately takes many hours over a link shared with everything else. The thresholds measure from the start of that transfer, so setting them above the interval catches a transfer that is genuinely stuck.

### The list of pairs is incomplete

`The appliance reports more replication pairs than this check reads in one run; the list below is incomplete.`

The check pages through the pairs 40 at a time, which is the maximum the vendor documents for this endpoint, and it stopped before the end. Narrow the check down with `--match` so several services each cover part of the pairs.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
