Check feed
==========

Overview
--------

This check warns on the newest feed item of an RSS or Atom feed for a given amount of time (default: 3 days). By default the check warns on the newest item published today or older (use ``--latest``  to change this behaviour). It strips HTML from the feed message.

With this check, you can acknowledge the warning in IcingaWeb, so that the check changes back to OK. To enable the check plugin to get the ACK status from Icinga and therefore automatically switch to OK, you have to create an Icinga API User like so:

.. code-block:: text

    object ApiUser "linuxfabrik-check-api-user" {
      password = "mysupersecretpassword"
      permissions = [ "objects/query/service" ]
    }

Please remember to set a reasonable check interval time. Usually it is a waste of bandwidth to poll feeds more often than each hour.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/feed"
    "Check Interval Recommendation",        "Once an hour, or every 4 hours"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux, Windows"
    "3rd Party Python modules",             "``BeautifulSoup4`` (Version 4) with Python module ``lxml``"
    "Handles Periods",                      "Yes"
    "Uses SQLite DBs",                      "``$TEMP/linuxfabrik-monitoring-plugins-feed.db``"


Help
----

.. code-block:: text

    usage: feed [-h] [-V] [--always-ok]
                [--icinga-service-name ICINGA_SERVICE_NAME]
                [--icinga-password ICINGA_PASSWORD] [--icinga-url ICINGA_URL]
                [--icinga-username ICINGA_USERNAME] [--icinga-callback]
                [--insecure] [--latest] [--no-proxy] [--no-summary]
                [--timeout TIMEOUT] [--url FEED_URL] [-w WARN]

    Warns on new feed items of an RSS or Atom feed. Does not warn any more if you
    acknowledge the warning in Icingaweb2, and/or if a given amount of time is
    over.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --icinga-service-name ICINGA_SERVICE_NAME
                            Unique name of the service using this check within
                            Icinga. Take it from the `__name` service attribute,
                            for example `icinga-server!my-service-name`.
      --icinga-password ICINGA_PASSWORD
                            Icinga API password.
      --icinga-url ICINGA_URL
                            Icinga API URL, for example https://icinga-server:5665
      --icinga-username ICINGA_USERNAME
                            Icinga API username.
      --icinga-callback     Get the service acknowledgement from Icinga. Default:
                            False
      --insecure            This option explicitly allows to perform "insecure"
                            SSL connections. Default: False
      --latest              Return the newest/latest feed item (may be in the
                            future).
      --no-proxy            Do not use a proxy. Default: False
      --no-summary          Do not show the feed item summary. Default: False
      --timeout TIMEOUT     Network timeout in seconds. Default: 5 (seconds)
      --url FEED_URL        The Feed URL. Default:
                            https://www.heise.de/security/rss/alert-news-atom.xml
      -w, --warning WARN    How long should this check return a warning on new
                            entries? Default: 4320 (minutes)


Usage Examples
--------------

.. code-block:: bash

    ./feed
    ./feed --url https://github.com/Linuxfabrik/monitoring-plugins/releases.atom --warn 1440
    ./feed --icinga-url https://icinga-host:5665 --icinga-callback --icinga-username linuxfabrik-check-api-user --icinga-password mysupersecretpassword --icinga-service-name 'icinga-host!Feed Service Name' --url https://www.heise.de/security/rss/alert-news-atom.xml

Output:

.. code-block:: text

    This is an important news item from a RSS feed. (2h 15m ago)


Feed examples
-------------

Heise Security Feed (German):

* Feed: https://www.heise.de/security/rss/alert-news-atom.xml
* Run every hour, during office hours only (8 to 18 o'clock, Mo to Fr) - more often makes no sense
* Warn for 4 hours (240 minutes)
* Usage: ``./feed``

Icinga2 Releases Feed on GitHub:

* Feed: https://github.com/Icinga/icinga2/releases.atom
* Run once or twice a day
* Warn for 24 hours (1440 minutes)
* No summary please, just the title (the new version string)
* Usage: ``./feed --url https://github.com/Icinga/icinga2/releases.atom --no-summary --warn 1440``


States
------

* WARN if current feed item is not acknowledged and not older than a given threshold.
* Otherwise always returns OK.


Perfdata / Metrics
------------------

There is no perfdata.


Troubleshooting
---------------

Python module "BeautifulSoup4" is not installed.
    .. code-block:: bash

        sudo -u icinga python3 -m pip install --user BeautifulSoup4

Couldn't find a tree builder with the features you requested: xml. Do you need to install a parser library?
    .. code-block:: bash

        sudo -u icinga python3 -m pip install --user lxml


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
