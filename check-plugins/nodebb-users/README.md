# Check nodebb-users

## Overview

Monitors NodeBB user statistics via the admin API, including total user count, admins, and banned users.

**Important Notes:**

* You need to issue a bearer token of type "user" in the NodeBB admin panel: Settings > API Access > Create Token > Specify your User ID and Description (for example "Linuxfabrik API Token"). In NodeBB, a user token is associated with a specific uid, and all calls are made in the name of that user.
* NodeBB Read API: <https://docs.nodebb.org/api/read/>
* Requires NodeBB v1.14.4+.



**Data Collection:**

* Queries the NodeBB Read API endpoint `/api/admin/manage/users` using Bearer Authentication
* Reports the total user count, the latest active user, and a table with user ID, slug, last online timestamp, banned status, admin flag, and IP address

**Compatibility:**

* Cross-platform



## Fact Sheet

| Fact | Value |
|----|----| 
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/nodebb-users> |
| Nagios/Icinga Check Name              | `check_nodebb_users` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | No (`--token` is required) |
| Compiled for Windows                  | No |


## Help

```text
usage: nodebb-users [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                    [--severity {warn,crit}] [--test TEST] [--timeout TIMEOUT]
                    -p TOKEN [--url URL]

Monitors NodeBB user statistics via the admin API, including total user count,
admins, and banned users.

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
./nodebb-users --token edd956be-9ea5-4f2a-94ca-3948a1b9d184 --severity warn
```

Output:

```text
402 users, latest active user: alice <alice@example.com>, online 2022-07-12 10:17:23 (22s ago)

uid ! userslug         ! lastonline                        ! banned ! admin ! ip              
----+------------------+-----------------------------------+--------+-------+-----------------
373 ! alice            ! 2022-07-12 10:17:23 (22s ago)     ! False  ! False ! 1.2.3.4         
2   ! bob              ! 2022-07-12 10:17:17 (28s ago)     ! False  ! True  ! 2.3.4.5   
...
```


## States

* OK if no users are banned.
* WARN or CRIT (depending on `--severity`, default: WARN) if a user is banned.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| users | Number | Total number of registered users. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
