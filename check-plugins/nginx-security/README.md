# Check nginx-security


## Overview

Checks the local security posture of an NGINX installation: which dynamic modules it loads, which account its worker processes run under, whether that account can be logged into, the ownership and permissions of the configuration directory and the process ID file, and how large a request body the server accepts. Every path is taken from the values the binary itself reports, so a setting left at its compiled-in default is checked just like one written into the configuration. Each finding maps to a copy-pasteable recommendation. Alerts when a dynamic module widens the attack surface without being needed, when the worker account is privileged or can be logged into, when a file the server relies on is readable or writable beyond root, or when the request body size is left unlimited or at the built-in default. Individual checks can be excluded with `--ignore`. Requires root or sudo.

The checks follow the "Minimize NGINX Modules", "Permissions and Ownership" and "Request Limits" controls of the CIS NGINX Benchmark.

**Important Notes:**

* The check is part of the Nginx Service Set, where it runs through the `-sudo` check command. A host that has not deployed the sudoers file makes the service report UNKNOWN until it has.
* Requires root or sudo. `nginx -T` creates the runtime directory while parsing, which an unprivileged account may not do, and the shadow database is unreadable without it.
* The check re-parses the configuration from disk. A change that has been written but not reloaded is therefore reported as if it were already in force. The worker account is the exception: it is additionally compared against the accounts the running processes actually use.
* **The configuration tree check fails on a stock installation by design.** The distributions ship `0644` for files and `0755` for directories, and the benchmark's hardening target is `0640` and `0750`, so world-readable is a finding. World-writable and world-readable are reported apart, because only the first is a defect on any system. Exclude the check with `--ignore=^Config tree access$` if the site accepts the distribution default.
* A web server running in a container shows up in the host's process list under a mapped user id. Only processes sharing this host's mount namespace are counted, so a containerised NGINX does not make the host's check report a stray account.
* Whether a loaded dynamic module is really needed is a judgement only the operator can make. The check lists what is loaded and leaves the decision; `--ignore=^Dynamic modules$` records that it has been made.
* **The request body check fails on a stock installation by design.** A configuration that never mentions `client_max_body_size` does not leave the body unlimited, it caps it at 1 MiB, which is small enough to reject an ordinary file upload with a `413` that names no cause. The benchmark asks for the limit to be written out, at a value the site has decided on. Such a value carries `(default)` in the result column.
* Every `client_max_body_size` the configuration sets is reported, whatever block it sits in, so a permissive `location` is visible even when the `http` block is restrictive. Which block a value belongs to is not resolved. The benchmark names no upper bound, because how large a request an application has to accept is an application question; only a `0`, which removes the limit entirely, is reported as a finding.

### Data Collection

Two invocations of the NGINX binary per run, both of which only read: `-V` for the compile-time paths and accounts (prefix, configuration path, process ID path, user, group, modules path), which is what every setting the configuration leaves out falls back to, and `-T` for the fully parsed configuration including every included file behind its own marker. The configuration directory is then walked and inspected with `stat`, as is the process ID file. `UID_MIN` comes from `/etc/login.defs`, the account's shell and groups from the local user database, its lock state from `/etc/shadow`, and the running worker processes from `psutil`. Nothing is stored between runs.

Symbolic links are followed, the way the benchmark's own audit does. A configuration directory that links to a modules directory elsewhere is therefore reported with the permissions of the target, which is what actually applies.


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/nginx-security> |
| Nagios/Icinga Check Name              | `check_nginx_security` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |
| Requirements                          | command-line tool `nginx`; root or sudo |
| 3rd Party Python modules              | `psutil` |
| Perfdata compatible with Prometheus   | Yes |


## Help

```text
usage: nginx-security [-h] [-V] [--always-ok] [--brief] [--command COMMAND]
                      [--ignore IGNORE] [--match MATCH]
                      [--no-match-severity {ok,warn,crit,unknown}]
                      [--no-perfdata] [--severity {warn,crit}]
                      [--timeout TIMEOUT]

Checks the local security posture of an NGINX installation: which dynamic
modules it loads, which account its worker processes run under, whether that
account can be logged into, the ownership and permissions of the configuration
directory and the process ID file, and how large a request body the server
accepts. Every path is taken from the values the binary itself reports, so a
setting left at its compiled-in default is checked just like one written into
the configuration. Each finding maps to a copy-pasteable recommendation.
Alerts when a dynamic module widens the attack surface without being needed,
when the worker account is privileged or can be logged into, when a file the
server relies on is readable or writable beyond root, or when the request body
size is left unlimited or at the built-in default. Individual checks can be
excluded with --ignore. Requires root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --brief               Hide the rows that are within the thresholds and show
                        only those in a WARN or CRIT state. Perfdata and
                        alerting are unaffected: every item still emits
                        performance data and still drives the overall check
                        state, so this is safe to leave on.
  --command COMMAND     Path to the NGINX binary. Probed automatically in the
                        PATH if not given. Example:
                        `--command=/usr/local/nginx/sbin/nginx`
  --ignore IGNORE       Any check whose name matches this Python regex will be
                        dropped from the report. Use it for a finding the site
                        knowingly accepts, for example a dynamic module the
                        service needs. Case-sensitive by default; use `(?i)`
                        for case-insensitive matching. Can be specified
                        multiple times. Example: `--ignore=^Dynamic modules$`
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
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/nginx-security/
```


## Usage Examples

A stock installation. The account side is clean out of the box, the configuration tree carries the distribution defaults:

