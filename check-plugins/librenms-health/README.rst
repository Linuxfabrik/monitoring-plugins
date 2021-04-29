Check "librenms-health"
=======================

Overview
--------

Get health details of all devices in LibreNMS (mostly for debugging purposes). Depending on the number of devices and their sensors, the execution can take 3 seconds or longer.

We recommend to run this check every hour.

.. hint::

    This check could, but does not return any performance data, as LibreNMS offers direct integration into various time series databases like Graphite, InfluxDB, OpenTSDB, Prometheus and RRDTool. The configuration options can be found in LibreNMS under Settings > Global Settings > Poller > Datastore.


Installation and Usage
----------------------

.. code-block:: bash

    ./librenms-health --help
    ./librenms-health --url http://librenms --token 03xyza61e74a9876f3dc7ab11234229d

Output::

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

Always returns OK.


Perfdata
--------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see LICENSE file.

