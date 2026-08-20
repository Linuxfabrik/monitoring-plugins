# File Plugins

The file plugins report on files and directories: how large they are, how fast
they grow, how old they are, how many there are, and who owns them. They read
file metadata only, never the contents.

This page holds what the group has in common. Each plugin's README covers what
is specific to it.


## Plugins in this group

| Plugin | Reports | Selects files with |
|---|---|---|
| `file-age` | time since the last modification | `--filename`, SMB |
| `file-count` | number of matching files | `--filename`, SMB |
| `file-descriptors` | file descriptors in use against the system limit | reads `/proc` |
| `file-growth` | how fast files grow or shrink, as a rate per second | `--filename`, SMB |
| `file-ownership` | owner, group and permissions against what they should be | `--filename` |
| `file-size` | size of one or more files | `--filename`, SMB |

`file-descriptors` shares the name but not the mechanics: it reads kernel
counters instead of a path an operator points it at, so most of this page does
not apply to it.


## Selecting files

`--filename` takes a path or a glob pattern, as documented for
[Python's glob module](https://docs.python.org/3/library/glob.html):

```bash
./file-size --filename=/var/log/messages
./file-size --filename='/var/log/*.log'
./file-size --filename='/var/log/**/*.log'
```

Write the parameter with `=`, as above, or quote the pattern. Both keep the
shell from expanding it: with `--filename=/var/log/*.log` the shell would have
to match the whole word against a path, finds nothing, and passes it through
untouched.

Separating the parameter from its value by a space is what goes wrong.
`--filename /var/log/*.log` is expanded before the plugin ever sees it, so the
check reads only the first match and discards the rest without a word: a
directory of four log files is reported as "1 file checked", and nothing says
that three were dropped.

Points that apply to every plugin in the group:

* **Recursive globs (`**`) can use a lot of memory** on large directory trees,
  because the whole match list is built before anything is checked. Prefer a
  pattern that names the directory level you mean.
* **Symbolic links are followed.** A link is reported as whatever it points at.
* **Directories are skipped** by `file-size` and `file-growth`, because the
  size a filesystem reports for a directory says nothing about its contents and
  differs between filesystems. `file-age` and `file-count` can include them,
  see their `--only-dirs` and `--only-files` parameters.
* **Files that disappear mid-check** are skipped rather than reported as an
  error. Temporary files come and go while the check runs.
* **A pattern that matches nothing** is UNKNOWN with `No files found.`, not OK.
  A check that silently reports success on a typo would be worse than useless.


## SMB shares

`file-age`, `file-count`, `file-growth` and `file-size` read from an SMB share
with `--url` instead of `--filename`. The two are mutually exclusive:

```bash
./file-size --url=smb://server.example/share/logs --username=monitoring --password=linuxfabrik
```

* `--pattern` filters the names on the share. It takes `*` and `?` as
  wildcards, and is not a regular expression.
* `--timeout` bounds the connection, so an unreachable server fails the check
  instead of hanging until the monitoring system kills it.
* This needs the optional `PySmbClient` and `smbprotocol` Python modules. They
  ship with the RPM and DEB packages; for a source install, add them to the
  venv of the user running the plugins:

```bash
python3 -m pip install PySmbClient smbprotocol
```

A password on the command line is visible in `ps auxf` to every user on the
host. Prefer a service account with read-only access to the share, and set the
password on the concrete Icinga service object rather than on a template or a
Service Set, so it is only distributed to the zone that runs the check.


## Thresholds and units

`--warning` and `--critical` take Nagios ranges, which is what allows a bound on
one side only, or an alert on a value falling *inside* a range.
[THRESHOLDS.md](THRESHOLDS.md) has the syntax and a table of worked examples.

Where a threshold is a size (`file-size`, `file-growth`), it is written with
the IEC qualifiers from [UNITS.md](UNITS.md), so `KiB`, `MiB`, `GiB` and so on,
always base 1024. Lowercase and the shorter spellings (`k`, `kb`, `kib`) are
accepted too. A value without a qualifier is a number of bytes.

A range bound includes its own value: a file growing at exactly the threshold
is still within it and does not alert.


## Aggregation across many files

`file-age`, `file-growth` and `file-size` take `--perfdata-mode` to collapse
the performance data of a glob that matches many files into a single series,
either `mean` or `median`. Without it, a glob over hundreds of files would
write hundreds of series into the time series database on every run.

The status message and the exit code are unaffected: every matched file is
still checked against the thresholds and still shows up in the output table.

`--perfdata-mode=None` is the same as not passing the parameter. It exists so
the Icinga Director dropdown has an entry for "do not aggregate" rather than
only an empty field.


## These plugins are not in the sudoers file

Linuxfabrik ships a sudoers file that lets the monitoring user run selected
plugins as root without a password (see `assets/sudoers/`). The file plugins
are deliberately **not** in it, and neither is a `-sudo` variant of their check
commands in the Icinga Director basket.

The reason is the shape of their parameters. `--filename` takes any path the
caller writes, including a glob. A plugin that accepts a free-form path and
runs as root hands whoever controls the monitoring account a way to ask about
any file on the system. For a plugin that prints file contents this is an
immediate privilege escalation, which is what happened to the `logfile` plugin
in [GHSA-f54c-p5vg-mr5c](https://github.com/Linuxfabrik/monitoring-plugins/security/advisories/GHSA-f54c-p5vg-mr5c).
The file plugins print metadata rather than contents, so the same mistake would
leak less, but it would still tell an attacker the size, age and existence of
every file on the host, including paths they have no business knowing about.

Rather than guess a list of directories that would be safe enough to allow, we
leave the decision where it belongs: with the administrator, who knows which
files on this host are worth monitoring and who is allowed near the monitoring
account.


## What to do when the plugin cannot read a file

A file the monitoring user may not open produces one of these:

```text
No files found.
```

```text
[Errno 13] Permission denied: '/var/log/audit/audit.log'
```

`No files found.` is the more confusing of the two, because it is also what an
empty glob looks like. A directory the monitoring user cannot traverse hides
its contents from the glob entirely, so a pattern that matches nothing and a
pattern the user may not look at give the same answer.

Confirm which of the two it is by looking as the monitoring user:

```bash
sudo --user=icinga ls -l /var/log/audit/audit.log
```

Then pick one of the following, in this order of preference.

**Grant read access with an ACL.** The cleanest fix, because it grants exactly
one thing and survives a reboot:

```bash
setfacl --modify=u:icinga:r /var/log/audit/audit.log
```

For a whole directory whose files are recreated by log rotation, set a default
ACL as well, so new files inherit it:

```bash
setfacl --modify=u:icinga:rx --modify=default:u:icinga:r /var/log/myapp/
```

**Adjust the rotation config** when a rotated file keeps losing its
permissions. `logrotate` recreates files with the mode from its own
configuration, so put the permission there instead of repairing it by hand
after every rotation:

```text
/var/log/myapp/*.log {
    create 0640 root icinga
}
```

**Add your own sudoers entry** when the file cannot be opened up, an audit log
under a policy that forbids widening its permissions for example. This is a
decision about your host, so it belongs in your own configuration and not in
the package:

```text
icinga ALL=(root) NOPASSWD: /usr/lib64/nagios/plugins/file-size --critical 200M --filename /var/log/myapp/big.log --warning 180M
```

**Pin every argument, and use no wildcard anywhere.** This is the part that is
easy to get wrong. An entry that ends at the plugin path allows every
`--filename` the caller cares to write, which is the thing this group avoids by
default. A `*` does not narrow that down the way it looks like it should,
because sudo does not match arguments one by one: it joins them into a single
string and matches that with `fnmatch()`, without `FNM_PATHNAME`. A `*`
therefore matches spaces and slashes and runs straight across argument
boundaries. So

```text
icinga ALL=(root) NOPASSWD: /usr/lib64/nagios/plugins/file-size --critical * --filename /var/log/myapp/big.log --warning *
```

still permits

```bash
sudo /usr/lib64/nagios/plugins/file-size --critical 200M \
    --filename /var/log/myapp/big.log --warning 180M --filename /root/.ssh/id_rsa
```

and reports on the key instead: the second `--filename` is swallowed by the
trailing `*`, and the check resolves the last one it is given. A `*` in the
middle of the line is no safer than one at the end.

Write the arguments out instead, in the order the check command generates them,
which is alphabetical by parameter name. The cost is that changing a threshold
in the Icinga Director means changing the sudoers entry as well, and the check
reports a sudo error until you do.

sudo can match arguments as a POSIX extended regular expression when the pattern
starts with `^` and ends with `$`, which would allow a threshold to vary without
opening up the path. That needs sudo 1.9.10 or newer: RHEL 8 (1.9.5), Debian 11
(1.9.5) and Ubuntu 22.04 (1.9.9) read such an entry as a literal pattern
instead, so the check is denied and stops working. Only use it on a fleet where
every host is new enough.

Then point the service at a check command that prepends `/usr/bin/sudo`. None of
the file checks ship such a variant, for the same reason they are not in the
sudoers file, so create your own in the Icinga Director. Do not edit the shipped
basket files.


## When sudo asks for a password

A check command that prepends `/usr/bin/sudo` without a matching sudoers entry
never reaches the plugin. What the monitoring server gets is sudo's own output,
including its lecture about respecting the privacy of others:

```text
sudo: a terminal is required to read the password; either use the -S option to read from standard input or configure an askpass helper
sudo: a password is required
```

sudo exits 1 for this, so the service goes WARNING rather than UNKNOWN and
looks like an alert about the files, while nothing about them was checked at
all.

The cause is always that sudo found no entry matching this exact call. The file
plugins are not in the shipped sudoers file (see above), and an entry of your
own matches only when every argument is identical to what the check command
generates, in the same order. A threshold changed in the Icinga Director or one
more parameter set on the service is enough to stop it from matching.

Reproduce it as the monitoring user, where `--non-interactive` turns the
password prompt into an immediate error:

```bash
sudo --user=icinga sudo --non-interactive /usr/lib64/nagios/plugins/file-age --filename /backup/myapp/*
```

Then either write the sudoers entry with every argument pinned as described
above, or drop the sudo call and open the path for the monitoring user with an
ACL. Reading file metadata needs no read permission on the files themselves,
only the right to traverse the directories above them, so a check on the age,
size or count of a file often comes down to one `x` bit:

```bash
setfacl --modify=u:icinga:rx /backup /backup/myapp
```


## Worked example: a file only root can reach

Say you want to alert when `/var/log/audit/audit.log` grows past a size. The
`audit` package ships `/var/log/audit` as `drwxr-x---` owned by root, so the
monitoring user cannot traverse into the directory, let alone stat the log. The
check reports a permission error, and none of the ACL approaches above are open
to you because the audit log is exactly the kind of file a policy tends to
forbid opening up.

The remaining route is a sudoers entry of your own, with every argument pinned:

```text
icinga ALL=(root) NOPASSWD: /usr/lib64/nagios/plugins/file-size --critical 200M --filename /var/log/audit/audit.log --warning 10M
```

Create a check command in the Icinga Director that prepends `/usr/bin/sudo` to
`cmd-check-file-size`, point a service at it, and set the same thresholds on
that service that the sudoers entry pins. Change one and you have to change the
other, or sudo refuses the call.

Before you build it, check whether the alert can fire at all. `auditd` rotates
its own log: `/etc/audit/auditd.conf` ships `max_log_file = 8` (megabytes),
`num_logs = 5` and `max_log_file_action = ROTATE`, so on a default installation
the file never comes near the given threshold. A size
threshold on a self-rotating log is a check that can only ever report OK. Either
set the threshold just under `max_log_file` so it catches rotation having
stopped, or watch the thing you actually care about: `file-count` on
`/var/log/audit/*.log` to see whether rotation is keeping up, or
`systemd-unit` on `auditd.service`.
