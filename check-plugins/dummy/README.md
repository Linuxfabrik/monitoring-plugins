# Check "dummy" - Overview

This check just returns the given message, state and perfdata.
It comes in handy when trying to pass Icinga DSL to the dummy command via the Icinga Director, as this is not currently possible with the Icinga in-built dummy command.

# Installation and Usage

```bash
./dummy --state crit --message 'test'
./dummy --help
```


# States

* Given state, or UNKNOWN if none is given


# Perfdata

* Given perfdata, or none


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
