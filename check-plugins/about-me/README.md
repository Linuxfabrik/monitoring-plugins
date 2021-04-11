# Check "about-me" - Overview

Reports a quick overview about the host dimensions and installed software. Plugin execution may take up to 30 seconds, depending on the amount or type of installed software.

* Software: packages installed using `yum`
* Apps (if any): manual installed software that resides in `/home`, `/opt` and `/var/www/html`
* Tools (if any): tools like dig, wget etc., normally not installed on a CentOS minimal system
* Python Modules: reports version of installed Python modules some of our checks depend on
* OS: system information

We recommend to run this check once a day or week.


# Installation and Usage

Requirements:
* Python2 module `psutil`

```bash
./about-me
./about-me --help
```


# States

* Always returns OK.


# Perfdata

* cpu: Number of CPUs
* ram: Size of memory
* disks: Number of disks
* osversion: as a Number. "Fedora 33" becomes "33", "CentOS 7.4.1708" becomes "741708" - to see when an update happened.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
