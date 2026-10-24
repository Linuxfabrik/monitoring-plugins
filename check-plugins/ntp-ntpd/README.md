# Check ntp-ntpd


## Overview

Checks how far the system clock is off from the NTP server ntpd synchronizes to, in milliseconds, and how long ago ntpd last synchronized it, for ntp and NTPsec. Alerts when the offset or the time since the last synchronization exceeds the configured thresholds, when the stratum is too high, when too few NTP sources are usable, or when ntpd uses no NTP server, including when it only uses its local clock.

**Important Notes:**

* `ntpd` is deprecated on RHEL 8+. Consider using `chronyd` instead.
* The stratum of the NTP time source determines its quality. The stratum is equal to the number of hops to a reference clock (stratum 0). A NTP server connected directly to the reference clock is Stratum 1, a client connected to this NTP server is Stratum 2, etc.

**Data Collection:**

* Executes `ntpq --numeric --peers` to obtain the current synchronization status
* Parses the system peer (marked with `*`, or with `o` if ntpd disciplines the clock with a PPS signal) and extracts stratum, delay, offset, and jitter. The stratum reported is the one of this host, one more than that of the system peer, as ntpd itself counts it.
* Works with both ntp and NTPsec
* Displays the full `ntpq --numeric --peers` output for reference
* The time since the last synchronization is the time since ntpd last heard from its system peer ("when" in `ntpq --peers`). It shows a system peer that went silent, which ntpd keeps as system peer for a while. The check warns after an hour by default (`--warning-age`).
* `--warning-sources` and `--critical-sources` warn when few NTP sources are usable, for example `--warning-sources=2:` before the last one fails. Usable are the system peer, candidates and backups.
* The offset is the one ntpd measured to its system peer, the NTP server it synchronizes to. The `ntp-offset` check measures against one NTP server of its own choice with a single query, so its value differs slightly, by up to half its round-trip delay.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/ntp-ntpd> |
| Nagios/Icinga Check Name              | `check_ntp_ntpd` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |


## Help

```text
usage: ntp-ntpd [-h] [-V] [--always-ok] [-c CRIT] [--critical-age CRIT_AGE]
                [--critical-sources CRIT_SOURCES] [--no-perfdata]
                [--stratum STRATUM] [--timeout TIMEOUT] [-w WARN]
                [--warning-age WARN_AGE] [--warning-sources WARN_SOURCES]

Checks how far the system clock is off from the NTP server ntpd synchronizes
to, in milliseconds, and how long ago ntpd last synchronized it, for ntp and
NTPsec. Alerts when the offset or the time since the last synchronization
exceeds the configured thresholds, when the stratum is too high, when too few
NTP sources are usable, or when ntpd uses no NTP server, including when it
only uses its local clock.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRIT   CRIT threshold for the offset of the system clock,
                        fast or slow, in milliseconds. Supports Nagios ranges.
                        Default: 60000
  --critical-age CRIT_AGE
                        CRIT threshold for the time since ntpd last
                        synchronized the clock. A duration such as `30m`, `2h`
                        or `1D`; `0D` disables it. Default: 0D
  --critical-sources CRIT_SOURCES
                        CRIT threshold for the number of usable NTP sources.
                        Supports Nagios ranges. Example: `--critical-
                        sources=1:` alerts if no source is usable.
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
                        WARN threshold for the time since ntpd last
                        synchronized the clock. A duration such as `30m`, `2h`
                        or `1D`; `0D` disables it. Default: 1h
  --warning-sources WARN_SOURCES
                        WARN threshold for the number of usable NTP sources.
                        Supports Nagios ranges. Example: `--warning-
                        sources=2:` warns if fewer than two sources are
                        usable, so a single remaining one does not go
                        unnoticed.

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/ntp-ntpd/
```


## Usage Examples

```bash
./ntp-ntpd --warning=300 --critical=60000 --stratum=6
```

Output:

