# Check nfs-exports


## Overview

Checks that an NFS server really exports what it is configured to export, and that every path it exports is there. The daemons say nothing about this: they keep running while the export table is empty, so a share that was added but never reloaded, and one whose directory has gone, both leave a server that looks healthy and serves nothing. A client only finds out when it tries to mount, or when its mount turns into a stale file handle. The check compares the export files against the table the server actually serves, and looks whether each exported path exists and sits on the filesystem it is meant for. An export below a filesystem that `/etc/fstab` lists and that is not mounted serves the directory underneath instead, and one carrying the `mp` or `mountpoint` option is refused by the server until the filesystem named there is mounted. An export the table has but the files do not is reported and does not alert by default, because that is what cluster software creating exports at runtime looks like. Nothing is asked over the network and no elevated privileges are needed: all of it is read from files. The paths are looked at under a deadline, so an export that sits on a filesystem which has stopped answering cannot hold the check up. Supports filtering export paths by regular expression via `--match` and `--ignore`. Alerts when a configured export is not served, or when a served export has no path or does not reach its filesystem.

**Important Notes:**

* This check answers whether the exports are right. Whether the daemons run is what the systemd unit checks in the same Service Set answer, and they do: stopping `nfs-server` takes `nfs-mountd` and `nfs-idmapd` down with it, and each of the three reports it.
* The counterpart on the client is `nfs-mounts`. An export whose path has gone is what a client sees as a stale file handle, so the same incident shows up there as well; this check names the cause on the server instead of the symptom on every client.
* An export whose filesystem failed to mount does not fail: the server serves the empty directory underneath it, clients see missing files, and what they write lands on the filesystem below. The check reports that for every filesystem `/etc/fstab` lists, `noauto` entries included. A filesystem mounted some other way, such as a ZFS dataset or a systemd mount unit, has no entry there and can only be covered with the `mp` export option, which makes the server refuse the export instead of serving the wrong directory.
* Only the presence of an export is compared, not its options. The table holds them fully expanded, with every default the server filled in, so comparing them against what an administrator wrote would report a difference on every line. Use `exportfs -v` to look at the effective options. The one option the check evaluates is `mp` / `mountpoint`: it runs the same mount point test the server runs before it answers a client, so an export the table lists and the server refuses is reported as such.
* An export whose path is on a network filesystem is looked at under `--timeout` like every other, so a re-exported share whose own server is gone does not hold the check up.

**Data Collection:**

* Reads `/etc/exports` and the files below `/etc/exports.d` for what is configured. Only a name ending in `.exports`, longer than that suffix and not starting with a dot counts, and the directory is walked in version order, which is what `exportfs` does
* Reads the export table at `/var/lib/nfs/etab` for what the server really serves. That file is what `exportfs` writes and what the server reads, it is world readable, and reading it cannot block the way asking the server over RPC could. `--etab` points the check at it if the state directory of the NFS utilities was moved
* Understands the export file the way the NFS utilities do: full-line and trailing comments, an entry continued over several lines with a trailing backslash, double quotes around a path holding a space, a backslash and three octal digits standing for a byte, and both `path client(options)` and `path -options client client`
* Looks whether each served export path exists, all of them at the same time and under one shared deadline. In the same look, a path the `mp` or `mountpoint` option names counts as a mount point if it and its parent are on different devices, which is the test the NFS server applies. A bind mount of a directory onto itself is therefore no mount point, for the server and for the check alike
* Reads `/etc/fstab` and `/proc/self/mountinfo` to find the filesystem each export is meant to be on, which is the deepest mount point covering its path, `/` aside. An fstab entry the kernel does not report has its symlinks resolved before it counts as not mounted
* Skips export paths matching `--ignore`, and looks only at those matching `--match` if that parameter is given


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/nfs-exports> |
| Nagios/Icinga Check Name              | `check_nfs_exports` |
| Check Interval Recommendation         | Every 15 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |


## Help

