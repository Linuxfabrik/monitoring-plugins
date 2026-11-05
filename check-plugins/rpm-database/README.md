# Check rpm-database


## Overview

Checks that the RPM database can be read completely, by listing every installed package the way the package manager does. A broken database stops dnf, yum, zypper and every check that asks for installed packages, so the host silently stops receiving updates. Alerts when the database cannot be opened, when reading it reports errors, and when it lists no packages at all. Requires root or sudo.

**Important Notes:**

* **Requires root, and refuses to run without it.** On RHEL 8 and older, rpm opens the database without its shared lock environment when it is not root. A database whose environment was left behind by a killed process then reads fine as an ordinary user and lists every package, while dnf and yum, which run as root, fail on it. The check therefore insists on root and returns UNKNOWN instead of reporting such a run as OK.
* **A damaged database does not always make rpm fail.** rpm lists the packages it gets to, prints its errors and exits 0. The check reads rpm's `error:` lines, not just the exit code, and reports how many packages could still be read.
* **Lines rpm marks as `warning:` are shown, but do not change the state.** The typical one is `BDB2053 Freeing read locks`, which rpm prints once after a process was killed while only reading, and which it repairs on its own.
* **A query killed inside Berkeley DB breaks the database.** A common way into the state this check reports on RHEL 8: something that reads the database, a package manager, a monitoring check, a script, gets killed with SIGKILL at the wrong moment. The check gives rpm 60 seconds, because the first read of a large database after a reboot can take tens of seconds on slow storage. Do not lower `--timeout` on RHEL 8, and keep the command timeout of the monitoring server above it. RHEL 9 and later use SQLite, which survives such a kill.
* Runs on the Red Hat and SUSE families. Other distributions can install `rpm` too, but their RPM database is empty by design.
* Related checks: `rpm-updates` reports what is waiting to be installed, `rpm-lastactivity` when the package manager last did something. Both depend on a readable database.

**Data Collection:**

* Runs `rpm --query --all --queryformat='%{NAME}\n'` and counts the packages
* Reads the `error:` and `warning:` lines rpm prints on stderr
* Measures how long the query takes
* Requires root or sudo


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/rpm-database> |
| Nagios/Icinga Check Name              | `check_rpm_database` |
| Check Interval Recommendation         | Every hour |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |
| Requirements                          | command-line tool `rpm`; User with higher permissions |


## Help

```text
usage: rpm-database [-h] [-V] [--always-ok] [--no-perfdata]
                    [--timeout TIMEOUT]

Checks that the RPM database can be read completely, by listing every
installed package the way the package manager does. A broken database stops
dnf, yum, zypper and every check that asks for installed packages, so the host
silently stops receiving updates. Alerts when the database cannot be opened,
when reading it reports errors, and when it lists no packages at all. Requires
root or sudo.

options:
  -h, --help         show this help message and exit
  -V, --version      show program's version number and exit
  --always-ok        Always returns OK.
  --no-perfdata      Suppress the performance data section from the output.
                     The status message and the exit code are unaffected, so
                     alerting keeps working while trending data is dropped.
  --timeout TIMEOUT  Network timeout in seconds. Default: 60 (seconds)

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/rpm-database/
```


## Usage Examples

```bash
sudo ./rpm-database
```

Output on a healthy host:

```text
The RPM database lists 365 installed packages and was read in 90ms.
```

Output on a RHEL 8 host after a process was killed inside Berkeley DB:

```text
The RPM database cannot be read [WARNING].
* rpmdb: BDB0113 Thread/process 3210/140028918020992 failed: BDB1507 Thread died in Berkeley DB library
* db5 error(-30973) from dbenv->failchk: BDB0087 DB_RUNRECOVERY: Fatal error, run database recovery
* cannot open Packages index using db5 -  (-30973)
* cannot open Packages database in /var/lib/rpm
A process was killed while it was using the database, and its lock files were left behind. Reboot, which removes them, or make sure no rpm, dnf, yum or PackageKit process is running and remove them: `sudo rm --force /var/lib/rpm/__db.*`
```

Output on a RHEL 9 host whose SQLite database is damaged:

```text
The RPM database is damaged, only 89 packages could be read [WARNING].
* SELECT hnum, blob FROM 'Packages': 11: database disk image is malformed
Restore the database directory (`rpm --eval %_dbpath`) from a backup. Without one, `sudo rpm --rebuilddb` gets the package manager working again, but silently drops every package it cannot read, and each of those has to be registered again with `rpm --install --justdb` in the version that is installed.
```


## States

* OK if rpm lists at least one package and reports no error.
* OK if rpm only reports warnings, such as freeing the read locks of a process that died while reading. They are listed in the output.
* WARN if rpm exits non-zero or reports an `error:` line, also when it still lists some packages.
* WARN if the database lists no packages at all.
* WARN if rpm does not answer within `--timeout`.
* UNKNOWN if the check does not run as root.
* UNKNOWN if the OS family is neither Red Hat nor SUSE.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| packages | Number | Number of installed packages rpm could read from the database. |
| query_duration | Seconds | How long rpm took to list all packages. |


## Troubleshooting

### `BDB1507 Thread died in Berkeley DB library`

A process was killed while it was using the database, and the lock files of the database environment (`/var/lib/rpm/__db.*`) still refer to it. Every later access as root fails with `DB_RUNRECOVERY`, which stops dnf and yum. The packages themselves are intact, and removing the lock files is all it takes.

Red Hat recommends a reboot: it removes the lock files during boot, before anything can use the database. Where a reboot is not an option, make sure nothing uses the database and remove them by hand:

```bash
ps -ef | grep --extended-regexp 'rpm|dnf|yum|packagekit'
sudo lsof +D /var/lib/rpm
sudo rm --force /var/lib/rpm/__db.*
```

Then find out what got killed. A script or check whose timeout is too short for the first read of the database after a reboot is a common cause.

### Damaged database files

`database disk image is malformed`, `illegal page type or format` or `file is not a database`

The database files themselves are damaged. Restore the database directory from a backup. It is the only way back to the complete list of installed packages:

```bash
rpm --eval %_dbpath
```

Without a backup, copy the damaged directory aside and rebuild the database:

```bash
sudo cp --archive /var/lib/rpm /var/lib/rpm.damaged
sudo rpm --rebuilddb
```

The rebuild gets the package manager working again, but drops every package it cannot read without saying so, and afterwards this check reports OK on the shorter list. Compare `rpm --query --all` against another host of the same role and register each missing package again with `rpm --install --justdb`, in the version that is installed on disk. On RHEL 8, Red Hat's procedure in [How to rebuild RPM database on a Red Hat Enterprise Linux system?](https://access.redhat.com/solutions/6903) additionally passes the `Packages` file through `rpmdb_dump` and `rpmdb_load` before the rebuild.

### `The RPM database lists no installed packages`

rpm found an empty database where it expected the one of this host. Check that `rpm --eval %_dbpath` points to the right directory and that the directory has not been emptied, replaced or mounted over.

### `This check has to run as root`

Without root, rpm on RHEL 8 reads the database past the locks dnf and yum stumble over, and a broken database looks healthy. Deploy the sudoers file from [assets/sudoers](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/assets/sudoers) and let the monitoring agent call the check through `sudo`.

```bash
sudo /usr/lib64/nagios/plugins/rpm-database
```

### `Timeout after 60s while listing the installed packages`

rpm is waiting for a running package transaction, or the database is slow to read, which happens right after a reboot on slow storage. If it repeats on an idle host, raise `--timeout` and the command timeout of the monitoring server together, rather than lowering anything: on RHEL 8 a query that gets killed can break the database.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
