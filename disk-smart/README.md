# Overview

The check calls `smartctl`, which itself _controls the Self-Monitoring, Analysis 
and Reporting Technology (SMART) system built into most ATA/SATA and SCSI/SAS 
hard drives and solid-state drives. The purpose of SMART is to monitor the 
reliability of the hard drive and predict drive failures._ 
(from the man page of `smart`)

* Tested on OS: CentOS 7 Minimal, Fedora 30, Fedora 31
* Tested with Monitoring Tool: Icinga2

Features:
* Auto Discovery: yes
* Default Thresholds: no (does not use any thresholds at all)
* Takes time periods into account: no
* Uses temporary files: no

Hints and Recommendations:
* Running this check just makes sense on hardware using ATA/SATA and/or SCSI/SAS
  HDDs and SSDs.
* The check tries to identify all disks automatically. Disks without SMART
  capability can be ignored using the `--ignore` parameter manually.
* Keep in mind that a `smartctl` run can take up to one or two seconds per disk,
  depending on its health and (interface/bus) speed.

We recommend to run this check every 8 hours.


# Installation and Usage

Requirements:
* `smartctl` from `smartmontools`

```bash
./disk-smart
./disk-smart --ignore sdd,sdbx,mmcblk0
./disk-smart --help
```


# States and Perfdata

CRIT, when SMART reports:
* Overall Health Self-Assessment Test: FAILED!
* Attribute list: failing pre-fail attribute
* Error Log: "Address mark not found"
* Error Log: "Identity not found"
* Error Log: "Track 0 not found"
* Error Log: "Uncorrectable error in data"

WARN, when SMART reports any other issue.

UNKNOWN on `smartctl` not found, errors running `smartctl`, SMART not
available or not supported.

If `smartctl` reports more than one issue, the worst issue state over all disks
is returned.


# Known Issues and Limitations

* The check can't handle NVMe (for example /dev/mmcblk0).


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
* Credits:
  * GSmartControl (https://gsmartcontrol.sourceforge.io/home/): We re-implemented parts of the logic in Python and used its excellent output.
