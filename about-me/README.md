# Overview

Reports a quick overview about the host dimensions and installed software. Plugin execution may take up to 30 seconds, depending on the amount or type of installed software.

* Tools: software that normally should not be installed on a server system, like Wireshark etc.
* SW = "Software": packages installed using `yum`
* Apps: manuall installed software that resides in `/home`, `/opt` and `/var/www/html`
* OS: system information

We recommend to run this check once or twice a day.


# Installation and Usage

Requirements:
* EPEL-Release: `yum install epel-release`
* Python2 psutil: `yum install python2-psutil` (installation via `pip` is not recommended)

```bash
./about-me
./about-me --help
```


# States and Perfdata

Returns WARN if some tools are found that might be useful for hackers on your system, otherwise always returns OK.

Perfdata: #CPU, size of memory, #disks and their size.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
