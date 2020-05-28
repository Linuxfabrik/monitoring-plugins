# Check "feed" - Overview

This check warns on the newest feed item of an RSS or Atom feed for a given amount of time.

To enable the check plugin to get the ACK status from Icinga, you have to create an Icinga API User like so:

```
object ApiUser "linuxfabrik-check-api-user" {
  password = "mysupersecretpassword"
  permissions = [ "objects/query/service" ]
}
```

Please remember to set a reasonable check interval time. Usually it is a waste of bandwidth to poll feeds more often than each hour.


# Installation and Usage

Requirements:
* Python2 module `BeautifulSoup4` (Version 4) with `lxml`

Where to get it:
* CentOS 8: `dnf install python2-beautifulsoup4`
* CentOS 7: `yum install python-beautifulsoup4`
* On Fedora and Ubuntu, one way is to download the [Beautiful Soup 4 source tarball](https://www.crummy.com/software/BeautifulSoup/bs4/download/4.0/beautifulsoup4-4.1.0.tar.gz) and install it with `python2 setup.py install`.

```bash
./feed
./feed --url https://github.com/Icinga/icinga2/releases.atom --no-summary --no-icinga-callback --warn 1440
./feed --icinga-url https://icinga-host:5665 --icinga-username linuxfabrik-check-api-user --icinga-password mysupersecretpassword --icinga-service-name 'icinga-host!Feed Service Name' --url https://www.heise.de/security/rss/alert-news-atom.xml
./feed --help
```

Feed examples:

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


# States

* WARN if newest feed item is not acknowledged and not older than a given threshold.
* Otherwise always returns OK.


# Perfdata

There is no perfdata.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
