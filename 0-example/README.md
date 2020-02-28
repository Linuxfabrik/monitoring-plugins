# Overview

The `0-example` check is just a development code base and as such may be correct or not. This `README.md` is a copy&paste template.

We recommend to run this check once a day / every 5 minutes.

If necessary this README answers questions about:
* Is there some outstanding feature or something special about this check?
* Is there some kind of Auto Discovery?
* Does the check use sqlite databases or temporary files?


# Installation and Usage

Requirements:
* Python2 module `psutil`
* Python2 module `mysql.connector`
* `smartctl` from `smartmontools`


Use `./0-example --input='<Event Name>, <yyyy-mm-dd>, <WARN days before>, <CRIT days before>'`.

```bash
./0-example --input='Fileserver Hardware, 2025-02-02, 60, 30'
./0-example --input='Contract A, 2023-12-31, 60, None; Contract B, 2024-12-31, 30, 14;'
./0-example --help
```


# States and Perfdata

* WARN and CRIT as provided.
* WARN: if event is <= days away; 'None' is not possible
* CRIT: if event is <= days away; 'None' means that CRIT is never returned

There is no perfdata.


# Known Issues and Limitations

* only if there are some


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
* Credits:
  - This tool, written in C++ (https://this.tool/): We re-implemented the logic in Python and copied the excellent output.
  - only if needed