# Check redis-version


## Overview

Checks the installed Redis version against the endoflife.date API and alerts if the version is end-of-life or if newer releases are available.

**Data Collection:**

* Runs `redis-server --version` locally to determine the installed version
* Queries the endoflife.date API (<https://endoflife.date/api/redis.json>) and caches the result in a local SQLite database
* Must run on the Redis server itself


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/redis-version> |
| Nagios/Icinga Check Name              | `check_redis_version` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| Uses State File                       | `$TEMP/linuxfabrik-lib-version.db` |


## Help

```text
usage: redis-version [-h] [-V] [--always-ok] [--check-major] [--check-minor]
                     [--check-patch] [--insecure] [--no-perfdata] [--no-proxy]
                     [--offset-eol OFFSET_EOL] [--path PATH] [--proxy PROXY]
                     [--timeout TIMEOUT]
                     [--unreachable-severity {ok,warn,crit,unknown}]

Checks the installed Redis version against the endoflife.date API and alerts
if the version is end-of-life or if newer major, minor, or patch releases are
available. By default, alerts 30 days before the official EOL date. The offset
is configurable.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --check-major         Alert when a new major release is available, even if
                        the current version is not yet EOL. Example: running
                        v26 (not yet EOL) and v27 is available.
  --check-minor         Alert when a new major.minor release is available,
                        even if the current version is not yet EOL. Example:
                        running v26.2 (not yet EOL) and v26.3 is available.
  --check-patch         Alert when a new major.minor.patch release is
                        available, even if the current version is not yet EOL.
                        Example: running v26.2.7 (not yet EOL) and v26.2.8 is
                        available.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --no-proxy            Do not use a proxy, not even one the environment
                        names. Overrides `--proxy`.
  --offset-eol OFFSET_EOL
                        Alert n days before ("-30") or after an EOL date ("30"
                        or "+30"). Default: -30 days
  --path PATH           Path to the Redis binary. Resolved via $PATH when
                        given without a directory. Default: redis-server
  --proxy PROXY         Proxy to reach the target through. The scheme defaults
                        to `http` when omitted. Overrides the proxy the
                        environment names (`http_proxy`, `https_proxy`,
                        `all_proxy`) together with the exceptions it lists in
                        `no_proxy`, and is itself overridden by `--no-proxy`.
                        Without either parameter the environment applies.
                        Credentials belong into the environment variable
                        rather than here, because a command-line argument is
                        visible to every user on the host. Example:
                        `--proxy=http://proxy.example.com:3128`.
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --unreachable-severity {ok,warn,crit,unknown}
                        State to report when the online source is unreachable.
                        What is used instead - bundled offline data, a cached
                        copy, or nothing at all - is named in the output, and
                        a clean result then only covers what that fallback
                        could confirm. Default: ok

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/redis-version/
```


## Usage Examples

```bash
./redis-version --offset-eol=-30
```

Output:

```text
Redis v7.0.13 (EOL unknown, minor 7.2.1 available)
```


## States

The end-of-life verdict, the `--check-major` / `--check-minor` / `--check-patch` alerts, `--offset-eol`, `--always-ok` and what happens when endoflife.date cannot be reached work the same way in every endoflife.date-based version plugin. They are described in [Version Plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-version/).


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| redis-version | Number | Installed Redis version as float. "3.3.22" becomes "3.322". |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
