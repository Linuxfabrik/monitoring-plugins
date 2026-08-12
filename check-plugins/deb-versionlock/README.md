# Check deb-versionlock


## Overview

Reports the packages that APT holds back at their installed version. A hold set to work around a broken update and then forgotten keeps a host on an unpatched version for good, while the update check stays green because APT no longer offers the update. Alerts as soon as one hold is in place; raise `--warning` to tolerate a number of deliberate holds, or filter the ones you keep on purpose with `--ignore`. Optionally also reports the packages pinned in the APT preferences via `--check-pinning`, and then alerts as well on a preferences file APT refuses, which stops the host from installing or upgrading anything. Supports extended reporting via `--lengthy`.

**Important Notes:**

* Debian-based distributions (Debian, Ubuntu, etc.)
* `--match` and `--ignore` filter on the package name, not on the version the package is held at
* A package that is held but no longer installed is reported with the version `not installed`. The hold survives the removal and applies again as soon as the package comes back.
* A held package of a foreign architecture is reported the way APT names it, with the architecture qualifier attached (`libgcc-s1:i386`). `--match` and `--ignore` see that name as well.
* `--check-pinning` is off by default because a pin is also used legitimately to give a repository like backports a priority of its own. A stanza with `Package: *` sets such an archive-wide priority and is never reported, since it holds no individual package. A clean host then reports "No holds and no pins in place.", so the summary shows that both searches ran.
* With `--check-pinning`, a preferences file APT refuses gets a line of its own and raises WARN. APT gives up on such a file at the offending stanza and then fails every command that works out package priorities, so the host cannot install or upgrade anything until it is fixed. The other files in `preferences.d` are still read, and so is the package list, which is why the holds are still reported while the pinning is broken.

**Data Collection:**

* Runs `apt-mark showhold` for the held packages
* Runs `dpkg-query` for those packages to report the version each hold pins the host to
* `--check-pinning` additionally reads the pin stanzas from `/etc/apt/preferences` and `/etc/apt/preferences.d/*`, restricted to what APT itself applies

APT's own rules decide what counts as a pin in force, so the check follows them exactly:

* A `.dpkg-old` or `.bak` copy left behind by an upgrade, and any other file name APT skips in `preferences.d`, is not read at all.
* A stanza without a `Pin`, or with a pin type APT does not understand, pins nothing and is skipped, while the rest of the file still applies.
* A stanza with no `Package` header, with a missing, zero or out-of-range `Pin-Priority`, or with `Pin-Priority: never` on a named package, is one APT refuses. It applies the stanzas before it, abandons the file there, and fails. The check reports it the same way.
* A `Pin-Priority` carrying trailing characters, such as `1001abc`, is a priority of 1001 to APT, not a typo it rejects.
* A line starting with whitespace continues the field above it, so a `Package` header may span several lines. Only a truly empty line separates two stanzas: one carrying a space or a tab merges the stanzas around it into a single one, in which a field that now appears twice keeps its last value.
* A line without a colon takes the next field with it. APT looks for the colon that ends a field name in everything that follows rather than to the end of the line, so an `Explanation` line that lost its colon runs on into the `Pin` below it and that stanza pins nothing. One line higher up the same mistake costs the stanza its `Package` header, and that is a file APT refuses. So is a file whose last line lost its colon, because the field name it opens never finds one at all.

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
the APT preferences via --check-pinning, and then alerts as well on a
preferences file APT refuses, which stops the host from installing or
upgrading anything. Supports extended reporting via --lengthy.

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
  -c, --critical CRIT   CRIT threshold for the number of holds. Supports
                        Nagios ranges. Default: None
  --ignore IGNORE       Any item matching this Python regex will be ignored.
                        Can be specified multiple times. Example:
                        `(?i)linuxfabrik` for a case-insensitive match.
  --lengthy             Extended reporting.
  --match MATCH         Filter by this Python regular expression. Case-
                        sensitive by default; use `(?i)` for case-insensitive
                        matching. Can be specified multiple times. If both
                        `--match` and `--ignore` are given, an item must match
                        `--match` AND not match `--ignore` to be reported
                        (include first, exclude second). Examples:
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
  -w, --warning WARN    WARN threshold for the number of holds. Supports
                        Nagios ranges. Default: 0

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/deb-versionlock/
```


## Usage Examples

```bash
./deb-versionlock --lengthy
```

Output:

```text
2 holds in place. [WARNING]

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
2 holds and 1 pin in place. [WARNING]

