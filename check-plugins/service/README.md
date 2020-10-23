# Check "service" - Overview

Checks the state of a Windows service.

We recommend to run this check every minute.


# Installation and Usage

## Examples

```bash
./service3 --task Schedule
./service3 --task Schedule --severity crit
./service3 --task Schedule --status running
./service3 --help
```


# States

* WARN if result does not match the given parameter values.
* CRIT only if configured as such.


# Perfdata

There is no perfdata.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
