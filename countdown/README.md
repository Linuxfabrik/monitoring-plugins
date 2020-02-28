# Check "countdown" - Overview

The check warns before an expiration date of events that are scheduled to occur. Useful to warn before a hardware or contract expiration date. For example, `./countdown --input='Supermicro X11 (SerNo ABCD), 2025-12-23, 60, 30'` returns WARN/CRIT 60/30 days before 2025-12-23, otherwise OK.

We recommend to run this check twice a day.


# Installation and Usage

Use `./countdown --input='<Event Name>, <yyyy-mm-dd>, <WARN days before>, <CRIT days before>'` (repeating).

```bash
./countdown --input='Supermicro X11 (SerNo ABCD), 2025-12-23, 60, 30'
./countdown --input='Contract A, 2023-12-31, 60, None' --input 'Contract B, 2024-12-31, 30, 14'
./countdown --help
```


# States

For each event:
* CRIT: if event is <= days away; 'None' means that CRIT is never returned
* WARN: if event is <= days away; 'None' is not possible


# Perfdata

There is no perfdata.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
