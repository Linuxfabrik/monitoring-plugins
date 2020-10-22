# Check "memory-usage" - Overview

Displays amount of free and used memory in the system, checks against used memory in percent.

We recommend to run this check every minute.


# Installation and Usage

Requirements:
* Python2 module `psutil`

```bash
./memory-usage
./memory-usage --warning 90 --critical 95
./memory-usage --help
```


# States

* WARN or CRIT if total memory usage is above a given threshold.


# Perfdata

* total: total physical memory (exclusive swap).
* used: memory used, calculated differently depending on the platform and designed for informational purposes only. total - free does not necessarily match used.
* free: memory not being used at all (zeroed) that is readily available; note that this doesn’t reflect the actual memory available (use available instead). total - used does not necessarily match free.
* shared (Linux, BSD): memory that may be simultaneously accessed by multiple processes.
* buffers (Linux, BSD): cache for things like file system metadata.
* cached (Linux, BSD): cache for various things.
* available: the memory that can be given instantly to processes without the system going into swap. This is calculated by summing different memory values depending on the platform and it is supposed to be used to monitor actual memory usage in a cross platform fashion.

The sum of used and available memory is not necessarily equal to total.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
* Credits:
  - https://github.com/giampaolo/psutil/blob/master/scripts/free.py
