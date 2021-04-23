# Check "load" - Overview

On the *No Sheep* blog, Zachary Tirrell defines the [load average](http://nosheep.net/story/defining-unix-load-average/) on GNU/Linux operating system:

> In short it is the average sum of the number of processes waiting in the run-queue plus the numbercurrently executing over 1, 5, and 15 minutes time periods.

Alerts on load average are only set on 15 minutes time period. For this, the check gets the number of CPU cores to *normalize* load values automatically. Loads are computed by dividing the 15 minutes average load per CPU(s) count. For example, if you have 3 CPUs and the 15 minutes load is 6.0, then you get a warning because of (6 / 3) >= 1.15, where 1.15 is the default warning threshold. Main advantage of this method is to make machines comparable and making the design of Grafana panels easier.

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