# Check rpm-versionlock


## Overview

Reports the packages that the RPM package manager holds back at a fixed version. A version lock set to work around a broken update and then forgotten keeps a host on an unpatched version for good, while the update check stays green because the package manager no longer offers the update. Only locks the package manager actually applies are reported, so a lock list it has switched off stays quiet. Alerts as soon as one lock is in place; raise `--warning` to tolerate a number of deliberate locks, or filter the ones you keep on purpose with `--ignore`. Alerts as well on a lock configuration the package manager refuses, which stops the host from installing or upgrading anything, and on one it reads without applying any of it. Optionally also reports the packages excluded in the package manager configuration via `--check-excludes`. Supports extended reporting via `--lengthy`.

**Important Notes:**

* Red Hat-based distributions (RHEL, CentOS, Rocky, AlmaLinux, Fedora, etc.)
* Version locking is not part of dnf 4, which RHEL 8, 9 and 10 ship. It comes with the `python3-dnf-plugin-versionlock` package, and a host without that package cannot hold anything back and is reported as having no locks. dnf 5, which Fedora ships, brings version locking with it and needs no extra package.
* On dnf 4 and yum, two configurations leave the entries in a lock list without effect, and the check reports neither: `enabled = 0` in the plugin configuration and `plugins = 0` in the main configuration. Both simply mean the package manager never loads the plugin, and a host with either is healthy.
* A lock configuration that is enabled but unusable is a different matter, and the check alerts on it. The package manager does not fall back to "no locks" there, it refuses to install or upgrade anything at all until the file is fixed: `Error: Locklist not set` where no `locklist` is named, `Error: Unable to read version lock configuration` where the file it names is not there, and `Error: Parsing file failed` where the plugin configuration itself does not parse. An `enabled` that is neither true nor false is harsher still and takes down every command, not only a transaction, because the package manager's own parser raises while it loads its plugins. dnf 5 is harsher still and aborts with an unhandled parser error on a `versionlock.toml` it cannot read. The offending files are named at the end of the output.
* dnf 5 acts on `versionlock.toml` only where it declares `version = "1.0"`. With any other version, and with none at all, it reads the file and applies nothing in it while installing and upgrading as usual. Locks in such a file are reported as not applied rather than as being in place, so the verdict never claims a package is held back when it is not.
* None of the plugin configuration applies to dnf 5. It locks without a plugin, so `plugins = 0` does not switch its locks off and the check reports them regardless.
* The two generations do not read each other's configuration, and dnf 5 keeps its own plugin configuration below `/etc/dnf/dnf5-plugins/` and `/etc/dnf/libdnf5-plugins/` rather than in `/etc/dnf/plugins/`. A host that was upgraded to dnf 5 and still carries a `/etc/dnf/plugins/versionlock.conf` from before therefore gets the dnf 4 reading of that leftover, which dnf 5 applies nothing of. Delete the directory once the locks have been moved to `/etc/dnf/versionlock.toml`. Red Hat-based distributions are not affected, RHEL 8, 9 and 10 all ship dnf 4.
* A host without the `python3-dnf-plugin-versionlock` package but with a leftover `versionlock.conf` cannot be told apart from one where the package is installed, so the check reads the presence of that file as "the plugin is there". The reverse case, a package installed whose configuration file was deleted, breaks the package manager the same way `Error: Locklist not set` does, and the check cannot see it: nothing in `/etc` says the plugin is installed.
* `--match` and `--ignore` filter on the package name, not on the version the package is locked to
* `--check-excludes` is off by default because an exclusion is also used legitimately to keep two repositories apart, for example to stop a third-party repository from replacing distribution packages. Turn it on where every exclusion on the host is meant to be temporary. A clean host then reports "No version locks and no exclusions in place.", so the summary shows that both searches ran.

**Data Collection:**

The check reads the version lock configuration itself rather than asking the package manager for it. On dnf 4 `dnf versionlock list` refreshes repository metadata over the network and fails outright when the metadata cache is empty, and reading the files keeps the check free of a subprocess on every generation.

