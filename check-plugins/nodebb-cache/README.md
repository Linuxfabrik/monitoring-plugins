# Check nodebb-cache


## Overview

Monitors NodeBB cache usage via the admin API. Alerts when cache utilization exceeds the configured thresholds.

**Important Notes:**

* You need to issue a bearer token of type "user" in the NodeBB admin panel: Settings > API Access > Create Token > Specify your User ID and Description (for example "Linuxfabrik API Token"). In NodeBB, a user token is associated with a specific uid, and all calls are made in the name of that user.
* NodeBB Read API: <https://docs.nodebb.org/api/read/>
* Requires NodeBB v1.14.4+.

**Data Collection:**

* Queries the NodeBB Read API endpoint `/api/admin/advanced/cache` using Bearer Authentication
* Reports status, usage percentage, size, hit/miss counts and hit ratio for each cache: `postCache`, `groupCache`, `localCache`, `objectCache`


## Fact Sheet

| Fact | Value |
|----|----| 
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/nodebb-cache> |
| Nagios/Icinga Check Name              | `check_nodebb_cache` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | No (`--token` is required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |


## Help

```text
usage: nodebb-cache [-h] [-V] [--always-ok] [-c CRIT] [--insecure]
                    [--no-proxy] [--severity {warn,crit}] [--test TEST]
                    [--timeout TIMEOUT] -p TOKEN [--url URL] [-w WARN]

Monitors NodeBB cache usage via the admin API. Alerts when cache utilization
exceeds the configured thresholds.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRIT   CRIT threshold in percent. Default: >= 90
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
  -w, --warning WARN    WARN threshold in percent. Default: >= 80
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

* OK if all caches are enabled and usage is below the warning threshold.
* WARN if any cache is disabled (configurable via `--severity`).
* WARN if cache usage is >= `--warning` (default: 80).
* CRIT if cache usage is >= `--critical` (default: 90).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| cache_CACHENAME_hitRatio | Percentage | Cache hit ratio. |
| cache_CACHENAME_hits | Continuous Counter | Number of cache hits. |
| cache_CACHENAME_itemCount | Number | Number of items in the cache. |
| cache_CACHENAME_length | Number | Current cache size. |
| cache_CACHENAME_misses | Continuous Counter | Number of cache misses. |
| cache_CACHENAME_percentFull | Percentage | Cache usage in percent. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
