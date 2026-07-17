# Check huawei-pacific-quota

## Overview

Checks how full the quotas of a Huawei OceanStor Pacific storage system are via the REST API (`/file_service/fs_quota` endpoint). Walks all file systems and their dtrees and reports the used space of every quota relative to its configured hard quota. Quotas without a hard quota are skipped, because there is no limit to compare against. Alerts when the used space in percent reaches the warning or critical threshold. Supports extended reporting via `--lengthy`.

**Important Notes:**

* Create a read-only API user that can perform queries only
* The fill level is calculated against the **hard quota**. A quota that has only a soft or an advisory quota configured is skipped, because a fill level needs an upper limit to relate to
* The API does not return `null` for a value that is unset or unavailable. It returns the maximum of the field's data type instead (`18446744073709551615` for a 64-bit field, `4294967295` for a 32-bit one). Such quotas are skipped rather than reported as 0%
* By default only directory quotas are checked. Use `--quota-type` to check user or user group quotas as well. User and user group quotas repeat per share, so their rows carry the owner name in brackets
* The file quota (number of files) is shown with `--lengthy` for context only. It does not alert; this check is about space
* The check queries the API once per file system and once per dtree, so its runtime grows with the number of shares. The shipped Director basket therefore raises the command timeout to 60 seconds and lowers the check interval to 15 minutes
* The credential/session token is cached in a local SQLite database between runs; `--cache-expire` controls how long it is reused before a fresh login

**Data Collection:**

