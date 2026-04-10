# Check ntp-systemd-timesyncd

## Overview

Checks the state of systemd-timesyncd, including synchronization status, server reachability, and stratum level. Alerts if time synchronization is inactive or if the stratum exceeds the configured limit.

**Data Collection:**

* Executes `timedatectl show-timesync --all` to obtain the current synchronization status
* Parses the NTP message to extract the stratum value
* Displays the full timedatectl output including configured NTP servers, server name and address, root distance, poll intervals, NTP message details, and frequency

**Compatibility:**

* Linux systems using systemd-timesyncd for time synchronization
* The stratum of the NTP time source determines its quality. The stratum is equal to the number of hops to a reference clock (stratum 0). A NTP server connected directly to the reference clock is Stratum 1, a client connected to this NTP server is Stratum 2, etc.


## Fact Sheet

| Fact | Value |
|----|----| 
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/ntp-systemd-timesyncd> |
| Nagios/Icinga Check Name              | `check_ntp_systemd_timesyncd` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
usage: ntp-systemd-timesyncd [-h] [-V] [--stratum STRATUM] [--test TEST]

Checks the state of systemd-timesyncd, including synchronization status,
server reachability, and stratum level. Alerts if time synchronization is
inactive or if the stratum exceeds the configured limit.

options:
  -h, --help         show this help message and exit
  -V, --version      show program's version number and exit
  --stratum STRATUM  Warns if the determined stratum of the time server is
                     greater than or equal to this value. Stratum 1 indicates
                     a computer with a locally attached reference clock. A
                     computer that is synchronised to a stratum 1 computer is
                     at stratum 2. A computer that is synchronised to a
                     stratum 2 computer is at stratum 3, and so on. Default: 6
  --test TEST        For unit tests. Needs "path-to-stdout-file,path-to-
                     stderr-file,expected-retc".
```


## Usage Examples

```bash
./ntp-systemd-timesyncd --stratum=6
```

Output:

```text
Stratum is 2

LinkNTPServers=
SystemNTPServers=0.arch.pool.ntp.org 1.arch.pool.ntp.org 2.arch.pool.ntp.org 3.arch.pool.ntp.org
FallbackNTPServers=0.pool.ntp.org 1.pool.ntp.org 0.fr.pool.ntp.org
ServerName=0.arch.pool.ntp.org
ServerAddress=46.22.24.205
RootDistanceMaxUSec=5s
PollIntervalMinUSec=32s
PollIntervalMaxUSec=34min 8s
PollIntervalUSec=34min 8s
NTPMessage={ Leap=0, Version=4, Mode=4, Stratum=2, Precision=-26, RootDelay=4.364ms, RootDispersion=534us, Reference=C3B01ACD, OriginateTimestamp=Sun 2022-08-07 10:09:44 UTC, ReceiveTimestamp=Sun 2022-08-07 10:09:44 UTC, TransmitTimestamp=Sun 2022-08-07 10:09:44 UTC, DestinationTimestamp=Sun 2022-08-07 10:09:44 UTC, Ignored=no PacketCount=6, Jitter=22.804ms }
Frequency=-1365573
```


## States

* OK if the stratum is below the configured limit and an NTP server is in use.
* WARN if stratum is >= `--stratum` (default: 6).
* WARN if no NTP server is used.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| stratum | Number | Stratum of the currently used NTP server. |


## Troubleshooting

`Failed to parse bus message: No such device or address`  
You don't have `systemd-timesyncd` installed or the service is not running.

`No NTP server used.`  
This message occurs when systemd-timesyncd is running but does not currently use any NTP server.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
