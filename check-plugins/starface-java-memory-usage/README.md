# Check starface-java-memory-usage

## Overview

Monitors Java heap and non-heap memory usage of the Starface PBX. If the JVM reports unlimited memory for heap or non-heap, no percentage is calculated and no threshold check is performed for that memory area.

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
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/starface-java-memory-usage> |
| Nagios/Icinga Check Name              | `check_starface_java_memory_usage` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Requirements                          | [Monitoring module for Starface PBX](https://wiki.fluxpunkt.de/display/FPW/Monitoring) |
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-monitoring-plugins-starface.db` |


## Help

```text
usage: starface-java-memory-usage [-h] [-V] [--always-ok]
                                  [--cache-expire CACHE_EXPIRE]
                                  [--critical CRIT] [-H HOSTNAME]
                                  [--port PORT] [--test TEST]
                                  [--timeout TIMEOUT] [--warning WARN]
                                  [--ipv6]

Monitors Java heap and non-heap memory usage of a Starface PBX via its
monitoring module on port 6556. Alerts when memory usage exceeds the
configured thresholds. Supports both IPv4 and IPv6. Data is cached to avoid
overloading the PBX when multiple checks run in parallel.

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
./starface-java-memory-usage --cache-expire 1 --hostname mypbx --port 6556 --timeout 3
```

Output:

```text
Heap used: 5.2% (277.7MiB of 5.2GiB), Non-Heap used: 303.2MiB (unlimited memory usage allowed)
```


## States

* OK if heap and non-heap memory usage are below the warning thresholds.
* WARN if heap or non-heap memory usage is >= `--warning` (default: 80%).
* CRIT if heap or non-heap memory usage is >= `--critical` (default: 90%).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| heap-max | Bytes | Maximum available Java heap space |
| heap-used | Bytes | Currently used Java heap space |
| heap-used-percent | Percentage | heap-used / heap-max \* 100 |
| non-heap-max | Bytes | Maximum available Java non-heap space |
| non-heap-used | Bytes | Currently used Java non-heap space |
| non-heap-used-percent | Percentage | non-heap-used / non-heap-max \* 100 |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
