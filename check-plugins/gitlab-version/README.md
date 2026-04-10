# Check gitlab-version

## Overview

Checks the installed GitLab version against the endoflife.date API and alerts if the version is end-of-life or if newer major, minor, or patch releases are available. By default, alerts 30 days before the official EOL date. The offset is configurable.

**Important Notes:**

* The check must run locally on the GitLab server because it reads the version from a local file.


**Data Collection:**

* Reads the installed GitLab version from `/opt/gitlab/version-manifest.txt` (configurable via `--path`)
* Compares against the [endoflife.date API](https://endoflife.date/api/gitlab.json) to determine EOL status and available updates
* Caches API responses locally for 24 hours to reduce external requests

**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/gitlab-version> |
| Nagios/Icinga Check Name              | `check_gitlab_version` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-lib-version.db` |


## Help

```text
usage: gitlab-version [-h] [-V] [--always-ok] [--check-major] [--check-minor]
                      [--check-patch] [--insecure] [--no-proxy]
                      [--offset-eol OFFSET_EOL] [--path PATH]
                      [--timeout TIMEOUT]

Checks the installed GitLab version against the endoflife.date API and alerts
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
  --no-proxy            Do not use a proxy.
  --offset-eol OFFSET_EOL
                        Alert n days before ("-30") or after an EOL date ("30"
                        or "+30"). Default: -30 days
  --path PATH           Full path to GitLab's `version-manifest.txt`. Default:
                        /opt/gitlab/version-manifest.txt
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
```


## Usage Examples

```bash
./gitlab-version --offset-eol=-30
```

Output:

```text
GitLab v16.0.3 (EOL 2023-08-22 -30d [WARNING], minor 16.4.1 available, patch 16.0.8 available)
```


## States

* OK if the installed version is not EOL and no update alerts are configured.
* WARN if the installed version is EOL (considering `--offset-eol`, default: -30 days).
* WARN if `--check-major` is set and a new major version is available.
* WARN if `--check-minor` is set and a new minor version is available.
* WARN if `--check-patch` is set and a new patch version is available.
* UNKNOWN if GitLab is not found or the version file cannot be read.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| gitlab-version | Number | Installed GitLab version as float. For example, "16.0.3" becomes "16.03". |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
