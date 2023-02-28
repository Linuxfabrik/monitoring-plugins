Check cometsystem
=================

Overview
--------

This check targets the JSON endpoint of `COMET SYSTEM <https://www.cometsystem.com/>`_ Web Sensors.
Alert states can be set per measurement and on low and high threshold violations.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/cometsystem"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 3, Windows"
    "Requirements",                         "None ?"


Help
----

.. code-block:: text

    usage: cometsystems [-h] [-V] [--always-ok] [--insecure]
                        [--no-proxy] [--low LIST] [--high LIST] [--perfdata]
                        [--timeout TIMEOUT] [-u URL]

    This check targets the JSON endpoint of https://www.cometsystem.com/ Web Sensors.
    Alert states can be set per measurement and on low and high threshold violations.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --filename FILENAME   Set the path of the json file. This is mutually
                            exclusive with -u / --url.
      --high                comma sparated states [OK,CRITCAL,WARNING] per sensor value
                            If only one state is provided it gets applied to all high
			    threashold volations.
                            Default: CRITCAL
      --insecure            This option explicitly allows to perform "insecure"
                            SSL connections. Default: False
      --low                 comma sparated states [OK,CRITCAL,WARNING] per sensor value.
                            If only one state is provided it gets applied to all low
			    threashold volations
                            Default: WARN
      --no-proxy            Do not use a proxy. Default: False
      --perfdata            send perfdata. Default: False
      --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
      -u URL, --url URL     Set the URL of the values as JSON.  http://example.com/values.jsonfile


Usage Examples
--------------

.. code-block:: bash

    ./commetsystem --url=http://example.com/values.jsonfile --perfdata

    cat > /tmp/example.json2 << 'EOF'
    {
     "devname":"example",
     "devsn":"12345678",
     "time":"15:30:33 2022-12-07",
     "timeunix":"1670427033",
     "synch":"1",
     "ch1":
     {
      "name":"Temperature",
      "unit":"�C",
      "aval":"28.9",
      "alarm":0
     },
     "ch2":
     {
      "name":"Relative humidity",
      "unit":"%RH",
      "aval":"15.8",
      "alarm":0
     },
     "ch3":
     {
      "name":"Dew point",
      "unit":"�C",
      "aval":"0.4",
      "alarm":0
     },
     "ch4":
     {
      "name":"n/a",
      "unit":"n/a",
      "aval":"Error 2",
      "alarm":0
     }
    }
    EOF
    ./json-values --filename=/tmp/example.json

Output:

.. code-block:: text

    [OK] 28.9°C, 15.8%RH, Dew point 0.4°C |'Temperature'=28.9C;;;0;100 'Relative humidity'=15.8%;;0;100 'Dew point'=0.4C;;;0;100


States
------

* Exits with the state from the json array.


Perfdata / Metrics
------------------

Returns the perfdata from the aval in the JSON per Channel if requested.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_; originally written by Dominik Riva, Universitätsspital Basel/Switzerland
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
