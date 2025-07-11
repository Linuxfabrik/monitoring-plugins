# Check nodebb-cache

## Overview

Get NodeBB system cache info.

The Plugin uses the Read API and Bearer Authentication. You need to issue a bearer token of type "user" in the NodeBB admin panel in order to grant access to the API. In NodeBB, a user token is associated with a specific uid, and all calls are made in the name of that user.

To create a Bearer Token, do this:

* Settings \> API Access \> Create Token \> Specify your User ID and Description (for example "Linuxfabrik API Token").

Hints:

* NodeBB Read API: <https://docs.nodebb.org/api/read/>
* Requires NodeBB v1.14.4+.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/nodebb-cache> |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | No |
| Compiled for Windows                  | No |
| Requirements                          | NodeBB v1.14.4+ |


## Help

```text
usage: nodebb-cache [-h] [-V] [--always-ok] [-c CRIT] [--insecure]
                    [--no-proxy] [--severity {warn,crit}] [--test TEST]
                    [--timeout TIMEOUT] -p TOKEN [--url URL] [-w WARN]

Get NodeBB system cache info.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRIT   Set the CRIT threshold as a percentage. Default: >= 90
  --insecure            This option explicitly allows to perform "insecure"
                        SSL connections. Default: False
  --no-proxy            Do not use a proxy. Default: False
  --severity {warn,crit}
                        Severity for alerts that do not depend on thresholds.
                        One of "warn" or "crit". Default: warn
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -p, --token TOKEN     NodeBB API Bearer token.
  --url URL             NodeBB API URL. Default: http://localhost:4567/forum
  -w, --warning WARN    Set the WARN threshold as a percentage. Default: >= 80
```


## Usage Examples

```bash
./nodebb-cache --token edd956be-9ea5-4f2a-94ca-3948a1b9d184 --severity warn
```

Output:

```text
Everything is ok.

Cache       ! Enabled ! Usage  ! Size          ! Hits   ! Misses ! HitRatio 
------------+---------+--------+---------------+--------+--------+----------
postCache   ! True    ! 0.63%  ! 65.9K / 10.5M ! 1.9K   ! 169.0  ! 91.8%    
groupCache  ! True    ! 32.07% ! 12.8K / 40.0K ! 951.2K ! 13.2K  ! 98.6%    
localCache  ! True    ! 2.71%  ! 1.1K / 40.0K  ! 380.9K ! 1.2K   ! 99.7%    
objectCache ! True    ! 5.97%  ! 2.4K / 40.0K  ! 3.2M   ! 147.5K ! 95.6%
```


## States

* Alerts according to the given severity (default: WARN) if any cache is disabled.
* Alerts if cache usage is above the percentage thresholds (default: 80/90%).


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| cache_CACHENAME_hitRatio | Percentage | According to the Web GUI /forum/admin/advanced/cache |
| cache_CACHENAME_hits | Continous Counter | According to the Web GUI /forum/admin/advanced/cache |
| cache_CACHENAME_itemCount | Number | According to the Web GUI /forum/admin/advanced/cache |
| cache_CACHENAME_length | Continous Counter | According to the Web GUI /forum/admin/advanced/cache |
| cache_CACHENAME_misses | Continous Counter | According to the Web GUI /forum/admin/advanced/cache |
| cache_CACHENAME_percentFull | Percentage | According to the Web GUI /forum/admin/advanced/cache |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
