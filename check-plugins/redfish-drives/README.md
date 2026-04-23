# Check redfish-drives


## Overview

Checks the state of all physical drives and their storage controllers in a Redfish-compatible server via the Redfish API. Iterates over the Systems collection, fetches storage controllers and their attached drives, and reports health status, media type, protocol, capacity, and predicted media life left.

**Important Notes:**

* Tested on DELL iDRAC and DMTF Simulator
* A check takes up to 10 seconds. Increasing runtime timeout to 30 seconds is recommended.
* This check runs with both HTTP and HTTPS. It uses GET requests only.
* No additional Python Redfish modules need to be installed.
* System-level health (processors, BIOS, power, temperature, indicator LED, etc.) is deliberately not aggregated into the plugin state, so that a system-level warning unrelated to storage (such as an inlet temperature threshold) cannot mask or flip the drive status. Use `redfish-system` for system-level health monitoring.

**Data Collection:**

* Queries `/redfish/v1/Systems` to enumerate system members
* For each member, queries the Storage collection and iterates over all storage controllers and attached drives
* Uses HTTP Basic authentication if `--username` and `--password` are provided
* Only evaluates drives and controllers in "Enabled" or "Quiesced" state
* Aggregates only drive health and storage-controller health into the plugin state. The member identification line (manufacturer, model, hostname, SKU, serial number) is shown as context without a status label.


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/redfish-drives> |
| Nagios/Icinga Check Name              | `check_redfish_drives` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |


## Help

```text
usage: redfish-drives [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                      [--password PASSWORD] [--test TEST] [--timeout TIMEOUT]
                      [--url URL] [--username USERNAME]

Checks the state of all physical drives and their storage controllers in a
Redfish-compatible server via the Redfish API. Alerts when any drive or
storage controller reports a degraded or failed state. System-level health
(processors, BIOS, power, temperature, indicator LED, etc.) is deliberately
ignored by this check so that a system warning unrelated to storage does not
mask the drive status; use `redfish-system` for that.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  --insecure           This option explicitly allows insecure SSL connections.
  --no-proxy           Do not use a proxy.
  --password PASSWORD  Redfish API password.
  --test TEST          For unit tests. Needs "path-to-stdout-file,path-to-
                       stderr-file,expected-retc".
  --timeout TIMEOUT    Network timeout in seconds. Default: 8 (seconds)
  --url URL            Redfish API URL. Default: https://localhost:5000
  --username USERNAME  Redfish API username.
```


## Usage Examples

```bash
./redfish-drives --url https://bmc --username redfish-monitoring --password 'mypassword'
```

Output:

```text
Everything is ok, checked storage on 1 member.

Member: Dell Inc. PowerEdge R750, HostName: web483, SKU: ABCDEFG, SerNo: 1234567890ABCDE

Disk                ! Type ! Proto ! Manufacturer ! Model         ! SerialNumber ! Size     ! LifeLeft % ! State 
--------------------+------+-------+--------------+---------------+--------------+----------+------------+-------
Physical Disk 0:1:0 ! HDD  ! SAS   ! SEAGATE      ! ST1200MM0099  ! 12345678     ! 1.1TiB   ! None       ! [OK]  
SSD 0               ! SSD  ! SATA  ! MICRON       ! MTFDDAV480TDS ! ABCDEFGHIJKL ! 447.1GiB ! 100        ! [OK]  
SSD 1               ! SSD  ! SATA  ! MICRON       ! MTFDDAV480TDS ! MNOPQRSTUVWX ! 447.1GiB ! 100        ! [OK]  


ID                ! Name                                                    ! Description             ! Drives ! State 
------------------+---------------------------------------------------------+-------------------------+--------+-------
RAID.SL.7-1       ! PERC H345 Front                                         ! RAID Controller in SL 7 ! 1      ! [OK]  
AHCI.SL.6-1       ! BOSS-S2                                                 ! AHCI controller in SL 6 ! 2      ! [OK]  
AHCI.Embedded.1-1 ! C620 Series Chipset Family SSATA Controller [AHCI mode] ! Embedded AHCI 1         ! 0      ! [OK]  
AHCI.Embedded.2-1 ! C620 Series Chipset Family SATA Controller [AHCI mode]  ! Embedded AHCI 2         ! 0      ! [OK]  
CPU.1             ! CPU.1                                                   ! CPU.1                   ! 0      ! [OK]
```


## States

* OK if all drives and storage controllers are healthy.
* WARN if an enabled drive's health or health rollup state is "Warning".
* WARN if an enabled controller's health or health rollup state is "Warning".
* CRIT if an enabled drive's health or health rollup state is "Critical".
* CRIT if an enabled controller's health or health rollup state is "Critical".
* System-level health is NOT considered. Use `redfish-system` for that.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
