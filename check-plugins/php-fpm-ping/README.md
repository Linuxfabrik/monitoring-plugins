# Check php-fpm-ping

## Overview

Checks whether PHP-FPM is alive by fetching its ping monitoring page. Returns OK if FPM responds with the expected "pong" reply.

**Data Collection:**

* Fetches the PHP-FPM ping page via HTTP (default: `http://localhost/fpm-ping`)
* Compares the response against the expected string (default: "pong")

**Important Notes:**

* Requires a configured ping page in PHP-FPM. Example PHP-FPM config:

    ```text
    ping.path = /fpm-ping
    ping.response = pong
    ```

* Requires an Apache/nginx configuration to proxy the ping page. Example Apache config:

    ```text
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
| Nagios/Icinga Check Name              | `check_php_fpm_ping` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


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

* OK if PHP-FPM responds with the expected string (default: "pong").
* WARN or CRIT (depending on `--severity`, default: WARN) if the response does not match the expected string.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| ping | Number | 0 (STATE_OK) if the response matches, 1 (STATE_WARN) or 2 (STATE_CRIT) otherwise. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
