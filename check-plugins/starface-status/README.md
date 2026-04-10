# Check starface-status

## Overview

Checks the overall health of a Starface PBX, reporting system state, version, license information, RAID status, SIP status, and phone connectivity.

**Alerting Logic:**

* WARN if RAID status is not "HEALTHY"
* WARN if SIP status is not "OK"
* `--always-ok` suppresses all alerts and always returns OK

**Data Collection:**

* Connects via socket to the [Starface Monitoring Module](https://wiki.fluxpunkt.de/display/FPW/Monitoring) on port 6556
* Supports both IPv4 (default) and IPv6
* Fetched data is cached for up to one minute in a shared SQLite database, so that multiple Starface checks running in parallel do not overload the PBX

**Compatibility:**

* Requires the [Starface Monitoring Module](https://wiki.fluxpunkt.de/display/FPW/Monitoring) to be installed on the PBX


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/starface-status> |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Requirements                          | [Monitoring module for Starface PBX](https://wiki.fluxpunkt.de/display/FPW/Monitoring) |
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-monitoring-plugins-starface.db` |


## Help

```text
usage: starface-status [-h] [-V] [--always-ok] [--cache-expire CACHE_EXPIRE]
                       [--critical CRIT] [-H HOSTNAME] [--port PORT]
                       [--test TEST] [--timeout TIMEOUT] [--warning WARN]
                       [--ipv6]

Checks the overall health of a Starface PBX via its monitoring module on port
6556. Reports system state, version, and license information. Supports both
IPv4 and IPv6. Data is cached to avoid overloading the PBX when multiple
checks run in parallel. Alerts when the PBX reports a non-healthy system
state.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --cache-expire CACHE_EXPIRE
                        The amount of time after which the credential/data
                        cache expires, in minutes. Default: 1
  --critical CRIT       CRIT threshold in percent. Default: >= 90
  -H, --hostname HOSTNAME
                        Starface PBX hostname or IP address. Default:
                        localhost
  --port PORT           Starface PBX monitoring port. Default: 6556
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --warning WARN        WARN threshold in percent. Default: >= 80
  --ipv6                Use IPv6.
```


## Usage Examples

```bash
./starface-status --cache-expire 1 --hostname mypbx --port 6556 --timeout 3
```

Output:

```text
STARFACE Free, v6.7.3.20, RAID Status: HEALTHY, 7 blacklisted hosts, SIP Status: OK, 97 phones online
Owner: Linuxfabrik, 99 licensed users, 138 whitelisted hosts, 167 phones known, 3 phones changed IP, Up 2 weeks, 6 days, 21 hours, 21 minutes, 42 seconds
```


## States

* OK if RAID status is "HEALTHY" and SIP status is "OK".
* WARN if RAID status is not "HEALTHY".
* WARN if SIP status is not "OK".
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| blacklisted_hosts | Number | Number of blacklisted hosts |
| ip_changed_phones | Number | Number of phones that changed their IP address |
| known_phones | Number | Number of known phones |
| online_phones | Number | Number of online phones |
| starface_version | Number | Version number as float |
| whitelisted_hosts | Number | Number of whitelisted hosts |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
