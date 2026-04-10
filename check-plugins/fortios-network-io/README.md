# Check fortios-network-io


## Overview

Monitors network I/O and link states on all interfaces of FortiGate appliances running FortiOS via the REST API. Alerts only if bandwidth thresholds have been exceeded for a configurable number of consecutive check runs (default: 5), suppressing short spikes. Reports per-interface traffic counters and link status. Authentication uses a single API token (token-based authentication).

**Important Notes:**

* FortiGate appliances running FortiOS with REST API enabled
* The `--always-ok` parameter is accepted but has no effect (the plugin does not pass it to the output function)

**Data Collection:**

* Queries the FortiOS REST API endpoint `/api/v2/monitor/system/interface/select` to fetch per-interface traffic counters, link state, speed, and duplex mode
* Uses SQLite state persistence between runs to calculate bandwidth deltas and to track link state changes
* On the first run, returns "Waiting for more data." until at least two measurements are available
* `--count=5` (the default) while checking every minute means the check uses a 5-minute sliding window for threshold evaluation

**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|------|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/fortios-network-io> |
| Nagios/Icinga Check Name              | `check_fortios_network_io` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | No (`--hostname` and `--password` are required) |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-fortios-network-io.db` |


## Help

```text
usage: fortios-network-io [-h] [-V] [--always-ok] [--count COUNT] [-c CRIT]
                          -H HOSTNAME [--insecure] [--no-proxy]
                          --password PASSWORD [--timeout TIMEOUT] [-w WARN]

Monitors network I/O and link states on all interfaces of FortiGate appliances
running FortiOS via the REST API. Alerts only if bandwidth thresholds have
been exceeded for a configurable number of consecutive check runs (default:
5), suppressing short spikes. Reports per-interface traffic counters, error
rates, and link status.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --count COUNT         Number of consecutive checks the threshold must be
                        exceeded before alerting. Default: 5
  -c, --critical CRIT   CRIT threshold for link bandwidth saturation in bits
                        per second. Applied over the last `--count`
                        measurements. Default: 900000000
  -H, --hostname HOSTNAME
                        FortiOS-based appliance address, optionally including
                        port. Example: `--hostname 192.168.1.1:443`.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-proxy            Do not use a proxy.
  --password PASSWORD   FortiOS REST API single-use access token.
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -w, --warning WARN    WARN threshold for link bandwidth saturation in bits
                        per second. Applied over the last `--count`
                        measurements. Default: 800000000
```


## Usage Examples

```bash
./fortios-network-io --hostname fortigate-cluster.linuxfabrik.io --password mypass --count 5 --warning 800000000 --critical 900000000
```

Output (first run):

```text
Waiting for more data.
```

Output (subsequent runs):

```text
port8: 338.9KiB/33.4KiB bps (rx/tx, current).

interface   ! rx1bps   ! tx1bps  ! rx5bps   ! tx5bps
------------+----------+---------+----------+---------
mgmt1       ! 2.6KiB   ! 2.5KiB  ! 2.6KiB   ! 2.5KiB
modem       ! 0.0B     ! 0.0B    ! 0.0B     ! 0.0B
npu0_vlink0 ! 0.0B     ! 0.0B    ! 0.0B     ! 0.0B
npu1_vlink0 ! 0.0B     ! 0.0B    ! 0.0B     ! 0.0B
npu1_vlink1 ! 0.0B     ! 0.0B    ! 0.0B     ! 0.0B
port8       ! 338.9KiB ! 33.4KiB ! 334.0KiB ! 33.3KiB
```


## States

* OK if all interfaces are below the warning threshold and no link state changes are detected.
* OK with "Waiting for more data." on the first run or when insufficient measurements are available.
* WARN if link state, speed rate, or duplex mode for an interface changes compared to the inventorized baseline.
* WARN if rx or tx bandwidth saturation (averaged over `--count` measurements) is >= `--warning` (default: 800000000 bps).
* CRIT if rx or tx bandwidth saturation (averaged over `--count` measurements) is >= `--critical` (default: 900000000 bps).


## Perfdata / Metrics

Depends on the interfaces present on your appliance. For each interface (e.g. `port8`):

| Name | Type | Description |
|----|----|----|
| `<interface>_rx1` | Bytes | Received bytes per second since the last check run. |
| `<interface>_rxn` | Bytes | Received bytes per second averaged over the last n check runs. |
| `<interface>_tx1` | Bytes | Sent bytes per second since the last check run. |
| `<interface>_txn` | Bytes | Sent bytes per second averaged over the last n check runs. |


## Troubleshooting

`Waiting for more data.`
The check needs at least two measurements to calculate a delta. Wait for the next check interval.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
