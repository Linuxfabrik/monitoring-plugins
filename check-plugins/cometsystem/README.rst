Check cometsystem
=================

Overview
--------

This check targets the JSON endpoint of `COMET SYSTEM <https://www.cometsystem.com/>`_ Web Sensors.
Alert states can be set per measurements low and high threshold violations.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/cometsystem"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "No"
    "Available for",                        "Python 3, Windows"
    "Requirements",                         "None"


Help
----

.. code-block:: text

    usage: cometsystem3 [-h] [-V] [--always-ok] [--channels CHANNELS] [--high HIGH] [--insecure] [--low LOW] [--no-proxy]
                    [--perfdata] [--test TEST] [--timeout TIMEOUT] -u URL

    This check targets the JSON endpoint of https://www.cometsystem.com/ Web Sensors. Alert states can be set per
    measurements low and high threshold violations.

    optional arguments:
    -h, --help           show this help message and exit
    -V, --version        show program's version number and exit
    --always-ok          Always returns OK.
    --channels CHANNELS  comma separated channels of sensor. Default: ['ch1', 'ch2', 'ch3']
    --high HIGH          comma separated states [OK,CRITCAL,WARNING] per sensor value. If only one state is provided it
                         gets applied to all highthreashold volations. Default: CRITICAL
    --insecure           This option explicitly allows to perform "insecure" SSL connections. Default: False
    --low LOW            comma separated states [OK,CRITCAL,WARNING] per sensor value. If only one state is provided it
                         gets applied to all lowthreashold volations. Default: WARNING
    --no-proxy           Do not use a proxy. Default: False
    --perfdata           send perfdata. Default: False
    --test TEST          For unit tests. Needs "path-to-stdout-file,path-to-stderr-file,expected-retc".
    --timeout TIMEOUT    Network timeout in seconds. Default: 3 (seconds)
    -u URL, --url URL    Set the URL of the values as JSON. http://example.com/values.json


Usage Examples
--------------

.. code-block:: bash

    ./cometsystem3 --url http://example.com/values.json --perfdata


Output:

.. code-block:: text

    [CRITICAL] Temperature high: 27.3 °C
    ch1 = Temperature 27.3 °C high [CRITICAL]
    ch2 = Relative humidity 43.1 %RH
    ch3 = Dew point 13.7 °C low [WARNING]|'Temperature'=27.3C;;;; 'Relative humidity'=43.1%;;;0;100 'Dew point'=13.7C;;;;


States
------

* By default WARN for low alarm and CRIT for high alarm threshold violations.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1

    Name,                                       Type,               Description
    Temperature,                                C,                  Temperature in ° Celsius.
    Relative humidity,                          Percentage,         Relative humidity.
    Dew point,                                  C                   Temperature at which condensation starts.
    Atmospheric pressure,                       hPa                 Barometric pressure or weight of the atmospher above.



Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_; originally written by Dominik Riva, Universitätsspital Basel/Switzerland
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
