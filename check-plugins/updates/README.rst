Check updates
=============

Overview
--------

Checks the the number of pending Windows updates.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/updates"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 3, Windows"
    "Requirements",                         "Python module ``psutil``"


Help
----

.. code-block:: text

    usage: updates [-h] [-V] [--always-ok] [-c CRIT] [-w WARN]

    Checks the number of pending updates.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      -c CRIT, --critical CRIT
                            Set the critical threshold for the number of pending
                            updates. Default: 50
      -w WARN, --warning WARN
                            Set the warning threshold for the number of pending
                            updates. Default: 2


Usage Examples
--------------

.. code-block:: bash

    ./updates --critical 10
    
Output:

.. code-block:: text

    TODO


States
------

* WARN or CRIT if number of updates is above a given threshold.


Perfdata / Metrics
------------------

* ``pending_updates``: Number of pending updates.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
