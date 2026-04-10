# Check rpm-lastactivity

## Overview

Checks the timespan since the last package manager activity, for example due to a yum/dnf install/update.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/rpm-lastactivity> |
| Check Interval Recommendation         | Once a day |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
usage: rpm-lastactivity [-h] [-V] [-c CRIT] [-w WARN]

Checks how long ago the last RPM package manager activity occurred (install,
update, or remove via yum/dnf). Alerts if no package management activity has
happened within the configured thresholds. Useful for detecting servers that
have not been patched in a long time.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  -c, --critical CRIT  CRIT threshold for the time since the last RPM
                       activity, in days. Default: 365
  -w, --warning WARN   WARN threshold for the time since the last RPM
                       activity, in days. Default: 90
```


## Usage Examples

```bash
./rpm-lastactivity --warning 90 --critical 365
```

Output:

```text
Last package manager activity is 5M 2W ago [WARNING] (thresholds 90D/365D).
```


## States

* WARN or CRIT if last activity is above a given threshold.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
