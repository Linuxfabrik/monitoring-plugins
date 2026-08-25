# Check openstack-cinder-list


## Overview

Lists the OpenStack Cinder block storage volumes of a project and reports the status of every one of them. Alerts when a volume sits in a status that needs attention, for example error or maintenance, or when the Block Storage API cannot be reached in time. The state reported per volume status is configurable, so a cloud on which unattached volumes are a problem can say so. Supports extended reporting via `--lengthy`.

**Important Notes:**

* You have to provide a path to an rc file to authenticate. The rc file should contain the standard OpenStack environment variables such as `OS_AUTH_URL`, `OS_USERNAME`, `OS_PASSWORD`, `OS_PROJECT_NAME` and `OS_PROJECT_DOMAIN_NAME`. A domain is taken from the id variable if the rc file sets one, otherwise from the name variable, and falls back to the `default` domain if it sets neither.
* A cloud whose certificate a private CA signed is covered by `OS_CACERT` in the rc file, naming either a PEM file or a directory of hashed certificates. That bundle replaces the trust store of the host for this check, the same way `curl --cacert` does, so a public CA no longer verifies while it is set.
* The check reuses the Keystone token of the previous run. A run that has a valid token makes a single API request, a run that has to authenticate first makes one more. `--cache-expire` bounds the reuse, and a token is never reused past its own lifetime. A password that changed therefore takes until the cached token expires to show up as a failed authentication.
* The check reports the volumes of the project the rc file scopes to, not of the whole cloud. Point it at one service per project.
* A volume that nobody attached sits in `available`, which is an ordinary state and not an alert by default. On a cloud where every volume belongs to an instance, `--severity=available,warn` turns a forgotten volume into something visible: it keeps costing money for as long as it exists.
* The migration status of a volume and the storage host it lives on are reported by Cinder only to a project with administrative rights, so neither appears in the output of an ordinary project account and neither can be filtered on.
* A volume is listed as attached to `<server id>:<device>`. That server id is the same one [openstack-nova-list](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/openstack-nova-list/) reports with `--lengthy`, which is where the name behind it can be looked up.

**Data Collection:**

* Authenticates against the Keystone Identity v3 API with the credentials from the rc file, and reuses the resulting token on the following runs
* Lists every volume of the project, following the pagination of the Block Storage API so that projects with more than a thousand volumes are covered too
* Maps every Cinder volume status to a state, counts the volumes per status, sums up their size and reports the most recent status change across all of them
* `--match` and `--ignore` filter by volume name, `--match-type` and `--match-zone` (each with an `--ignore-` counterpart) by volume type and availability zone
* `--brief` hides the volumes that are fine, `--lengthy` adds the id, the volume type, the availability zone, whether the volume is bootable, what it is attached to and the creation date
* A column that no volume filled in is left out of the table, so a project whose volumes are all unattached does not carry an empty attachment column


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/openstack-cinder-list> |
| Nagios/Icinga Check Name              | `check_openstack_cinder_list` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Requirements                          | An rc file with OpenStack credentials, readable by the user running the check |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-cache.db` |


## Help

```text
usage: openstack-cinder-list [-h] [-V] [--always-ok] [--brief]
                             [--cache-expire CACHE_EXPIRE] [--ignore IGNORE]
                             [--ignore-type IGNORE_TYPE]
                             [--ignore-zone IGNORE_ZONE] [--insecure]
                             [--lengthy] [--match MATCH]
                             [--match-type MATCH_TYPE]
                             [--match-zone MATCH_ZONE]
                             [--no-match-severity {ok,warn,crit,unknown}]
                             [--no-perfdata] [--no-proxy] [--proxy PROXY]
                             [--rc-file RC_FILE] [--severity SEVERITY]
                             [--timeout TIMEOUT]

