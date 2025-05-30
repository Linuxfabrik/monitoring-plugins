Check qts-temperatures
======================

Overview
--------

Checks system and CPU temperatures. All temperatures are expressed in celsius. Temperature thresholds are determined automatically.

Hints and Recommendations:

* Tested on `QuTScloud <https://www.qnap.com/en-us/download?model=qutscloud&category=firmware>`_ v4.5.6+
* The user used for monitoring must be a member of the "administrators" group. It is not sufficient to be a member of the "everyone" group.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/qts-temperatures"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "No"
    "Compiled for Windows",                 "No"


Help
----

.. code-block:: text

    usage: qts-temperatures [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                            --password PASSWORD [--timeout TIMEOUT] --url URL
                            [--username USERNAME]

    Checks the current temperatures from QNAP Appliances running QTS via API.

    options:
      -h, --help           show this help message and exit
      -V, --version        show program's version number and exit
      --always-ok          Always returns OK.
      --insecure           This option explicitly allows to perform "insecure" SSL
                           connections. Default: False
      --no-proxy           Do not use a proxy. Default: False
      --password PASSWORD  QTS Password.
      --timeout TIMEOUT    Network timeout in seconds. Default: 6 (seconds)
      --url URL            QTS-based Appliance URL, for example
                           https://192.168.1.1:8080.
      --username USERNAME  QTS User. Default: admin


Usage Examples
--------------

.. code-block:: bash

    ./qts-temperatures --url http://qts:8080 --username admin --password linuxfabrik --insecure
    
Output:

.. code-block:: text

    Sys: 59°C (Thresholds: 60/70°C), CPU: 82°C (Thresholds: 80/85°C) [WARNING]


States
------

* WARN or CRIT if temperature for a sensor is above the given thresholds.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    cputemp,                                    Number,             CPU temperature in °C.
    systemp,                                    Number,             System temperature in °C.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
