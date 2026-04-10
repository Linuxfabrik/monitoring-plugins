# Check ntp-chronyd


## Overview

Checks the clock offset of chronyd in milliseconds compared to the configured NTP servers. Alerts when the offset exceeds the configured thresholds.

**Important Notes:**

* The stratum of the NTP time source determines its quality. The stratum is equal to the number of hops to a reference clock (stratum 0). A NTP server connected directly to the reference clock is Stratum 1, a client connected to this NTP server is Stratum 2, etc.

**Data Collection:**

* Executes `chronyc tracking` to obtain the current synchronization status
* Reports Reference ID, Stratum, Ref time, System time, Last offset, RMS offset, Frequency, Residual freq, Skew, Root delay, Root dispersion, Update interval, and Leap status
* If no NTP server is reachable, additionally runs `chronyc sources` to display the configured NTP servers


## Fact Sheet

| Fact | Value |
|----|----| 
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/ntp-chronyd> |
| Nagios/Icinga Check Name              | `check_ntp_chronyd` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |


## Help

```text
usage: ntp-chronyd [-h] [-V] [-c CRIT] [--stratum STRATUM] [--test TEST]
                   [-w WARN]

Checks the clock offset of chronyd in milliseconds compared to the configured
NTP servers. Alerts when the offset exceeds the configured thresholds.

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
./ntp-chronyd --warning=500 --critical=10000 --stratum=6
```

Output:

```text
NTP offset is 0.698234ms, Stratum is 3, Leap status is Normal

Reference ID    : C3BA0165 (bwntp1pool.bluewin.ch)
Stratum         : 3
Ref time (UTC)  : Sun Aug 07 10:02:47 2022
System time     : 0.000254363 seconds slow of NTP time
Last offset     : +0.000698234 seconds
RMS offset      : 0.028022379 seconds
Frequency       : 23.159 ppm fast
Residual freq   : -0.032 ppm
Skew            : 6.203 ppm
Root delay      : 0.068764083 seconds
Root dispersion : 0.016749078 seconds
Update interval : 518.9 seconds
Leap status     : Normal
```

Example of an alert:

```text
NTP server not reachable. No NTP server is used.

MS Name/IP address         Stratum Poll Reach LastRx Last sample               
===============================================================================
^? ntp1.hetzner.de               0   6     0     -     +0ns[   +0ns] +/-    0ns
```


## States

* OK if the NTP offset is within the thresholds and stratum is acceptable.
* WARN if the NTP offset is >= `--warning` (default: 800ms).
* WARN if stratum is >= `--stratum` (default: 6).
* WARN if no NTP server is used or reachable.
* CRIT if the NTP offset is >= `--critical` (default: 86400000ms).


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| frequency | ppm | Rate by which the system clock would be wrong if chronyd was not correcting it. |
| last_offset | Milliseconds | Estimated local offset on the last clock update. |
| residual_freq | ppm | Residual frequency for the currently selected reference source. |
| rms_offset | Milliseconds | Long-term average of the offset value. |
| root_delay | Milliseconds | Total network path delay to the stratum-1 source. |
| root_dispersion | Milliseconds | Total dispersion accumulated through all computers back to the stratum-1 source. |
| skew | ppm | Estimated error bound on the frequency. |
| stratum | Number | Number of hops away from a computer with an attached reference clock. |

Source of description: <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/ch-configuring_ntp_using_the_chrony_suite>


## Troubleshooting

`OS Error "2 No such file or directory" calling command "chronyc tracking"`  
You don't have `chronyd` installed.

`No NTP server used.`  
This message occurs when chronyd is running but does not currently use any NTP server.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
