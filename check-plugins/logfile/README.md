# Check logfile


## Overview

Scans a logfile for matching patterns or regular expressions and alerts based on the number of matches found. Supports both simple string matching (`--warning-pattern`, `--critical-pattern`) and Python regular expressions (`--warning-regex`, `--critical-regex`). Lines can be excluded via `--ignore-pattern` or `--ignore-regex`.

**Important Notes:**

* Requires root or sudo to access most system logfiles
* At least one `--warning-pattern`, `--warning-regex`, `--critical-pattern`, or `--critical-regex` must be specified
* When using `--icinga-callback`, the parameters `--icinga-url`, `--icinga-password`, `--icinga-username`, and `--icinga-service-name` are all required. Create an Icinga API user like so:

```text
object ApiUser "linuxfabrik-check-logfile" {
  password = "mysupersecretpassword"
  permissions = [
  {
    permission = "objects/query/service"
  }]
}
```

* For more complex log analysis use cases, consider using a dedicated logging server like Graylog

**Data Collection:**

* Reads the logfile forward from the last known offset, only scanning new lines since the previous run
* Detects logfile rotation by tracking the file's inode and size; resets to the beginning when rotation is detected
* Uses SQLite state persistence to store the file offset and all matching lines between runs
* Pattern arguments use the Python `in` operator for simple substring matching, which is faster than regex in most cases


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/logfile> |
| Nagios/Icinga Check Name              | `check_logfile` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | No (`--filename` and at least one pattern/regex are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | Yes |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-logfile-*.db` |


## Help

```text
usage: logfile [-h] [-V] [--alarm-duration ALARM_DURATION] [--always-ok]
               [-c CRIT] [--critical-pattern CRIT_PATTERN]
               [--critical-regex CRIT_REGEX] --filename FILENAME
               [--icinga-callback] [--icinga-password ICINGA_PASSWORD]
               [--icinga-service-name ICINGA_SERVICE_NAME]
               [--icinga-url ICINGA_URL] [--icinga-username ICINGA_USERNAME]
               [--ignore-pattern IGNORE_PATTERN] [--ignore-regex IGNORE_REGEX]
               [--insecure] [--no-proxy] [--suppress-lines]
               [--timeout TIMEOUT] [-w WARN] [--warning-pattern WARN_PATTERN]
               [--warning-regex WARN_REGEX]

Scans a logfile for matching patterns or regular expressions and alerts based
on the number of matches found. Reads the file backwards from the end and
supports Icinga acknowledgement integration to suppress repeated alerts for
known issues. Configurable alarm duration limits how long matches trigger
alerts. Requires root or sudo.

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
  --filename FILENAME   Path to the logfile.
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
Scanned 8 lines, 1 warning match, 2 critical matches

Warning matches:
* warning

Critical matches:
* error1
* error2
```


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
