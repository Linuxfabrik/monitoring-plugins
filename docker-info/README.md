# Overview

Checks additional info about docker containers like data space usage, docker warnings etc. Needs sudo.

We recommend to run this check every 5 minutes.


# Installation and Usage

Requirements:
* `docker`

```bash
./docker-info --w_data_space_used_percentage 90 --c_data_space_used_percentage 95 --w_metadata_space_used_percentage 90 --c_metadata_space_used_percentage 95 --ignore-devicemapper-storage-driver
./docker-info --help
```

# States and Perfdata

* WARN or CRIT if data space is above a given threshold.
* WARN or CRIT if metadata space is above a given threshold.
* WARN on `docker info` warnings and errors.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.