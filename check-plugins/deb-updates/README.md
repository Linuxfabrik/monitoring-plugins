# Check deb-updates


## Overview

Checks for available APT package updates on Debian, Ubuntu, and compatible systems. Reports the number of pending updates and how many of them come from a security repository. Alerts when the number of pending updates reaches the warning threshold, and when the number of security updates reaches the critical threshold. This check only lists updates and never actually installs anything. Requires root or sudo.

**Important Notes:**

* Debian 11+, Ubuntu 20+, and other apt-based distributions
* By default the plugin refreshes the package cache first, so the user running it must have sudo permissions with NOPASSWD for the exact command `apt-get update --quiet 2`. With `--no-update` the check evaluates the cache as it is and needs no elevated permissions at all, which suits hosts where a timer already keeps the cache fresh
* The plugin stores all relevant information in a local SQLite database that lives only for the duration of the run. For the `--query` parameter, the following database columns are available:
    * `critical` (INT): `1` if the update matches `--critical-pattern`, `0` otherwise
    * `package` (TEXT)
* As the output interface of the `apt` tool is not stable, the database table has been kept deliberately simple
* The check reports the packages that carry a newer candidate version. Packages that a distribution upgrade would additionally pull in, a kernel ABI bump for example, are not installed yet and therefore do not appear

Example content of the `package` column:

```text
base-files/stable 12.4+deb12u11 amd64 [upgradable from: 12.4+deb12u5]
bash/stable 5.2.15-2+b8 amd64 [upgradable from: 5.2.15-2+b2]
bind9-dnsutils/stable,stable-security 1:9.18.33-1~deb12u2 amd64 [upgradable from: 1:9.18.19-1~deb12u1]
```

**Data Collection:**

* Runs `sudo apt-get update --quiet 2` to refresh the package cache, unless `--no-update` is given
* Runs `apt list --upgradable` to determine available updates
* Stores the results in a local SQLite database for flexible querying via `--query`
* Classifies an update as security-critical when it matches `--critical-pattern`, which by default keys on the suite an update is offered from. This covers a package offered by the security archive alone (`aom-tools/stable-security`), which is what a fresh CVE fix looks like before the next point release folds it into the main suite, as well as one offered by both (`gzip/noble-updates,noble-security`)
* Optionally narrows the report down to those updates (`--only-critical`); the security count is reported either way


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/deb-updates> |
| Nagios/Icinga Check Name              | `check_deb_updates` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |
| Requirements                          | User with sudo permissions, unless `--no-update` is used |


## Help

```text
usage: deb-updates [-h] [-V] [--always-ok] [-c CRIT]
                   [--critical-pattern CRITICAL_PATTERN] [--no-perfdata]
                   [--no-update] [--only-critical] [--query QUERY]
                   [--timeout TIMEOUT] [-w WARN]

Checks for available APT package updates on Debian, Ubuntu, and compatible
systems. Reports the number of pending updates and how many of them come from
a security repository. Alerts when the number of pending updates reaches the
warning threshold, and when the number of security updates reaches the
critical threshold. This check only lists updates and never actually installs
anything. Requires root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRIT   Minimum number of pending security updates to trigger
                        a CRITICAL. Counts the updates matching `--critical-
                        pattern`, within the scope of `--query`. Unset by
                        default, so security updates raise a WARNING like any
                        other update until a threshold is given. Example:
                        `--critical=1` Default: None
  --critical-pattern CRITICAL_PATTERN
                        Marks an update as security-critical. Matched against
                        the whole line as printed by `apt list --upgradable`,
                        so it can key on the package name, the suite, or the
                        version. Uses Python regular expressions. Case-
                        sensitive. Example: `--critical-
                        pattern='^\S+/\S*(-security|-lts)'` Default:
                        ^\S+/\S*-security
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --no-update           Skip the package cache refresh and evaluate the cache
                        as it is. Without this, the check runs `apt-get
                        update` first, which needs sudo and reaches the
                        package repositories on every run. Use it on hosts
                        where a timer already keeps the cache fresh.
  --only-critical       Only report security-critical updates and upgrades.
  --query QUERY         SQL WHERE clause to narrow down results from the
                        internal updates table. Supports regular expressions
                        via a REGEXP statement. If specified, a list of
                        matching updates is printed. Have a look at the README
                        for a list of available columns. Example:
                        `--query='package like "bind9-%"'`. Default: 1
  --timeout TIMEOUT     Network timeout in seconds. Default: 60 (seconds)
  -w, --warning WARN    Minimum number of pending updates to trigger a
                        WARNING. Default: 1

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/deb-updates/
```