Lists the OpenStack Cinder block storage volumes of a project and reports the
status of every one of them. Alerts when a volume sits in a status that needs
attention, for example error or maintenance, or when the Block Storage API
cannot be reached in time. The state reported per volume status is
configurable, so a cloud on which unattached volumes are a problem can say so.
Supports extended reporting via --lengthy.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --brief               Hide the rows that are within the thresholds and show
                        only those in a WARN or CRIT state. Perfdata and
                        alerting are unaffected: every item still emits
                        performance data and still drives the overall check
                        state, so this is safe to leave on.
  --cache-expire CACHE_EXPIRE
                        The amount of time after which the credential/data
                        cache expires, in minutes. Default: 50
  --ignore IGNORE       Any item matching this Python regex will be ignored.
                        Can be specified multiple times. Example:
                        `(?i)linuxfabrik` for a case-insensitive match.
                        Matched against the volume name.
  --ignore-type IGNORE_TYPE
                        Any item matching this Python regex will be ignored.
                        Can be specified multiple times. Example:
                        `(?i)linuxfabrik` for a case-insensitive match.
                        Matched against the volume type, for example `ssd`.
  --ignore-zone IGNORE_ZONE
                        Any item matching this Python regex will be ignored.
                        Can be specified multiple times. Example:
                        `(?i)linuxfabrik` for a case-insensitive match.
                        Matched against the availability zone of the volume.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --lengthy             Extended reporting.
  --match MATCH         Filter by this Python regular expression. Case-
                        sensitive by default; use `(?i)` for case-insensitive
                        matching. Can be specified multiple times. If both
                        `--match` and `--ignore` are given, an item must match
                        `--match` AND not match `--ignore` to be reported
                        (include first, exclude second). Examples:
                        `(?i)example` to match "example" regardless of case.
                        `^(?!.*example).*$` to match any string except
                        "example" (negative lookahead). Matched against the
                        volume name.
  --match-type MATCH_TYPE
                        Filter by this Python regular expression. Case-
                        sensitive by default; use `(?i)` for case-insensitive
                        matching. Can be specified multiple times. If both
                        `--match` and `--ignore` are given, an item must match
                        `--match` AND not match `--ignore` to be reported
                        (include first, exclude second). Examples:
                        `(?i)example` to match "example" regardless of case.
                        `^(?!.*example).*$` to match any string except
                        "example" (negative lookahead). Matched against the
                        volume type, for example `ssd`.
  --match-zone MATCH_ZONE
                        Filter by this Python regular expression. Case-
                        sensitive by default; use `(?i)` for case-insensitive
                        matching. Can be specified multiple times. If both
                        `--match` and `--ignore` are given, an item must match
                        `--match` AND not match `--ignore` to be reported
                        (include first, exclude second). Examples:
                        `(?i)example` to match "example" regardless of case.
                        `^(?!.*example).*$` to match any string except
                        "example" (negative lookahead). Matched against the
                        availability zone of the volume.
  --no-match-severity {ok,warn,crit,unknown}
                        State to report when no item matches the filters and
                        nothing is checked. Default: ok
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --no-proxy            Do not use a proxy, not even one the environment
                        names. Overrides `--proxy`.
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
  --rc-file RC_FILE     Path to a rc file containing OpenStack connection
                        parameters like OS_USERNAME (instead of specifying
                        them on the command line). Example: `--rc-
                        file=/var/spool/icinga2/.openstack.cnf`. Default:
                        /var/spool/icinga2/.openstack.cnf
  --severity SEVERITY   State to report for volumes in a given status, as
                        `STATUS,STATE`. STATUS is a Cinder volume status such
                        as `available`, case-insensitive. STATE is one of
                        `ok`, `warn`, `crit` or `unknown`. Overrides the
                        built-in state for that status only, every other
                        status keeps its default. Can be specified multiple
                        times. Example: `--severity=available,warn
                        --severity=maintenance,crit`
  --timeout TIMEOUT     Network timeout in seconds. Applies to the whole run,
                        not to a single request. Default: 8 (seconds)

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/openstack-cinder-list/
```


## Usage Examples

```bash
./openstack-cinder-list --rc-file=/var/spool/icinga2/.openstack.cnf
```

Output:

```text
24 volumes checked: 2 available, 22 in-use. 1.3TiB in total. Last status change 2026-07-17 12:41:47 UTC (1M 1W ago).

Name                  ! Size     ! Updated (UTC)                   ! Status
----------------------+----------+---------------------------------+----------
web01--boot           ! 20.0GiB  ! 2026-06-02 08:59:55 (2M 3W ago) ! in-use
db01--data            ! 100.0GiB ! 2026-07-13 14:28:28 (1M 1W ago) ! in-use
spare01               ! 80.0GiB  ! 2026-07-17 12:41:47 (1M 1W ago) ! available
```

Everything a volume carries, for the ones of a single type:

```bash
./openstack-cinder-list --rc-file=/var/spool/icinga2/.openstack.cnf --match-type=^ssd$ --lengthy
```

Output:

```text
1 volume checked: 1 in-use. 20.0GiB in total. Last status change 2026-06-02 08:59:55 UTC (2M 3W ago).

Name        ! ID                                   ! Type ! Zone   ! Size    ! Bootable ! Attached to                                   ! Created (UTC)                   ! Updated (UTC)                   ! Status
------------+--------------------------------------+------+--------+---------+----------+-----------------------------------------------+---------------------------------+---------------------------------+-------
web01--boot ! 94dff704-5554-4a1d-b5eb-8dd1d0ea8099 ! ssd  ! zone-a ! 20.0GiB ! true     ! a5b52fe9-0bd2-4983-bf9b-fa8ef04c3226:/dev/vda ! 2026-06-02 08:59:22 (2M 3W ago) ! 2026-06-02 08:59:55 (2M 3W ago) ! in-use
```

Report a volume nobody attached, and show only what needs attention:

```bash
./openstack-cinder-list --rc-file=/var/spool/icinga2/.openstack.cnf --severity=available,warn --brief
```

Output:

```text
24 volumes checked: 2 available, 22 in-use. 1.3TiB in total. Last status change 2026-07-17 12:41:47 UTC (1M 1W ago).