Package   ! Held at                      ! Type ! Configured in
----------+------------------------------+------+--------------------------------
bash      ! 5.0-4                        ! hold ! apt-mark
coreutils ! 8.30-3                       ! hold ! apt-mark
nginx     ! version 1.24.* priority 1001 ! pin  ! /etc/apt/preferences.d/99-nginx
```

A host whose preferences APT refuses:

```text
1 pin in place. APT refuses 1 preferences file, so installing and upgrading fails on this host. [WARNING]

Package   ! Held at                      ! Type
----------+------------------------------+-----
nginx     ! version 1.24.* priority 1001 ! pin

APT stops reading these files where they are named:
/etc/apt/preferences.d/60-backports: no priority (or zero) specified for pin
```


## States

* OK if nothing is held back, or if the number of holds is within `--warning`.
* WARN or CRIT depending on how the number of holds compares to `--warning` and `--critical`, which take [Nagios range expressions](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/THRESHOLDS.md). The default `--warning=0` alerts on the first hold. Pins count towards the same number.
* WARN, whatever the thresholds say, if `--check-pinning` finds a preferences file APT refuses.
* OK if `--match` and `--ignore` leave nothing to check, unless `--no-match-severity` says otherwise.
* UNKNOWN if APT cannot be asked for its held packages, which means the check is deployed on a host that does not install its packages with APT, or that its APT installation is damaged. APT's own error message is part of the output.
* `--always-ok` forces OK for everything the thresholds decide. It does not cover UNKNOWN, which is reported whatever else is set.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| holds | Number | Number of holds, plus pins with `--check-pinning`, after `--match` and `--ignore` were applied. |


## Troubleshooting

### A hold is reported that nobody set

Holds are dpkg selections, so they also come from configuration management and from an `apt-mark hold` inside a maintainer script. List them and see what the package is:

```bash
apt-mark showhold
dpkg --get-selections | grep hold
```

Release a hold with `apt-mark unhold <package>`.

With `--check-pinning`, an entry of type `pin` is not a hold at all. The `Configured in` column that `--lengthy` adds names the preferences file it comes from; edit that file instead.

### `APT refuses N preferences files, so installing and upgrading fails on this host`

APT reads `/etc/apt/preferences` and `/etc/apt/preferences.d/*` whenever it works out package priorities, and treats a stanza it cannot make sense of as a fatal error, so the host can neither install nor upgrade until the file is fixed. The check names the file and the reason; APT itself prints the same thing:

```bash
apt-get -s upgrade
```

```text
E: No priority (or zero) specified for pin
```

The usual causes are a stanza whose `Pin-Priority` is missing or zero, one whose priority does not fit into the range -32768 to 32767, a stanza with no `Package` header, `Pin-Priority: never` on a stanza that names a package instead of `Package: *`, and a last line that lost its colon.

A missing `Package` header is worth a second look, because it is rarely missing on purpose. A line above it that lost its colon, `Explanation hold nginx` instead of `Explanation: hold nginx`, runs on into the `Package` line and takes it with it, which leaves the stanza without the header it plainly has.

The same mistake on the last line of the file reads differently, because the field name it opens never finds a colon anywhere below it. APT reports that one as `Unable to parse package file /etc/apt/preferences (1)`. Note that `apt-cache policy` without a package name does not work out any priorities and therefore stays silent about it, which makes the file look healthy:

```bash
apt-get -s upgrade
```

```text
E: Unable to parse package file /etc/apt/preferences (1)
```

### A pin is in place but not reported

APT ignores a file in `preferences.d` whose extension is neither absent nor `.pref`, so a `.dpkg-old`, `.bak` or `.save` copy left behind by an upgrade pins nothing. It also skips a stanza that carries no `Pin` or a pin type it does not understand, and `Pin: version` on `Package: *` counts as one of those, since a version is matched against a package. A stanza can lose its `Pin` without looking like it: a line above it that lost its colon runs on into the `Pin` line and swallows it. And two stanzas separated by a line that carries a space instead of nothing are one stanza to APT, of which only the last `Pin` survives. The check follows those rules, so what it leaves out is what APT leaves out. Compare against APT's own view:

```bash
apt-cache policy
```

A preferences file the monitoring user cannot read holds no pins the check could report, so it is treated as empty rather than as an error.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
