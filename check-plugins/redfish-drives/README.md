# Check redfish-drives

## Overview

Checks the state of all drives or other physical storage media in the Systems collection.

Tested on:

* DELL iDRAC
* DMTF Simulator

Hints:

* A check takes up to 10 seconds. Increasing runtime timout to 30 seconds is recommended.
* This check runs with both http and https. It just uses GET requests.
* No additional Python Redfish modules need to be installed.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/redfish-drives> |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
usage: redfish-drives [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                      [--password PASSWORD] [--timeout TIMEOUT] [--url URL]
                      [--username USERNAME]

Checks the state of all drives or other physical storage media in the Systems
collection.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  --insecure           This option explicitly allows to perform "insecure" SSL
                       connections. Default: True
  --no-proxy           Do not use a proxy. Default: False
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

* CRIT if an enabled drive's health rollup state is equal to "Critical".
* CRIT if an enabled drive's health state is equal to "Critical".
* CRIT if an enabled controller's rollup state is equal to "Critical".
* CRIT if an enabled controller's state is equal to "Critical".
* WARN if an enabled drive's health rollup state is equal to "Warning".
* WARN if an enabled drive's health state is equal to "Warning".
* WARN if an enabled controller's rollup state is equal to "Warning".
* WARN if an enabled controller's state is equal to "Warning".


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
