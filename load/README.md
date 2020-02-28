# Check "load" - Overview

Return the average system load _per cpu_ over the last 1, 5 and 15 minutes. Therefore a value of "1" means that the overall system has a load of 100%. Warns on load15 only.

We recommend to run this check every minute.


# Installation and Usage

Requirements:
* Python2 module `psutil`

```bash
./load
./load --warning 1.15 --critical 5.0
./load --help
```


# States

* WARN if load15 >= 1.15 (default)
* CRIT if load15 >= 5.00 (default)


# Perfdata

* load1
* load5
* load15


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.