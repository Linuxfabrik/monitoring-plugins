Check librenms-health
=====================

Overview
--------

Get health details of all devices in LibreNMS (mostly for debugging purposes). Depending on the number of devices and their sensors, the execution can take 3 seconds or longer.

.. hint::

    This check could, but does not return any performance data, as LibreNMS offers direct integration into various time series databases like Graphite, InfluxDB, OpenTSDB, Prometheus and RRDTool. The configuration options can be found in LibreNMS under Settings > Global Settings > Poller > Datastore.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/librenms-alerts"
    "Check Interval Recommendation",        "Once an hour"
    "Can be called without parameters",     "No"
    "Available for",                        "Python 2"
    "Requirements",                         "LibreNMS"


Help
----

.. code-block:: text

    usage: librenms-health [-h] [-V] [--insecure] [--lengthy] [--no-proxy]
                           [--timeout TIMEOUT] --token TOKEN [--url URL]

    This check fetches information from a LibreNMS instance, using its API.

    optional arguments:
      -h, --help         show this help message and exit
      -V, --version      show program's version number and exit
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

    ./librenms-health --url http://librenms --token 03xyza61e74a9876f3dc7ab11234229d

Output:

.. code-block:: text

    Everything is ok.

    Hostname     SysName         Sensor                      Val (prev)  Limit low/high 
    --------     -------         ------                      ----------  -------------- 
    10.80.32.109 S3900-48T4S     Oper State                  3 (None)    None/None      
    10.80.32.109 S3900-48T4S     Temperature Unit 1 sensor 1 37 (38)     27/57          
    10.80.32.12  brw38b1db3b30f4 Life time sheets            3492 (None) None/None      
    10.80.32.12  brw38b1db3b30f4 Sheets since powered on     0 (286)     None/None      
    10.80.32.12  brw38b1db3b30f4 Printer Device Status       3 (5)       None/None


States
------

* Always returns OK.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
