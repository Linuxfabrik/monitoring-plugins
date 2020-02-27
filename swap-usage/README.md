# Overview

Displays amount of free and used swap space in the system, checks against used swap in percent.

We recommend to run this check every minute.


# Installation and Usage

Requirements:
* Python2 module `psutil`

```bash
./swap-usage
./swap-usage --warning 70 --critical 90
./swap-usage --help
```


# States and Perfdata

* WARN and CRIT as provided.

Perfdata:
* Swap Usage (%)
* Total Swap Space (Bytes)
* Used (Bytes)
* Free (Bytes)
* Swap In (Bytes)
* Swap Out (Bytes)


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.