Check librenms-alerts
=====================

Overview
--------

LibreNMS includes a highly customizable alerting system. The system requires a set of user-defined rules to evaluate the situation of each device, port, service or any other entity. This check warns about unacknowledged alerts in LibreNMS and reports the latest of the most critical alerts of each device.

You need to create an API token for a user with "Global Read" level (login with an admin account, then go to LibreNMS > Gear Icon > API > API Settings, choose this user and create the API token).


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/librenms-alerts"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "No"
    "Available for",                        "Python 2"
    "Requirements",                         "LibreNMS API Token"


Help
----

.. code-block:: text

    usage: librenms-alerts [-h] [-V] [--always-ok] [--insecure] [--lengthy]
                           [--no-proxy] [--timeout TIMEOUT] --token TOKEN
                           [--url URL]

    This check fetches information from a LibreNMS instance, using its API.

    optional arguments:
      -h, --help         show this help message and exit
      -V, --version      show program's version number and exit
      --always-ok        Always returns OK.
      --insecure         This option explicitly allows to perform "insecure" SSL
                         connections. Default: False
      --lengthy          Extended reporting.
      --no-proxy         Do not use a proxy. Default: False
      --timeout TIMEOUT  Network timeout in seconds. Default: 3 (seconds)
      --token TOKEN      LibreNMS API token
      --url URL          LibreNMS API URL. Default: http://localhost


Usage Examples
--------------

.. code-block:: bash

    ./librenms-alerts --url http://librenms --token 03xyza61e74a9876f3dc7ab11234229d

Output:

.. code-block:: text

    There are one or more criticals.

    Hostname     SysName         Alerts Worst State Latest & Worst Msg                    
    --------     -------         ------ ----------- ------------------                    
    10.80.32.109 S3900-48T4S     1      [CRITICAL]  Device Down! Due to no ICMP response. 
    10.80.32.141 switch99        3      [CRITICAL]  Port status up/down
    10.80.32.12  brw38b1db3b30f4 0      [OK]                                              
    10.80.32.1   router01        0      [OK]                                              
    10.80.32.50                  0      [OK]                                              
    10.80.32.58                  0      [OK]


States
------

* CRIT on criticals in LibreNMS
* WARN on warnings in LibreNMS
* OK on OK in LibreNMS


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
