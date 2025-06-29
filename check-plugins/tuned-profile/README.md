# Check tuned-profile

## Overview

Checks the current tuned profile against a desired one, and returns a warning on a non-match. If `--profile` is ommited, we suppose tuned expects the `virtual-guest` profile.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/tuned-profile> |
| Check Interval Recommendation         | Every 15 minutes |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
usage: tuned-profile [-h] [-V] [--always-ok] [--profile TUNED_PROFILE]

Checks the current tuned profile against a desired one, and returns a warning
on a non-match.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --profile TUNED_PROFILE
                        The expected tuned profile (full name), for example
                        "virtual-guest" (case-insensitive). Default: virtual-
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


## States

* WARN if tuned profile is not as expected.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
