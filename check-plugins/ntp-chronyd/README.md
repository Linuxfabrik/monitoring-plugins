# Check ntp-chronyd


## Overview

Checks how far the system clock is off from the time chronyd derives from its NTP servers, in milliseconds, and how long ago chronyd last synchronized it. Alerts when the offset or the time since the last synchronization exceeds the configured thresholds, when the stratum is too high, when too few NTP sources are usable, or when chronyd uses no NTP server, including when it only serves its local clock.

**Important Notes:**

* The check reports the current offset of the system clock from the time chronyd derives from its NTP servers ("System time" in `chronyc tracking`). The `ntp-offset` check measures against one NTP server of its own choice with a single query, so its value differs slightly, by up to half its round-trip delay. After a clock jump, for example when a virtual machine resumes, chronyd corrects the clock slowly, which can take hours for a large offset. The check keeps warning until the clock is right again, while "Last offset" and "RMS offset" already look fine; those two are only reported as performance data.
* When all NTP sources go silent, chronyd keeps reporting a synchronized clock with its last stratum and a tiny offset for a long time, because it no longer measures anything. The time since the last clock update ("Ref time" in `chronyc tracking`) reveals it; the check warns after an hour by default (`--warning-age`). chronyd normally updates the clock at least every 17 minutes.
* `--warning-sources` and `--critical-sources` warn when few NTP sources are usable, for example `--warning-sources=2:` before the last one fails. Usable are the selected source and those combined with it.
* If the chrony configuration contains a `local` line (`/etc/chrony.conf` on the Red Hat family, `/etc/chrony/chrony.conf` on Debian and Ubuntu), chronyd serves its own clock when no NTP server is reachable and reports a normal stratum and an offset of 0. The check recognizes this and warns.
* The stratum of the NTP time source determines its quality. The stratum is equal to the number of hops to a reference clock (stratum 0). A NTP server connected directly to the reference clock is Stratum 1, a client connected to this NTP server is Stratum 2, etc.

**Data Collection:**

* Executes `chronyc -n tracking` to obtain the current synchronization status
* Reports Reference ID, Stratum, Ref time, System time, Last offset, RMS offset, Frequency, Residual freq, Skew, Root delay, Root dispersion, Update interval, and Leap status
* Executes `chronyc -n sources` to count the usable NTP sources and, if no NTP server is reachable or chronyd serves its local clock, to display the configured ones


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/ntp-chronyd> |
| Nagios/Icinga Check Name              | `check_ntp_chronyd` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |


## Help

```text
usage: ntp-chronyd [-h] [-V] [--always-ok] [-c CRIT] [--critical-age CRIT_AGE]
                   [--critical-sources CRIT_SOURCES] [--no-perfdata]
                   [--stratum STRATUM] [--timeout TIMEOUT] [-w WARN]
                   [--warning-age WARN_AGE] [--warning-sources WARN_SOURCES]

Checks how far the system clock is off from the time chronyd derives from its
NTP servers, in milliseconds, and how long ago chronyd last synchronized it.
Alerts when the offset or the time since the last synchronization exceeds the
configured thresholds, when the stratum is too high, when too few NTP sources
are usable, or when chronyd uses no NTP server, including when it only serves
its local clock.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRIT   CRIT threshold for the offset of the system clock,
                        fast or slow, in milliseconds. Supports Nagios ranges.
                        Default: 60000
  --critical-age CRIT_AGE
                        CRIT threshold for the time since chronyd last
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
                        WARN threshold for the time since chronyd last
                        synchronized the clock. A duration such as `30m`, `2h`
                        or `1D`; `0D` disables it. Default: 1h
  --warning-sources WARN_SOURCES
                        WARN threshold for the number of usable NTP sources.
                        Supports Nagios ranges. Example: `--warning-
                        sources=2:` warns if fewer than two sources are
                        usable, so a single remaining one does not go
                        unnoticed.

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/ntp-chronyd/
```


## Usage Examples

```bash
./ntp-chronyd --warning=300 --critical=60000 --stratum=6
```

