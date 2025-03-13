Check mod-qos-stats
===================

Overview
--------

mod_qos for Apache httpd features a handler showing the current connection and request status. This check fetches the machine-readable version of the status information.

Due to the behavior of mod_qos, this check does not issue a warning, since mod_qos adds waiting times in the event of overuse, for example. The check is useful for statistical purposes and for visualization over time, e.g. in Grafana.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mod-qos-stats"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux, Windows"
    "Requirements",                         "Enable ``mod_qos`` and configure a ``Location`` for ``SetHandler qos-viewer``"


Help
----

.. code-block:: text

    usage: mod-qos-stats [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                         [--test TEST] [--timeout TIMEOUT] [-u URL]

    mod_qos for Apache httpd features a handler showing the current connection and
    request status. This check fetches the machine-readable version of the status
    information.

    options:
      -h, --help         show this help message and exit
      -V, --version      show program's version number and exit
      --always-ok        Always returns OK.
      --insecure         This option explicitly allows to perform "insecure" SSL
                         connections. Default: False
      --no-proxy         Do not use a proxy. Default: False
      --test TEST        For unit tests. Needs "path-to-stdout-file,path-to-
                         stderr-file,expected-retc".
      --timeout TIMEOUT  Network timeout in seconds. Default: 8 (seconds)
      -u, --url URL      mod_qos Status URL. Default: http://localhost/qos-status


Usage Examples
--------------

.. code-block:: bash

    ./mod-qos-stats --url http://webserver/qos-status

Output:

.. code-block:: text

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

* Always returns OK.


Perfdata / Metrics
------------------

Depends on your mod_qos configuration. The configuration options are suffixed by their specified request pattern (path and query). For example:

* QS_AllConn_All
* QS_CondLocRequestLimitMatch_[^.*$]
* QS_LocKBytesPerSecLimitMatch_[^.*$]
* QS_LocRequestLimitMatch_[^.*$]
* QS_SrvMaxConn_[]


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
