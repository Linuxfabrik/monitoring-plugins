# Check nginx-status


## Overview

Monitors NGINX performance via the stub_status module. Reports active connections, accepts, handled requests, and connection states (reading, writing, waiting). Alerts when active connections exceed the configured thresholds.

**Important Notes:**

* The `stub_status` module must be enabled in the NGINX configuration. Because the module increments counters at the moment a new request object is created (before the URI is parsed), there is no way to exclude specific URIs or server blocks from the statistics.

To enable `stub_status`:

```text
# /etc/nginx/nginx.conf
server {
    location /server-status {
        stub_status;
        allow 127.0.0.1;    # only allow requests from localhost
        deny all;           # deny all other hosts   
    }
}
```

**Data Collection:**

* Fetches and parses the output of the NGINX [stub_status](https://nginx.org/en/docs/http/ngx_http_stub_status_module.html) module
* Reports active connections, accepted/handled connections, total requests, requests per connection, and current connection states (reading, writing, waiting)


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/nginx-status> |
| Nagios/Icinga Check Name              | `check_nginx_status` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Requirements                          | Enable `stub_status` |
| Perfdata compatible with Prometheus   | Yes |


## Help

```text
usage: nginx-status [-h] [-V] [--always-ok] [-c CRIT] [--insecure]
                    [--no-proxy] [--timeout TIMEOUT] [-u URL] [-w WARN]
                    [--test TEST]

Monitors NGINX performance via the stub_status module. Reports active
connections, accepts, handled requests, and connection states (reading,
writing, waiting). Alerts when active connections exceed the configured
thresholds.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  -c, --critical CRIT  CRIT threshold for the number of active connections.
                       Default: >= 486
  --insecure           This option explicitly allows insecure SSL connections.
  --no-proxy           Do not use a proxy.
  --timeout TIMEOUT    Network timeout in seconds. Default: 8 (seconds)
  -u, --url URL        NGINX stub_status URL. Default:
                       http://localhost/server-status
  -w, --warning WARN   WARN threshold for the number of active connections.
                       Default: >= 460
  --test TEST          For unit tests. Needs "path-to-stdout-file,path-to-
                       stderr-file,expected-retc".
```


## Usage Examples

```bash
./nginx-status --url http://nginx/server-status --warning 460 --critical 486
```

Output:

```text
1 active concurrent conn; 3 accepted conns, 3 handled conns, 3 reqs; 1.0 req per conn; currently 0 receiving reqs, 1 sending response, 0 keep-alive conns
```


## States

* OK if handled connections equal accepted connections and active connections are below thresholds.
* WARN if the number of total handled connections is not equal to the number of total accepted connections.
* WARN or CRIT if the active connections exceed the specified thresholds.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| nginx_connections_accepted | Continous Counter | The total number of accepted client connections. |
| nginx_connections_active | Number | The current number of active client connections including waiting connections. |
| nginx_connections_handled | Continous Counter | The total number of handled connections. Generally both values are the same unless some resource limits have been reached (for example, the `worker_connections` limit). |
| nginx_connections_reading | Number | The current number of connections where NGINX is reading the request header. |
| nginx_connections_waiting | Number | The current number of idle client connections waiting for a request. This number depends on the `keepalive_timeout`. |
| nginx_connections_writing | Number | The current number of connections where NGINX is writing the response back to the client. |
| nginx_http_requests_total | Continous Counter | The total number of client requests. |
| nginx_requests_per_connection | Number | The number of handled requests per connection. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