```text
usage: nfs-exports [-h] [-V] [--always-ok] [--brief] [--etab ETAB]
                   [--ignore IGNORE] [--match MATCH]
                   [--missing-path-severity {ok,warn,crit,unknown}]
                   [--no-match-severity {ok,warn,crit,unknown}]
                   [--no-perfdata]
                   [--not-exported-severity {ok,warn,crit,unknown}]
                   [--not-mounted-severity {ok,warn,crit,unknown}]
                   [--timeout TIMEOUT]
                   [--unconfigured-severity {ok,warn,crit,unknown}]

Checks that an NFS server really exports what it is configured to export, and
that every path it exports is there. The daemons say nothing about this: they
keep running while the export table is empty, so a share that was added but
never reloaded, and one whose directory has gone, both leave a server that
looks healthy and serves nothing. A client only finds out when it tries to
mount, or when its mount turns into a stale file handle. The check compares
the export files against the table the server actually serves, and looks
whether each exported path exists and sits on the filesystem it is meant for.
An export below a filesystem that /etc/fstab lists and that is not mounted
serves the directory underneath instead, and one carrying the `mp` or
`mountpoint` option is refused by the server until the filesystem named there
is mounted. An export the table has but the files do not is reported and does
not alert by default, because that is what cluster software creating exports
at runtime looks like. Nothing is asked over the network and no elevated
privileges are needed: all of it is read from files. The paths are looked at
under a deadline, so an export that sits on a filesystem which has stopped
answering cannot hold the check up. Supports filtering export paths by regular
expression via --match and --ignore. Alerts when a configured export is not
served, or when a served export has no path or does not reach its filesystem.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --brief               Hide the rows that are within the thresholds and show
                        only those in a WARN or CRIT state. Perfdata and
                        alerting are unaffected: every item still emits
                        performance data and still drives the overall check
                        state, so this is safe to leave on.
  --etab ETAB           Path to the export table the server serves, which is
                        where the state directory of the NFS utilities was
                        moved to if it was moved at all. Default:
                        /var/lib/nfs/etab
  --ignore IGNORE       Any item matching this Python regex will be ignored.
                        Can be specified multiple times. Example:
                        `(?i)linuxfabrik` for a case-insensitive match.
  --match MATCH         Filter by this Python regular expression. Case-
                        sensitive by default; use `(?i)` for case-insensitive
                        matching. Can be specified multiple times. If both
                        `--match` and `--ignore` are given, an item must match
                        `--match` AND not match `--ignore` to be reported
                        (include first, exclude second). Examples:
                        `(?i)example` to match "example" regardless of case.
                        `^(?!.*example).*$` to match any string except
                        "example" (negative lookahead).
  --missing-path-severity {ok,warn,crit,unknown}
                        State to report for an export whose path does not
                        exist. The server keeps serving it, and a client that
                        has it mounted gets a stale file handle. Default: warn
  --no-match-severity {ok,warn,crit,unknown}
                        State to report when no item matches the filters and
                        nothing is checked. Default: ok
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --not-exported-severity {ok,warn,crit,unknown}
                        State to report for an export the configuration asks
                        for and the server does not serve. Usually `exportfs
                        -ra` has not been run since the entry was added, or it
                        refused the entry; a client cannot mount such a share
                        at all. Default: warn
  --not-mounted-severity {ok,warn,crit,unknown}
                        State to report for an export that does not reach the
                        filesystem it is meant for. Either its path lies below
                        a filesystem /etc/fstab lists and that is not mounted,
                        so the server serves the directory underneath and
                        writes land on the wrong filesystem, or the export
                        carries the `mp` or `mountpoint` option and the server
                        refuses it to every client because the path named
                        there is not a mount point. Default: warn
  --timeout TIMEOUT     How long the export paths get to answer before they
                        are reported as unreachable. Only a path on a network
                        filesystem ever needs it: one whose server has stopped
                        answering does not fail, it blocks. Every path is
                        looked at at the same time and they share one
                        deadline, so this is the runtime of the whole check
                        and not a budget per path. Default: 8 (seconds)
  --unconfigured-severity {ok,warn,crit,unknown}
                        State to report for an export the server serves and
                        the configuration does not ask for. Cluster software
                        that creates its exports at runtime looks exactly like
                        this, which is why it does not alert by default.
                        Default: ok

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/nfs-exports/
```


## Usage Examples

```bash
./nfs-exports
```

Output:

```text
Everything is ok. 3 NFS exports are served.

Path             ! Source                        ! Clients          ! State
-----------------+-------------------------------+------------------+---------
/srv/nfs/backup  ! /etc/exports                  ! 192.168.100.0/24 ! exported
/srv/nfs/data    ! /etc/exports                  ! 192.168.100.0/24 ! exported
/srv/nfs/fromdir ! /etc/exports.d/10-lab.exports ! 192.168.100.0/24 ! exported
```

Output (with an entry that was added to `/etc/exports` and never put into effect):

```text
1 of 3 NFS exports is not right: /srv/nfs/forgotten: configured but not exported
Hint: an export the server does not serve cannot be mounted at all, and `exportfs -ra` is what puts the configuration into effect and names the entries it refuses.

Path               ! Source       ! Clients          ! State
-------------------+--------------+------------------+--------------------------------------
/srv/nfs/data      ! /etc/exports ! 192.168.100.0/24 ! exported
/srv/nfs/forgotten ! /etc/exports ! 192.168.100.0/24 ! configured but not exported [WARNING]
/srv/nfs/home      ! /etc/exports ! 192.168.100.0/24 ! exported
```

Output (with an export whose directory has gone):

```text
1 of 2 NFS exports is not right: /srv/nfs/vanish: path does not exist
Hint: an export whose path is gone keeps being served, and every client that has it mounted gets a stale file handle until the path is back.

Path            ! Source       ! Clients          ! State
----------------+--------------+------------------+------------------------------
/srv/nfs/data   ! /etc/exports ! 192.168.100.0/24 ! exported
/srv/nfs/vanish ! /etc/exports ! 192.168.100.0/24 ! path does not exist [WARNING]
```

Output (with an export whose filesystem did not mount, and one with the `mp` option whose path is no mount point):

```text
2 of 3 NFS exports are not right:
* /srv/nfs/data: /srv/nfs is not mounted, the directory underneath is served
* /srv/scratch: path is not a mount point, the export is refused
Hint: an export with the `mp` or `mountpoint` option is refused to every client until the path named there is a mount point again; an export below a filesystem that is not mounted serves the directory underneath it, so clients see the wrong files and their writes land on the wrong filesystem; the `mp` export option makes the server refuse such an export instead; `sudo mount --all --verbose` mounts what /etc/fstab lists and names what fails.

Path          ! Source       ! Clients      ! State
--------------+--------------+--------------+----------------------------------------------------------------------
/srv/local    ! /etc/exports ! 192.0.2.0/24 ! exported
/srv/nfs/data ! /etc/exports ! 192.0.2.0/24 ! /srv/nfs is not mounted, the directory underneath is served [WARNING]
/srv/scratch  ! /etc/exports ! 192.0.2.0/24 ! path is not a mount point, the export is refused [WARNING]
```

An export the server serves and no file asks for is what `exportfs -o ...` and cluster software look like. The Source column names `exportfs` for it, and it does not alert:

```text
Everything is ok. 2 NFS exports are served.

Path           ! Source       ! Clients          ! State
---------------+--------------+------------------+----------------------------
/srv/nfs/adhoc ! exportfs     ! 192.168.100.0/24 ! exported but not configured
/srv/nfs/data  ! /etc/exports ! 192.168.100.0/24 ! exported
```

On a server with many exports, `--brief` keeps the table down to the ones that are not right:

```bash
./nfs-exports --brief
```

Alert on an export nobody configured, on a server where nothing is supposed to create exports at runtime:

```bash
./nfs-exports --unconfigured-severity=warn
```

Treat a share that cannot be mounted as critical:

```bash
./nfs-exports --not-exported-severity=crit
```

Ignore a share that is exported only while a backup runs:

```bash
./nfs-exports --ignore='^/srv/backup'
```


## States

