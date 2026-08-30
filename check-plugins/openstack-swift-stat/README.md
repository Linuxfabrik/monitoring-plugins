# Check openstack-swift-stat


## Overview

Checks OpenStack Swift object storage account statistics, including total container count, object count, and bytes used. Alerts when the space or the object headroom left in a container with a quota falls to or below the thresholds, when the account itself is running out of its own quota, or when the Swift API cannot be reached in time. Containers without a quota are listed but cannot be alerted on. Supports extended reporting via `--lengthy`.

**Important Notes:**

* The check reuses the Keystone token of the previous run. A run that has a valid token makes one request for the account plus one per container, a run that has to authenticate first makes one more. `--cache-expire` bounds the reuse, and a token is never reused past its own lifetime.
* You have to provide a path to an rc file to authenticate. The rc file should contain the standard OpenStack environment variables such as `OS_AUTH_URL`, `OS_USERNAME`, `OS_PASSWORD`, `OS_PROJECT_NAME` and `OS_PROJECT_DOMAIN_NAME`. A domain is taken from the id variable if the rc file sets one, otherwise from the name variable, and falls back to the `default` domain if it sets neither.
* The check reads the headers of every container it reports on, one request each, so its runtime grows with the number of containers. `--match` and `--ignore` decide which ones are read at all, so narrowing the check down saves the requests rather than only shortening the table. `--timeout` bounds the whole run: containers it did not get to are reported as not read rather than left out silently. On an account with many containers, either run one service per group of containers with `--match`, or raise `--timeout` together with the timeout of the check command.
* Swift enforces two quotas per container, one on bytes and one on the number of objects, and a container can run out of either. `--warning` and `--critical` are the free space left in GiB, `--warning-count` and `--critical-count` the number of objects the container may still take. A lower number is worse in both cases. They only apply where the matching quota is actually set; a container without one is listed with an empty cell and cannot raise an alert on it.
* The account carries a quota of its own and is checked against `--warning` and `--critical` as well, because it can run out while every single container is still well inside its own.
* Only the quotas Swift exposes to a client can be reported on. A reseller may set the account byte quota as system metadata, which takes precedence on the server but is stripped from every response, and the account object count quota and the per-storage-policy quotas exist only as system metadata. None of those are visible to this check, or to any other client.

**Data Collection:**

* Authenticates to the OpenStack Swift API using the credentials from an rc file
* Reports account-level statistics: container count, object count, total bytes used, and account quota
* Reports per-container statistics: item count, both quotas, usage, and the remaining free space and object headroom
* One request lists the account: its own numbers arrive in the response headers and its containers in the body. The headers of each container that passes the filters take one request more
* `--match` and `--ignore` filter by container name and are applied before those requests, `--brief` hides the containers that are within the thresholds and `--lengthy` adds the storage policy and the last modification date
* A column that no container filled in is left out of the table, so an account whose containers carry no quota does not show an empty Free column


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/openstack-swift-stat> |
| Nagios/Icinga Check Name              | `check_openstack_swift_stat` |
| Check Interval Recommendation         | Every 15 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| Requirements                          | An rc file with OpenStack credentials, readable by the user running the check |


## Help

```text
usage: openstack-swift-stat [-h] [-V] [--always-ok] [--brief]
                            [--cache-expire CACHE_EXPIRE] [-c CRIT]
                            [--critical-count CRIT_COUNT] [--ignore IGNORE]
                            [--insecure] [--lengthy] [--match MATCH]
                            [--no-match-severity {ok,warn,crit,unknown}]
                            [--no-perfdata] [--no-proxy] [--proxy PROXY]
                            [--rc-file RC_FILE] [--timeout TIMEOUT] [-w WARN]
                            [--warning-count WARN_COUNT]

Checks OpenStack Swift object storage account statistics, including total
container count, object count, and bytes used. Alerts when the free space left
in a container with a quota falls to or below the thresholds, or when the
Swift API cannot be reached in time. Containers without a quota are listed but
cannot be alerted on. Supports extended reporting via --lengthy.

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
  -c, --critical CRIT   CRIT threshold for remaining free space, in GiB. Only
                        applies to containers that have a quota set. Default:
                        <= 10
  --critical-count CRIT_COUNT
                        CRIT threshold for the remaining number of objects a
                        container may still take. Only applies to containers
                        that have an object count quota set. Default: <= 1000
  --ignore IGNORE       Any item matching this Python regex will be ignored.
                        Can be specified multiple times. Example:
                        `(?i)linuxfabrik` for a case-insensitive match.
                        Matched against the container name.
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
                        container name.
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
  --timeout TIMEOUT     Network timeout in seconds. Applies to the whole run,
                        not to a single request. Default: 50 (seconds)
  -w, --warning WARN    WARN threshold for remaining free space, in GiB. Only
                        applies to containers that have a quota set. Default:
                        <= 50
  --warning-count WARN_COUNT
                        WARN threshold for the remaining number of objects a
                        container may still take. Only applies to containers
                        that have an object count quota set. Default: <= 10000

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/openstack-swift-stat/
```


## Usage Examples

```bash
./openstack-swift-stat --rc-file=/var/spool/icinga2/rc/.openstack-myproject.rc
```

Output:

