Check cometsystem
=================

Overview
--------

This check targets the JSON endpoint of a `COMET SYSTEM <https://www.cometsystem.com/>`_ Web Sensor. Cometsystem web sensors allow configuration of two separate alarms for each channel. The alarm mode selects the direction of the alarm - lower than limit, higher than limit or disabled. This check plugin allows you to define a severity for each channel and alarm mode.

The repeating ``--severity`` parameter can be set in different ways:

* ``--severity ok|warn|crit|unknown``: High and low alarm severity for all channels and all alarm modes.
* ``--severity part-of-channel-name:ok|warn|crit|unknown``: High and low alarm severity for a specific channel and all alarm modes. You just need to specify a part of the channel name. Case-insensitive.
* ``--severity part-of-channel-name:low|high:ok|warn|crit|unknown``: Alarm severity for a specific channel and a specific alarm mode.

The order of ``--severity`` matters, the first match wins.

Example:

.. code-block:: bash

    ./cometsystem --url http://example.com/values.json --severity temp:high:crit --severity humi:ok --severity warn

Here, the check raises critical for any channel with "temp" in its name on high alarms only, returns ok for any alarm in channels with "humi" in their name, and finally warns on all other alarms in all other channels. The last ``--severity warn`` can be omitted as this is the default behavior.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/cometsystem"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "No"
    "Compiled for",                         "Linux, Windows"


Help
----

.. code-block:: text

    usage: cometsystem [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                       [--severity SEVERITY] [--test TEST] [--timeout TIMEOUT] -u
                       URL

    This check targets the JSON endpoint of https://www.cometsystem.com/ Web
    Sensors.

    options:
      -h, --help           show this help message and exit
      -V, --version        show program's version number and exit
      --always-ok          Always returns OK.
      --insecure           This option explicitly allows to perform "insecure" SSL
                           connections. Default: False
      --no-proxy           Do not use a proxy. Default: False
      --severity SEVERITY  Severity for alerting, order matters, first match on
                           part of a channel name wins. Have a look at the README
                           for details. Example: `--severity temp:high:crit
                           --severity dew:low:crit --severity humi:ok --severity
                           warn`. Repeating. Default: warn
      --test TEST          For unit tests. Needs "path-to-stdout-file,path-to-
                           stderr-file,expected-retc".
      --timeout TIMEOUT    Network timeout in seconds. Default: 5 (seconds)
      -u URL, --url URL    Comet system URL pointing to the JSON file
                           (http://example.com/values.json).


Usage Examples
--------------

.. code-block:: bash

    ./cometsystem --url http://example.com/values.json --severity temp:high:crit --severity dew:ok

Output:

.. code-block:: text

    There are critical errors on Web Sensor SN 17965562.

    Ch# ! Name                 ! Alarm ! Value            
    ----+----------------------+-------+------------------
    ch1 ! Temperature          ! high  ! 27.3C [CRITICAL] 
    ch2 ! Relative humidity    !       ! 43.1%RH          
    ch3 ! Dew point            ! low   ! 13.7C
    ch4 ! Atmospheric pressure !       ! 958.6hPa


States
------

* WARN for any alarm threshold violations.


Perfdata / Metrics
------------------

Name of the channel and its value, depend on the Web Sensor model and its configuration. For example:

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1

    Name,                                       Type,               Description
    Atmospheric pressure,                       Number              Barometric pressure or weight of the atmosphere above.
    Dew point,                                  Number              Temperature at which condensation starts.
    Relative humidity,                          Percentage,         Relative humidity.
    Temperature,                                Number              Temperature in C or F.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_; originally written by Dominik Riva, Universitätsspital Basel/Switzerland
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
