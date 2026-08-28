# Check openstack-nova-list


## Overview

Lists the OpenStack Nova compute instances (virtual servers) of a project and reports the status of every one of them. Alerts when an instance sits in a status that needs attention, for example ERROR, or when the Nova API cannot be reached in time. Also alerts on an instance Nova lists as ACTIVE while the hypervisor last reported it as anything but running, which the Nova status itself never shows. The state reported per Nova status is configurable, so a cloud on which powered-off instances are a problem can say so. Supports extended reporting via `--lengthy`.

**Important Notes:**

* You have to provide a path to an rc file to authenticate. The rc file should contain the standard OpenStack environment variables such as `OS_AUTH_URL`, `OS_USERNAME`, `OS_PASSWORD`, `OS_PROJECT_NAME` and `OS_PROJECT_DOMAIN_NAME`. A domain is taken from the id variable if the rc file sets one, otherwise from the name variable, and falls back to the `default` domain if it sets neither.
* A cloud whose certificate a private CA signed is covered by `OS_CACERT` in the rc file, naming either a PEM file or a directory of hashed certificates. That bundle replaces the trust store of the host for this check, the same way `curl --cacert` does, so a public CA no longer verifies while it is set.
* The check reuses the Keystone token of the previous run. A run that has a valid token makes a single API request, a run that has to authenticate first makes one more. `--cache-expire` bounds the reuse, and a token is never reused past its own lifetime. A password that changed therefore takes until the cached token expires to show up as a failed authentication. The token is stored in the plugin cache database, which lives in a directory only the user running the check can read.
* The check reports the instances of the project the rc file scopes to, not of the whole cloud. Point it at one service per project.
* Instances whose Nova cell does not answer are left out of the listing by the Compute API itself, and the check cannot tell them apart from instances that do not exist. A cell outage therefore shows up as a shrinking instance count, not as an alert. Trend the `total` metric to catch it.
* A Nova status says what was last done to an instance, not what the hypervisor sees. It is built from the VM state and the running task alone, never from the power state, so an instance whose domain is paused, shut down or gone keeps reporting ACTIVE. Nova compares the two itself and leaves `paused` and a domain it cannot find alone; the remaining cases it hands to the stop API, and the status follows only once that call gets through. The check therefore reads the power state separately and rates the disagreement with `--power-mismatch-severity`. None of this says anything about the guest operating system: a kernel panic or a broken network stack leaves the domain running and the instance ACTIVE, and only a ping or agent check sees it.
* The compute host an instance runs on is reported by Nova only to a project with administrative rights, because it sits behind the `os_compute_api:os-extended-server-attributes` policy, which defaults to admin. With an ordinary project account the Host column stays out of the table, and `--match-host` and `--ignore-host` report UNKNOWN instead of quietly matching nothing.

**Data Collection:**

* Authenticates against the Keystone Identity v3 API with the credentials from the rc file, and reuses the resulting token on the following runs
* Lists every instance of the project, following the pagination of the Compute API so that clouds with more than a thousand instances are covered too
* Maps every Nova server status to a state, counts the instances per status, and reports the most recent status change across all of them
* `--match` and `--ignore` filter by instance name, `--match-zone`, `--match-vm-state` and `--match-host` (each with an `--ignore-` counterpart) by availability zone, VM state and compute host
* `--brief` hides the instances that are fine, `--lengthy` adds the id, the host id, the availability zone, the addresses, the creation date and the task Nova is currently running on the instance
* The id and the host id are shortened to ten characters, the way a short commit hash stands in for the full one
* Compares the power state the hypervisor last reported against the status, for every instance that is ACTIVE with no task running, which is the same guard Nova applies before it looks at the two
* A column that no instance filled in is left out of the table, so the compute host does not take up space on a project that is not allowed to see it


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/openstack-nova-list> |
| Nagios/Icinga Check Name              | `check_openstack_nova_list` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Requirements                          | An rc file with OpenStack credentials, readable by the user running the check |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-cache.db` |


## Help

```text
usage: openstack-nova-list [-h] [-V] [--always-ok] [--brief]
                           [--cache-expire CACHE_EXPIRE] [--ignore IGNORE]
                           [--ignore-host IGNORE_HOST]
                           [--ignore-vm-state IGNORE_VM_STATE]
                           [--ignore-zone IGNORE_ZONE] [--insecure]
                           [--lengthy] [--match MATCH]
                           [--match-host MATCH_HOST]
                           [--match-vm-state MATCH_VM_STATE]
                           [--match-zone MATCH_ZONE]
                           [--no-match-severity {ok,warn,crit,unknown}]
                           [--no-perfdata] [--no-proxy]
                           [--power-mismatch-severity {ok,warn,crit,unknown}]
                           [--proxy PROXY] [--rc-file RC_FILE]
                           [--severity SEVERITY] [--timeout TIMEOUT]

