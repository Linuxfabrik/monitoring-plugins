# Check feed

## Overview

This check warns on the newest feed item of an RSS or Atom feed for a given amount of time (default: 3 days). By default the check warns on the newest item published today or older (use `--latest` to change this behaviour). It strips HTML from the feed message.

With this check, you can acknowledge the warning in IcingaWeb, so that the check changes back to OK. To enable the check plugin to get the ACK status from Icinga and therefore automatically switch to OK, you have to create an Icinga API User like so:

```text
object ApiUser "linuxfabrik-check-api-user" {
  password = "mysupersecretpassword"
  permissions = [ "objects/query/service" ]
}
```

Please remember to set a reasonable check interval time. Usually it is a waste of bandwidth to poll feeds more often than each hour.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/feed> |
| Check Interval Recommendation         | Once an hour, or every 4 hours |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `BeautifulSoup4` (Version 4) with Python module `lxml` |
| Handles Periods                       | Yes |
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-monitoring-plugins-feed.db` |


## Help

```text
usage: feed [-h] [-V] [--always-ok]
            [--icinga-service-name ICINGA_SERVICE_NAME]
            [--icinga-password ICINGA_PASSWORD] [--icinga-url ICINGA_URL]
            [--icinga-username ICINGA_USERNAME] [--icinga-callback]
            [--insecure] [--latest] [--no-proxy] [--no-summary]
            [--timeout TIMEOUT] [--url FEED_URL] [-w WARN]

Monitors an RSS or Atom feed for new entries and alerts when new items appear
within a configurable time window (default: 3 days). If Icinga callback is
enabled, the alert is automatically cleared once the corresponding service is
acknowledged in Icinga. After the time window expires, the alert clears
regardless of acknowledgement status.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --icinga-service-name ICINGA_SERVICE_NAME
                        Unique name of the service using this check within
                        Icinga, taken from the `__name` service attribute.
                        Example: `icinga-server!my-service-name`.
  --icinga-password ICINGA_PASSWORD
                        Password for the Icinga API.
  --icinga-url ICINGA_URL
                        Icinga API URL. Example: `https://icinga-server:5665`.
  --icinga-username ICINGA_USERNAME
                        Username for the Icinga API.
  --icinga-callback     Query Icinga for the service acknowledgement state and
                        auto-clear alerts on ack. Default: False
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --latest              Return the newest feed item, even if its timestamp is
                        in the future.
  --no-proxy            Do not use a proxy.
  --no-summary          Suppress the feed item summary in the output. Default:
                        False
  --timeout TIMEOUT     Network timeout in seconds. Default: 5
  --url FEED_URL        RSS or Atom feed URL. Default:
                        https://www.heise.de/security/rss/alert-news-atom.xml
  -w, --warning WARN    Time window in minutes during which new feed entries
                        trigger a warning. Default: 4320
```


## Usage Examples

```bash
./feed
./feed --url https://github.com/Linuxfabrik/monitoring-plugins/releases.atom --warn 1440
./feed --icinga-url https://icinga-host:5665 --icinga-callback --icinga-username linuxfabrik-check-api-user --icinga-password mysupersecretpassword --icinga-service-name 'icinga-host!Feed Service Name' --url https://www.heise.de/security/rss/alert-news-atom.xml
```

Output:

```text
This is an important news item from a RSS feed. (2h 15m ago)
```

## Feed examples

Heise Security Feed (German):

* Feed: <https://www.heise.de/security/rss/alert-news-atom.xml>
* Run every hour, during office hours only (8 to 18 o'clock, Mo to Fr) - more often makes no sense
* Warn for 4 hours (240 minutes)
* Usage: `./feed`

Icinga2 Releases Feed on GitHub:

* Feed: <https://github.com/Icinga/icinga2/releases.atom>
* Run once or twice a day
* Warn for 24 hours (1440 minutes)
* No summary please, just the title (the new version string)
* Usage: `./feed --url https://github.com/Icinga/icinga2/releases.atom --no-summary --warn 1440`


## States

* WARN if current feed item is not acknowledged and not older than a given threshold.
* Otherwise always returns OK.


## Perfdata / Metrics

There is no perfdata.


## Troubleshooting

Python module "BeautifulSoup4" is not installed.  
```bash
sudo -u icinga python3 -m pip install --user BeautifulSoup4
```

Couldn't find a tree builder with the features you requested: xml. Do you need to install a parser library?  
```bash
sudo -u icinga python3 -m pip install --user lxml
```


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
