# Check systemd-timedate-status


## Overview

Checks system clock and RTC settings via `timedatectl status`, including whether network time synchronization is active and whether the system clock is synchronized.

**Data Collection:**

* Executes `timedatectl status` and parses its output
* Reports NTP synchronization status, NTP service state, and RTC configuration
* Uses `timedatectl status` (not `timedatectl show`) for compatibility with older systemd versions (e.g. RHEL 7)

**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/systemd-timedate-status> |
| Nagios/Icinga Check Name              | `check_systemd_timedate_status` |
| Check Interval Recommendation         | Once a day |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
usage: systemd-timedate-status [-h] [-V] [--always-ok] [--test TEST]

Checks system clock and RTC settings via timedatectl, including whether
network time synchronization is active and whether the system clock is
synchronized. Alerts on misconfigured time settings.

options:
  -h, --help     show this help message and exit
  -V, --version  show program's version number and exit
  --always-ok    Always returns OK.
  --test TEST    For unit tests. Needs "path-to-stdout-file,path-to-stderr-
                 file,expected-retc".
```


## Usage Examples

```bash
./systemd-timedate-status
```

Output:

```text
System clock synchronized: yes, NTP service: active, RTC in local TZ: no
```

Output (RTC misconfigured):

```text
System clock synchronized: yes. NTP service: active. The system is configured to read the RTC time in the local time zone. This mode cannot be fully supported. It will create various problems with time zone changes and daylight saving time adjustments. The RTC time is never updated, it relies on external facilities to maintain it. If at all possible, use RTC in UTC by calling `timedatectl set-local-rtc 0` [WARNING].
```


## States

* OK if NTP is synchronized and RTC is set to UTC.
* WARN if the system is configured to read the RTC time in the local time zone.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
