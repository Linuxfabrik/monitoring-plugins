# Check needs-restarting


## Overview

Reports what on this host is still running the code it had before the last update: processes that were started before they or one of their dependencies were replaced, and a kernel or core library that only a full reboot puts into service. A machine that was patched and not restarted keeps running the old code, vulnerabilities included, and nothing on it says so by itself. The reboot and the individual services are reported apart, because they are fixed by different things. A grace period holds the alert back for as long as a host is allowed to take between its updates and its reboot. Alerts when a reboot is pending and when a running process needs a restart. Requires root or sudo.

**Important Notes:**

* **Requires root, and refuses to guess without it.** Both tools need root to see the processes of other users. `needrestart` does not say so: run without privileges it prints its version line, nothing else, and exits 0, which is indistinguishable from a clean host. The check therefore insists on root and returns UNKNOWN instead of reporting such a run as OK.
* **A pending service restart is not a pending reboot.** On the Debian family the two come from different fields, and only the kernel state (`NEEDRESTART-KSTA` together with the running and installed kernel version) decides the reboot. Five services running replaced libraries on a host whose kernel is current need `systemctl restart`, not a maintenance window.
* **The grace period is off by default.** `--grace-wait` starts when a pending restart is first seen, separately for the reboot and for each service, and starts over once that entry is gone. The plugin defaults to `0D`, so a run from the command line reports what is pending right now; the Icinga Director template carries the site policy of four hours.
* **What is pending is always reported, only the state waits.** A finding inside its grace period is counted and named in the summary; it just does not raise the state yet.
* **Red Hat and Debian answer different questions.** `needs-restarting --reboothint` names the core packages replaced since boot, and its exit code is the reboot verdict. `needrestart` compares the running kernel against the installed one and lists the services. The check reads both for what they are.
* **On the Debian family `/run/reboot-required` is written by `reboot-notifier`**, which a minimal installation does not have. It is read as an additional signal where it exists, never as a substitute for `needrestart`.
* Related checks: `deb-updates` and `rpm-updates` report what is waiting to be installed, this one what is waiting to be put into service afterwards.

**Data Collection:**

* Red Hat family: `needs-restarting --reboothint` for the reboot verdict, then `needs-restarting` for the processes still running replaced code
* Debian family: `needrestart -b`, plus `/run/reboot-required` where a package left it behind
* The tool is resolved through `PATH` first and then in the place it is installed in, because `needrestart` lives in `/usr/sbin`
* Remembers since when each pending restart has been pending, in a local SQLite database, so `--grace-wait` can hold the alert back
* Requires root or sudo


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/needs-restarting> |
| Nagios/Icinga Check Name              | `check_needs_restarting` |
| Check Interval Recommendation         | Every hour |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |
| Requirements                          | command-line tool `needs-restarting` (package `yum-utils`) on the Red Hat family, `needrestart` on the Debian family; User with higher permissions |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-needs-restarting.db` |


## Help

```text
usage: needs-restarting [-h] [-V] [--always-ok] [--grace-wait GRACE_WAIT]

