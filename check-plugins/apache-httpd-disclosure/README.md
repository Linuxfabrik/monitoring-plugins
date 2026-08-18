# Check apache-httpd-disclosure


## Overview

Checks how much an Apache httpd server discloses about itself in its HTTP responses: the product and version banner in the `Server` response header, the server signature footer on generated error pages, and inode numbers leaked through `ETag` response headers. Every finding is measured on the response the server actually sends, so a value overridden further down the configuration or by a reverse proxy is reported as it reaches a client rather than as it is written in a configuration file. Each finding maps to a copy-pasteable configuration recommendation. Alerts when the server discloses its version, its signature or an inode number.

The checks follow the "Information Leakage" chapter of the CIS Apache HTTP Server 2.4 Benchmark. The `X-Powered-By` check has no counterpart there and is carried out anyway, because a forwarded backend header discloses the application stack just as effectively as the server banner does.

**Important Notes:**

* The check is part of the Apache httpd and Apache apache2 Service Set and runs against `http://localhost` on the tagged host itself. A server that does not answer there, because it only serves HTTPS or only name-based virtual hosts, makes the service report UNKNOWN until `--url` is pointed at something it does serve. That is the point of shipping it in the Set: the tag says the host runs the server, and the UNKNOWN says nobody has finished setting the check up for it.
* The check reads a live HTTP response and needs no access to the server's configuration files, so it can be pointed at a remote host from anywhere the URL is reachable.
* To provoke a server-generated error page, the check requests `/linuxfabrik-monitoring-plugins-probe` below the given URL. That path shows up in the access log on every run.
* A server behind a cache or reverse proxy answers the probe with the proxy's own `Server` header, and the proxy rewrites `ETag`. Those two checks are then reported as not evaluated rather than as passed. The signature footer travels inside the page body and is still found, so a fronted server is still audited for it.
* If the response comes from a different product entirely and carries no Apache signature anywhere, the check says so and returns UNKNOWN instead of auditing a foreign server against Apache settings.
* A signature footer found somewhere other than on the probed error page may come from a page the server generated (a directory listing) or from stored content that happens to contain a captured error page. The recommendation covers both, because the check cannot tell them apart.
* An endpoint that answers without an `ETag` header, for example a directory listing or a dynamic page, discloses no inode. That counts as a pass.

### Data Collection

Two HTTP requests per run: one for the probe path, whose generated error page carries the signature footer, and one for the given URL, whose response header carries the `ETag`. Neither request needs authentication. Nothing is stored between runs.


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/apache-httpd-disclosure> |
| Nagios/Icinga Check Name              | `check_apache_httpd_disclosure` |
| Check Interval Recommendation         | Every hour |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Requirements                          | The URL has to be reachable from the host running the check |
| Perfdata compatible with Prometheus   | Yes |


## Help

```text
usage: apache-httpd-disclosure [-h] [-V] [--always-ok] [--insecure]
                               [--no-perfdata] [--no-proxy]
                               [--severity {warn,crit}] [--timeout TIMEOUT]
                               [--url URL]

Checks how much an Apache httpd server discloses about itself in its HTTP
responses: the product and version banner in the `Server` response header, the
server signature footer on generated error pages, and inode numbers leaked
through `ETag` response headers. Every finding is measured on the response the
server actually sends, so a value overridden further down the configuration or
by a reverse proxy is reported as it reaches a client rather than as it is
written in a configuration file. Each finding maps to a copy-pasteable
configuration recommendation. Alerts when the server discloses its version,
its signature or an inode number.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --no-proxy            Do not use a proxy.
  --severity {warn,crit}
                        State to report for a server that discloses
                        information. One of `warn` or `crit`. Default: warn
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --url URL             Base URL of the Apache httpd server to inspect.
                        Example: `--url=https://www.example.com` Default:
                        http://localhost

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/apache-httpd-disclosure/
```


## Usage Examples

A server left at the distribution defaults, which names its version and its operating system:

```bash
./apache-httpd-disclosure --url=https://www.example.com
```

```text
1 of 4 checks report disclosed information.

Recommendations:
* Set `ServerTokens Prod` to reduce the `Server` header to `Apache`.

Check            ! Result                           ! State
-----------------+----------------------------------+----------
Server header    ! `Server: Apache/2.4.38 (Debian)` ! [WARNING]
Server signature ! no signature footer              ! [OK]
ETag inode       ! no `ETag` response header        ! [OK]
Backend headers  ! no backend headers               ! [OK]
```

The `Detail` column explains every result:

```bash
./apache-httpd-disclosure --url=https://www.example.com
```

```text
1 of 4 checks report disclosed information.

