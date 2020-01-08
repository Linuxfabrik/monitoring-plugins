# Overview

The `0-example` check is just a development code base and as such may be correct or not. This `README.md` is a copy&paste template.

We recommend to run this check once a day / every 5 minutes.

If necessary this README answers questions about:
* Is there some outstanding feature or something special about this check?
* What are required OS Packages?
* What are required Python libs?
* Is there some kind of Auto Discovery?
* Does the check use sqlite databases or temporary files?


# Usage

Use `./countdown --input='<Event Name>, <yyyy-mm-dd>, <WARN days before>, <CRIT days before>'`.

```bash
./countdown --input='Fileserver Hardware, 2025-02-02, 60, 30'
./countdown --input='Contract A, 2023-12-31, 60, None; Contract B, 2024-12-31, 30, 14;'
./countdown --help
```


# States

For each event tuple:
* CRIT: if event is <= days away; 'None' means that CRIT is never returned
* WARN: if event is <= days away; 'None' is not possible

There is no perfdata.


# Known Issues and Limitations

* only if there are some


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.

* Credits:
  * only if needed
  * This tool, written in C++ (https://this.tool/): We re-implemented the logic in Python and copied the excellent output.
