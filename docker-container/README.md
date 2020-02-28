# Check "docker-container" - Overview

Checks the stats and number of docker containers. Needs sudo.

We recommend to run this check every minute.


# Installation and Usage

Requirements:
* `docker`

```bash
./docker-container --warning 90 --critical 95
./docker-container --help
```


# States

* WARN or CRIT if container cpu usage is above a given threshold.
* WARN or CRIT if container memory usage is above a given threshold.
* WARN if number of installed containers is less than expected.
* WARN if number of running containers is less than expected.


# Perfdata

* Installed Container count
* Running container count

Perfdata (per container):

* CPU usage
* Memory usage


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
