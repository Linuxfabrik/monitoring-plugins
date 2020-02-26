# Overview

Checks system load average, normalized for the number of CPUs in a system.
We recommend to run this check every minute.


# Installation and Usage

```bash
./load --warning 1.15 --critical 5.0
./load --help
```


# States and Perfdata

Prints load1, load5 and load15, but warns on load15 only.

* WARN if load15 >= 1.15 (default)
* CRIT if load15 >= 5.00 (default)


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
