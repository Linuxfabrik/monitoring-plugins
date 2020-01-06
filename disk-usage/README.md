# Overview

Measures the usage of all disk _partitions_ on any disks found. It does not
check the usage on the raw disks, because for example in LVM more than
one disk can be a member of a logical volume, and some of the disks might be 
full - which is ok as long as the LVM has some space available.

* Packages required: 
* Tested on OS: CentOS 7 Minimal, Fedora 30, Fedora 31
* Tested with Monitoring Tool: Icinga2
* Python libs required: 

Features:
* Auto Discovery: yes
* Default Thresholds: no
* Takes time periods into account: no
* Uses temporary files: no

Hints and Recommendations:
* 


# Usage

```bash
./disk-usage
```


# Returns

* CRIT: 
* WARN: 
* UNKNOWN: 


# Parameters

...


# Examples

...


# Installation in Icinga Director

...


# Known Issues and Limitations

* 


# Contents

...


# Changelog

* 2019120301: Initial release.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
