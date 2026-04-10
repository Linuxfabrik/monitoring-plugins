# Check starface-backup-status

## Overview

Checks the status of the most recent backup of a Starface PBX, including backup age, target, and success state.

**Alerting Logic:**

* WARN or CRIT if the age of the last backup exceeds the configured thresholds (default WARN: 24 hours)
* WARN if the last backup did not finish successfully
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
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/starface-backup-status> |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Requirements                          | [Monitoring module for Starface PBX](https://wiki.fluxpunkt.de/display/FPW/Monitoring) |
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-monitoring-plugins-starface.db` |


## Help

```text
usage: starface-backup-status [-h] [-V] [--always-ok]
                              [--cache-expire CACHE_EXPIRE] [-c CRIT]
                              [-H HOSTNAME] [--port PORT] [--test TEST]
                              [--timeout TIMEOUT] [-w WARN] [--ipv6]

Checks the status of the newest backups of a Starface PBX via its monitoring
module on port 6556. Reports backup age, size, and success state. Supports
both IPv4 and IPv6. Data is cached to avoid overloading the PBX when multiple
checks run in parallel. Alerts when the latest backup has failed or is too
old.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --cache-expire CACHE_EXPIRE
                        The amount of time after which the credential/data
                        cache expires, in minutes. Default: 1
  -c, --critical CRIT   CRIT threshold for the age of the last backup, in
                        hours. Default: None
  -H, --hostname HOSTNAME
                        Starface PBX hostname or IP address. Default:
                        localhost
  --port PORT           Starface PBX monitoring port. Default: 6556
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  -w, --warning WARN    WARN threshold for the age of the last backup, in
                        hours. Default: 24
  --ipv6                Use IPv6.
```


## Usage Examples

```bash
./starface-backup-status --cache-expire 1 --hostname mypbx --port 6556 --timeout 3
```

Output:

```text
Last Backup to [HDD] at 2021-06-21 01:14:07 (13h 45m ago) was successful.
```


## States

* OK if the last backup was successful and its age is below the warning threshold.
* WARN if the last backup age exceeds `--warning` (default: 24 hours).
* WARN if the last backup failed.
* CRIT if the last backup age exceeds `--critical` (default: none).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
