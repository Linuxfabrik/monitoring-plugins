Check onlyoffice-stats
======================

Overview
--------

Checks OnlyOffice statistics and license usage via HTTP.

Pay attention that by default the ``info/info.json`` page is only available from localhost. The OnlyOffice nginx configuration has to be modified if the exporter is not running locally (``/etc/onlyoffice/documentserver/nginx/includes/ds-docservice.conf``: set ``allow ...`` instead of ``deny all`` on ``location ~* ^(\/[\d]+\.[\d]+\.[\d]+[\.|-][\d]+)?\/(info|internal)(\/.*)$``).


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/onlyoffice-stats"
    "Check Interval Recommendation",        "Every 30 minutes"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux, Windows"
    "3rd Party Python modules",             "``psutil``"


Help
----

.. code-block:: text

    usage: onlyoffice-stats [-h] [-V] [--test TEST] [--timeout TIMEOUT]
                            [--url URL]

    Checks OnlyOffice statistics and license usage via HTTP.

    optional arguments:
      -h, --help         show this help message and exit
      -V, --version      show program's version number and exit
      --test TEST        For unit tests. Needs "path-to-stdout-file,path-to-
                         stderr-file,expected-retc".
      --timeout TIMEOUT  Network timeout in seconds. Default: 3 (seconds)
      --url URL          OnlyOffice API URL. Default: http://localhost


Usage Examples
--------------

.. code-block:: bash

    ./onlyoffice-stats --url http://localhost --timeout 3

Output:

.. code-block:: text

    Max 20 connections, licensed (expired) [WARNING], last hour: 3/7/12 views and 2/6/11 edits (min/avr/max), 13 unique users, v1.2.3


States
------

Alerts if

* license expires in the next 10 days
* license has expired
* number of connections per hour reaches the licensed maximum


Perfdata / Metrics
------------------

* conn_hour_edit_avr
* conn_hour_edit_max
* conn_hour_edit_min
* conn_hour_view_avr
* conn_hour_view_max
* conn_hour_view_min
* unique_users


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
