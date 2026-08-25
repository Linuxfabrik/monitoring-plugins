# Check openstack-quota


## Overview

Reports how full the quotas of an OpenStack project are, for compute, block storage and network alike. Alerts when the share of a quota that is in use reaches the thresholds, so a project running out of instances, volumes or ports is noticed before the next deployment fails, and when one of the APIs cannot be reached in time. A quota the cloud reports as unlimited has nothing to run out of and is counted rather than listed. Supports extended reporting via `--lengthy`.

A full quota is the kind of failure that stays quiet: nothing breaks while it fills up, and then a deployment stops with a message somebody has to go looking for. The network quotas are the ones worth watching most closely, because a port is consumed by every single interface and by every load balancer, and `openstack limits show --absolute` does not report them at all.

**Important Notes:**

* You have to provide a path to an rc file to authenticate. The rc file should contain the standard OpenStack environment variables such as `OS_AUTH_URL`, `OS_USERNAME`, `OS_PASSWORD`, `OS_PROJECT_NAME` and `OS_PROJECT_DOMAIN_NAME`. A domain is taken from the id variable if the rc file sets one, otherwise from the name variable, and falls back to the `default` domain if it sets neither.
* A cloud whose certificate a private CA signed is covered by `OS_CACERT` in the rc file, naming either a PEM file or a directory of hashed certificates. That bundle replaces the trust store of the host for this check, the same way `curl --cacert` does, so a public CA no longer verifies while it is set.
* The check reuses the Keystone token of the previous run. A run that has a valid token makes one API request per service, a run that has to authenticate first makes one more. `--cache-expire` bounds the reuse, and a token is never reused past its own lifetime. The token is stored in the plugin cache database, which lives in a directory only the user running the check can read. A password that changed therefore takes until the cached token expires to show up as a failed authentication.
* The check reports the quotas of the project the rc file scopes to, not of the whole cloud. Point it at one service per project.
* A service the check cannot read is reported as a warning, and the quotas of the other services are still reported. On a cloud that runs no block storage or no network service of its own, name the services it does run with `--service` so the missing one stops being reported.
* A quota whose limit is `-1` is unlimited and a quota whose limit is `0` forbids the resource outright. Neither can fill up, so neither is rated against the thresholds; both are counted in the summary instead.

**Data Collection:**

* Authenticates against the Keystone Identity v3 API with the credentials from the rc file, and reuses the resulting token on the following runs
* Asks Nova, Cinder and Neutron for the quotas of the project, each in one request, and rates the share in use of every quota that has a limit
* What a reservation holds counts as in use, because a reservation is on its way to becoming a real object and the cloud counts it against the limit until it expires
* Only quotas whose usage the cloud actually counts are reported. Nova still answers with the quotas of the nova-network era (`floating_ips`, `security_groups`, `security_group_rules`, `fixed_ips`), with per-request limits that are no quota at all (`metadata_items`, `injected_files`), and with two resources it counts per user and always answers zero for (`key_pairs`, `server_group_members`). Reporting any of them would claim "0 of 100 in use" about something nobody is counting. Neutron is the authority on the network resources, and it is asked directly
* Cinder is asked for the quota set rather than for its limits, so the quotas of the individual volume types are covered as well: a project can sit against the quota of one volume type while its overall storage quota is nearly empty
* RAM is reported in bytes although Nova counts it in mebibytes, and volume storage likewise although Cinder counts it in gibibytes
* `--match` and `--ignore` filter by quota name, `--service` limits the check to the services named
* `--brief` hides the quotas that are fine, `--lengthy` adds what is reserved, what is left and the limit


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/openstack-quota> |
| Nagios/Icinga Check Name              | `check_openstack_quota` |
| Check Interval Recommendation         | Every 15 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Requirements                          | An rc file with OpenStack credentials, readable by the user running the check |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-cache.db` |


## Help

```text
usage: openstack-quota [-h] [-V] [--always-ok] [--brief]
                       [--cache-expire CACHE_EXPIRE] [-c CRIT]
                       [--ignore IGNORE] [--insecure] [--lengthy]
                       [--match MATCH]
                       [--no-match-severity {ok,warn,crit,unknown}]
                       [--no-perfdata] [--no-proxy] [--proxy PROXY]
                       [--rc-file RC_FILE]
                       [--service {compute,network,volume}]
                       [--timeout TIMEOUT] [-w WARN]

