Check "metabase-stats"
======================

Overview
--------

Getting some statistics from `Metabase <https://www.metabase.com>`_.

Read the `Metabase API Documentation <https://www.metabase.com/learn/developing-applications/advanced-metabase/metabase-api.html#authenticate-your-requests-with-a-session-token>`_ to note some things about user credentials and sessions. The check plugin caches credentials to reuse them until they expire, because logins to Metabase are rate-limited for security. You must use a Metabase superuser.

We recommend running this check every hour.


Installation and Usage
----------------------

.. code-block:: bash

    ./metabase-stats
    ./metabase-stats  -username user --password pass --url http://metabase:3000
    ./metabase-stats --help

Output::

    MyCube on Metabase v0.39.1; 8 users, 1 DB analyzed, 55 questions (GUI), 0 alerts, 0 pulses, 13 collections; 6 CPUs, 5462 MiB RAM
    Last activity: "card-create/My Card" by John Doe (3D 16h ago)


States
------

Always returns OK.


Perfdata
--------

* alerts
* collections
* cpu
* dbs_analyzed
* memory
* pulses
* questions_gui
* users


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see LICENSE file.
