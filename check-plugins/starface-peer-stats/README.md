# Check starface-peer-stats

## Overview

Reports SIP peer statistics of a Starface PBX, including online/offline counts for both monitored and unmonitored peers.

**Data Collection:**

* Connects via socket to the [Starface Monitoring Module](https://wiki.fluxpunkt.de/display/FPW/Monitoring) on port 6556
* Supports both IPv4 (default) and IPv6
* Fetched data is cached for up to one minute in a shared SQLite database, so that multiple Starface checks running in parallel do not overload the PBX

**Compatibility:**

* Requires the [Starface Monitoring Module](https://wiki.fluxpunkt.de/display/FPW/Monitoring) to be installed on the PBX


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/starface-peer-stats> |
| Nagios/Icinga Check Name              | `check_starface_peer_stats` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Requirements                          | [Monitoring module for Starface PBX](https://wiki.fluxpunkt.de/display/FPW/Monitoring) |
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-monitoring-plugins-starface.db` |


## Help

```text
usage: starface-peer-stats [-h] [-V] [--cache-expire CACHE_EXPIRE]
                           [-H HOSTNAME] [--port PORT] [--test TEST]
                           [--timeout TIMEOUT] [--ipv6]

Monitors SIP peer statistics of a Starface PBX via its monitoring module on
port 6556. Reports registered, unregistered, and unreachable peers. Supports
both IPv4 and IPv6. Data is cached to avoid overloading the PBX when multiple
checks run in parallel. Alerts when peers are unregistered or unreachable.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --cache-expire CACHE_EXPIRE
                        The amount of time after which the credential/data
                        cache expires, in minutes. Default: 1
  -H, --hostname HOSTNAME
                        Starface PBX hostname or IP address. Default:
                        localhost
  --port PORT           Starface PBX monitoring port. Default: 6556
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --ipv6                Use IPv6.
```


## Usage Examples

```bash
./starface-peer-stats --cache-expire 1 --hostname mypbx --port 6556 --timeout 3
```

Output:

```text
169 SIP Peers: 98 online / 70 offline (monitored), 1 online / 0 offline (unmonitored)
```


## States

* Always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mon_offline | Number | Number of monitored offline peers |
| mon_online | Number | Number of monitored online peers |
| sip_peers | Number | Total number of SIP peers |
| unmon_offline | Number | Number of unmonitored offline peers |
| unmon_online | Number | Number of unmonitored online peers |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
