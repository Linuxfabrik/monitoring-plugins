# Check apache-httpd-security


## Overview

Checks the local security posture of an Apache httpd installation: which modules the server has loaded, which account its worker processes run under, the ownership and permissions of the configuration files, the process ID file, the lock file directory and the core dump directory, and how large a request the server accepts. Paths and accounts are read back from the running installation rather than from a configuration file, so a value left at a compiled-in default and a directive overridden further down the configuration are both reported as they actually take effect. The request limits are taken from the configuration files the server itself names, and where a directive is absent the value httpd falls back to is reported instead. Each finding maps to a copy-pasteable recommendation. Alerts when a module widens the attack surface without being needed, when the worker account is not a dedicated unprivileged system account, when a file or directory the server relies on can be modified by somebody other than root, or when a request limit is more permissive than recommended. Individual checks can be excluded with `--ignore`. Requires root or sudo.

The checks follow the "Minimize Apache Modules", "Principles, Permissions, and Ownership" and "Request Limits" chapters of the CIS Apache HTTP Server 2.4 Benchmark.

**Important Notes:**

* The check is part of the Apache httpd and Apache apache2 Service Sets, where it runs through the `-sudo` check command. A host that has not deployed the sudoers file makes the service report UNKNOWN until it has.
* The shipped service template excludes the status module check (`--ignore=^Status module`), because the same Service Sets deploy the status check, which reads `mod_status`. Drop that default on a host where the module is not wanted.
* Requires root or sudo. Both `httpd` and `apachectl` refuse to parse the configuration as an unprivileged account, because they create the runtime directory while doing so.
* The check re-parses the configuration from disk. A change that has been written but not reloaded is therefore reported as if it were already in force. The worker account is the exception: it is additionally compared against the accounts the running processes actually use.
* The module checks report what CIS recommends disabling. A module a site knowingly needs is excluded with `--ignore`, for example `--ignore=^Status module$` on a host whose monitoring reads `mod_status`. The check still lists everything else.
* A check that finds more than three modules names the first three and counts the rest. The `Detail` column carries the full list.
* The ownership and permission checks cover the configuration files the server itself reports reading, plus the runtime directories it resolves. They do not walk the whole installation tree, which would be both slow and unbounded.
* The benchmark treats the core dump, lock, process ID and scoreboard file checks as ones an auditor confirms rather than as fully automatable. This check does the legwork and reports what it found; the judgement stays with the operator.
* A scoreboard file that is not configured at all is compliant, and reported as such.
* The four request limits are reported whether or not the configuration sets them, because httpd enforces a value either way. An absent `LimitRequestLine`, `LimitRequestFields` or `LimitRequestFieldSize` leaves a compiled-in value the benchmark accepts, so those pass. An absent `LimitRequestBody` caps the request body at 1 GiB, which the benchmark does not accept, so a stock installation fails that one until the directive is written out. Such a value carries `(default)` in the result column.
* `LimitRequestBody` may also be set per virtual host, directory or location. Every value the configuration files carry is reported and judged, so a single permissive block is visible even when the server level is restrictive. Which block a value belongs to is not resolved; the recommendation names the value, and the operator knows where it lives.
* `LimitRequestBody` caps every upload the server accepts, and an upload rejected by it never reaches the application. A host that has to accept larger uploads raises the directive for the vhost or location in question and excludes this check with `--ignore=^Request body limit$`, rather than lifting the limit everywhere.

### Data Collection

Three invocations of the Apache control binary per run, all of which only read: `-M` for the loaded modules, `-S` for the resolved runtime settings (server root, document root, process ID file, mutex mechanisms and directories, user and group with their numeric ids), and `-t -D DUMP_INCLUDES` for the list of configuration files. The paths that come out of these are then inspected with `stat`. `UID_MIN` is read from `/etc/login.defs`, and the running worker processes are enumerated via `psutil`. The core dump directory, the scoreboard file and the four request limits are the values the runtime dump does not resolve; they are read from the configuration files the server itself named. Nothing is stored between runs.

The binary is probed automatically: `httpd` first, which covers the Red Hat and SUSE families, then `apachectl`, which is the entry point on Debian and Ubuntu because `apache2` refuses to parse its own configuration without the variables from `/etc/apache2/envvars`. Use `--command` to point at a binary in a non-standard location.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/apache-httpd-security> |
| Nagios/Icinga Check Name              | `check_apache_httpd_security` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |
| Requirements                          | command-line tool `httpd` or `apachectl`; root or sudo |
| 3rd Party Python modules              | `psutil` |


## Help

