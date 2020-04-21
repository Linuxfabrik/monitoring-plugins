# Check "ntp-offset" - Overview

This plugin checks the clock offset in milliseconds compared to ntp servers.

If `ntpd` is used, prints
* address of the remote peer
* reference ID (0.0.0.0 if this is unknown)
* stratum of the remote peer
* type of the peer (local, unicast, multicast or broadcast)
* when the last packet was received
* polling interval in seconds
* reachability register in octal
* and the current estimated delay, offset and dispersion of the peer

If `chronyd` is used, prints
* reference id
* stratum
* ref time (utc)
* system time
* last offset
* rms offset
* frequency
* residual freq
* skew
* root delay
* root dispersion
* update interval
* leap status

We recommend to run this check every minute.


# Installation and Usage

Requirements:
* `ntpq` or `chronyc`

```bash
./ntp-offset
./ntp-offset --warning 500 --critical 1000
./ntp-offset --help
```


# States

* WARN or CRIT if ntp offset is above a given threshold.


# Perfdata

* Time Offset (Milliseconds)


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.