# Check rpm-versionlock


## Overview

Reports the packages that the RPM package manager holds back at a fixed version. A version lock set to work around a broken update and then forgotten keeps a host on an unpatched version for good, while the update check stays green because the package manager no longer offers the update. Only locks the package manager actually applies are reported, so a lock list it has switched off stays quiet. Alerts as soon as one lock is in place; raise `--warning` to tolerate a number of deliberate locks, or filter the ones you keep on purpose with `--ignore`. Optionally also reports the packages excluded in the package manager configuration via `--check-excludes`. Supports extended reporting via `--lengthy`.

**Important Notes:**

* Red Hat-based distributions (RHEL, CentOS, Rocky, AlmaLinux, Fedora, etc.)
* Version locking is not part of dnf 4, which RHEL 8, 9 and 10 ship. It comes with the `python3-dnf-plugin-versionlock` package, and a host without that package cannot hold anything back and is reported as having no locks. dnf 5, which Fedora ships, brings version locking with it and needs no extra package.
* On dnf 4 and yum, three configurations leave the entries in a lock list without effect, and the check reports none of them: `enabled = 0` in the plugin configuration, `plugins = 0` in the main configuration, and a plugin configuration that names no `locklist` at all. The last one is worth fixing on its own, because the package manager then refuses to install or upgrade anything with `Error: Locklist not set`.
* None of that applies to dnf 5. It locks without a plugin, so `plugins = 0` does not switch its locks off and the check reports them regardless.
* `--match` and `--ignore` filter on the package name, not on the version the package is locked to
* `--check-excludes` is off by default because an exclusion is also used legitimately to keep two repositories apart, for example to stop a third-party repository from replacing distribution packages. Turn it on where every exclusion on the host is meant to be temporary. A clean host then reports "No version locks and no exclusions in place.", so the summary shows that both searches ran.

**Data Collection:**

The check reads the version lock configuration itself rather than asking the package manager for it. On dnf 4 `dnf versionlock list` refreshes repository metadata over the network and fails outright when the metadata cache is empty, and reading the files keeps the check free of a subprocess on every generation.

* dnf 4 and yum: reads the lock list named by `locklist` in `/etc/dnf/plugins/versionlock.conf`, conventionally `/etc/dnf/plugins/versionlock.list`. There is no built-in default for it, so a configuration that names none is read as "no locks". The `/etc/yum/pluginconf.d/` layout is followed as well, and a lock reachable under both paths is counted once. A `pluginconfpath` in the main configuration moves that search: it replaces the two directories above rather than adding to them, exactly as the package manager treats it.
* dnf 5: reads `/etc/dnf/versionlock.toml`, because that generation keeps its configuration in TOML rather than in a plain list. That file is read unconditionally, since dnf 5 applies its locks from its own library rather than from a plugin.
* `--check-excludes` additionally reads `exclude` / `excludepkgs` from `/etc/dnf/dnf.conf` and from every `.repo` file in the directories `reposdir` names. Where it names none, all four default directories are searched: `/etc/yum.repos.d`, `/etc/yum/repos.d`, `/etc/distro.repos.d` and `/usr/share/dnf5/repos.d`. The last two generations disagree on one entry each, dnf 4 not reading the dnf 5 directory and dnf 5 not reading `/etc/yum/repos.d`, so an exclusion left in the directory belonging to the other generation is reported although nothing applies it. A `main` section inside a `.repo` file is skipped, since the package manager reads its main configuration from one file only.

Entries the package manager marks as an exclusion (a `!` prefix in the lock list, `evr !=` on dnf 5) are reported as type `exclude`, everything else as `versionlock`. The summary counts the two kinds separately, because an exclusion keeps a package off the host rather than at a version. The `locks` metric and the `--warning` / `--critical` thresholds count both together.

