Check fah-stats
===============

Overview
--------

.. hint::

    As already filed `here <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/issues/198>`_, the check does not work.

Returns information about a specific team or donor at Folding@Home.

No need to run this every minute (depends on your number of team members and/or active CPUs).


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/fah-stats"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2"
    "Requirements",                         "None"


Help
----

.. code-block:: text

    usage: fah-stats [-h] [--donor DONOR] [-V] [--team TEAM] [--timeout TIMEOUT]
                     [-u URL]

    Returns information about a specific team or donor at Folding@Home.

    optional arguments:
      -h, --help         show this help message and exit
      --donor DONOR      Folding@Home Donor ID. Mutually exclusive with --team
      -V, --version      show program's version number and exit
      --team TEAM        Folding@Home Team ID. Mutually exclusive with --donor.
                         Default: 260774
      --timeout TIMEOUT  Network timeout in seconds. Default: 7 (seconds)
      -u URL, --url URL  Folding@Home Team Stats API URL. Default:
                         https://stats.foldingathome.org/api/


Usage Examples
--------------

.. code-block:: bash

    ./fah-stats --team 260774
    ./fah-stats --donor 105577492
    
Output:

.. code-block:: text

    TODO


States
------

* Always returns OK.


Perfdata / Metrics
------------------

* active_50: Active CPUs within 50 days
* credit: Grand Score
* donors: Number of Team Members (only when querying for a team)
* rank: Team Ranking
* wus: Work Unit Count


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
