# Check "file-ownership" - Overview

Checks the ownership (owner and group, both have to be names) of a list of files. Depending on the file and user (e.g. running as 'icinga') sudo (sudoers) is needed.

We recommend to run this check every 5 minutes.


# Installation and Usage

```bash
./file-ownership
./file-ownership/file-ownership --filename root:root,/tmp
./file-ownership --help
```

# States

* WARN if ownership does not match expected values.


# Perfdata

There is no perfdata.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.