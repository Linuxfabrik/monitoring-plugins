# Check huawei-pacific-alarm


## Overview

Lists active (unrecovered) alarms on a Huawei OceanStor Pacific storage system via the REST API (`/common/alarms` endpoint). Alerts when unrecovered alarms are present: critical if any critical alarm exists, warning for major or warning alarms.

**Important Notes:**

* Create a read-only API user that can perform queries only
* Only alarms in the "unrecovered" state are reported; cleared and recovered alarms are ignored
* The credential/session token is cached in a local SQLite database between runs; `--cache-expire` controls how long it is reused before a fresh login

**Data Collection:**

* Queries the Huawei OceanStor Pacific REST API at `https://<ip>:<port>/api/v2/common/alarms`, filtered to unrecovered alarms
* Authenticates via a session token (`X-Auth-Token`), cached in a SQLite database to avoid repeated logins
* If the appliance rejects a request (for example after a session reset or timeout), the check logs in again and retries


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/huawei-pacific-alarm> |
| Nagios/Icinga Check Name              | `check_huawei_pacific_alarm` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | No (`--password`, `--url` and `--username` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-cache.db` |


## Help

```text
usage: huawei-pacific-alarm [-h] [-V] [--always-ok]
                            [--cache-expire CACHE_EXPIRE] [--insecure]
                            [--no-proxy] --password PASSWORD [--scope SCOPE]
                            [--timeout TIMEOUT] -u URL --username USERNAME

Lists active (unrecovered) alarms on a Huawei OceanStor Pacific storage system
via the REST API (/common/alarms endpoint). Alerts when unrecovered alarms are
present: critical if any critical alarm exists, warning for major or warning
alarms.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --cache-expire CACHE_EXPIRE
                        The amount of time after which the credential/data
                        cache expires, in minutes. Default: 15
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-proxy            Do not use a proxy.
  --password PASSWORD   Huawei OceanStor Pacific API password.
  --scope SCOPE         Huawei OceanStor Pacific API scope.
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -u, --url URL         Huawei OceanStor Pacific API URL.
  --username USERNAME   Huawei OceanStor Pacific API username.
```


## Usage Examples

```bash
./huawei-pacific-alarm --url=https://oceanstor:8088 --username=monitoring --password=mypass
```

Output:

```text
There are critical alarms.

Alarm ID    ! Time                ! Severity     ! Name                   ! State
------------+---------------------+--------------+------------------------+-----------
0xF00F40003 ! 2023-08-31 16:23:43 ! Critical (6) ! License Has Expired    ! [CRITICAL]
0xF00F40010 ! 2023-08-31 16:25:00 ! Major (5)    ! Disk Predicted To Fail ! [WARNING]

Fetched API 1 time
```


## States

* OK if there are no unrecovered alarms.
* WARN if any unrecovered alarm has a "major" or "warning" severity.
* CRIT if any unrecovered alarm has a "critical" severity.
* UNKNOWN on invalid API responses or responses with error codes.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| critical_alarms | Number | Number of unrecovered critical alarms. |
| major_alarms | Number | Number of unrecovered major alarms. |
| warning_alarms | Number | Number of unrecovered warning alarms. |


## Troubleshooting

### No valuable response from the API

`Got no valuable response from https://...`

Check the `--url`, `--username` and `--password` parameters. Verify that the API user has query permissions and that the storage system REST API is reachable.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
