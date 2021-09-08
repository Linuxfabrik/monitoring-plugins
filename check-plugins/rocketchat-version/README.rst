Check rocketchat-version
=========================

Overview
--------

This plugin lets you track if a Rocket.Chat server update is available. To check for updates, this plugin uses the Git Repo at https://github.com/RocketChat/Rocket.Chat/releases. To compare against the current/installed version of Rocket.Chat, the check needs URL/API access to the Rocket.Chat server.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/rocketchat-version"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "No"
    "Available for",                        "Python 2"
    "Requirements",                         "Requires a user with strong password and 'view-statistics' permission (only)."
    "Uses SQLite DBs",                      "Yes"


Help
----

.. code-block:: text

    usage: rocketchat-version [-h] [-V] [--always-ok]
                               [--cache-expire CACHE_EXPIRE] -p PASSWORD
                               [--url URL] --username USERNAME

    This plugin lets you track if server updates are available. Requires a user
    with strong password and "view-statistics" permission (only).

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --cache-expire CACHE_EXPIRE
                            The amount of time after which the update check cache
                            expires, in hours. Default: 24
      -p PASSWORD, --password PASSWORD
                            Rocket.Chat API password.
      --url URL             Rocket.Chat API URL. Default:
                            http://localhost:3000/api/v1
      --username USERNAME   Rocket.Chat API username. Default: rocket-stats


Usage Examples
--------------

.. code-block:: bash

    ./rocketchat-version --username rocket-stats --password mypassword --url http://rocket:3000/api/v1 --cache-expire 8 --always-ok
    
Output:

.. code-block:: text

    Rocket.Chat v3.15.0 is up to date


States
------

* If wanted, always returns OK,
* else returns WARN if update is available.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
