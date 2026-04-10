# Check php-fpm-ping

## Overview

This check fetches the ping monitoring page of PHP-FPM. This could be used to test from outside that FPM is alive and responding, to create a graph of FPM availability, or to trigger alerts for the operating team (24/7).

PHP-FPM config example:

```text
; PHP-FPM Config
ping.path = /fpm-ping
ping.response = pong
```

```text
# Apache Config
Alias /fpm-ping /dev/null
<Location "/fpm-ping">
    Require local
    ProxyPass unix:/run/php-fpm/www.sock|fcgi://localhost/fpm-ping
</Location>
```


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/php-fpm-ping> |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Requirements                          | Configure a ping page like `/fpm-ping`, `/<poolname>-fpm-ping` or similar in `/etc/php-fpm.d/<poolname>.conf` |


## Help

```text
usage: php-fpm-ping [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                    [--response RESPONSE] [--severity {warn,crit}]
                    [--test TEST] [--timeout TIMEOUT] [-u URL]

Checks whether PHP-FPM is alive by fetching its ping monitoring page. Returns
OK if FPM responds with the expected "pong" reply.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-proxy            Do not use a proxy.
  --response RESPONSE   Expected PHP-FPM ping response string. Default: pong
  --severity {warn,crit}
                        Severity for alerting. Default: warn
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  -u, --url URL         PHP-FPM ping URL. Default: http://localhost/fpm-ping
```


## Usage Examples

```bash
./php-fpm-ping --url http://localhost/fpm-ping --response pong --severity crit
```

Output:

```text
pong
```


## States

* WARN or CRIT if output is not identical to `--response` (default: "pong"), depending on the given severity (default: WARN)


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| ping | Number | 0 (= STATE_OK) if response is as expected, 1 (STATE_WARN) or 2 (STATE_CRIT)otherwise |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
