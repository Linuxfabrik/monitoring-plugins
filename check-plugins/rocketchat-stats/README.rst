Check rocketchat-stats
=======================

Overview
--------

This plugin lets you track statistics about a Rocket.Chat server.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/rocketchat-stats"
    "Check Interval Recommendation",        "Every 15 minutes"
    "Can be called without parameters",     "No"
    "Available for",                        "Python 2, Python 3, Windows"
    "Requirements",                         "Requires a user with strong password and 'view-statistics' permission (only)."


Help
----

.. code-block:: text

    usage: rocketchat-stats [-h] [-V] -p PASSWORD [--url URL] --username
                             USERNAME

    This plugin lets you track statistics about a Rocket.Chat server. Requires a
    user with strong password and (just) "view-statistics" permission.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      -p PASSWORD, --password PASSWORD
                            Rocket.Chat API password.
      --url URL             Rocket.Chat API URL. Default:
                            http://localhost:3000/api/v1
      --username USERNAME   Rocket.Chat API username. Default: rocket-stats


Usage Examples
--------------

.. code-block:: bash

    ./rocketchat-stats --username rocket-stats --password mypassword --url http://rocket:3000/api/v1
    
Output:

.. code-block:: text

    178 users (26 online), 147778 msgs, 2506 uploads, 2.7GiB uploads total size, v3.15.0
    
    394 rooms, 56 private groups, 70506 private group msgs, 75791 direct msgs
    78 livechat visitors, 95 livechats, 1478 livechat msgs


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