* dnf 4 and yum: reads the lock list named by `locklist` in `/etc/dnf/plugins/versionlock.conf`, conventionally `/etc/dnf/plugins/versionlock.list`. There is no built-in default for it, so a configuration that names none holds nothing back and is reported as a configuration the package manager refuses. The `/etc/yum/pluginconf.d/` layout is followed as well, and a lock reachable under both paths is counted once. A `pluginconfpath` in the main configuration moves that search: it replaces the two directories above rather than adding to them, exactly as the package manager treats it. Every directory it names is searched, but the files found are merged into a single configuration in which a later one overrides an earlier one, so exactly one `enabled` and exactly one `locklist` are ever in force - and therefore exactly one lock list. A file that does not parse is the exception: the package manager stumbles over it while it is still reading and never gets to the directories behind it.
* A lock list the monitoring user is not allowed to read is reported as holding no locks, not as a broken configuration. The package manager runs as root and reads it without trouble, so the host is fine and the check simply cannot see that far.
* dnf 5: reads `/etc/dnf/versionlock.toml`, because that generation keeps its configuration in TOML rather than in a plain list. That file is read unconditionally, since dnf 5 applies its locks from its own library rather than from a plugin.
* `--check-excludes` additionally reads `exclude` / `excludepkgs` from the main configuration and from every `.repo` file in the directories `reposdir` names. Two configurations take an exclusion out of force without removing it from the file: a repository whose section is `enabled=0`, which the package manager skips whole, and `disable_excludes`, which switches exclusion off for the main configuration, for a named repository, or for every scope at once. Both generations honour it from the configuration file; only the spelling for "every scope" differs, `all` on dnf 4 and `*` on dnf 5, and only dnf 5 lacks a command line switch for it. Both spellings are accepted. Such an entry is still reported, because an exclusion written down is worth seeing, and the summary says how many of them are not acted on. The main configuration is one file: `/etc/dnf/dnf.conf`, or `/etc/yum.conf` where that is the only one present. Where `/etc/yum.conf` survives as a file of its own beside the dnf one, the package manager reads neither it nor its exclusions, and neither does the check. Where it names none, all four default directories are searched: `/etc/yum.repos.d`, `/etc/yum/repos.d`, `/etc/distro.repos.d` and `/usr/share/dnf5/repos.d`. The last two generations disagree on one entry each, dnf 4 not reading the dnf 5 directory and dnf 5 not reading `/etc/yum/repos.d`, so an exclusion left in the directory belonging to the other generation is reported although nothing applies it. A `main` section inside a `.repo` file is skipped, since the package manager reads its main configuration from one file only.

Entries the package manager marks as an exclusion (a `!` prefix in the lock list, `evr !=` on dnf 5) are reported as type `exclude`, everything else as `versionlock`. The summary counts the two kinds separately, because an exclusion keeps a package off the host rather than at a version. The `locks` metric and the `--warning` / `--critical` thresholds count both together.

A lock list entry is read the way the package manager reads it, which matters wherever the name and the version cannot be told apart by eye. `bash-0:4.4.20-6.el8_10.*` is the spelling the package manager writes, with the epoch behind the name, and it is the only position it reads an epoch in: `0:bash-4.4.20-6.el8_10.*` is refused with `could not parse pattern` and holds nothing, so it is reported as a dead entry rather than as a lock. An entry with no epoch is split on its last two dash-separated fields only when both of them start with a digit, so `python3-foo-1.2-3.el9` is a version lock while `java-1.8.0-openjdk` and `kernel-devel-*` stay whole package names.


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
with --ignore. Alerts as well on a lock configuration the package manager
refuses, which stops the host from installing or upgrading anything, and on
one it reads without applying any of it. Optionally also reports the packages
excluded in the package manager configuration via --check-excludes. Supports
extended reporting via --lengthy.

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
* WARN if the package manager refuses a lock configuration, whatever the number of locks says. Such a host cannot install or upgrade anything until the file is fixed.
* WARN if a `versionlock.toml` declares a version dnf 5 does not act on, so the locks in it are not applied. They are not counted as locks in place, because they are not.
* WARN if a lock list holds an entry the package manager cannot parse. It looks like a lock in the file but holds nothing, so it is named separately instead of being counted as one.
* A single entry dnf 5 marks invalid, because it carries a condition key the package manager does not know or no condition at all, is not counted as a lock either. dnf 5 reports it the same way under `dnf5 versionlock list`.
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

On dnf 4 and yum, two settings switch version locking off, and the check follows both. Verify neither applies:

```bash
grep -E '^\s*enabled' /etc/dnf/plugins/versionlock.conf
grep -E '^\s*plugins' /etc/dnf/dnf.conf
```

`enabled = 0` or `plugins = 0` mean the package manager never loads the plugin, so the check reports no locks either. A missing `locklist` is not one of these cases and gets its own alert, see below. On dnf 5 none of this matters: it locks from its own library, and `/etc/dnf/versionlock.toml` is read whatever those settings say.