```bash
sudo ./nginx-security
```

```text
1 of 7 checks failed.

Recommendations:
* Config tree access: `chmod o= /etc/nginx /etc/nginx/conf.d ...` (currently /etc/nginx (0755), /etc/nginx/conf.d (0755), ...)

Check              ! Result                ! Detail                                           ! State
-------------------+-----------------------+--------------------------------------------------+----------
Dynamic modules    ! none loaded           ! No dynamic module adds to the attack surface.    ! [OK]
Worker account     ! nginx (uid 101)       ! Dedicated unprivileged system account.           ! [OK]
Account shell      ! nginx: `/bin/false`   ! Cannot be logged into.                           ! [OK]
Account locked     ! nginx: locked         ! The password is locked.                          ! [OK]
Config tree owner  ! 9 paths               ! Everything belongs to `root:root`.               ! [OK]
Config tree access ! 9 of 9 paths          ! 9 paths readable by other.                       ! [WARNING]
Pid file           ! /run/nginx.pid (0644) ! Owned by `root:root` and not writable by others. ! [OK]
```

The same host with the distribution default accepted:

```bash
sudo ./nginx-security --ignore=^Config
```

```text
Everything is ok. All 5 checks passed.
```

A host whose worker runs as root, whose account can be logged into, and whose configuration anybody may rewrite:

```bash
sudo ./nginx-security --brief
```

```text
3 of 7 checks failed.

Check              ! Result            ! Detail                                                ! State
-------------------+-------------------+-------------------------------------------------------+----------
Worker account     ! root (uid 0)      ! runs as root; member of root; processes run as nginx. ! [WARNING]
Account shell      ! root: `/bin/bash` ! An interactive login shell.                           ! [WARNING]
Config tree access ! 9 of 9 paths      ! 1 path writable by other, 8 paths readable by other.  ! [WARNING]
```


## States

* Returns OK if every check that could be carried out passed.
* Returns WARN (or CRIT with `--severity=crit`) if at least one check failed:
    * a dynamic module is loaded, which the operator has to confirm is needed,
    * there is no `user` directive, or the worker account runs as root, is an account shared with other daemons (`daemon`, `nfsnobody`, `nobody`, `nogroup`), has a uid at or above `UID_MIN`, is a member of a privileged group (`adm`, `root`, `sudo`, `wheel`), or a running process uses an account other than the configured one,
    * the worker account has a shell the system lists in `/etc/shells`,
    * the worker account carries a password that can be used, or none at all,
    * something below the configuration directory is not owned by `root:root`, or is readable or writable by other,
    * the process ID file is not owned by `root:root`, or its mode is wider than `0644`,
    * `client_max_body_size` is not configured anywhere, or is set to `0`, which removes the limit.
* Returns UNKNOWN if `nginx` is not found, if the binary given via `--command` does not exist, or if the configuration does not parse, in which case `nginx -T` produces no dump at all.
* A check that cannot be carried out is reported as not evaluated and neither counts nor drives the state. That covers an account served by a directory service rather than by local files, a shadow database the check may not read, and a process ID file that does not exist because the server is not running.
* If `--match` and `--ignore` between them exclude every check, the plugin prints "Nothing checked." and returns the state given by `--no-match-severity` (OK by default).
* `--always-ok` masks a WARN or CRIT as OK.


## Perfdata / Metrics

| Name | Type | Description |
|------|------|-------------|
| nginx_checks_evaluated | Number | Number of checks that could be carried out on this run. |
| nginx_checks_failed | Number | Number of checks that failed. |
| nginx_dynamic_modules_loaded | Number | Number of dynamic modules the configuration loads. |


## Troubleshooting

### `returned nothing ... The server configuration does not parse.`

`nginx -T` prints no dump when the configuration test fails. Run `nginx -t` by hand to see the syntax error. The server keeps running on its last good configuration while this is the case, so the check failing here says nothing about availability.

### `NGINX does not seem to be installed`

`nginx` was not found in the `PATH` of the account running the check. On a host where the binary lives outside the usual locations, for example a source build under `/usr/local/nginx`, point at it with `--command=/usr/local/nginx/sbin/nginx`.

### The configuration tree check fails on a fresh installation

Expected. Every distribution ships `0644` for files and `0755` for directories, while the benchmark wants `0640` and `0750`. Tighten the tree, or exclude the check with `--ignore=^Config tree access$`. Look at the `Detail` column first: world-**writable** is a defect worth fixing on any system, world-**readable** is the hardening target.

### The modules directory keeps being reported after `chmod -R o= /etc/nginx`

`/etc/nginx/modules` is usually a symlink to a directory elsewhere, and `chmod -R` does not follow it. Tighten the target instead, or accept it: the module files themselves are shipped by the package and readable anyway.

### `Request body limit` fires on a fresh installation

Expected, and the reason is worth knowing before the value is changed: a request body above `client_max_body_size` is answered with `413 Request Entity Too Large` by NGINX itself, so the request never reaches the application behind it, and the application's own upload settings (`upload_max_filesize` and `post_max_size` in PHP, for example) never come into play. An unconfigured directive caps every request at 1 MiB.

Set `client_max_body_size` in the `http` block to the largest request the site has to accept, raise it in the `location` blocks that take uploads, and reload.

### `Account locked` is not evaluated

Either the check is not running as root, in which case `/etc/shadow` cannot be read, or the worker account is served by a directory service and has no local shadow entry. The message says which of the two it is.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
