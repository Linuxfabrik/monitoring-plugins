Check librenms-version
======================

Overview
--------

Displays LibreNMS instance information. This is not a "is there a new version out there" check as LibreNMS is capable of updating itself (if running the Git version).


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/librenms-alerts"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "No"
    "Available for",                        "Python 2"
    "Requirements",                         "LibreNMS"


Help
----

.. code-block:: text

    usage: librenms-version [-h] [-V] [--insecure] [--no-proxy]
                            [--timeout TIMEOUT] --token TOKEN [--url URL]

    This check displays LibreNMS instance information, using its API.

    optional arguments:
      -h, --help         show this help message and exit
      -V, --version      show program's version number and exit
      --insecure         This option explicitly allows to perform "insecure" SSL
                         connections. Default: False
      --no-proxy         Do not use a proxy. Default: False
      --timeout TIMEOUT  Network timeout in seconds. Default: 3 (seconds)
      --token TOKEN      LibreNMS API token
      --url URL          LibreNMS API URL. Default: http://localhost


Usage Examples
--------------

.. code-block:: bash

    ./librenms-version --url http://librenms --token 03xyza61e74a9876f3dc7ab11234229d

Output:

.. code-block:: text

    LibreNMS 21.4.0 (HEAD), DB-Schema 2021_04_08_151101_add_foreign_keys_to_port_group_port_table (208), MariaDB 10.6.0-MariaDB, NET-SNMP 5.8, PHP 8.0.5, Python 3.6.8, RRD-Tool 1.7.0|'librenms-version'=21.4;;;0;


States
------

* Always returns OK.


Perfdata / Metrics
------------------

* librenms-version: Float


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
