# Check nodebb-errors

## Overview

Retrieves recent server-side errors from NodeBB via the admin API. Alerts when errors are found in the error log.

**Data Collection:**

* Queries the NodeBB Read API endpoint `/api/admin/advanced/errors` using Bearer Authentication
* Reports the count of HTTP 503 (too busy) and HTTP 404 (not found) responses from today

**Important Notes:**

* You need to issue a bearer token of type "user" in the NodeBB admin panel: Settings > API Access > Create Token > Specify your User ID and Description (for example "Linuxfabrik API Token"). In NodeBB, a user token is associated with a specific uid, and all calls are made in the name of that user.
* NodeBB Read API: <https://docs.nodebb.org/api/read/>
* Requires NodeBB v1.14.4+.


## Fact Sheet

| Fact | Value |
|----|----| 
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/nodebb-errors> |
| Nagios/Icinga Check Name              | `check_nodebb_errors` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | No (`--token` is required) |
| Compiled for Windows                  | No |


## Help

```text
usage: nodebb-errors [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                     [--severity {warn,crit}] [--test TEST]
                     [--timeout TIMEOUT] -p TOKEN [--url URL]

Retrieves recent server-side errors from NodeBB via the admin API. Alerts when
errors are found in the error log.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-proxy            Do not use a proxy.
  --severity {warn,crit}
                        Severity for alerts that do not depend on thresholds.
                        One of "warn" or "crit". Default: warn
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -p, --token TOKEN     NodeBB API bearer token.
  --url URL             NodeBB API URL. Default: http://localhost:4567/forum
```


## Usage Examples

```bash
./nodebb-errors --token edd956be-9ea5-4f2a-94ca-3948a1b9d184 --severity warn
```

Output:

```text
HTTP Status today: 0x 503 too busy, 1x 404 not found
```


## States

* OK if no HTTP 503 responses occurred today.
* WARN or CRIT (depending on `--severity`, default: WARN) if any HTTP 503 responses occurred today.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| err404 | Continuous Counter | Number of 404 responses from today. |
| err503 | Continuous Counter | Number of 503 responses from today. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