* Queries the Huawei OceanStor Pacific REST API at `https://<ip>:<port>/api/v2/`
* Enumerates the file systems (`/file_service/file_systems`) and their dtrees (`/file_service/dtrees`), then queries the quotas of each of them (`/file_service/fs_quota`). The quota endpoint returns at most 100 records per query, so the results are fetched page by page
* Authenticates via a session token (`X-Auth-Token`), cached in a SQLite database to avoid repeated logins
* If the appliance rejects a request (for example after a session reset or timeout), the check logs in again and retries
* Shares can be excluded by `--ignore-regex` (Python regular expression)


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/huawei-pacific-quota> |
| Nagios/Icinga Check Name              | `check_huawei_pacific_quota` |
| Check Interval Recommendation         | Every 15 minutes |
| Can be called without parameters      | No (`--password`, `--url` and `--username` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-cache.db` |


## Help

```text
usage: huawei-pacific-quota [-h] [-V] [--always-ok] [--brief]
                            [--cache-expire CACHE_EXPIRE] [-c CRIT]
                            [--ignore-regex IGNORE_REGEX] [--insecure]
                            [--lengthy]
                            [--no-match-severity {ok,warn,crit,unknown}]
                            [--no-perfdata] [--no-proxy] --password PASSWORD
                            [--quota-type {directory,user,user-group}]
                            [--scope SCOPE] [--timeout TIMEOUT] -u URL
                            --username USERNAME [-w WARN]

Checks how full the quotas of a Huawei OceanStor Pacific storage system are
via the REST API (/file_service/fs_quota endpoint). Walks all file systems and
their dtrees and reports the used space of every quota relative to its
configured hard quota. Quotas without a hard quota are skipped, because there
is no limit to compare against. Alerts when the used space in percent reaches
the warning or critical threshold. Supports extended reporting via --lengthy.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --brief               Hide table rows for quotas within the thresholds and
                        show only those in WARN/CRIT state. Perfdata and
                        alerting are unaffected: all quotas still emit
                        perfdata and still drive the overall check state.
                        Default: False
  --cache-expire CACHE_EXPIRE
                        The amount of time after which the credential/data
                        cache expires, in minutes. Default: 15
  -c, --critical CRIT   CRIT threshold in percent. Supports Nagios ranges.
                        Default: 90
  --ignore-regex IGNORE_REGEX
                        Any item matching this Python regex will be ignored.
                        Can be specified multiple times. Example:
                        `(?i)linuxfabrik` for a case-insensitive match.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --lengthy             Extended reporting.
  --no-match-severity {ok,warn,crit,unknown}
                        State to report when no item matches the filters and
                        nothing is checked. Default: ok
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --no-proxy            Do not use a proxy.
  --password PASSWORD   Huawei OceanStor Pacific API password.
  --quota-type {directory,user,user-group}
                        Type of quota to check. Can be specified multiple
                        times. Example: `--quota-type=directory --quota-
                        type=user`. Default: directory
  --scope SCOPE         Huawei OceanStor Pacific API scope.
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -u, --url URL         Huawei OceanStor Pacific API URL.
  --username USERNAME   Huawei OceanStor Pacific API username.
  -w, --warning WARN    WARN threshold in percent. Supports Nagios ranges.
                        Default: 80
```


## Usage Examples

```bash
./huawei-pacific-quota --url=https://oceanstor:8088 --username=monitoring --password=linuxfabrik --warning=80 --critical=90
```

Output:

```text
There are critical errors. (warn=80 crit=90) Checked 2 quotas.

Share   ! Used     ! Quota  ! Use% ! State
--------+----------+--------+------+-----------
fs1/dt1 ! 430.1MiB ! 1.0GiB ! 42%  ! [OK]
fs1/dt2 ! 972.8MiB ! 1.0GiB ! 95%  ! [CRITICAL]
```

With `--lengthy`, showing the quota type and the file quota:

```bash
./huawei-pacific-quota --url=https://oceanstor:8088 --username=monitoring --password=linuxfabrik --lengthy
```

```text
There are critical errors. (warn=80 crit=90) Checked 2 quotas.

Share   ! Type      ! Used     ! Quota  ! Use% ! Files      ! State
--------+-----------+----------+--------+------+------------+-----------
fs1/dt1 ! directory ! 430.1MiB ! 1.0GiB ! 42%  ! 1.2K/10.0K ! [OK]
fs1/dt2 ! directory ! 972.8MiB ! 1.0GiB ! 95%  ! -          ! [CRITICAL]
```

With `--brief`, hiding the shares that are within the thresholds. Both shares still emit perfdata:

```bash
./huawei-pacific-quota --url=https://oceanstor:8088 --username=monitoring --password=linuxfabrik --brief
```

```text
There are critical errors. (warn=80 crit=90) Checked 2 quotas.

Share   ! Used     ! Quota  ! Use% ! State
--------+----------+--------+------+-----------
fs1/dt2 ! 972.8MiB ! 1.0GiB ! 95%  ! [CRITICAL]
```

Checking the user quotas instead of the directory quotas:

```bash
./huawei-pacific-quota --url=https://oceanstor:8088 --username=monitoring --password=linuxfabrik --quota-type=user
```

```text
There are critical errors. (warn=80 crit=90) Checked 1 quota.

Share           ! Used      ! Quota  ! Use% ! State
----------------+-----------+--------+------+-----------
fs1/dt1 (alice) ! 1013.8MiB ! 1.0GiB ! 99%  ! [CRITICAL]
```


## States

* OK if the used space of every checked quota is below the warning threshold.
* WARN if the used space of any checked quota is at or above `--warning` (default: 80).
* CRIT if the used space of any checked quota is at or above `--critical` (default: 90).
* The worst state of all checked quotas becomes the state of the check.
* OK with "Nothing checked." if no quota matched, for example if no hard quota is configured anywhere or `--ignore-regex` excluded everything. Use `--no-match-severity` to report WARN, CRIT or UNKNOWN instead.
* UNKNOWN on invalid API responses or responses with error codes, and on an invalid `--ignore-regex` pattern.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

One metric per checked quota. `--brief` and `--lengthy` do not change the perfdata: every checked quota is always reported.

| Name | Type | Description |
|----|----|----|
| &lt;share&gt;_usage_percent | Percentage | Used space of the quota in percent of its hard quota. The share name is the file system and dtree name, sanitized into snake_case; for a user or user group quota the owner name is appended. |


## Troubleshooting

### No valuable response from the API

`Got no valuable response from https://...`

Check the `--url`, `--username` and `--password` parameters. Verify that the API user has query permissions and that the storage system REST API is reachable.

### A share is missing from the output

The check only reports quotas that have a hard quota configured, and by default only directory quotas. Verify on the appliance that the share has a hard quota (not just a soft or advisory quota), and run the check with `--quota-type=directory --quota-type=user --quota-type=user-group --lengthy` to see everything that is configured. Also check whether an `--ignore-regex` pattern excludes the share.

### The check runs into its timeout

The check queries the API once per file system and once per dtree, so its runtime grows with the number of shares. Raise the command timeout, raise `--timeout` for slow API responses, and increase the check interval. `--cache-expire` keeps the session token cached between runs and avoids a login on every check.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
