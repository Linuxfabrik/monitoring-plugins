# Check deb-versionlock


## Overview

Reports the packages that APT holds back at their installed version. A hold set to work around a broken update and then forgotten keeps a host on an unpatched version for good, while the update check stays green because APT no longer offers the update. Alerts as soon as one hold is in place; raise `--warning` to tolerate a number of deliberate holds, or filter the ones you keep on purpose with `--ignore`. Optionally also reports the packages pinned in the APT preferences via `--check-pinning`. Supports extended reporting via `--lengthy`.

**Important Notes:**

* Debian-based distributions (Debian, Ubuntu, etc.)
* `--match` and `--ignore` filter on the package name, not on the version the package is held at
* A package that is held but no longer installed is reported with the version `not installed`. The hold survives the removal and applies again as soon as the package comes back.
* A held package of a foreign architecture is reported the way APT names it, with the architecture qualifier attached (`libgcc-s1:i386`). `--match` and `--ignore` see that name as well.
* `--check-pinning` is off by default because a pin is also used legitimately to give a repository like backports a priority of its own. A stanza with `Package: *` sets such a repository-wide priority and is never reported, since it holds no individual package.

**Data Collection:**

* Runs `apt-mark showhold` for the held packages
* Runs `dpkg-query` for those packages to report the version each hold pins the host to
* `--check-pinning` additionally reads the pin stanzas from `/etc/apt/preferences` and `/etc/apt/preferences.d/*`, restricted to the files APT itself reads there: extension `.pref` or none, no leading dot. A `.dpkg-old` or `.bak` copy left behind by an upgrade pins nothing and is not reported.

Neither command needs root, and neither touches the network or refreshes the package cache.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/deb-versionlock> |
| Nagios/Icinga Check Name              | `check_deb_versionlock` |
| Check Interval Recommendation         | Every hour |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |
| Requirements                          | `apt-mark` and `dpkg-query`, both shipped with the distribution |


## Help

```text
usage: deb-versionlock [-h] [-V] [--always-ok] [--check-pinning] [-c CRIT]
                       [--ignore IGNORE] [--lengthy] [--match MATCH]
                       [--no-match-severity {ok,warn,crit,unknown}]
                       [--no-perfdata] [--timeout TIMEOUT] [-w WARN]

Reports the packages that APT holds back at their installed version. A hold
set to work around a broken update and then forgotten keeps a host on an
unpatched version for good, while the update check stays green because APT no
longer offers the update. Alerts as soon as one hold is in place; raise
--warning to tolerate a number of deliberate holds, or filter the ones you
keep on purpose with --ignore. Optionally also reports the packages pinned in
the APT preferences via --check-pinning. Supports extended reporting via
--lengthy.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --check-pinning       Additionally report the packages pinned in the APT
                        preferences. A pin keeps a package at a version just
                        as effectively as a hold, but it is also used
                        legitimately to give a repository like backports a
                        priority of its own, which is why it is not reported
                        by default.
  -c, --critical CRIT   CRIT threshold for the number of held packages.
                        Supports Nagios ranges. Default: None
  --ignore IGNORE       Any item matching this Python regex will be ignored.
                        Can be specified multiple times. Example:
                        `(?i)linuxfabrik` for a case-insensitive match.
  --lengthy             Extended reporting.
  --match MATCH         Filter by this Python regular expression. Case-
                        sensitive by default; use `(?i)` for case-insensitive
                        matching. Can be specified multiple times. Examples:
                        `(?i)example` to match "example" regardless of case.
                        `^(?!.*example).*$` to match any string except
                        "example" (negative lookahead).
  --no-match-severity {ok,warn,crit,unknown}
                        State to report when no item matches the filters and
                        nothing is checked. Default: ok
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  -w, --warning WARN    WARN threshold for the number of held packages.
                        Supports Nagios ranges. Default: 0

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/deb-versionlock/
```


## Usage Examples

```bash
./deb-versionlock --lengthy
```

Output:

```text
2 held packages. [WARNING]

Package   ! Held at ! Type ! Configured in
----------+---------+------+--------------
bash      ! 5.0-4   ! hold ! apt-mark
coreutils ! 8.30-3  ! hold ! apt-mark
```

Tolerate the hold the host is meant to have, and alert on anything on top of it:

```bash
./deb-versionlock --ignore='^linux-image' --warning=1
```

Also report what the APT preferences pin:

```bash
./deb-versionlock --check-pinning --lengthy
```

Output:

```text
3 held packages. [WARNING]

Package   ! Held at                      ! Type ! Configured in
----------+------------------------------+------+--------------------------------
bash      ! 5.0-4                        ! hold ! apt-mark
coreutils ! 8.30-3                       ! hold ! apt-mark
nginx     ! version 1.24.* priority 1001 ! pin  ! /etc/apt/preferences.d/99-nginx
```


## States

* OK if nothing is held back, or if the number of holds is within `--warning`.
* WARN or CRIT depending on how the number of holds compares to `--warning` and `--critical`, which take [Nagios range expressions](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/THRESHOLDS.md). The default `--warning=0` alerts on the first hold.
* OK if `--match` and `--ignore` leave nothing to check, unless `--no-match-severity` says otherwise.
* WARN if APT cannot be asked for its held packages, which means the check is deployed on a host that does not install its packages with APT, or that its APT installation is damaged.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| holds | Number | Number of held packages after `--match` and `--ignore` were applied. |


## Troubleshooting

### A hold is reported that nobody set

Holds are dpkg selections, so they also come from configuration management and from an `apt-mark hold` inside a maintainer script. List them and see what the package is:

```bash
apt-mark showhold
dpkg --get-selections | grep hold
```

Release a hold with `apt-mark unhold <package>`.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
