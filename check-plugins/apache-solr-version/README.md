# Check apache-solr-version


## Overview

Checks the installed Apache Solr version against the endoflife.date API and alerts if the version is end-of-life or if newer major, minor, or patch releases are available. By default, alerts 30 days before the official EOL date. The offset is configurable.

**Important Notes:**

* Must run on the Apache Solr server itself to detect the installed version

**Data Collection:**

* Detects the installed Apache Solr version by running `<path> version` (default path: `/opt/solr/bin/solr`)
* Queries the [endoflife.date API](https://endoflife.date/api/solr.json) to determine EOL status and available releases
* Caches the API response in a local SQLite database to reduce network calls


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/apache-solr-version> |
| Nagios/Icinga Check Name              | `check_apache_solr_version` |
| Check Interval Recommendation         | Once a day |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-lib-version.db` |


## Help

```text
usage: apache-solr-version [-h] [-V] [--always-ok] [--check-major]
                           [--check-minor] [--check-patch] [--insecure]
                           [--no-proxy] [--offset-eol OFFSET_EOL]
                           [--path PATH] [--timeout TIMEOUT]

Checks the installed Apache Solr version against the endoflife.date API and
alerts if the version is end-of-life or if newer major, minor, or patch
releases are available. By default, alerts 30 days before the official EOL
date. The offset is configurable.

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
  --no-proxy            Do not use a proxy.
  --offset-eol OFFSET_EOL
                        Alert n days before ("-30") or after an EOL date ("30"
                        or "+30"). Default: -30 days
  --path PATH           Local path to your Apache Solr binary. Default:
                        /opt/solr/bin/solr
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
```


## Usage Examples

```bash
./apache-solr-version --offset-eol=-30
```

Output:

```text
Apache Solr v7.7.0 (version 7.7.0 unknown)
```


## States

* OK if the installed version is not EOL and no newer releases are flagged.
* WARN if the installed version is EOL (or will be within `--offset-eol` days, default: -30).
* WARN if `--check-major` is set and a newer major version is available.
* WARN if `--check-minor` is set and a newer minor version is available.
* WARN if `--check-patch` is set and a newer patch version is available.
* UNKNOWN if Apache Solr binary is not found at the configured path.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| apache-solr-version | Number | Installed Apache Solr version as float, e.g. "7.7.0" becomes "7.70". |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
