# Check logfile


## Overview

Scans a logfile for matching patterns or regular expressions and alerts based on the number of matches found. Supports both simple string matching (`--warning-pattern`, `--critical-pattern`) and Python regular expressions (`--warning-regex`, `--critical-regex`). Lines can be excluded via `--ignore-pattern` or `--ignore-regex`.

**Important Notes:**

* Requires root or sudo to access most system logfiles
* `--filename` is confined to `/var/log`. The check runs as root via sudo, so it refuses a path that resolves outside the system log directory, which stops it from being turned into an arbitrary root file read. To monitor a log stored elsewhere, bind-mount that location under `/var/log` (a symlink is rejected); see the [Troubleshooting section](https://github.com/Linuxfabrik/monitoring-plugins#troubleshooting).
* At least one `--warning-pattern`, `--warning-regex`, `--critical-pattern`, or `--critical-regex` must be specified
* When using `--icinga-callback`, the parameters `--icinga-url`, `--icinga-password`, `--icinga-username`, and `--icinga-service-name` are all required. Create an Icinga API user like so:

```text
object ApiUser "linuxfabrik-check-logfile" {
  password = "linuxfabrik"
  permissions = [
  {
    permission = "objects/query/service"
  }]
}
```

* For more complex log analysis use cases, consider using a dedicated logging server like Graylog

**Data Collection:**

* Expands time macros in `--filename` on every run, so logfiles whose name contains the current date (`{today}.log`, `app-{today}.log`, `{%Y}{%m}{%d}.log`, etc.) can be monitored directly. For `{today}` and `{yesterday}`, the compact form (`YYYYMMDD`) is tried first and ISO 8601 (`YYYY-MM-DD`) is used as fallback. The read offset and pending matches carry over when the filename changes on the next day, so no wrapper script is needed
* Scans only the lines that were added since the previous run, and rescans the whole logfile once it was rotated, truncated, or rewritten from the beginning by the application. A rewrite that reproduces the first 256 bytes of the logfile unchanged is not recognized as one
* Keeps its state in a SQLite database. Each combination of logfile and pattern set gets its own database, so two services watching the same logfile for different things do not interfere. Changing a pattern starts a new database, and the next run therefore reports every match the logfile still holds
* `--warning-pattern` and `--critical-pattern` search for plain substrings and are faster than their regex counterparts
* Matches keep alerting across runs, even once the logfile stops growing: for `--alarm-duration` minutes (default 60), or, with `--icinga-callback`, until the service is acknowledged in Icinga. They appear in the output as "Unacknowledged warning/critical matches from previous runs" and count towards the thresholds like new matches do


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/logfile> |
| Nagios/Icinga Check Name              | `check_logfile` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | No (`--filename` and at least one pattern/regex are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | Yes |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-logfile-<basename>-<hash>.db` (one DB per combination of logfile and pattern set) |


## Help

```text
usage: logfile [-h] [-V] [--alarm-duration ALARM_DURATION] [--always-ok]
               [-c CRIT] [--critical-pattern CRIT_PATTERN]
               [--critical-regex CRIT_REGEX] --filename FILENAME
               [--icinga-callback] [--icinga-password ICINGA_PASSWORD]
               [--icinga-service-name ICINGA_SERVICE_NAME]
               [--icinga-url ICINGA_URL] [--icinga-username ICINGA_USERNAME]
               [--ignore-pattern IGNORE_PATTERN] [--ignore-regex IGNORE_REGEX]
               [--insecure] [--no-perfdata] [--no-proxy] [--suppress-lines]
               [--timeout TIMEOUT] [-w WARN] [--warning-pattern WARN_PATTERN]
               [--warning-regex WARN_REGEX]

Scans a logfile for matching patterns or regular expressions and alerts based
on the number of matches found. Only the lines added since the previous run
are scanned, and the whole file is rescanned whenever it was rotated,
truncated or rewritten in place. Supports Icinga acknowledgement integration
to suppress repeated alerts for known issues. Configurable alarm duration
limits how long matches trigger alerts. `--filename` accepts time macros, so
logfiles whose name contains the current date (`20260422.log`,
`app-2026-04-22.log`, etc.) can be monitored directly. `{today}` /
`{yesterday}` resolve tolerantly: compact (`YYYYMMDD`) first, ISO 8601 (`YYYY-
MM-DD`) as fallback if the compact file does not exist. Read offset and
pending matches carry over when the filename changes on the next day, no
wrapper script needed. Requires root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --alarm-duration ALARM_DURATION
                        Duration in minutes for how long new matches trigger
                        an alert. Overwritten by `--icinga-callback`. Default:
                        60
  --always-ok           Always returns OK.
  -c, --critical CRIT   CRIT threshold for the number of found critical
                        matches. Default: 1
  --critical-pattern CRIT_PATTERN
                        Any line containing this pattern will count as a
                        critical. Can be specified multiple times.
  --critical-regex CRIT_REGEX
                        Any line matching this Python regex will count as a
                        critical. Can be specified multiple times.
  --filename FILENAME   Path to the logfile. Supports time macros that are
                        expanded on every run: `{today}` / `{yesterday}` first
                        try the compact form `YYYYMMDD`, then fall back to
                        `YYYY-MM-DD` if that file does not exist. `{%Y}`,
                        `{%y}`, `{%m}`, `{%d}`, `{%H}`, `{%M}`, `{%S}` render
                        the matching strftime component of the current time.
                        Example: `/var/log/app/{today}.log`. Example:
                        `/var/log/app/app-{today}.log`. Example:
                        `/var/log/app/{%Y}{%m}{%d}.log`.
  --icinga-callback     Get the service acknowledgement from Icinga.
                        Overwrites `--alarm-duration`. Default: False
  --icinga-password ICINGA_PASSWORD
                        Icinga API password.
  --icinga-service-name ICINGA_SERVICE_NAME
                        Unique name of the service using this check within
                        Icinga. Take it from the `__name` service attribute.
                        Example: `icinga-server!my-service-name`.
  --icinga-url ICINGA_URL
                        Icinga API URL. Example: `https://icinga-server:5665`.
  --icinga-username ICINGA_USERNAME
                        Icinga API username.
  --ignore-pattern IGNORE_PATTERN
                        Any line containing this pattern will be ignored.
                        Case-sensitive. Can be specified multiple times.
  --ignore-regex IGNORE_REGEX
                        Any item matching this Python regex will be ignored.
                        Can be specified multiple times. Example:
                        `(?i)linuxfabrik` for a case-insensitive match.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --no-proxy            Do not use a proxy.
  --suppress-lines      Suppress the found lines in the output and only report
                        the number of findings.
  --timeout TIMEOUT     Network timeout in seconds. Default: 5 (seconds)
  -w, --warning WARN    WARN threshold for the number of found warning
                        matches. Default: 1
  --warning-pattern WARN_PATTERN
                        Any line containing this pattern will count as a
                        warning. Can be specified multiple times.
  --warning-regex WARN_REGEX
                        Any line matching this Python regex will count as a
                        warning. Can be specified multiple times.
```


## Usage Examples

```bash
cat > /tmp/test-logfile << 'EOF'
test0
test1
warning
test2
test
error1
error2
test4
EOF

./logfile --filename=/tmp/test-logfile --critical-pattern='error' --warning-pattern='warn'
```

Output:

```text
Scanned /tmp/test-logfile (8 lines) using patterns 'warn' (matched 1 line) [WARNING] and 'error' (matched 2 lines) [CRITICAL].

Warning matches:
* warning

Critical matches:
* error1
* error2
```

The `(N lines)` figure counts the lines that are **new** since the previous run, not the length of the logfile. Both are the same on the first run and after a rotation.


## States

* OK if no matches are found or the number of matches is below both thresholds.
* WARN if the number of warning matches (new + old) is >= `--warning` (default: 1).
* CRIT if the number of critical matches (new + old) is >= `--critical` (default: 1).
* UNKNOWN if the logfile does not exist, is not readable, or no pattern/regex is specified.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| crit_matches | Number | Number of new critical matches found in this run. |
| scanned_lines | Number | Total number of new lines scanned in this run. |
| warn_matches | Number | Number of new warning matches found in this run. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
