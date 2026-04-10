# Check example

## Overview

Skeleton plugin demonstrating all standard patterns and library functions: argparse with append/deprecated/suppress parameters, (success, result) error handling, SQLite delta calculations (no continuous counters), regex filtering, `--lengthy` table output, human-readable formatting (bytes, seconds, numbers), perfdata, get_state/get_worst, and Grafana-compatible panel design. Use this as a template for new check plugins.

**Data Collection:**

* Executes a shell command (`cat /etc/os-release` as a placeholder) to collect data
* Items can be filtered by `--name` (exact match) and excluded by `--ignore-regex` (Python regular expression)
* Uses SQLite state persistence between runs to calculate deltas (e.g. bytes per second)
* On the first run, returns "Waiting for more data." until at least two measurements are available
* After a system reboot, counter values may be lower than the previous measurement. The check detects this (negative delta) and returns "Waiting for more data." until the next valid measurement pair

**Compatibility:**

* Cross-platform: Linux, Windows, and all psutil-supported systems

## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/example> |
| Nagios/Icinga Check Name              | `check_example` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | No (`--token` is required) |
| Compiled for Windows                  | No (runs with Python interpreter) |
| 3rd Party Python modules              | `psutil` |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-example.db` |


## Help

```text
usage: example [-h] [-V] [--always-ok] [-c CRIT] [--ignore-regex IGNORE_REGEX]
               [--insecure] [--lengthy] [--module MODULE] [--name NAME]
               [--no-proxy] [--test TEST] [--timeout TIMEOUT] --token TOKEN
               [--url URL] [-w WARN]

Skeleton plugin demonstrating all standard patterns and library functions:
argparse with append/deprecated/suppress parameters, (success, result) error
handling, SQLite delta calculations (no continuous counters), regex filtering,
--lengthy table output, human-readable formatting (bytes, seconds, numbers),
perfdata, get_state/get_worst, and Grafana-compatible panel design.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRIT   CRIT threshold in percent. Supports Nagios ranges.
                        Default: 90
  --ignore-regex IGNORE_REGEX
                        Any item matching this Python regex will be ignored.
                        Can be specified multiple times. Example:
                        `(?i)linuxfabrik` for a case-insensitive match.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --lengthy             Extended reporting.
  --module MODULE       "modulename" to check (startswith). Can be specified
                        multiple times. Example: `--module json --module
                        mbstring`
  --name NAME           Only check items with this name. Can be specified
                        multiple times. If not specified, all items are
                        checked.
  --no-proxy            Do not use a proxy.
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --token TOKEN         Software API token.
  --url URL             URL to the endpoint. Default: http://localhost
  -w, --warning WARN    WARN threshold in percent. Supports Nagios ranges.
                        Default: 80
```


## Usage Examples

```bash
./example --token=mytoken --warning=80 --critical=90
```

Output (first run):

```text
Waiting for more data.
```

Output (subsequent runs):

```text
42% used, up 1D 10h, since 2026-04-09 06:30:44, 1.0GiB/s, 42K items

Title       ! Value
------------+------
Lorem ipsum ! 42%
```

With `--lengthy`:

```text
42% used, up 1D 10h, since 2026-04-09 06:30:44, 1.0GiB/s, 42K items

Title       ! Type  ! Value
------------+-------+------
Lorem ipsum ! Lorem ! 42%
```


## States

* OK if the percentage value is below the warning threshold.
* OK with "Waiting for more data." on the first run or after a reboot.
* WARN if the percentage value is >= `--warning` (default: 80).
* CRIT if the percentage value is >= `--critical` (default: 90).
* UNKNOWN on missing Python modules, invalid `--ignore-regex` patterns, or invalid command-line arguments.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| cpu-usage | Percentage | The measured percentage value. |
| rx-bytes-per-second | Bytes | Received bytes per second, calculated as delta between two consecutive check runs. |


## Troubleshooting

`Python module "psutil" is not installed.`  
Install `psutil`: `pip install psutil` or `dnf install python3-psutil`.

`Waiting for more data.`  
This is expected on the first run. The check needs at least two measurements to calculate a delta. Wait for the next check interval.

`Unable to compile regex.`  
The pattern passed via `--ignore-regex` is not a valid Python regular expression. Check the syntax at <https://docs.python.org/3/library/re.html>.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
