# Check nodebb-info


## Overview

Retrieves NodeBB process and system information via the admin API, including Node.js version, uptime, memory usage, and Git commit hash. Alerts when memory usage exceeds the configured thresholds.

**Important Notes:**

* You need to issue a bearer token of type "user" in the NodeBB admin panel: Settings > API Access > Create Token > Specify your User ID and Description (for example "Linuxfabrik API Token"). In NodeBB, a user token is associated with a specific uid, and all calls are made in the name of that user.
* NodeBB Read API: <https://docs.nodebb.org/api/read/>
* Requires NodeBB v1.14.4+.

**Data Collection:**

* Queries the NodeBB Read API endpoint `/api/admin/development/info` using Bearer Authentication
* Reports the NodeBB instance ID, Node.js binary path and version, heap usage (used vs. total), RSS (Resident Set Size), and process uptime


## Fact Sheet

| Fact | Value |
|----|----| 
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/nodebb-info> |
| Nagios/Icinga Check Name              | `check_nodebb_info` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | No (`--token` is required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |


## Help

```text
usage: nodebb-info [-h] [-V] [--always-ok] [-c CRIT] [--insecure] [--no-proxy]
                   [--test TEST] [--timeout TIMEOUT] -p TOKEN [--url URL]
                   [-w WARN]

Retrieves NodeBB process and system information via the admin API, including
Node.js version, uptime, memory usage, and Git commit hash. Alerts when memory
usage exceeds the configured thresholds.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  -c, --critical CRIT  CRIT threshold in percent. Default: >= 95
  --insecure           This option explicitly allows insecure SSL connections.
  --no-proxy           Do not use a proxy.
  --test TEST          For unit tests. Needs "path-to-stdout-file,path-to-
                       stderr-file,expected-retc".
  --timeout TIMEOUT    Network timeout in seconds. Default: 3 (seconds)
  -p, --token TOKEN    NodeBB API bearer token.
  --url URL            NodeBB API URL. Default: http://localhost:4567/forum
  -w, --warning WARN   WARN threshold in percent. Default: >= 90
```


## Usage Examples

```bash
./nodebb-info --token edd956be-9ea5-4f2a-94ca-3948a1b9d184
```

Output:

```text
NodeBB unalone-live1:4567, /usr/bin/node v14.19.3, Heap 93.2% used (97.9MiB of 105.1MiB) [WARNING], RSS 141.9MiB, Up 4D 10h
```


## States

* OK if heap usage is below the warning threshold.
* WARN if heap usage is >= `--warning` (default: 90).
* CRIT if heap usage is >= `--critical` (default: 95).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| nodebb_heap_used | Bytes | Heap memory currently in use. |
| nodebb_heap_used_percent | Percentage | Heap memory usage as a percentage of total heap. |
| nodebb_rss | Bytes | Resident Set Size, the non-swapped physical memory the process has used. |
| nodebb_uptime | Seconds | Process uptime. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
