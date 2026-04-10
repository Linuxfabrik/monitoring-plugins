# Check ping

## Overview

Sends ICMP ECHO_REQUEST packets to a network host using the system's built-in `ping` command. Reports round-trip time (min, avg, max, mdev) and packet loss percentage. Without any parameters, it sends five packets with a 0.2 second interval and exits after five seconds timeout at the latest.

**Data Collection:**

* Executes the system `ping` command with quiet output (`-q`) to collect summary statistics
* Works with both IPv4 and IPv6

**Important Notes:**

* This check is designed to be as tolerant as possible. It only reports CRIT when the host is definitively unreachable (0 received packets). Even with high packet loss, a single returned packet is sufficient to report OK.
* The `--always-ok` parameter is useful for hosts that do not allow ICMP but can still execute check-plugins. The packet loss will be reported, but the state will be OK.

**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/ping> |
| Nagios/Icinga Check Name              | `check_ping` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
usage: ping [-h] [-V] [--always-ok] [--count COUNT] [-H HOSTNAME]
            [--interval INTERVAL] [-t DEADLINE]

Sends ICMP ECHO_REQUEST packets to a network host using the system's built-in
ping command. Reports round-trip time (min, avg, max) and packet loss
percentage. Alerts on packet loss or high latency.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --count COUNT         Number of ECHO_REQUEST packets to send. Default: 5
  -H, --hostname HOSTNAME
                        Hostname or IP address to ping. Default: 127.0.0.1
  --interval INTERVAL   Interval between sending each packet, in seconds.
                        Accepts real numbers with dot as decimal separator
                        (regardless of locale). Default: 0.2
  -t, --timeout DEADLINE
                        Timeout in seconds before ping exits regardless of how
                        many packets have been sent or received. Default: 5
```


## Usage Examples

```bash
./ping --hostname localhost
./ping --interval=0.2 --count=5 --timeout=5 --hostname localhost
```

Output:

```text
PING 192.0.2.10: 10 packets transmitted, 5 received, 50% packet loss, time 187ms. rtt min/avg/max/mdev = 105.659/105.990/106.333/0.225 ms, pipe 6
```


## States

* OK if at least one packet is received.
* CRIT if 0 packets are received (destination host unreachable).
* UNKNOWN if name or service is unknown, out of memory, or other ping errors.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| checksum_corrupted | Number | Packets with corrupted checksum. |
| duplicates | Number | Duplicate packets. Not included in the packet loss calculation, but their round trip time is used for min/avg/max/mdev. |
| errors | Number | Packets with errors. |
| packet_loss | Percentage | Packet loss, in percent. |
| received | Number | Received packets. |
| rtt_avg | Milliseconds | Average round trip time. |
| rtt_max | Milliseconds | Maximum round trip time. |
| rtt_mdev | Milliseconds | Population standard deviation (mdev). An average of how far each ping RTT is from the mean RTT. The higher mdev is, the more variable the RTT is over time. |
| rtt_min | Milliseconds | Minimum round trip time. |
| time | Milliseconds | Total time for the ping run. |
| transmitted | Number | Transmitted packets. |


## Troubleshooting

From `man ping` and related to this check:

```text
When using ping for fault isolation, it should first be run on the
local host, to verify that the local network interface is up and
running. Then, hosts and gateways further and further away should be
"pinged". Round-trip times and packet loss statistics are computed. If
duplicate packets are received, they are not included in the packet
loss calculation, although the round trip time of these packets is used
in calculating the minimum/average/maximum/mdev round-trip time
numbers.

Population standard deviation (mdev), essentially an average of how far
each ping RTT is from the mean RTT. The higher mdev is, the more
variable the RTT is (over time). With a high RTT variability, you will
have speed issues with bulk transfers (they will take longer than is
strictly speaking necessary, as the variability will eventually cause
the sender to wait for ACKs) and you will have middling to poor VoIP
quality.
```


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
