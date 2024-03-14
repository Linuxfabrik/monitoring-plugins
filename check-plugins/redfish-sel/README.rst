Check redfish-sel
=================

Overview
--------

Checks the System Event Log (SEL) of the Redfish Manager collection. Returns an alert based on the severity of the messages.

Tested on:

* DELL iDRAC
* DMTF Simulator

Hints:

* This check runs with both http and https. It just uses GET requests.
* No additional Python Redfish modules need to be installed.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/redfish-sel"
    "Check Interval Recommendation",        "Every 15 minutes"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux, Windows"


Help
----

.. code-block:: text

    usage: redfish-sel [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                       [--password PASSWORD] [--timeout TIMEOUT] [--url URL]
                       [--username USERNAME]

    Checks the System Event Log (SEL) of the Redfish Manager collection. Returns
    an alert based on the severity of the messages.

    options:
      -h, --help           show this help message and exit
      -V, --version        show program's version number and exit
      --always-ok          Always returns OK.
      --insecure           This option explicitly allows to perform "insecure" SSL
                           connections. Default: True
      --no-proxy           Do not use a proxy. Default: False
      --password PASSWORD  Redfish API password.
      --timeout TIMEOUT    Network timeout in seconds. Default: 8 (seconds)
      --url URL            Redfish API URL. Default: https://localhost:5000
      --username USERNAME  Redfish API username.


Usage Examples
--------------

.. code-block:: bash

    ./redfish-sel --url https://bmc --username redfish-monitoring --password 'mypassword'

Output:

.. code-block:: text

    Checked SEL on 1 member. There are critical errors.

    Member: /redfish/v1/Managers/iDRAC.Embedded.1
    * 2021-10-14T10:32:20+02:00: The system inlet temperature is greater than the upper warning threshold. [WARNING]
    * 2021-10-14T09:52:27+02:00: The system inlet temperature is greater than the upper warning threshold. [WARNING]
    * 2021-10-14T02:02:47+02:00: The system inlet temperature is greater than the upper critical threshold. [CRITICAL]
    * 2021-10-14T00:10:12+02:00: The system inlet temperature is greater than the upper warning threshold. [WARNING]


States
------

* CRIT if severity of the message is equal to "Critical".
* WARN if severity of the message is equal to "Warning".
* Otherwise returns OK.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
