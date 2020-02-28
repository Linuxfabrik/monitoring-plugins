# Overview

Checks the size of a file, in bytes.

The plugin is able to follow symlinks. Depending on the file and user (e.g. running as 'icinga') sudo (sudoers) is needed.

We recommend to run this check every 15 minutes.


# Installation and Usage

```bash
./file-size --help
```


# States and Perfdata

tbd


# Known Issues and Limitations

* Does not work with directories.
* Does not work with wildcards.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
