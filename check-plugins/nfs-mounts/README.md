# Check nfs-mounts


## Overview

Checks that every mounted NFS filesystem still answers, by asking each one for its filesystem statistics and giving it a deadline. Two failures are invisible to the disk usage, inode and read-only checks, because those only look at local block devices: a stale file handle, where the mount stays "active" while every access returns an error, and a mount whose server no longer answers, where an access blocks instead of failing. The blocking one is the more damaging of the two, because a waiting process only gets out of that wait by being killed and every further access piles up behind it. The check itself never blocks. Each mount is asked in a process of its own, all of them at the same time, and a process that misses the deadline is killed, so the runtime stays within `--timeout` no matter how many mounts are unreachable. Reading the list of mounts is safe on its own, so a host whose server is gone still reports which mounts are affected. No elevated privileges are needed: asking for filesystem statistics works even on an export the user is not allowed to enter. Supports filtering mount points by regular expression via `--match` and `--ignore`, and extended reporting via `--lengthy`. Alerts when a mount reports a stale file handle, misses the deadline, or answers with an error.

**Important Notes:**

* A mount that does not answer is reported CRIT by default, a stale file handle likewise. Both are configurable, see `--hung-severity` and `--stale-severity`.
* After the server comes back, the first access still has to wait for the client's connection to time out and be re-established. Measured on Rocky 10 with kernel 6.12, that took about 10 seconds, so the check can report the mount as not answering one more time before it goes green. This is what `max_check_attempts` and `retry_interval` are for; the shipped Icinga Director service template sets `retry_interval` to 60 seconds.
* A `soft` mount does not block, it returns an I/O error once it has given up. That is reported as an error and defaults to WARN, not CRIT, because the applications on the host keep running.
* Whether the right data is behind a mount, and how full it is, is not part of this check. Space and inodes are reported by `disk-usage` and `fs-inodes`, a filesystem that never got mounted at all by `fs-mounts`, and the health of the NFS server itself by the systemd unit checks in the NFS Server Service Set.
* A mount point named by `--ignore` is never asked anything, so excluding a mount that is known to be unreachable also takes it out of the check's runtime.
* The NFS Client Service Set runs this check on its own, without the systemd unit checks its server-side counterpart carries. On a client the kernel does the work and the userspace helpers are optional, so none of them says whether NFS works. Measured on Rocky 10 and Debian 13: `rpc-statd` runs only while an NFSv3 mount needs locking and is dead on a client that mounts NFSv4 only, `nfs-idmapd` is a server-side daemon and stays dead on the client, `rpc-gssd` starts only where a Kerberos keytab exists, `nfs-blkmap` is enabled on one distribution and disabled on the other, and `nfs-client.target` reaches "active" as soon as the NFS utilities are installed, even on a host where every mount failed. Whether the mounts answer is what this check reports.

**Data Collection:**

* Reads `/proc/self/mounts` for the mounted filesystems, and keeps those of type `nfs` (NFSv2 and NFSv3) and `nfs4` (every NFSv4 minor version). The kernel renders this file from its own structures and never asks the server, so reading it is safe while a server is unreachable
* Skips mount points matching `--ignore`, and looks only at those matching `--match` if that parameter is given
* Asks every remaining mount point for its filesystem statistics (`statvfs`), each in a child process of its own, all of them started before the first one is waited for
* Kills a child that has not answered by the deadline, which is `--timeout` seconds after the first one started, and reports its mount as not answering
* Reads the NFS version and whether the mount is `hard` or `soft` off the mount options, for the `--lengthy` table


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/nfs-mounts> |
| Nagios/Icinga Check Name              | `check_nfs_mounts` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |


## Help