Lists the OpenStack Nova compute instances (virtual servers) of a project and
reports the status of every one of them. Alerts when an instance sits in a
status that needs attention, for example ERROR, or when the Nova API cannot be
reached in time. Also alerts on an instance Nova lists as ACTIVE while the
hypervisor last reported it as anything but running, which the Nova status
itself never shows. The state reported per Nova status is configurable, so a
cloud on which powered-off instances are a problem can say so. Supports
extended reporting via --lengthy.

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
                        Matched against the instance name.
  --ignore-host IGNORE_HOST
                        Any item matching this Python regex will be ignored.
                        Can be specified multiple times. Example:
                        `(?i)linuxfabrik` for a case-insensitive match.
                        Matched against the compute host the instance runs on.
  --ignore-vm-state IGNORE_VM_STATE
                        Any item matching this Python regex will be ignored.
                        Can be specified multiple times. Example:
                        `(?i)linuxfabrik` for a case-insensitive match.
                        Matched against the VM state, which is the lower-case
                        stable state the server status is derived from, for
                        example `active` or `stopped`.
  --ignore-zone IGNORE_ZONE
                        Any item matching this Python regex will be ignored.
                        Can be specified multiple times. Example:
                        `(?i)linuxfabrik` for a case-insensitive match.
                        Matched against the availability zone of the instance.
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
                        instance name.
  --match-host MATCH_HOST
                        Filter by this Python regular expression. Case-
                        sensitive by default; use `(?i)` for case-insensitive
                        matching. Can be specified multiple times. If both
                        `--match` and `--ignore` are given, an item must match
                        `--match` AND not match `--ignore` to be reported
                        (include first, exclude second). Examples:
                        `(?i)example` to match "example" regardless of case.
                        `^(?!.*example).*$` to match any string except
                        "example" (negative lookahead). Matched against the
                        compute host the instance runs on.
  --match-vm-state MATCH_VM_STATE
                        Filter by this Python regular expression. Case-
                        sensitive by default; use `(?i)` for case-insensitive
                        matching. Can be specified multiple times. If both
                        `--match` and `--ignore` are given, an item must match
                        `--match` AND not match `--ignore` to be reported
                        (include first, exclude second). Examples:
                        `(?i)example` to match "example" regardless of case.
                        `^(?!.*example).*$` to match any string except
                        "example" (negative lookahead). Matched against the VM
                        state, which is the lower-case stable state the server
                        status is derived from, for example `active` or
                        `stopped`.
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
                        availability zone of the instance.
  --no-match-severity {ok,warn,crit,unknown}
                        State to report when no item matches the filters and
                        nothing is checked. Default: ok
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --no-proxy            Do not use a proxy, not even one the environment
                        names. Overrides `--proxy`.
  --power-mismatch-severity {ok,warn,crit,unknown}
                        State to report for an instance Nova lists as ACTIVE
                        while the hypervisor last reported it as anything but
                        running, for example paused, shut down or gone. The
                        Nova status never shows this, and Nova does not
                        correct all of these cases by itself. Use `crit` on a
                        cloud where such an instance is an outage. Default:
                        warn
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
  --severity SEVERITY   State to report for instances in a given Nova status,
                        as `STATUS,STATE`. STATUS is a Nova server status such
                        as `SHUTOFF`, case-insensitive. STATE is one of `ok`,
                        `warn`, `crit` or `unknown`. Overrides the built-in
                        state for that status only, every other status keeps
                        its default. Can be specified multiple times. Example:
                        `--severity=SHUTOFF,warn --severity=BUILD,ok`
  --timeout TIMEOUT     Network timeout in seconds. Applies to the whole run,
                        not to a single request. Default: 8 (seconds)

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/openstack-nova-list/
```


## Usage Examples

```bash
./openstack-nova-list --rc-file=/var/spool/icinga2/rc/.openstack-myproject.rc
```

Output:

```text
7 instances checked: 1 ERROR, 1 BUILD, 1 RESCUE, 1 VERIFY_RESIZE, 1 ACTIVE, 1 PASSWORD, 1 SHUTOFF. Last status change 2026-08-25 09:00:00 UTC (2D 12h ago).

