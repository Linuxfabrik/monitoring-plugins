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
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-cache.db` |


## Help

```text
usage: huawei-pacific-power [-h] [-V] [--always-ok]
                            [--cache-expire CACHE_EXPIRE] [--insecure]
                            [--no-proxy] --password PASSWORD [--scope SCOPE]
                            [--timeout TIMEOUT] -u URL --username USERNAME

Checks the status of all power supplies on a Huawei OceanStor Pacific storage
system via the REST API (/hwm/power endpoint). Alerts when any power supply
reports a non-normal status.

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
./huawei-pacific-power --url=https://oceanstor:8088 --username=monitoring --password=mypass
```

Output:

```text
Everything is ok.

Chassis SN            ! Name ! Status ! State
----------------------+------+--------+------
2102355GLC10N9100002  ! PSU0 ! normal ! [OK]
2102355GLC10N9100002  ! PSU1 ! normal ! [OK]

Fetched API 2 times
```


## States

* OK if all power supplies report a status of "normal".
* WARN if any power supply reports a status other than "normal".
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
