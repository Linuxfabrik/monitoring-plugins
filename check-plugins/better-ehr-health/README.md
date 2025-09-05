# Check better-ehr-health

## Overview

Monitoring plugin for Better EHR, querying the JSON health endpoint (for example, `http://server:port/health`).
Supports overriding component states and applying Nagios-style threshold ranges to detail metrics.

Hints:

* Useful for monitoring Better EHR availability and component health.
* Allows fine-grained overrides to adjust alerting behaviour.

## Fact Sheet

| Fact                             | Value                                                                                       |
|----------------------------------|---------------------------------------------------------------------------------------------|
| Check Plugin Download            | https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/better-ehr-health |
| Check Interval Recommendation    | Once a minute                                                                               |
| Can be called without parameters | No                                                                                          |

## Help

```text
usage: better-ehr-health [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                         [--url URL] [--test TEST] [--timeout TIMEOUT]
                         [--override-status COMPONENT:API_STATE:NAGIOS_STATE]
                         [--override-threshold COMPONENT:DETAIL[:WARN[:CRIT]]]
                         [-v]

Monitoring plugin for Better EHR, querying the JSON health endpoint (e.g.
http://server:port/health). Supports overriding component states and applying
Nagios-style threshold ranges to detail metrics.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --insecure            Allow insecure SSL connections. Default: True
  --no-proxy            Do not use a proxy. Default: False
  --url URL             Better EHR Health endpoint. Default:
                        http://localhost:80/health
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  --timeout TIMEOUT     Network timeout in seconds. Default: 3
  --override-status COMPONENT:API_STATE:NAGIOS_STATE
                        Override mapping from API state to Nagios state.
                        Example: diskSpace:DEGRADED:WARN
  --override-threshold COMPONENT:DETAIL[:WARN[:CRIT]]
                        Override threshold check for a component detail.
                        Example: diskSpace:free::20000000
  -v, --verbose         Set the verbosity level.
```

## Usage Examples

```bash
./better-ehr-health --url http://server:8080/health
```

```bash
./better-ehr-health --override-status diskSpace:DEGRADED:WARN
```

```bash
./better-ehr-health --override-threshold diskSpace:free::20000000
```

## States

* Returns **OK**, **WARN**, **CRIT**, or **UNKNOWN** depending on API state, component overrides, and threshold checks.
* `--always-ok` forces the check to always return OK.

## Perfdata / Metrics

Each numeric detail is exposed as perfdata unless explicitly excluded (`threshold`, `total`).

| Name               | Type   | Description             |
| ------------------ | ------ | ----------------------- |
| diskSpace\_free    | Bytes  | Free disk space         |
| diskSpace\_total   | Bytes  | Total disk space        |
| hikari\_activeConn | Number | Active DB connections   |
| ...                | ...    | Other component details |

## Troubleshooting

**Error:** Connection refused
**Solution:** Verify Better EHR endpoint is reachable and correct URL is provided with `--url`.

**Error:** SSL error
**Solution:** Use `--insecure` for testing, but configure proper certificates in production.

## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
