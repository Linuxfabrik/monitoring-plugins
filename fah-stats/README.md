# Check "fah-team-stats" - Overview

Returns information about a specific team at Folding@Home.

No need to run this every minute (depends on your number of team members and/or active CPUs).


# Installation and Usage

```bash
./fah-team-stats --team 260774
./fah-team-stats --help
```

# States

* Always returns OK.


# Perfdata

* active_50: Active CPUs within 50 days
* credit: Grand Score
* donors: Number of Team Members
* rank: Team Ranking
* wus: Work Unit Count


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.