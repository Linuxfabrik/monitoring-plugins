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

* WARN and CRIT as provided.
* Perfdata: Number of TTY and PTY users.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.