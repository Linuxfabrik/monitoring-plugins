Check "onlyoffice-stats"
========================

Overview
--------

Exports OnlyOffice statistics via HTTP. We recommend to run this check every 30 minutes.


Installation and Usage
----------------------

.. code-block:: bash

    ./onlyoffice-stats --url http://localhost --timeout 3

Pay attention that by default the ``info/info.json`` page is only available from localhost. The OnlyOffice Nginx configuration has to be modified if the exporter is not running locally (``/etc/onlyoffice/documentserver/nginx/includes/ds-docservice.conf``: set ``allow ...`` instead of ``deny all`` on ``location ~* ^(\/[\d]+\.[\d]+\.[\d]+[\.|-][\d]+)?\/(info|internal)(\/.*)$``).


States
------

Alerts if

* license expires in the next 10 days
* license has expired
* number of connections per hour reaches the licensed maximum


Perfdata
--------

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
* License: The Unlicense, see LICENSE file.
