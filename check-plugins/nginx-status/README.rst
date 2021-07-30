Check nginx-status
==================

Overview
--------

This check provides nginx basic status information from the stub status module.

For this check to work, enable the `stub_status <https://nginx.org/en/docs/http/ngx_http_stub_status_module.html>`_ module:

.. code-block::
    :caption: /etc/nginx/nginx.conf

    server {
        location /server-status {
            stub_status;
            allow 127.0.0.1;    # only allow requests from localhost
            deny all;           # deny all other hosts   
        }
    }


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/nginx-status"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2, Python 3"
    "Requirements",                         "Enable ``stub_status``"
    "Perfdata compatible to Prometheus",    "Yes"


Help
----

.. code-block:: text

    usage: nginx-status [-h] [-V] [--always-ok] [-c CRIT] [-u URL] [-w WARN]
                        [--test TEST]

    This check provides NGINX basic status information.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      -c CRIT, --critical CRIT
                            Set the CRIT threshold for the number of active
                            connections. Default: >= 486
      -u URL, --url URL     NGINX Server Status URL. Default:
                            http://localhost/server-status
      -w WARN, --warning WARN
                            Set the WARN threshold for the number of active
                            connections. Default: >= 460
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".


Usage Examples
--------------

.. code-block:: bash

    ./nginx-status --url http://nginx/server-status --warning 460 --critical 486

Output:

.. code-block:: text

    1 active concurrent conn; 3 accepted conns, 3 handled conns, 3 reqs; 1.0 req per conn; currently 0 receiving reqs, 1 sending response, 0 keep-alive conns


States
------

* WARN if the number of total handled connections is not equal to the number of total handled requests.
* WARN or CRIT if the active connections are above the specified thresholds.


Perfdata / Metrics
------------------

* nginx_connections_accepted: The total number of accepted client connections. 
* nginx_connections_active: The current number of active client connections including Waiting connections. 
* nginx_connections_handled: The total number of handled connections. Generally both values are the same unless some resource limits have been reached (for example, the worker_connections limit).
* nginx_connections_reading: The current number of connections where nginx is reading the request header.
* nginx_connections_waiting: The current number of idle client connections waiting for a request.
* nginx_connections_writing: The current number of connections where nginx is writing the response back to the client.
* nginx_http_requests_total: The total number of client requests. 
* nginx_requests_per_connection: The number of handled requests per connection.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
