# Check deb-lastactivity

## Overview

Checks how long ago the last APT package manager activity occurred (install, update, or remove). Alerts if no package management activity has happened within the configured thresholds (default: WARN after 90 days, CRIT after 365 days). Useful for detecting servers that have not been patched in a long time.

**Data Collection:**

* Runs `dpkg-query --show --showformat='${db-fsys:Last-Modified} ${Package}\n'` to retrieve the last modification timestamp for each installed package
* Uses the most recent timestamp across all packages as the "last activity" time

**Compatibility:**

* Debian, Ubuntu, and other dpkg-based distributions

**Important Notes:**

* If one or more packages have a missing "Last-Modified" timestamp (for example due to deleted files), the check returns WARN with a hint to reinstall the affected packages
* If dpkg-query returns no data at all (for example if an update has never been performed), the check returns UNKNOWN


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/deb-lastactivity> |
| Nagios/Icinga Check Name              | `check_deb_lastactivity` |
| Check Interval Recommendation         | Once a day |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
usage: deb-lastactivity [-h] [-V] [-c CRIT] [--test TEST] [-w WARN]

Checks how long ago the last APT package manager activity occurred (install,
update, or remove). Alerts if no package management activity has happened
within the configured thresholds (default: WARN after 90 days, CRIT after 365
days). Useful for detecting servers that have not been patched in a long time.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  -c, --critical CRIT  CRIT threshold for time since last package manager
                       activity, in days. Default: 365
  --test TEST          For unit tests. Needs "path-to-stdout-file,path-to-
                       stderr-file,expected-retc".
  -w, --warning WARN   WARN threshold for time since last package manager
                       activity, in days. Default: 90
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

* OK if the last package manager activity is within the warning threshold.
* WARN if the last activity is more than `--warning` days ago (default: 90).
* WARN if "Last-Modified" timestamp for one or more packages is not found.
* CRIT if the last activity is more than `--critical` days ago (default: 365).
* UNKNOWN if dpkg-query fails or no activity data is available.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
