# Check ntp-w32tm


## Overview

Checks the Windows Time Service (w32tm) status, including clock offset, stratum, and time source. Useful for diagnosing time synchronization issues on Windows servers. Alerts when the clock offset exceeds the configured thresholds.

**Important Notes:**

* `w32tm` prints its output in the display language of the host, and Windows offers no way to request another language for a single call. The check reads English and German output. On a host with any other display language it reports UNKNOWN instead of guessing.

**Data Collection:**

* Executes `w32tm /query /status /verbose` to obtain detailed time synchronization status
* Parses Leap Indicator, Stratum, Precision, Root Delay, Root Dispersion, Phase Offset, Clock Rate, Last Sync Error, and Time since Last Good Sync Time, in English or German (for example "Stammverzögerung" for "Root Delay")


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/ntp-w32tm> |
| Nagios/Icinga Check Name              | `check_ntp_w32tm` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Windows |
| Compiled for Windows                  | Yes |


## Help

```text
usage: ntp-w32tm [-h] [-V] [--always-ok] [-c CRIT] [--no-perfdata]
                 [--stratum STRATUM] [--timeout TIMEOUT] [-w WARN]

Checks the Windows Time Service (w32tm) status, including clock offset,
stratum, and time source. Useful for diagnosing time synchronization issues on
Windows servers. Reads the output in English and German. Alerts when the time
since the last successful synchronization exceeds the configured thresholds,
when no time source is used or its stratum is too high, when a leap second is
announced, and when the last synchronization failed.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  -c, --critical CRIT  CRIT threshold for the time since "Last Good Sync", in
                       seconds. Default: 129600
  --no-perfdata        Suppress the performance data section from the output.
                       The status message and the exit code are unaffected, so
                       alerting keeps working while trending data is dropped.
  --stratum STRATUM    Warns if the determined stratum of the time server is
                       greater than or equal to this value. Stratum 1
                       indicates a computer with a locally attached reference
                       clock. A computer that is synchronised to a stratum 1
                       computer is at stratum 2. A computer that is
                       synchronised to a stratum 2 computer is at stratum 3,
                       and so on. Default: 6
  --timeout TIMEOUT    Network timeout in seconds. Default: 8 (seconds)
  -w, --warning WARN   WARN threshold for the time since "Last Good Sync", in
                       seconds. Default: 28800

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/ntp-w32tm/
```


## Usage Examples

```bash
./ntp-w32tm --warning=28800 --critical=129600 --stratum=6
```

Output:

```text
Leap Indicator: 3 (not synchronized), No NTP server used [WARNING], Last Sync Error: 1 (The computer did not resync because no time data was available.)

Leap Indicator: 3(not synchronized)
Stratum: 0 (unspecified)
Precision: -23 (119.209ns per tick)
Root Delay: 0.0267908s
Root Dispersion: 0.0402331s
ReferenceId: 0x00000000 (unspecified)
Last Successful Sync Time: 9/16/2023 12:52:13 PM
Source: time.windows.com,0x8
Poll Interval: 6 (64s)

Phase Offset: 0.7679486s
ClockRate: 0.0156250s
State Machine: 0 (Unset)
Time Source Flags: 0 (None)
Server Role: 0 (None)
Last Sync Error: 1 (The computer did not resync because no time data was available.)
Time since Last Good Sync Time: 19.2218793s
```


## States

* OK if all checks pass and "Time since Last Good Sync Time" is within thresholds.
* WARN if no NTP server is used (Stratum 0).
* WARN if stratum is >= `--stratum` (default: 6).
* WARN if "Leap Indicator" is not 0.
* WARN if "Last Sync Error" is not 0.
* WARN if "Time since Last Good Sync Time" is >= `--warning` (default: 28800s).
* CRIT if "Time since Last Good Sync Time" is >= `--critical` (default: 129600s).
* WARN on a timeout while querying the Windows Time Service.
* WARN if the Windows Time service (w32time) is not running. On a host outside a domain it starts on demand only.
* UNKNOWN if `w32tm` fails, or if its output lacks the stratum or the time since the last good sync, for example because the host uses a display language other than English or German.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| clock_rate | Milliseconds | Clock rate. |
| leap_indicator | Number | Indicates whether an impending leap second is to be inserted or deleted in the last minute of the current day. |
| phase_offset | Milliseconds | Phase offset. |
| precision | Number | Precision value. |
| root_delay | Milliseconds | Total network path delay to the stratum-1 source. |
| root_dispersion | Milliseconds | Total dispersion accumulated through all computers back to the stratum-1 source. |
| stratum | Number | Number of hops away from a computer with an attached reference clock. |
| time_since_last_good_sync_time | Seconds | Time elapsed since the last successful synchronization. |


## Troubleshooting

### Output in an unsupported display language

``Unable to read the output of `w32tm /query /status /verbose`.``

`w32tm` prints its output in a display language the check does not know. The check reads English and German. Either install the English language pack and make English the display language of the account the monitoring agent runs as (for LocalSystem, set the system preferred UI language with `Set-SystemPreferredUILanguage -Language en-US` and reboot), or open an issue with the output shown below the message, so that the labels of that language can be added.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
