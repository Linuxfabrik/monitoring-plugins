Check sensors-temperatures
==========================

Overview
--------

Certain hardware temperature sensors may be returned (it could be a CPU, a hard disk or something else, depending on the operating system and its configuration). All temperatures are expressed in Celsius. Checks are performed automatically against hardware thresholds. If the sensors are not supported by the OS, 'OK' is returned.

Hints:

* Run ``sensors-detect --auto`` beforehand to scan your system for the various hardware monitoring chips or sensors supported by libsensors or, more generally, by the lm_sensors tool suite.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/sensors-temperatures"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Compiled for Windows",                 "No"
    "3rd Party Python modules",             "``psutil``"


Help
----

.. code-block:: text

    usage: sensors-temperatures [-h] [-V] [--always-ok]

    Return certain hardware temperature sensors (it may be a CPU, an hard disk or
    something else, depending on the OS and its configuration). All temperatures
    are expressed in celsius. Check is done automatically against hardware
    thresholds. If sensors are not supported by the OS OK is returned.

    options:
      -h, --help     show this help message and exit
      -V, --version  show program's version number and exit
      --always-ok    Always returns OK.


Usage Examples
--------------

.. code-block:: bash

    ./sensors-temperatures
    
Output:

.. code-block:: text

    * nvme: Composite = 42.85°C, Sensor 1 = 42.85°C
    * coretemp: Package id 0 = 52.0°C, Core 0 = 50.0°C, Core 1 = 52.0°C, Core 2 = 51.0°C, Core 3 = 50.0°C, Package id 0 = 52.0°C, Core 0 = 50.0°C, Core 1 = 52.0°C, Core 2 = 51.0°C, Core 3 = 50.0°C
    * iwlwifi_1: iwlwifi_1 = 46.0°

States
------

* WARN or CRIT if temperature for a sensor is above a given hardware threshold (automatically).


Perfdata / Metrics
------------------

* temperature for each sensor found (°C)


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
* Credits: https://github.com/giampaolo/psutil/blob/master/scripts/temperatures.py
