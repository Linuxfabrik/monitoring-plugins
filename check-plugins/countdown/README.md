# Check countdown


## Overview

Counts down to one or more user-defined expiration dates, such as certificate renewals, contract deadlines, or license expirations. Alerts when the remaining days fall below the configured warning or critical thresholds. Each item can have its own thresholds. Past dates are reported as expired.

**Important Notes:**

* Each `--input` item uses the format `"Display Name, YYYY-MM-DD, warn, crit"` where `warn` and `crit` are days before expiration
* Setting `crit` to `None` means CRIT is never returned for that item
* Setting `warn` to `None` means WARN is never returned for that item
* Already expired dates are always reported with their respective threshold state

**Data Collection:**

* No external data is collected; all information is provided via the `--input` parameter
* Compares each expiration date against the current date and calculates the remaining days


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/countdown> |
| Nagios/Icinga Check Name              | `check_countdown` |
| Check Interval Recommendation         | Every 12 hours |
| Can be called without parameters      | No (`--input` is required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |


## Help

```text
usage: countdown [-h] [-V] [--always-ok] --input INPUT

Counts down to one or more user-defined expiration dates, such as certificate
renewals, contract deadlines, or license expirations. Alerts when the
remaining days fall below the configured warning or critical thresholds. Each
item can have its own thresholds. Past dates are reported as expired.

options:
  -h, --help     show this help message and exit
  -V, --version  show program's version number and exit
  --always-ok    Always returns OK.
  --input INPUT  Countdown item in the format "Display Name, YYYY-MM-DD, warn,
                 crit". Can be specified multiple times. Example: `--input
                 "Supermicro SYS1, 2025-01-10, 50, 30"`.
```


## Usage Examples

```bash
./countdown --input='Supermicro X11 (SerNo ABCD), 2023-12-31, 60, None' --input 'Allianz Insurance, 2024-12-31, 120, 30'
```

Output:

```text
There are one or more criticals.
* Supermicro X11 (SerNo ABCD) expired 344 days ago [WARNING]
* Allianz Insurance expires in 22 days (thresholds 120/30) [CRITICAL]
```


## States

* OK if all items have more remaining days than their respective warning thresholds.
* WARN if an item's remaining days are below its `warn` threshold.
* CRIT if an item's remaining days are below its `crit` threshold (unless `crit` is set to `None`).
* UNKNOWN if the `--input` format or timestamps are invalid.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
