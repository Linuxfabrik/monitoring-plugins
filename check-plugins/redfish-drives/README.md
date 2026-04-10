# Check redfish-drives

## Overview

Checks the state of all physical drives and storage media in a Redfish-compatible server via the Redfish API. Iterates over the Systems collection, fetches storage controllers and their attached drives, and reports health status, media type, protocol, capacity, and predicted media life left.

**Data Collection:**

* Queries `/redfish/v1/Systems` to enumerate system members
* For each member, queries the Storage collection and iterates over all storage controllers and attached drives
* Uses HTTP Basic authentication if `--username` and `--password` are provided
* Only evaluates drives and controllers in "Enabled" or "Quiesced" state

**Important Notes:**

* Tested on DELL iDRAC and DMTF Simulator
* A check takes up to 10 seconds. Increasing runtime timeout to 30 seconds is recommended.
* This check runs with both HTTP and HTTPS. It uses GET requests only.
* No additional Python Redfish modules need to be installed.

**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/redfish-drives> |
| Nagios/Icinga Check Name              | `check_redfish_drives` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
usage: redfish-drives [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                      [--password PASSWORD] [--timeout TIMEOUT] [--url URL]
                      [--username USERNAME]

Checks the state of all physical drives and storage media in a Redfish-
compatible server via the Redfish API. Alerts when any drive reports a
degraded or failed state.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  --insecure           This option explicitly allows insecure SSL connections.
  --no-proxy           Do not use a proxy.
  --password PASSWORD  Redfish API password.
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

Member: Dell Inc. PowerEdge R750, Processors: 2x Intel(R) Xeon(R) Gold 6354 CPU @ 3.00GHz (72 logical), BIOS: 1.1.3, Power: On, LED: Lit, SKU: ABCDEFG, SerNo: 1234567890ABCDE

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

* OK if all drives and controllers are healthy.
* WARN if an enabled drive's health or health rollup state is "Warning".
* WARN if an enabled controller's health or health rollup state is "Warning".
* CRIT if an enabled drive's health or health rollup state is "Critical".
* CRIT if an enabled controller's health or health rollup state is "Critical".
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
