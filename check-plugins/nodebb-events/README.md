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
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | No (`--token` is required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |


## Help

```text
usage: nodebb-events [-h] [-V] [--insecure] [--no-proxy] [--test TEST]
                     [--timeout TIMEOUT] -p TOKEN [--url URL]

Retrieves recent events from the NodeBB event log via the admin API. Reports
administrative actions such as user bans, plugin activations, and
configuration changes.

options:
  -h, --help         show this help message and exit
  -V, --version      show program's version number and exit
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
