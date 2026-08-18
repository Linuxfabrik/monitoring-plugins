# Check nginx-disclosure


## Overview

Checks how much an NGINX server discloses about itself and about the application behind it in its HTTP responses: the product and version banner in the `Server` response header, references to the server software in generated error pages, and headers an upstream application leaks through the proxy, such as `X-Powered-By`. Every finding is measured on the response the server actually sends, so a value overridden further down the configuration or by another proxy is reported as it reaches a client rather than as it is written in a configuration file. Each finding maps to a copy-pasteable configuration recommendation. Alerts when the server discloses its version, names itself on an error page, or forwards a header that identifies the backend. Supports extended reporting via `--lengthy`.

The checks follow the information disclosure controls of the CIS NGINX Benchmark.

**Important Notes:**

* The check is part of the Nginx Service Set and runs against `http://localhost` on the tagged host itself. A server that does not answer there, because it only serves HTTPS or only name-based virtual hosts, makes the service report UNKNOWN until `--url` is pointed at something it does serve. That is the point of shipping it in the Set: the tag says the host runs the server, and the UNKNOWN says nobody has finished setting the check up for it.
* The check reads a live HTTP response and needs no access to the server's configuration files, so it can be pointed at a remote host from anywhere the URL is reachable.
* To provoke a server-generated error page, the check requests `/linuxfabrik-monitoring-plugins-probe` below the given URL. That path shows up in the access log on every run.
* `server_tokens off` and the error page are two separate findings. The directive removes the version from the `Server` header and from the error page footer, but the footer keeps naming the product. Only an `error_page` of your own removes that.
* A server behind a cache or reverse proxy answers the probe with the proxy's own `Server` header, so that check is reported as not evaluated rather than as passed. The generated footer travels inside the page body and is still found, so a fronted server is still audited for it.
* If the response comes from a different product entirely and carries no NGINX footer anywhere, the check says so and returns UNKNOWN instead of auditing a foreign server against NGINX settings.
* The benchmark's own audit searches the whole response body for the bare product name. This check matches the footer NGINX actually generates instead, so a page that merely mentions the product, a directory listing of a package named `nginx-mode` for example, is not reported as a finding.

### Data Collection

Two HTTP requests per run: one for the probe path, whose generated error page carries the footer, and one for the given URL. Neither request needs authentication. Nothing is stored between runs.


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/nginx-disclosure> |
| Nagios/Icinga Check Name              | `check_nginx_disclosure` |
| Check Interval Recommendation         | Every hour |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Requirements                          | The URL has to be reachable from the host running the check |
| Perfdata compatible with Prometheus   | Yes |


## Help

```text
usage: nginx-disclosure [-h] [-V] [--always-ok] [--insecure] [--lengthy]
                        [--no-perfdata] [--no-proxy] [--severity {warn,crit}]
                        [--timeout TIMEOUT] [--url URL]

Checks how much an NGINX server discloses about itself and about the
application behind it in its HTTP responses: the product and version banner in
the `Server` response header, references to the server software in generated
error pages, and headers an upstream application leaks through the proxy, such
as `X-Powered-By`. Every finding is measured on the response the server
actually sends, so a value overridden further down the configuration or by
another proxy is reported as it reaches a client rather than as it is written
in a configuration file. Each finding maps to a copy-pasteable configuration
recommendation. Alerts when the server discloses its version, names itself on
an error page, or forwards a header that identifies the backend. Supports
extended reporting via --lengthy.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --lengthy             Extended reporting.
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --no-proxy            Do not use a proxy.
  --severity {warn,crit}
                        State to report for a server that discloses
                        information. One of `warn` or `crit`. Default: warn
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --url URL             Base URL of the NGINX server to inspect. Example:
                        `--url=https://www.example.com` Default:
                        http://localhost

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/nginx-disclosure/
```


## Usage Examples

A server left at the defaults, which names its version in the header and in the error page:

```bash
./nginx-disclosure --url=https://www.example.com
```

```text
2 of 3 checks report disclosed information.

Recommendations:
* Set `server_tokens off;` to reduce the `Server` header to `nginx`.
* Point `error_page` at pages of your own that carry no product name, for example `error_page 404 /404.html;`.

