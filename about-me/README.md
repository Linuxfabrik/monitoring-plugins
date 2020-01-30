# Overview

Reports a quick overview about the host dimensions and installed software. Plugin execution may take up to 30 seconds, depending on the amount or type of installed software.

* Tools: software like Wireshark, tcpdump etc. - that normally should not be installed on a server system
* SW = "Software": packages installed using `yum`
* Apps: manual installed software that resides in `/home`, `/opt` and `/var/www/html`
* Python Modules: reports version of installed Python modules our checks depend on
* OS: system information

We recommend to run this check once a day or week.


# Installation and Usage

Requirements:
* Python2 psutil

```bash
./about-me
./about-me --no-warn
./about-me --help
```


# States and Perfdata

* Returns WARN if some tools are found that might be useful for hackers on your system, otherwise always returns OK. This behaviour can be switched off using the `--no-warn` parameter.
* Perfdata: number of CPUs, size of memory, number of disks and their size.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