Reports how full the quotas of an OpenStack project are, for compute, block
storage and network alike. Alerts when the share of a quota that is in use
reaches the thresholds, so a project running out of instances, volumes or
ports is noticed before the next deployment fails, and when one of the APIs
cannot be reached in time. A quota the cloud reports as unlimited has nothing
to run out of and is counted rather than listed. Supports extended reporting
via --lengthy.

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
  -c, --critical CRIT   CRIT threshold for the share of a quota that is in
                        use, in percent. Only applies to a quota that has a
                        limit. Supports Nagios ranges. Default: 90
  --ignore IGNORE       Any item matching this Python regex will be ignored.
                        Can be specified multiple times. Example:
                        `(?i)linuxfabrik` for a case-insensitive match.
                        Matched against the quota name, which is the resource
                        prefixed with its service, for example `compute_cores`
                        or `network_port`.
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
                        quota name, which is the resource prefixed with its
                        service, for example `compute_cores` or
                        `network_port`.
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
  --service {compute,network,volume}
                        OpenStack service to report the quotas of. Can be
                        specified multiple times. A service that does not
                        answer is reported as a warning, so name the ones this
                        cloud actually runs. Example: `--service=compute
                        --service=network`. If not specified, all of them are
                        checked.
  --timeout TIMEOUT     Network timeout in seconds. Applies to the whole run,
                        not to a single request. Default: 8 (seconds)
  -w, --warning WARN    WARN threshold for the share of a quota that is in
                        use, in percent. Only applies to a quota that has a
                        limit. Supports Nagios ranges. Default: 80

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/openstack-quota/
```


## Usage Examples

```bash
./openstack-quota --rc-file=/var/spool/icinga2/.openstack.cnf
```

Output:

```text
18 quotas checked, the fullest is network_port at 13.0%. 17 of them have no limit.

Service ! Resource            ! Used    ! Limit   ! Usage
--------+---------------------+---------+---------+------
Network ! port                ! 26      ! 200     ! 13.0%
Compute ! instances           ! 21      ! 200     ! 10.5%
Compute ! cores               ! 38      ! 500     ! 7.6%
Volume  ! volumes             ! 24      ! 500     ! 4.8%
Compute ! ram                 ! 78.0GiB ! 2.0TiB  ! 3.8%
Network ! security_group_rule ! 30      ! 1000    ! 3.0%
Volume  ! gigabytes           ! 1.3TiB  ! 48.8TiB ! 2.7%
Network ! network             ! 2       ! 100     ! 2.0%
Network ! subnet              ! 2       ! 100     ! 2.0%
Network ! security_group      ! 4       ! 500     ! 0.8%
```

Only the network quotas, with the columns `--lengthy` adds:

```bash
./openstack-quota --rc-file=/var/spool/icinga2/.openstack.cnf --service=network --lengthy
```

Output:

```text
network_port at 95.0% [CRITICAL], network_security_group_rule at 85.0% [WARNING], 7 quotas checked.

