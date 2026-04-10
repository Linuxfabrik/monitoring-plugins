# Check starface-channel-status

## Overview

Counts the number of active DAHDI, SIP, and other channels on a Starface PBX, and alerts on channel overusage when a maximum call limit is configured on the PBX.

**Data Collection:**

* Connects via socket to the [Starface Monitoring Module](https://wiki.fluxpunkt.de/display/FPW/Monitoring) on port 6556
* Supports both IPv4 (default) and IPv6
* Fetched data is cached for up to one minute in a shared SQLite database, so that multiple Starface checks running in parallel do not overload the PBX

**Compatibility:**

* Cross-platform

**Important Notes:**

* Requires the [Starface Monitoring Module](https://wiki.fluxpunkt.de/display/FPW/Monitoring) to be installed on the PBX



## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/starface-channel-status> |
| Nagios/Icinga Check Name              | `check_starface_channel_status` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Requirements                          | [Monitoring module for Starface PBX](https://wiki.fluxpunkt.de/display/FPW/Monitoring) |
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-monitoring-plugins-starface.db` |


## Help

```text
usage: starface-channel-status [-h] [-V] [--always-ok]
                               [--cache-expire CACHE_EXPIRE] [--critical CRIT]
                               [-H HOSTNAME] [--port PORT] [--test TEST]
                               [--timeout TIMEOUT] [--warning WARN] [--ipv6]

Counts the number of active DAHDI, SIP, and other channels on a Starface PBX
via its monitoring module on port 6556. Alerts when channel usage exceeds the
configured percentage threshold. Supports both IPv4 and IPv6. Data is cached
to avoid overloading the PBX when multiple checks run in parallel.

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
./starface-channel-status --cache-expire 1 --hostname mypbx --port 6556 --timeout 3
```

Output:

```text
Current channels: 4x DAHDI, 7x SIP
```


## States

* OK if channel usage is below the warning threshold (or no maximum call limit is configured).
* WARN if channel usage is >= `--warning` (default: 80%).
* CRIT if channel usage is >= `--critical` (default: 90%).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| channel_dahdi | Number | Number of currently active DAHDI connections |
| channel_other | Number | Number of all other currently active connections |
| channel_sip | Number | Number of currently active SIP connections |
| max_calls | Number | Maximum allowed concurrent calls (if configured) |
| used_percent | Percentage | Channel usage as a percentage of max_calls (if configured) |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
