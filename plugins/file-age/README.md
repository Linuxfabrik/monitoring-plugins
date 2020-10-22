# Check "file-age" - Overview

Checks the time of last data modification for a file or directory, in seconds. The plugin is able to follow symlinks. Depending on the file and user (e.g. running as 'icinga') sudo (sudoers) is needed.

We recommend to run this check every minute.


# Installation and Usage

```bash
./file-age --help
```


# States

tbd


# Perfdata

tbd


# Known Issues and Limitations

* Does not work with wildcards.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
