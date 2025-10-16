# Check users

## Overview

Counts how many users are currently logged in, both via tty (on Windows: Console) and pts (on Linux: typically ssh, on Windows: RDP). Also counts the disconnected users on Windows (closed connections without logging out).

Hints:

* A *tty* is a native terminal device, the backend is either hardware or kernel emulated.
* A *pty* (pseudo terminal device) is a terminal device which is emulated by applications such as network login services (ssh, rlogin, telnet), terminal emulators such as xterm, script, screen, tmux, unbuffer, and expect.
* A *pts* is a pseudo terminal slave part of a *pty*.
* If running on hardware, use `--critical 1,20` (Linux) and `--critical 1,50,3` (Windows).


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/users> |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | Yes |
| Requirements                          | `w` on Linux, `query users` on Windows |


## Help

```text
usage: users [-h] [-V] [-c CRIT] [--test TEST] [-w WARN]

Counts how many users are currently logged in, both via tty (on Windows:
Console) and pts (on Linux: typically ssh, on Windows: RDP). Also counts the
disconnected users on Windows (closed connections without logging out).

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  -c, --critical CRIT  Set the critical threshold for logged in tty/pts users,
                       in the format "3,10". On Windows, you can additionally
                       set it for disconnected users, in the format "3,10,1".
                       Default: [None, None, None]
  --test TEST          For unit tests. Needs "path-to-stdout-file,path-to-
                       stderr-file,expected-retc".
  -w, --warning WARN   Set the warning threshold for logged in tty/pts users,
                       in the format "1,5". On Windows, you can additionally
                       set it for disconnected users, in the format "1,5,10".
                       Default: [1, 20, 1]
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

On Windows, if one user is connected via RDP:

```text
./users --warning 1,20,1 --critical None,50,5
```

```text
TTY: 0, PTS: 1, Disconnected: 0

USERNAME              SESSIONNAME        ID  STATE   IDLE TIME  LOGON TIME
administrator         rdp-tcp#11          1  Active          .  24.08.2022 17:42|'disc'=0;1;;0; 'tty'=0;1;;0; 'pts'=1;20;;0;
```


## States

* WARN or CRIT if number of users is above a given threshold.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| tty | Number | Number of TTY users on Linux, Number of Console users on Windows. |
| pts | Number | Number of PTY users on Linux (for example ssh), Number of RDP users on Windows. |
| disc | Number | Number of disconnected users (on Windows only). |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
