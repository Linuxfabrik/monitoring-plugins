# Check "ping" - Overview

Sends ICMP ECHO_REQUEST to network hosts using the built-in `ping` command. Without any parameters it tries to send five packets within one second (so its fast!) and exits after five seconds timeout at the latest. It doesn't care about round trip times or packet loss as long the host is still reachable in some way. That means 90% packet loss is ok, while 100% are not. Why? If this check is used to test the host-liveliness (which in 99.9% is its use case), mostly all other service checks depend on its result. For that reason it should be as tolerant and reliable as possible and only throw CRIT (equal to DOWN) if the host is definitely not reachable at all.

`check_ping` from `nagios-plugins` just prints `PING OK - Packet loss = 0%, RTA = 3.79 ms`, while this check tells you everything that you are used to if using the `ping` command directly: `PING localhost(localhost (::1)): 5 packets transmitted, 5 received, time 828ms. rtt min/avg/max/mdev = 0.029/0.113/0.189/0.052 ms`.

This command works with both IPv4 and IPv6.


# Installation and Usage

Requirements:
* `ping`

```bash
./ping --hostname www.linuxfabrik.ch 
./ping --help
```


# States

* CRIT if sending ICMP ECHO_REQUEST to network host fails
* UNKNOWN if name or service is unknown, out of memory, etc.
* Otherwise OK


# Perfdata

* transmitted packets
* received packets
* duplicate packets
* checksum_corrupted packets
* errors
* packet_loss (%)
* time (ms)
* rtt_min (ms)
* rtt_avg (ms)
* rtt_max (ms)
* rtt_mdev (ms)


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.