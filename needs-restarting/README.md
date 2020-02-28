# Check "needs-restarting" - Overview

Checks for processes that started running before they or some component that they use were updated. Returns WARN if a full reboot is required or if services might need a restart, and in any other case OK. May take more than 10 seconds to execute.

We recommend to run this check once a day or after a `yum update` only.


# Installation and Usage

```bash
./needs-restarting
./needs-restarting --help
```


# States

* WARN on needed service or system restarts.
* Does not WARN or CRIT on other problems like `Modular dependency problem` etc.


# Perfdata

There is no perfdata.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.