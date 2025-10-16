# Check ntp-ntpd

## Overview

This plugin checks the clock offset of ntpd in milliseconds compared to ntp servers. It also prints

* `remote`: address of the remote peer
* `refid`: reference ID (0.0.0.0 if this is unknown)
* `st`: stratum of the remote peer
* `t`: type of the peer (local, unicast, multicast or broadcast)
* `when`: when the last packet was received
* `poll`: polling interval in seconds
* `reach`: reachability register in octal
* `delay`: estimated delay
* `offset`: estimated offset
* `jitter`: dispersion of the peer

`ntpd` is deprecated on RHEL 8+.

The stratum of the NTP time source determines its quality. The stratum is equal to the number of hops to a reference clock (which is stratum 0). A NTP server connected directly to the reference clock is Stratum 1, a client connected to this NTP server is Stratum 2, etc.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/ntp-ntpd> |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
usage: ntp-ntpd [-h] [-V] [-c CRIT] [--stratum STRATUM] [--test TEST]
                [-w WARN]

This plugin checks the clock offset of ntpd in milliseconds compared to ntp
servers.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  -c, --critical CRIT  Set the critical threshold for the ntp time offset, in
                       ms. Default: 86400000ms
  --stratum STRATUM    Warns if the determined stratum of the time server is
                       greater than or equal to this value. Stratum 1
                       indicates a computer with a locally attached reference
                       clock. A computer that is synchronised to a stratum 1
                       computer is at stratum 2. A computer that is
                       synchronised to a stratum 2 computer is at stratum 3,
                       and so on. Default: 6
  --test TEST          For unit tests. Needs "path-to-stdout-file,path-to-
                       stderr-file,expected-retc".
  -w, --warning WARN   Set the warning threshold for the ntp time offset, in
                       ms. Default: 800ms
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

* WARN or CRIT if ntp offset is below or above a given threshold.
* WARN if stratum is \>= `--stratum`.
* WARN if no NTP server is used.
* WARN if no NTP server is found.
* WARN if only LOCAL clock is used.


## Perfdata / Metrics

| Name    | Type         | Description       |
|---------|--------------|-------------------|
| delay   | Milliseconds | Delay in ms       |
| jitter  | Milliseconds | Jitter in ms      |
| offset  | Milliseconds | Time offset in ms |
| stratum | Number       | Stratum           |


## Troubleshooting

OS Error "2 No such file or directory" calling command "ntpq -p"  
You don't have `ntpd`.

ntpq: read: Connection refused  
`ntpd` is not running.

No NTP server used.  
This message occurs when ntpd is running, and ntpd does (currently) not use any ntp server.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
