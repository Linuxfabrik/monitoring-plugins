# Check rpm-versionlock


## Overview

Reports the packages that the RPM package manager holds back at a fixed version. A version lock set to work around a broken update and then forgotten keeps a host on an unpatched version for good, while the update check stays green because the package manager no longer offers the update. Alerts as soon as one lock is in place; raise `--warning` to tolerate a number of deliberate locks, or filter the ones you keep on purpose with `--ignore`. Optionally also reports the packages excluded in the package manager configuration via `--check-excludes`. Supports extended reporting via `--lengthy`.

**Important Notes:**

* Red Hat-based distributions (RHEL, CentOS, Rocky, AlmaLinux, Fedora, etc.)
* Version locking is not part of dnf 4, which RHEL 8, 9 and 10 ship. It comes with the `python3-dnf-plugin-versionlock` package. A host without that package cannot hold anything back and is reported as having no locks.
* `--match` and `--ignore` filter on the package name, not on the version the package is locked to
* `--check-excludes` is off by default because an exclusion is also used legitimately to keep two repositories apart, for example to stop a third-party repository from replacing distribution packages. Turn it on where every exclusion on the host is meant to be temporary.

**Data Collection:**

The check reads the version lock configuration itself rather than asking the package manager for it, because `dnf versionlock list` refreshes repository metadata over the network on dnf 4 and fails outright when the metadata cache is empty.

* dnf 4 and yum: reads the lock list named by `locklist` in `/etc/dnf/plugins/versionlock.conf`, by default `/etc/dnf/plugins/versionlock.list`. The `/etc/yum/pluginconf.d/` layout is followed as well, and a lock reachable under both paths is counted once.
* dnf 5: runs `dnf versionlock list`, because that generation keeps its configuration in `/etc/dnf/versionlock.toml`. Unlike on dnf 4 the command reads no repository metadata.
* `--check-excludes` additionally reads `exclude` / `excludepkgs` from `/etc/dnf/dnf.conf` and from every `.repo` file in the directories `reposdir` names, which defaults to `/etc/yum.repos.d`, `/etc/yum/repos.d` and `/etc/distro.repos.d`.

Entries the package manager marks as an exclusion (a `!` prefix in the lock list, `evr !=` on dnf 5) are reported as type `exclude`, everything else as `versionlock`.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/rpm-versionlock> |
| Nagios/Icinga Check Name              | `check_rpm_versionlock` |
| Check Interval Recommendation         | Every hour |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |
| Requirements                          | On RHEL 8, 9 and 10: `python3-dnf-plugin-versionlock`, but only where locks are actually used |


## Help

```text
usage: rpm-versionlock [-h] [-V] [--always-ok] [--check-excludes] [-c CRIT]
                       [--ignore IGNORE] [--lengthy] [--match MATCH]
                       [--no-match-severity {ok,warn,crit,unknown}]
                       [--no-perfdata] [--timeout TIMEOUT] [-w WARN]

Reports the packages that the RPM package manager holds back at a fixed
version. A version lock set to work around a broken update and then forgotten
keeps a host on an unpatched version for good, while the update check stays
green because the package manager no longer offers the update. Alerts as soon
as one lock is in place; raise --warning to tolerate a number of deliberate
locks, or filter the ones you keep on purpose with --ignore. Optionally also
reports the packages excluded in the package manager configuration via
--check-excludes. Supports extended reporting via --lengthy.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --check-excludes      Additionally report the packages excluded in the
                        package manager configuration. An exclusion keeps a
                        package off the host just as effectively as a version
                        lock, but it is also used legitimately to keep two
                        repositories apart, which is why it is not reported by
                        default.
  -c, --critical CRIT   CRIT threshold for the number of version locks.
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
  -w, --warning WARN    WARN threshold for the number of version locks.
                        Supports Nagios ranges. Default: 0

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/rpm-versionlock/
```


## Usage Examples

```bash
./rpm-versionlock --lengthy
```

Output:

```text
3 version locks in place. [WARNING]

Package ! Locked to             ! Type        ! Configured in
--------+-----------------------+-------------+----------------------------------
bash    ! 0:5.1.8-9.el9.*       ! versionlock ! /etc/dnf/plugins/versionlock.list
curl    ! 0:7.76.1-40.el9.*     ! exclude     ! /etc/dnf/plugins/versionlock.list
glibc   ! 0:2.34-231.el9_7.10.* ! versionlock ! /etc/dnf/plugins/versionlock.list
```

Tolerate the two locks the host is meant to have, and alert on anything on top of them:

```bash
./rpm-versionlock --ignore='^kernel' --warning=1
```

Also report what the package manager configuration excludes:

```bash
./rpm-versionlock --check-excludes --lengthy
```

Output:

```text
5 version locks in place. [WARNING]

Package ! Locked to             ! Type        ! Configured in
--------+-----------------------+-------------+----------------------------------
bash    ! 0:5.1.8-9.el9.*       ! versionlock ! /etc/dnf/plugins/versionlock.list
curl    ! 0:7.76.1-40.el9.*     ! exclude     ! /etc/dnf/plugins/versionlock.list
glibc   ! 0:2.34-231.el9_7.10.* ! versionlock ! /etc/dnf/plugins/versionlock.list
kernel* ! [main]                ! exclude     ! /etc/dnf/dnf.conf
redis   ! [main]                ! exclude     ! /etc/dnf/dnf.conf
```


## States

* OK if nothing is locked, or if the number of locks is within `--warning`.
* WARN or CRIT depending on how the number of locks compares to `--warning` and `--critical`, which take [Nagios range expressions](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/THRESHOLDS.md). The default `--warning=0` alerts on the first lock.
* OK if `--match` and `--ignore` leave nothing to check, unless `--no-match-severity` says otherwise.
* UNKNOWN if the host has no dnf or yum configuration at all, which means the check is deployed on a host that does not install its packages with RPM.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| locks | Number | Number of version locks after `--match` and `--ignore` were applied. |


## Troubleshooting

### A lock is in place but not reported

The lock list the package manager uses is the one named by `locklist` in `/etc/dnf/plugins/versionlock.conf`. Check where that points, and whether the monitoring user can read the file:

```bash
grep locklist /etc/dnf/plugins/versionlock.conf
su icinga -s /bin/bash -c "cat /etc/dnf/plugins/versionlock.list"
```

A file the monitoring user cannot read holds no locks the check could report, so it is treated as empty rather than as an error.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
