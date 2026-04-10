# Check ntp-ntpd

## Overview

Checks the clock offset of ntpd in milliseconds compared to the configured NTP servers. Alerts when the offset exceeds the configured thresholds.

**Important Notes:**

* `ntpd` is deprecated on RHEL 8+. Consider using `chronyd` instead.
* The stratum of the NTP time source determines its quality. The stratum is equal to the number of hops to a reference clock (stratum 0). A NTP server connected directly to the reference clock is Stratum 1, a client connected to this NTP server is Stratum 2, etc.



**Data Collection:**

* Executes `ntpq -p` to obtain the current synchronization status
* Parses the active peer (marked with `*`) and extracts stratum, delay, offset, and jitter
* Displays the full `ntpq -p` output for reference

**Compatibility:**

* Cross-platform



## Fact Sheet

| Fact | Value |
|----|----| 
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/ntp-ntpd> |
| Nagios/Icinga Check Name              | `check_ntp_ntpd` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
usage: ntp-ntpd [-h] [-V] [-c CRIT] [--stratum STRATUM] [--test TEST]
                [-w WARN]

Checks the clock offset of ntpd in milliseconds compared to the configured NTP
servers. Alerts when the offset exceeds the configured thresholds.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  -c, --critical CRIT  CRIT threshold for the NTP time offset, in
                       milliseconds. Default: 86400000ms
  --stratum STRATUM    Warns if the determined stratum of the time server is
                       greater than or equal to this value. Stratum 1
                       indicates a computer with a locally attached reference
                       clock. A computer that is synchronised to a stratum 1
                       computer is at stratum 2. A computer that is
                       synchronised to a stratum 2 computer is at stratum 3,
                       and so on. Default: 6
  --test TEST          For unit tests. Needs "path-to-stdout-file,path-to-
                       stderr-file,expected-retc".
  -w, --warning WARN   WARN threshold for the NTP time offset, in
                       milliseconds. Default: 800ms
```


## Usage Examples

```bash
./ntp-ntpd --warning=500 --critical=10000 --stratum=6
```

Output:

```text
NTP offset is -3.005ms, Stratum is 2

     remote           refid      st t when poll reach   delay   offset  jitter
==============================================================================
+host234-254-110 131.188.3.221    2 u   51   64   77   77.863   -7.828  19.747
+a-na27-74.tin.i 80.20.16.52      5 u   42   64  177  107.243  -10.797 108.288
-time.cloudflare 10.19.9.88       3 u   43   64  177  262.432  -106.25  64.326
*ns3.fiberteleco 192.168.10.2     2 u   13   64  377   56.901   -3.005  33.579
```


## States

* OK if the NTP offset is within the thresholds and stratum is acceptable.
* WARN if the NTP offset is >= `--warning` (default: 800ms).
* WARN if stratum is >= `--stratum` (default: 6).
* WARN if no NTP server is used or found.
* WARN if only the LOCAL clock is used.
* CRIT if the NTP offset is >= `--critical` (default: 86400000ms).


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| delay | Milliseconds | Round-trip delay to the active NTP peer. |
| jitter | Milliseconds | Dispersion of the active NTP peer. |
| offset | Milliseconds | Time offset to the active NTP peer. |
| stratum | Number | Stratum of the active NTP peer. |


## Troubleshooting

`OS Error "2 No such file or directory" calling command "ntpq -p"`  
You don't have `ntpd` installed.

`ntpq: read: Connection refused`  
`ntpd` is not running.

`No NTP server used.`  
This message occurs when ntpd is running but does not currently use any NTP server.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
