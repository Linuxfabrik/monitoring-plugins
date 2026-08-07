# Check huawei-dorado-sfp


## Overview

Checks the health and link status of the optical modules (SFP) of a Huawei OceanStor Dorado storage system via the REST API (`/sfp` endpoint). Alerts when a module reports a non-normal health status, and optionally when its link is down. Reports the vendor, model, mode, working speed and what the module sits in.

**Important Notes:**

* Tested on Huawei OceanStor Dorado 8000 V6 6.1.0
* The `/sfp` endpoint is documented from V700R001C10 on. Older firmware does not serve it, and the check then reports OK with "No optical modules found."
* This endpoint is the odd one out: it reports its fields in camelCase (`id`, `healthStatus`, `location`) where every other object uses upper case, and it carries no `TYPE`. Modules are therefore identified by their location, not by the `TYPE:ID` the rest of the checks use
* A module whose link is down reports exactly what an uncabled one reports, so this does not alert by default. Set `--link-down-severity` on an array where every module is expected to be connected
* Create a read-only API user that can perform queries only
* The default session timeout period on the storage system is 20 minutes; `--cache-expire` defaults to 15 minutes to stay within that window

**Data Collection:**

* Queries the Huawei OceanStor Dorado REST API at `https://<ip>:<port>/deviceManager/rest/<deviceId>/sfp`
* Authenticates via session tokens (iBaseToken + cookie), cached in a SQLite database to avoid repeated logins
* If the appliance rejects a request, the check logs in again and retries, up to three attempts one second apart


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/huawei-dorado-sfp> |
| Nagios/Icinga Check Name              | `check_huawei_dorado_sfp` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | No (`--device-id`, `--password`, `--url` and `--username` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-huawei-dorado.db` |


## Help

```text
usage: huawei-dorado-sfp [-h] [-V] [--always-ok] [--brief]
                         [--cache-expire CACHE_EXPIRE] [--device-id DEVICE_ID]
                         [--ignore IGNORE] [--insecure]
                         [--link-down-severity {ok,warn,crit,unknown}]
                         [--match MATCH] [--no-insecure]
                         [--no-match-severity {ok,warn,crit,unknown}]
                         [--no-perfdata] [--no-proxy] [--password PASSWORD]
                         [--password-file PASSWORD_FILE]
                         [--rx-power-critical RX_POWER_CRIT]
                         [--rx-power-warning RX_POWER_WARN] [--scope SCOPE]
                         [--tx-power-critical TX_POWER_CRIT]
                         [--tx-power-warning TX_POWER_WARN]
                         [--timeout TIMEOUT] -u URL --username USERNAME [-v]

Checks the health, link status and optical power of the optical modules (SFP)
of a Huawei OceanStor Dorado storage system via the REST API (/sfp endpoint).
Alerts when a module reports a non-normal health status, when its receive or
transmit power leaves the range the module itself reports as its operating
range, and optionally when its link is down. A degrading transceiver or a
dirty connector shows up as falling receive power long before the link drops.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --brief               Hide the rows that are within the thresholds and show
                        only those in a WARN or CRIT state. Perfdata and
                        alerting are unaffected: every item still emits
                        performance data and still drives the overall check
                        state, so this is safe to leave on. Worth setting on
                        an array with many optical modules. Default: False
  --cache-expire CACHE_EXPIRE
                        The amount of time after which the credential/data
                        cache expires, in minutes. Default: 15
  --device-id DEVICE_ID
                        Huawei OceanStor Dorado API device ID. Optional: the
                        appliance reports its own at login, so this is only
                        needed to override that answer.
  --ignore IGNORE       Skip optical modules. Any item matching this Python
                        regex will be ignored. Can be specified multiple
                        times. Example: `(?i)linuxfabrik` for a case-
                        insensitive match. The regex is anchored at the start
                        of the string (Python `re.match`) and is matched
                        against the module identifier, its location, vendor,
                        model and serial number, so prefix with `.*` to match
                        anywhere. Default: None
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --link-down-severity {ok,warn,crit,unknown}
                        State to report for a port whose link is down. A port
                        that is simply not cabled reports the same thing,
                        which is why this defaults to not alerting. Default:
                        ok
  --match MATCH         Filter by optical modules. Filter by this Python
                        regular expression. Case-sensitive by default; use
                        `(?i)` for case-insensitive matching. Can be specified
                        multiple times. Examples: `(?i)example` to match
                        "example" regardless of case. `^(?!.*example).*$` to
                        match any string except "example" (negative
                        lookahead). The regex is anchored at the start of the
                        string (Python `re.match`) and is matched against the
                        module identifier, its location, vendor, model and
                        serial number, so prefix with `.*` to match anywhere.
                        Default: None
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
  --no-proxy            Do not use a proxy.
  --password PASSWORD   Huawei OceanStor Dorado API password. Password.
  --password-file PASSWORD_FILE
                        Path to a file holding the password, read from its
                        first line. Keeps the password out of the process
                        list, where a command-line argument is visible to
                        every user on the host. Takes precedence over
                        `--password`. Keep the file readable only by the
                        monitoring user. Example: `--password-
                        file=/etc/icinga2/secrets/storage`.
  --rx-power-critical RX_POWER_CRIT
                        CRIT threshold for the receive power of a module, as a
                        Nagios range in dBm. Defaults to the operating range
                        the module itself reports, so a transceiver is judged
                        against its own data sheet rather than against one
                        number for the whole appliance. Example: `--rx-power-
                        critical=-14:0`
  --rx-power-warning RX_POWER_WARN
                        WARN threshold for the receive power of a module, as a
                        Nagios range in dBm. Example: `--rx-power-
                        warning=-12:-1`
  --scope SCOPE         Huawei OceanStor Dorado API scope.
  --tx-power-critical TX_POWER_CRIT
                        CRIT threshold for the transmit power of a module, as
                        a Nagios range in dBm. Defaults to the operating range
                        the module itself reports. Example: `--tx-power-
                        critical=-9:3`
  --tx-power-warning TX_POWER_WARN
                        WARN threshold for the transmit power of a module, as
                        a Nagios range in dBm. Example: `--tx-power-
                        warning=-8:2`
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -u, --url URL         Huawei OceanStor Dorado API URL. URL to the endpoint.
  --username USERNAME   Huawei OceanStor Dorado API username. Username.
  -v, --verbose         Makes this plugin verbose during the operation. Useful
                        for debugging and seeing what is going on under the
                        hood. Appends what every API request returned, so the
                        appliance's own answers can be read while working out
                        how it reports something. Session tokens are redacted.
                        The output is as long as those answers are, so this is
                        a debugging aid rather than something to leave
                        switched on.

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/huawei-dorado-sfp/
```


## Usage Examples

```bash
./huawei-dorado-sfp --url=https://oceanstor:8088 --device-id=123456789 --username=monitoring --password=linuxfabrik
```

Output:

```text
Everything is ok.

Location       ! Sits In          ! Vendor ! Model      ! Mode        ! Mbit/s ! Link           ! Health ! Link State
---------------+------------------+--------+------------+-------------+--------+----------------+--------+-----------
CTE0.A.IOM0.P0 ! interface module ! HUAWEI ! SFP-32G-FC ! single-mode ! 32000  ! Link up (10)   ! [OK]   ! [OK]
CTE0.A.IOM0.P1 ! interface module ! HUAWEI ! SFP-32G-FC ! single-mode ! 32000  ! Link down (11) ! [OK]   ! [OK]
```

Alert on a module that lost its link, and look at one vendor's modules only:

```bash
./huawei-dorado-sfp --url=https://oceanstor:8088 --device-id=123456789 --username=monitoring --password=linuxfabrik --link-down-severity=warn --match='.*HUAWEI'
```


## States

* OK if all optical modules report normal health.
* OK with "No optical modules found." if the array has no optical connectivity, or if its firmware does not serve this endpoint.
* WARN if a module reports a degraded health status, or one this check does not know.
* WARN if a module reports a link state this check does not know.
* CRIT if a module reports health status "Faulty", "No Input", "Invalid" or "Offline".
* `--link-down-severity` decides what a module whose link is down reports (default: OK).
* UNKNOWN on invalid API responses or responses with error codes.
* `--match` limits the check to the modules whose identifier, location, vendor, model or serial number matches the regex; `--no-match-severity` sets what to report when nothing matches (default: OK).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| \<Location\>\_health_status | Number | 0: unknown, 1: normal, 2: faulty, 9: inconsistent. |
| \<Location\>\_running_status | Number | 0: unknown, 10: link up, 11: link down. |
| \<Location\>\_speed | Number | Working speed in Mbit/s. |

Have a look at the [API documentation](https://support.huawei.com/enterprise/en/doc/EDOC1100144155/387d790e/overview) for details.


## Troubleshooting

### No valuable response from the API

`Got no valuable response from https://...`

Check the `--url`, `--device-id`, `--username` and `--password` parameters. Verify that the API user has query permissions and that the storage system REST API is reachable.

### `This operation fails to be performed because of the unauthorized REST.`

This is a known transient issue with the Huawei REST API. The check makes up to three attempts and forces a fresh login before the second one. If the error persists, verify the API credentials and session timeout settings.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