Output:

```text
System clock is 0.857ms slow compared to the time chronyd derives from its NTP servers (currently 192.0.2.31), Stratum is 2, Leap status is Normal, last synchronized 11m 31s ago, 1 usable source

Reference ID    : C000021F (192.0.2.31)
Stratum         : 2
Ref time (UTC)  : Fri Oct 23 19:25:59 2026
System time     : 0.000856512 seconds slow of NTP time
Last offset     : -0.000087123 seconds
RMS offset      : 0.002977934 seconds
Frequency       : 33.139 ppm fast
Residual freq   : -0.012 ppm
Skew            : 1.431 ppm
Root delay      : 0.028390646 seconds
Root dispersion : 0.004321930 seconds
Update interval : 1044.3 seconds
Leap status     : Normal
```


## States

* OK if the offset, the stratum and the time since the last synchronization are within their thresholds.
* WARN if the offset, fast or slow, exceeds `--warning` (default: 300ms).
* WARN if stratum is >= `--stratum` (default: 6).
* WARN if no NTP server is used or reachable, or chronyd serves its local clock instead.
* WARN if `chronyc -n tracking` fails or does not return within `--timeout`, for example because chronyd is not running.
* WARN if chronyd last synchronized the clock longer than `--warning-age` ago (default: 1h).
* WARN if the number of usable NTP sources is outside `--warning-sources` (default: not checked).
* CRIT if the offset, fast or slow, exceeds `--critical` (default: 60000ms).
* CRIT if chronyd last synchronized the clock longer than `--critical-age` ago (default: not checked).
* CRIT if the number of usable NTP sources is outside `--critical-sources` (default: not checked).
* UNKNOWN on invalid parameters.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| frequency | ppm | Rate by which the system clock would be wrong if chronyd was not correcting it. Positive if the clock runs fast, negative if it runs slow. |
| last_offset | Milliseconds | Estimated offset on the last clock update, relative to chronyd's NTP clock: positive if the local clock was behind, negative if it was ahead. |
| offset | Milliseconds | Current offset of the system clock from NTP time ("System time" in `chronyc tracking`), as RFC 5905 and `ntpq` define it: positive if the system clock is slow, negative if it is fast. Checked against `--warning` and `--critical`. |
| residual_freq | ppm | Residual frequency for the currently selected reference source. |
| rms_offset | Milliseconds | Long-term average of the offset value. |
| root_delay | Milliseconds | Total network path delay to the stratum-1 source. |
| root_dispersion | Milliseconds | Total dispersion accumulated through all computers back to the stratum-1 source. |
| skew | ppm | Estimated error bound on the frequency. |
| stratum | Number | Stratum of this host, as chronyd reports it. |
| sync_age | Seconds | Time since chronyd last updated the clock. |
| usable_sources | Number | NTP sources chronyd selected or combined with the selected one. |

Source of description: <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/ch-configuring_ntp_using_the_chrony_suite>


## Troubleshooting

### chronyc is not installed

`` `chronyc -n tracking` failed: Command "chronyc" not found (No such file or directory). ``

Install chrony, or monitor the time service this host actually runs, for example with `ntp-systemd-timesyncd`.

### chronyd is not running

`` `chronyc -n tracking` failed (exit 1): 506 Cannot talk to daemon ``

chronyd is not running. Start it and enable it at boot with `sudo systemctl enable --now chronyd` (on Debian and Ubuntu, the service is called `chrony`), then look at `sudo journalctl --unit=chronyd` if it does not stay up.

### `NTP server not reachable. No NTP server is used.`

chronyd is running but does not currently use any NTP server. The output lists the configured sources. Check name resolution and that outgoing NTP traffic (UDP port 123) is allowed.

### NTP server not reachable, chronyd serves its local clock

`NTP server not reachable. chronyd serves its local clock instead (local directive in the chrony configuration).`

No NTP server is usable, and chronyd falls back to its own clock because of the `local` directive in its configuration. Clients of this host get time that drifts freely. Fix the reachability of the NTP servers as above.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