```text
Account: 4 containers, 2.8M objects, 5.4TiB used, 90.9TiB quota (5.9% used, 85.6TiB free)

Container ! Items  ! Quota    ! Used           ! Free     ! State
----------+--------+----------+----------------+----------+----------
01        ! 2.4M   !          ! 2.2TiB         !          !
02        ! 324.4K ! 3.1TiB   ! 3.1TiB (99.5%) ! 17.2GiB  ! [WARNING]
03        ! 107.7K !          ! 111.8GiB       !          !
04        ! 2.0    ! 204.9GiB ! 2.0GiB (1.0%)  ! 202.9GiB !
```

A container with an object count quota instead of a byte quota. The byte columns are gone because no container here carries a byte quota, and the State column appears only while something is wrong:

```text
Account: 2 containers, 99.7K objects, 1.9GiB used, 931.3GiB quota (0.2% used, 929.5GiB free)

Container ! Items         ! Items Quota ! Free Items ! Used     ! State
----------+---------------+-------------+------------+----------+-----------
roomy     ! 700.0 (0.1%)  ! 1.0M        ! 999.3K     ! 953.7MiB !
crowded   ! 99.0K (99.0%) ! 100.0K      ! 1.0K       ! 953.7MiB ! [CRITICAL]
```

Only the containers that are running out of space, with every column:

```bash
./openstack-swift-stat --rc-file=/var/spool/icinga2/rc/.openstack-myproject.rc --lengthy --brief
```

Output:

```text
Account: 4 containers, 2.8M objects, 5.4TiB used, 90.9TiB quota

Container ! Policy   ! Last Modified                 ! Items  ! Quota  ! Used           ! Free
----------+----------+-------------------------------+--------+--------+----------------+------------------
02        ! Policy-0 ! Tue, 05 Jul 2022 13:18:43 GMT ! 324.4K ! 3.1TiB ! 3.1TiB (99.5%) ! 17.2GiB [WARNING]
```

Check only the backup containers of the account, and alert earlier:

```bash
./openstack-swift-stat --rc-file=/var/spool/icinga2/rc/.openstack-myproject.rc --match=^backup- --warning=200 --critical=100
```


## States

The overall state is the worst state of all containers that survived `--match` and `--ignore`.

* OK if every container and the account have more headroom left than the thresholds, or carry no quota at all.
* WARN if the free space left in a container or in the account is <= `--warning` (default: 50 GiB), or if the number of objects a container may still take is <= `--warning-count` (default: 10000).
* CRIT if the free space left in a container or in the account is <= `--critical` (default: 10 GiB), or if the number of objects a container may still take is <= `--critical-count` (default: 1000).
* The state marker sits in its own last column and states the verdict for the whole row, whichever of the two quotas caused it. The percentages in the columns before it say which one. The column is left out entirely while every row is fine.
* WARN if the Swift API cannot be reached within `--timeout`, refuses the credentials, or answers with an error. A store that does not answer says nothing about the containers in it, so this does not silently pass as OK.
* WARN if `--timeout` runs out before every container was read. The message names how many were read, and the containers that were not read cannot raise an alert of their own.
* UNKNOWN if `--match` or `--ignore` is not a valid regular expression.
* `--no-match-severity` decides the state when `--match` or `--ignore` leaves nothing to check. Default: OK.
* "Nothing checked." means the account really holds no containers to look at. `--brief` hiding every row is not that: the containers were checked and are within their thresholds, so only the account summary is printed.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

Every container emits its metrics, including the ones `--brief` hides from the table.

| Name | Type | Description |
|----|----|----|
| \<container-name\>\_items | Number | Number of items in the Swift container. |
| \<container-name\>\_used | Bytes | Bytes used in the Swift container. |


## Troubleshooting

### The check is killed by its own timeout

`<Timeout exceeded.><Terminated by signal 15 (Terminated).><Terminated with exit code 128 (0x80).>`

The monitoring server stopped the check before it had an answer, so this is the server's timeout and not the plugin's. The check reads the headers of every container one by one, so an account that grew past a handful of containers is the usual reason. Narrow it down with `--match` and split it into one service per group of containers, or raise `--timeout` and the timeout of the check command together: the plugin only gives up on its own while the command timeout is the larger of the two.

### `Only N of them read within Ns`

`--timeout` ran out before every container was read. The containers that were not read are not covered by this run, so the state only describes the ones that were. Split the account across several services with `--match`, or raise `--timeout` and the timeout of the check command together.

### `Cannot read the account: ...`

The endpoint did not answer within `--timeout`, or it refused the request. Verify `OS_AUTH_URL` in the rc file, and that the monitoring host reaches the endpoint and its port. If the endpoint presents a certificate the host does not trust, either point `OS_CACERT` in the rc file at its CA, add that CA to the system trust store, or use `--insecure`.

### A container is listed with an empty Free or Free Items column

The container carries no quota of that kind, so there is nothing to measure its usage against and the matching thresholds cannot apply to it. Set one with `swift post --meta quota-bytes:<bytes> <container>` or `swift post --meta quota-count:<objects> <container>` if it should be alerted on. When no container in the account carries a given quota, the whole column is left out.

### `Failed to authenticate.`

The credentials in the rc file were refused. Verify them with `openstack token issue` using the same file. A password that was changed recently takes until the cached token expires to surface here, because the check reuses the token of the previous run; `--cache-expire=0` skips the cache for a single run.

### `N containers could not be read`

The store refused the request for those containers while answering for the others, which an ACL on a single container can cause. `swift stat <container>` with the same credentials shows what it says.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