## Usage Examples

```bash
./deb-updates
```

Output:

```text
17 updates available, 15 of them critical. [WARNING]
* aom-tools/stable-security 3.12.1-1+deb13u1 amd64 [upgradable from: 3.12.1-1]
* base-files/stable 13.8+deb13u6 amd64 [upgradable from: 13.8+deb13u5]
* bind9-doc/stable-security 1:9.20.26-1~deb13u1 all [upgradable from: 1:9.20.23-1~deb13u1]
```

Wake somebody up as soon as a security update is pending, and refresh the package cache from the check:

```bash
./deb-updates --critical=1
```

Output:

```text
17 updates available, 15 of them critical. [CRITICAL]
```

Report only the security updates of a single package family, against the cache a timer already keeps fresh:

```bash
./deb-updates --no-update --only-critical --query='package like "bind9-%"'
```

Output:

```text
3 critical updates available (query: package like "bind9-%"). [WARNING]
* bind9-doc/stable-security 1:9.20.26-1~deb13u1 all [upgradable from: 1:9.20.23-1~deb13u1]
* bind9-libs/stable-security 1:9.20.26-1~deb13u1 amd64 [upgradable from: 1:9.20.23-1~deb13u1]
* bind9-utils/stable-security 1:9.20.26-1~deb13u1 amd64 [upgradable from: 1:9.20.23-1~deb13u1]
```


## States

* OK if no updates are available (or both counts stay below their thresholds).
* WARN if the number of pending updates is >= `--warning` (default: 1).
* CRIT if the number of security updates is >= `--critical`. Unset by default, so security updates raise a WARNING like any other update until a threshold is given.
* UNKNOWN if `apt-get update` or `apt list --upgradable` fails, or if `--critical-pattern` is not a valid regular expression.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| critical_updates | Number | Number of security updates matching the current `--query`. |
| updates | Number | Number of updatable packages matching the current `--query`. With `--only-critical` this is the security count. |


## Troubleshooting

### `apt-get update returned with an error.`

The plugin runs `sudo apt-get update` and requires a working sudoers configuration. The package installs `/etc/sudoers.d/linuxfabrik-monitoring-plugins` automatically. If this file is missing, restore it:

```bash
apt install --reinstall -o Dpkg::Options::="--force-confmiss" linuxfabrik-monitoring-plugins
```

If the file exists but the error persists, verify that the monitoring user (typically `icinga` or `nagios`) can run `sudo apt-get update` without a password prompt:

```bash
su icinga -s /bin/bash -c "sudo apt-get update --quiet 2"
```

Two checks refreshing the cache at the same moment lock each other out, and the one that loses the race reports this error. Where the cache is kept fresh by a timer anyway, run the check with `--no-update`; it then needs neither sudo nor the network.

### A pending security update is not counted as critical

`--critical-pattern` decides what counts, and by default it keys on the suite an update is offered from, as printed by `apt list --upgradable`. A third-party repository whose suite is not named `*-security` therefore does not register. Look at the line the plugin prints for the package and write a pattern that matches it, for example:

```bash
./deb-updates --critical-pattern='^\S+/\S*(-security|-lts)'
```


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
