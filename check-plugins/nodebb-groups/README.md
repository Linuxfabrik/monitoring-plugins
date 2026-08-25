# Check nodebb-groups


## Overview

Monitors NodeBB group statistics via the admin API, including group count and membership numbers. This is an informational check only.

**Important Notes:**

* You need to issue a bearer token of type "user" in the NodeBB admin panel: Settings > API Access > Create Token > Specify your User ID and Description (for example "Linuxfabrik API Token"). In NodeBB, a user token is associated with a specific uid, and all calls are made in the name of that user.
* NodeBB Read API: <https://docs.nodebb.org/api/read/>
* Requires NodeBB v1.14.4+.

**Data Collection:**

* Queries the NodeBB Read API endpoint `/api/admin/settings/post` using Bearer Authentication
* Reports the number of groups exempt from the post queue, with details on the newest group including name, visibility, member count, and creation date


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/nodebb-groups> |
| Nagios/Icinga Check Name              | `check_nodebb_groups` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | No (`--token` is required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |


## Help

```text
usage: nodebb-groups [-h] [-V] [--always-ok] [--insecure] [--no-perfdata]
                     [--no-proxy] [--proxy PROXY] [--timeout TIMEOUT] -p TOKEN
                     [--url URL]

Monitors NodeBB group statistics via the admin API, including group count and
membership numbers.

options:
  -h, --help         show this help message and exit
  -V, --version      show program's version number and exit
  --always-ok        Always returns OK.
  --insecure         This option explicitly allows insecure SSL connections.
  --no-perfdata      Suppress the performance data section from the output.
                     The status message and the exit code are unaffected, so
                     alerting keeps working while trending data is dropped.
  --no-proxy         Do not use a proxy, not even one the environment names.
                     Overrides `--proxy`.
  --proxy PROXY      Proxy to reach the target through. The scheme defaults to
                     `http` when omitted. Overrides the proxy the environment
                     names (`http_proxy`, `https_proxy`, `all_proxy`) together
                     with the exceptions it lists in `no_proxy`, and is itself
                     overridden by `--no-proxy`. Without either parameter the
                     environment applies. Credentials belong into the
                     environment variable rather than here, because a command-
                     line argument is visible to every user on the host.
                     Example: `--proxy=http://proxy.example.com:3128`.
  --timeout TIMEOUT  Network timeout in seconds. Default: 3 (seconds)
  -p, --token TOKEN  NodeBB API bearer token.
  --url URL          NodeBB API URL. Default: http://localhost:4567/forum

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/nodebb-groups/
```


## Usage Examples

```bash
./nodebb-groups --token edd956be-9ea5-4f2a-94ca-3948a1b9d184
```

Output:

```text
57 groups, newest group: "Lorem ipsum" (private) with 2 members (created 2022-03-06 16:21:16 (4M 1W ago) ago)

createtime                      ! slug        ! memberCount
--------------------------------+-------------+-------------
2022-03-06 16:21:16 (4M 1W ago) ! lorem-ipsum ! 2
...
```


## States

* Always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| posts | Number | Number of groups exempt from the post queue. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
