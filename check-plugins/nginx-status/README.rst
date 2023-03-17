Check nginx-status
==================

Overview
--------

This check provides global nginx basic status information from the stub_status module.

For this check to work, enable the `stub_status <https://nginx.org/en/docs/http/ngx_http_stub_status_module.html>`_ module:

.. code-block::
    
    # /etc/nginx/nginx.conf
    server {
        location /server-status {
            stub_status;
            allow 127.0.0.1;    # only allow requests from localhost
            deny all;           # deny all other hosts   
        }
    }

Due to the fact that the `stub_status <https://github.com/nginx/nginx/blob/master/src/http/modules/ngx_http_stub_status_module.c>` module increments each counter at the exact moment a new request "object" is created, even before any request header (including the URI) is parsed, there is unfortunately no way to tell Nginx not to count requests for a given URI. In other words: It is not possible to get stats only for a specific server block.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/nginx-status"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux, Windows"
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

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    nginx_connections_accepted,                 Continous Counter,  "The total number of accepted client connections."
    nginx_connections_active,                   None,               "The current number of active client connections including ``Waiting`` connections. One user can have several concurrent connections to a server."
    nginx_connections_handled,                  Continous Counter,  "The total number of handled connections. Generally both values are the same unless some resource limits have been reached (for example, the ``worker_connections`` limit)."
    nginx_connections_reading,                  None,               "The current number of connections where nginx is reading the request header."
    nginx_connections_waiting,                  None,               "The current number of idle client connections waiting for a request. This number depends on the ``keepalive_timeout``."
    nginx_connections_writing,                  None,               "The current number of connections where nginx is writing the response back to the client."
    nginx_http_requests_total,                  Continous Counter,  "The total number of client requests."
    nginx_requests_per_connection,              None,               "The number of handled requests per connection."


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
