Check rocket.chat-stats
=======================

Overview
--------

This plugin lets you track statistics about a Rocket.Chat server. Requires a user with strong password and "view-statistics" permission (only).


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/rocket.chat-stats"
    "Check Interval Recommendation",        "Every 15 minutes"
    "Available for",                        "Python 2"
    "Requirements",                         "Python module ``psutil``, command-line tool ``foo``"
    "Handles Periods",                      "Yes"
    "Uses SQLite DBs",                      "Yes"
    "Perfdata compatible with Prometheus",  "Yes"


Help
----

.. code-block:: text

    usage: example [-h] [-V]

    Example Check.

    optional arguments:
      -h, --help       show this help message and exit
      -V, --version    show program's version number and exit


Usage Examples
--------------

.. code-block:: bash

    ./rocket.chat-stats --username rocket-stats --password mypassword --url http://localhost:3000/api/v1
    
Output:

.. code-block:: text

    TODOVM Output


States
------

* Always returns OK.


Perfdata / Metrics
------------------

* Online Users
* Total Direct Messages
* Total Livechat
* Total Livechat Messages
* Total Livechat Visitors
* Total Messages
* Total Private Group Messages
* Total Private Groups
* Total Rooms
* Total Users
* Uploads Total
* Uploads Total Size (Byte)


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
