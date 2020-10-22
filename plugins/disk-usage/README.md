# Check "disk-usage" - Overview

Measures the usage of all mounted disk _partitions_ on physical disks only (e.g. hard disks, CD-ROM drives, USB keys) found. It does not check the usage on the raw disks, because for example in LVM more than one disk can be a member of a logical volume, and some of the disks might be full - which is ok as long as the LVM has some space available. The check also ignores all other partition types (e.g. memory partitions such as /dev/shm).

*Note*: UNIX usually reserves 5% of the total disk space for the root user. total and used fields on UNIX refer to the overall total and used space, whereas free represents the space available for the user and percent represents the user utilization. That is why percent value may look 5% bigger than what you would expect it to be (starting with psutil v4.3.0; quote from the [psutil documentation](https://psutil.readthedocs.io/en/latest/)).

We recommend to run this check every 5 minutes.


# Installation and Usage

Requirements:
* Python2 module `psutil`

```bash
./disk-usage
./disk-usage --warning=80 --critical=90
```

# States

* WARN or CRIT if disk usage is above a given threshold.


# Perfdata

* Usage (%)
* Usage (Bytes)
* Total Disksize (Bytes)


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.