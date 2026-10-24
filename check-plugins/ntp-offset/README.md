# Check ntp-offset


## Overview

Checks how far the system clock is off from the time of an NTP server, in milliseconds, measured by the check itself and not taken from the local time service. By default it asks the NTP server the local time service follows. Alerts when the offset exceeds the configured thresholds, when no NTP server is found, when it does not answer, or when it is not synchronized itself.

**Important Notes:**

* This check works with every time service (chronyd, ntpd, systemd-timesyncd, W32Time) and is a second line next to the check for it (`ntp-chronyd`, `ntp-ntpd`, `ntp-systemd-timesyncd`, `ntp-w32tm`). Those report what the time service believes, this one measures the system clock itself. It notices a clock that is off even when the time service reports everything as fine.
* With the default `--hostname=auto`, the check asks the running time service which NTP server it follows and measures against that server. It runs without configuration, also where only internal NTP servers are reachable. It cannot notice an NTP server that is wrong itself, because the time service follows the same server. To catch that as well, run the check on a few hosts with `--hostname` set to an independent server, for example `ntp.metas.ch`.
* `auto` needs a running time service that uses an NTP server. A host without one, or one that follows a reference clock (GPS, PPS) or only its local clock, gets a warning asking for `--hostname`.
* The time service and this check measure against a server with different methods, so their values differ slightly. The difference is at most half the round-trip delay, typically a few milliseconds over the internet, well below the default warning threshold.
* The thresholds apply in both directions, so `--warning=300` warns if the system clock is more than 300 ms fast or slow.
* The check needs no root privileges, only outgoing NTP traffic (UDP port 123) to the server.

**Data Collection:**

* With `--hostname=auto`, asks the running time service for its NTP server: `w32tm /query /source` on Windows (an account without administrator rights may not ask W32Time and reads its configured NTP server from the registry instead), otherwise `chronyc -n sources` (the selected source, else the first configured one), `ntpq --numeric --command='rv 0 peeradr'` (the system peer) and, only if systemd-timesyncd is active, `timedatectl show-timesync --all`
* Resolves the server and sends an SNTP client request (NTP version 4, mode 3) to each address in turn until one answers, then three more to that address, one second apart. The answer with the smallest round-trip delay counts, because waiting times on one of the two network paths skew the others. Finding the server and asking it share `--timeout`; a run takes about three seconds.
* Accepts the answer only if it belongs to the request, comes from a synchronized server (stratum 1 to 15) and has a root distance of at most 1.5 seconds. A Kiss-o'-Death answer (`DENY`, `RATE`, `RSTR`) is reported as such.
* Computes offset and round-trip delay from the four timestamps as described in RFC 5905


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/ntp-offset> |
| Nagios/Icinga Check Name              | `check_ntp_offset` |
| Check Interval Recommendation         | Every 15 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | Yes |


## Help

```text
usage: ntp-offset [-h] [-V] [--always-ok] [-c CRIT] [-H HOSTNAME]
                  [--no-perfdata] [--timeout TIMEOUT] [-w WARN]

Checks how far the system clock is off from the time of an NTP server, in
milliseconds, measured by the check itself and not taken from the local time
service. By default it asks the NTP server the local time service follows.
Alerts when the offset exceeds the configured thresholds, when no NTP server
is found, when it does not answer, or when it is not synchronized itself.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRIT   CRIT threshold for the offset of the system clock,
                        fast or slow, in milliseconds. Supports Nagios ranges.
                        Default: 60000
  -H, --hostname HOSTNAME
                        NTP server to compare the system clock with. Hostname
                        or IP address. `auto` takes the NTP server the local
                        time service follows (chronyd, ntpd, systemd-
                        timesyncd, W32Time). Default: auto
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  -w, --warning WARN    WARN threshold for the offset of the system clock,
                        fast or slow, in milliseconds. Supports Nagios ranges.
                        Default: 300

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/ntp-offset/
```


