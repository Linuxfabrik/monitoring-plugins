# Overview

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


# States and Perfdata

* Always returns OK.
* Perfdata: number of CPUs, size of memory, number of disks and their size.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
