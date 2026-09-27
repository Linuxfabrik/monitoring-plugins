# Check tuned-profile


## Overview

Verifies that the current `tuned` profile matches the expected setting. Alerts when the profile in force is not the expected one, when no profile is active, or when the tuned daemon is not running and the profile is therefore not applied. Useful for ensuring consistent performance tuning across a fleet of servers.

**Important Notes:**

* A post-loaded profile (`/etc/tuned/post_loaded_profile`) is part of what tuned reports as the active profile. `--profile` matches with and without it, so `--profile=virtual-guest` and `--profile="virtual-guest intel-sst"` both accept `virtual-guest` with the post-loaded `intel-sst`.

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

Verifies that the current tuned profile matches the expected setting. Alerts
when the profile in force is not the expected one, when no profile is active,
or when the tuned daemon is not running and the profile is therefore not
applied. Useful for ensuring consistent performance tuning across a fleet of
servers.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --profile TUNED_PROFILE
                        Expected tuned profile name (case-insensitive).
                        Example: `--profile virtual-guest`. Default: virtual-
                        guest

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/tuned-profile/
```


## Usage Examples

```bash
./tuned-profile --profile="virtual-guest kernel-settings"
```

Output:

```text
tuned profile is "virtual-guest kernel-settings" (as expected).
```

Output (mismatch):

```text
tuned profile is "throughput-performance", but supposed to be "virtual-guest".
```

Output (tuned stopped):

```text
tuned is not running, so the profile "virtual-guest" is not applied. Start it with `systemctl enable --now tuned`.
```


## States

* OK if the tuned profile matches the expected value.
* WARN if the tuned profile does not match the expected value.
* WARN if no tuned profile is active.
* WARN if the tuned daemon is not running, so its preset profile is not applied.
* UNKNOWN if `tuned-adm` cannot be run.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
