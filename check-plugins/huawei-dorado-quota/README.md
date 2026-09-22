# Check huawei-dorado-quota

## Overview

Checks how full the quotas of a Huawei OceanStor Dorado storage system are via the REST API (`/FS_QUOTA` endpoint). Walks all file systems and reports the used space of every quota, the quotas of their dtrees (the directories a share is usually created on) included, relative to its configured hard quota. Quotas without a hard quota are skipped, because there is no limit to compare against. Alerts when the used space in percent reaches the warning or critical threshold. Supports extended reporting via `--lengthy`.

A dtree is a directory directly below the root of a file system that the appliance manages as an object of its own. Shares and quotas are usually set on dtrees rather than on the whole file system, which is why the quota of a dtree is often called a "dtree quota". On the appliance it is a directory quota whose parent is the dtree.

**Important Notes:**

* Create a read-only API user that can perform queries only
* The fill level is calculated against the **hard quota**. A quota that has only a soft quota configured is skipped, because a fill level needs an upper limit to relate to
* The API reports an unset quota as `-1`. Such values are left out rather than reported as a quota of 0 bytes
* By default only directory quotas are checked, which covers the dtree quotas. Use `--quota-type` to check user or user group quotas as well. User and user group quotas repeat per share, so their rows carry the owner name in brackets
* The soft quota and the file quota (number of files) are shown with `--lengthy` for context only. They do not alert; this check is about the hard limit on space
* The check queries the API once for the list of file systems and once per file system that carries a quota, so its runtime grows with the number of file systems. The shipped Director basket therefore raises the command timeout to 120 seconds and runs the check once an hour
* The credential/session token is cached in a local SQLite database between runs; `--cache-expire` controls how long it is reused before a fresh login

**Data Collection:**

