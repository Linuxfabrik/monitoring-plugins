# Check starface-account-stats


## Overview

Reports account statistics of a Starface PBX, including ringing, active, available, and unavailable accounts.

**Important Notes:**

* Requires the [Starface Monitoring Module](https://wiki.fluxpunkt.de/display/FPW/Monitoring) to be installed on the PBX

**Data Collection:**

* Connects via socket to the [Starface Monitoring Module](https://wiki.fluxpunkt.de/display/FPW/Monitoring) on port 6556
* Supports both IPv4 (default) and IPv6
* Fetched data is cached for up to one minute in a shared SQLite database, so that multiple Starface checks running in parallel do not overload the PBX

**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/starface-account-stats> |
| Nagios/Icinga Check Name              | `check_starface_account_stats` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Requirements                          | [Monitoring module for Starface PBX](https://wiki.fluxpunkt.de/display/FPW/Monitoring) |
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-monitoring-plugins-starface.db` |


## Help

```text
usage: starface-account-stats [-h] [-V] [--cache-expire CACHE_EXPIRE]
                              [-H HOSTNAME] [--port PORT] [--test TEST]
                              [--timeout TIMEOUT] [--ipv6]

Monitors account statistics of a Starface PBX via its monitoring module on
port 6556. Reports SIP and DAHDI account states including registered,
unregistered, and failed accounts. Supports both IPv4 and IPv6. Data is cached
to avoid overloading the PBX when multiple checks run in parallel.

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
./starface-account-stats --cache-expire 1 --hostname mypbx --port 6556 --timeout 3
```

Output:

```text
1 ringing, 6 active, 86 available (total 97 accounts)
6 of them are admin accounts
```


## States

* Always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| active_accounts | Number | Number of currently active accounts |
| admin_accounts | Number | Number of admin accounts |
| available_accounts | Number | Number of available accounts |
| ringing_accounts | Number | Number of currently ringing accounts |
| total_accounts | Number | Total number of accounts |
| unavailable_accounts | Number | Number of unavailable accounts |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