```text
System clock is 1.231ms fast compared to the NTP server ntpd synchronizes to (192.0.2.12), Stratum is 2, last synchronized 1s ago, 4 usable sources

     remote           refid      st t when poll reach   delay   offset   jitter
===============================================================================
 pool.example.co .POOL.          16 p    -  256    0   0.0000   0.0000   0.0000
+ntp1.example.co .DTS.            1 u    1   16    1  40.9363  -1.3031   6.0536
+ntp2.example.co 198.51.100.188   2 u    1   16    1  45.0695   2.9765   5.8408
*192.0.2.12      .PTPs.           1 u    1   16    1  37.2066  -1.2311   8.0047
+ntp3.example.co 198.51.100.61    2 u    1   16    1  39.3613   0.5564   6.5445
 ntp4.example.co .INIT.          16 u    -   16    0   0.0000   0.0000   0.0000
 ntp5.example.co .INIT.          16 u    -   16    0   0.0000   0.0000   0.0000
 ntp6.example.co .INIT.          16 u    -   16    0   0.0000   0.0000   0.0000
 2001:db8::2     .INIT.          16 u    -   16    0   0.0000   0.0000   0.0000
```


## States

* OK if the offset, the stratum and the time since the last synchronization are within their thresholds.
* WARN if the offset, fast or slow, exceeds `--warning` (default: 300ms).
* WARN if stratum is >= `--stratum` (default: 6).
* WARN if no NTP server is used.
* WARN if ntpd uses its undisciplined local clock (`LOCAL(0)`) instead of an NTP server.
* WARN if `ntpq --numeric --peers` fails or does not return within `--timeout`, for example because ntpd is not running.
* WARN if ntpd last synchronized the clock longer than `--warning-age` ago (default: 1h).
* WARN if the number of usable NTP sources is outside `--warning-sources` (default: not checked).
* CRIT if the offset, fast or slow, exceeds `--critical` (default: 60000ms).
* CRIT if ntpd last synchronized the clock longer than `--critical-age` ago (default: not checked).
* CRIT if the number of usable NTP sources is outside `--critical-sources` (default: not checked).
* UNKNOWN on invalid parameters.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| delay | Milliseconds | Round-trip delay to the system peer. |
| jitter | Milliseconds | Jitter of the system peer. |
| offset | Milliseconds | Offset of the system clock from the system peer. Positive if the system clock is slow, as in RFC 5905. |
| stratum | Number | Stratum of this host, one more than that of the system peer. |
| sync_age | Seconds | Time since ntpd last synchronized the clock, that is, last heard from its system peer. |
| usable_sources | Number | NTP sources ntpd uses or keeps as candidates or backups. |


## Troubleshooting

### ntpq is not installed

`` `ntpq --numeric --peers` failed: Command "ntpq" not found (No such file or directory). ``

Install ntp or NTPsec, which bring `ntpq` along, or monitor the time service this host actually runs, for example with `ntp-chronyd`.

### ntpd is not running

`` `ntpq --numeric --peers` failed (exit 0): ntpq: read: Connection refused ``

`ntpd` is not running. NTPsec reports this as `***Socket error; probably ntpd is not running`. Start it and enable it at boot with `sudo systemctl enable --now ntpd` (on Debian and Ubuntu, the service is called `ntpsec` or `ntp`), then look at `sudo journalctl --unit=ntpd` if it does not stay up.

### `NTP server not reachable. ntpd uses its local clock (LOCAL(0)) instead.`

No NTP server is usable, and ntpd synchronizes to its own clock because of a `server 127.127.1.0` line in its configuration. Clients of this host get time that drifts freely. Check name resolution and that outgoing NTP traffic (UDP port 123) is allowed.

### `No NTP server used.`

ntpd is running, but no NTP server qualifies as its system peer, for example shortly after a start or when every server is unreachable. `ntpq --numeric --peers` lists the configured servers and why they are not selected (the first column). Check the `server` and `pool` lines in the ntpd configuration, name resolution, and that outgoing NTP traffic (UDP port 123) is allowed.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
