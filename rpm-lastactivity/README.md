# Check "rpm-lastactivity" - Overview

Checks the timespan since the last rpm activity, for example due to a yum/dnf install, update or remove.

* `./rpm-lastactivity` checks if the last rpm-activity (for example a yum-update) is more than 90 or 365 days ago. If not, it results in "Last rpm/yum/dnf activity is below the given thresholds (90d/365d)." (OK)
* `./rpm-lastactivity --warning 0` checks if there was rpm-activity within the last 0 days. If not, it results in "Last rpm/yum/dnf activity is more than 0 days ago." (WARN)

We recommend to run this check once a day.


# Installation and Usage

Requirements:
* `rpm`

```bash
./rpm-lastactivity
./rpm-lastactivity --warning 90 --critical 365
./rpm-lastactivity --help
```


# States

* WARN or CRIT if last activity is above a given threshold.


# Perfdata

There is no perfdata.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.