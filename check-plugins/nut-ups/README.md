# Check nut-ups


## Overview

Monitors an Uninterruptible Power Supply (UPS) managed by [Network UPS Tools](https://networkupstools.org) (NUT). Talks to the upsd daemon over TCP and reports battery charge, remaining runtime, load, input/output voltage, real power, temperature and the aggregated `ups.status` flags.

The NUT daemon abstracts the underlying connection to the UPS (USB, serial, SNMP, ...). The plugin therefore works for any UPS that NUT supports without needing to know the wire protocol of the UPS itself. Optional NUT authentication via `--username` and `--password` for setups that protect their upsd. The status-flag mapping reserves CRIT for situations that warrant an immediate human reaction (battery on the verge of empty, forced shutdown); everything else is WARN. See "States" below.

Highlights:

* Threshold defaults are taken from the UPS or NUT admin configuration (`battery.charge.warning`/`battery.charge.low`/`battery.runtime.low`), so admins do not have to retype values the UPS already knows. Explicit CLI thresholds always override.
* Auto-discovery via `LIST UPS`: without `--device` the plugin uses the only configured UPS, or the first one on a multi-UPS host (with a hint that lists the others). The typical single-UPS setup needs no parameters at all.
* The identification block (device name, manufacturer, model, serial, firmware, battery date, USB vendor/product ID, connection type) and the `--lengthy` table together cover what `upsc` would otherwise give you on the side.
* Every numeric NUT variable is emitted as performance data automatically. When a future NUT release adds vendor-specific telemetry, it appears in your visualisation tool without the plugin needing changes.
* Status flags are rendered as "Label (CODE)" pairs (`Online (OL)`, `On Battery, Low Battery (OB+LB)`), so admins see both the friendly description and the raw NUT flag for cross-referencing with `upsc`.

**Important Notes:**

* The plugin requires a running NUT `upsd` daemon. See <https://networkupstools.org/docs/user-manual.chunked/index.html> for setup. The plugin itself never touches the UPS; it only talks to `upsd` via TCP.
* The default `--hostname 127.0.0.1` assumes the upsd is on the same host. For remote upsd, set `--hostname` and ensure `upsd.conf` has a matching `LISTEN <ip> 3493` line and a firewall rule.
* `LIST VAR` requires no NUT authentication on a default upsd configuration. Authentication is only relevant for setups that have configured `upsd.users` and want to gate read access.

**Data Collection:**

* Opens a single TCP connection to upsd, optionally authenticates (`USERNAME` then `PASSWORD`), runs `LIST VAR <device>` and `LOGOUT`, parses the `VAR <device> <name> "<value>"` lines into a dict, and closes the connection.
* The string from `ups.status` is split into individual flags. The combination `OB LB` (on battery and low) and the flag `FSD` (forced shutdown) raise CRIT; everything else stays at OK or WARN per the table in "States".
* Battery charge, runtime, load and temperature are evaluated against per-metric thresholds. Voltage and real power feed performance data only; voltage anomalies are already covered by the `OVER`, `TRIM`, `BOOST` and `OB` flags.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/nut-ups> |
| Nagios/Icinga Check Name              | `check_nut_ups` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Requirements                          | A running NUT `upsd` daemon, reachable on TCP 3493 from the host that runs the plugin. |


## Help

```text
usage: nut-ups [-h] [-V] [--always-ok] [--critical-charge CRITICAL_CHARGE]
               [--critical-load CRITICAL_LOAD]
               [--critical-runtime CRITICAL_RUNTIME]
               [--critical-temperature CRITICAL_TEMPERATURE] [--device DEVICE]
               [-H HOSTNAME] [--lengthy] [--password PASSWORD] [--port PORT]
               [--test TEST] [--timeout TIMEOUT] [--username USERNAME]
               [--warning-charge WARNING_CHARGE] [--warning-load WARNING_LOAD]
               [--warning-runtime WARNING_RUNTIME]
               [--warning-temperature WARNING_TEMPERATURE]

Monitors an Uninterruptible Power Supply (UPS) managed by Network UPS Tools
(NUT, https://networkupstools.org). Talks to the upsd daemon over TCP and
reports battery charge, runtime, load, input/output voltage, real power and
temperature, plus the aggregated ups.status flags. Alerts when the UPS goes on
battery, when the battery runs low, when the UPS signals a forced shutdown,
when the load is above threshold, when battery temperature is above threshold,
or when battery charge or runtime drop below threshold. The NUT daemon
abstracts the underlying connection to the UPS (USB, serial, SNMP), so the
same plugin works for any UPS that NUT supports. Without --device the plugin
queries upsd and picks the only configured UPS; on a multi-UPS host it picks
the first entry and surfaces the choice in the plugin output. Optional NUT
authentication via --username and --password. Supports extended reporting via
--lengthy.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --critical-charge CRITICAL_CHARGE
                        CRIT threshold for battery charge in percent. When
                        omitted, the plugin prefers the UPS-reported
                        `battery.charge.low` (which is the level at which the
                        UPS itself triggers the LB flag). Falls back to '10:'
                        if neither the UPS nor the admin configured a value.
                        Supports Nagios ranges.
  --critical-load CRITICAL_LOAD
                        CRIT threshold for UPS load in percent. Supports
                        Nagios ranges. Default: ~:95
  --critical-runtime CRITICAL_RUNTIME
                        CRIT threshold for remaining battery runtime in
                        seconds. When omitted, the plugin prefers the UPS-
                        reported `battery.runtime.low` (which is the runtime
                        at which the UPS itself triggers the LB flag). Falls
                        back to '300:' if neither the UPS nor the admin
                        configured a value. Supports Nagios ranges.
  --critical-temperature CRITICAL_TEMPERATURE
                        CRIT threshold for UPS temperature in degrees Celsius.
                        Supports Nagios ranges. Default: ~:60
  --device DEVICE       UPS device name as configured in NUT (matches the
                        [section] in ups.conf). If omitted, the plugin queries
                        upsd for the configured UPS list and picks the first
                        entry, which is the right thing to do on the typical
                        single-UPS setup. On hosts with more than one
                        configured UPS the picked name is mentioned in the
                        plugin output so the admin notices and can pin the
                        choice via --device.
  -H, --hostname HOSTNAME
                        Hostname or IP address. Default: 127.0.0.1
  --lengthy             Extended reporting.
  --password PASSWORD   Password.
  --port PORT           Port number. Default: 3493
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --username USERNAME   Username.
  --warning-charge WARNING_CHARGE
                        WARN threshold for battery charge in percent. When
                        omitted, the plugin prefers the UPS-reported
                        `battery.charge.warning`. Falls back to '30:' if
                        neither the UPS nor the admin configured a value.
                        Supports Nagios ranges.
  --warning-load WARNING_LOAD
                        WARN threshold for UPS load in percent. Supports
                        Nagios ranges. Default: ~:80
  --warning-runtime WARNING_RUNTIME
                        WARN threshold for remaining battery runtime in
                        seconds. Supports Nagios ranges. Default: 600:
  --warning-temperature WARNING_TEMPERATURE
                        WARN threshold for UPS temperature in degrees Celsius.
                        Supports Nagios ranges. Default: ~:50
```


## Usage Examples

Local upsd, default thresholds, auto-selected device (the typical single-UPS case):

```bash
./nut-ups
```

Output (default, OK):

```text
Everything is ok. Device `apc-ups`: Online (OL), charge 100%, runtime left 2h 46m, battery 26.3V, American Power Conversion Smart-UPS_1500 (S/N AS0000000000, firmware UPS 02.0 / ID=1060, via USB 051d:0003)
```

Multi-UPS host. The first configured UPS is selected and the others are surfaced as a hint:

```text
Everything is ok. Device `primary`: Online (OL), charge 100%, runtime left 2h 47m, ...
Other configured UPS on this upsd: secondary. Use --device to pin the choice.
```

UPS on battery (WARN):

```text
Device `apc-ups`: On Battery (OB), Discharging (DISCHRG), charge 60%, load 50%, runtime left 15m, battery 24.8V, ...
```

UPS on battery and low (CRIT, the 2-AM wakeup):

```text
Device `apc-ups`: On Battery, Low Battery (OB+LB), Discharging (DISCHRG), charge 8% [CRITICAL], runtime left 1m [CRITICAL], battery 22.1V, ...
```

Remote upsd with authentication, extended output:

```bash
./nut-ups --device apc-ups --hostname ups.example.com --username monitor \
    --password s3cret --lengthy
```

The `--lengthy` table lists every NUT variable from the `LIST VAR` response with its original dotted name (so you can map each row 1:1 to `upsc <device>`); the State column is filled for the threshold-aware metrics.


## States

The state aggregation has two sources: the `ups.status` flags reported by the UPS, and the per-metric thresholds.

`ups.status` flag mapping. Severity is per individual flag; CRIT is reserved for situations that require an immediate human reaction (i.e. the UPS is about to drop the protected load):

| Flag      | State | Meaning |
|-----------|-------|---------|
| `OL`      | OK    | Online (running on utility power). |
| `CHRG`    | OK    | Charging the battery. |
| `CAL`     | OK    | Calibrating the battery (informational). |
| `BOOST`   | OK    | Boosting incoming voltage to compensate for under-voltage. |
| `TRIM`    | OK    | Trimming incoming voltage to compensate for over-voltage. |
| `OB`      | WARN  | On battery (utility power lost). |
| `LB`      | WARN  | Low battery alone. |
| `HB`      | WARN  | High battery (rare; usually a sensor offset). |
| `RB`      | WARN  | Replace battery. |
| `DISCHRG` | WARN  | Discharging the battery. |
| `BYPASS`  | WARN  | Bypass active (the protected load runs straight off utility, no battery protection). |
| `OVER`    | WARN  | Overload. |
| `OFF`     | WARN  | UPS is offline (administrative state, not a fault). |
| `ALARM`   | WARN  | Vendor-specific alarm condition. |
| `FSD`     | CRIT  | Forced Shutdown signalled to clients. |
| `OB`+`LB` | CRIT  | On battery **and** low battery: utility power is gone and the battery is almost empty. The protected load is about to drop. |

Per-metric threshold mapping (Nagios ranges, see [THRESHOLDS.md](../../THRESHOLDS.md)):

| Metric | WARN default | CRIT default | Direction |
|--------|--------------|--------------|-----------|
| `--warning-charge` / `--critical-charge`           | `30:` | `10:`  | WARN if below 30 %, CRIT if below 10 %. |
| `--warning-load` / `--critical-load`               | `~:80` | `~:95` | WARN if above 80 %, CRIT if above 95 %. |
| `--warning-runtime` / `--critical-runtime`         | `600:` | `300:` | WARN if below 10 min, CRIT if below 5 min. |
| `--warning-temperature` / `--critical-temperature` | `~:50` | `~:60` | WARN if above 50 °C, CRIT if above 60 °C. NUT has no per-UPS temperature threshold variable, so the plugin defaults are used. |

The overall plugin state is the worst of all flag-driven and threshold-driven states. `--always-ok` suppresses all alerts and always returns OK.

UNKNOWN cases:

* The configured `--device` is not known to upsd (`ERR UNKNOWN-UPS`).
* `upsd` is unreachable, refuses the connection, or times out within `--timeout` seconds.
* Authentication fails (`ERR ACCESS-DENIED` after `USERNAME`/`PASSWORD`).
* `upsd` reports `ERR DATA-STALE` (the driver lost contact with the UPS hardware).


## Perfdata / Metrics

Every numeric NUT variable is emitted as performance data. NUT's dotted names (`battery.charge`, `ups.delay.shutdown`, ...) are sanitised to snake_case (`battery_charge`, `ups_delay_shutdown`) so the labels follow the Linuxfabrik perfdata convention. Variables only appear when the UPS actually reports them - cheap home UPSes ship voltage and charge only, rack-grade APC/Eaton devices ship the full electrical telemetry plus configuration thresholds.

The named entries below are the threshold-aware metrics that drive the plugin state and are guaranteed to appear when the UPS reports the underlying NUT variable. Anything else NUT exposes (`battery.runtime.elapsed`, `input.transfer.high`, `ups.delay.shutdown`, vendor-specific extensions, ...) shows up automatically alongside.

| Name                 | Type       | Description |
|----------------------|------------|-------------|
| `charge`             | Percentage | Battery charge in %. Threshold-aware (`--warning-charge` / `--critical-charge`, default from UPS `battery.charge.warning` / `battery.charge.low`). |
| `load`               | Percentage | UPS load (`active load / nominal capacity * 100`). Threshold-aware (`--warning-load` / `--critical-load`). |
| `runtime`            | Seconds    | Remaining battery runtime estimated by the UPS, in seconds. NUT calls this `battery.runtime`; it is the firmware's prediction of how long the battery would carry the load if utility power was lost right now, *not* the UPS uptime. The estimate fluctuates as load and calibration change. Threshold-aware (`--warning-runtime` / `--critical-runtime`, default from UPS `battery.runtime.low`). |
| `temperature`        | Number     | UPS temperature in degrees Celsius. Threshold-aware (`--warning-temperature` / `--critical-temperature`). The plugin reads `ups.temperature` and falls back to `battery.temperature`. NUT specifies all temperature variables as "degrees C" (drivers convert their native reading), so no Fahrenheit handling is needed. |


## For Maintainers

The plugin ships ready-to-use Containerfiles for every supported distribution under [`unit-test/containerfiles/`](unit-test/containerfiles/) (`archlinux-vlatest`, `debian-v11/v12/v13`, `fedora-v43`, `rhel-v8/v9/v10`, `sles-v15/v16`, `ubuntu-v2004/v2204/v2404/v2604`). Each one installs `nut-server` with a dummy UPS profile, exposes upsd on TCP 3493 and configures an `admin` user with the password `linuxfabrik` for testing the auth path.

Quick smoke test against one image, from the repository root:

```bash
podman build \
    --tag lfmp-nut-ups-fedora-v43 \
    --file check-plugins/nut-ups/unit-test/containerfiles/fedora-v43 \
    check-plugins/nut-ups/unit-test
podman run \
    --detach --rm \
    --name lfmp-nut-ups-test \
    --publish 3493:3493 \
    lfmp-nut-ups-fedora-v43
sleep 3
check-plugins/nut-ups/nut-ups --device dummy
check-plugins/nut-ups/nut-ups --device dummy --username admin --password linuxfabrik --lengthy
podman stop lfmp-nut-ups-test
```

To simulate a different UPS state, edit the `ups.status` value (or any other variable) in the Containerfile's `dummy.dev` block and rebuild. For example `ups.status: OB DISCHRG` exercises the on-battery WARN path and `ups.status: OB LB` exercises the CRIT combination.

The full cross-distro matrix is exercised in one go by `python tools/run-unit-tests --only-container nut-ups`.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
