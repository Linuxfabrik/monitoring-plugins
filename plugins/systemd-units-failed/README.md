# Check "systemd-units-failed" - Overview

This plugin warns on any `systemd` unit file which is in a failed state (whether active state or sub state).

We recommend to run this check every 1 minute.


# Installation and Usage

```bash
./systemd-units-failed
./systemd-units-failed --help
```


# States

* WARN if at least one unit has a failed active state or failed sub state.


# Perfdata

* systemd-units-failed: Number of failed units


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
