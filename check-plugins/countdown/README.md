# Check countdown


## Overview

Counts down to one or more user-defined expiration dates, such as certificate renewals, contract deadlines, or license expirations. Alerts when the number of days left falls below the warning or critical threshold configured for that date. Every date carries its own thresholds. Past dates are reported as expired. Supports extended reporting via --lengthy.

Typical subjects are hardware support contracts, insurance policies, domain registrations, software subscriptions and any other deadline that has no API to query but still has to show up in monitoring.

**Important Notes:**

* Every `--input` describes one date, in the format `"Display Name, YYYY-MM-DD, warn, crit"`.
* The date is the anchor of that format. Everything in front of it is the display name, everything behind it are the thresholds, which is why a display name may contain commas.
* Both thresholds are a number of days left and may be omitted. Leaving both out applies the defaults, `50` for warning and `30` for critical.
* A threshold of `none` (case-insensitive) or an empty field switches that threshold off, so the check never returns that state for that date. A date with both thresholds switched off is reported but never alerts.
* A threshold given as a plain number alerts once fewer days than that are left. This is the inverse of what a bare number means in the standard Nagios range syntax, and it is deliberate: it is what every existing configuration of this check relies on. Write `50:` if you prefer to be explicit, it means exactly the same thing.
* Anything beyond a plain number is read as a [Nagios range](../THRESHOLDS.md), so `~:400` alerts on a date further out than 400 days, and `@0:10` alerts only within the last 10 days before it.
* A malformed `--input` returns UNKNOWN and names the value it could not read, so the offending date is identifiable among many.
* Every date is reported as one row of a table, in the order the `--input` parameters were given. `--lengthy` adds the configured thresholds as two further columns.
* `Left` counts down to zero on the expiration date and turns negative afterwards, so `-967` means the date passed 967 days ago.
* The shipped Icinga Director service template switches `--lengthy` on, so a service created from it shows the threshold columns out of the box.

**Data Collection:**

