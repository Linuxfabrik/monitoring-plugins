# Check deb-lastactivity

## Overview

Checks the timespan since the last package manager activity, for example due to an apt install/update.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/deb-lastactivity> |
| Check Interval Recommendation         | Once a day |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
usage: deb-lastactivity [-h] [-V] [-c CRIT] [--test TEST] [-w WARN]

Checks the timespan since the last package manager activity, for example due
to an apt install/update.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  -c, --critical CRIT  Set the critical threshold (in days). Default: 365
  --test TEST          For unit tests. Needs "path-to-stdout-file,path-to-
                       stderr-file,expected-retc".
  -w, --warning WARN   Set the warning threshold (in days). Default: 90
```


## Usage Examples

```bash
./deb-lastactivity --warning 90 --critical 365
```

Output:

```text
Last package manager activity is 5M 2W ago [WARNING] (thresholds 90D/365D).
```


## States

* WARN or CRIT if last activity is above a given threshold.
* WARN if "Last-Modified" timestamp for one or more packages is not found.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