* Queries the Huawei OceanStor Dorado REST API at `https://<ip>:<port>/deviceManager/rest/<device-id>/`
* Enumerates the file systems (`/filesystem`) and queries the quotas of every file system that carries at least one (`/FS_QUOTA`). The quotas of a file system include those of all its dtrees, so the dtrees do not have to be queried one by one
* Both endpoints are read page by page, so a large appliance is reported completely
* Authenticates via a session token (`iBaseToken`), cached in a SQLite database to avoid repeated logins
* If the appliance rejects a request (for example after a session reset or timeout), the check logs in again and retries
* Shares can be limited with `--match` and excluded with `--ignore` (Python regular expressions, anchored at the start of the share name). The share name is the file system name followed by the dtree name, for example `fs_nfs_01/share_a`


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/huawei-dorado-quota> |
| Nagios/Icinga Check Name              | `check_huawei_dorado_quota` |
| Check Interval Recommendation         | Every hour |
| Can be called without parameters      | No (`--password`, `--url` and `--username` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-huawei-dorado.db` |


## Help

```text
usage: huawei-dorado-quota [-h] [-V] [--always-ok] [--brief]
                           [--cache-expire CACHE_EXPIRE] [-c CRIT]
                           [--device-id DEVICE_ID] [--ignore IGNORE]
                           [--insecure] [--lengthy] [--match MATCH]
                           [--no-insecure]
                           [--no-match-severity {ok,warn,crit,unknown}]
                           [--no-perfdata] [--no-proxy] [--password PASSWORD]
                           [--password-file PASSWORD_FILE] [--proxy PROXY]
                           [--quota-type {directory,user,user-group}]
                           [--scope SCOPE] [--timeout TIMEOUT] -u URL
                           --username USERNAME [-v] [-w WARN]

Checks how full the quotas of a Huawei OceanStor Dorado storage system are via
the REST API (/FS_QUOTA endpoint). Walks all file systems and reports the used
space of every quota, the quotas of their dtrees (the directories a share is
usually created on) included, relative to its configured hard quota. Quotas
without a hard quota are skipped, because there is no limit to compare
against. Alerts when the used space in percent reaches the warning or critical
threshold. Supports extended reporting via --lengthy.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --brief               Hide the rows that are within the thresholds and show
                        only those in a WARN or CRIT state. Perfdata and
                        alerting are unaffected: every item still emits
                        performance data and still drives the overall check
                        state, so this is safe to leave on. Worth setting on
                        an appliance with many quotas.
  --cache-expire CACHE_EXPIRE
                        The amount of time after which the credential/data
                        cache expires, in minutes. Default: 15
  -c, --critical CRIT   CRIT threshold in percent. Supports Nagios ranges.
                        Default: 90
  --device-id DEVICE_ID
                        Huawei OceanStor Dorado API device ID. Optional: the
                        appliance reports its own at login, so this is only
                        needed to override that answer.
  --ignore IGNORE       Skip quotas. Any item matching this Python regex will
                        be ignored. Can be specified multiple times. Example:
                        `(?i)linuxfabrik` for a case-insensitive match. The
                        regex is anchored at the start of the string (Python
                        `re.match`) and is matched against the share name,
                        including the owner of a user or user group quota, so
                        prefix with `.*` to match anywhere.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --lengthy             Extended reporting.
  --match MATCH         Limit to quotas. Filter by this Python regular
                        expression. Case-sensitive by default; use `(?i)` for
                        case-insensitive matching. Can be specified multiple
                        times. If both `--match` and `--ignore` are given, an
                        item must match `--match` AND not match `--ignore` to
                        be reported (include first, exclude second). Examples:
                        `(?i)example` to match "example" regardless of case.
                        `^(?!.*example).*$` to match any string except
                        "example" (negative lookahead). The regex is anchored
                        at the start of the string (Python `re.match`) and is
                        matched against the share name, including the owner of
                        a user or user group quota, so prefix with `.*` to
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
  --quota-type {directory,user,user-group}
                        Type of quota to check. Can be specified multiple
                        times. Example: `--quota-type=directory --quota-
                        type=user`. Default: directory
  --scope SCOPE         Huawei OceanStor Dorado API scope.
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
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
  -w, --warning WARN    WARN threshold in percent. Supports Nagios ranges.
                        Default: 80

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/huawei-dorado-quota/
```


## Usage Examples

```bash
./huawei-dorado-quota --url=https://dorado:8088 --username=monitoring --password=linuxfabrik --warning=80 --critical=90
```

Output:

```text
There are critical errors. Checked 3 quotas (warn=80 crit=90).

Share             ! Used     ! Quota  ! Use% ! State
------------------+----------+--------+------+-----------
fs_nfs_01/share_a ! 1.7TiB   ! 2.0TiB ! 85%  ! [WARNING]
fs_nfs_01/share_b ! 100.0GiB ! 1.0TiB ! 9%   ! [OK]
fs_smb_01/share_c ! 4.0TiB   ! 4.0TiB ! 99%  ! [CRITICAL]
```

With `--lengthy`, showing the vStore and the quota type:

```bash
./huawei-dorado-quota --url=https://dorado:8088 --username=monitoring --password=linuxfabrik --lengthy
```

```text
There are critical errors. Checked 3 quotas (warn=80 crit=90).

Share             ! vStore     ! Type      ! Used     ! Quota  ! Use% ! State
------------------+------------+-----------+----------+--------+------+-----------
fs_nfs_01/share_a ! vstore_nfs ! directory ! 1.7TiB   ! 2.0TiB ! 85%  ! [WARNING]
fs_nfs_01/share_b ! vstore_nfs ! directory ! 100.0GiB ! 1.0TiB ! 9%   ! [OK]
fs_smb_01/share_c ! vstore_smb ! directory ! 4.0TiB   ! 4.0TiB ! 99%  ! [CRITICAL]
```

With `--brief`, hiding the shares that are within the thresholds. All shares still emit perfdata:

```bash
./huawei-dorado-quota --url=https://dorado:8088 --username=monitoring --password=linuxfabrik --brief
```

```text
There are critical errors. Checked 3 quotas (warn=80 crit=90).

Share             ! Used   ! Quota  ! Use% ! State
------------------+--------+--------+------+-----------
fs_nfs_01/share_a ! 1.7TiB ! 2.0TiB ! 85%  ! [WARNING]
fs_smb_01/share_c ! 4.0TiB ! 4.0TiB ! 99%  ! [CRITICAL]
```

Checking the user quotas next to the directory quotas:

```bash
./huawei-dorado-quota --url=https://dorado:8088 --username=monitoring --password=linuxfabrik --quota-type=directory --quota-type=user
```

```text
There are critical errors. Checked 2 quotas (warn=80 crit=90).

Share             ! Used     ! Quota  ! Use% ! State
------------------+----------+--------+------+-----------
fs_nfs_01/share_b ! 100.0GiB ! 1.0TiB ! 9%   ! [OK]
fs_nfs_01 (alice) ! 972.8MiB ! 1.0GiB ! 95%  ! [CRITICAL]
```


## States

* OK if the used space of every checked quota is below the warning threshold.
* WARN if the used space of any checked quota is above `--warning` (default: 80).
* CRIT if the used space of any checked quota is above `--critical` (default: 90).
* The worst state of all checked quotas becomes the state of the check.
* OK with "No share carries a hard quota." if the appliance has no file system with a hard quota.
* OK with "No quota matched the filters." if `--match`, `--ignore` or `--quota-type` excluded everything. Use `--no-match-severity` to report WARN, CRIT or UNKNOWN instead.
* WARN if the appliance reports more objects than the check reads in one run, since the list is then incomplete.
* UNKNOWN on invalid API responses or responses with error codes, and on an invalid `--match` or `--ignore` pattern.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

One metric per checked quota. `--brief` and `--lengthy` do not change the perfdata: every checked quota is always reported.

| Name | Type | Description |
|----|----|----|
| &lt;share&gt;_usage_percent | Percentage | Used space of the quota in percent of its hard quota. The share name is the file system and dtree name, sanitized into snake_case; for a user or user group quota the owner name is appended. |


## Troubleshooting

### A share is missing from the output

The check only reports quotas that have a hard quota configured, and by default only directory quotas. Verify on the appliance that the share has a hard quota (not just a soft quota), and run the check with `--quota-type=directory --quota-type=user --quota-type=user-group --lengthy` to see everything that is configured. Also check whether a `--match` or `--ignore` pattern excludes the share. Both are anchored at the start of the share name, so prefix a pattern with `.*` to match anywhere.

### `Failed to query the quotas of file system ...`

The appliance rejected the quota query and names the reason after the error code. Most often the API user lacks the permission to read quotas. Grant it read access to file systems, dtrees and quotas, and check that `--url` points at the appliance's management address. Run the check with `--verbose` to see every answer of the appliance.

### The check runs into its timeout

The check queries the API once per file system that carries a quota, so its runtime grows with the number of file systems. Raise the command timeout, raise `--timeout` for slow API responses, and increase the check interval. `--cache-expire` keeps the session token cached between runs and avoids a login on every check.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