```text
usage: apache-httpd-security [-h] [-V] [--always-ok] [--brief]
                             [--command COMMAND] [--ignore IGNORE]
                             [--match MATCH]
                             [--no-match-severity {ok,warn,crit,unknown}]
                             [--no-perfdata] [--severity {warn,crit}]
                             [--timeout TIMEOUT]

Checks the local security posture of an Apache httpd installation: which
modules the server has loaded, which account its worker processes run under,
the ownership and permissions of the configuration files, the process ID file,
the lock file directory and the core dump directory, and how large a request
the server accepts. Paths and accounts are read back from the running
installation rather than from a configuration file, so a value left at a
compiled-in default and a directive overridden further down the configuration
are both reported as they actually take effect. The request limits are taken
from the configuration files the server itself names, and where a directive is
absent the value httpd falls back to is reported instead. Each finding maps to
a copy-pasteable recommendation. Alerts when a module widens the attack
surface without being needed, when the worker account is not a dedicated
unprivileged system account, when a file or directory the server relies on can
be modified by somebody other than root, or when a request limit is more
permissive than recommended. Individual checks can be excluded with --ignore.
Requires root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --brief               Hide the rows that are within the thresholds and show
                        only those in a WARN or CRIT state. Perfdata and
                        alerting are unaffected: every item still emits
                        performance data and still drives the overall check
                        state, so this is safe to leave on.
  --command COMMAND     Path to the Apache httpd control binary. Probed
                        automatically if not given: `httpd` first, then
                        `apachectl`. Example: `--command=/usr/sbin/httpd`
  --ignore IGNORE       Any check whose name matches this Python regex will be
                        dropped from the report. Use it for a finding the site
                        knowingly accepts, for example the status module on a
                        host whose monitoring reads it. Case-sensitive by
                        default; use `(?i)` for case-insensitive matching. Can
                        be specified multiple times. Example:
                        `--ignore=^Status module$`
  --match MATCH         Only report the checks whose name matches this Python
                        regex. Filter by this Python regular expression. Case-
                        sensitive by default; use `(?i)` for case-insensitive
                        matching. Can be specified multiple times. If both
                        `--match` and `--ignore` are given, an item must match
                        `--match` AND not match `--ignore` to be reported
                        (include first, exclude second). Examples:
                        `(?i)example` to match "example" regardless of case.
                        `^(?!.*example).*$` to match any string except
                        "example" (negative lookahead).
  --no-match-severity {ok,warn,crit,unknown}
                        State to report when no item matches the filters and
                        nothing is checked. Default: ok
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --severity {warn,crit}
                        State to report for a failed check. One of `warn` or
                        `crit`. Default: warn
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/apache-httpd-security/
```


## Usage Examples

A stock installation, which loads every module the distribution packages:

```bash
sudo ./apache-httpd-security --brief
```

```text
7 of 16 checks failed.

Recommendations:
* WebDAV modules: Comment out the `LoadModule` lines for `mod_dav`, `mod_dav_fs` and `mod_dav_lock`.
* Status module: Comment out the `LoadModule` line for `mod_status`, or exclude this check with `--ignore=^Status module$` if the module feeds your monitoring.
* Autoindex module: Comment out the `LoadModule` line for `mod_autoindex` so a directory without an index file stops listing its content.
* Proxy modules: Comment out the `LoadModule` lines for the `mod_proxy` family unless the host really is a reverse proxy.
* User directories module: Comment out the `LoadModule` line for `mod_userdir` so home directories stop being served.
* Info module: Comment out the `LoadModule` line for `mod_info`; it exposes the whole configuration, including credentials of other modules.
* Basic and digest auth: Comment out the `LoadModule` lines for `mod_auth_basic` and `mod_auth_digest`.

Check                   ! Result                                                                    ! State
------------------------+---------------------------------------------------------------------------+----------
WebDAV modules          ! dav_fs_module, dav_lock_module, dav_module                                ! [WARNING]
Status module           ! status_module                                                             ! [WARNING]
Autoindex module        ! autoindex_module                                                          ! [WARNING]
Proxy modules           ! proxy_ajp_module, proxy_balancer_module, proxy_connect_module and 11 more ! [WARNING]
User directories module ! userdir_module                                                            ! [WARNING]
Info module             ! info_module                                                               ! [WARNING]
Basic and digest auth   ! auth_basic_module, auth_digest_module                                     ! [WARNING]
```

The same host, ignoring the module a site knowingly runs:

```bash
sudo ./apache-httpd-security --brief --ignore=^Status
```

```text
6 of 15 checks failed.
```

A host whose worker account and runtime paths are wrong. The `Detail` column carries the reasoning:

```bash
sudo ./apache-httpd-security --brief
```

