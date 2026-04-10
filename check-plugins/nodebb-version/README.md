# Check nodebb-version


## Overview

Checks if a NodeBB update is available by comparing the installed version against the latest release. Alerts when an update is available.

**Important Notes:**

* You need to issue a bearer token of type "user" in the NodeBB admin panel: Settings > API Access > Create Token > Specify your User ID and Description (for example "Linuxfabrik API Token"). In NodeBB, a user token is associated with a specific uid, and all calls are made in the name of that user.
* NodeBB Read API: <https://docs.nodebb.org/api/read/>
* Requires NodeBB v1.14.4+.

**Data Collection:**

* Queries the NodeBB Read API endpoint `/api/admin/dashboard` using Bearer Authentication
* Compares the installed NodeBB version against the latest available version
* Reports the last restart timestamp including the user who triggered it

**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|----| 
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/nodebb-version> |
| Nagios/Icinga Check Name              | `check_nodebb_version` |
| Check Interval Recommendation         | Once a day |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
usage: nodebb-version [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                      [--test TEST] [--timeout TIMEOUT] [-p TOKEN] [--url URL]

Checks if a NodeBB update is available by comparing the installed version
against the latest release. Alerts when an update is available.

options:
  -h, --help         show this help message and exit
  -V, --version      show program's version number and exit
  --always-ok        Always returns OK.
  --insecure         This option explicitly allows insecure SSL connections.
  --no-proxy         Do not use a proxy.
  --test TEST        For unit tests. Needs "path-to-stdout-file,path-to-
                     stderr-file,expected-retc".
  --timeout TIMEOUT  Network timeout in seconds. Default: 3 (seconds)
  -p, --token TOKEN  NodeBB API bearer token.
  --url URL          NodeBB API URL. Default: http://localhost:4567/forum
```


## Usage Examples

```bash
./nodebb-version --url http://localhost:4567/forum --token bc68eed3-4cff-4a6e-8372-3b41dfa67635
```

Output:

```text
NodeBB v1.18.1 is available (installed: v1.17.1), Last restart: 2021-08-09 16:03:29 by Linuxfabrik <info at linuxfabrik dot ch> (4W 22h ago)
```


## States

* OK if the installed version is up to date.
* WARN if an update is available.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| nodebb-version | Number | Currently installed version as a float. Example: `1.171` for v1.17.1. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
