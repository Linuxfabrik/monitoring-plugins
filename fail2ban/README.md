# Overview

In fail2ban, checks the amount of banned IP addresses (for a list of jails).

We recommend to run this check every minute.


# Installation and Usage

```bash
./fail2ban --warning 1000 --critical 10000 
./fail2ban --help
```


# States and Perfdata

* WARN or CRIT if number of blocked IP addresses is above a given threshold.

Perfdata (per jail):

* Number of blocked IP addresses.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.