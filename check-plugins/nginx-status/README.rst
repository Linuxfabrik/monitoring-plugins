Check "nginx-status"
====================

Overview
--------

This check provides NGINX basic status information (from the stub status module).

We recommend to run this check every minute.


Installation and Usage
----------------------

Enable the `stub_status <https://nginx.org/en/docs/http/ngx_http_stub_status_module.html>`_ module:

.. code-block::
    :caption: /etc/nginx/nginx.conf

    server {
        location /server-status {
            stub_status;
            allow 127.0.0.1;    # only allow requests from localhost
            deny all;           # deny all other hosts   
         }
    }

Fetch the status data:

.. code-block:: bash

    ./nginx-status --url http://nginx/server-status --warning 460 --critical 486

Output::

    4 active concurrent conns; 4540245 accepted conns, 4540245 handled conns, 4540243 reqs; 1.0 req per conn; currently 0 receiving reqs, 2 sending responses, 2 keep-alive conns


States
------

* WARN if the number of total handled connections is not equal to the number of total handled requests.
* WARN or CRIT if the active connections are above the specified thresholds.


Perfdata
--------

* connections_active: The current number of active client connections including Waiting connections. 
* total_connections_accepted: The total number of accepted client connections. 
* total_connections_handled: The total number of handled connections. Generally both values are the same unless some resource limits have been reached (for example, the worker_connections limit).
* total_requests: The total number of client requests. 
* requests_per_connection: The number of handled requests per connection.
* connections_reading: The current number of connections where nginx is reading the request header.
* connections_writing: The current number of connections where nginx is writing the response back to the client.
* connections_waiting: The current number of idle client connections waiting for a request.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see LICENSE file.

