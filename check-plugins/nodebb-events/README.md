# Check nodebb-events


## Overview

Retrieves recent events from the NodeBB event log via the admin API. Reports administrative actions such as user bans, plugin activations, and configuration changes. This is an informational check only.

**Important Notes:**

* You need to issue a bearer token of type "user" in the NodeBB admin panel: Settings > API Access > Create Token > Specify your User ID and Description (for example "Linuxfabrik API Token"). In NodeBB, a user token is associated with a specific uid, and all calls are made in the name of that user.
* NodeBB Read API: <https://docs.nodebb.org/api/read/>
* Requires NodeBB v1.14.4+.

**Data Collection:**

* Queries the NodeBB Read API endpoint `/api/admin/advanced/events` using Bearer Authentication
* Displays the latest events with event ID, user ID, display name, event type, timestamp with human-readable age, and IP address


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/nodebb-events> |
| Nagios/Icinga Check Name              | `check_nodebb_events` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | No (`--token` is required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |


## Help

```text
usage: nodebb-events [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                     [--proxy PROXY] [--timeout TIMEOUT] -p TOKEN [--url URL]

Retrieves recent events from the NodeBB event log via the admin API. Reports
administrative actions such as user bans, plugin activations, and
configuration changes. The figures are reported for trending and never alert
on their own.

options:
  -h, --help         show this help message and exit
  -V, --version      show program's version number and exit
  --always-ok        Always returns OK.
  --insecure         This option explicitly allows insecure SSL connections.
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
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/nodebb-events/
```


## Usage Examples

```bash
./nodebb-events --token edd956be-9ea5-4f2a-94ca-3948a1b9d184
```

Output:

```text
Latest event: #770 uid=2 username settings-change 1.2.3.4 (10M 1W ago)

eid ! uid ! displayname ! type            ! timestamp                        ! ip
----+-----+-------------+-----------------+----------------------------------+---------
770 ! 2   ! alice       ! settings-change ! 2021-09-03 14:59:48 (10M 1W ago) ! 1.2.3.4
769 ! 2   ! bob         ! password-reset  ! 2021-09-03 14:30:01 (10M 1W ago) ! 1.2.3.4
```


## States

* Always returns OK.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
