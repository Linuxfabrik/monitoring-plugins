# Check apache-tomcat-version


## Overview

Checks the installed Apache Tomcat version against the endoflife.date API and alerts if the version is end-of-life or if newer major, minor, or patch releases are available. By default, alerts 30 days before the official EOL date. The offset is configurable.

**Important Notes:**

* Must run on the Tomcat server itself to detect the installed version
* Point `--catalina-home` at the Tomcat installation directory (CATALINA_HOME). The location depends on how Tomcat was installed:
    * `/usr/share/tomcat` on Red Hat family packages (default)
    * `/usr/share/tomcat10`, `/usr/share/tomcat9` and similar on Debian/Ubuntu packages (the path carries the major version)
    * the unpacked directory (often `/opt/tomcat`) for the upstream binary distribution

**Data Collection:**

* Detects the installed Apache Tomcat version by running `bin/version.sh`, which ships with the upstream distribution and the official container images
* Falls back to reading the version from `lib/catalina.jar` when `bin/version.sh` is absent, which is the case for Red Hat family packages
* Queries the [endoflife.date API](https://endoflife.date/api/tomcat.json) to determine EOL status and available releases
* Caches the API response in a local SQLite database to reduce network calls


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/apache-tomcat-version> |
| Nagios/Icinga Check Name              | `check_apache_tomcat_version` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-lib-version.db` |


## Help

```text
usage: apache-tomcat-version [-h] [-V] [--always-ok]
                             [--catalina-home CATALINA_HOME] [--check-major]
                             [--check-minor] [--check-patch] [--insecure]
                             [--no-proxy] [--offset-eol OFFSET_EOL]
                             [--timeout TIMEOUT]
                             [--unreachable-severity {ok,warn,crit,unknown}]

Checks the installed Apache Tomcat version against the endoflife.date API and
alerts if the version is end-of-life or if newer major, minor, or patch
releases are available. By default, alerts 30 days before the official EOL
date. The offset is configurable.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --catalina-home CATALINA_HOME
                        Tomcat installation directory (CATALINA_HOME)
                        containing `bin/version.sh`. Default:
                        /usr/share/tomcat
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
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --unreachable-severity {ok,warn,crit,unknown}
                        State to report when the online end-of-life source is
                        unreachable and the check falls back to the bundled
                        offline data. Default: ok
```


## Usage Examples

```bash
./apache-tomcat-version --catalina-home=/usr/share/tomcat --offset-eol=-30
```

Output:

```text
Apache Tomcat v10.1.49 (EOL unknown, major 11.0.23 available)
```


## States

* OK if the installed version is not EOL and no newer releases are flagged.
* WARN if the installed version is EOL (or will be within `--offset-eol` days, default: -30).
* WARN if `--check-major` is set and a newer major version is available.
* WARN if `--check-minor` is set and a newer minor version is available.
* WARN if `--check-patch` is set and a newer patch version is available.
* UNKNOWN if Apache Tomcat is not found.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| apache-tomcat-version | Number | Installed Apache Tomcat version as float, e.g. "10.1.49" becomes "10.149". |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