A lock list entry is read the way the package manager reads it, which matters wherever the name and the version cannot be told apart by eye. `bash-0:4.4.20-6.el8_10.*` is the spelling the package manager writes; `0:bash-4.4.20-6.el8_10.*` puts the same epoch in front and is accepted as well. An entry with no epoch is split on its last two dash-separated fields only when both of them start with a digit, so `python3-foo-1.2-3.el9` is a version lock while `java-1.8.0-openjdk` and `kernel-devel-*` stay whole package names.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/rpm-versionlock> |
| Nagios/Icinga Check Name              | `check_rpm_versionlock` |
| Check Interval Recommendation         | Every hour |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |
| Requirements                          | On RHEL 8, 9 and 10: `python3-dnf-plugin-versionlock`, but only where locks are actually used. On dnf 5 nothing extra. |


## Help

```text
usage: rpm-versionlock [-h] [-V] [--always-ok] [--check-excludes] [-c CRIT]
                       [--ignore IGNORE] [--lengthy] [--match MATCH]
                       [--no-match-severity {ok,warn,crit,unknown}]
                       [--no-perfdata] [-w WARN]

Reports the packages that the RPM package manager holds back at a fixed
version. A version lock set to work around a broken update and then forgotten
keeps a host on an unpatched version for good, while the update check stays
green because the package manager no longer offers the update. Only locks the
package manager actually applies are reported, so a lock list it has switched
off stays quiet. Alerts as soon as one lock is in place; raise --warning to
tolerate a number of deliberate locks, or filter the ones you keep on purpose
with --ignore. Optionally also reports the packages excluded in the package
manager configuration via --check-excludes. Supports extended reporting via
--lengthy.

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
2 version locks and 1 exclusion in place. [WARNING]

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
2 version locks and 3 exclusions in place. [WARNING]

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
* WARN or CRIT depending on how the number of locks compares to `--warning` and `--critical`, which take [Nagios range expressions](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/THRESHOLDS.md). The default `--warning=0` alerts on the first lock. Exclusions count towards the same number.
* OK if `--match` and `--ignore` leave nothing to check, unless `--no-match-severity` says otherwise.
* UNKNOWN if the host has no dnf or yum configuration at all, which means the check is deployed on a host that does not install its packages with RPM.
* `--always-ok` forces OK for everything the thresholds decide. It does not cover UNKNOWN, which is reported whatever else is set.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| locks | Number | Number of version locks, plus exclusions with `--check-excludes`, after `--match` and `--ignore` were applied. |


## Troubleshooting

### A lock is in place but not reported

The lock list the package manager uses is the one named by `locklist` in `/etc/dnf/plugins/versionlock.conf`. Check where that points, and whether the monitoring user can read the file:

```bash
grep locklist /etc/dnf/plugins/versionlock.conf
su icinga -s /bin/bash -c "cat /etc/dnf/plugins/versionlock.list"
```

A file the monitoring user cannot read holds no locks the check could report, so it is treated as empty rather than as an error.

On dnf 4 and yum, three settings switch version locking off, and the check follows all three. Verify none of them applies:

```bash
grep -E '^\s*(enabled|locklist)' /etc/dnf/plugins/versionlock.conf
grep -E '^\s*plugins' /etc/dnf/dnf.conf
```

`enabled = 0`, `plugins = 0` or a missing `locklist` each mean the package manager applies no locks, so the check reports none either. On dnf 5 none of this matters: it locks from its own library, and `/etc/dnf/versionlock.toml` is read whatever those settings say.

### A lock is reported that nobody set

Look at the `Configured in` column that `--lengthy` adds, and remove the entry there:

```bash
./rpm-versionlock --lengthy
dnf versionlock delete <package>
```

An entry that names a `.repo` file or `/etc/dnf/dnf.conf` is not a version lock but an exclusion, which only shows up with `--check-excludes`. Those are removed by editing the `exclude` or `excludepkgs` line in the file the column names, not with `dnf versionlock`.

An exclusion in `/etc/yum/repos.d` on a dnf 5 host, or in `/usr/share/dnf5/repos.d` on a dnf 4 host, is reported although that generation never reads the directory. Move it to `/etc/yum.repos.d`, which both of them read, or delete it.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