Name       ! Updated (UTC)                    ! Status
-----------+----------------------------------+------------------------
batch01    ! 2026-07-20 08:00:00 (1M 1W ago)  ! SHUTOFF
broken01   ! 2026-08-25 07:00:00 (2D 14h ago) ! RESCUE [WARNING]
db01       ! 2026-08-01 09:00:00 (3W 5D ago)  ! ERROR [CRITICAL]
new01      ! 2026-08-25 09:00:00 (2D 12h ago) ! BUILD [WARNING]
pwchange01 ! 2026-08-25 08:00:00 (2D 13h ago) ! PASSWORD
resized01  ! 2026-08-24 10:00:00 (3D 11h ago) ! VERIFY_RESIZE [WARNING]
web01      ! 2026-07-13 14:29:16 (1M 2W ago)  ! ACTIVE
```

Only the instances that need attention, with every column:

```bash
./openstack-nova-list --rc-file=/var/spool/icinga2/rc/.openstack-myproject.rc --lengthy --brief
```

Output:

```text
7 instances checked: 1 ERROR, 1 BUILD, 1 RESCUE, 1 VERIFY_RESIZE, 1 ACTIVE, 1 PASSWORD, 1 SHUTOFF. Last status change 2026-08-25 09:00:00 UTC (2D 12h ago).

Name      ! ID         ! Host ID    ! Zone   ! Addresses  ! Created (UTC)                    ! Updated (UTC)                    ! Task     ! Status
----------+------------+------------+--------+------------+----------------------------------+----------------------------------+----------+------------------------
broken01  ! bbbbbbb7-0 ! 4fd724d424 ! zone-b ! 192.0.2.17 ! 2026-07-01 10:00:00 (1M 3W ago)  ! 2026-08-25 07:00:00 (2D 14h ago) !          ! RESCUE [WARNING]
db01      ! bbbbbbb2-0 ! 4fd724d424 ! zone-a ! 192.0.2.12 ! 2026-07-13 14:30:00 (1M 2W ago)  ! 2026-08-01 09:00:00 (3W 5D ago)  !          ! ERROR [CRITICAL]
new01     ! bbbbbbb4-0 !            ! zone-b !            ! 2026-08-25 09:00:00 (2D 12h ago) ! 2026-08-25 09:00:00 (2D 12h ago) ! spawning ! BUILD [WARNING]
resized01 ! bbbbbbb5-0 ! 4fd724d424 ! zone-a ! 192.0.2.15 ! 2026-07-01 10:00:00 (1M 3W ago)  ! 2026-08-24 10:00:00 (3D 11h ago) !          ! VERIFY_RESIZE [WARNING]
```

The Host ID column is the compute host the instance sits on, obfuscated by Nova into a hash over the project and the host name. It needs no administrative rights, unlike the Host column, so on an ordinary project account it is the only thing that says which instances share a compute host and would therefore go down together. An instance that has not been scheduled onto a host yet has no host id, which is why the cell of `new01` is empty above.

The Task column names what Nova is doing to the instance at this moment. It is the one thing the Status column does not already imply: with no task running, the status determines the VM state exactly, which is why there is no separate VM state column. On a quiet cloud the column is empty for every instance and drops out of the table by itself.

Check only the instances of one availability zone:

```bash
./openstack-nova-list --rc-file=/var/spool/icinga2/rc/.openstack-myproject.rc --match-zone=^dc3-a-09$
```

Instances that are powered down on purpose are fine by default. On a cloud where they are not, say so, and silence the instances that are still building:

```bash
./openstack-nova-list --rc-file=/var/spool/icinga2/rc/.openstack-myproject.rc --severity=SHUTOFF,warn --severity=BUILD,ok
```

An instance that is ACTIVE but not running is an outage on this cloud, not something to look at tomorrow:

```bash
./openstack-nova-list --rc-file=/var/spool/icinga2/rc/.openstack-myproject.rc --power-mismatch-severity=crit
```

Output:

```text
7 instances checked: 1 HARD_REBOOT, 5 ACTIVE, 1 SHUTOFF. 3 ACTIVE instances not running on the hypervisor: 1 not found, 1 paused, 1 shutdown. Last status change 2026-07-13 14:29:16 UTC (1M 2W ago).

