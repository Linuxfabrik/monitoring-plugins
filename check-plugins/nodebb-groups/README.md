# Check nodebb-groups

## Overview

Get NodeBB post / group settings.

The Plugin uses the Read API and Bearer Authentication. You need to issue a bearer token of type "user" in the NodeBB admin panel in order to grant access to the API. In NodeBB, a user token is associated with a specific uid, and all calls are made in the name of that user.

To create a Bearer Token, do this:

* Settings \> API Access \> Create Token \> Specify your User ID and Description (for example "Linuxfabrik API Token").

Hints:

* NodeBB Read API: <https://docs.nodebb.org/api/read/>
* Requires NodeBB v1.14.4+.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/nodebb-groups> |
| Check Interval Recommendation         | Once a day |
| Can be called without parameters      | No |
| Compiled for Windows                  | No |
| Requirements                          | NodeBB v1.14.4+ |


## Help

```text
usage: nodebb-groups [-h] [-V] [--insecure] [--no-proxy] [--test TEST]
                     [--timeout TIMEOUT] -p TOKEN [--url URL]

Get NodeBB post settings.

options:
  -h, --help         show this help message and exit
  -V, --version      show program's version number and exit
  --insecure         This option explicitly allows to perform "insecure" SSL
                     connections. Default: False
  --no-proxy         Do not use a proxy. Default: False
  --test TEST        For unit tests. Needs "path-to-stdout-file,path-to-
                     stderr-file,expected-retc".
  --timeout TIMEOUT  Network timeout in seconds. Default: 3 (seconds)
  -p, --token TOKEN  NodeBB API Bearer token.
  --url URL          NodeBB API URL. Default: http://localhost:4567/forum
```


## Usage Examples

```bash
./nodebb-groups --token edd956be-9ea5-4f2a-94ca-3948a1b9d184 --warning 120 --critical 365
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

| Name  | Type   | Description     |
|-------|--------|-----------------|
| posts | Number | Number of posts |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
