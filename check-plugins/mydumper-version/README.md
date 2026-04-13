# Check mydumper-version


## Overview

Checks whether a newer version of mydumper/myloader is available by comparing the locally installed version against the latest release from the GitHub API.

**Important Notes:**

* Requires `mydumper` to be installed and available in the system PATH

**Data Collection:**

* Runs `mydumper --version` locally to determine the installed version
* Queries the GitHub releases API for the latest version of `mydumper/mydumper`
* Caches the latest version information locally to reduce API calls (default: 24 hours)


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mydumper-version> |
| Nagios/Icinga Check Name              | `check_mydumper_version` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-monitoring-plugins-mydumper-version.db` |


## Help

```text
usage: mydumper-version [-h] [-V] [--always-ok] [--cache-expire CACHE_EXPIRE]
                        [--test TEST]

Checks if a newer version of mydumper is available by querying the GitHub
releases API. Alerts when the installed version is outdated.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --cache-expire CACHE_EXPIRE
                        The amount of time after which the credential/data
                        cache expires, in minutes. Default: 24
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
```


## Usage Examples

```bash
./mydumper-version --cache-expire 8 --always-ok
```

Output:

```text
mydumper/myloader v0.10.5 is up to date
```


## States

* OK if the installed version is up to date.
* WARN if a newer version is available.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mydumper-version | Number | Installed mydumper version as float. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
