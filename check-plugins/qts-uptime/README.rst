Check qts-uptime
================

Overview
--------

Checks and tells how long the system has been running (in days).


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/qts-uptime"
    "Check Interval Recommendation",        "Every 5 minutes"
    "Can be called without parameters",     "No"
    "Available for",                        "Python 2, Python 3, Windows"
    "Requirements",                         "None"


Help
----

.. code-block:: text

    usage: qts-uptime [-h] [-V] --url URL [--insecure] [--no-proxy]
                      [--username USERNAME] --password PASSWORD
                      [--timeout TIMEOUT]

    Tells how long the system has been running.

    optional arguments:
      -h, --help           show this help message and exit
      -V, --version        show program's version number and exit
      --url URL            QTS-based Appliance URL, for example
                           https://192.168.1.1:8080.
      --insecure           This option explicitly allows to perform "insecure" SSL
                           connections. Default: False
      --no-proxy           Do not use a proxy. Default: False
      --username USERNAME  QTS User. Default: admin
      --password PASSWORD  QTS Password.
      --timeout TIMEOUT    Network timeout in seconds. Default: 3 (seconds)


Usage Examples
--------------

.. code-block:: bash

    ./qts-uptime --url http://192.168.1.100:8080 --username admin --password my-password
    
Output:

.. code-block:: text

    Up 1W 6D


States
------

* Always returns OK.


Perfdata / Metrics
------------------

* Uptime (seconds)


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
