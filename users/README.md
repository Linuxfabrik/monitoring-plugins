# Overview

Counts how many users are currently logged in, both via tty and pts (typically SSH).

We recommend to run this check every minute.


# Installation and Usage

```bash
./users
./users --warning '1, None'
./users --warning '1, None' --critical '1, 1'
./users --help
```


# States and Perfdata

* WARN or CRIT if number of users is above a given threshold.

Perfdata:
* tty: Number of TTY users.
* pty: Number of PTY users (for example SSH).


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.