Service ! Resource            ! Used ! Reserved ! Free ! Limit ! Usage
--------+---------------------+------+----------+------+-------+-----------------
Network ! port                ! 190  ! 2        ! 10   ! 200   ! 95.0% [CRITICAL]
Network ! security_group_rule ! 850  !          ! 150  ! 1000  ! 85.0% [WARNING]
Network ! floatingip          ! 12   !          ! 88   ! 100   ! 12.0%
Network ! network             ! 2    !          ! 98   ! 100   ! 2.0%
Network ! subnet              ! 2    !          ! 98   ! 100   ! 2.0%
Network ! router              ! 1    !          ! 99   ! 100   ! 1.0%
Network ! security_group      ! 4    !          ! 496  ! 500   ! 0.8%
```

Watch the quotas that a deployment consumes, and stay quiet about the rest:

```bash
./openstack-quota --rc-file=/var/spool/icinga2/.openstack.cnf --match=^network_port$ --match=^compute_ --brief
```


## States

* OK if the share in use of every checked quota is within the thresholds.
* WARN if the share in use of a quota reaches `--warning`, or if the quotas of a service cannot be read: the service is not in the catalog of this cloud, it refused the account, or it did not answer inside `--timeout`. The quotas of the other services are still reported.
* CRIT if the share in use of a quota reaches `--critical`.
* UNKNOWN if the rc file cannot be read, or if a `--match` / `--ignore` pattern is not a valid regular expression.
* A quota without a limit and a quota whose limit is zero are never rated, so they cannot cause a WARN or CRIT.
* If every quota is filtered out by `--match` or `--ignore`, the state is the one `--no-match-severity` names.
* `--always-ok` reports OK regardless.


## Perfdata / Metrics

One metric per quota that has a limit, named `<service>_<resource>`, where the service is `compute`, `network` or `volume` and the resource is the name the cloud gives it. A quota without a limit has no share to report and therefore no metric.

| Name | Type | Description |
|------|------|-------------|
| compute_cores | Percentage | Share of the vCPU quota that is in use |
| compute_instances | Percentage | Share of the instance quota that is in use |
| compute_ram | Percentage | Share of the memory quota that is in use |
| compute_server_groups | Percentage | Share of the server group quota that is in use |
| network_floatingip | Percentage | Share of the floating IP quota that is in use |
| network_network | Percentage | Share of the network quota that is in use |
| network_port | Percentage | Share of the port quota that is in use |
| network_rbac_policy | Percentage | Share of the RBAC policy quota that is in use |
| network_router | Percentage | Share of the router quota that is in use |
| network_security_group | Percentage | Share of the security group quota that is in use |
| network_security_group_rule | Percentage | Share of the security group rule quota that is in use |
| network_subnet | Percentage | Share of the subnet quota that is in use |
| network_subnetpool | Percentage | Share of the subnet pool quota that is in use |
| network_trunk | Percentage | Share of the trunk quota that is in use |
| volume_backup_gigabytes | Percentage | Share of the backup storage quota that is in use |
| volume_backups | Percentage | Share of the backup quota that is in use |
| volume_gigabytes | Percentage | Share of the volume storage quota that is in use |
| volume_groups | Percentage | Share of the volume group quota that is in use |
| volume_snapshots | Percentage | Share of the snapshot quota that is in use |
| volume_volumes | Percentage | Share of the volume quota that is in use |

A cloud that defines quotas per volume type reports those as well, as `volume_volumes_<type>`, `volume_gigabytes_<type>` and `volume_snapshots_<type>`. Which resources a cloud has quotas for is up to the cloud: Neutron in particular registers them per loaded service plugin, so the list above is what a common deployment answers with, not a fixed set.


## Troubleshooting

### `The time budget of this run is spent.`

`--timeout` covers the whole run, not a single request, and the run makes one request per service plus one to authenticate. Raise it, or check fewer services with `--service`. A run whose token is still cached saves the authentication and is a good deal faster, so the first run after a deployment is the slowest one.

### `Failed to authenticate.`

The credentials in the rc file were refused. Verify them with `openstack token issue` using the same file. A password that was changed recently takes until the cached token expires to surface here, because the check reuses the token of the previous run; `--cache-expire=0` skips the cache for a single run.

### A service refuses the request

`Cannot read the quotas of Volume (HTTP 403: ...) [WARNING]`

The account may talk to the service but not to its quota endpoint. The quota endpoints of Nova and Cinder are open to a project reader, so the account is usually missing the `reader` role, which Keystone normally implies for `member`. On a cloud with a policy of its own, the message names the policy that refused.

### A service is not in the catalog

`Cannot read the quotas of Volume (the service catalog holds no "volumev3" endpoint) [WARNING]`

This cloud runs no block storage service, or does not offer it in the region the rc file names. Name the services it does run, for example `--service=compute --service=network`.

### A quota reports 100% although nothing uses it

Its limit is zero, which forbids the resource outright. The check does not rate such a quota and counts it in the summary instead. If a resource is supposed to be available, ask the cloud operator to raise the quota.

### The certificate cannot be verified

`TLS certificate verification failed for https://...: self-signed certificate in certificate chain`

The cloud presents a certificate that no authority the host trusts has signed. Point `OS_CACERT` in the rc file at the CA bundle of the cloud, put that CA into the trust store of the host (`/etc/pki/ca-trust/source/anchors/` plus `update-ca-trust` on RHEL family, `/usr/local/share/ca-certificates/` plus `update-ca-certificates` on Debian family), or accept an unverified connection with `--insecure`. A bundle named in `OS_CACERT` that cannot be read is reported as such rather than silently falling back to the trust store.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/)
