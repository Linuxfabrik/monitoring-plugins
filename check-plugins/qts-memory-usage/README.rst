Check qts-memory-usage
======================

Overview
--------

Returns the current system-wide memory utilization as a percentage from a QNAP Appliance running QTS, using the HTTP API.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/qts-memory-usage"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "No"
    "Compiled for",                         "Linux, Windows"


Help
----

.. code-block:: text

    usage: qts-memory-usage [-h] [-V] [--always-ok] [-c CRIT] [--insecure]
                            [--no-proxy] --password PASSWORD [--timeout TIMEOUT]
                            --url URL [--username USERNAME] [-w WARN]

    Returns the current system-wide Memory utilization as a percentage from QNAP
    Appliances running QTS via API.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      -c CRIT, --critical CRIT
                            Set the critical threshold Memory Usage Percentage.
                            Default: 90
      --insecure            This option explicitly allows to perform "insecure"
                            SSL connections. Default: False
      --no-proxy            Do not use a proxy. Default: False
      --password PASSWORD   QTS Password.
      --timeout TIMEOUT     Network timeout in seconds. Default: 6 (seconds)
      --url URL             QTS-based Appliance URL, for example
                            https://192.168.1.1:8080.
      --username USERNAME   QTS User. Default: admin
      -w WARN, --warning WARN
                            Set the warning threshold Memory Usage Percentage.
                            Default: 80


Usage Examples
--------------

.. code-block:: bash

    ./qts-memory-usage --url http://qts:8080 --username admin --password my-password
    
Output:

.. code-block:: text

    7.33% - total: 62.8GiB, used: 4.6GiB, free: 58.2GiB


States
------

* OK if overall ``memory-usage`` is below the thresholds.
* Otherwise CRIT or WARN.


Perfdata / Metrics
------------------

* ``memory-usage``: The overall memory usage.
* ``free``: The free memory.
* ``total``: The total memory.
* ``used``: The used memory.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