Recommendations:
* Set `ServerTokens Prod` to reduce the `Server` header to `Apache`.

Check            ! Result                           ! Detail                                                ! State
-----------------+----------------------------------+-------------------------------------------------------+----------
Server header    ! `Server: Apache/2.4.38 (Debian)` ! Discloses version and operating system.               ! [WARNING]
Server signature ! no signature footer              ! No page served here carries a server signature.       ! [OK]
ETag inode       ! no `ETag` response header        ! Without an `ETag` there is no inode to disclose.      ! [OK]
Backend headers  ! no backend headers               ! Nothing identifies the application behind the server. ! [OK]
```

A hardened server:

```bash
./apache-httpd-disclosure --url=https://www.example.com
```

```text
Everything is ok. Nothing disclosed in 4 checks.

Check            ! Result                    ! State
-----------------+---------------------------+------
Server header    ! `Server: Apache`          ! [OK]
Server signature ! no signature footer       ! [OK]
ETag inode       ! `ETag: "3-6595047330f0d"` ! [OK]
Backend headers  ! no backend headers        ! [OK]
```

An application behind the server announcing itself:

```bash
./apache-httpd-disclosure --url=https://www.example.com
```

```text
1 of 4 checks report disclosed information.

Recommendations:
* Drop the header before it reaches the client with `Header always unset X-Powered-By` from `mod_headers`, and turn it off at its source, `expose_php = Off` in php.ini.

Check            ! Result                            ! State
-----------------+-----------------------------------+----------
Server header    ! `Server: Apache`                  ! [OK]
Server signature ! no signature footer               ! [OK]
ETag inode       ! no `ETag` response header         ! [OK]
Backend headers  ! `x-powered-by: PHP/8.2.18`        ! [WARNING]
```

A URL that is answered by a different product:

```bash
./apache-httpd-disclosure --url=https://www.example.com
```

```text
This URL is answered by nginx, not by Apache httpd. Point `--url` at the Apache httpd instance you want to check.
```


## States

* Returns OK if no check reports disclosed information.
* Returns WARN (or CRIT with `--severity=crit`) if at least one check reports disclosed information:
    * the `Server` response header contains a version part, which is everything beyond the bare product token `Apache`,
    * a page served here carries the signature footer Apache writes onto the pages it generates,
    * the `ETag` response header is built from three hexadecimal components, the first of which is the file's inode number,
    * the response carries `X-Powered-By`, `X-AspNet-Version`, `X-AspNetMvc-Version` or `X-Generator`.
* Returns UNKNOWN if the URL cannot be fetched at all, or if the response comes from a different product and carries no Apache signature anywhere.
* A check that cannot be carried out, because a proxy replaced the header it reads or because the URL did not answer, is reported as not evaluated. It does not count towards the result and does not drive the state.
* `--always-ok` masks a WARN or CRIT as OK. It does not mask the UNKNOWN of an unreachable or foreign endpoint.


## Perfdata / Metrics

| Name | Type | Description |
|------|------|-------------|
| apache_httpd_checks_evaluated | Number | Number of checks that could be carried out on this run. |
| apache_httpd_disclosures | Number | Number of checks that report disclosed information. |


## Troubleshooting

### `TLS certificate verification failed`

The certificate the server presents does not verify on this host. The message names the reason and what to do about it. The most common one on an otherwise working site is an incomplete chain: the server sends only its own certificate and omits the intermediate that links it to a trusted root. A browser hides this by fetching the missing certificate itself, which is why the page loads in a browser but not here. Compare with `openssl s_client -connect HOST:443 -servername HOST`: a chain listing only the server certificate has to be completed on the server. If the issuer is a private authority, add its certificate to the trust store of the host running the check. `--insecure` skips verification and is the right answer only for an endpoint whose certificate you deliberately do not verify.

### `URL error "Server disconnected without sending a response."`

Usually a plaintext request sent to a port that speaks TLS, for example `--url=http://192.0.2.1:443/`. Request the endpoint with `https://` instead. A browser hides this too, because it upgrades the request on its own.

### The signature footer is reported although `ServerSignature Off` is set

The footer was found somewhere other than the probed error page, and the page carrying it is stored content rather than something the server generated. A captured error page saved into the document root by a caching or optimisation plugin is the usual source. Remove the version from that file; the directive is already correct.

### Everything is reported as not evaluated

A cache or reverse proxy in front of the server answers with its own headers. Point the check at the origin instead, or accept that only the signature footer can be audited from the outside.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
