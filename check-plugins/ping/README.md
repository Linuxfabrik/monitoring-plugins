# Check ping


## Overview

Sends ICMP ECHO_REQUEST packets to a network host using the system's built-in `ping` command. Reports round-trip time (min, avg, max, mdev) and packet loss percentage. By default it reports CRITICAL only when the host is unreachable; the optional thresholds additionally alert on latency, round-trip variability (jitter) and packet loss. Without any parameters, it sends five packets with a 0.2 second interval and exits after five seconds timeout at the latest.

**Important Notes:**

* This check is tolerant by default: without any threshold it reports CRIT only when the host is definitively unreachable (0 received packets), so even high packet loss stays OK as long as a single packet returns. Set the optional `--rta-*`, `--rtt-mdev-*` or `--packet-loss-*` thresholds to additionally alert on latency, jitter or packet loss.
* The `--always-ok` parameter is useful for hosts that do not allow ICMP but can still execute check-plugins. The packet loss will be reported, but the state will be OK.

**Data Collection:**

* Executes the system `ping` command with quiet, numeric output (`-q -n`) to collect summary statistics
* Works with both IPv4 and IPv6


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/ping> |
| Nagios/Icinga Check Name              | `check_ping` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |


## Help

```text
usage: ping [-h] [-V] [--always-ok] [--count COUNT] [-H HOSTNAME]
            [--interface INTERFACE] [--interval INTERVAL] [--ipv4] [--ipv6]
            [--no-perfdata] [--packet-loss-critical PACKET_LOSS_CRIT]
            [--packet-loss-warning PACKET_LOSS_WARN]
            [--packet-size PACKET_SIZE] [--rta-critical RTA_CRIT]
            [--rta-warning RTA_WARN] [--rtt-mdev-critical RTT_MDEV_CRIT]
            [--rtt-mdev-warning RTT_MDEV_WARN] [-t DEADLINE] [--ttl TTL]

Sends ICMP ECHO_REQUEST packets to a network host using the system's built-in
ping command and reports round-trip time, round-trip variability and packet
loss. By default it reports CRITICAL only when the host is unreachable (no
packet returns), so even high packet loss stays OK as long as one reply
arrives. The optional --rta-warning/--rta-critical (round-trip average),
--rtt-mdev-warning/--rtt-mdev-critical (round-trip variability, a jitter
measure) and --packet-loss-warning/--packet-loss-critical thresholds
additionally alert on latency, jitter and packet loss.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --count COUNT         Number of ECHO_REQUEST packets to send. Default: 5
  -H, --hostname HOSTNAME
                        Hostname or IP address to ping. Default: 127.0.0.1
  --interface INTERFACE
                        Interface name or source address to ping from (`ping
                        -I`). Example: `--interface eth0`.
  --interval INTERVAL   Interval between sending each packet, in seconds.
                        Accepts real numbers with dot as decimal separator
                        (regardless of locale). Default: 0.2
  --ipv4                Force IPv4.
  --ipv6                Use IPv6.
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --packet-loss-critical PACKET_LOSS_CRIT
                        CRIT threshold for the packet loss, in percent.
                        Supports Nagios ranges. Disabled by default.
  --packet-loss-warning PACKET_LOSS_WARN
                        WARN threshold for the packet loss, in percent.
                        Supports Nagios ranges. Disabled by default.
  --packet-size PACKET_SIZE
                        Number of data bytes to send (`ping -s`), excluding
                        the 8-byte ICMP header. Example: `--packet-size 1472`.
  --rta-critical RTA_CRIT
                        CRIT threshold for the round-trip average, in
                        milliseconds. Supports Nagios ranges. Disabled by
                        default.
  --rta-warning RTA_WARN
                        WARN threshold for the round-trip average, in
                        milliseconds. Supports Nagios ranges. Disabled by
                        default.
  --rtt-mdev-critical RTT_MDEV_CRIT
                        CRIT threshold for the round-trip variability (mdev, a
                        jitter measure), in milliseconds. Supports Nagios
                        ranges. Disabled by default.
  --rtt-mdev-warning RTT_MDEV_WARN
                        WARN threshold for the round-trip variability (mdev, a
                        jitter measure), in milliseconds. Supports Nagios
                        ranges. Disabled by default.
  -t, --timeout DEADLINE
                        Timeout in seconds before ping exits regardless of how
                        many packets have been sent or received. Default: 5
  --ttl TTL             IP Time To Live for the outgoing packets (`ping -t`).
                        Example: `--ttl 64`.

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/ping/
```


## Usage Examples

```bash
./ping --hostname=localhost
./ping --interval=0.2 --count=5 --timeout=5 --hostname=localhost
```

Output:

```text
PING 192.0.2.10: 10 packets transmitted, 5 received, 50% packet loss, time 187ms. rtt min/avg/max/mdev = 105.659/105.990/106.333/0.225 ms, pipe 6
```


## States

* OK if at least one packet is received and no threshold is exceeded.
* WARNING if the round-trip average (`--rta-warning`), the round-trip variability (`--rtt-mdev-warning`) or the packet loss (`--packet-loss-warning`) exceeds its threshold. Each threshold is opt-in and disabled by default.
* CRITICAL if 0 packets are received (destination host unreachable), or if the round-trip average (`--rta-critical`), the round-trip variability (`--rtt-mdev-critical`) or the packet loss (`--packet-loss-critical`) exceeds its threshold.
* UNKNOWN if the name or service is unknown, out of memory, or other ping errors.
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

### Isolating where packet loss or latency originates

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
```

### Interpreting RTT variability (mdev)

From `man ping` and related to this check:

```text
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
