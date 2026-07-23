# Check disk-smart


## Overview

Queries SMART (Self-Monitoring, Analysis, and Reporting Technology) data from hard disks and solid-state drives using smartctl. Inspects drive health attributes, error logs, and self-test results to detect failing or degraded drives before data loss occurs. Supports both SCSI and ATA drives, including drives behind hardware RAID controllers, using the device type reported by the drive scan. Devices smartctl cannot open are reported as inaccessible instead of aborting the whole check. Supports filtering drives by regular expression via `--match` and `--ignore`. Alerts when any drive reports failing health attributes, SMART errors, or failed self-tests. Requires root or sudo.

**Important Notes:**

* Requires root privileges. Without them, `smartctl` cannot open a single device and the check reports UNKNOWN with the reason `smartctl` gives (usually `Permission denied`). Run the plugin via `sudo`, as shipped in `/etc/sudoers.d/linuxfabrik-monitoring-plugins`
* Supports ATA/SATA and SCSI/SAS hard drives and solid-state drives
* Run `/usr/sbin/update-smart-drivedb` periodically to update the drive database, which can improve attribute interpretation
* Use `--full` to also alert on notices (assumptions), not just on actual SMART issues

**Data Collection:**

* Runs `smartctl --scan-open` to discover all available drives, then runs `smartctl --xall` against each drive
* The device type reported by the drive scan (`-d sat`, `-d nvme`, `-d megaraid,0`, ...) is passed on to `smartctl --xall`, which is what makes external USB drives and drives behind a hardware RAID controller readable
* `smartctl` comments out the devices it was unable to open. Such a device is reported as inaccessible together with the reason and does not abort the check, so the remaining drives are still inspected
* Parses drive health status, SMART attributes (pre-fail and old-age), error logs, self-test results, temperatures, power-on hours, and remaining lifetime
* The check tries to identify all disks automatically. Drives can be filtered using `--match` and `--ignore` (case-sensitive Python regular expressions; use `(?i)` for case-insensitive matching). A drive hit by `--ignore` is dropped even if it also matches `--match`. The device path (`/dev/sda`), the short device name (`sda`) and the name `smartctl` reports the drive under (`/dev/bus/0 [megaraid_disk_00]`) are all matched. The last one is what makes a single drive behind a RAID controller filterable at all, since all of them share one device name
* A `smartctl` run can take up to one or two seconds per disk, depending on its health and interface/bus speed


## Fact Sheet

| Fact | Value |
|----|----| 
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/disk-smart> |
| Nagios/Icinga Check Name              | `check_disk_smart` |
| Check Interval Recommendation         | Every 8 hours |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Requirements                          | command-line tool `smartctl` (package `smartmontools`); root or sudo |


## Help

```text
usage: disk-smart [-h] [-V] [--always-ok] [--full] [--ignore IGNORE]
                  [--match MATCH] [--no-match-severity {ok,warn,crit,unknown}]
                  [--no-perfdata]

Queries SMART (Self-Monitoring, Analysis, and Reporting Technology) data from
hard disks and solid-state drives using smartctl. Inspects drive health
attributes, error logs, and self-test results to detect failing or degraded
drives before data loss occurs. Supports both SCSI and ATA drives, including
drives behind hardware RAID controllers, using the device type reported by the
drive scan. Devices smartctl cannot open are reported as inaccessible instead
of aborting the whole check. Supports filtering drives by regular expression
via --match and --ignore. Alerts when any drive reports failing health
attributes, SMART errors, or failed self-tests. Requires root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --full                Also warn on assumptions (stated as "notice" in
                        GSmartControl), not just on actual SMART issues.
                        Default: False
  --ignore IGNORE       Any item matching this Python regex will be ignored.
                        Can be specified multiple times. Example:
                        `(?i)linuxfabrik` for a case-insensitive match.
  --match MATCH         Filter by this Python regular expression. Case-
                        sensitive by default; use `(?i)` for case-insensitive
                        matching. Can be specified multiple times. Examples:
                        `(?i)example` to match "example" regardless of case.
                        `^(?!.*example).*$` to match any string except
                        "example" (negative lookahead).
  --no-match-severity {ok,warn,crit,unknown}
                        State to report when no item matches the filters and
                        nothing is checked. Default: ok
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
```


## Usage Examples

```bash
sudo ./disk-smart --ignore='mmcblk0' --full
```

Output:

```text
Checked 4 disks. There are critical errors.
* /dev/sda (Crucial/Micron Client SSDs, Crucial_CT525MX300SSD1, SerNo 1a2b3c4d)
* /dev/sdb (Crucial/Micron Client SSDs, Crucial_CT525MX300SSD1, SerNo 1a2b3c4d)
* /dev/sdc (Seagate IronWolf, ST12000VN0007-2GS116, SerNo 1a2b3c4d) [CRITICAL]
  - The device error log contains records of errors.
  - Error Log: Drive is reporting 2 internal errors. Usually this means uncorrectable data loss and similar severe errors. Check the actual errors for details.
  - Error Log: Error "Uncorrectable error in data".
  - Attributes: Drive has a non-zero Raw value ("5 Reallocated_Sector_Ct"), but there is no SMART warning yet. This could be an indication of future failures and/or potential data loss in bad sectors.
* /dev/sdd (Seagate IronWolf, ST12000VN0007-2GS116, SerNo 1a2b3c4d)
```

Running without root privileges:

```bash
./disk-smart
```

Output:

```text
Did not check any disk. smartctl cannot access 1 device. Run this plugin as root or via sudo.
* /dev/nvme0: Permission denied [UNKNOWN]
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
* WARN if the device self-test log contains records of errors.
* UNKNOWN on `smartctl` not found or errors running `smartctl`.
* UNKNOWN if `smartctl` cannot open a device, for example because the plugin runs without root privileges. The device is reported with the reason `smartctl` gives, the remaining drives are still checked.
* UNKNOWN if the drive scan does not report a single device.
* If no drive matches `--match`/`--ignore`, "Nothing checked." is reported with the state given by `--no-match-severity` (default: OK).
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

### smartctl cannot access the devices

`smartctl cannot access 2 devices. Run this plugin as root or via sudo.`

`smartctl` needs raw access to the block devices, which an unprivileged account does not have. `smartctl --scan-open` then comments out every device it could not open and appends the reason (`Permission denied`), which the plugin repeats per device.

Run the check with root privileges. The shipped `/etc/sudoers.d/linuxfabrik-monitoring-plugins` allows the monitoring account to run the plugin via `sudo`, and the Icinga Director basket calls it as `/usr/bin/sudo /usr/lib64/nagios/plugins/disk-smart`. Reproducing the check by hand therefore has to include `sudo` as well:

```bash
sudo /usr/lib64/nagios/plugins/disk-smart
```

Note that the monitoring account usually has no interactive shell, so `su nagios` does not work for testing. Use `runuser` instead:

```bash
runuser --user=nagios -- sudo /usr/lib64/nagios/plugins/disk-smart
```

### Unable to detect device type

`/dev/sda: Unable to detect device type`

`smartctl` could not determine how to talk to the drive. This is what a device that cannot be opened at all looks like on the follow-up call, so check the privileges first (see above). If the check runs as root and the drive sits behind a controller `smartctl` does not recognize, add the drive to `--ignore` and query it manually with an explicit `smartctl --device=...`.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits: [GSmartControl](https://gsmartcontrol.sourceforge.io/home/): We re-implemented parts of the logic in Python and used its excellent output.
