# Check disk-smart

## Overview

Queries SMART (Self-Monitoring, Analysis, and Reporting Technology) data from hard disks and solid-state drives using smartctl. Inspects drive health attributes, error logs, and self-test results to detect failing or degraded drives before data loss occurs. Supports both SCSI and ATA drives, including drives behind hardware RAID controllers when the correct device type is specified. Alerts when any drive reports failing health attributes, SMART errors, or failed self-tests. Requires root or sudo.

**Data Collection:**

* Runs `smartctl --scan-open` to discover all available drives, then runs `smartctl --xall` against each drive
* Parses drive health status, SMART attributes (pre-fail and old-age), error logs, self-test results, temperatures, power-on hours, and remaining lifetime
* The check tries to identify all disks automatically. Disks without SMART capability can be excluded using the `--ignore` parameter
* A `smartctl` run can take up to one or two seconds per disk, depending on its health and interface/bus speed

**Compatibility:**

* Cross-platform

**Important Notes:**

* Supports ATA/SATA and SCSI/SAS hard drives and solid-state drives
* Run `/usr/sbin/update-smart-drivedb` periodically to update the drive database, which can improve attribute interpretation
* Use `--full` to also alert on notices (assumptions), not just on actual SMART issues


## Fact Sheet

| Fact | Value |
|----|----| 
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/disk-smart> |
| Nagios/Icinga Check Name              | `check_disk_smart` |
| Check Interval Recommendation         | Every 8 hours |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
usage: disk-smart [-h] [-V] [--always-ok] [--full] [--ignore IGNORE]
                  [--test TEST]

Queries SMART (Self-Monitoring, Analysis, and Reporting Technology) data from
hard disks and solid-state drives using smartctl. Inspects drive health
attributes, error logs, and self-test results to detect failing or degraded
drives before data loss occurs. Supports both SCSI and ATA drives, including
drives behind hardware RAID controllers when the correct device type is
specified. Alerts when any drive reports failing health attributes, SMART
errors, or failed self-tests. Requires root or sudo.

options:
  -h, --help       show this help message and exit
  -V, --version    show program's version number and exit
  --always-ok      Always returns OK.
  --full           Also warn on assumptions (stated as "notice" in
                   GSmartControl), not just on actual SMART issues. Default:
                   False
  --ignore IGNORE  Comma-separated list of disk names to ignore. Example:
                   `sda,sdb`. Default: []
  --test TEST      For unit tests. Needs "path-to-stdout-file,path-to-stderr-
                   file,expected-retc".
```


## Usage Examples

```bash
./disk-smart --ignore sdd,sdbx,mmcblk0 --full
```

Output:

```text
Checked 6 disks. There are critical errors.
* sda (Crucial/Micron Client SSDs, Crucial_CT525MX300SSD1, SerNo 1a2b3c4d)
* sdb (Crucial/Micron Client SSDs, Crucial_CT525MX300SSD1, SerNo 1a2b3c4d)
* [CRITICAL] sdc (Seagate IronWolf, ST12000VN0007-2GS116, SerNo 1a2b3c4d)
  - The device error log contains records of errors.
  - Error Log: Drive is reporting 2 internal errors. Usually this means uncorrectable data loss and similar severe errors. Check the actual errors for details.
  - Error Log: Error "Uncorrectable error in data".
  - Error Log: Error "Uncorrectable error in data".
  - Attributes: Drive has a non-zero Raw value ("5 Reallocated_Sector_Ct"), but there is no SMART warning yet. This could be an indication of future failures and/or potential data loss in bad sectors.
* sdd (Seagate IronWolf, ST12000VN0007-2GS116, SerNo 1a2b3c4d)
  - The device error log contains records of errors.
* sde (Seagate IronWolf, ST12000VN0007-2GS116, SerNo 1a2b3c4d)
  - The device error log contains records of errors.
* sdf (Seagate IronWolf, ST12000VN0007-2GS116, SerNo 1a2b3c4d)
  - The device error log contains records of errors.
```


## States

* CRIT if SMART reports any messages in "health" subsection.
* CRIT if a drive has a failing pre-fail attribute.
* CRIT if "Address mark not found" in error log.
* CRIT if "Identity not found" in error log.
* CRIT if "Track 0 not found" in error log.
* CRIT if "Uncorrectable error in data" in error log.
* CRIT if SMART status check returned "DISK FAILING".
* WARN if a drive has a failing old-age attribute.
* WARN if a drive has a failing pre-fail attribute in the past.
* WARN if "Command completion timed out" in error log.
* WARN if "End of media" in error log.
* WARN if "Interface CRC error" in error log.
* WARN if a drive is past its estimated lifespan.
* WARN if a drive is reporting surface errors.
* UNKNOWN on `smartctl` not found, errors running `smartctl`, SMART not available or not supported.
* If `smartctl` reports more than one issue, the worst state over all disks is returned.
* With `--full`, notices (stated as "notice" in GSmartControl) also trigger WARN.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| temperatures | Number | Drive temperatures (per disk, if reported). |
| remaining/used lifetimes | Percentage | Remaining or used drive lifetime (per disk, if reported). |
| power_on_hours | Number | Total power-on hours (per disk, if reported). |
| power_cycle_count | Number | Number of power cycles (per disk, if reported). |


## Troubleshooting

`smartctl failed with exit status "Device open failed, device did not return an IDENTIFY DEVICE structure, or device is in a low-power mode.`  
Run the check with root privileges, for example using `sudo`.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits: [GSmartControl](https://gsmartcontrol.sourceforge.io/home/): We re-implemented parts of the logic in Python and used its excellent output.
