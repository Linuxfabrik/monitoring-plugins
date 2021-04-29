Check "librenms-alerts"
=======================

Overview
--------

Warn about unacknowledged alerts in LibreNMS.

We recommend to run this check every minute.



Installation and Usage
----------------------

.. code-block:: bash

    ./librenms-alerts --help
    ./librenms-alerts --url http://librenms --token 03xyza61e74a9876f3dc7ab11234229d

Output::

    There are one or more criticals.

    Hostname     SysName         Alerts Worst State Latest & Worst Msg                    
    --------     -------         ------ ----------- ------------------                    
    10.80.32.109 S3900-48T4S     1      [CRITICAL]  Device Down! Due to no ICMP response. 
    10.80.32.141 d0-switch99     1      [CRITICAL]  Device Down! Due to no ICMP response. 
    10.80.32.12  brw38b1db3b30f4 0      [OK]                                              
    10.80.32.1   d0-router01     0      [OK]                                              
    10.80.32.50                  0      [OK]                                              
    10.80.32.58                  0      [OK]


States
------

* CRIT on criticals in LibreNMS
* WARN on warnings in LibreNMS
* OK on OK in LibreNMS


Perfdata
--------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see LICENSE file.

