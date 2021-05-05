Check "mod-qos-stats"
=====================

Overview
--------

mod_qos for Apache httpd features a handler showing the current connection and request status. This check fetches the machine-readable version of the status information.

Due to the behavior of mod_qos, this check does not issue a warning, since mod_qos adds waiting times in the event of overuse, for example. The check is useful for statistical purposes and for visualization over time, e.g. in Grafana.


Installation and Usage
----------------------

.. code-block:: bash

    ./mod-qos-stats
    ./mod-qos-stats --url http://webserver/qos-status
    ./mod-qos-stats --help

Output::

    Everything is ok.

    Type Host              Port Key                                   Configured Current 
    ---- ----              ---- ---                                   ---------- ------- 
    base proxy.example.com 0    QS_AllConn (All)                      None       381     
    virt www.example.com   443  QS_LocRequestLimitMatch ([^.*$])      90         3       
    virt www.example.com   443  QS_LocKBytesPerSecLimitMatch ([^.*$]) 1250       14      
    virt www.example.com   443  QS_CondLocRequestLimitMatch ([^.*$])  1          3       
    virt www.example.com   443  QS_SrvMaxConn ([])                    100        0


States
------

Always returns ok.


Perfdata
--------

Depends on your mod_qos configuration. The configuration options are suffixed by their specified request pattern (path and query). For example:

* QS_AllConn_All
* QS_CondLocRequestLimitMatch_[^.*$]
* QS_LocKBytesPerSecLimitMatch_[^.*$]
* QS_LocRequestLimitMatch_[^.*$]
* QS_SrvMaxConn_[]


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see LICENSE file.
