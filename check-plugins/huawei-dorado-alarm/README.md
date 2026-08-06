# Check huawei-dorado-alarm


## Overview

Lists the current alarms of a Huawei OceanStor Dorado storage system via the REST API (`/alarm/currentalarm` endpoint). Alerts when alarms are present: critical if any critical alarm exists, warning for a major or a warning alarm. Reports the alarm sequence number, the time it was raised, its severity, its name and the module it occurred on.

This is the check that notices what the per-component checks cannot see, because the array raises an alarm for anything it considers worth reporting, including conditions that have no object of their own.

**Important Notes:**

* Tested on Huawei OceanStor Dorado 8000 V6 6.1.0
* Timestamps are requested in UTC. The appliance otherwise answers in whatever timezone it is configured for, without saying which
* An informational alarm is listed but does not alert, because it is a note rather than a fault
* A major alarm alerts as a warning: it marks a fault that degrades the array without stopping it
* Create a read-only API user that can perform queries only
* The default session timeout period on the storage system is 20 minutes; `--cache-expire` defaults to 15 minutes to stay within that window

**Data Collection:**

* Queries the Huawei OceanStor Dorado REST API at `https://<ip>:<port>/deviceManager/rest/<deviceId>/alarm/currentalarm`
* Walks the alarm list page by page, 250 alarms per request, which is the limit this endpoint sets
* Decodes the HTML entities the appliance embeds in the texts it generates
* Authenticates via session tokens (iBaseToken + cookie), cached in a SQLite database to avoid repeated logins
* If the appliance rejects a request, the check logs in again and retries, up to three attempts one second apart


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/huawei-dorado-alarm> |
| Nagios/Icinga Check Name              | `check_huawei_dorado_alarm` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | No (`--device-id`, `--password`, `--url` and `--username` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-huawei-dorado.db` |


## Help

```text
usage: huawei-dorado-alarm [-h] [-V] [--always-ok]
                           [--cache-expire CACHE_EXPIRE] --device-id DEVICE_ID
                           [--insecure] [--match MATCH] [--no-insecure]
                           [--no-match-severity {ok,warn,crit,unknown}]
                           [--no-perfdata] [--no-proxy] --password PASSWORD
                           [--scope SCOPE] [--timeout TIMEOUT] -u URL
                           --username USERNAME

Lists the current alarms of a Huawei OceanStor Dorado storage system via the
REST API (/alarm/currentalarm endpoint). Alerts when alarms are present:
critical if any critical alarm exists, warning for a major or a warning alarm.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --cache-expire CACHE_EXPIRE
                        The amount of time after which the credential/data
                        cache expires, in minutes. Default: 15
  --device-id DEVICE_ID
                        Huawei OceanStor Dorado API device ID.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --match MATCH         Filter by alarms. Filter by this Python regular
                        expression. Case-sensitive by default; use `(?i)` for
                        case-insensitive matching. Can be specified multiple
                        times. Examples: `(?i)example` to match "example"
                        regardless of case. `^(?!.*example).*$` to match any
                        string except "example" (negative lookahead). The
                        regex is anchored at the start of the string (Python
                        `re.match`) and is matched against the alarm name, its
                        description and the module it occurred on, so prefix
                        with `.*` to match anywhere. Default:
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
  --password PASSWORD   Huawei OceanStor Dorado API password.
  --scope SCOPE         Huawei OceanStor Dorado API scope.
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -u, --url URL         Huawei OceanStor Dorado API URL.
  --username USERNAME   Huawei OceanStor Dorado API username.

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/huawei-dorado-alarm/
```


## Usage Examples

```bash
./huawei-dorado-alarm --url=https://oceanstor:8088 --device-id=123456789 --username=monitoring --password=linuxfabrik
```

Output:

```text
There are critical alarms.

Sequence ! Time                ! Severity     ! Name                           ! Location ! State
---------+---------------------+--------------+--------------------------------+----------+-----------
4711     ! 2023-08-31 16:23:43 ! Critical (6) ! Controller (CTE0.A) Is Offline ! CTE0.A   ! [CRITICAL]
4712     ! 2023-08-31 17:23:43 ! Major (5)    ! Disk Is About To Fail          ! DAE000.7 ! [WARNING]
```

Ignore the alarms of one enclosure, for example while it is being serviced:

```bash
./huawei-dorado-alarm --url=https://oceanstor:8088 --device-id=123456789 --username=monitoring --password=linuxfabrik --match='^(?!.*DAE000).*$'
```


## States

* OK if the appliance reports no alarms, or only informational ones.
* WARN if a warning or a major alarm is present.
* CRIT if a critical alarm is present.
* WARN if the appliance reports more alarms than the check reads in one run, because the list is then incomplete.
* UNKNOWN on invalid API responses or responses with error codes.
* `--match` limits the check to the alarms whose name, description or location matches the regex; `--no-match-severity` sets what to report when nothing matches (default: OK).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| critical_alarms | Number | Number of current critical alarms. |
| informational_alarms | Number | Number of current informational alarms. |
| major_alarms | Number | Number of current major alarms. |
| warning_alarms | Number | Number of current warning alarms. |

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
