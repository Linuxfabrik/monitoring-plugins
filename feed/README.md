# Check "feed" - Overview

This check warns on the newest feed item of an RSS or Atom feed for a given amount of time.

Please remember to set a reasonable check interval time. Usually it is a waste of bandwidth to poll feeds more often than each hour.

We recommend to run this check every hour, and in most cases during office hours only. 


# Installation and Usage

Requirements:
* Python2 module `feedparser`

Heise Security Feed (German):
* Feed: https://www.heise.de/security/rss/alert-news-atom.xml
* Run every hour, during office hours only (8 to 18 o'clock, Mo to Fr) - more makes no sense
* Warn for 4 hours (240 minutes)
* `./feed`

Icinga2 Releases Feed on GitHub:
* Feed: https://github.com/Icinga/icinga2/releases.atom
* Run once or twice a day
* Warn for 24 hours (1440 minutes)
* No summary please, just the title (the new version string)
* `./feed --url https://github.com/Icinga/icinga2/releases.atom --no-summary --warn 1440`


```bash
./feed
./feed --url https://github.com/Icinga/icinga2/releases.atom --no-summary --warn 1440
./feed --help
```


# States

* WARN if newest feed item is not older than a given threshold.
* Otherwise always returns OK.


# Perfdata

There is no perfdata.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
* Credits:
  - https://github.com/jrottenberg/check_rss/blob/master/check_rss.py