Name        ! Updated (UTC)                   ! Status
------------+---------------------------------+------------------------------
batch01     ! 2026-07-13 14:29:16 (1M 2W ago) ! SHUTOFF
gone01      ! 2026-07-13 14:29:16 (1M 2W ago) ! ACTIVE (not found) [CRITICAL]
healthy01   ! 2026-07-13 14:29:16 (1M 2W ago) ! ACTIVE
nocell01    ! 2026-07-13 14:29:16 (1M 2W ago) ! ACTIVE
paused01    ! 2026-07-13 14:29:16 (1M 2W ago) ! ACTIVE (paused) [CRITICAL]
rebooting01 ! 2026-07-13 14:29:16 (1M 2W ago) ! HARD_REBOOT [WARNING]
shutdown01  ! 2026-07-13 14:29:16 (1M 2W ago) ! ACTIVE (shutdown) [CRITICAL]
```

`rebooting01` is powered off too, but a task is running on it, so its status explains it and it is not counted as a mismatch. `nocell01` comes without a power state at all, which is what an unanswering cell looks like, and says nothing either way.

Check only the database instances of the project:

```bash
./openstack-nova-list --rc-file=/var/spool/icinga2/rc/.openstack-myproject.rc --match=^db
```


## States

The overall state is the worst state of all instances that survived `--match` and `--ignore`.

Every status the Compute API can report is rated, and `--severity` overrides the rating of a single status without touching the others:

| Nova Status | Default State | Meaning |
|----|----|----|
| ACTIVE | OK | The instance is running. |
| BUILD | WARN | The instance has not finished its original build. Normal for a few minutes after creation, a problem when it lasts. Set `--severity=BUILD,ok` on a cloud that creates instances all day. |
| DELETED | CRIT | The instance is deleted. The Compute API does not normally list these. |
| ERROR | CRIT | The instance is in error. |
| HARD_REBOOT | WARN | The instance is hard rebooting, the equivalent of pulling the power plug. |
| MIGRATING | OK | The instance is being live migrated. |
| PASSWORD | OK | An authorized user is resetting the root password. Nova only accepts this on a running instance, so the instance itself is healthy. |
| PAUSED | WARN | The instance is paused. |
| REBOOT | OK | The instance is in a soft reboot. |
| REBUILD | WARN | The instance is being rebuilt from an image. |
| RESCUE | WARN | The instance runs a rescue image instead of its workload. A deliberate administrative action, but not a state to leave it in. |
| RESIZE | WARN | The instance is down while its data is copied to the new flavor. |
| REVERT_RESIZE | WARN | A resize or migration is being reverted and the original instance is restarting. |
| SHELVED | OK | The instance is shelved and will be offloaded after the shelve offload time. |
| SHELVED_OFFLOADED | OK | The shelved instance was removed from its compute host and needs an unshelve to be used again. |
| SHUTOFF | OK | The instance was powered down, either through the API or from inside the guest. Set `--severity=SHUTOFF,warn` if an instance that is off is a problem in your cloud. |
| SOFT_DELETED | WARN | The instance is marked as deleted and can still be restored until the reclaim interval expires. |
| SUSPENDED | OK | The instance is suspended, its memory written to disk. |
| UNKNOWN | CRIT | The Compute API cannot determine the state, typically because part of the infrastructure is down. |
| VERIFY_RESIZE | WARN | The resize is waiting to be confirmed or reverted. It stays here until somebody acts. |

Further:

* UNKNOWN for a status that a later Nova release adds and this check does not rate yet. The status is reported by name, so `--severity` can rate it without waiting for a plugin update.
* UNKNOWN if `--severity` names a status or a state that does not exist, or if any `--match` or `--ignore` pattern is not a valid regular expression.
* UNKNOWN if a `--match-` or `--ignore-` filter names a field the Compute API did not report for a single instance. That is the normal answer for `--match-host` on a project without administrative rights, and it beats dropping every instance without saying why.
* WARN if the OpenStack API cannot be reached within `--timeout`, refuses the credentials, or answers with an error. A cloud that does not answer says nothing about the instances in it, so this does not silently pass as OK.
* `--power-mismatch-severity` decides the state for an instance that is ACTIVE while the hypervisor last reported it as anything but running. Default: WARN. The power state is named in the Status column next to ACTIVE, for example `ACTIVE (paused)`, and the summary line counts the instances per power state.

    | Power State | Meaning |
    |----|----|
    | not found | The hypervisor does not know this domain. Nova logs it and takes no further action, so it stays this way. Nova spells this state `pending`, which is misleading once an instance is ACTIVE. |
    | paused | The domain is paused. Often an external action such as a snapshot, but also what KVM does to a domain that hit an I/O error. Nova logs it and takes no further action. |
    | shutdown | The domain is powered off. Nova asks the stop API to move the instance to SHUTOFF; while that is pending, or if it keeps failing, the status stays ACTIVE. |
    | crashed | The domain crashed. Treated like `shutdown` by Nova. |
    | suspended | The domain is suspended. Nova asks the stop API to move the instance to SHUTOFF. |

* `--no-match-severity` decides the state when `--match` or `--ignore` leaves nothing to check. Default: OK.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

One metric per Nova server status, so every status keeps a series in Grafana even while it is zero, plus the total.

| Name | Type | Description |
|----|----|----|
| ACTIVE | Number | Number of instances in this status. |
| BUILD | Number | Number of instances in this status. |
| DELETED | Number | Number of instances in this status. |
| ERROR | Number | Number of instances in this status. |
| HARD_REBOOT | Number | Number of instances in this status. |
| MIGRATING | Number | Number of instances in this status. |
| PASSWORD | Number | Number of instances in this status. |
| PAUSED | Number | Number of instances in this status. |
| REBOOT | Number | Number of instances in this status. |
| REBUILD | Number | Number of instances in this status. |
| RESCUE | Number | Number of instances in this status. |
| RESIZE | Number | Number of instances in this status. |
| REVERT_RESIZE | Number | Number of instances in this status. |
| SHELVED | Number | Number of instances in this status. |
| SHELVED_OFFLOADED | Number | Number of instances in this status. |
| SHUTOFF | Number | Number of instances in this status. |
| SOFT_DELETED | Number | Number of instances in this status. |
| SUSPENDED | Number | Number of instances in this status. |
| UNKNOWN | Number | Number of instances in this status. |
| VERIFY_RESIZE | Number | Number of instances in this status. |
| power_mismatch | Number | Number of instances that are ACTIVE while the hypervisor last reported them as anything but running. Carries a warning threshold of 0, so it alerts from the first instance on. |
| total | Number | Total number of instances checked. |


## Troubleshooting

### The check is killed by its own timeout

`<Timeout exceeded.><Terminated by signal 15 (Terminated).><Terminated with exit code 128 (0x80).>`

The monitoring server stopped the check before it had an answer, so this is the server's timeout and not the plugin's. Raise `--timeout` and the timeout of the check command together: the plugin gives up on its own once `--timeout` is spent, which produces a readable WARN instead of a killed process, but only as long as the command timeout is the larger of the two.

A run that has to authenticate first makes three API requests instead of one, so it is the run most likely to hit the limit. Check that the plugin cache database is writable by the user running the check, otherwise every run authenticates from scratch.

If the timeout comes and goes without a pattern, the Compute API is the place to look. `GET /servers/detail` collects the instances from every cell of the deployment and waits up to a minute for a cell database that is slow to answer, which turns an otherwise instant listing into a check that runs into its limit.

### `Cannot reach the OpenStack API: ...`

The Keystone or Compute endpoint did not answer within `--timeout`. Verify `OS_AUTH_URL` in the rc file, and that the monitoring host reaches the endpoint and its port. If the endpoint presents a certificate the host does not trust, either add the CA to the system trust store, point `OS_CACERT` in the rc file at it, or use `--insecure`.

### `Failed to authenticate.`

Keystone rejected the credentials. Verify `OS_USERNAME`, `OS_PASSWORD` and the project in the rc file by sourcing it and running `openstack server list` by hand. A password that was changed recently takes until the cached token expires to surface here, because the check reuses the token of the previous run; `--cache-expire=0` skips the cache for a single run.

An rc file that sets `OS_PROJECT_DOMAIN_NAME` or `OS_USER_DOMAIN_NAME` for a domain other than the default is worth a second look: a domain is addressed either by its id or by its name, and if the rc file sets both, the id wins and the name is dropped.

### An instance shows a status the table describes as unrated

A later Nova release added a server status that this check does not rate yet, and the check reports UNKNOWN rather than guessing. Rate it with `--severity=<STATUS>,<state>` and open an issue so the default follows.

### The certificate cannot be verified

`TLS certificate verification failed for https://...: self-signed certificate in certificate chain`

The cloud presents a certificate that no authority the host trusts has signed. Point `OS_CACERT` in the rc file at the CA bundle of the cloud, put that CA into the trust store of the host (`/etc/pki/ca-trust/source/anchors/` plus `update-ca-trust` on RHEL family, `/usr/local/share/ca-certificates/` plus `update-ca-certificates` on Debian family), or accept an unverified connection with `--insecure`. A bundle named in `OS_CACERT` that cannot be read is reported as such rather than silently falling back to the trust store.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
