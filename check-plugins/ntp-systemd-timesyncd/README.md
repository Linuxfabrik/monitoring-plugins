# Check ntp-systemd-timesyncd


## Overview

Checks which NTP server systemd-timesyncd synchronizes with, the stratum of this host and how long ago it last synchronized. Alerts when no NTP server is used or answers, when the stratum is too high, or when the time since the last synchronization exceeds the configured thresholds.

**Important Notes:**

* The stratum of the NTP time source determines its quality. The stratum is equal to the number of hops to a reference clock (stratum 0). A NTP server connected directly to the reference clock is Stratum 1, a client connected to this NTP server is Stratum 2, etc.
* When the NTP server goes silent, systemd-timesyncd keeps reporting its last answer. The time since that answer reveals it; the check warns after an hour by default (`--warning-age`). systemd-timesyncd normally asks at least every 34 minutes.

**Data Collection:**

* Executes `timedatectl show-timesync --all` to obtain the current synchronization status
* Parses the NTP message to extract the stratum of the NTP server; the stratum reported is the one of this host, one more than that of the server
* systemd-timesyncd does not report the offset of the system clock. Use the `ntp-offset` check for it.
* Displays the full timedatectl output including configured NTP servers, server name and address, root distance, poll intervals, NTP message details, and frequency


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/ntp-systemd-timesyncd> |
| Nagios/Icinga Check Name              | `check_ntp_systemd_timesyncd` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |


## Help

```text
usage: ntp-systemd-timesyncd [-h] [-V] [--always-ok] [--critical-age CRIT_AGE]
                             [--no-perfdata] [--stratum STRATUM]
                             [--timeout TIMEOUT] [--warning-age WARN_AGE]

Checks which NTP server systemd-timesyncd synchronizes with, the stratum of
this host and how long ago it last synchronized. Alerts when no NTP server is
used or answers, when the stratum is too high, or when the time since the last
synchronization exceeds the configured thresholds.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --critical-age CRIT_AGE
                        CRIT threshold for the time since systemd-timesyncd
                        last synchronized the clock. A duration such as `30m`,
                        `2h` or `1D`; `0D` disables it. Default: 0D
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
  --warning-age WARN_AGE
                        WARN threshold for the time since systemd-timesyncd
                        last synchronized the clock. A duration such as `30m`,
                        `2h` or `1D`; `0D` disables it. Default: 1h

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/ntp-systemd-timesyncd/
```


## Usage Examples

```bash
./ntp-systemd-timesyncd --warning-age=1h --stratum=6
```

Output:

```text
Synchronized with NTP server ntp1.example.com (192.0.2.115), Stratum is 3, last synchronized 5m ago

LinkNTPServers=
SystemNTPServers=ntp1.example.com ntp2.example.com ntp3.example.com ntp4.example.com
FallbackNTPServers=ntp5.example.com ntp6.example.com ntp7.example.com
ServerName=ntp1.example.com
ServerAddress=192.0.2.115
RootDistanceMaxUSec=5s
PollIntervalMinUSec=32s
PollIntervalMaxUSec=34min 8s
PollIntervalUSec=32s
NTPMessage={ Leap=0, Version=4, Mode=4, Stratum=2, Precision=-25, RootDelay=1.388ms, RootDispersion=1.510ms, Reference=559E1B1F, OriginateTimestamp=Sun 2022-08-07 09:32:10 UTC, ReceiveTimestamp=Sun 2022-08-07 09:32:08 UTC, TransmitTimestamp=Sun 2022-08-07 09:32:08 UTC, DestinationTimestamp=Sun 2022-08-07 09:32:10 UTC, Ignored=no PacketCount=1, Jitter=0 }
Frequency=0
```


## States

* OK if an NTP server is in use and the stratum and the time since the last synchronization are within their thresholds.
* WARN if stratum is >= `--stratum` (default: 6).
* WARN if no NTP server is used.
* WARN if the NTP server does not answer.
* WARN if systemd-timesyncd is not installed or masked.
* WARN if `timedatectl show-timesync --all` fails or does not return within `--timeout`.
* WARN if systemd-timesyncd last synchronized longer than `--warning-age` ago (default: 1h).
* CRIT if systemd-timesyncd last synchronized longer than `--critical-age` ago (default: not checked).
* UNKNOWN on invalid parameters.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| stratum | Number | Stratum of this host, one more than that of the NTP server. |
| sync_age | Seconds | Time since systemd-timesyncd last synchronized with the NTP server. |


## Troubleshooting

### systemd-timesyncd is not installed or masked

`` systemd-timesyncd is not available on this host (`timedatectl show-timesync --all` failed with exit <code>: <error>). ``

`timedatectl` could not reach systemd-timesyncd. A stopped service is started on demand, so it is either not installed (minimal Debian installations come without it, and the Red Hat family keeps time with chronyd) or masked. The raw error in parentheses depends on the systemd version, for example `Failed to parse bus message: No route to host` or `File exists` (masked). Install and enable `systemd-timesyncd`, or, on a host that keeps its time with chronyd, use the `ntp-chronyd` check instead.

### `No NTP server used.`

systemd-timesyncd is running but has no NTP server to use. Check `NTP=` and `FallbackNTP=` in `/etc/systemd/timesyncd.conf` and name resolution.

### NTP server does not answer

`No answer from NTP server <name> (<address>). Check that outgoing NTP traffic (UDP port 123) is allowed.`

systemd-timesyncd has resolved an NTP server but has not received an answer from it. Check that outgoing NTP traffic (UDP port 123) is allowed.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
