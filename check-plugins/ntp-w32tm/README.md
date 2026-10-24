# Check ntp-w32tm


## Overview

Checks how far the system clock is off from the time the Windows Time service (W32Time) derives from its time source, in milliseconds, and how long ago it last synchronized. Alerts when the offset or the time since the last synchronization exceeds the configured thresholds, when the stratum is too high, when no time source is used, when a leap second is announced, or when the last synchronization failed.

**Important Notes:**

* `w32tm` prints its output in the display language of the host, and Windows offers no way to request another language for a single call. The check reads English and German output. On a host with any other display language it reports UNKNOWN instead of guessing.
* The offset is the "Phase Offset" W32Time measured at its last synchronization. A clock that jumps in between shows up only at the next poll. The `ntp-offset` check measures the offset itself, at every run.
* By default, W32Time polls every 64 to 1024 seconds on a domain controller, and at most every 2^15 seconds (about 9.1 hours) on domain members and stand-alone hosts ([Windows Time Service Tools and Settings](https://learn.microsoft.com/en-us/windows-server/networking/windows-time-service/windows-time-service-tools-and-settings)). The default `--warning-age=10h` therefore means at least one missed synchronization. A time server with the `0x1` (SpecialInterval) flag, as in the default `time.windows.com,0x9`, is polled every `SpecialPollInterval` seconds instead, 604800 (one week) on a stand-alone host. Since Windows 10 1703 and Windows Server 2019, `MaxPollInterval` caps it at 2^15 seconds; on Windows Server 2016, raise `--warning-age`, for example to `8D`.
* Microsoft supports an accuracy of 50 ms only for hosts no further than stratum 5 from a highly accurate time source (["Support boundary for high accuracy time"](https://learn.microsoft.com/en-us/troubleshoot/windows-server/active-directory/support-boundary-high-accuracy-time)), hence the default `--stratum=6`.

**Data Collection:**

* Executes `w32tm /query /status /verbose` to obtain detailed time synchronization status
* Parses Leap Indicator, Stratum, Precision, Root Delay, Root Dispersion, Source, Phase Offset, Clock Rate, Last Sync Error, and Time since Last Good Sync Time, in English or German (for example "Stammverzögerung" for "Root Delay")


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
usage: ntp-w32tm [-h] [-V] [--always-ok] [-c CRIT] [--critical-age CRIT_AGE]
                 [--no-perfdata] [--stratum STRATUM] [--timeout TIMEOUT]
                 [-w WARN] [--warning-age WARN_AGE]

Checks how far the system clock is off from the time the Windows Time service
(W32Time) derives from its time source, in milliseconds, and how long ago it
last synchronized. Alerts when the offset or the time since the last
synchronization exceeds the configured thresholds, when the stratum is too
high, when no time source is used, when a leap second is announced, or when
the last synchronization failed. Reads the output in English and German.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRIT   CRIT threshold for the offset of the system clock,
                        fast or slow, in milliseconds. Supports Nagios ranges.
                        Default: 60000
  --critical-age CRIT_AGE
                        CRIT threshold for the time since W32Time last
                        synchronized the clock. A duration such as `30m`, `2h`
                        or `1D`; `0D` disables it. Default: 0D
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --stratum STRATUM     Warns if the stratum of this host is greater than or
                        equal to this value. Stratum 1 indicates a computer
                        with a locally attached reference clock. A computer
                        that is synchronised to a stratum 1 computer is at
                        stratum 2. A computer that is synchronised to a
                        stratum 2 computer is at stratum 3, and so on.
                        Default: 6
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  -w, --warning WARN    WARN threshold for the offset of the system clock,
                        fast or slow, in milliseconds. Supports Nagios ranges.
                        Default: 300
  --warning-age WARN_AGE
                        WARN threshold for the time since W32Time last
                        synchronized the clock. A duration such as `30m`, `2h`
                        or `1D`; `0D` disables it. Default: 10h

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/ntp-w32tm/
```


## Usage Examples

```bash
./ntp-w32tm --warning=300 --critical=60000 --warning-age=10h --stratum=6
```

Output:

```text
System clock is 0.004ms slow compared to the time W32Time derives from time.windows.com, Stratum is 4, last synchronized 8s ago

Leap Indicator: 0(no warning)
Stratum: 4 (secondary reference - syncd by (S)NTP)
Precision: -23 (119.209ns per tick)
Root Delay: 0.0296267s
Root Dispersion: 0.0448955s
ReferenceId: 0xC0000226 (source IP:  192.0.2.38)
Last Successful Sync Time: 9/16/2023 12:47:56 PM
Source: time.windows.com,0x8
Poll Interval: 7 (128s)

Phase Offset: 0.0000039s
ClockRate: 0.0156250s
State Machine: 2 (Sync)
Time Source Flags: 0 (None)
Server Role: 0 (None)
Last Sync Error: 0 (The command completed successfully.)
Time since Last Good Sync Time: 7.8834592s
```


## States

* OK if a time source is used and the offset, the stratum and the time since the last synchronization are within their thresholds.
* WARN if the offset, fast or slow, exceeds `--warning` (default: 300ms).
* WARN if the stratum of this host is >= `--stratum` (default: 6).
* WARN if W32Time is not synchronized (Stratum 0): it uses no NTP server, for example "Local CMOS Clock" as source, or has not synchronized with its NTP server yet, as for a while after a clock step.
* WARN if "Leap Indicator" is not 0.
* WARN if "Last Sync Error" is not 0.
* WARN if W32Time last synchronized longer than `--warning-age` ago (default: 10h).
* WARN on a timeout while querying the Windows Time Service.
* WARN if the Windows Time service (w32time) is not running. On a host outside a domain it starts on demand only.
* CRIT if the offset, fast or slow, exceeds `--critical` (default: 60000ms).
* CRIT if W32Time last synchronized longer than `--critical-age` ago (default: not checked).
* UNKNOWN if `w32tm` fails, or if its output lacks the stratum or the time since the last good sync, for example because the host uses a display language other than English or German.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| clock_rate | Milliseconds | Clock rate. |
| leap_indicator | Number | Indicates whether an impending leap second is to be inserted or deleted in the last minute of the current day. |
| offset | Milliseconds | Offset of the system clock from the time source at the last synchronization ("Phase Offset"), as RFC 5905 defines it: positive if the system clock is slow, negative if it is fast. Not reported without a time source. |
| precision | Number | Precision value. |
| root_delay | Milliseconds | Total network path delay to the stratum-1 source. |
| root_dispersion | Milliseconds | Total dispersion accumulated through all computers back to the stratum-1 source. |
| stratum | Number | Stratum of this host, as W32Time reports it. |
| sync_age | Seconds | Time since W32Time last synchronized the clock. |


## Troubleshooting

### Output in an unsupported display language

``Unable to read the output of `w32tm /query /status /verbose`.``

`w32tm` prints its output in a display language the check does not know. The check reads English and German. Either install the English language pack and make English the display language of the account the monitoring agent runs as (for LocalSystem, set the system preferred UI language with `Set-SystemPreferredUILanguage -Language en-US` and reboot), or open an issue with the output shown below the message, so that the labels of that language can be added.

### Access denied while querying the Windows Time service

`Access denied while querying the Windows Time service.`

The Windows Time service answers administrators, services and interactive sessions, but not a standard user who logged in remotely, for example over SSH or WinRM. The check works as it is when the Icinga 2 agent runs it, whatever account the agent uses. To try the check by hand as a standard user, log in to the desktop instead of over the network.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
