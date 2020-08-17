# Check "pip-version" - Overview

This plugin lets you track if an update for a python package installed via `pip` is available.

We recommend to run this check once a week.

# Installation and Usage

```bash
./pip-version --package sphinx
./pip-version --package sphinx --virtualenv /opt/sphinx/bin/activate
./pip-version --help
```


# States

* If wanted, always returns OK,
* else returns WARN if update is available.


# Perfdata

There is no perfdata.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
