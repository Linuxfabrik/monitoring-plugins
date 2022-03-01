Check qts-temperatures
======================

Overview
--------

Returns system and CPU temperatures. All temperatures are expressed in celsius.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/qts-temperatures"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "No"
    "Available for",                        "Python 2, Python 3, Windows"
    "Requirements",                         "None"


Help
----

.. code-block:: text

    usage: qts-temperatures [-h] [-V] [--always-ok] [-c CRIT] [--insecure]
                            [--no-proxy] --password PASSWORD [--timeout TIMEOUT]
                            --url URL [--username USERNAME] [-w WARN]

    Returns the current temperatures from QNAP Appliances running QTS via API.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      -c CRIT, --critical CRIT
                            Set the critical threshold for the sytem and CPU
                            temperature. Default: 80
      --insecure            This option explicitly allows to perform "insecure"
                            SSL connections. Default: False
      --no-proxy            Do not use a proxy. Default: False
      --password PASSWORD   QTS Password.
      --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
      --url URL             QTS-based Appliance URL, for example
                            https://192.168.1.1:8080.
      --username USERNAME   QTS User. Default: admin
      -w WARN, --warning WARN
                            Set the warning threshold for the sytem and CPU
                            temperature. Default: 70



Usage Examples
--------------

.. code-block:: bash

    ./qts-temperatures --url http://qts:8080 --username admin --password my-password
    
Output:

.. code-block:: text

    Sys: 37°C, CPU: 60°C


States
------

* WARN or CRIT if temperature for a sensor is above the given thresholds.


Perfdata / Metrics
------------------

* temperature for system and CPU (°C)


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
