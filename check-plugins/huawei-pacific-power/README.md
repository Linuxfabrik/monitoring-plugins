# Check huawei-pacific-power


## Overview

Checks the status of all power supplies on a Huawei OceanStor Pacific storage system via the REST API (`/hwm/power` endpoint). Alerts when any power supply reports a non-normal status.

**Important Notes:**

* Create a read-only API user that can perform queries only
* The hardware endpoint is node-scoped. The check first enumerates the cluster nodes (`/cluster/servers`) and then queries the power supplies on every node
* The credential/session token is cached in a local SQLite database between runs; `--cache-expire` controls how long it is reused before a fresh login

**Data Collection:**

* Enumerates the cluster nodes and queries the Huawei OceanStor Pacific REST API at `https://<ip>:<port>/api/v2/hwm/power`
* Authenticates via a session token (`X-Auth-Token`), cached in a SQLite database to avoid repeated logins
* If the appliance rejects a request (for example after a session reset or timeout), the check logs in again and retries


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/huawei-pacific-power> |
| Nagios/Icinga Check Name              | `check_huawei_pacific_power` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | No (`--password`, `--url` and `--username` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-huawei-pacific.db` |


## Help

```text
usage: huawei-pacific-power [-h] [-V] [--always-ok]
                            [--cache-expire CACHE_EXPIRE] [--ignore IGNORE]
                            [--insecure] [--lengthy] [--no-insecure]
                            [--match MATCH]
                            [--no-match-severity {ok,warn,crit,unknown}]
                            [--no-perfdata] [--no-proxy] [--password PASSWORD]
                            [--password-file PASSWORD_FILE] [--scope SCOPE]
                            [--timeout TIMEOUT] -u URL --username USERNAME
                            [-v]

Checks the status of all power supplies on a Huawei OceanStor Pacific storage
system via the REST API (/hwm/power endpoint). Alerts when any power supply
reports a non-normal status. Supports extended reporting via --lengthy.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --cache-expire CACHE_EXPIRE
                        The amount of time after which the credential/data
                        cache expires, in minutes. Default: 15
  --ignore IGNORE       Skip power supplies. Any item matching this Python
                        regex will be ignored. Can be specified multiple
                        times. Example: `(?i)linuxfabrik` for a case-
                        insensitive match. The regex is anchored at the start
                        of the string (Python `re.match`) and is matched
                        against `frame_sn`, `name`, `node`, so prefix with
                        `.*` to match anywhere.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --lengthy             Extended reporting.
  --no-insecure         Verify the TLS certificate against the system trust
                        store, overriding the insecure default of this check.
                        Use it once the endpoint presents a publicly trusted
                        certificate, or once its CA has been added to the
                        system trust store.
  --match MATCH         Limit to power supplies. Filter by this Python regular
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
  --no-proxy            Do not use a proxy.
  --password PASSWORD   Huawei OceanStor Pacific API password. Password.
  --password-file PASSWORD_FILE
                        Path to a file holding the password, read from its
                        first line. Keeps the password out of the process
                        list, where a command-line argument is visible to
                        every user on the host. Takes precedence over
                        `--password`. Keep the file readable only by the
                        monitoring user. Example: `--password-
                        file=/etc/icinga2/secrets/storage`.
  --scope SCOPE         Huawei OceanStor Pacific API scope.
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -u, --url URL         Huawei OceanStor Pacific API URL. URL to the endpoint.
  --username USERNAME   Huawei OceanStor Pacific API username. Username.
  -v, --verbose         Makes this plugin verbose during the operation. Useful
                        for debugging and seeing what is going on under the
                        hood. Appends what every API request returned, so the
                        appliance's own answers can be read while working out
                        how it reports something. Session tokens are redacted.
                        The output is as long as those answers are, so this is
                        a debugging aid rather than something to leave
                        switched on.

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/huawei-pacific-power/
```


## Usage Examples

```bash
./huawei-pacific-power --url=https://oceanstor:8088 --username=monitoring --password=linuxfabrik
```

Output:

```text
There are critical errors.

Node   ! Name ! Status ! State
-------+------+--------+-----------
node01 ! PSU0 ! normal ! [OK]
node01 ! PSU1 ! normal ! [OK]
node02 ! PSU0 ! normal ! [OK]
node02 ! PSU1 ! fault  ! [CRITICAL]
```

The check covers every node of the cluster, and each chassis numbers its power
supplies from zero, so the node is what tells the two `PSU0` rows apart.
`--lengthy` puts the chassis serial number next to it:

```bash
./huawei-pacific-power --url=https://oceanstor:8088 --username=monitoring --password=linuxfabrik --lengthy
```

Output:

```text
There are critical errors.

Node   ! Chassis SN           ! Name ! Status ! State
-------+----------------------+------+--------+-----------
node01 ! 2102355GLC10N9100001 ! PSU0 ! normal ! [OK]
node01 ! 2102355GLC10N9100001 ! PSU1 ! normal ! [OK]
node02 ! 2102355GLC10N9100002 ! PSU0 ! normal ! [OK]
node02 ! 2102355GLC10N9100002 ! PSU1 ! fault  ! [CRITICAL]
```


## States

* OK if all power supplies report a status of "normal".
* WARN if any power supply reports a status this check does not know.
* CRIT if any power supply reports a status of "fault".
* UNKNOWN if the appliance lists no power supplies at all, which points at the query rather than at the hardware.
* UNKNOWN on invalid API responses or responses with error codes.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| \<chassis\>\_\<power\>\_status | Number | Power supply status. 0: normal, 1: not normal. |


## Troubleshooting

### No valuable response from the API

`Got no valuable response from https://...`

Check the `--url`, `--username` and `--password` parameters. Verify that the API user has query permissions and that the storage system REST API is reachable.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
