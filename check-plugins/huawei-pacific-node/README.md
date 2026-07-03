# Check huawei-pacific-node


## Overview

Checks the health and running status of all cluster nodes on a Huawei OceanStor Pacific storage system via the REST API (`/cluster/servers` endpoint). Alerts when any node is not online or its OAM agent is not healthy.

**Important Notes:**

* Create a read-only API user that can perform queries only
* The credential/session token is cached in a local SQLite database between runs; `--cache-expire` controls how long it is reused before a fresh login

**Data Collection:**

* Queries the Huawei OceanStor Pacific REST API at `https://<ip>:<port>/api/v2/cluster/servers`
* Authenticates via a session token (`X-Auth-Token`), cached in a SQLite database to avoid repeated logins
* If the appliance rejects a request (for example after a session reset or timeout), the check logs in again and retries


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/huawei-pacific-node> |
| Nagios/Icinga Check Name              | `check_huawei_pacific_node` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | No (`--password`, `--url` and `--username` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-cache.db` |


## Help

```text
usage: huawei-pacific-node [-h] [-V] [--always-ok]
                           [--cache-expire CACHE_EXPIRE] [--insecure]
                           [--no-proxy] --password PASSWORD [--scope SCOPE]
                           [--timeout TIMEOUT] -u URL --username USERNAME

Checks the health and running status of all cluster nodes on a Huawei
OceanStor Pacific storage system via the REST API (/cluster/servers endpoint).
Alerts when any node is not online or its OAM agent is not healthy.

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
./huawei-pacific-node --url=https://oceanstor:8088 --username=monitoring --password=mypass
```

Output:

```text
Everything is ok.

Name  ! Management IP ! Model             ! Running ! OAM Agent   ! Running State ! OAM State
------+---------------+-------------------+---------+-------------+---------------+----------
FSM01 ! 192.0.2.11    ! OceanStor Pacific ! online  ! healthy (0) ! [OK]          ! [OK]
HN00  ! 192.0.2.12    ! OceanStor Pacific ! online  ! healthy (0) ! [OK]          ! [OK]

Fetched API 1 time
```


## States

* OK if all nodes report a running status of "online" and an OAM agent status of "healthy".
* WARN if any node's running status is not "online".
* WARN if any node's OAM agent status is not "healthy".
* UNKNOWN on invalid API responses or responses with error codes.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| \<node\>\_oam_agent_status | Number | OAM agent status of the node. -1: --, 0: healthy, 1: faulty. |


## Troubleshooting

### No valuable response from the API

`Got no valuable response from https://...`

Check the `--url`, `--username` and `--password` parameters. Verify that the API user has query permissions and that the storage system REST API is reachable.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
