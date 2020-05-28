# Check "users" - Overview

Counts how many users are currently logged in, both via tty and pts (typically ssh).

A _tty_ is a native terminal device, the backend is either hardware or kernel emulated.

A _pty_ (pseudo terminal device) is a terminal device which is emulated by applications such as network login services (ssh, rlogin, telnet), terminal emulators such as xterm, script, screen, tmux, unbuffer, and expect. A _pts_ is a psuedo terminal slave part of a _pty_.

We recommend to run this check every minute.


# Installation and Usage

Requirements:
* `w`

```bash
./users
./users --warning '1, None'
./users --warning '1, None' --critical '1, 1'
./users --help
```


# States

* WARN or CRIT if number of users is above a given threshold.


# Perfdata

* tty: Number of TTY users.
* pty: Number of PTY users (for example ssh).


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.