Check           ! Result                                  ! State
----------------+-----------------------------------------+----------
Server header   ! `Server: nginx/1.30.4`                  ! [WARNING]
Error page      ! `nginx/1.30.4` on the probed error page ! [WARNING]
Backend headers ! no backend headers                      ! [OK]
```

The same server after `server_tokens off`. The header is clean, the default error page still names the product:

```bash
./nginx-disclosure --url=https://www.example.com --lengthy
```

```text
1 of 3 checks report disclosed information.

Recommendations:
* Point `error_page` at pages of your own that carry no product name, for example `error_page 404 /404.html;`.

Check           ! Result                           ! Detail                                                                                  ! State
----------------+----------------------------------+-----------------------------------------------------------------------------------------+----------
Server header   ! `Server: nginx`                  ! Product token only, no version disclosed.                                               ! [OK]
Error page      ! `nginx` on the probed error page ! The default page identifies the server as NGINX even when the `Server` header does not.  ! [WARNING]
Backend headers ! no backend headers               ! Nothing identifies the application behind the server.                                   ! [OK]
```

An upstream application announcing itself through the proxy:

```bash
./nginx-disclosure --url=https://www.example.com
```

```text
1 of 3 checks report disclosed information.

Recommendations:
* Strip the header before it reaches the client with `proxy_hide_header X-Powered-By;`, or `fastcgi_hide_header X-Powered-By;` when the upstream is reached over FastCGI, and turn it off at its source, `expose_php = Off` in php.ini.

Check           ! Result                                 ! State
----------------+----------------------------------------+----------
Server header   ! `Server: nginx`                        ! [OK]
Error page      ! no product name in the generated pages ! [OK]
Backend headers ! `x-powered-by: PHP/8.2.18`             ! [WARNING]
```

`server_tokens off` plus an `error_page` of your own:

```bash
./nginx-disclosure --url=https://www.example.com
```

```text
Everything is ok. Nothing disclosed in 3 checks.

Check           ! Result                                 ! State
----------------+----------------------------------------+------
Server header   ! `Server: nginx`                        ! [OK]
Error page      ! no product name in the generated pages ! [OK]
Backend headers ! no backend headers                     ! [OK]
```

A URL that is answered by a different product:

```bash
./nginx-disclosure --url=https://www.example.com
```

```text
This URL is answered by apache, not by NGINX. Point `--url` at the NGINX instance you want to check.
```


## States

* Returns OK if no check reports disclosed information.
* Returns WARN (or CRIT with `--severity=crit`) if at least one check reports disclosed information:
    * the `Server` response header contains a version part, which is everything beyond the bare product token `nginx`,
    * a page served here carries the footer NGINX writes onto the pages it generates,
    * the response carries `X-Powered-By`, `X-AspNet-Version`, `X-AspNetMvc-Version` or `X-Generator` with a value that names something.
* Returns UNKNOWN if the URL cannot be fetched at all, or if the response comes from a different product and carries no NGINX footer anywhere.
* A check that cannot be carried out, because a proxy replaced the header it reads or because the URL did not answer, is reported as not evaluated. It does not count towards the result and does not drive the state.
* `--always-ok` masks a WARN or CRIT as OK. It does not mask the UNKNOWN of an unreachable or foreign endpoint.


## Perfdata / Metrics

| Name | Type | Description |
|------|------|-------------|
| nginx_checks_evaluated | Number | Number of checks that could be carried out on this run. |
| nginx_disclosures | Number | Number of checks that report disclosed information. |


## Troubleshooting

### `TLS certificate verification failed`

The certificate the server presents does not verify on this host. The message names the reason and what to do about it. The most common one on an otherwise working site is an incomplete chain: the server sends only its own certificate and omits the intermediate that links it to a trusted root. A browser hides this by fetching the missing certificate itself, which is why the page loads in a browser but not here. Compare with `openssl s_client -connect HOST:443 -servername HOST`: a chain listing only the server certificate has to be completed on the server. If the issuer is a private authority, add its certificate to the trust store of the host running the check.

### `URL error "Server disconnected without sending a response."`

Usually a plaintext request sent to a port that speaks TLS, for example `--url=http://192.0.2.1:443/`. Request the endpoint with `https://` instead.

### The error page check keeps firing although `server_tokens off` is set

That is the expected behaviour and the reason the two are separate controls. `server_tokens off` removes the version from the footer, not the product name. Point `error_page` at content of your own to remove the name as well.

### The server header is reported as not evaluated

A cache or reverse proxy in front of the server answers with its own `Server` header, so it says nothing about the origin any more. Point the check at the origin instead.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
