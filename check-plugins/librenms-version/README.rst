Check librenms-version
======================

Overview
--------

Displays LibreNMS instance information. This is not a "is there a new version out there" check as LibreNMS is capable of updating itself (if running the Git version).

You need to create an API token for a user with "Global Read" level (login with an admin account, then go to LibreNMS > Gear Icon > API > API Settings, choose this user and create the API token).


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/librenms-version"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "No"
    "Available for",                        "Python 2, Python 3, Windows"
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

    LibreNMS 21.6.0 (Git: HEAD), DB-Schema 2021_06_07_123600_create_sessions_table (211), MariaDB 10.6.3-MariaDB, NET-SNMP 5.8, PHP 8.0.8, Python 3.6.8, RRD-Tool 1.7.0


States
------

* Always returns OK.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    librenms-version,                           Float,              Version number as a floating point number
    mysql-version,                              Float,              Version number as a floating point number
    netsnmp-version,                            Float,              Version number as a floating point number
    php-version,                                Float,              Version number as a floating point number
    python-version,                             Float,              Version number as a floating point number
    rrdtool-version,                            Float,              Version number as a floating point number


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
