# Overview

Checks network I/O for all interfaces. We only consider inferfaces that have a MAC-Address, therefore we ignore `lo`.

Hints and Recommendations:
* `--count=5` (the default) while checking every minute means that the check reports a warning if the `tx_rate` or `rx_rate` was above a threshold in the last 5 minutes.
* If there is an increase in either drops or errors, the check returns a warning for the time duration specified with `--timespan=15` (default: 15min)
* Check uses a SQLite database in `/tmp` to store its historic data.

We recommend to run this check every minute.


# Installation and Usage

Requirements:
* Python2 module `psutil`

```bash
./network-io
./network-io --help
```


# States and Perfdata

tbd


# Known Issues and Limitations

* The check has to be rewritten.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.