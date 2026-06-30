# Check network-errors

## Overview

Monitors network interface errors per interface and alerts on receive and transmit errors. On Linux it additionally shows the receive and transmit error breakdown (the FIFO, frame and carrier error groups); on Windows only the receive and transmit error totals are available. Each counter is reported as a per-second rate measured between two check runs, so the values reflect the current situation rather than totals accumulated since boot. Alerts when the combined error rate (receive plus transmit errors) of an interface leaves the warning or critical range (default: warns on any new errors).

This is the error companion to [network-io](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/network-io/): `network-io` tracks throughput (bytes and packets per second), while `network-errors` tracks the counters that indicate a faulty link or a misbehaving NIC.

Packet drops and collisions are intentionally not monitored. Per the [Linux kernel statistics documentation](https://docs.kernel.org/networking/statistics.html), `rx_dropped` / `tx_dropped` count packets that could not be processed "due to lack of resources or unsupported protocol", and `collisions` are "not categorized as errors" but appear as a separate counter (collisions are expected on half-duplex links). Neither indicates a faulty interface on its own, so this error-focused check does not collect them. Throughput, packet rates, errors and drops as raw counters are available from [network-io](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/network-io/).

On a healthy host this check is boring on purpose: it normally reports nothing but `0` rates, which is exactly what you want to see. The zeros are mainly there for graphing, so a rising error rate stands out immediately on the dashboard. As long as the values stay at zero, everything is ok.

The receive and transmit error types are not symmetric, because the underlying hardware errors are direction-specific and the data source exposes exactly that. Generic errors and FIFO over/underruns occur in both directions, frame errors (an aggregate of length, overrun, CRC and frame-alignment errors) only happen while receiving, and carrier errors (an aggregate of carrier, aborted, window and heartbeat errors) only happen while transmitting. The set of counters also differs by platform: Linux exposes the full breakdown from `/proc/net/dev`, whereas Windows only exposes the receive and transmit error totals. The exact counters and their official definitions are listed per platform under [Perfdata / Metrics](#perfdata--metrics).

**Important Notes:**

* On the first run, returns "Waiting for more data." until at least two measurements are available.
* After a system reboot, counter values may be lower than the previous measurement. The check detects this (negative delta) and returns "Waiting for more data." until the next valid measurement pair.
* By default all interfaces are checked. Use `--match` to restrict the check to specific interfaces and `--ignore` to exclude some; both match the interface name with a Python regular expression.
* The alert value is `rx_errs + tx_errs`. The FIFO, frame and carrier columns are breakdown counters shown for diagnosis only and are never summed into the alert (so they do not add up to the `Errors/s` total). For transmit, the kernel guarantees these are already part of `tx_errs`; for receive, the frame errors are part of `rx_errs`, while `rx_fifo` may or may not be, depending on the driver. Either way the alert stays correct, because the breakdown is never added on top.

**Data Collection:**

* On Linux, reads `/proc/net/dev` and monitors the receive counters `errs`, `fifo`, `frame` and the transmit counters `errs`, `fifo`, `carrier`.
* On Windows, uses `psutil.net_io_counters()` for the receive and transmit error totals.
* Interfaces can be selected with `--match` and excluded with `--ignore` (both Python regular expressions on the interface name).
* Uses SQLite state persistence between runs to calculate deltas (errors per second).


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/network-errors> |
| Nagios/Icinga Check Name              | `check_network_errors` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform (error types broken down on Linux via `/proc/net/dev`; receive/transmit error totals on Windows via `psutil`) |
| Compiled for Windows                  | Yes |
| 3rd Party Python modules              | `psutil` (Windows only) |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-network-errors.db` |


## Help

```text
usage: network-errors [-h] [-V] [--always-ok] [-c CRIT] [--ignore IGNORE]
                      [--match MATCH]
                      [--no-match-severity {ok,warn,crit,unknown}] [-w WARN]

Monitors network interface errors per interface and alerts on receive and
transmit errors. On Linux it additionally shows the receive and transmit error
breakdown (the FIFO, frame and carrier error groups); on Windows only the
receive and transmit error totals are available. Each counter is reported as a
per-second rate measured between two check runs, so the values reflect the
current situation rather than totals accumulated since boot. Alerts when the
combined error rate (receive plus transmit errors) of an interface leaves the
warning or critical range (default: warns on any new errors).

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRIT   CRIT threshold for the combined per-second error rate
                        of an interface. Supports Nagios ranges. Default: no
                        critical threshold
  --ignore IGNORE       Ignore items whose name matches this Python regular
                        expression. Case-sensitive by default; use `(?i)` for
                        case-insensitive matching. Can be specified multiple
                        times.
  --match MATCH         Only check items whose name matches this Python
                        regular expression. Case-sensitive by default; use
                        `(?i)` for case-insensitive matching. Can be specified
                        multiple times.
  --no-match-severity {ok,warn,crit,unknown}
                        State to report when no item matches the filters and
                        nothing is checked. Default: ok
  -w, --warning WARN    WARN threshold for the combined per-second error rate
                        of an interface. Supports Nagios ranges. Default: 0
```


## Usage Examples

```bash
./network-errors --warning=0 --critical=100
```

Output (first run):

```text
Waiting for more data.
```

Output (subsequent runs, healthy host):

```text
Everything is ok.

Interface ! Rx Errs/s ! Rx Fifo/s ! Rx Frame/s ! Tx Carrier/s ! Tx Errs/s ! Tx Fifo/s ! Errors/s
----------+-----------+-----------+------------+--------------+-----------+-----------+---------
eth0      ! 0.0       ! 0.0       ! 0.0        ! 0.0          ! 0.0       ! 0.0       ! 0.0
```

Output when an interface accumulates errors (`Errors/s` is `rx_errs + tx_errs`; the FIFO/frame/carrier columns are a breakdown and are not added on top):

```text
eth0: 9.0 errors/s [WARNING]

Interface ! Rx Errs/s ! Rx Fifo/s ! Rx Frame/s ! Tx Carrier/s ! Tx Errs/s ! Tx Fifo/s ! Errors/s
----------+-----------+-----------+------------+--------------+-----------+-----------+--------------
eth0      ! 5.0       ! 1.0       ! 3.0        ! 2.0          ! 4.0       ! 1.0       ! 9.0 [WARNING]
```


## States

* OK if the combined per-second error rate (`rx_errs + tx_errs`) of every interface is within the warning range.
* OK with "Waiting for more data." on the first run or after a reboot.
* WARN if the combined per-second error rate of an interface leaves the `--warning` range (default: `0`, meaning any new error triggers a warning).
* CRIT if the combined per-second error rate of an interface leaves the `--critical` range (default: no critical threshold).
* UNKNOWN on missing Python modules (Windows), invalid `--match` or `--ignore` patterns, an unreadable `/proc/net/dev`, or invalid command-line arguments.
* `--no-match-severity` sets the state reported when the filters match no interface and nothing is checked (default: `ok`); set it to `warn`, `crit`, or `unknown` to alert on an empty selection (for example a filter typo or a missing interface) instead of silently returning OK.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

All values are per-second rates, calculated as the delta between two consecutive check runs. The available counters and their meaning differ by platform, because Linux and Windows expose interface errors through different data sources. The aggregate `<interface>_errors_per_second` (`rx_errs + tx_errs`) is emitted on both platforms and is the value compared against the thresholds.

### Linux

Read from `/proc/net/dev`; descriptions taken from the [Linux kernel networking statistics documentation](https://docs.kernel.org/networking/statistics.html).

| Name | Type | Description |
|----|----|----|
| `<interface>_rx_errs_per_second` | Number | Receive errors per second. The kernel total of bad packets received (`rx_errors`). |
| `<interface>_rx_fifo_per_second` | Number | Receiver FIFO overruns per second (`rx_fifo_errors`). Shown for diagnosis; whether it is also part of `rx_errs` is driver-dependent. |
| `<interface>_rx_frame_per_second` | Number | Receive frame errors per second. The kernel's aggregate `frame` column: length, overrun, CRC and frame-alignment errors. Part of `rx_errs`. |
| `<interface>_tx_errs_per_second` | Number | Transmit errors per second. The kernel total of transmit problems (`tx_errors`); includes the carrier and FIFO error groups. |
| `<interface>_tx_carrier_per_second` | Number | Transmit carrier errors per second. The kernel's aggregate `carrier` column: carrier, aborted, window and heartbeat errors (typically a link or cable problem). |
| `<interface>_tx_fifo_per_second` | Number | Transmit FIFO underrun/underflow errors per second (`tx_fifo_errors`). |

### Windows

Read via [`psutil.net_io_counters()`](https://psutil.readthedocs.io/en/latest/#psutil.net_io_counters) (`errin` / `errout`), which on Windows maps to the `InErrors` / `OutErrors` members of the [`MIB_IF_ROW2`](https://learn.microsoft.com/en-us/windows/win32/api/netioapi/ns-netioapi-mib_if_row2) interface structure. Windows does not expose the FIFO, frame and carrier breakdown, so only the totals are available.

| Name | Type | Description |
|----|----|----|
| `<interface>_rx_errs_per_second` | Number | Receive errors per second. `psutil` `errin`; per Microsoft, `MIB_IF_ROW2.InErrors`: "the number of incoming packets that were discarded because of errors". |
| `<interface>_tx_errs_per_second` | Number | Transmit errors per second. `psutil` `errout`; per Microsoft, `MIB_IF_ROW2.OutErrors`: "the number of outgoing packets that were discarded because of errors". |

## Troubleshooting

### Errors keep climbing on a physical interface

A non-zero and growing `tx_carrier` or `rx_frame` rate usually points at a hardware or cabling fault rather than at load.

1. Check the link with `ethtool <interface>` for duplex mismatches and link flaps.
2. Inspect the cable, the transceiver/SFP and the switch port; carrier losses are typically physical.
3. Compare against the switch-side counters to confirm where the errors originate.
4. Persistent `rx_fifo`/`tx_fifo` overruns indicate the NIC cannot keep up; check the interrupt affinity and ring buffer sizes (`ethtool -g <interface>`).

### `Waiting for more data.`

This is expected on the first run and after a reboot. The check needs at least two measurements to calculate a delta. Wait for the next check interval.

### `Python module "psutil" is not installed.`

Only relevant on Windows. Install `psutil`: `pip install psutil`. On Linux the check reads `/proc/net/dev` directly and needs no third-party module.

### Invalid `--match` or `--ignore` regular expression

A pattern passed via `--match` or `--ignore` is not a valid Python regular expression; the plugin reports that it `contains one or more errors`. Check the syntax at <https://docs.python.org/3/library/re.html>.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