Reports what on this host is still running the code it had before the last
update: processes that were started before they or one of their dependencies
were replaced, and a kernel or core library that only a full reboot puts into
service. A machine that was patched and not restarted keeps running the old
code, vulnerabilities included, and nothing on it says so by itself. The
reboot and the individual services are reported apart, because they are fixed
by different things. A grace period holds the alert back for as long as a host
is allowed to take between its updates and its reboot. Alerts when a reboot is
pending and when a running process needs a restart. Requires root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --grace-wait GRACE_WAIT
                        How long a pending restart is tolerated before it
                        counts towards the state. Set this to cover the time a
                        host needs between taking its updates and rebooting,
                        so a machine that is already scheduled for a reboot
                        stays quiet until it has had its chance. Starts when
                        the pending restart is first seen, separately for the
                        reboot and for each service, and starts over once that
                        entry is gone. A duration such as `12h`, `8D` or `2W`;
                        `0D` disables the grace period. Default: 0D

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/needs-restarting/
```


## Usage Examples

```bash
sudo ./needs-restarting
```

Output on a host that was patched and not rebooted:

```text
A reboot is pending. 7 running processes need a restart.
replaced since boot: dbus-broker, glibc, kernel, kernel-core, linux-firmware, microcode_ctl, systemd
* /usr/lib/systemd/systemd --system --deserialize=73
* /usr/lib/systemd/systemd-userdbd
* /usr/bin/dbus-broker-launch --scope system --audit
* /usr/lib/systemd/systemd-logind
* /usr/sbin/NetworkManager --no-daemon
Schedule the reboot. Until it happens the host keeps running the old kernel and the old core libraries, so a fix that came with the update is not in effect. `--grace-wait` holds this back for as long as a host is allowed to take between its updates and its reboot.
Restart the listed services, which puts them on the libraries that are now installed: `systemctl restart dbus.service` for each of them, or let the configuration management do it. On the Debian family `needrestart -r a` restarts all of them in one go.
```

Output on a Debian host whose kernel is current and whose services are not:

```text
5 running processes need a restart.
* cron.service
* dbus.service
* getty@tty1.service
* ifup@enp1s0.service
* systemd-logind.service
Restart the listed services, which puts them on the libraries that are now installed: `systemctl restart dbus.service` for each of them, or let the configuration management do it. On the Debian family `needrestart -r a` restarts all of them in one go.
```

Give a host four hours between its patch run and its reboot before the check says anything:

```bash
sudo ./needs-restarting --grace-wait=4h
```

While the grace period is running, the check reports what is pending and stays OK:

```text
5 pending restarts, all within the grace period (4h), the oldest for 12m 4s.
```

Once part of it is due, the summary names both:

```text
A reboot is pending. 2 more within the grace period (4h), the oldest for 8m 31s.
```

Output on a host where nothing is waiting:

```text
No reboot and no service restart pending.
```


## States

* OK if no reboot and no service restart is pending.
* OK while every pending restart is still within `--grace-wait`. The summary counts them and names the age of the oldest.
* WARN if a reboot is pending and past its grace period. On the Red Hat family that is `needs-restarting --reboothint` returning non-zero, on the Debian family a kernel state of 2 or 3.
* WARN if a running process needs a restart and is past its grace period.
* UNKNOWN if the check does not run as root. Without it the tools answer with nothing at all, which is not the same as nothing being pending.
* UNKNOWN if the tool is not installed, or cannot be run.
* UNKNOWN if the OS family is neither Red Hat nor Debian.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

There is no perfdata. What this check reports is a list of things to act on, not a number to trend; how many services are waiting says nothing about the host that the list does not say better.


## Troubleshooting

### `This check has to run as root to see what needs restarting`

Both tools need root, and one of them fails quietly without it: `needrestart` run as an ordinary user prints its version line, nothing else, and exits 0. Deploy the sudoers file from [assets/sudoers](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/assets/sudoers) and let the monitoring agent call the check through `sudo`.

```bash
sudo /usr/lib64/nagios/plugins/needs-restarting
```

### `needrestart is not installed`

The Debian family does not ship it by default, and without it nothing on the host reports which services are running replaced libraries.

```bash
apt install needrestart
```

`/run/reboot-required` is not a substitute: it is written by `reboot-notifier`, which a minimal installation does not have either, and it says nothing about individual services.

### `needs-restarting is not installed`

On the Red Hat family the tool comes with `yum-utils`, which a minimal installation leaves out.

```bash
dnf install yum-utils
```

### The check keeps warning although the services were restarted

A process that was restarted drops off the list on the next run, so a finding that stays means the process is still the old one. `systemctl restart` on the unit is not always enough: a process started outside systemd, or a session that is still open, keeps the old libraries mapped.

```bash
sudo needs-restarting
sudo needrestart -b
```

On the Debian family `needrestart -r a` restarts everything it lists in one go.

### A host reports a pending reboot right after its patch run, every time

That is what `--grace-wait` is for. Set it to cover the time between the patch window and the reboot window, and the check stays quiet over that span while still reporting what is pending:

```bash
sudo ./needs-restarting --grace-wait=4h
```

The Icinga Director template ships that value. The clock starts when the pending restart is first seen and starts over once it is gone, so a host that reboots on schedule never alerts.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