* No data is collected from the system or from the network. Every date is supplied on the command line via `--input` and compared against the current date.
* The comparison runs on whole calendar dates, so the result does not depend on the time of day the check runs at.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/countdown> |
| Nagios/Icinga Check Name              | `check_countdown` |
| Check Interval Recommendation         | Every 12 hours |
| Can be called without parameters      | No (`--input` is required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |


## Help

```text
usage: countdown [-h] [-V] [--always-ok] --input INPUT [--lengthy]
                 [--no-perfdata]

Counts down to one or more user-defined expiration dates, such as certificate
renewals, contract deadlines, or license expirations. Alerts when the number
of days left falls below the warning or critical threshold configured for that
date. Every date carries its own thresholds. Past dates are reported as
expired. Supports extended reporting via --lengthy.

options:
  -h, --help     show this help message and exit
  -V, --version  show program's version number and exit
  --always-ok    Always returns OK.
  --input INPUT  One date to count down to, in the format "Display Name, YYYY-
                 MM-DD, warn, crit". Both thresholds are a number of days left
                 and may be omitted; "none" switches one off, so that state is
                 never returned for that date. A plain number alerts once
                 fewer days than that are left. Supports Nagios ranges. The
                 display name may contain commas, the date field separates it
                 from the thresholds. Can be specified multiple times. Default
                 thresholds: 50/30 days. Example: `--input "Supermicro SYS1,
                 2027-01-10, 50, 30"`.
  --lengthy      Extended reporting.
  --no-perfdata  Suppress the performance data section from the output. The
                 status message and the exit code are unaffected, so alerting
                 keeps working while trending data is dropped.

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/countdown/
```


## Usage Examples

Two dates that are both far enough out:

```bash
./countdown --input='Supermicro X11 (SerNo ABCD), 2028-12-31, 60, 30' --input='Allianz Insurance, 2029-06-30, 120, 30'
```

Output:

```text
Everything is ok.

Name                        ! Expires    ! Left ! State
----------------------------+------------+------+------
Supermicro X11 (SerNo ABCD) ! 2028-12-31 ! 860  ! [OK]
Allianz Insurance           ! 2029-06-30 ! 1041 ! [OK]
```

One date already expired with CRIT switched off, one date inside its critical threshold:

```bash
./countdown --input='Supermicro X11 (SerNo ABCD), 2023-12-31, 60, None' --input='Allianz Insurance, 2026-09-15, 120, 30'
```

Output:

```text
There are one or more criticals.

Name                        ! Expires    ! Left ! State
----------------------------+------------+------+-----------
Supermicro X11 (SerNo ABCD) ! 2023-12-31 ! -967 ! [WARNING]
Allianz Insurance           ! 2026-09-15 ! 22   ! [CRITICAL]
```

The same run with `--lengthy`, which adds the configured thresholds:

```bash
./countdown --input='Supermicro X11 (SerNo ABCD), 2023-12-31, 60, None' --input='Allianz Insurance, 2026-09-15, 120, 30' --lengthy
```

Output:

```text
There are one or more criticals.

Name                        ! Expires    ! Left ! Warn ! Crit ! State
----------------------------+------------+------+------+------+-----------
Supermicro X11 (SerNo ABCD) ! 2023-12-31 ! -967 ! 60   ! none ! [WARNING]
Allianz Insurance           ! 2026-09-15 ! 22   ! 120  ! 30   ! [CRITICAL]
```

Omitting both thresholds applies the defaults:

```bash
./countdown --input='Domain example.com, 2027-03-01'
```

Output:

```text
Everything is ok.

Name               ! Expires    ! Left ! State
-------------------+------------+------+------
Domain example.com ! 2027-03-01 ! 189  ! [OK]
```

Nagios ranges, here spelled out explicitly:

```bash
./countdown --input='TLS Cert wildcard.example.com, 2026-11-01, 30:, 14:' --lengthy
```

Output:

```text
Everything is ok.

Name                          ! Expires    ! Left ! Warn ! Crit ! State
------------------------------+------------+------+------+------+------
TLS Cert wildcard.example.com ! 2026-11-01 ! 69   ! 30:  ! 14:  ! [OK]
```


## States

* OK if every date has more days left than its warning threshold, or if its thresholds are switched off.
* WARN if the days left of a date fall below its `warn` threshold, or fall outside the range given there.
* CRIT if the days left of a date fall below its `crit` threshold, or fall outside the range given there.
* A date that has passed counts as a negative number of days left, so it stays below any positive threshold and keeps alerting until it is removed or moved.
* The worst state across all dates becomes the state of the check. Every date keeps its own row in the table either way, and `--lengthy` has no influence on any state.
* UNKNOWN if an `--input` cannot be read: no date in `YYYY-MM-DD` format, no display name in front of the date, a date that does not exist such as `2027-02-30`, a threshold that is neither a number nor a valid Nagios range, or more fields behind the date than a warning and a critical threshold.
* `--always-ok` returns OK regardless. The report itself is unchanged, so the affected dates stay visible in the output.


## Perfdata / Metrics

One metric per date, named after its display name with everything outside `[A-Za-z0-9_]` replaced by an underscore. `Supermicro X11 (SerNo ABCD)` therefore reports as `supermicro_x11_serno_abcd_days_left`.

| Name | Type | Description |
|------|------|-------------|
| `<display-name>_days_left` | Number | Days left until that date. Negative once the date has passed, counting the days since. |

Two display names that differ only in characters outside `[A-Za-z0-9_]`, `Cert A` and `Cert-A` for instance, produce the same metric name. Give them distinct display names if you want to trend them apart.


## Troubleshooting

### `Found no expiration date in "..."`

The `--input` carries no field in `YYYY-MM-DD` format. Either the date is missing entirely, or it is written in another format such as `31.12.2027` or `2027/12/31`. Rewrite it as an ISO date, for example `Supermicro SYS1, 2027-01-10, 50, 30`.

### `Found no display name in front of the date in "..."`

The `--input` starts with the date. Put a display name in front of it, because that name is what identifies the date in the output and in the performance data.

### A date is not a valid date

`"2027-02-30" of "Contract" is not a valid date.`

The field has the right shape but names a day that does not exist, most often a day past the end of a short month, or a 29th of February in a year that has none.

### A threshold is rejected

`Warning threshold "sixty" of "Contract": Range format incorrect.`

A threshold has to be a number of days, the word `none`, or a Nagios range. Spelled-out numbers, a unit suffix such as `60d`, and a percent sign are all rejected. See [THRESHOLDS.md](../THRESHOLDS.md) for the range syntax.

### A date never alerts

The thresholds of that date are switched off. Run the check with `--lengthy` and read the `Warn` and `Crit` columns: `none` in both means neither state can ever be returned for it. An empty field between two commas has the same effect as `none`, so `Contract, 2027-01-01, , 30` switches off the warning threshold.

### A date alerts far too early

A plain number in this check means "alert once fewer days than this are left", not the standard Nagios reading of "alert above this value". A threshold of `400` therefore alerts on everything that is less than 400 days away. Lower the number, or state the intended range explicitly, for example `~:400` to alert on dates further out than 400 days.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
