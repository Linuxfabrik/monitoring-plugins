# Check gitlab-version


## Overview

Checks the installed GitLab version against the endoflife.date API and alerts if the version is end-of-life or if newer major, minor, or patch releases are available. By default, alerts 30 days before the official EOL date. The offset is configurable. Optionally also asks the public GitLab Version Check service whether the installed version has a security-relevant update available.

**Important Notes:**

* The check must run locally on the GitLab server because it reads the version from a local file.
* `--check-security` queries `https://version.gitlab.com/check.json`, the same public service the GitLab admin dashboard uses internally. No GitLab admin token is required.

**Data Collection:**

* Reads the installed GitLab version from `/opt/gitlab/version-manifest.txt` (configurable via `--path`)
* Compares against the [endoflife.date API](https://endoflife.date/api/gitlab.json) to determine EOL status and available updates
* With `--check-security`, additionally queries `https://version.gitlab.com/check.json` for the installed version and treats `severity != success` or `critical_vulnerability == true` as a warning
* Caches endoflife.date responses locally for 24 hours and security responses for 4 hours to reduce external requests


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/gitlab-version> |
| Nagios/Icinga Check Name              | `check_gitlab_version` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-lib-version.db` |


## Help

```text
usage: gitlab-version [-h] [-V] [--always-ok] [--check-major] [--check-minor]
                      [--check-patch] [--check-security] [--insecure]
                      [--no-proxy] [--offset-eol OFFSET_EOL] [--path PATH]
                      [--timeout TIMEOUT]

Checks the installed GitLab version against the endoflife.date API and alerts
if the version is end-of-life or if newer major, minor, or patch releases are
available. By default, alerts 30 days before the official EOL date. The offset
is configurable. Optionally also asks the public GitLab Version Check service
whether the installed version has a security-relevant update available.

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
  --check-security      Alert when the vendor version-check service reports a
                        security-relevant update for the currently installed
                        version (security severity, critical vulnerability or
                        similar). Requires online access to the vendor
                        service. Has no effect on plugins that do not
                        implement an upstream security check.
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

```bash
./gitlab-version --check-security
```

Output:

```text
GitLab v18.10.3, security update available (full support ended on 2026-04-16; EOL 2026-06-18 -30d, minor 18.11.0 available) [WARNING]
```


## States

* OK if the installed version is not EOL and no update alerts are configured.
* WARN if `--check-major` is set and a new major version is available.
* WARN if `--check-minor` is set and a new minor version is available.
* WARN if `--check-patch` is set and a new patch version is available.
* WARN if `--check-security` is set and GitLab reports a non-`success` severity or a critical vulnerability for the installed version.
* WARN if the installed version is EOL (considering `--offset-eol`, default: -30 days).
* UNKNOWN if `--check-security` is set and the GitLab Version Check service cannot be reached.
* UNKNOWN if GitLab is not found or the version file cannot be read.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| gitlab-version | Number | Installed GitLab version as float. For example, "16.0.3" becomes "16.03". |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