```text
usage: nfs-mounts [-h] [-V] [--always-ok] [--brief]
                  [--error-severity {ok,warn,crit,unknown}]
                  [--hung-severity {ok,warn,crit,unknown}] [--ignore IGNORE]
                  [--lengthy] [--match MATCH]
                  [--no-match-severity {ok,warn,crit,unknown}] [--no-perfdata]
                  [--stale-severity {ok,warn,crit,unknown}]
                  [--timeout TIMEOUT]

Checks that every mounted NFS filesystem still answers, by asking each one for
its filesystem statistics and giving it a deadline. Two failures are invisible
to the disk usage, inode and read-only checks, because those only look at
local block devices: a stale file handle, where the mount stays "active" while
every access returns an error, and a mount whose server no longer answers,
where an access blocks instead of failing. The blocking one is the more
damaging of the two, because a waiting process only gets out of that wait by
being killed and every further access piles up behind it. The check itself
never blocks. Each mount is asked in a process of its own, all of them at the
same time, and a process that misses the deadline is killed, so the runtime
stays within --timeout no matter how many mounts are unreachable. Reading the
list of mounts is safe on its own, so a host whose server is gone still
reports which mounts are affected. No elevated privileges are needed: asking
for filesystem statistics works even on an export the user is not allowed to
enter. Supports filtering mount points by regular expression via --match and
--ignore, and extended reporting via --lengthy. Alerts when a mount reports a
stale file handle, misses the deadline, or answers with an error.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --brief               Hide the rows that are within the thresholds and show
                        only those in a WARN or CRIT state. Perfdata and
                        alerting are unaffected: every item still emits
                        performance data and still drives the overall check
                        state, so this is safe to leave on.
  --error-severity {ok,warn,crit,unknown}
                        State to report for a mount that answers with an error
                        other than a stale file handle, for example the I/O
                        error a `soft` mount reports once it has given up on
                        its server. Default: warn
  --hung-severity {ok,warn,crit,unknown}
                        State to report for a mount that does not answer
                        within --timeout. A `hard` mount blocks instead of
                        failing, so this is what an unreachable server looks
                        like, and a process waiting on such a mount only gets
                        out of that wait by being killed. Default: crit
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
  --stale-severity {ok,warn,crit,unknown}
                        State to report for a mount that answers with a stale
                        file handle. The export it points at is gone, and the
                        mount does not recover on its own. Default: crit
  --timeout TIMEOUT     Network timeout in seconds. Every mount is asked at
                        the same time and they share one deadline, so this is
                        the runtime of the whole check and not a budget per
                        mount. Default: 8 (seconds)

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/nfs-mounts/
```


## Usage Examples

```bash
./nfs-mounts
```

Output:

```text
Everything is ok. 3 NFS mounts respond, slowest 351ms.

Mountpoint  ! Source                          ! State
------------+---------------------------------+---------
/mnt/data   ! nfs1.example.com:/export/data   ! responds
/mnt/home   ! nfs1.example.com:/export/home   ! responds
/mnt/backup ! nfs2.example.com:/export/backup ! responds
```

Output (with an export that is gone from the server):

```text
1 of 2 NFS mounts is not usable: /mnt/gone (nfs1.example.com:/export/gone): stale file handle
Hint: a stale file handle needs the export back on the server and the mount unmounted and mounted again.

Mountpoint ! Source                        ! State
-----------+-------------------------------+-----------------------------
/mnt/data  ! nfs1.example.com:/export/data ! responds
/mnt/gone  ! nfs1.example.com:/export/gone ! stale file handle [CRITICAL]
```

Output (with a server that no longer answers):

```text
2 of 2 NFS mounts are not usable:
* /mnt/data (nfs1.example.com:/export/data): no answer within 8s
* /mnt/home (nfs1.example.com:/export/home): no answer within 8s
Hint: a mount that does not answer blocks every access to it until its server is back, and a process that is waiting only gets out of that wait by being killed.

Mountpoint ! Source                        ! State
-----------+-------------------------------+-------------------------------
/mnt/data  ! nfs1.example.com:/export/data ! no answer within 8s [CRITICAL]
/mnt/home  ! nfs1.example.com:/export/home ! no answer within 8s [CRITICAL]
```

Extended reporting, adding the NFS version, whether the mount blocks or gives up, and how long it took to answer:

```bash
./nfs-mounts --lengthy
```

Output:

```text
Everything is ok. 3 NFS mounts respond, slowest 351ms.

Mountpoint  ! Source                          ! Vers ! Mode ! Response ! State
------------+---------------------------------+------+------+----------+---------
/mnt/data   ! nfs1.example.com:/export/data   ! 4.2  ! hard ! 4ms      ! responds
/mnt/home   ! nfs1.example.com:/export/home   ! 4.2  ! hard ! 6ms      ! responds
/mnt/backup ! nfs2.example.com:/export/backup ! 3    ! hard ! 351ms    ! responds
```

On a host with many NFS mounts, `--brief` keeps the table down to the ones that are not usable:

```bash
./nfs-mounts --lengthy --brief
```

Output:

```text
3 of 4 NFS mounts are not usable:
* /mnt/gone (nfs1.example.com:/export/gone): stale file handle
* /mnt/backup (nfs2.example.com:/export/backup): no answer within 8s
* /mnt/scratch (nfs3.example.com:/export/scratch): input/output error
Hint: a mount that does not answer blocks every access to it until its server is back, and a process that is waiting only gets out of that wait by being killed; a stale file handle needs the export back on the server and the mount unmounted and mounted again.

Mountpoint   ! Source                           ! Vers ! Mode ! Response ! State
-------------+----------------------------------+------+------+----------+-------------------------------
/mnt/gone    ! nfs1.example.com:/export/gone    ! 4.2  ! hard ! 3ms      ! stale file handle [CRITICAL]
/mnt/backup  ! nfs2.example.com:/export/backup  ! 3    ! hard ! 8.0s     ! no answer within 8s [CRITICAL]
/mnt/scratch ! nfs3.example.com:/export/scratch ! 4.2  ! soft ! 5.0s     ! input/output error [WARNING]
```

