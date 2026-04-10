# Check crypto-policy

## Overview

Verifies that the system-wide cryptographic policy (as reported by update-crypto-policies) matches the expected setting. Returns WARN if the current policy differs from the desired one (default: "DEFAULT"). Useful for ensuring consistent TLS and cipher configurations across a fleet of servers.

**Data Collection:**

* Runs `update-crypto-policies --show` to determine the active system-wide crypto policy
* Compares the result against the expected policy name (case-insensitive)

**Compatibility:**

* RHEL/CentOS/Fedora and other distributions that ship `update-crypto-policies`


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/crypto-policy> |
| Nagios/Icinga Check Name              | `check_crypto_policy` |
| Check Interval Recommendation         | Every 15 minutes |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
usage: crypto-policy [-h] [-V] [--always-ok] [--policy CRYPTO_POLICY]

Verifies that the system-wide cryptographic policy (as reported by update-
crypto-policies) matches the expected setting. Returns WARN if the current
policy differs from the desired one (default: "DEFAULT"). Useful for ensuring
consistent TLS and cipher configurations across a fleet of servers.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --policy CRYPTO_POLICY
                        Expected crypto policy name. Case-insensitive.
                        Example: `FUTURE`. Default: DEFAULT
```


## Usage Examples

```bash
./crypto-policy --policy FUTURE
```

Output:

```text
Crypto policy is "DEFAULT" (as expected).
```


## States

* OK if the current crypto policy matches the expected one (case-insensitive).
* WARN if the current crypto policy does not match the expected one.
* UNKNOWN if `update-crypto-policies` is not available on the system.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