## Usage Examples

```bash
./ntp-offset
```

Output:

```text
System clock is 2.57ms slow compared to NTP server 192.0.2.10 (stratum 1, used by chronyd), Delay is 22.119ms
```

Against an independent server, while chronyd slews a clock that was moved 60 seconds ahead:

```bash
./ntp-offset --hostname=ntp.example.com --warning=300 --critical=60000
```

Output:

```text
System clock is 28941.16ms fast [WARNING] compared to NTP server ntp.example.com (192.0.2.11, stratum 1), Delay is 18.186ms
```


## States

* OK if the offset of the system clock is within the thresholds.
* WARN if the offset, fast or slow, exceeds `--warning` (default: 300ms).
* WARN if `--hostname=auto` finds no NTP server, or a time service does not answer within `--timeout`.
* WARN if the server cannot be resolved or does not answer within `--timeout`.
* WARN if the server is not synchronized itself, is too far from its reference clock, refuses to answer (Kiss-o'-Death) or sends an invalid answer.
* CRIT if the offset, fast or slow, exceeds `--critical` (default: 60000ms).
* UNKNOWN if `--hostname` is not a valid host name, and on other invalid parameters.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| delay | Milliseconds | Round-trip delay to the NTP server. The offset is accurate to half of it. |
| offset | Milliseconds | Offset of the NTP server's time relative to the system clock (RFC 5905). Positive if the system clock is slow, negative if it is fast. |
| stratum | Number | Stratum of the NTP server, not of this host. |


## Troubleshooting

### No NTP server to compare with

`No NTP server to compare the system clock with: no running time service (chronyd, ntpd, systemd-timesyncd) uses one. Set --hostname to an NTP server.`

`--hostname=auto` found no NTP server: no time service is running, or it follows a reference clock or only its local clock. Start the time service of the host (`sudo systemctl enable --now chronyd`), or set `--hostname` to an NTP server. On Windows, the message names what W32Time uses instead, for example `Local CMOS Clock`; configure an NTP server there (`w32tm /config /manualpeerlist:ntp.example.com /syncfromflags:manual /update`) or set `--hostname`.

### A time service does not answer

``No NTP server to compare the system clock with: chronyd (`chronyc -n sources`) did not answer within 8s. Set --hostname to an NTP server.``

The time service hangs, so `--hostname=auto` cannot learn its NTP server. The check for the time service itself (`ntp-chronyd`, `ntp-ntpd`, `ntp-systemd-timesyncd`) reports the same problem. Restart the time service, for example with `sudo systemctl restart chronyd`, and look at its journal if it hangs again.

### No answer from the NTP server

`No answer from NTP server <hostname> (<address>) within 8s. Check that outgoing NTP traffic (UDP port 123) is allowed.`

A firewall drops the request or the answer. Allow outgoing UDP traffic to port 123 of the server, or use `--hostname` to point the check to an NTP server that is reachable from this host.

### NTP server refuses the connection

`No answer from NTP server <hostname> (<address>): Connection refused.`

The host behind the address does not run an NTP server. Use `--hostname` to point the check to an NTP server.

### The NTP server is not synchronized itself

`NTP server <hostname> (<details>): The server is not synchronized itself (reference ID INIT). Use another NTP server.`

The NTP server has no usable time source of its own, for example after a restart or because it cannot reach its upstream servers. Use another server.

### The NTP server refuses to answer

`NTP server <hostname> (<details>): The server refuses to answer (Kiss-o'-Death code RATE).`

The NTP server limits how often a client may ask. Check less often or use another server. `DENY` and `RSTR` mean that the server does not serve this host at all.

### The NTP server is too far from its reference clock

`NTP server <hostname> (<details>): The server is too far from its reference clock (root distance <n>s, more than 1.5s). Use another NTP server.`

The server reports a root distance (root delay / 2 + root dispersion) above 1.5 seconds, so its own time is uncertain by that much. Use another server.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
