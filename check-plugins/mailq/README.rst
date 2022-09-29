Check mailq
===========

Overview
--------

Checks the mail queue. Tested with Postfix and Exim.

Hints:

* Exim: By default, ``exim -bq`` (alias ``mailq``) can be used only by an admin user. However, the ``queue_list_requires_admin`` option can be set false to allow any user to see the queue. Alternatively, add the icinga user to the exim group.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mailq"
    "Check Interval Recommendation",        "Every 5 minutes"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2, Python 3"
    "Requirements",                         "command-line tool ``mailq``"


Help
----

.. code-block:: text

    usage: mailq [-h] [-V] [--always-ok] [-c CRIT] [--test TEST] [-w WARN]

    Checks the mail queue.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      -c CRIT, --critical CRIT
                            Set the critical threshold for mails in the queue.
                            Default: 250
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".
      -w WARN, --warning WARN
                            Set the warning threshold for mails in the queue.
                            Default: 2


Usage Examples
--------------

.. code-block:: bash

    ./mailq --warning 2 --critical 250
    
Output:

.. code-block:: text

    4 mails to deliver.


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
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
