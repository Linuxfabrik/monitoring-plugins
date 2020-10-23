# Check "scheduled-task" - Overview

Checks the status of a Windows scheduled task.

We recommend to run this check every minute.


# Installation and Usage

## Examples

```bash
./scheduled-task3 --task Schedule
./scheduled-task3 --task Schedule --severity crit
./scheduled-task3 --task Schedule --status Disabled
./scheduled-task3 --help
```


# States

* WARN if result does not match the expected status.
* CRIT only if configured as such.


# Perfdata

There is no perfdata.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
