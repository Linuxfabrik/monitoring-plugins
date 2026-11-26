# Check mongodb-version


## Overview

Checks the installed MongoDB version against the endoflife.date API and alerts if the version is end-of-life or if newer major, minor, or patch releases are available. By default, alerts 30 days before the official EOL date. The offset is configurable.

**Important Notes:**

* The check must run locally on the MongoDB server because it runs the `mongod` binary to read its version. It needs no MongoDB user, even if authorization is enabled.
* Whether an upgrade of MongoDB was finished is checked by [mongodb-feature-compatibility](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mongodb-feature-compatibility/).

**Data Collection:**

* Runs `mongod --version` to read the installed MongoDB version (configurable via `--path`)
* Compares against the [endoflife.date API](https://endoflife.date/api/mongodb.json) to determine EOL status and available updates
* Where the software comes from a package the distribution maintains itself, the end of life is the one the distribution gives it rather than the upstream one: on Red Hat Enterprise Linux and its rebuilds such as AlmaLinux and Rocky Linux the date Red Hat gives the package or its Application Stream, on Debian the end of the release's security support including LTS, on Ubuntu the end of its standard support for `main` and `restricted`. Software from EPEL, Ubuntu's `universe`, backports or a third-party repository such as MongoDB's own `mongodb-org` repository keeps the upstream date
* Caches endoflife.date responses locally for 24 hours to reduce external requests


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mongodb-version> |
| Nagios/Icinga Check Name              | `check_mongodb_version` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| Uses State File                       | `$TEMP/linuxfabrik-lib-version.db` |


## Help

```text
usage: mongodb-version [-h] [-V] [--always-ok] [--check-major] [--check-minor]
                       [--check-patch] [--insecure] [--no-perfdata]
                       [--no-proxy] [--offset-eol OFFSET_EOL] [--path PATH]
                       [--proxy PROXY] [--timeout TIMEOUT]
                       [--unreachable-severity {ok,warn,crit,unknown}]

Checks the installed MongoDB version against the endoflife.date API and alerts
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
  --path PATH           Path to the mongod binary. Resolved via $PATH when
                        given without a directory. Default: mongod
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
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mongodb-version/
```


## Usage Examples

```bash
./mongodb-version --offset-eol=-30
```

Output:

```text
MongoDB v8.0.38 (EOL 2029-10-31 -30d, major 9.0.8 available)
```


## States

The end-of-life verdict, the `--check-major` / `--check-minor` / `--check-patch` alerts, `--offset-eol`, `--always-ok` and what happens when endoflife.date cannot be reached work the same way in every endoflife.date-based version plugin. They are described in [Version Plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-version/). In addition:

* WARN if `mongod` refuses to run on this host, as it logs a fatal startup error already for `--version`.
* WARN if `mongod --version` does not answer within `--timeout` (default: 8 seconds).
* UNKNOWN if `--path` does not point at a `mongod` binary.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mongodb-version | Number | Installed MongoDB version as float. For example, "8.0.38" becomes "8.000038". |


## Troubleshooting

### mongod refuses to run

`mongod refuses to run on this host: MongoDB cannot start: Linux kernel versions 6.19 and newer has a known incompatibility with this version of MongoDB.`

`mongod` runs its startup checks before it prints its version, so the server will not start either, for example after a reboot into a newer kernel. The message is the one `mongod` logs. For the kernel incompatibility of MongoDB 8.0, see [SERVER-121912](https://jira.mongodb.org/browse/SERVER-121912): upgrade to a MongoDB release that supports the kernel, or boot the previous kernel.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
