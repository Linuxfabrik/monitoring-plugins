# Check users


## Overview

Counts the sessions that `w` (Linux) or `query user` (Windows) lists, by type: tty (console) and pts (SSH on Linux, RDP on Windows). On Windows, also counts disconnected sessions (closed connections without logging out). Alerts when the number of sessions of a type reaches its threshold; by default, every console session warns.

**Important Notes:**

* The defaults are `--warning=1,20,1` and no `--critical`: any console session (tty) warns, 20 or more pts sessions warn, and on Windows any disconnected session warns
* The plugin counts sessions, not users: a user logged in twice counts twice. On RHEL 10, `w` also lists the per-user service manager (`systemd --user`) as a session without a terminal; the plugin leaves that line out of the count
* `--warning` and `--critical` need both values, `tty,pts`. `None` leaves a threshold out (`--critical=None,50`), an empty value is not accepted
* If running on physical hardware, consider using `--critical 1,20` (Linux) or `--critical 1,50,3` (Windows) as a starting point

**Data Collection:**

* On Linux: executes `/usr/bin/w` and parses its output, using the header line to determine column positions
* On Windows: executes `query user` and parses its output
* A *tty* is a native terminal device (on Windows: Console); a *pts* is a pseudo terminal slave, typically from SSH (on Windows: RDP)


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/users> |
| Nagios/Icinga Check Name              | `check_users` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | Yes |
| Requirements                          | `/usr/bin/w` on Linux, `query user` on Windows |


## Help

```text
usage: users [-h] [-V] [--always-ok] [-c CRIT] [--no-perfdata] [-w WARN]

Counts the sessions that `w` (Linux) or `query user` (Windows) lists, by type:
tty (console) and pts (SSH on Linux, RDP on Windows). On Windows, also counts
disconnected sessions (closed connections without logging out). Alerts when
the number of sessions of a type reaches its threshold; by default, every
console session warns.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  -c, --critical CRIT  Threshold for the number of tty and pts sessions, in
                       the format "tty,pts". Both values are required, `None`
                       leaves a threshold out. On Windows, you can
                       additionally specify a threshold for disconnected
                       sessions in the format "tty,pts,disc". Alerts when the
                       number reaches the threshold. Example:
                       `--critical=3,10`. Default: [None, None, None]
  --no-perfdata        Suppress the performance data section from the output.
                       The status message and the exit code are unaffected, so
                       alerting keeps working while trending data is dropped.
  -w, --warning WARN   Threshold for the number of tty and pts sessions, in
                       the format "tty,pts". Both values are required, `None`
                       leaves a threshold out. On Windows, you can
                       additionally specify a threshold for disconnected
                       sessions in the format "tty,pts,disc". Alerts when the
                       number reaches the threshold. Example: `--warning=1,5`.
                       Default: [1, 20, 1]

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/users/
```


## Usage Examples

On Linux, if one user is connected to the console:

```bash
./users --warning=1,20 --critical=1,20
```

Output:

```text
TTY: 1 [WARNING], PTS: 0

USER     TTY        LOGIN@   IDLE   JCPU   PCPU WHAT
markus.f :0         Mon06   ?xdm?  6:02m  0.03s /usr/libexec/gdm-x-session --run-script /usr/bin/gnome-session
```

On Linux, if one user is connected via SSH using IPv6 (no TTY allocated):

```bash
./users
```

Output:

```text
TTY: 0, PTS: 1

USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU  WHAT
clox              2001:db8::ff30   16:05   15:44m  0.00s   ?    sshd: clox [priv]
```

On Windows, if one user is connected via RDP:

```bash
./users --warning=1,20,1 --critical=None,50,5
```

Output:

```text
TTY: 0, PTS: 1, Disconnected: 0

USERNAME              SESSIONNAME        ID  STATE   IDLE TIME  LOGON TIME
administrator         rdp-tcp#11          1  Active          .  24.08.2022 17:42
```


## States

* OK if the number of sessions of each type is below its warning threshold.
* WARN if the number of tty, pts, or disconnected sessions is >= `--warning` (default: `1,20,1`, so any console session warns).
* CRIT if the number of tty, pts, or disconnected sessions is >= `--critical` (default: none).
* UNKNOWN if `--warning` or `--critical` does not have the format `tty,pts` (Windows: `tty,pts,disc`), or `w` fails.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| disc | Number | Number of disconnected sessions (Windows only) |
| pts | Number | Number of pts sessions (SSH on Linux, RDP on Windows) |
| tty | Number | Number of tty sessions (console on Linux, console on Windows) |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
