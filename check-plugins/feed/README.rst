Check "feed"
============

Overview
--------

This check warns on the newest feed item of an RSS or Atom feed for a given amount of time (default: 3 days). By default the check warns on the newest item published today or older (use ``--latest``  to change this behaviour). It strips HTML from the feed message.

With this check, you can acknowledge the warning in IcingaWeb, so that the check changes back to OK. To enable the check plugin to get the ACK status from Icinga and therefore automatically switch to OK, you have to create an Icinga API User like so::

    object ApiUser "linuxfabrik-check-api-user" {
      password = "mysupersecretpassword"
      permissions = [ "objects/query/service" ]
    }

Please remember to set a reasonable check interval time. Usually it is a waste of bandwidth to poll feeds more often than each hour.


Installation and Usage
----------------------

Requirements:

* Python2 module ``BeautifulSoup4`` (Version 4) with ``lxml``

Where to get BeautifulSoup:

* In your venv using pip: ``pip install beautifulsoup lxml``
* CentOS 7: ``yum install python-beautifulsoup4``
* CentOS 8: ``dnf install python2-beautifulsoup4``
* On Fedora and Ubuntu, one way is to download the [Beautiful Soup 4 source tarball](https://www.crummy.com/software/BeautifulSoup/bs4/download/4.9/beautifulsoup4-4.9.3.tar.gz) and install it with ``python2 setup.py install``.

.. code-block:: bash

    ./feed
    ./feed --url https://github.com/Icinga/icinga2/releases.atom --no-summary --warn 1440
    ./feed --icinga-url https://icinga-host:5665 --icinga-callback --icinga-username linuxfabrik-check-api-user --icinga-password mysupersecretpassword --icinga-service-name 'icinga-host!Feed Service Name' --url https://www.heise.de/security/rss/alert-news-atom.xml
    ./feed --help


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


Perfdata
--------

There is no perfdata.


Credits, License
----------------

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
