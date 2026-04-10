# Check onlyoffice-stats

## Overview

Monitors OnlyOffice Document Server statistics and license usage via the HTTP API. Reports active connections, document editing sessions, and license consumption. Alerts when license usage exceeds the configured thresholds.

**Data Collection:**

* Fetches statistics from the OnlyOffice `info/info.json` endpoint via HTTP
* Reports maximum licensed connections, license status and expiration, hourly view and edit connection statistics (min/avg/max), unique user count, and server version

**Important Notes:**

* By default the `info/info.json` page is only available from localhost. The OnlyOffice nginx configuration has to be modified if the check is not running locally (`/etc/onlyoffice/documentserver/nginx/includes/ds-docservice.conf`: set `allow ...` instead of `deny all` on `location ~* ^(\/[\d]+\.[\d]+\.[\d]+[\.|-][\d]+)?\/(info|internal)(\/.*)$`).


## Fact Sheet

| Fact | Value |
|----|----| 
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/onlyoffice-stats> |
| Nagios/Icinga Check Name              | `check_onlyoffice_stats` |
| Check Interval Recommendation         | Every 30 minutes |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
usage: onlyoffice-stats [-h] [-V] [--insecure] [--no-proxy] [--test TEST]
                        [--timeout TIMEOUT] [--url URL]

Monitors OnlyOffice Document Server statistics and license usage via the HTTP
API. Reports active connections, document editing sessions, and license
consumption. Alerts when license usage exceeds the configured thresholds.

options:
  -h, --help         show this help message and exit
  -V, --version      show program's version number and exit
  --insecure         This option explicitly allows insecure SSL connections.
  --no-proxy         Do not use a proxy.
  --test TEST        For unit tests. Needs "path-to-stdout-file,path-to-
                     stderr-file,expected-retc".
  --timeout TIMEOUT  Network timeout in seconds. Default: 3 (seconds)
  --url URL          OnlyOffice API URL. Default: http://localhost
```


## Usage Examples

```bash
./onlyoffice-stats --url http://localhost --timeout 3
```

Output:

```text
Max 20 connections, licensed (expired) [WARNING], last hour: 3/7/12 views and 2/6/11 edits (min/avr/max), 13 unique users, v1.2.3
```


## States

* OK if the license is valid and connection counts are within limits.
* WARN if the license expires in the next 10 days.
* WARN if the license has expired.
* WARN if the maximum hourly view or edit connections reach 90% of the licensed maximum.
* CRIT if the maximum hourly view or edit connections reach 95% of the licensed maximum.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| conn_hour_edit_avr | Number | Average number of editing connections per hour. |
| conn_hour_edit_max | Number | Maximum number of editing connections per hour. |
| conn_hour_edit_min | Number | Minimum number of editing connections per hour. |
| conn_hour_view_avr | Number | Average number of viewing connections per hour. |
| conn_hour_view_max | Number | Maximum number of viewing connections per hour. |
| conn_hour_view_min | Number | Minimum number of viewing connections per hour. |
| unique_users | Number | Number of unique users. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
