# Check disk-smart

## Overview

Queries SMART (Self-Monitoring, Analysis, and Reporting Technology) data from hard disks and solid-state drives using smartctl. Inspects drive health attributes, error logs, and self-test results to detect failing or degraded drives before data loss occurs. Supports both SCSI and ATA drives, including drives behind hardware RAID controllers when the correct device type is specified. Alerts when any drive reports failing health attributes, SMART errors, or failed self-tests. Requires root or sudo.

**Data Collection:**

* Runs `smartctl --scan-open` to discover all available drives, then runs `smartctl --xall` against each drive
* Parses drive health status, SMART attributes (pre-fail and old-age), error logs, self-test results, temperatures, power-on hours, and remaining lifetime
* The check tries to identify all disks automatically. Disks without SMART capability can be excluded using the `--ignore` parameter
* A `smartctl` run can take up to one or two seconds per disk, depending on its health and interface/bus speed

**Compatibility:**

* Linux only (requires `smartctl` from the `smartmontools` package)


**