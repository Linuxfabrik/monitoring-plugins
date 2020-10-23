# Check "file-size" - Overview

Checks the size of a file, in bytes. The plugin is able to follow symlinks. Depending on the file and user (e.g. running as 'icinga') sudo (sudoers) is needed.

We recommend to run this check every 15 minutes.


# Installation and Usage

```bash
./file-size --filename /var/log/messages --warning 104857600 --critical 1073741824
./file-size --help
```


# States

* WARN or CRIT if file size is above a given threshold.


# Perfdata

* File Size (Bytes)


# Known Issues and Limitations

* Does not work with directories.
* Does not work with wildcards.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.