Give the mounts less time, for a check that has to return quickly:

```bash
./nfs-mounts --timeout=4
```

Ignore an archive share that is known to be offline outside business hours, so that it neither alerts nor costs the check its deadline:

```bash
./nfs-mounts --ignore='^/mnt/archive'
```

Report a mount that does not answer as a warning instead, on a host where NFS is not on the critical path:

```bash
./nfs-mounts --hung-severity=warn --stale-severity=warn
```


## States

* OK if every checked mount answers.
* OK if the host has no NFS mounts at all.
* OK if `--match` and `--ignore` dropped every mount point. The output says how many the host carries and which parameter dropped them. `--no-match-severity` raises that case to WARN, CRIT or UNKNOWN.
* CRIT if a mount does not answer within `--timeout`. `--hung-severity` lowers or raises that case.
* CRIT if a mount reports a stale file handle. `--stale-severity` lowers or raises that case.
* WARN if a mount answers with any other error, for example the I/O error a `soft` mount reports once it has given up. `--error-severity` lowers or raises that case.
* UNKNOWN if the host does not provide `/proc/self/mounts`.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name                       | Type    | Description |
|----------------------------|---------|-------------|
| nfs_mounts_total           | Number  | Number of NFS mounts that were checked, after filtering. |
| nfs_mounts_hung            | Number  | Number of those that did not answer within `--timeout`. |
| nfs_mounts_stale           | Number  | Number of those that reported a stale file handle. |
| nfs_mounts_failed          | Number  | Number of those that answered with any other error. |
| nfs_mounts_slowest_seconds | Seconds | How long the slowest mount took to answer. Rises long before a failing server stops answering altogether. |


## Troubleshooting

### `no answer within 8s`

The server behind that mount is not answering, and because the mount is `hard`, every access to it waits instead of failing. Processes that touch it end up in uninterruptible sleep, shown as state `D` by `ps`. That sleep ends only for a signal that would terminate the process anyway, so `kill` and `kill -9` both get such a process out of it, while Ctrl+C does not reach a program that handles the interrupt itself. Measured on Rocky 10 with kernel 6.12: SIGTERM and SIGKILL both ended the wait immediately, SIGINT left the process sleeping.

Find out whether the server is reachable at all, and on the NFS port:

```bash
ping -c 3 nfs1.example.com
```

```bash
rpcinfo -t nfs1.example.com nfs 4
```

A server that answers `ping` but not `rpcinfo` is up while its NFS service is not, which looks exactly the same from the client: the mount blocks either way. Note that a closed port does not make a `hard` mount fail, it makes it wait, so a stopped NFS service is as bad for the client as a powered-off server.

The mount recovers on its own once the server answers again, without an unmount. Give it a moment: the client's connection has to time out and be re-established first, which takes several seconds.

Do not try to `umount` a mount that is blocking. The unmount blocks too. `umount --force` is for NFS specifically and often still is not enough; `umount --lazy` detaches the mount point right away and lets the pending accesses drain, which is what an unmount that has to succeed should use:

```bash
umount --lazy /mnt/data
```


### `stale file handle`

The mount points at an export the server no longer has under that identity, which usually means the exported directory was deleted and recreated, the export was removed from `/etc/exports`, or the server was reinstalled. Unlike a mount that does not answer, this one fails immediately rather than blocking, so the host stays usable while the data is not.

It does not heal by itself. Put the export back on the server, then remount on the client:

```bash
exportfs -v
```

```bash
umount /mnt/gone && mount /mnt/gone
```

If the unmount reports the mount point as busy, find what is still holding it:

```bash
lsof +D /mnt/gone
```


### `input/output error`

A `soft` mount reports this once it has given up on its server, so the finding is the same as a mount that does not answer: the server is not reachable. The difference is only in how the mount was configured, and it is why this defaults to WARN rather than CRIT. Chase it the same way as `no answer within 8s` above.

Be aware that `soft` trades a blocked process for a failed write. On a filesystem holding data that must not be lost, `hard` is the safer option, and this check is then the thing that tells you the server is gone.


### The check reports one more failure right after the server came back

That is expected, see the first troubleshooting entry: the client's connection has to time out before the mount answers again, which took about 10 seconds when measured. Raise `max_check_attempts` or `retry_interval` on the service if a single such run is enough to notify.


### A mount is missing from the output

Only mounts of type `nfs` and `nfs4` are checked, and only those the kernel currently reports. Compare against what is really mounted:

```bash
findmnt --types nfs,nfs4
```

A mount point that is not in that list is not mounted, which is what `fs-mounts` reports. An automounter mount point that has not been triggered yet is not mounted either, and is deliberately left alone: asking it for its statistics would trigger the mount.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
