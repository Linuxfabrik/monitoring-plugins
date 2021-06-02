Check mailq
===========

Overview
--------

Checks the mail queue. Tested with Postfix and Exim.

Regarding Exim: _By default, ``exim -bq`` (``mailq``) can be used only by an admin user. However, the ``queue_list_requires_admin`` option can be set false to allow any user to see the queue._ Alternatively, add the icinga user to the exim group.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/mailq"
    "Check Interval Recommendation",        "Every 5 minutes"
    "Available for",                        "Python 2"
    "Requirements",                         "Python module ``psutil``, command-line tool ``mailq``"
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

    ./mailq
    ./mailq --warning 2 --critical 250
    
Output:

.. code-block:: text

    TODOVM Output


States
------

* WARN on error messages from mailq.
* WARN or CRIT if number of messages is greater than or equal to the thresholds.


Perfdata / Metrics
------------------

* mailq: Mails in mail queue


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
