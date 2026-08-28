# Check huawei-pacific-fan


## Overview

Checks the status of all fans on a Huawei OceanStor Pacific storage system via the REST API (`/hwm/fan` endpoint). Alerts when any fan reports a non-normal status.

**Important Notes:**

* Create a read-only API user that can perform queries only
* The hardware endpoint is node-scoped. The check first enumerates the cluster nodes (`/cluster/servers`) and then queries the fans on every node
* The credential/session token is cached in a local SQLite database between runs; `--cache-expire` controls how long it is reused before a fresh login

**Data Collection:**

* Enumerates the cluster nodes and queries the Huawei OceanStor Pacific REST API at `https://<ip>:<port>/api/v2/hwm/fan`
* Authenticates via a session token (`X-Auth-Token`), cached in a SQLite database to avoid repeated logins
* If the appliance rejects a request (for example after a session reset or timeout), the check logs in again and retries


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/huawei-pacific-fan> |
| Nagios/Icinga Check Name              | `check_huawei_pacific_fan` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | No (`--password`, `--url` and `--username` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-huawei-pacific.db` |


## Help

```text
usage: huawei-pacific-fan [-h] [-V] [--always-ok]
                          [--cache-expire CACHE_EXPIRE] [--ignore IGNORE]
                          [--insecure] [--lengthy] [--no-insecure]
                          [--match MATCH]
                          [--no-match-severity {ok,warn,crit,unknown}]
                          [--no-perfdata] [--no-proxy] [--password PASSWORD]
                          [--password-file PASSWORD_FILE] [--proxy PROXY]
                          [--scope SCOPE] [--timeout TIMEOUT] -u URL
                          --username USERNAME [-v]

Checks the status of all fans on a Huawei OceanStor Pacific storage system via
the REST API (/hwm/fan endpoint). Alerts when any fan reports a non-normal
status. Supports extended reporting via --lengthy.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --cache-expire CACHE_EXPIRE
                        The amount of time after which the credential/data
                        cache expires, in minutes. Default: 15
  --ignore IGNORE       Skip fans. Any item matching this Python regex will be
                        ignored. Can be specified multiple times. Example:
                        `(?i)linuxfabrik` for a case-insensitive match. The
                        regex is anchored at the start of the string (Python
                        `re.match`) and is matched against `frame_sn`, `name`,
                        `node`, so prefix with `.*` to match anywhere.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --lengthy             Extended reporting.
  --no-insecure         Verify the TLS certificate against the system trust
                        store, overriding the insecure default of this check.
                        Use it once the endpoint presents a publicly trusted
                        certificate, or once its CA has been added to the
                        system trust store.
  --match MATCH         Limit to fans. Filter by this Python regular
                        expression. Case-sensitive by default; use `(?i)` for
                        case-insensitive matching. Can be specified multiple
                        times. If both `--match` and `--ignore` are given, an
                        item must match `--match` AND not match `--ignore` to
                        be reported (include first, exclude second). Examples:
                        `(?i)example` to match "example" regardless of case.
                        `^(?!.*example).*$` to match any string except
                        "example" (negative lookahead). The regex is anchored
                        at the start of the string (Python `re.match`) and is
                        matched against `frame_sn`, `name`, `node`, so prefix
                        with `.*` to match anywhere.
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
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/huawei-pacific-fan/
```


## Usage Examples

```bash
./huawei-pacific-fan --url=https://oceanstor:8088 --username=monitoring --password=linuxfabrik
```

Output:

```text
There are critical errors.

Node   ! Name ! Status ! State
-------+------+--------+-----------
node01 ! Fan0 ! normal ! [OK]
node01 ! Fan1 ! normal ! [OK]
node02 ! Fan0 ! normal ! [OK]
node02 ! Fan1 ! fault  ! [CRITICAL]
```

The check covers every node of the cluster, and each chassis numbers its fans from
zero, so the node is what tells the two `Fan0` rows apart. `--lengthy` puts the
chassis serial number next to it:

```bash
./huawei-pacific-fan --url=https://oceanstor:8088 --username=monitoring --password=linuxfabrik --lengthy
```

Output:

```text
There are critical errors.

Node   ! Chassis SN           ! Name ! Status ! State
-------+----------------------+------+--------+-----------
node01 ! 2102355GLC10N9100001 ! Fan0 ! normal ! [OK]
node01 ! 2102355GLC10N9100001 ! Fan1 ! normal ! [OK]
node02 ! 2102355GLC10N9100002 ! Fan0 ! normal ! [OK]
node02 ! 2102355GLC10N9100002 ! Fan1 ! fault  ! [CRITICAL]
```


## States

* OK if all fans report a status of "normal".
* OK for a fan reporting "absent". A chassis is sold with more fan bays than it is usually populated with, and an empty bay reports this on every run.
* WARN if any fan reports a status this check does not know.
* CRIT if any fan reports a status of "fault".
* UNKNOWN if the appliance lists no fans at all, which points at the query rather than at the hardware.
* UNKNOWN on invalid API responses or responses with error codes.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| \<chassis\>\_\<fan\>\_status | Number | Fan status. 0: normal, 1: not normal. |


## Troubleshooting

### No valuable response from the API

`Got no valuable response from https://...`

Check the `--url`, `--username` and `--password` parameters. Verify that the API user has query permissions and that the storage system REST API is reachable.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
