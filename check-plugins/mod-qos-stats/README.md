# Check mod-qos-stats


## Overview

Monitors Apache mod_qos status via the machine-readable status handler. Reports current connection and request limits, active connections, and quality of service metrics for all configured virtual hosts. This check is primarily useful for statistical purposes and visualization over time in Grafana.

**Important Notes:**

* Due to the behavior of mod_qos (which adds waiting times in case of overuse rather than rejecting requests), this check always returns OK and does not issue warnings
* Requires `mod_qos` to be enabled and a `Location` configured with `SetHandler qos-viewer`

**Data Collection:**

* Fetches the machine-readable status page from the mod_qos handler (`?auto` parameter)
* Parses per-virtual-host connection and request limit entries, including `QS_AllConn`, `QS_LocRequestLimitMatch`, `QS_LocKBytesPerSecLimitMatch`, `QS_CondLocRequestLimitMatch`, and `QS_SrvMaxConn`
* Perfdata metric names are composed of the mod_qos configuration option suffixed by the request pattern (e.g. `QS_LocRequestLimitMatch_[^.*$]`)


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mod-qos-stats> |
| Nagios/Icinga Check Name              | `check_mod_qos_stats` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Requirements                          | Enable `mod_qos` and configure a `Location` for `SetHandler qos-viewer` |


## Help

```text
usage: mod-qos-stats [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                     [--test TEST] [--timeout TIMEOUT] [-u URL]

Monitors Apache mod_qos status via the machine-readable status handler.
Reports current connection and request limits, active connections, and quality
of service metrics. Alerts when connection or request limits are approached.

options:
  -h, --help         show this help message and exit
  -V, --version      show program's version number and exit
  --always-ok        Always returns OK.
  --insecure         This option explicitly allows insecure SSL connections.
  --no-proxy         Do not use a proxy.
  --test TEST        For unit tests. Needs "path-to-stdout-file,path-to-
                     stderr-file,expected-retc".
  --timeout TIMEOUT  Network timeout in seconds. Default: 8 (seconds)
  -u, --url URL      URL of the mod_qos machine-readable status handler.
                     Default: http://localhost/qos-status
```


## Usage Examples

```bash
./mod-qos-stats --url http://webserver/qos-status
```

Output:

```text
Everything is ok.

Type Host              Port Key                                   Configured Current 
---- ----              ---- ---                                   ---------- ------- 
base proxy.example.com 0    QS_AllConn (All)                      None       381     
virt www.example.com   443  QS_LocRequestLimitMatch ([^.*$])      90         3       
virt www.example.com   443  QS_LocKBytesPerSecLimitMatch ([^.*$]) 1250       14      
virt www.example.com   443  QS_CondLocRequestLimitMatch ([^.*$])  1          3       
virt www.example.com   443  QS_SrvMaxConn ([])                    100        0
```


## States

* Always returns OK.


## Perfdata / Metrics

Depends on your mod_qos configuration. The configuration options are suffixed by their specified request pattern (path and query). For example:

| Name | Type | Description |
|----|----|----|
| QS_AllConn_All | Number | Current number of all connections (global). |
| QS_CondLocRequestLimitMatch_[^.*$] | Number | Current conditional location request limit match count. |
| QS_LocKBytesPerSecLimitMatch_[^.*$] | KB | Current location KBytes per second limit match count. |
| QS_LocRequestLimitMatch_[^.*$] | Number | Current location request limit match count. |
| QS_SrvMaxConn_[] | Number | Current server max connection count. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
