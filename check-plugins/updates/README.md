# Check "updates" - Overview

Checks the the number of pending Windows updates.

We recommend to run this check every day.


# Installation and Usage

## Examples

```bash
./updates3
./updates3 --critical 10
./updates3 --help
```


# States

* WARN or CRIT if number of updates is above a given threshold.

# Perfdata

* `pending_updates`: Number of pending updates.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
