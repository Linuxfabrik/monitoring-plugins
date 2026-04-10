# Check users

## Overview

Counts the number of currently logged-in users by session type: tty (console) and pts (SSH on Linux, RDP on Windows). On Windows, also counts disconnected sessions (closed connections without logging out).

**Data Collection:**

* On Linux: executes `/usr/bin/w` and parses its output, using the header line to determine column positions
* On Windows: executes `query user` and parses its output
* A *tty* is a native terminal device (on Windows: Console); a *pts* is a pseudo terminal slave, typically from SSH (on Windows: RDP)

**Important Notes:**

* If running on physical hardware, consider using `--critical 1,20` (Linux) or `--critical 1,50,3` (Windows) as a starting point

**Compatibility:**

* Cross-platform: Linux (requires `/usr/bin/w`) and Windows (requires `query user`)


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/users> |
| Nagios/Icinga Check Name              | `check_users` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | Yes |
| Requirements                          | `/usr/bin/w` on Linux, `query user` on Windows |


## Help

```text
usage: users [-h] [-V] [-c CRIT] [--test TEST] [-w WARN]

Counts the number of currently logged-in users by session type: tty (console)
and pts (SSH on Linux, RDP on Windows). On Windows, also counts disconnected
sessions (closed connections without logging out). Alerts when the total user
count exceeds the configured thresholds.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  -c, --critical CRIT  Threshold for logged-in tty/pts users, in the format
                       "tty,pts". On Windows, you can additionally specify a
                       threshold for disconnected users in the format
                       "tty,pts,disc". Example: `--critical 3,10`. Default:
                       [None, None, None]
  --test TEST          For unit tests. Needs "path-to-stdout-file,path-to-
                       stderr-file,expected-retc".
  -w, --warning WARN   Threshold for logged-in tty/pts users, in the format
                       "tty,pts". On Windows, you can additionally specify a
                       threshold for disconnected users in the format
                       "tty,pts,disc". Example: `--warning 1,5`. Default: [1,
                       20, 1]
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
./users --warning 1,20,1 --critical None,50,5
```

Output:

```text
TTY: 0, PTS: 1, Disconnected: 0

USERNAME              SESSIONNAME        ID  STATE   IDLE TIME  LOGON TIME
administrator         rdp-tcp#11          1  Active          .  24.08.2022 17:42
```


## States

* OK if the number of users is below all warning thresholds.
* WARN if the number of tty, pts, or disconnected users exceeds `--warning`.
* CRIT if the number of tty, pts, or disconnected users exceeds `--critical`.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| disc | Number | Number of disconnected users (Windows only) |
| pts | Number | Number of PTS users (SSH on Linux, RDP on Windows) |
| tty | Number | Number of TTY users (console on Linux, console on Windows) |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