Name    ! Size    ! Updated (UTC)                   ! Status
--------+---------+---------------------------------+--------------------
spare01 ! 80.0GiB ! 2026-07-17 12:41:47 (1M 1W ago) ! available [WARNING]
```


## States

The state per volume status is what `--severity` overrides. The defaults are:

| State | Volume status |
|----|----|
| OK | `attaching`, `available`, `backing-up`, `creating`, `deleting`, `detaching`, `downloading`, `extending`, `in-use`, `managing`, `reserved`, `restoring-backup`, `retyping`, `uploading` |
| WARN | `awaiting-transfer`, `maintenance` |
| CRIT | `error`, `error_backing-up`, `error_deleting`, `error_extending`, `error_managing`, `error_restoring` |

The six `error*` states are the ones that stay until somebody acts on them. `maintenance` is a volume the cloud has taken out of service, usually after a migration that did not finish, and `awaiting-transfer` is an offer to another project that nobody accepted. Everything else is either a healthy volume or a step on the way to one: unlike an instance, a volume passes through its transitional states in seconds to minutes, so alerting on them would fire on ordinary work rather than on a problem.

* UNKNOWN if a volume reports a status this check does not rate. A later Cinder release may add one, and guessing its severity would be worse than saying so. Rate it with `--severity=<status>,<state>`.
* UNKNOWN if the rc file cannot be read, if a `--match` / `--ignore` pattern is not a valid regular expression, or if a `--match-type` / `--match-zone` filter is given while the API reports that field for no volume at all.
* WARN if the Block Storage API cannot be reached inside `--timeout` or refuses the account.
* If every volume is filtered out by `--match` or `--ignore`, the state is the one `--no-match-severity` names.
* `--always-ok` reports OK regardless.


## Perfdata / Metrics

| Name | Type | Description |
|------|------|-------------|
| total | Number | Volumes checked, after the filters |
| size | Bytes | Size of all checked volumes together |
| attaching | Number | Volumes in this status |
| available | Number | Volumes in this status |
| awaiting-transfer | Number | Volumes in this status |
| backing-up | Number | Volumes in this status |
| creating | Number | Volumes in this status |
| deleting | Number | Volumes in this status |
| detaching | Number | Volumes in this status |
| downloading | Number | Volumes in this status |
| error | Number | Volumes in this status |
| error_backing-up | Number | Volumes in this status |
| error_deleting | Number | Volumes in this status |
| error_extending | Number | Volumes in this status |
| error_managing | Number | Volumes in this status |
| error_restoring | Number | Volumes in this status |
| extending | Number | Volumes in this status |
| in-use | Number | Volumes in this status |
| maintenance | Number | Volumes in this status |
| managing | Number | Volumes in this status |
| reserved | Number | Volumes in this status |
| restoring-backup | Number | Volumes in this status |
| retyping | Number | Volumes in this status |
| uploading | Number | Volumes in this status |

A status a later Cinder release adds is reported as a metric of its own as soon as a volume sits in it.


## Troubleshooting

### `Failed to authenticate.`

Keystone rejected the credentials. Verify `OS_USERNAME`, `OS_PASSWORD` and the project in the rc file by sourcing it and running `openstack volume list` by hand. A password that was changed recently takes until the cached token expires to surface here, because the check reuses the token of the previous run; `--cache-expire=0` skips the cache for a single run.

An rc file that sets `OS_PROJECT_DOMAIN_NAME` or `OS_USER_DOMAIN_NAME` for a domain other than the default is worth a second look: a domain is addressed either by its id or by its name, and if the rc file sets both, the id wins and the name is dropped.

### A volume shows a status the table describes as unrated

A later Cinder release added a volume status that this check does not rate yet, and the check reports UNKNOWN rather than guessing. Rate it with `--severity=<status>,<state>` and open an issue so the default follows.

### A volume sits in `error` and nothing says why

The status is all the Block Storage API reports to a project account. `openstack volume show <id>` adds the fault message where the driver left one, and the volume log of the storage node has the rest. A volume in `error_deleting` usually needs `cinder-manage volume delete` or an administrator resetting its state.

### `The Block Storage API did not report the volume type of any volume`

`--match-type` or `--ignore-type` was given, but no volume in the answer carries a type. That happens on a cloud that defines none. Drop the filter, otherwise it would silently drop every volume and the project would read as empty.

### The certificate cannot be verified

`TLS certificate verification failed for https://...: self-signed certificate in certificate chain`

The cloud presents a certificate that no authority the host trusts has signed. Point `OS_CACERT` in the rc file at the CA bundle of the cloud, put that CA into the trust store of the host (`/etc/pki/ca-trust/source/anchors/` plus `update-ca-trust` on RHEL family, `/usr/local/share/ca-certificates/` plus `update-ca-certificates` on Debian family), or accept an unverified connection with `--insecure`. A bundle named in `OS_CACERT` that cannot be read is reported as such rather than silently falling back to the trust store.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/)