```text
11 of 16 checks failed.

Check               ! Result                    ! Detail                                                                      ! State
--------------------+---------------------------+-----------------------------------------------------------------------------+----------
Worker account      ! nobody:nobody (uid 65534) ! `nobody` is shared with other daemons; uid 65534 is not below UID_MIN 1000. ! [WARNING]
Config other write  ! 1 of 16 files             ! /etc/httpd/conf.d/zz-bad.conf (0646)                                        ! [WARNING]
Core dump directory ! /var/www/html             ! inside the document root.                                                   ! [WARNING]
Lock file           ! default in /tmp           ! writable beyond its owner (1777).                                           ! [WARNING]
```

A hardened host:

```bash
sudo ./apache-httpd-security
```

```text
Everything is ok. All 16 checks passed.

Check                   ! Result                       ! State
------------------------+------------------------------+------
Log config module       ! log_config_module loaded     ! [OK]
WebDAV modules          ! WebDAV modules not loaded    ! [OK]
...
```


## States

* Returns OK if every check that could be carried out passed.
* Returns WARN (or CRIT with `--severity=crit`) if at least one check failed:
    * a module CIS recommends disabling is loaded, or the log config module is missing,
    * the worker account runs as root, is an account shared with other daemons (`daemon`, `nfsnobody`, `nobody`, `nogroup`), has a uid at or above `UID_MIN`, or a running process uses an account other than the configured one,
    * a configuration file is not owned by `root:root`, or is writable by other,
    * the core dump directory, the lock file directory, the process ID file directory or the scoreboard file directory sits inside the document root, is not owned by root, or is writable beyond its owner,
    * a request limit is above the value the benchmark recommends, or is zero, which lifts the limit for `LimitRequestBody` and `LimitRequestFields` and breaks every request for `LimitRequestLine` and `LimitRequestFieldSize`.
* Returns UNKNOWN if neither `httpd` nor `apachectl` is found, if the binary given via `--command` does not exist, or if the configuration does not parse, in which case the binary produces no output at all.
* A check that cannot be carried out, because a directory could not be read for example, is reported as not evaluated. It does not count towards the result and does not drive the state.
* If `--match` and `--ignore` between them exclude every check, the plugin prints "Nothing checked." and returns the state given by `--no-match-severity` (OK by default).
* `--always-ok` masks a WARN or CRIT as OK.


## Perfdata / Metrics

| Name | Type | Description |
|------|------|-------------|
| apache_httpd_checks_evaluated | Number | Number of checks that could be carried out on this run. |
| apache_httpd_checks_failed | Number | Number of checks that failed. |
| apache_httpd_modules_loaded | Number | Total number of modules the server has loaded. |


## Troubleshooting

### `returned nothing ... The server configuration does not parse.`

The control binary exits without printing anything when the configuration test fails. Run `httpd -t` (or `apachectl -t` on Debian and Ubuntu) by hand to see the syntax error, fix it, and the check reports again. Note that the server keeps running on its last good configuration while this is the case, so the check failing here says nothing about availability.

### `Apache httpd does not seem to be installed`

Neither `httpd` nor `apachectl` was found in the `PATH` of the account running the check. On a host where the binary lives outside the usual locations, point at it with `--command=/path/to/httpd`.

### Every module check fires on a fresh installation

That is expected on the Red Hat family, which ships a `LoadModule` line for every module it packages. Work through the recommendations, or exclude the ones the host knowingly needs with `--ignore`. The Debian family ships a much smaller default set and starts from a better position.

### The status module check fires on a host you monitor

`mod_status` is what the `apache-httpd-status` check reads, so a host running that check will keep failing this one. Exclude it deliberately with `--ignore=^Status module$` and keep the rest of the report.

### `Request body limit` fires on a fresh installation

Expected. A configuration that never mentions `LimitRequestBody` does not leave the request body unlimited, it caps it at 1 GiB, which is far above the 102400 bytes the benchmark asks for. Write the directive out, at a value that covers the largest upload the site has to accept, and reload.

Note what the directive does before lowering it on a host that takes uploads: a request body above the limit is answered with `413 Request Entity Too Large` by httpd itself, so the application never sees the upload, and the application's own upload settings (`upload_max_filesize` and `post_max_size` in PHP, for example) never come into play. Raise the limit for the vhost, directory or location that needs it, and exclude this check with `--ignore=^Request body limit$` on a host where a larger limit is deliberate.

### The worker account check fires although the account is correct

Compare the numeric id with `UID_MIN` from `/etc/login.defs`. An account created as a regular user rather than as a system account gets an id at or above that boundary, which is what the check reports. Recreate it with `useradd --system`, or accept the finding deliberately with `--ignore`.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