* OK if every configured export is served and every served export has its path on the filesystem it is meant for.
* OK if the host is configured to export nothing and exports nothing.
* OK for an export the server serves that no file asks for. `--unconfigured-severity` raises that case.
* OK if `--match` and `--ignore` dropped every export. The output says how many the host carries and which parameter dropped them. `--no-match-severity` raises that case to WARN, CRIT or UNKNOWN.
* WARN if an export is configured and not served. `--not-exported-severity` lowers or raises that case.
* WARN if a served export has no path, or if its path did not answer within `--timeout`. `--missing-path-severity` lowers or raises both.
* WARN if a served export lies below a filesystem `/etc/fstab` lists and the kernel has not mounted, or if it carries the `mp` or `mountpoint` option and the path named there is no mount point. `--not-mounted-severity` lowers or raises both.
* UNKNOWN if the host has neither `/etc/exports` nor an export table, which means the check is not on an NFS server.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name                      | Type   | Description |
|---------------------------|--------|-------------|
| nfs_exports_configured    | Number | Number of export paths the configuration asks for. |
| nfs_exports_served        | Number | Number of export paths the server really serves. |
| nfs_exports_not_exported  | Number | Number of configured exports the server does not serve. |
| nfs_exports_missing_path  | Number | Number of served exports whose path does not exist or did not answer. |
| nfs_exports_not_mounted   | Number | Number of served exports below a filesystem that is not mounted, or whose `mp` or `mountpoint` option is not met. |
| nfs_exports_unconfigured  | Number | Number of served exports no file asks for. |


## Troubleshooting

### `configured but not exported`

The entry is in `/etc/exports` or below `/etc/exports.d`, and the server does not serve it, so a client cannot mount that share at all. Put the configuration into effect and read what it says:

```bash
exportfs -ra
```

`exportfs` names every entry it refuses, and the usual reason is that the directory is not there yet, which it reports as `Failed to stat /your/export: No such file or directory`. An entry it refuses stays out of the table while every other one goes in, so the rest of the server keeps working and only that share is missing.

If `exportfs -ra` reports nothing and the export is still missing, look for a typo in the path, and remember that the files below `/etc/exports.d` are only read when their name ends in `.exports`.


### `path does not exist`

The server keeps serving an export whose directory is gone. Clients that have it mounted get a stale file handle on every access, and a client that mounts it fresh gets an empty directory or an error. The export table is not revalidated, so nothing on the server notices on its own.

The usual cause is that the filesystem the export lives on is not mounted, which `fs-mounts` reports separately. Check that first:

```bash
findmnt /your/export
```

Once the path is back, put the table in order again:

```bash
exportfs -ra
```

If the directory is gone for good, remove its entry from `/etc/exports` and run `exportfs -ra`, otherwise the stale entry survives every reload.


### Export below a filesystem that is not mounted

`/srv/nfs is not mounted, the directory underneath is served`

The filesystem `/etc/fstab` lists for the export is not mounted, so the server serves the directory it would have covered. Clients see that directory's content, usually nothing, and what they write lands on the filesystem below, often the root filesystem. Find out why it is not mounted and mount it:

```bash
sudo mount --all --verbose
findmnt --verify
```

Whatever clients wrote in the meantime went into the directory underneath. Mounting the filesystem hides those files rather than removing them, so move them aside before mounting, or reach them afterwards through a bind mount of the parent filesystem (`sudo mount --bind / /mnt`).

To keep this from happening again, add the `mp` option to the export in `/etc/exports` and run `sudo exportfs -ra`. The server then refuses the export while the filesystem is missing, which the check reports as `path is not a mount point, the export is refused`.


### Export refused because its `mp` option is not met

`path is not a mount point, the export is refused`

The export carries the `mp` or `mountpoint` option, so the server serves it only while the path named there (the export path itself for a bare `mp`) is a mount point. It is not, so every client is refused. Mount the filesystem, then check that it is there:

```bash
sudo mount --all --verbose
findmnt /your/export
```

A bind mount of a directory onto itself does not count as a mount point for the server, because it stays on the same device.


### `exported but not configured`

The server serves an export that no file asks for, which is what `exportfs -o ...` on the command line and cluster software creating exports at runtime both look like. It does not alert by default for exactly that reason.

On a server where nothing is supposed to create exports at runtime, this is a leftover: it disappears on the next reboot and takes its share with it. Write it into `/etc/exports` if it is meant to stay, or drop it:

```bash
exportfs -u <client>:/your/export
```

Set `--unconfigured-severity=warn` on such a server so the case is reported rather than only listed.


### `path did not answer within 8s`

The export lives on a filesystem that has stopped answering, which on a re-exported NFS share means its own server is gone. The check gives up on it rather than waiting, so the rest of the exports are still reported. `nfs-mounts` is the check that reports such a mount on this host.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