On dnf 5, check that the lock file declares the one version the package manager acts on:

```bash
head -n1 /etc/dnf/versionlock.toml
```

```text
version = "1.0"
```

With any other version, and with none at all, dnf 5 reads the file and applies nothing in it. The check reports that as locks that are not applied rather than as locks in place.

### `The package manager refuses N lock configurations, so installing and upgrading fails on this host`

The named file is enabled but unusable, and the package manager does not degrade gracefully: it stops before every install and every upgrade. Reproduce it with a resolving command, since `dnf list` and `dnf repoquery` never look at the lock configuration:

```bash
dnf --assumeno install <any-package>
```

```text
Error: Locklist not set
```

Which of the three it is comes from the reason printed behind the file name. `it names no lock list` means the plugin configuration has no `locklist` line, which is what an emptied or hand-edited `versionlock.conf` usually looks like; restore it to the shipped default:

```bash
printf '[main]\nenabled = 1\nlocklist = /etc/dnf/plugins/versionlock.list\n' > /etc/dnf/plugins/versionlock.conf
touch /etc/dnf/plugins/versionlock.list
```

`its lock list "..." does not exist` means the file the configuration names was deleted; `touch` it, or point `locklist` at the file that holds the locks. `it does not parse` means the plugin configuration is not valid INI at all, most often a `key = value` line that ended up above the `[main]` header. On dnf 5, `it does not parse as TOML` means `/etc/dnf/versionlock.toml` is damaged. That generation does not report it as an error at all: it aborts on an unhandled parser exception and leaves a `what():` line behind. `dnf5 versionlock list` names the offending line and is the quickest way to find it.

### `N lock configurations are not applied at all`

The `versionlock.toml` named at the end of the output declares a format version dnf 5 does not act on, so every lock in it is inert. This only happens to a hand-edited file, since `dnf5 versionlock add` writes the version itself. Put it back:

```bash
sed -i '1s/.*/version = "1.0"/' /etc/dnf/versionlock.toml
dnf --assumeno install <a-locked-package>
```

```text
Argument '<a-locked-package>' matches only packages excluded by versionlock.
```

### A lock is reported that nobody set

Look at the `Configured in` column that `--lengthy` adds, and remove the entry there:

```bash
./rpm-versionlock --lengthy
dnf versionlock delete <package>
```

An entry that names a `.repo` file or `/etc/dnf/dnf.conf` is not a version lock but an exclusion, which only shows up with `--check-excludes`. Those are removed by editing the `exclude` or `excludepkgs` line in the file the column names, not with `dnf versionlock`.

An exclusion in `/etc/yum/repos.d` on a dnf 5 host, or in `/usr/share/dnf5/repos.d` on a dnf 4 host, is reported although that generation never reads the directory. Move it to `/etc/yum.repos.d`, which both of them read, or delete it.

### `N of the exclusions are written down but not in force`

The exclusions are in the files, but something switches them off: the repository section they sit in is `enabled=0`, or `disable_excludes` in `/etc/dnf/dnf.conf` names that repository, `main`, or every scope at once (`all` on dnf 4, `*` on dnf 5). The entries stay in the report, because an exclusion written down is worth seeing and because the same files have to produce the same list whichever generation is installed.

Nothing is broken here, and no state comes from this line. It is worth reading when a package is unexpectedly installable on one host and not on another that has the same files, and when a `disable_excludes` left over from a migration keeps exclusions inert that were meant to hold. Compare against what the package manager itself has:

```bash
dnf config-manager --dump | grep --extended-regexp 'disable_excludes|excludepkgs'
```


### `N lock entries the package manager cannot parse, so they hold nothing`

A line in the lock list is written in a spelling the package manager cannot read. It looks like a lock in the file, the package manager logs `Versionlock plugin: could not parse pattern: ...` on every transaction, and the package is not held at all. The offending lines are named at the end of the output.

The usual cause is an epoch written in front of the package name. The package manager writes it behind the name and reads it nowhere else, so rewrite the entry:

```text
0:bash-5.1.8-9.el9.*        wrong, holds nothing
bash-0:5.1.8-9.el9.*        right
```

Easiest is to let the package manager write the entry itself, which always produces the spelling it can read back:

```bash
dnf versionlock delete '0:bash-5.1.8-9.el9.*'
dnf versionlock add bash
```


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
