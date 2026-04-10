# Check tuned-profile


## Overview

Verifies that the current `tuned` profile matches the expected setting. Useful for ensuring consistent performance tuning across a fleet of servers.

**Data Collection:**

* Executes `tuned-adm active` and compares the result against the expected profile name


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/tuned-profile> |
| Nagios/Icinga Check Name              | `check_tuned_profile` |
| Check Interval Recommendation         | Every 15 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |


## Help

```text
usage: tuned-profile [-h] [-V] [--always-ok] [--profile TUNED_PROFILE]

Verifies that the current tuned profile matches the expected setting. Returns
WARN if the active profile differs from the desired one. Useful for ensuring
consistent performance tuning across a fleet of servers.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --profile TUNED_PROFILE
                        Expected tuned profile name (case-insensitive).
                        Example: `--profile virtual-guest`. Default: virtual-
                        guest
```


## Usage Examples

```bash
./tuned-profile --profile "virtual-guest kernel-settings"
```

Output:

```text
tuned profile is "virtual-guest kernel-settings" (as expected).
```

Output (mismatch):

```text
tuned profile is "throughput-performance", but supposed to be "virtual-guest".
```


## States

* OK if the tuned profile matches the expected value.
* WARN if the tuned profile does not match the expected value.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
